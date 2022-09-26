#!/bin/bash

SSH_ENV=$HOME/.ssh/environment

# start the ssh-agent
function start_agent {
  echo "Initializing new SSH agent..."
  # spawn ssh-agent
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo Done
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  # add keys here
  find ~/.ssh -maxdepth 1 -type f -name 'id_*' | grep -v '\.pub$' | xargs ssh-add
}

if [[ ! -z $STY || ! -z $TMUX ]]; then
  echo "Running inside screen or tmux: attaching to an existing agent"
  export SSH_AUTH_SOCK=$(find /tmp -maxdepth 2 -type s -name "agent*" -user $USER -printf '%T@ %p\n' 2>/dev/null |sort -n|tail -1|cut -d' ' -f2)
  SSH_AGENT_PID=${SSH_AUTH_SOCK#*agent.}
  SSH_AGENT_PNAME='sshd'
elif [[ "$SSH_AUTH_SOCK" != "" ]]; then
  echo "SSH_AUTH_SOCK defined ($SSH_AUTH_SOCK): using forwarded agent"
  SSH_AGENT_PID=${SSH_AUTH_SOCK#*agent.}
  SSH_AGENT_PNAME='sshd'
elif [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  SSH_AGENT_PNAME='ssh-agent$'

  ([[ "$SSH_AGENT_PID" != "" ]] && ps -ef | grep ${SSH_AGENT_PID} | grep "$SSH_AGENT_PNAME" > /dev/null) || {
    start_agent;
  }
fi


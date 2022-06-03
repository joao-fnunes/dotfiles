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

if [[ "$SSH_AUTH_SOCK" != "" ]]; then
  echo "SSH_AUTH_SOCK defined (agent forwarding)"
  SSH_AGENT_PID=${SSH_AUTH_SOCK#*agent.}
  SSH_AGENT_PNAME='sshd'
elif [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  SSH_AGENT_PNAME='ssh-agent$'
fi

([[ "$SSH_AGENT_PID" != "" ]] && ps -ef | grep ${SSH_AGENT_PID} | grep "$SSH_AGENT_PNAME" > /dev/null) || {
  start_agent;
}

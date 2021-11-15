.PHONY: bootstrap install

bootstrap:
	ansible-playbook --connection local -i 127.0.0.1, bootstrap.yml --ask-become-pass

install:
	ansible-playbook --connection local -i 127.0.0.1, install.yml

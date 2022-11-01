# Automated Builder

The `automated_builder` folder contains ansible plays in order to streamline Whonix build automation. Github actions triggers these builds which run on a remote Digital Ocean VPS.

## Setup

### VM Setup
1. A Digital Ocean (or similar) Debian VPS must exist with the following configurations
  a) A user named `ansible` must exist
  b) SSH must be set up and ports open, with a key for `ansible` in `/home/users/ansible/.ssh/authorized_keys`.
  c) XFCE Desktop must be setup and running (use a VNC viewer such as tightvnc for inspecting and troubleshooting). See https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-debian-11 for reference. Note: A VNC passord is required for this, and should be stored securely.

### Environment variables
In the github repository settings, the variable `ANSIBLE_VAULT_PASSWORD` must be set to encrypt `automated_builder/vars/main.yml`

In the event you want to help maintain this piece, but don't have the password and want to use your own runner server, `automated_builder/vars/main.yml` has the following variables

```
VPS_IP: # Put your VPS ip here
SSH_KEY: |
  # Put the Ansible user's configured private key here
SSH_PUBLIC_KEY: |
  # Put the ansible user's configured public key here
```

then run `ansible-vault decrypt automated_builder/vars/main.yml` and enter a password to use in your fork. Enter it as your `ANSIBLE_VAULT_PASSWORD` as mentioned above

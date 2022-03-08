#!/usr/bin/env bash

# This lab uses Vagrant to ensure consistent development environments for all developers

# Add some color!
# Ref: https://stackoverflow.com/a/20983251
readonly GREEN=$(tput setaf 2)
readonly RESET=$(tput sgr0)

function info_() {
    local MESSAGE="$1"
    local PROMPT="\n\n>>> "

    echo -e "${GREEN}${PROMPT}${MESSAGE}${RESET}"
    return $?
}

# This function exits if its argument is not 0.
function exit_on_failure() {
    local RETURN_VALUE="$1"
    if [[ "${RETURN_VALUE}" -ne 0 ]]; then
        exit "${RETURN_VALUE}"
    fi
}

function main() {
    info_ "bootstrapping"
    sudo apt-get install --yes curl
    local OS_RELEASE
    OS_RELEASE=$(lsb_release --codename --short)

    # Ref: https://www.vagrantup.com/downloads
    info_ "installing vagrant"
    curl --fail --silent --show-error --location https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
        && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com ${OS_RELEASE} main" \
        && sudo apt-get update --yes \
        && sudo apt-get install --yes vagrant
    exit_on_failure $?

    # We use the VirtualBox provider with Vagrant
    # Ref: https://www.vagrantup.com/docs/providers
    # Ref: https://www.virtualbox.org/wiki/Linux_Downloads
    info_ "installing virtualbox"
    sudo apt-add-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian ${OS_RELEASE} contrib" \
        && sudo apt-get update --yes \
        && sudo apt-get install --yes virtualbox-6.1
    exit_on_failure $?

    # Ansible is used to provision local Virtual Machines (VM)
    # Ansible requires Python
    # `python3.9-distutils` is necessary to install pip
    info_ "installing python 3.9"
    sudo add-apt-repository ppa:deadsnakes/ppa \
        && sudo apt-get install --yes python3.9 python3.9-distutils python-setuptools
    exit_on_failure $?

    # Utils required for ansible
    info_ "installing utils required by ansible"
    sudo apt-get install --yes python3-pip python3.9-dev libxml2-dev libxslt-dev libssl-dev curl
    exit_on_failure $?

    # Install Ansible
    info_ "installing ansible"
    sudo python3.9 -m pip install --upgrade ansible
    exit_on_failure $?
}

main
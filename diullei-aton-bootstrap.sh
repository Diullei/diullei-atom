#!/usr/bin/env bash

# curl https://raw.githubusercontent.com/Diullei/diullei-atom/master/diullei-aton-bootstrap.sh -L > diullei-aton-bootstrap.sh && sh diullei-aton-bootstrap.sh

############################  SETUP PARAMETERS
app_name='diullei-atom'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.diullei-atom"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/diullei/diullei-atom.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='master'
debug_mode='0'
fork_maintainer='0'

############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    type $1 >/dev/null 2>&1 || { local ret='1'; }

    # throw error on non-zero return value
    if [ ! "$ret" -eq '0' ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

############################ SETUP FUNCTIONS

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ]; then
        msg "Attempting to back up your original atom configuration."
        today=`date +%Y%m%d_%s`
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today";
        done
        ret="$?"
        success "Your original atom configuration has been backed up."
        debug
   fi
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    debug
}

istall_packages() {
    local repo_path="$1"

    msg "Trying to install atom packages"

    apm install --packages-file "$repo_path"/package-list.txt

    success "Successfully. All packages has been installed"

    debug
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    ln -s "$source_path" "$target_path"/.atom

    ret="$?"
    success "Setting up atom symlinks."
    debug
}

############################ MAIN()
variable_set "$HOME"
program_exists  "atom"
program_exists  "apm"
program_exists  "git"

do_backup       "$HOME/.atom"

sync_repo       "$APP_PATH" \
                "$REPO_URI" \
                "$REPO_BRANCH" \
                "$app_name"

create_symlinks "$APP_PATH" \
                "$HOME"

istall_packages "$APP_PATH"

msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` https://github.com/diullei/diullei-atom"

#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

# file
ln -sf ${SCRIPT_DIR}/.bash_profile $HOME/.bash_profile
ln -sf ${SCRIPT_DIR}/.bashrc $HOME/.bashrc
ln -sf ${SCRIPT_DIR}/.vimrc $HOME/.vimrc
ln -sf ${SCRIPT_DIR}/.gitconfig $HOME/.gitconfig
ln -sf ${SCRIPT_DIR}/.gitignore_global $HOME/.gitignore_global

# directory (2重にsymlinkを作らないようにする)
if [[ ! -L "$HOME/.vim" ]]; then
    ln -s ${SCRIPT_DIR}/.vim $HOME/.vim
fi
if [[ ! -L "$HOME/.config/brewfile" ]]; then
    ln -s ${SCRIPT_DIR}/.config/brewfile $HOME/.config/brewfile
fi

# molokai.vim
(cd ${SCRIPT_DIR}; git submodule update --init)

# vscode
if [[ -e "$HOME/Library/Application Support/Code/User/" ]]; then
    ln -sf ${SCRIPT_DIR}/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"
    ln -sf ${SCRIPT_DIR}/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
fi

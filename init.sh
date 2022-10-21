#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

# file
ln -sf ${SCRIPT_DIR}/.bash_profile $HOME/.bash_profile
ln -sf ${SCRIPT_DIR}/.bashrc $HOME/.bashrc
ln -sf ${SCRIPT_DIR}/.vimrc $HOME/.vimrc

# vim (2重にsymlinkを作らないようにする)
if [[ ! -L "$HOME/.vim" ]]; then
    ln -s ${SCRIPT_DIR}/.vim $HOME/.vim
fi

# molokai.vim
(cd ${SCRIPT_DIR}; git submodule update --init)

# git
if [[ ! -L "$HOME/.config/git" ]]; then
    ln -s ${SCRIPT_DIR}/.config/git $HOME/.config/git
fi

# karabiner
if [[ ! -L "$HOME/.config/karabiner" ]]; then
    ln -s ${SCRIPT_DIR}/.config/karabiner $HOME/.config/karabiner
fi

# vscode
if [[ -e "$HOME/Library/Application Support/Code/User/" ]]; then
    ln -sf ${SCRIPT_DIR}/etc/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"
    ln -sf ${SCRIPT_DIR}/etc/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
fi

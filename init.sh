#! /bin/bash
ln -s ~/dotfiles/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vim ~/.vim
ln -s ~/dotfiles/.vimrc ~/.vimrc

# subl
chmod +x ~/dotfiles/bin/subl.sh
ln -s ~/dotfiles/bin/subl.sh /usr/local/bin/subl

# rperm
chmod +x ~/dotfiles/bin/rperm.sh
ln -s ~/dotfiles/bin/rperm.sh /usr/local/bin/rperm
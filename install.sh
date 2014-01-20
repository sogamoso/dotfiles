cp -fv $PWD/bash_profile ~/.bash_profile
cp -fv $PWD/bashrc ~/.bashrc

mkdir -pv ~/.gitt
ln -sFv $PWD/git/gitconfig ~/.gitconfig
ln -sFv $PWD/git/githelpers ~/.githelpers
ln -sFv $PWD/git/gitignore ~/.gitignore
ln -sFv $PWD/git/aliases ~/.gitt/aliases

mkdir -pv ~/.ruby
ln -sFv $PWD/ruby/gemrc ~/.gemrc
ln -sFv $PWD/ruby/irbrc ~/.irbrc
ln -sFv $PWD/ruby/aliases ~/.ruby/aliases
ln -sFv $PWD/ruby/rbenv ~/.ruby/rbenv

mkdir -pv ~/.vim/colors
ln -sFv $PWD/vim/vimrc ~/.vimrc
ln -sFv $PWD/vim/vimrc.bundles ~/.vimrc.bundles
ln -sFv $PWD/vim/vividchalk.vim ~/.vim/colors/vividchalk.vim

mkdir -pv ~/.bash
ln -sFv $PWD/bash/aliases ~/.bash/aliases
ln -sFv $PWD/bash/git_completion.bash ~/.bash/git_completion.bash

mkdir -pv ~/.system
ln -sFv $PWD/system/aliases ~/.system/aliases
ln -sFv $PWD/system/config ~/.system/config
ln -sFv $PWD/system/env ~/.system/env
ln -sFv $PWD/system/path ~/.system/path

source ~/.bashrc
source ~/.bash_profile

if [ ! -d ~/.vim/bundle/vundle ]; then
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

vim +BundleInstall +qall

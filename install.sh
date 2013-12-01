cp -fi ./bash_profile ~/.bash_profile
cp -fi ./bashrc ~/.bashrc

cp -fi ./git/gitconfig ~/.gitconfig
cp -fi ./git/githelpers ~/.githelpers
cp -fi ./git/gitignore ~/.gitignore
cp -fi ./ruby/gemrc ~/.gemrc
cp -fi ./ruby/irbrc ~/.irbrc
cp -fi ./vim/vimrc ~/.vimrc
cp -fi ./vim/vimrc.bundles ~/.vimrc.bundles
cp -fi ./vim/railscasts.vim ~/.vim/colors/railscasts.vim

cp -fi ./bash/aliases ~/.bash/aliases
cp -fi ./bash/git_completion.bash ~/.bash/git_completion.bash
cp -fi ./git/aliases ~/.gitt/aliases
cp -fi ./ruby/aliases ~/.ruby/aliases
cp -fi ./ruby/rbenv ~/.ruby/rbenv
cp -fi ./system/aliases ~/.system/aliases
cp -fi ./system/config ~/.system/config
cp -fi ./system/env ~/.system/env
cp -fi ./system/path ~/.system/path

source ~/.bashrc
source ~/.bash_profile

vim +BundleInstall +qall

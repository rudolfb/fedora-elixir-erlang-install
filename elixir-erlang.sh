#!/usr/bin/env bash

add_to_file_if_not_exists() {
  LINESEARCH=$1
  LINEREPLACE=$2
  FILE=$3
  grep -qF "$LINESEARCH" "$FILE" || echo -e $LINEREPLACE >> "$FILE"
}

asdf_install () {
  APPNAME=$1
  # Get the last line in the version number string (sed -e '$!d'). This will be the latest version available for the application.
  LATEST_VERSION=$(asdf list-all $APPNAME | sed -e '$!d')
  echo $APPNAME: $LATEST_VERSION
  asdf install $APPNAME $LATEST_VERSION
  asdf global $APPNAME $LATEST_VERSION
}

# Install prerequisites for Erlang
sudo dnf upgrade -y
sudo dnf install make automake gcc gcc-c++ kernel-devel git wget openssl-devel ncurses-devel wxBase3 wxGTK3-devel m4 nodejs inotify-tools fop -y

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.3.0

# For asdf and Ubuntu or other linux distros
add_to_file_if_not_exists '. $HOME/.asdf/asdf.sh' '\n. $HOME/.asdf/asdf.sh' ~/.bashrc
add_to_file_if_not_exists '. $HOME/.asdf/completions/asdf.bash' '\n. $HOME/.asdf/completions/asdf.bash' ~/.bashrc

#Reloads the .bashrc for asdf, without needing to log in and out again
. ~/.bashrc
# This does not seem to work, so perform these steps manually within this session
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add elm https://github.com/vic/asdf-elm.git
asdf plugin-update --all


asdf_install "erlang"
asdf_install "elixir"
asdf_install "elm"

source ~/.bash_profile

# git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.3.0
# echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
# echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
# 
# asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
# asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
# 
# asdf list-all erlang
# asdf list-all elixir
# 
# asdf install erlang 19.3
# asdf install elixir 1.4.4
# 
# asdf global erlang 19.3
# asdf global elixir 1.4.4

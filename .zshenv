##### .zshenv #####

#-------------------------------------------------
# Internal Functions
#
# executable check function
_executable() {
  return $(whence $1 >/dev/null)
}

#-------------------------------------------------
# Enviroment Valiable
#
path=($HOME/.local/bin(N-/) $path)

if [[ -z "${ld_library_path}" ]]; then
  typeset -T LD_LIBRARY_PATH ld_library_path
fi
ld_library_path=(${HOME}/.local/lib(N-/) $ld_library_path)

typeset -U path ld_library_path
export PATH LD_LIBRARY_PATH

export EDITOR=vim
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"
export PAGER=less

# XDG Base Directory
export XDG_CONFIG_HOME="${HOME}"/.config
export XDG_DATA_HOME="${HOME}"/.local/share
export XDG_CACHE_HOME="${HOME}"/.cache

# XDG Base Directory Support
export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc
export GVIMINIT=":source $XDG_CONFIG_HOME"/vim/gvimrc

# 補完
[[ -d $HOME/.zsh/completion ]] && fpath=(~/.zsh/completion $fpath)

# export JAVA_HOME=$HOME/.local/share/jdk1.8.0_202
# path=($JAVA_HOME/bin(N-/) $path)

#-------------------------------------------------
#
# rust
# add ./cargo/bin to $path
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env

# haskell
# add ghcup
[[ -f $HOME/.ghcup/env ]] && source $HOME/.ghcup/env

# rbenv initialize
# if _executable rbenv; then
#   eval "$(rbenv init -)"
# fi

# nvm
if [[ -d $HOME/.nvm ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

##### .zshenv #####

#-------------------------------------------------
# PATH
#
if [ -d $HOME/.cargo/bin ]; then
  path=($HOME/.cargo/bin(N-/) $path)
fi

path=($HOME/.local/bin(N-/) $path)

if [ -z "${ld_library_path}" ]; then
  typeset -T LD_LIBRARY_PATH ld_library_path
fi
ld_library_path=(${HOME}/.local/lib(N-/) $ld_library_path)

typeset -U path ld_library_path
export PATH LD_LIBRARY_PATH

# rbenv initialize
if type rbenv > /dev/null 2>&1 ; then
  eval "$(rbenv init -)"
fi

#-------------------------------------------------
#
export EDITOR=vim
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"
export PAGER=less

# export JAVA_HOME=$HOME/.local/share/jdk1.8.0_202
# path=($JAVA_HOME/bin(N-/) $path)

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

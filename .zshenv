##### .zshenv #####

#-------------------------------------------------
# PATH
#
# $B=EJ#$7$?%Q%9$rEPO?$7$J$$(B
typeset -U path

path=($HOME/.local/bin(N-/) $path)

# rbenv initialize
if type rbenv > /dev/null 2>&1 ; then
  eval "$(rbenv init -)"
fi

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

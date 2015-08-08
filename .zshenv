##### .zshenv #####

#-------------------------------------------------
# PATH
#
# 重複したパスを登録しない
typeset -U path

path=($HOME/.local/bin(N-/) $path)

# rbenv initialize
if type rbenv > /dev/null 2>&1 ; then
  eval "$(rbenv init -)"
fi

#-------------------------------------------------
# 環境変数
#
export EDITOR=vim
export PAGER=lv

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

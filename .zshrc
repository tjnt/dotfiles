##### .zshrc #####

#-------------------------------------------------
# umask
#
# file rw-r--r--
# directory rwxr-xr-x
umask 022

#-------------------------------------------------
# 見た目に関する設定
#
# 色を使用出来るようにする
autoload -Uz colors
colors

# 左プロンプト
if [ ${UID} = 0 ]; then
  # PROMPT="%{$fg_bold[red]%}%n@%m:%~%#%{$reset_color%} "
  PROMPT="%F{red}%B%n@%m:%~%#%b%f "
else
  PROMPT="%B%n@%m:%~%#%b "
fi
# 右プロンプト
# RPROMPT='%B%~%b'
# RPROMPT="%(?.%F{green}%Bヾ（ﾟω ﾟ）ﾉﾞ%b%f.%F{red}%Bヾ（ﾟд ﾟ）ﾉﾞ%b%f)"

#-------------------------------------------------
# History
#
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# コマンドの実行時間もヒストリに記録
setopt extended_history
# 同じコマンドを連続して実行した場合、ヒストリには一つしか記録しない
setopt hist_ignore_dups
# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
# historyコマンドはヒストリに追加しない
setopt hist_no_store
# 複数セッションでヒストリを共有
# setopt share_history

#-------------------------------------------------
# Completion
#
# 補完機能を有効にする
autoload -U +X compinit && compinit -u
autoload -U +X bashcompinit && bashcompinit
# 補完候補を詰めて表示する
setopt list_packed
# 末尾のスラッシュを削除しない
#setopt noautoremoveslash
# 補完前にエイリアスをオリジナルのコマンドに展開
setopt complete_aliases
# 小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..
# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
    /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

#-------------------------------------------------
# File glob
#
# 拡張グロブを使用する
setopt extended_glob
# ファイルグロブで数値パターンがマッチすれば数値でソート
setopt numeric_glob_sort

#-------------------------------------------------
# Change Directory
#
# ディレクトリ名で移動
setopt auto_cd
# 自動的にディレクトリスタックに追加 "cd -[tab]"で移動
setopt auto_pushd
# ディレクトリスタックに重複を登録しない
setopt pushd_ignore_dups

#-------------------------------------------------
# Other option
#
# 日本語ファイル名など8bit目を通す
setopt print_eight_bit
# ビープ音を消す
setopt no_beep
# コマンドのスペル訂正を試みる
#setopt correct
# Ctrl-Dでログアウトするのを抑制する
#setopt ignore_eof
# フローコントロールを無効にする
setopt no_flow_control
# '#' 以降をコメントとして扱う
setopt interactive_comments

#-------------------------------------------------
# KeyBind
#
# emacsキーバインド
bindkey -e

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

#-------------------------------------------------
# Alias
#
# ls
eval "`dircolors -b`"
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lf='ls -F'
alias lla='ls -la'
alias llf='ls -lF'
alias ltr='ls -ltr'
# -iで確認 -vで詳細表示
# nocorrectスペル訂正をしない
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias ln='ln -v'
alias mkdir='mkdir -p'
# grep
alias grep='grep --color'
# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '
# python
alias python='python3'
alias venv='python3 -m venv'
# other alias
alias jobs='jobs -l'
alias dirs='dirs -v'
alias lv='lv -c'
alias vi='vim'
# グローバルエイリアス
alias -g G='| grep'
if type -p lv >/dev/null 2>&1; then
  alias -g L='| lv'
else
  alias -g L='| less'
fi

#-------------------------------------------------
# Functions
#
# backup
bk() {
  cp -rp "$1" "$1_`date +%y%m%d%H%M`"
}

# calc
calc() {
  awk "BEGIN { print $* }"
}

# ranger
# Start new ranger instance only if it's not running in current shell
rg() {
  if [ -z "$RANGER_LEVEL" ]; then
    ranger
  else
    exit
  fi
}

#-------------------------------------------------
# その他の設定
#
# ctrl-sによる端末ロックを無効化
stty stop undef
# stackのサブコマンドを補完する
eval "$(stack --bash-completion-script stack)"

#-------------------------------------------------
# tmux
#
# tmux自動起動
is_screen_running() {
  # tscreen also uses this varariable.
  [ ! -z "$WINDOW" ]
}
is_tmux_runnning() {
  [ ! -z "$TMUX" ]
}
is_screen_or_tmux_running() {
  is_screen_running || is_tmux_runnning
}
shell_has_started_interactively() {
  [ ! -z "$PS1" ]
}
if ! is_screen_or_tmux_running && shell_has_started_interactively; then
  for cmd in tmux tscreen screen; do
    if type -p $cmd >/dev/null 2>/dev/null; then
      eval $cmd
      break
    fi
  done
fi

# alias
alias tls='tmux ls'
alias tat='tmux attach -t'

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

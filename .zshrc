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

# プロンプト
local c1='009', c2='104', c3='084', c4='196'
local mark="%B%F{${c1}}%# %f%b"
local userhost="%B%F{${c1}}%n@%m:%f%b"
local location="%B%F{$c2}%~%f%b"
local number_of_jobs="%(1j.%F{${c1}} | %f%B%F{${c3}}%j%b%f.)"
local status_code="%(?,,%F{${c1}} > %f%B%F{${c4}}%?%f%b)"
PROMPT="${userhost}${location}${number_of_jobs}${status_code}
${mark}"

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd() { vcs_info }
RPROMPT='${vcs_info_msg_0_}'

# 補完候補の色表示
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#-------------------------------------------------
# History
#
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
# コマンドの実行時間もヒストリに記録
setopt extended_history
# 同じコマンドを連続して実行した場合、ヒストリには一つしか記録しない
# setopt hist_ignore_dups
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
# historyコマンドはヒストリに追加しない
setopt hist_no_store
# 複数セッションでヒストリを共有
setopt share_history
# シェルの終了を待たずに履歴を保存
setopt inc_append_history

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

# Edit command lineを有効
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

#-------------------------------------------------
# Alias
#
# ls
eval "`dircolors -b`"
if _executable lsd; then
  alias ls='lsd'
else
  alias ls='ls --color=auto'
fi
alias l='ls'
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
alias grep='grep --color=auto'
# diff
alias diff='diff --color=auto'
# sudo の後のコマンドでエイリアスを有効にする
# alias sudo='sudo '
# git
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gs='git status'
alias gd='git diff'
alias gf='git fetch'
alias gm='git merge'
alias gb='git branch'
alias gco='git checkout'
alias gps='git push'
alias gpl='git pull'
alias gl='git log'
alias gll='git log --oneline'
alias glg='git log --oneline --graph'
# python
alias python='python3'
alias pip='python3 -m pip'
alias pdb='python3 -m pdb'
alias venv='python3 -m venv'
# other alias
alias jobs='jobs -l'
alias dirs='dirs -v'
alias lv='lv -c'
alias vi='vim'
alias open='xdg-open'
alias standby='xset dpms force standby'
# translate-shell
if _executable trans; then
  alias transJ='trans -shell -brief ja:en'
  alias transE='trans -shell -brief en:ja'
fi

# グローバルエイリアス
alias -g A='| awk'
alias -g C='| xclip -i -selection clipboard'
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g L='| $PAGER'
alias -g X='| xargs'

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
  if [[ -z "$RANGER_LEVEL" ]]; then
    ranger
  else
    exit
  fi
}

# man color
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# xdg
# 現在の関連付けを表示
xdg-default-show() {
  if [[ $# -ne 1 ]]; then
    echo 'Usage: xdg-default-show [filepath]' >&2
    return 1
  fi
  local file="$1"
  local mime=$(xdg-mime query filetype "$file")
  xdg-mime query default "$mime"
}

# 関連付けを登録
xdg-default-regist() {
  if [[ $# -ne 2 ]]; then
    echo 'Usage: xdg-default-regist [application] [filepath]' >&2
    return 1
  fi
  local app="$1"
  local file="$2"
  local desktop=$(find /usr/share/applications -name "${app}.desktop")
  if [[ ! -n "$desktop" ]]; then
    echo 'desktop entry not found.' >&2
    return 1
  fi
  local mime=$(xdg-mime query filetype "$file")
  if [[ "$mime" == 'inode/x-empty' ]]; then
    echo 'mime type x-empty.' >&2
    return 1
  fi
  xdg-mime default "${desktop##*/}" "$mime"
}

# anacondaをパスに追加してプロンプトを変える
anaconda() {
  path=($HOME/.local/anaconda3/bin(N-/) $path)
  PROMPT="%B%F{228}[anaconda] %f%b${PROMPT}"
  export ANACONDA=1
  unset -f anaconda
}

#-------------------------------------------------
# その他の設定
#
# 画面出力のstart/stopを無効化
stty start undef
stty stop undef

# msys/mingwで補完を有効にする
if [[ ! -v $COMSPEC ]]; then
  drives=$(mount | sed -rn 's#^[A-Z]: on /([a-z]).*#\1#p' | tr '\n' ' ')
  zstyle ':completion:*' fake-files /: "/:$drives"
  unset drives
fi

#-------------------------------------------------
# tmux
#
if _executable tmux; then
  # tmux自動起動
  # !!disable!!
  #     tmux runs with terminal commandline arguments
  #
  # is_screen_running() {
  #   # tscreen also uses this varariable.
  #   [[ ! -z "$WINDOW" ]]
  # }
  # is_tmux_runnning() {
  #   [[ ! -z "$TMUX" ]]
  # }
  # is_screen_or_tmux_running() {
  #   is_screen_running || is_tmux_runnning
  # }
  # shell_has_started_interactively() {
  #   [[ ! -z "$PS1" ]]
  # }
  # if ! is_screen_or_tmux_running && shell_has_started_interactively; then
  #   for cmd in tmux tscreen screen; do
  #     if _executable "$cmd"; then
  #       eval "$cmd"
  #       break
  #     fi
  #   done
  # fi

  # alias
  alias tls='tmux ls'
  alias tat='tmux attach -t'
fi

#-------------------------------------------------
# プラグインのロード
#
if [[ -f ~/.zplug/init.zsh ]]; then
  unset PROMPT RPROMPT # pureのプロンプトを使うためクリア

  source ~/.zplug/init.zsh

  zplug 'zplug/zplug', hook-build:'zplug --self-manage'
  zplug 'mafredri/zsh-async', from:github
  zplug 'sindresorhus/pure', use:pure.zsh, from:github, as:theme
  zplug 'zsh-users/zsh-syntax-highlighting', defer:2
  zplug 'zsh-users/zsh-completions'
  zplug 'zsh-users/zsh-autosuggestions'
  zplug 'junegunn/fzf-bin', as:command, from:gh-r, rename-to:fzf
  zplug 'junegunn/fzf', as:command, use:bin/fzf-tmux
  zplug 'junegunn/fzf', use:shell/key-bindings.zsh
  zplug 'junegunn/fzf', use:shell/completion.zsh

  if ! zplug check --verbose; then
    printf 'Install? [y/N]: '
    if read -q; then
      echo; zplug install
    fi
  fi

  zplug load
fi

install_zplug() {
  curl -sL --proto-redir -all,https \
    https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
}

#-------------------------------------------------
# fzf
#
if _executable fzf; then
  export FZF_DEFAULT_COMMAND='ag --nocolor --hidden -g ""'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

  # fd - cd to selected directory
  fd() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune \
                       -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
  }

  # fda - including hidden directories
  fda() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
  }

  # fdr - cd to selected parent directory
  fdr() {
    local declare dirs=()
    get_parent_dirs() {
      [[ -d "${1}" ]] && dirs+=("$1")
      if [[ "${1}" == '/' ]]; then
        for _dir in "${dirs[@]}"; do echo $_dir; done
      else
        get_parent_dirs $(dirname "$1")
      fi
    }
    local dir=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf +m --tac)
    cd "$dir"
  }

  # fe - Open the selected file with the default editor
  fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
  }

  # fe - Open the selected file with xdg-open
  fo() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && xdg-open "${files[@]}" 2> /dev/null
  }

  # fkill - kill processes
  fkill() {
    local pid
    pid=$(ps -fu $UID | sed 1d | fzf -m | awk '{print $2}')
    [[ -n $pid ]] && echo $pid | xargs kill -${1:-15}
  }
fi

#-------------------------------------------------
# clipboard
#
if _executable fzf && _executable clipc; then
  alias clip='clip_fzf'

  clip_fzf() {
    local recid=$(clipc --list | fzf | awk '{print $1}')
    [[ -n $recid ]] && clipc --select $recid
  }
fi

# vim:set expandtab ft=sh ts=2 sts=2 sw=2:

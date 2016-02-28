"
" .vimrc
"
"

" 基本設定 {{{1
"
" 起動時間の計測
if has('vim_starting') && has('reltime')
  let g:startuptime = reltime()
  augroup ag_vimrc_startuptime
    au! VimEnter * let g:startuptime = reltime(g:startuptime) | redraw |
                 \ echomsg 'startuptime: '.reltimestr(g:startuptime)
  augroup END
endif

" Vi互換モードをオフ（Vimの拡張機能を有効）
set nocompatible

" エラー時の音とビジュアルベルの抑制(gvimは.gvimrcで設定)
set noerrorbells
set novisualbell
" set visualbell t_vb=

" <LEADER>の変更
let mapleader = ','
let g:mapleader = ','

let g:is_windows = has('win16') || has('win32') || has('win64')

" パスの区切り文字に/を使えるようにする
if g:is_windows
  set shellslash
endif


" エンコーディング設定 {{{1
"
if &encoding !=? 'utf-8'
  let &termencoding = &encoding
  set encoding=utf-8
endif

scriptencoding utf-8

if has('guess_encode')
  set fileencodings=ucs-bom,iso-2022-jp,guess,euc-jp,cp932,utf-8
else
  set fileencodings=ucs-bom,iso-2022-jp,euc-jp,cp932,utf-8
endif

set fileformats=unix,dos,mac

" 新規バッファ生成時のエンコードを指定
if has('vim_starting')
  set fileencoding=utf-8
endif


" 環境変数の設定 {{{1
"
if has('vim_starting')
  let $VIMLOCAL = expand('$HOME/.vim')
  if g:is_windows
    set runtimepath+=$VIMLOCAL
    if isdirectory(expand('$VIMLOCAL/bin'))
      let $PATH = $PATH.';'.expand('$VIMLOCAL/bin')
    endif
  endif
endif


" 共通関数 {{{1
"
" 設定ファイルのフルパス取得
function! s:rc_path(name)
  return expand('$HOME/.'.a:name)
endfunction

" ファイルがあったら実行
function! s:source_ifexists(file)
  if filereadable(a:file)
    exe 'source '.a:file
  endif
endfunction

" プラグイン存在チェック
function! s:has_plugin(name)
  return globpath(&runtimepath, 'plugin/'.a:name.'.vim') !=# '' ||
       \ globpath(&runtimepath, 'autoload/'.a:name.'.vim') !=# ''
endfunction
command! -nargs=1 HasPlugin echomsg <SID>has_plugin(<q-args>)

" global関数格納変数
let g:myfuncs = {}

" 外部コマンド実行
function! g:myfuncs.bang(cmd)
  let caller = s:has_plugin('vimproc') ? 'VimProcBang' : '!'
  exe caller.' '.a:cmd
endfunction

function! g:myfuncs.read(cmd, bufopt)
  let caller = s:has_plugin('vimproc') ? 'VimProcRead' : '$read!'
  new
  if a:bufopt !=# ''
      exe 'setlocal '.a:bufopt
  endif
  exe caller.' '.a:cmd
  call cursor(1, 0)
endfunction

" 文字列末尾の改行を削除する
function! g:myfuncs.chomp(str)
  return matchstr(a:str, '\zs.*\ze\n')
endfunction

" 条件'pred'を満たすウィンドウを検索し、そのウィンドウ番号を返す
" 開いていないなら0を返す
function! g:myfuncs.find_window_if(pred)
  let winnr_save = winnr()
  let wincount = winnr("$")
  let i = 1
  while i <= wincount
    exe i."wincmd w"
    if eval(a:pred)
      exe winnr_save."wincmd w"
      return i
    endif
    let i = i + 1
  endwhile
  exe winnr_save."wincmd w"
  return 0
endfunction


" プラグインの読み込み {{{1
"
filetype off

" 標準添付されているプラグインの設定
"
" matchit.vim
if !exists('loaded_matchit')
  runtime macros/matchit.vim
  " 大文字小文字を区別しない
  let b:match_ignorecase = 1
  " 対応するペアのパターン
  let b:match_words = &matchpairs.',' .
        \ '<begin>:<end>,'.
        \ '<if>:<endif>,'.
        \ '<function>:<endfunction>,'
endif

" 外部プラグインの設定
" .pluginrcが存在する場合は読み込む
call s:source_ifexists(s:rc_path('pluginrc'))

" ファイルタイププラグインを有効にする
filetype indent plugin on


" 画面表示に関する設定 {{{1
"
" 行番号を表示 (nonumber:非表示)
set number
" 相対行番号表示(7.3)
" if version >= 703
"   set relativenumber
" endif
" ルーラーを表示 (noruler:非表示)
set ruler
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
"ステータスラインの表示フォーマット
"set statusline=%<%f\ %m%r%h%w[ft:%{&ft}][fenc:%{&fenc}][ffmt:%{&ff}][bomb:%{&bomb}][ascii:\%03.3b][hex:\%02.2B]%=%c,%l/%L%10p%%
set statusline=%t\ %m%r%h%w%<[buf:%n][ftyp:%{&ft}][enc:%{&enc}][fenc:%{&fenc}][ffmt:%{&ff}][bomb:%{&bomb}][ascii:\%03.3B]%=%3p%%%3c,%l/%L
" コマンドをステータス行に表示
set showcmd
" コマンドラインの高さ (gvimはgvimrcで指定)
set cmdheight=2
" 画面最後の行をできる限り表示する
set display=lastline
" タイトルを表示
set title
" カーソルライン非表示
set nocursorline
" スプラッシュ(起動時のメッセージ)を表示しない
set shortmess+=I
" 全てのウィンドウのサイズを同じにする
" set equalalways
" マクロ実行中などの画面再描画を行わない
" WindowsXpまたはWindowテーマが「Windowsクラシック」で
" Google日本語入力を使用するとIビームカーソルが残る場合にも有効
set lazyredraw

" 文字表示に関する設定
"
" タブ、空白、改行等の不可視文字を表示する (nolist:非表示)
set nolist
" どの文字でタブや改行を表示するかを設定
"set listchars=tab:^\ ,trail:_,extends:»,precedes:«,nbsp:%
set listchars=tab:^\ ,trail:_,nbsp:%
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch matchtime=1
" □とか○の文字があってもカーソル位置がずれないようにする
if has('kaoriya') && g:is_windows && has('gui_running')
  set ambiwidth=auto
else
  set ambiwidth=double
endif

" シンタックスハイライトを有効にする
if &t_Co > 2 || has('gui_running')
  syntax on
endif

" コンソールでの見た目に関する設定
if !has('gui_running')
  " 背景を消してターミナル背景を表示
  augroup ag_remove_background_color
    au!
    au ColorScheme * highlight! Normal ctermbg=none
    au ColorScheme * highlight! NonText ctermbg=none
    au ColorScheme * highlight! LineNr ctermbg=none
  augroup END

  " カラースキーマ
  if &t_Co >= 256
    try
      colorscheme jellybeans
    catch
      colorscheme default
    endtry
  else
    colorschem default
  endif
endif


" 編集に関する設定 {{{1
"
" タブの画面上での幅
set tabstop=4
" Tabキーを押した時に挿入される空白の量 (0の場合はtabstopに合わせる)
set softtabstop=0
" シフト幅
set shiftwidth=4
" タブをスペースに展開しない (expandtab:展開する)
"set noexpandtab
set expandtab
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
" 新しい行を作ったときに高度な自動インデントを行う
set smartindent
"行頭の余白内で Tab を打ち込むと'shiftwidth' の数だけインデントする。
set smarttab
" バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
" カーソルキーで行末／行頭の移動可能に設定
"set whichwrap=b,s,[,],<,>
" Visual blockモードでフリーカーソルを有効にする
set virtualedit+=block
" w,bの移動で認識する文字
" set iskeyword=a-z,A-Z,48-57,_,.,-,>
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" コードの折りたたみの設定 (ziで有効/無効をトグルできる)
set nofoldenable
set foldmethod=syntax
set foldlevel=1
set foldnestmax=3
" 8進数を無効にする。<C-a>,<C-x>に影響する
set nrformats-=octal
" キーコードやマッピングされたキー列が完了するのを待つ時間(ミリ秒)
"set timeout timeoutlen=3000 ttimeoutlen=100
" 編集結果非保存のバッファから、新しいバッファを開くときに警告を出さない
set hidden
" ヒストリの保存数
set history=50
" ビジュアルモードで選択したテキストが、クリップボードに入るようにする
" set clipboard+=autoselect
" 無名レジスタに入るデータを*レジスタにも入れる(クリップボード使用)
set clipboard+=unnamed
if has("unix")
  set clipboard=unnamedplus
endif
" IMEOFFで起動する
set iminsert=0 imsearch=0
" tagsファイルを検索する際に、カレントバッファから上に辿って探す
set tags+=./tags
" 横分割で新しいウィンドウを下に開く
set splitbelow
" 縦分割で右に新しいウィンドウを開く
set splitright


" 検索の挙動に関する設定 {{{1
"
" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase
" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase
" インクリメンタルサーチ
set incsearch
" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan
" 検索結果をハイライト
set hlsearch


" ファイル操作に関する設定 {{{1
"
" 外部のエディタで編集中のファイルが変更されたら自動的に読み直す
set autoread
" バックアップファイルを作成する (作成しない:nobackup)
set backup
" バックアップファイルディレクトリ
set backupdir=$VIMLOCAL/tmp/backup
" スワップファイルの保存先
let &directory=$VIMLOCAL.'/tmp/swap'
" 再読込、vim終了後も継続するアンドゥ  (vim-user.jp hack-162)
if has('persistent_undo')
  set undodir=$VIMLOCAL/tmp/undo
  " 全ファイルでpersistent_undoを有効
  set undofile
  " 特定ファイルのみpersistent_undoを有効
"  augroup ag_vimrc_undofile
"    au!
"    au BufReadPre ~/* setlocal undofile
"  augroup END
endif


" キーマッピング {{{1
"
" スペースキーでスクロール
nnoremap <Space>   <C-e>
nnoremap <S-Space> <C-y>
vnoremap <Space>   <C-e>
vnoremap <S-Space> <C-y>

" Ctrl+SpaceでIME切り替え
inoremap <C-Space> <C-^>
cnoremap <C-Space> <C-^>
" ノーマルモードでは何もしない
nnoremap <C-Space> <Nop>
vnoremap <C-Space> <Nop>

" 折り返し行でも見た目の次の行へ移動する
nnoremap gj j
nnoremap gk k
nnoremap g$ $
vnoremap gj j
vnoremap gk k
vnoremap g$ $
" デフォルトのj,k,$をgj,gk,g$に割り当てる
nnoremap j gj
nnoremap k gk
nnoremap $ g$
vnoremap j gj
vnoremap k gk
vnoremap $ g$
" h,lは行末、行頭を超えることが可能に設定(whichwrap)
nnoremap h <Left>zv
nnoremap l <Right>zv

" Yで行末までコピー
nnoremap Y y$

" ビジュアルモード時vで行末まで選択
vnoremap v $h

" ビジュアルモード時Aで全選択
vnoremap A <ESC>gg0vG$h

" ビジュアルモード選択範囲を検索する
vnoremap / <ESC>/\%V
vnoremap ? <ESC>?\%V

" ビジュアルモード選択中の単語を検索
vnoremap <silent>* "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>

" 検索結果のハイライトをEsc連打でリセットする
noremap <silent><ESC><ESC> :<C-u>nohlsearch<CR>

" ;と:を入れ替える
" noremap ; :
" noremap : ;

" Ctrl+Enterで保存
map  <C-CR> :<C-u>w<CR>
imap <C-CR> <ESC>:<C-u>w<CR>
vmap <C-CR> <ESC>:<C-u>w<CR>

" Ctrl+h,j,k,lで分割ウィンドウ移動
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" タブキーで分割画面移動
nnoremap <Tab>   <C-w>w
nnoremap <S-Tab> <C-w><S-w>

" Ctrl+矢印で分割画面のサイズ変更
noremap <C-Up>    <C-w>+
noremap <C-Down>  <C-w>-
noremap <C-Right> <C-w>>
noremap <C-Left>  <C-w><

" qでウィンドウを閉じる
noremap <silent>q :<C-u>close<CR>
" Qでマクロ
noremap <silent>Q q

" バッファ操作のprefix
nnoremap [buf] <Nop>
nmap     <LEADER> [buf]

" バッファ一覧
nnoremap <silent>[buf]l :<C-u>ls<CR>

" バッファを閉じる
nnoremap <silent>[buf]d :<C-u>bdelete<CR>

" バッファ切り替え
nnoremap <silent>[buf]n :<C-u>bnext<CR>
nnoremap <silent>[buf]p :<C-u>bprevious<CR>
nnoremap <silent>[buf]1 :<C-u>e #1<CR>
nnoremap <silent>[buf]2 :<C-u>e #2<CR>
nnoremap <silent>[buf]3 :<C-u>e #3<CR>
nnoremap <silent>[buf]4 :<C-u>e #4<CR>
nnoremap <silent>[buf]5 :<C-u>e #5<CR>
nnoremap <silent>[buf]6 :<C-u>e #6<CR>
nnoremap <silent>[buf]7 :<C-u>e #7<CR>
nnoremap <silent>[buf]8 :<C-u>e #8<CR>
nnoremap <silent>[buf]9 :<C-u>e #9<CR>

" tab操作のprefix
nnoremap [tab] <Nop>
nmap     t [tab]

" [tab]+t 新しいタブ
noremap <silent>[tab]t :<C-u>tabnew<CR>
" [tab]+c タブを閉じる
noremap <silent>[tab]c :<C-u>tabclose<CR>

" [tab]+l / [tab]+h でタブ切り替え
noremap <silent>[tab]l :<C-u>tabnext<CR>
noremap <silent>[tab]h :<C-u>tabprevious<CR>

" [tab]+nでタブを右へ移動
function! s:tabmove_next()
  exe 'tabmove'.(tabpagenr() % tabpagenr('$'))
endfunction
noremap <silent>[tab]n :<C-u>call <SID>tabmove_next()<CR>

" [tab]+pでタブを左へ移動
function! s:tabmove_previous()
  exe 'tabmove'.(tabpagenr() == 1 ? tabpagenr('$') : tabpagenr()-2)
endfunction
noremap <silent>[tab]p :<C-u>call <SID>tabmove_previous()<CR>

function! s:quickfix_operation(direction)
  if g:myfuncs.find_window_if("&filetype == 'qf'")
    exe a:direction == 'd' ? 'cnext' : 'cprevious'
  else
    exe 'copen'
  endif
endfunction
" Ctrl+n Ctrl+n QuickFixで次へ
noremap <silent><C-n><C-n> :<C-u>call <SID>quickfix_operation('d')<CR>
" Ctrl+p Ctrl+p QuickFixで前へ
noremap <silent><C-p><C-p> :<C-u>call <SID>quickfix_operation('u')<CR>

" 括弧入力時に自動的に括弧の内側にカーソルを移動する
"inoremap {} {}<Left>
"inoremap [] []<Left>
"inoremap () ()<Left>
"inoremap “” “”<Left>
"inoremap ” ”<Left>
"inoremap <> <><Left>
"inoremap “ “<Left>

nnoremap [toggle] <Nop>
nmap     <LEADER><LEADER> [toggle]
" 不可視文字表示のトグル
noremap <silent>[toggle]l :<C-u>set list!<CR>
" カーソルライン表示のトグル
noremap <silent>[toggle]c :<C-u>set cursorline!<CR>
" タブ展開のトグル
noremap <silent>[toggle]e :<C-u>set expandtab!<CR>

" emacsキーバインド (インサートモード)
" inoremap <C-p> <Up>
" inoremap <C-n> <Down>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-e> <End>
inoremap <C-a> <Home>
inoremap <C-h> <Backspace>
inoremap <C-d> <Del>

" emacsキーバインド (コマンドモード)
" cnoremap <C-p> <Up>
" cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-e> <End>
cnoremap <C-a> <Home>
cnoremap <C-h> <Backspace>
cnoremap <C-d> <Del>

" Shortcut enc and ff.
cnoreabbrev ++u ++enc=utf8
cnoreabbrev ++c ++enc=cp932
cnoreabbrev ++s ++enc=cp932
cnoreabbrev ++e ++enc=euc-jp
cnoreabbrev ++j ++enc=iso-2022-jp
cnoreabbrev ++x ++ff=unix
cnoreabbrev ++d ++ff=dos
cnoreabbrev ++m ++ff=mac

" disable keymaps
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
noremap <C-z> <Nop>


" smooth scroll (smooth_scroll.vim) {{{2
"
" 重く感じるので無効...
" let g:scroll_factor = 5000
" function! s:smooth_scroll(dir, windiv, factor)
"    let wh=winheight(0)
"    let i=0
"    while i < wh / a:windiv
"       let t1=reltime()
"       let i = i + 1
"       if a:dir=="d"
"          silent normal! j
"       else
"          silent normal! k
"       end
"       redraw
"       while 1
"          let t2=reltime(t1,reltime())
"          if t2[1] > g:scroll_factor * a:factor
"             break
"          endif
"       endwhile
"    endwhile
" endfunction
" noremap <silent><C-D> :<C-u>call <SID>smooth_scroll("d",2, 2)<CR>
" noremap <silent><C-U> :<C-u>call <SID>smooth_scroll("u",2, 2)<CR>
" noremap <silent><C-F> :<C-u>call <SID>smooth_scroll("d",1, 1)<CR>
" noremap <silent><C-B> :<C-u>call <SID>smooth_scroll("u",1, 1)<CR>


" grep {{{2
"
" 使用するgrepの指定
let mygrepprg = 'internal'

" ビジュアルモード選択文字列取得
function! s:get_selected_string()
  let old_reg = getreg('a')
  let old_regmode = getregtype('a')
  silent normal! gv"ay
  let selected = @a
  call setreg('a', old_reg, old_regmode)
  return selected
endfunction

" grep関数共通処理
function! s:grep_func_main(word, target, option)
  if a:option == ''
    " no action
  endif
  if a:option == 's'
    split
  endif
  if a:option == 'v'
    vsplit
  endif
  if a:option == 't'
    tabnew
  endif
  echo 'grep 'a:word ' target 'a:target
  exe 'vimgrep /'.a:word.'/ 'a:target' | cw'
endfunction

function! s:grep_func(option)
  let word = expand("<cword>")
  let target = b:grep_target_file
  call s:grep_func_main(word, target, a:option)
endfunction

function! s:v_grep_func(option)
  let word = s:get_selected_string()
  let target = b:grep_target_file
  call s:grep_func_main(word, target, a:option)
endfunction

" g r でカーソル位置の単語をgrep
nnoremap gr :<C-u>call <SID>grep_func('')
" g s でカーソル位置の単語をgrep → 分割して開く
nnoremap gs :<C-u>call <SID>grep_func('s')
" g v でカーソル位置の単語をgrep → 縦分割して開く
nnoremap gv :<C-u>call <SID>grep_func('v')
" g t でカーソル位置の単語をgrep → 新しいタブで開く
nnoremap gt :<C-u>call <SID>grep_func('t')
" ビジュアルモード選択中文字列をgrep
vnoremap gr :<C-u>call <SID>v_grep_func('')
" ビジュアルモード選択中文字列をgrep → 分割して開く
vnoremap gs :<C-u>call <SID>v_grep_func('s')
" ビジュアルモード選択中文字列をgrep → 縦分割して開く
vnoremap gv :<C-u>call <SID>v_grep_func('v')
" ビジュアルモード選択中文字列をgrep → 新しいタブで開く
vnoremap gt :<C-u>call <SID>v_grep_func('t')


" タグジャンプ {{{2
"
" 分割ウィンドウでタグジャンプ
function! s:split_tagjump()
  try
    exe "normal! \<C-w>\<C-]>"
  catch
    " suppress error message
  endtry
endfunction
nnoremap <silent><C-]> :<C-u>call <SID>split_tagjump()<CR>

" Enterでタグジャンプ
function! s:tagjump_or_cr()
    try
      exe (bufname('%') == '[Command Line]' || &buftype == 'quickfix') ?
            \ "normal! \<CR>" : "normal! \<C-]>"
    catch
      " suppress error message
    endtry
endfunction
nnoremap <silent><Enter> :<C-u>call <SID>tagjump_or_cr()<CR>


" ユーザー定義コマンド {{{1
"
" ディレクトリ移動
command! -nargs=0 CC cd %:h
command! -nargs=0 CDV cd $VIM
command! -nargs=0 CDVL cd $VIMLOCAL
command! -nargs=0 CDH cd $HOME

" 保存せずに終了
command! -nargs=0 Q q!
" 全終了
command! -nargs=0 QQQ qall!

" 設定ファイルの再読み込み
" 本関数の実行中にvimrcの読み込みが行われ、
" 関数の再定義が失敗するため、起動時だけ定義するようにする
if has('vim_starting')
  function s:reload_rc()
    exe 'source '.s:rc_path('vimrc')
    if has('gui_running')
      exe 'source '.s:rc_path('gvimrc')
    endif
  endfunction
endif
command! -nargs=0 Reloadrc call <SID>reload_rc()

" 設定ファイルを開く
function! s:open_rc(name)
  exe 'edit '.s:rc_path(a:name)
endfunction
command! -nargs=0 Openvimrc call <SID>open_rc('vimrc')
command! -nargs=0 Opengvimrc call <SID>open_rc('gvimrc')
command! -nargs=0 Openpluginrc call <SID>open_rc('pluginrc')

" 保存前の状態とdiffをとる
command! -nargs=0 DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

" VDsplit (kaoriya - cmdex.vim)
command! -nargs=1 -complete=file VDsplit vertical diffsplit <args>

" 一時ファイルを作ることなくサクッと2つの範囲のdiffをとる方法。(VimWiki tips49)
" http://vimwiki.net/?tips%2F49
function! s:diff_clip(reg) range
  exe "let @a=@".a:reg
  exe a:firstline.",".a:lastline."y b"
  new
  " このウィンドウを閉じたらバッファを消去するようにする
  set buftype=nofile bufhidden=wipe
  put a
  diffthis
  vnew
  set buftype=nofile bufhidden=wipe
  put b
  diffthis
endfunction
command! -nargs=0 -range DiffClip <line1>, <line2>:call s:diff_clip('0')

" Undiff (kaoriya - cmdex.vim)
" カレントバッファのdiffモードを解除
command! -nargs=0 Undiff set nodiff noscrollbind wrap nocursorbind

" Scratch (kaoriya - cmdex.vim)
" 保存できない一時領域を作成
command! -nargs=0 Scratch new | setlocal bt=nofile noswf | let b:cmdex_scratch = 1
function! s:check_scratch_written()
  if &buftype ==# 'nofile' && expand('%').'x' !=# 'x' && exists('b:cmdex_scratch') && b:cmdex_scratch == 1
    setlocal buftype=swapfile
    unlet b:cmdex_scratch
  endif
endfunction
augroup CmdexScratch
  au!
  au BufWritePost * call <SID>check_scratch_written()
augroup END

" BufOnly (BufOnly.vim 簡易版)
" カレントバッファ以外を閉じる
function! s:buf_only(buffer, bang)
  if a:buffer == ''
    let buffer = bufnr('%')
  elseif (a:buffer + 0) > 0
    let buffer = bufnr(a:buffer + 0)
  else
    let buffer = bufnr(a:buffer)
  endif
  if buffer == -1
    return
  endif
  let last_buffer = bufnr('$')
  let n = 1
  while n <= last_buffer
    if n != buffer && buflisted(n)
      if a:bang == '' && getbufvar(n, '&modified')
        " modified buffer
      else
        silent exe 'bdel'.a:bang.' '.n
      endif
    endif
    let n = n+1
  endwhile
  redraw!
endfunction
command! -nargs=? -complete=buffer -bang BufOnly call <SID>buf_only(<q-args>, '<bang>')

" タグファイル生成
function! s:ctags_r()
  call g:myfuncs.bang('ctags -R')
  if s:has_plugin('neocomplete.vim')
    NeoCompleteTagMakeCache
  endif
endfunction
command! -nargs=0 Ctags call <SID>ctags_r()

" 行末の不要スペースを削除する
function! s:rtrim()
  let s:cursor = getpos(".")
  %s/\s\+$//e
  call setpos(".", s:cursor)
endfunction
command! -nargs=0 RTrim call <SID>rtrim()

" 定義されているマッピングを調べる (vim-user.jp hack-203)
" 全てのマッピングを表示
"   :AllMaps
" 現在のバッファで定義されたマッピングのみ表示
"   :AllMaps <buffer>
" どのスクリプトで定義されたかの情報も含め表示
"   :verbose AllMaps <buffer>
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args> | lmap <args>

" vimrcの行数を数える
function! s:count_vimrc()
  call g:myfuncs.bang(join(
          \ ['wc -l', s:rc_path('vimrc'), s:rc_path('gvimrc'), s:rc_path('pluginrc')], ' '))
endfunction
command! -nargs=0 CountVimrc call <SID>count_vimrc()

" Simple VCS Diff {{{2
function! s:vcs_diff(command, only)
  let target = a:only ? expand('%') : ''
  let bufopt = 'buftype=nofile bufhidden=wipe filetype=diff noswf '
  call g:myfuncs.read(a:command.' '.target, bufopt)
  unlet target
endfunction

" git diff
if executable('git')
  command! -nargs=0 GitDiff     call <SID>vcs_diff('git diff', 0)
  command! -nargs=0 GitDiffOnly call <SID>vcs_diff('git diff', 1)
endif

" svn diff
if executable('svn')
  command! -nargs=0 SvnDiff     call <SID>vcs_diff('svn diff', 0)
  command! -nargs=0 SvnDiffOnly call <SID>vcs_diff('svn diff', 1)
endif

" cvs diff
if executable('cvs')
  command! -nargs=0 CvsDiff     call <SID>vcs_diff('cvs diff', 0)
  command! -nargs=0 CvsDiffOnly call <SID>vcs_diff('cvs diff', 1)
endif

" C++向け環境の切り替え {{{2
if has('vim_starting')
  let CppEnv = {}
  let CppEnv.default = {
      \   'path': $PATH,
      \   'lib': $LIB,
      \   'libpath': $LIBPATH,
      \   'library_path': $LIBRARY_PATH,
      \   'include': $INCLUDE,
      \   'c_include_path': $C_INCLUDE_PATH,
      \   'cplus_include_path': $CPLUS_INCLUDE_PATH,
      \   'pa': &path,
      \ }
endif
let CppEnv.current_name = ''
let CppEnv.environment = {
      \   'gcc': {
      \     'path': [
      \         '/usr/local/bin',
      \         '/usr/bin',
      \         '/bin',
      \     ],
      \     'lib': [
      \         '/usr/local/lib',
      \         '/usr/lib',
      \         '/lib',
      \     ],
      \     'include': [
      \         '/usr/local/include',
      \         '/usr/include',
      \     ] +
      \     filter(
      \       split(glob('/usr/include/c++/*'), '\n') +
      \       split(glob('/usr/include/*/c++/*'), '\n'),
      \       'isdirectory(v:val)')
      \   },
      \   'mingw': {
      \     'path': [
      \         'C:\Opt\MinGW\bin',
      \         'C:\Opt\MinGW\msys\1.0\bin',
      \     ],
      \     'lib': [
      \         'C:\Opt\MinGW\lib',
      \     ],
      \     'include': [
      \         'C:\Opt\MinGW\include',
      \         'C:\Opt\mingw\x86_64-w64-mingw32\include',
      \         'C:\Opt\mingw\x86_64-w64-mingw32\include\c++',
      \     ],
      \   },
      \   'cygwin': {
      \     'path': [
      \         'C:\Opt\cygwin\bin',
      \         'C:\Opt\cygwin\usr\sbin',
      \     ],
      \     'lib': [
      \         'C:\Opt\cygwin\lib',
      \     ],
      \     'include': [
      \         'C:\Opt\cygwin\usr\include',
      \     ],
      \   },
      \   'msvc_2005': {
      \     'path': [
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\Common7\Tools',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\Common7\IDE',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\bin',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\PlatformSDK\Bin',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\SDK\v2.0\Bin',
      \     ],
      \     'lib': [
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\lib',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\atlmfc\lib',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\PlatformSDK\Lib',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\SDK\v2.0\Lib',
      \     ],
      \     'include': [
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\include',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\atlmfc\include',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\VC\PlatformSDK\Include',
      \         'C:\Program Files (x86)\Microsoft Visual Studio 8\SDK\v2.0\include;',
      \     ],
      \   },
      \ }

function! CppEnv.set_default()
  let $PATH = get(self.default, 'path')
  let $LIB = get(self.default, 'lib')
  let $LIBPATH = get(self.default, 'libpath')
  let $LIBRARY_PATH = get(self.default, 'library_path')
  let $INCLUDE = get(self.default, 'include')
  let $C_INCLUDE_PATH = get(self.default, 'c_include_path')
  let $CPLUS_INCLUDE_PATH = get(self.default, 'cplus_include_path')
  let &l:path = get(self.default, 'pa')
endfunction

function! CppEnv.change(name)
  " set to default
  call self.set_default()
  " append parameter path
  let sp = g:is_windows ? ';' : ':'
  let env = get(self.environment, a:name)
  let $PATH = $PATH.sp.join(get(env, 'path'), sp)
  let $LIB = '.'.sp.join(get(env, 'lib'), sp)
  let $LIBPATH = $LIB
  let $LIBRARY_PATH = $LIB
  let $INCLUDE = '.'.sp.join(get(env, 'include'), sp)
  let $C_INCLUDE_PATH = $INCLUDE
  let $CPLUS_INCLUDE_PATH = $INCLUDE
  let &l:path = '.,'.fnameescape(join(get(env, 'include'), ','))
  let self.current_name = a:name
  unlet sp
  unlet env
endfunction

command! -nargs=0 CppEnvDefault  call CppEnv.set_default()
command! -nargs=0 CppEnvGcc      call CppEnv.change('gcc')
command! -nargs=0 CppEnvMinGW    call CppEnv.change('mingw')
command! -nargs=0 CppEnvCygwin   call CppEnv.change('cygwin')
command! -nargs=0 CppEnvMSVC2005 call CppEnv.change('msvc_2005')


" Auto Command {{{1
"
" ファイルタイプごとのインデント設定
augroup ag_indent_filetype
  au!
  au FileType c,cpp,cs,java setlocal ts=4 sts=0 sw=4
                          \ cindent cinoptions=:4
  au FileType ruby,perl,lua,vim,javascript setlocal ts=2 sts=0 sw=2
  au FileType python setlocal expandtab
  au FileType html,xml,xhtml setlocal ts=2 sts=0 sw=2 expandtab
  au FileType mkd,markdown setlocal list listchars=tab:^\ ,trail:»,nbsp:%
  au FileType mkd,markdown highlight! link SpecialKey Identifier
augroup END

" ファイルタイプごとのテキスト整形設定
" デフォルトは"tcq"  (参照 :help fo-table)
augroup ag_formatoptions_filetype
  au!
  " 挿入モードでの自動折り返しを行わない
  au FileType * setlocal formatoptions+=l
  " 文字コードが 255 より後のマルチバイト文字の間でも改行する
  au FileType * setlocal formatoptions+=m
  " マルチバイト文字の行連結時に空白を挿入しない
  au FileType * setlocal formatoptions+=MB
  " 改行後に自動的にコメントを挿入するのをやめさせる
  au FileType * setlocal formatoptions-=ro
  " 自動改行を無効
  au FileType * setlocal formatoptions-=t
augroup END

" ファイルタイプごとのgrep_func関数の検索対象ファイルパターン
augroup ag_grep_filetype
  au!
  au FileType *
        \ let b:grep_target_file = '**/*'
  au FileType c,cpp
        \ let b:grep_target_file = '**/*.c **/*.cpp **/*.cxx **/*.cc **/*.h **/*.hpp'
  au FileType cs
        \ let b:grep_target_file = '**/*.cs'
  au FileType java
        \ let b:grep_target_file = '**/*.java'
  au FileType ruby
        \ let b:grep_target_file = '**/*.rb'
  au FileType perl
        \ let b:grep_target_file = '**/*.pl'
  au FileType python
        \ let b:grep_target_file = '**/*.py'
  au FileType vim
        \ let b:grep_target_file = '**/*.vim'
augroup END

" ファイルを開いた時にカーソル位置を復元する
augroup ag_restore_cursor
  au! BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
augroup END

" Insert mode開始/終了時の動作
augroup ag_ins_enter_leave
  au!
  " Normal modeに戻る時に自動的にIMEOFF
  " 再度Insert modeに入るときは元のIME状態に戻す
  let g:imstate = 0
  au InsertEnter * let &iminsert = g:imstate
  au InsertLeave * let g:imstate = &iminsert
        \        | set iminsert=0 imsearch=0
  " Insert modeに入るときに一時的にfoldingをmanualに変更
  au InsertEnter * let b:foldstate = &l:foldmethod
        \        | setlocal foldmethod=manual
  au InsertLeave * if exists('b:foldstate')
        \        |   let &l:foldmethod = b:foldstate
        \        | endif
augroup END

" 以下のコマンドの結果は常にQuickFixで表示
" augroup ag_cmd_qfopen
  " au! QuickfixCmdPost grep,vimgrep,make,copen cw
" augroup END

"function! s:file_enc_check()
"  日本語を含まない場合はfileencoding にencoding を使うようにする
"  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
"    let &fileencoding=&encoding
"  endif
"endfunction
" VC2005でBOM無しUTF-8を扱うとSJISとして認識されるためBOMを付ける
function! s:set_utf8_bom()
  if g:is_windows && &fileencoding ==# 'utf-8'
    set bomb
  endif
endfunction
" バッファオープン時のエンコード再チェック
augroup ag_file_enc_check
  au!
"  au BufReadPost * call s:file_enc_check()
  au FileType c,cpp,cs call s:set_utf8_bom()
augroup END

" 全角スペースを視覚化
" function! s:zenkaku_space()
"   highlight ZenkakuSpace ctermbg=darkgrey guibg=darkgrey
" endfunction
" if has('syntax')
"   augroup ag_zenkaku_space
"     au!
"     au ColorScheme       * call s:zenkaku_space()
"     au VimEnter,WinEnter * match ZenkakuSpace /　/
"   augroup END
"   call s:zenkaku_space()
" endif

" ファイルオープン時にカレントディレクトリを自動的に移動
" augroup ag_buf_lcd
"   au! BufEnter * lcd %:p:h
" augroup END

" ファイル保存時に行末の不要スペースを削除する
" augroup ag_rtrim
"   au! BufWritePre *.c,*.cpp,*.rb,*.php,*.js,*.vim,*.bat call s:rtrim()
" augroup END

" shファイルの保存時にはファイルのパーミッションを755にする
if has("unix")
  function! s:chg_sh_permission()
    if &ft =~ "\\(z\\|c\\|ba\\)\\?sh"
      call system("chmod 755 ".shellescape(expand('%:p')))
      " echo "Set permission 755"
    endif
  endfunction
  augroup ag_chg_sh_permission
    au! BufWritePost *.sh call s:chg_sh_permission()
  augroup END
endif


" <Fn> 短縮キーマップ {{{1
"
noremap <F1>    :<C-u>Unite help<CR>
noremap <F2>    :<C-u>Unite outline<CR>
noremap <F3>    :<C-u>Unite mark<CR>
noremap <F4>    :<C-u>Unite -buffer-name=register history/yank<CR>
noremap <F5>    :<C-u>Unite buffer<CR>
noremap <F6>    :<C-u>Unite buffer_tab<CR>
noremap <F7>    :<C-u>Unite -buffer-name=files file<CR>
noremap <F8>    :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
noremap <F9>    :<C-u>Unite -buffer-name=files file_rec<CR>
noremap <F10>   :<C-u>Unite -buffer-name=files file_rec:<C-r>=expand('%:p:h:gs?[ :]?\\\0?')<CR><CR>
noremap <F11>   :<C-u>Unite -buffer-name=files file_mru<CR>
noremap <F12>   :<C-u>Unite -buffer-name=files directory_mru<CR>

noremap <S-F1>  <Nop>
noremap <S-F2>  :<C-u>Unite tag<CR>
noremap <S-F3>  :<C-u>Unite grep<CR>
noremap <S-F4>  :<C-u>Unite find<CR>
noremap <S-F5>  :<C-u>Unite command<CR>
noremap <S-F6>  <Nop>
noremap <S-F7>  <Nop>
noremap <S-F8>  :<C-u>UniteResume<CR>
noremap <S-F9>  <Nop>
noremap <S-F10> <Nop>
noremap <S-F11> :<C-u>Unite -buffer-name=files bookmark<CR>
noremap <S-F12> :<C-u>UniteBookmarkAdd<CR>

noremap <C-F1>  :<C-u>Openvimrc<CR>
noremap <C-F2>  :<C-u>Opengvimrc<CR>
noremap <C-F3>  :<C-u>Openpluginrc<CR>
noremap <C-F4>  :<C-u>Reloadrc<CR>
noremap <C-F5>  :<C-u>VimFiler<CR>
noremap <C-F6>  :<C-u>VimFilerBufferDir<CR>
noremap <C-F7>  :<C-u>VimFiler -buffer-name=explorer -split -simple -winwidth=30 -toggle -no-quit<CR>
noremap <C-F8>  :<C-u>VimFilerBufferDir -buffer-name=explorer -split -simple -winwidth=30 -toggle -no-quit<CR>
noremap <C-F9>  :<C-u>VimShell<CR>
noremap <C-F10> :<C-u>VimShellBufferDir<CR>
noremap <C-F11> :<C-u>VimShellPop<CR>
noremap <C-F12> :<C-u>VimShellBufferDir -popup<CR>

noremap <M-F1>  :<C-u>NeoBundleInstall<CR>
noremap <M-F2>  :<C-u>NeoBundleUpdate<CR>
noremap <M-F3>  :<C-u>NeoBundleLog<CR>
noremap <M-F4>  <Nop>
noremap <M-F5>  :<C-u>NeoBundleSource<CR>
noremap <M-F6>  <Nop>
noremap <M-F7>  <Nop>
noremap <M-F8>  <Nop>
noremap <M-F9>  :<C-u>call ColorRoller.unroll()<CR>
noremap <M-F10> :<C-u>call ColorRoller.roll()<CR>
noremap <M-F11> :<C-u>call DecreaseTrancyLevel()<CR>
noremap <M-F12> :<C-u>call IncreaseTrancyLevel()<CR>


" 起動前処理 {{{1
"
" ディレクトリ作成 (vim-user.jp hack-202)
function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
    \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction

if has('vim_starting')
  " ディレクトリの自動生成
  call s:auto_mkdir(&backupdir, 1)
  call s:auto_mkdir(&directory, 1)
  if has('persistent_undo')
    call s:auto_mkdir(&undodir, 1)
  endif
endif


" 環境ごとの設定読み込み
call s:source_ifexists(s:rc_path('vimlocal'))

" Example
"
" environment path for c++
"
" function! s:set_cpp_env_path()
"   call g:CppEnv.change('mingw')
" endfunction
" augroup ag_cpp_env_path
"   au! FileType c,cpp call s:set_cpp_env_path()
" augroup END


" {{{1
" vim:set expandtab ft=vim ts=2 sts=2 sw=2 foldmethod=marker:

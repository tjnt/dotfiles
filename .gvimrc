"
" .gvimrc
"
"

" 基本設定 {{{1
"
" エラー時の音とビジュアルベルの抑制
set noerrorbells
set novisualbell
" set visualbell t_vb=

" マウスに関する設定
if has('mouse')
  " どのモードでもマウスを使えるようにする
  set mouse=a
  " マウスの移動でフォーカスを自動的に切替えない (mousefocus:切替る)
  set nomousefocus
  " 入力時にマウスポインタを隠す (nomousehide:隠さない)
  set mousehide
endif

" ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
"set guioptions+=a


" ウインドウに関する設定 {{{1
"
if has('vim_starting')
  " ウインドウの幅
  set columns=80
  " ウインドウの高さ
  set lines=25
endif
" コマンドラインの高さ(GUI使用時)
set cmdheight=2


" メニューに関する設定 {{{1
"
" メニューを非表示
set guioptions-=m
" ツールバーを非表示
set guioptions-=T


" フォント設定 {{{1
"
if g:is_windows
  " 半角文字
  set guifont=Consolas:h11:cDEFAULT
  " set guifont=Inconsolata:h11:cDEFAULT
  " set guifont=MigMix_1M:h11:w5:cDEFAULT
  " set guifont=Lucida_Console:h10:cDEFAULT
  " set guifont=Ricty:h11:cDEFAULT
  " set guifont=MS_Gothic:h11:cDEFAULT
  " 全角文字
  set guifontwide=Migu_1M:h11:cDEFAULT
  " set guifontwide=IPAGothic:h11:cDEFAULT
  " set guifontwide=TakaoGothic:h11:cDEFAULT
  " set guifontwide=MigMix_1M:h11:cDEFAULT
  " set guifontwide=メイリオ:h11:b:cDEFAULT
  " set guifont=Ricty:h11:cDEFAULT
  " set guifontwide=MS_Gothic:h11:cDEFAULT
elseif (has('unix'))
  " 半角文字
  " set guifont=Ricty\ 11
  set guifont=Ricty\ Diminished\ 11
  " 全角文字
  " set guifontwide=Ricty\ 11
  set guifont=Ricty\ Diminished\ 11
endif

" 印刷用フォント
if has('printer') && g:is_windows
  set printfont=MS_Gothic:h11:cDEFAULT
  " set printfont=MS_Mincho:h11:cDEFAULT
endif

" 行間隔の設定
set linespace=1


" カーソルやステータスラインの設定 {{{1
"
" カーソルの変更
function! s:chg_cursor_style()
  " IMEの状態でカーソル色を変更する
  if has('multi_byte_ime')
    "  highlight Cursor guifg=NONE guibg=Green
    highlight CursorIM guifg=NONE guibg=Purple
  endif
  " カーソルラインはアンダーラインで表示
  hi CursorLine gui=underline
endfunction
augroup ag_chg_colorscheme
  au!
  au ColorScheme * call s:chg_cursor_style()
augroup END


" カラー設定 {{{1
"
" ColorRoller
let ColorRoller = {}
let ColorRoller.colors = [
      \ 'jellybeans',
      \ 'molokai',
      \ 'wombat256',
      \ 'lucius',
      \ 'rootwater',
      \ 'candycode',
      \ 'elflord',
      \ ]

function! ColorRoller.change()
  let color = get(self.colors, 0)
  silent exe 'colorscheme '.color
  redraw
  echon self.colors
endfunction

function! ColorRoller.roll()
  let item = remove(self.colors, 0)
  call insert(self.colors, item, len(self.colors))
  call self.change()
endfunction

function! ColorRoller.unroll()
  let item = remove(self.colors, -1)
  call insert(self.colors, item, 0)
  call self.change()
endfunction

" ColorRollerの先頭をデフォルトのカラースキーマとして使用する
try
  silent exe "colorscheme ".ColorRoller.colors[0]
catch
  colorscheme default
endtry


" 背景透過設定 {{{1
"
if has('kaoriya') || has('mac')
  gui
  set transparency=255

  " 透過率を変更
  function! DecreaseTrancyLevel()
    let &transparency = &transparency - 5
    echon 'transparency='.&transparency
  endfunction

  function! IncreaseTrancyLevel()
    let &transparency = &transparency + 5
    echon 'transparency='.&transparency
  endfunction

  " フォーカスが外れた時に自動的に透過設定を有効 (vim-user.jp hack-234)
  let s:enable_auto_hide_trancy = 0
  if s:enable_auto_hide_trancy
    let s:gained_trancy_level = 255
    let s:lost_trancy_level   = 100
    augroup ag_auto_hide_trancy
      au!
      au FocusGained * let &transparency = s:gained_trancy_level
      au FocusLost * let &transparency = s:lost_trancy_level
    augroup END
  endif
endif


" {{{1
" vim:set expandtab ft=vim ts=2 sts=2 sw=2 foldmethod=marker:

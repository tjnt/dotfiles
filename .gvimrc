"
" .gvimrc
"
"

" オプション設定 {{{1
"
if has('vim_starting')
  " ウインドウの幅
  set columns=80
  " ウインドウの高さ
  set lines=25
endif

" コマンドラインの高さ(GUI使用時)
set cmdheight=2

" 行間隔
set linespace=1

" メニューを非表示
set guioptions-=m
" ツールバーを非表示
set guioptions-=T
" タブを非表示(テキストベースのタブを使う)
set guioptions-=e
" スクロールバーを非表示
set guioptions-=rL

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
augroup _chg_colorscheme
  au!
  au ColorScheme * call s:chg_cursor_style()
augroup END

" フォント {{{1
"
function! s:set_guifont(normal, wide)
  let &guifont = join(a:normal, ',')
  let &guifontwide = join(a:wide, ',')
endfunction

if g:is_win
  let s:normal = [
        \ 'Consolas:h12',
        \ 'Inconsolata:h12',
        \ 'MigMix_1M:h12',
        \ 'MS_Gothic:h12',
        \ ]
  let s:wide = [
        \ 'Migu_1M:h12',
        \ 'TakaoGothic:h12',
        \ 'メイリオ:h12',
        \ 'MS_Gothic:h12',
        \ ]
  call s:set_guifont(s:normal, s:wide)
endif

if has('unix')
  let s:normal= [
        \ 'Ricty Diminished 12',
        \ 'Ricty 12',
        \ ]
  let s:wide= [
        \ 'Ricty Diminished 12',
        \ 'Ricty 12',
        \ 'Monospace 12',
        \ ]
  call s:set_guifont(s:normal, s:wide)
endif

" 印刷用フォント
if has('printer') && g:is_win
  set printfont=MS_Gothic:h11:cDEFAULT
  " set printfont=MS_Mincho:h11:cDEFAULT
endif

" 背景透過 {{{1
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
    augroup _auto_hide_trancy
      au!
      au FocusGained * let &transparency = s:gained_trancy_level
      au FocusLost * let &transparency = s:lost_trancy_level
    augroup END
  endif
endif

" {{{1
" vim:set expandtab ft=vim ts=2 sts=2 sw=2 foldmethod=marker:

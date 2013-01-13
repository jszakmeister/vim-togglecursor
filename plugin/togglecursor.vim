" ============================================================================
" File:         togglecursor.vim 
" Description:  Toggles cursor shape in the terminal
" Maintainer:   John Szakmeister <john@szakmeister.net>
" License:      Same license as Vim.
" ============================================================================

if exists('g:loaded_togglecursor') || &cp || !has("cursorshape")
  finish
endif
let g:loaded_togglecursor = 1

let g:togglecursor_default = 'block'
let g:togglecursor_insert = 'line'

let s:cursorshape_line = "\<Esc>]50;CursorShape=1\x7"
let s:cursorshape_block = "\<Esc>]50;CursorShape=0\x7"

let s:supported_terminal = 0

" Check for supported terminals.
if !has("gui_running")
    if (has("macunix") && $TERM_PROGRAM == "iTerm.app") || $KONSOLE_DBUS_SESSION != ""
        " Konsole and  iTerm support using CursorShape.
        let s:supported_terminal = 1
    endif
endif

function s:ToggleCursorInit()
    if !s:supported_terminal
        return
    endif

    let &t_EI = s:cursorshape_block
    let &t_SI = s:cursorshape_line
endfunction

augroup ToggleCursorStartup
    autocmd!
    autocmd VimEnter * call <SID>ToggleCursorInit()
augroup END

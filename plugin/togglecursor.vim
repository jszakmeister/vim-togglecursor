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

let s:xterm_underline = "\<Esc>[4 q"
let s:xterm_line = "\<Esc>[6 q"
let s:xterm_block = "\<Esc>[2 q"

let s:in_tmux = exists("$TMUX")

let s:supported_terminal = ''

" Check for supported terminals.
if !has("gui_running")
    if (has("macunix") && $TERM_PROGRAM == "iTerm.app") || $KONSOLE_DBUS_SESSION != ""
        " Konsole and  iTerm support using CursorShape.
        let s:supported_terminal = 'cursorshape'
    elseif $XTERM_VERSION != ''
        let s:supported_terminal = 'xterm'
    endif
endif

function! s:TmuxEscape(line)
    " Tmux has an escape hatch for talking to the real terminal.  Use it.
    let escaped_line = substitute(a:line, "\<Esc>", "\<Esc>\<Esc>", 'g')
    return "\<Esc>Ptmux;" . escaped_line . "\<Esc>\\"
endfunction

function s:ToggleCursorInit()
    if s:supported_terminal == ''
        return
    endif

    if s:supported_terminal == 'cursorshape'
        let new_ei = s:cursorshape_block
        let new_si = s:cursorshape_line
    else
        let new_ei = s:xterm_block

        " When I can find a better way of detecting a supported xterm, I can use
        " the xterm's line cursor.  For now, use the underline version.
        let new_si = s:xterm_underline
    endif

    if s:in_tmux
        let &t_EI = s:TmuxEscape(new_ei)
        let &t_SI = s:TmuxEscape(new_si)
    else
        let &t_EI = new_ei
        let &t_SI = new_si
    endif
endfunction

augroup ToggleCursorStartup
    autocmd!
    autocmd VimEnter * call <SID>ToggleCursorInit()
augroup END

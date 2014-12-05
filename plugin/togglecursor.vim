" ============================================================================
" File:         togglecursor.vim
" Description:  Toggles cursor shape in the terminal
" Maintainer:   John Szakmeister <john@szakmeister.net>
" Version:      0.3.0
" License:      Same license as Vim.
" ============================================================================

if exists('g:loaded_togglecursor') || &cp || !has("cursorshape")
  finish
endif
let g:loaded_togglecursor = 1

let s:cursorshape_underline = "\<Esc>]50;CursorShape=2;BlinkingCursorEnabled=0\x7"
let s:cursorshape_line = "\<Esc>]50;CursorShape=1;BlinkingCursorEnabled=0\x7"
let s:cursorshape_block = "\<Esc>]50;CursorShape=0;BlinkingCursorEnabled=0\x7"

let s:cursorshape_blinking_underline = "\<Esc>]50;CursorShape=2;BlinkingCursorEnabled=1\x7"
let s:cursorshape_blinking_line = "\<Esc>]50;CursorShape=1;BlinkingCursorEnabled=1\x7"
let s:cursorshape_blinking_block = "\<Esc>]50;CursorShape=0;BlinkingCursorEnabled=1\x7"

" Note: newer iTerm's support the DECSCUSR extension (same one used in xterm).

let s:xterm_underline = "\<Esc>[4 q"
let s:xterm_line = "\<Esc>[6 q"
let s:xterm_block = "\<Esc>[2 q"

" Not used yet, but don't want to forget them.
let s:xterm_blinking_block = "\<Esc>[0 q"
let s:xterm_blinking_line = "\<Esc>[5 q"
let s:xterm_blinking_underline = "\<Esc>[3 q"

let s:in_tmux = exists("$TMUX")

let s:supported_terminal = ''

" Check for supported terminals.
if !has("gui_running")
    if $TERM_PROGRAM == "iTerm.app" || exists("$ITERM_SESSION_ID")
                \ || $XTERM_VERSION != ""
                " \ || $VTE_VERSION != ""
        " iTerm, xterm, and future VTE based terminals support DESCCUSR.
        let s:supported_terminal = 'xterm'
    elseif $TERM_PROGRAM == "Konsole" || exists("$KONSOLE_DBUS_SESSION")
        "cursorshape for konsole
        let s:supported_terminal = 'cursorshape'
    endif
endif


" -------------------------------------------------------------
" Options
" -------------------------------------------------------------

if !exists("g:togglecursor_default")
    let g:togglecursor_default = 'block'
endif

if !exists("g:togglecursor_insert")
    let g:togglecursor_insert = 'line'
    if exists("$XTERM_VERSION")
        let xterm_patch = str2nr(matchstr($XTERM_VERSION,
                    \ '\v^XTerm\(\zs\d+\ze\)'))
        if xterm_patch < 282
            let g:togglecursor_insert = 'underline'
        endif
    endif
endif

if !exists("g:togglecursor_replace")
    let g:togglecursor_replace = 'underline'
endif

if !exists("g:togglecursor_leave")
    let g:togglecursor_leave = g:togglecursor_default
endif

if !exists("g:togglecursor_disable_tmux")
    let g:togglecursor_disable_tmux = 0
endif

" -------------------------------------------------------------
" Functions
" -------------------------------------------------------------

function! s:TmuxEscape(line)
    " Tmux has an escape hatch for talking to the real terminal.  Use it.
    let escaped_line = substitute(a:line, "\<Esc>", "\<Esc>\<Esc>", 'g')
    return "\<Esc>Ptmux;" . escaped_line . "\<Esc>\\"
endfunction

function! s:SupportedTerminal()
    if s:supported_terminal == '' || (s:in_tmux && g:togglecursor_disable_tmux)
        return 0
    endif

    return 1
endfunction

function! s:GetEscapeCode(shape)
    if !s:SupportedTerminal()
        return ''
    endif

    let l:escape_code = s:{s:supported_terminal}_{a:shape}

    if s:in_tmux
        return s:TmuxEscape(l:escape_code)
    endif

    return l:escape_code
endfunction

function! s:ToggleCursorInit()
    if !s:SupportedTerminal()
        return
    endif

    let &t_EI = s:GetEscapeCode(g:togglecursor_default)
    let &t_SI = s:GetEscapeCode(g:togglecursor_insert)
endfunction

function! s:ToggleCursorLeave()
    " One of the last codes emitted to the terminal before exiting is the "out
    " of termcap" sequence.  Tack our escape sequence to change the cursor type
    " onto the beginning of the sequence.
    let &t_te = s:GetEscapeCode(g:togglecursor_leave) . &t_te
endfunction

function! s:ToggleCursorByMode()
    if v:insertmode == 'r' || v:insertmode == 'v'
        let &t_SI = s:GetEscapeCode(g:togglecursor_replace)
    else
        " Default to the insert mode cursor.
        let &t_SI = s:GetEscapeCode(g:togglecursor_insert)
    endif
endfunction

" Having our escape come first seems to work better with tmux and konsole under
" Linux.
let &t_ti = s:GetEscapeCode(g:togglecursor_default) . &t_ti

augroup ToggleCursorStartup
    autocmd!
    autocmd VimEnter * call <SID>ToggleCursorInit()
    autocmd VimLeave * call <SID>ToggleCursorLeave()
    autocmd InsertEnter * call <SID>ToggleCursorByMode()
augroup END

" dispatch.vim X11 strategy

if exists('g:autoloaded_dispatch_x11')
  finish
endif
let g:autoloaded_dispatch_x11 = 1

function! dispatch#x11#handle(request) abort
  if $DISPLAY !~# '^:'
    return 0
  endif
  if get(a:request, 'background') &&
        \ (!v:windowid || !executable('wmctrl'))
    return 0
  endif
  if exists('g:dispatch_terminal_exec')
    let terminal = g:dispatch_terminal_exec
  elseif !empty($TERMINAL)
    let terminal = $TERMINAL . ' -e'
  elseif executable('xterm')
    let terminal = 'xterm -e'
  else
    return 0
  endif
  if a:request.action ==# 'start'
    return dispatch#x11#spawn(terminal, dispatch#prepare_start(a:request), a:request)
  else
    return 0
  endif
endfunction

function! dispatch#x11#spawn(terminal, command, request) abort
  let command = dispatch#set_title(a:request) . '; ' . a:command
  if a:request.background
    let command = 'wmctrl -i -a '.v:windowid . ';' . command
  endif
  call system(a:terminal . ' ' . dispatch#shellescape(&shell, &shellcmdflag, command). ' &')
  return 1
endfunction

function! dispatch#x11#activate(pid) abort
  let out = system('ps ewww -p '.a:pid)
  let window = matchstr(out, 'WINDOWID=\zs\d\+')
  if !empty(window) && executable('wmctrl')
    call system('wmctrl -i -a '.window)
    return !v:shell_error
  endif
endfunction

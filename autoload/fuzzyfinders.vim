for fuzzyfinders_matcher in fuzzyfinders_matchers
  if executable(split(g:fuzzyfinders_matcher)[0])
    let g:fuzzyfinders_matcher = fuzzyfinders_matcher
    break
  endif
endfor

if !exists('g:fuzzyfinders_matcher')
  echomsg "Please install a fuzzy matcher such as sk, fzy, fzf, peco or point g:fuzzyfinders_matchers to valid executables!"
  finish
endif

for fuzzyfinders_file_cmd in fuzzyfinders_file_cmds
  if executable(split(g:fuzzyfinders_file_cmd)[0])
    let g:fuzzyfinders_file_cmd = fuzzyfinders_file_cmd
    break
  endif
endfor

if !exists('g:fuzzyfinders_file_cmd')
  if has('unix')
    let g:fuzzyfinders_file_cmd = 'find -L . -type f'
  elseif has('win32')
    let g:fuzzyfinders_file_cmd = 'dir . /-n /b /s /a-d'
  else
    echomsg "Please install a file finder such as fd, ripgrep or the silver searcher or point g:fuzzyfinders_file_cmds to valid executables!"
    finish
  endif
endif

for fuzzyfinders_dir_cmd in fuzzyfinders_dir_cmds
  if executable(split(g:fuzzyfinders_dir_cmd)[0])
    let g:fuzzyfinders_dir_cmd = fuzzyfinders_dir_cmd
    break
  endif
endfor

if !exists('g:fuzzyfinders_dir_cmd')
  if has('unix')
    let g:fuzzyfinders_dir_cmd = 'find -L . -type d'
  elseif has('win32')
    let g:fuzzyfinders_dir_cmd = 'dir . /-n /b /s /a:d'
  else
    echomsg "Please install a directory finder such as fd or point g:fuzzyfinders_dir_cmds to valid executables!"
    finish
  endif
endif

if g:fuzzyfinders_use_scheduler
  if has('unix') && executable('chrt') && executable('ionice')
      let s:scheduler = 'chrt --idle 0 ionice -c2 -n7 '
  elseif has('win32')
      let s:scheduler = (&shell =~? '\v(^|\\)cmd\.exe$' ? '' : 'cmd.exe ')
                  \ . 'start /B /LOW'
  else
      let s:scheduler = ''
  endif
  let g:fuzzyfinders_file_cmd = s:scheduler . ' ' . g:fuzzyfinders_file_cmd
  let g:fuzzyfinders_dir_cmd  = s:scheduler . ' ' . g:fuzzyfinders_dir_cmd
  unlet s:scheduler
endif

let s:slash = exists('+shellslash') && !&shellslash ? '\' : '/'

function! fuzzyfinders#command(shell_cmd, dir, vim_cmd, prompt) abort
  let cwd = getcwd()
  let dir = fnamemodify(resolve(a:dir), ':p:h')

  try
    exe 'lcd' dir
    let choice = fuzzyfinders#select(a:shell_cmd, a:prompt)
  catch /Vim:Interrupt/
    " Swallow errors from Ctrl+C
  catch
    echohl WarningMsg
    echom v:exception
    echohl None
    return 1
  finally
    exe 'lcd' cwd
  endtry

  redraw!
  if v:shell_error == 0 && !empty(choice)
    exec a:vim_cmd . ' ' . dir . s:slash . choice
  endif
endfunction

if !has('gui_running')
  function! fuzzyfinders#select(shell_cmd, prompt) abort
    return system(a:shell_cmd . ' | ' . g:fuzzyfinders_matcher . ' --prompt "' . a:prompt . '"')
  endfunction
else
  function! fuzzyfinders#select(shell_cmd, prompt) abort
    let choices = fuzzyfinders#finder(a:shell_cmd, a:prompt)
    return empty(choices) ? '' : choices[0]
  endfunction

  " From https://vim.fandom.com/wiki/Implement_your_own_interactive_finder_without_plugins
  fun! s:FilterClose(bufnr) abort
    wincmd p
    execute 'bwipe' a:bufnr
    redraw
    echo "\r"
    return []
  endf

  fun! fuzzyfinders#finder(input, prompt) abort
    let l:prompt = a:prompt . '>'
    let l:filter = ''
    let l:undoseq = []
    botright 10new +setlocal\ buftype=nofile\ bufhidden=wipe\
          \ nobuflisted\ nonumber\ norelativenumber\ noswapfile\ nowrap\
          \ foldmethod=manual\ nofoldenable\ modifiable\ noreadonly
    let l:cur_buf = bufnr('%')
    if type(a:input) ==# v:t_string
      let l:input = systemlist(a:input)
      call setline(1, l:input)
    else " Assume List
      call setline(1, a:input)
    endif
    setlocal cursorline
    redraw
    echo l:prompt . ' '
    while 1
      let l:error = 0 " Set to 1 when pattern is invalid
      try
        let ch = getchar()
      catch /^Vim:Interrupt$/  " CTRL-C
        return s:FilterClose(l:cur_buf)
      endtry
      if ch ==# "\<bs>" " Backspace
        let l:filter = l:filter[:-2]
        let l:undo = empty(l:undoseq) ? 0 : remove(l:undoseq, -1)
        if l:undo
          undo
        endif
      elseif ch >=# 0x20 " Printable character
        let l:filter .= nr2char(ch)
        let l:seq_old = get(undotree(), 'seq_cur', 0)
        try " Ignore invalid regexps
          execute 'silent keepp g!:\m' . escape(l:filter, '~\[:') . ':norm "_dd'
        catch /^Vim\%((\a\+)\)\=:E/
          let l:error = 1
        endtry
        let l:seq_new = get(undotree(), 'seq_cur', 0)
        " seq_new != seq_old iff the buffer has changed
        call add(l:undoseq, l:seq_new != l:seq_old)
      elseif ch ==# 0x1B " Escape
        return s:FilterClose(l:cur_buf)
      elseif ch ==# 0x0D " Enter
        let l:result = empty(getline('.')) ? [] : [getline('.')]
        call s:FilterClose(l:cur_buf)
        return l:result
      elseif ch ==# 0x0C " CTRL-L (clear)
        call setline(1, type(a:input) ==# v:t_string ? l:input : a:input)
        let l:undoseq = []
        let l:filter = ''
        redraw
      elseif ch ==# 0x0B " CTRL-K
        normal! k
      elseif ch ==# 0x0A " CTRL-J
        normal! j
      endif
      redraw!
      echo (l:error ? '[Invalid pattern] ' : '').l:prompt l:filter
    endwhile
  endf

endif

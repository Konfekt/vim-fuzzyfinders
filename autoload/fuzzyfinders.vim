for fuzzyfinders_matcher in fuzzyfinders_matchers
  if executable(split(g:fuzzyfinders_matcher)[0])
    let g:fuzzyfinders_matcher = fuzzyfinders_matcher
    break
  endif
endfor

if !exists('g:fuzzyfinders_matcher')
  echomsg "Please install a fuzzy matcher such as sk, fzy, fzf, gof, peco or point g:fuzzyfinders_matchers to valid executables!"
  finish
endif

for fuzzyfinders_file_cmd in fuzzyfinders_file_cmds
  if executable(split(g:fuzzyfinders_file_cmd)[0])
    let g:fuzzyfinders_file_cmd = fuzzyfinders_file_cmd
    break
  endif
endfor

if !exists('g:fuzzyfinders_file_cmd')
  echomsg "Please install a file finder such as fd, ripgrep or the silver searcher or point g:fuzzyfinders_file_cmds to valid executables!"
  finish
endif

for fuzzyfinders_dir_cmd in fuzzyfinders_dir_cmds
  if executable(split(g:fuzzyfinders_dir_cmd)[0])
    let g:fuzzyfinders_dir_cmd = fuzzyfinders_dir_cmd
    break
  endif
endfor

if !exists('g:fuzzyfinders_dir_cmd')
  echomsg "Please install a directory finder such as fd or point g:fuzzyfinders_dir_cmds to valid executables!"
  finish
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
" elseif !has('terminal')

  " call term_start(l:cmd, {'term_name': 'Fz', 'curwin': l:ctx['buf'], 'exit_cb': function('s:exit_cb', [l:ctx]), 'tty_type': 'conpty', 'cwd': l:ctx['basepath']})
  "
  " " first argument is the ctx
  " " neovim passes third argument as 'exit' while vim passes only 2 arguments
  " function! s:exit_cb(ctx, job, st, ...) abort
  "   if has_key(a:ctx, 'tmp_input') && !has_key(a:ctx, 'file')
  "     call delete(a:ctx['tmp_input'])
  "   endif
  "   if a:st != 0
  "     call s:wipe(a:ctx)
  "     call delete(a:ctx['tmp_result'])
  "     return
  "   endif
  "   silent! call ch_close(job_getchannel(term_getjob(a:ctx['buf'])))
  "   let l:items = readfile(a:ctx['tmp_result'])
  "   call delete(a:ctx['tmp_result'])
  "   call s:wipe(a:ctx)
  "   if len(l:items) == 0
  "     return
  "   endif
  "   if has_key(a:ctx['options'], 'accept')
  "     let l:params = {}
  "     if has_key(a:ctx, 'actions')
  "       let l:params['actions'] = a:ctx['actions']
  "       if has_key(l:params['actions'], l:items[0])
  "         let l:params['action'] = l:params['actions'][l:items[0]]
  "       else
  "         let l:params['action'] = l:items[0]
  "       endif
  "       let l:params['items'] = l:items[1:]
  "     else
  "       let l:params['items'] = l:items
  "     endif
  "     call a:ctx['options']['accept'](l:params)
  "   else
  "     if has_key(a:ctx, 'actions')
  "       let l:action = l:items[0]
  "       let l:items = l:items[1:]
  "     else
  "       let l:action = ''
  "     endif
  "
  "     if len(l:items) ==# 1 && l:action ==# ''
  "       let l:path = expand(l:items[0])
  "       if !s:absolute_path(l:path)
  "         let l:path = a:ctx.basepath . '/' . l:path
  "       endif
  "       if filereadable(expand(l:path))
  "         exe 'edit' l:path
  "       endif
  "     else
  "       for l:item in l:items
  "         let l:path = expand(l:item)
  "         if !s:absolute_path(l:path)
  "           let l:path = a:ctx.basepath . '/' . l:path
  "         endif
  "         if filereadable(expand(l:path))
  "           if l:action == ''
  "             exe 'sp' l:path
  "           else
  "             exe a:ctx['actions'][l:action] . ' ' . l:path
  "           endif
  "         endif
  "       endfor
  "     endif
  "   endif
  " endfunction

  " function! fuzzyfinders#file(list_command, vim_command, ...) abort
  "   " Create a callback that executes a Vim command against the user's
  "   " selection escaped for use as a filename, and invoke Picker() with
  "   " that callback.
  "   "
  "   " Parameters
  "   " ----------
  "   " list_command : String
  "   "     Shell command to generate list user will choose from.
  "   " vim_command : String
  "   "     Readable representation of the Vim command which will be
  "   "     invoked against the user's selection, for display in the
  "   "     statusline.
  "   let l:callback = {'vim_command': a:vim_command}
  "
  "   if a:0 > 0
  "       let l:callback['cwd'] = a:1
  "   endif
  "
  "   function! l:callback.on_select(selection) abort
  "       if has_key(l:self, 'cwd') && strlen(l:self.cwd)
  "           let filename = simplify(fnamemodify(l:self.cwd . '/' . a:selection, ':p:~:.'))
  "           exec l:self.vim_command fnameescape(filename)
  "       else
  "           exec l:self.vim_command fnameescape(a:selection)
  "       endif
  "   endfunction
  "
  "   call fuzzyfinders#finder(a:list_command, a:vim_command, l:callback)
  " endfunction
  "
  " function! fuzzyfinders#finder(list_command, vim_command, callback) abort
  "   " Invoke callback.on_select on the line of output of list_command
  "   " selected by the user, using PickerTermopen() in Neovim and
  "   " PickerSystemlist() otherwise.
  "   "
  "   " Parameters
  "   " ----------
  "   " list_command : String
  "   "     Shell command to generate list user will choose from.
  "   " vim_command : String
  "   "     Readable representation of the Vim command which will be
  "   "     invoked against the user's selection, for display in the
  "   "     statusline.
  "   " callback.on_select : String -> Void
  "   "     Function executed with the item selected by the user as the
  "   "     first argument.
  "   if !executable(g:picker_selector_executable)
  "       echoerr 'vim-picker:' g:picker_selector_executable 'executable not found'
  "       return
  "   endif
  "
  "   call fuzzyfinders#termstart(a:list_command, a:vim_command, a:callback)
  " endfunction
  "
  " function! fuzzyfinders#termstart(list_command, vim_command, callback) abort
  "   " Open a Vim terminal emulator buffer in a new window using term_start,
  "   " execute list_command piping its output to the fuzzy selector, and call
  "   " callback.on_select with the item selected by the user as the first
  "   " argument.
  "   "
  "   " Parameters
  "   " ----------
  "   " list_command : String
  "   "     Shell command to generate list user will choose from.
  "   " vim_command : String
  "   "     Readable representation of the Vim command which will be
  "   "     invoked against the user's selection, for display in the
  "   "     statusline.
  "   " callback.on_select : String -> Void
  "   "     Function executed with the item selected by the user as the
  "   "     first argument.
  "   let l:callback = {
  "               \ 'window_id': win_getid(),
  "               \ 'filename': tempname(),
  "               \ 'callback': a:callback
  "               \ }
  "
  "   let l:directory = getcwd()
  "   if has_key(a:callback, 'cwd') && isdirectory(a:callback.cwd)
  "       let l:callback['cwd'] = a:callback.cwd
  "       let l:directory = a:callback.cwd
  "   endif
  "
  "   function! l:callback.exit_cb(...) abort
  "       close!
  "       call win_gotoid(l:self.window_id)
  "       if filereadable(l:self.filename)
  "           try
  "               call l:self.callback.on_select(readfile(l:self.filename)[0])
  "           catch /E684/
  "           endtry
  "           call delete(l:self.filename)
  "       endif
  "   endfunction
  "
  "   let l:options = {
  "               \ 'curwin': 1,
  "               \ 'exit_cb': l:callback.exit_cb,
  "               \ }
  "
  "   if strlen(l:directory)
  "       let l:options.cwd = l:directory
  "   endif
  "
  "   execute g:picker_split g:picker_height . 'new'
  "   let l:term_command = a:list_command . '|'
  "               \ . g:picker_selector_executable .  ' '
  "               \ . g:picker_selector_flags .
  "               \ '>' . l:callback.filename
  "   let s:picker_buf_num = term_start([&shell, &shellcmdflag, l:term_command],
  "               \ l:options)
  "   startinsert
  " endfunction

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

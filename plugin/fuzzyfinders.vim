if exists('g:loaded_fuzzyfinders') || &cp
  finish
endif
let g:loaded_fuzzyfinders = 1

let s:keepcpo         = &cpo
set cpo&vim
" ------------------------------------------------------------------------------

nnoremap <Plug>(FuzzyFindFileWorkDir) :<c-u>FuzzyFinderFile .<CR>
nnoremap <Plug>(FuzzyFindFileBufferDir) :<c-u>FuzzyFinderFile %:p:h<CR>

if !has('gui_running')
  if !hasmapto('<Plug>(FindWorkDir)', 'n')
    silent! nmap <unique>  <c-p>  <Plug>(FuzzyFindFileWorkDir)
  endif
  if !hasmapto('<Plug>(FindFileDir)', 'n')
    silent! nmap <unique> g<c-p>  <Plug>(FuzzyFindFileBufferDir)
  endif
endif

if !(exists('g:fuzzyfinders_matcher') && executable(split(g:fuzzyfinders_matcher)[0]))
  if executable('sk')
    let g:fuzzyfinders_matcher = 'sk'
  elseif executable('fzy')
    let g:fuzzyfinders_matcher = 'fzy'
  elseif executable('fzf')
    let g:fuzzyfinders_matcher = 'fzf'
  elseif executable('peco')
    let g:fuzzyfinders_matcher = 'peco'
  else
    echomsg "fuzzyfinders.vim: No fuzzy finder in terminal available. Please install a fuzzy finder such as sk, fzy, peco, fzf or point g:fuzzyfinders_matcher to a valid executable!"
    finish
  endif
endif

if executable('fd')
  let s:file_cmd = 'fd -L --type file --full-path --hidden --no-ignore-vcs --exclude .git/ --color never ' . (has('win32') ? '--fixed-strings ' : '') . ' .'
elseif executable('rg')
  let s:file_cmd = 'rg --glob "" --files --hidden --no-ignore-vcs --iglob !.git/ --color never .'
elseif executable('ag')
  let s:file_cmd = 'ag --filename-pattern "" --files-with-matches --hidden --skip-vcs-ignores --ignore .git/ --silent --nocolor .'
elseif has('unix')
  let s:file_cmd = 'find -L . -type f'
elseif has('win32')
  let s:file_cmd = 'dir . /-n /b /s /a-d'
endif

if exists('s:file_cmd')
  command! -complete=dir -nargs=1 FuzzyFinderFile call fuzzyfinders#command(s:file_cmd, <q-args>, 'edit', 'file >')
endif

if executable('fd')
  let s:dir_cmd = 'fd --type directory --full-path --no-ignore --hidden ' . (has('win32') ? '--fixed-strings ' : '') . ' .'
elseif has('unix')
  let s:dir_cmd = 'find -L . -type d'
elseif has('win32')
  let s:dir_cmd = 'dir . /-n /b /s /a:d'
endif

if exists('s:dir_cmd')
  command! -complete=dir -nargs=1 FuzzyFinderDir call fuzzyfinders#command(s:dir_cmd, 'Explore', 'directory > ')
endif

if has('unix') && executable('chrt') && executable('ionice')
    let s:scheduler = 'chrt --idle 0 ionice -c2 -n7 '
elseif has('win32')
    let s:scheduler = (&shell =~? '\v(^|\\)cmd\.exe$' ? '' : 'cmd.exe ')
                \ . 'start /B /LOW'
else
    let s:scheduler = ''
endif
let s:file_cmd = s:scheduler . ' ' . s:file_cmd
let s:dir_cmd  = s:scheduler . ' ' . s:dir_cmd
unlet s:scheduler

" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

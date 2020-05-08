if exists('g:loaded_fuzzyfinders') || &cp
  finish
endif
let g:loaded_fuzzyfinders = 1

let s:keepcpo         = &cpo
set cpo&vim
" ------------------------------------------------------------------------------

if !exists('g:fuzzyfinders_matchers')
  let g:fuzzyfinders_matchers = [
  \ 'sk',
  \ 'fzy',
  \ 'fzf',
  \ 'peco',
  \ ]
endif

if !exists('g:fuzzyfinders_file_cmds')
  let g:fuzzyfinders_file_cmds = [
  \ 'fd -L --type file --hidden --no-ignore --exclude .git/ --color never ' . (has('win32') ? '--fixed-strings ' : '') . '"" .',
  \ 'rg --glob "" --files --hidden --no-ignore --iglob !.git/ --color never "" .' ,
  \ 'ag --files-with-matches --unrestricted --ignore .git/ --nocolor --silent --filename-pattern "" .',
  \ ]
endif

if !exists('g:fuzzyfinders_dir_cmds')
  let g:fuzzyfinders_dir_cmds = [
        \ 'fd -L --type directory --hidden --no-ignore --exclude .git/ --color never ' . (has('win32') ? '--fixed-strings ' : '') . ' "" .',
        \ ]
endif

if !exists('g:fuzzyfinders_use_scheduler')
  let g:fuzzyfinders_use_scheduler = 1
endif

nnoremap <Plug>(FuzzyFinderFileWorkDir) :<c-u>FuzzyFinderFile .<CR>
nnoremap <Plug>(FuzzyFinderFileBufferDir) :<c-u>FuzzyFinderFile %:p:h<CR>

if !has('gui_running')
  if !hasmapto('<Plug>(FuzzyFinderFileWorkDir)', 'n')
    silent! nmap <unique>  <c-p>  <Plug>(FuzzyFinderFileWorkDir)
  endif
  if !hasmapto('<Plug>(FuzzyFinderFileBufferDir)', 'n')
    silent! nmap <unique> g<c-p>  <Plug>(FuzzyFinderFileBufferDir)
  endif
endif

command! -complete=dir -nargs=1 FuzzyFinderFile call fuzzyfinders#command(g:fuzzyfinders_file_cmd, <q-args>, 'edit', 'file >')

command! -complete=dir -nargs=1 FuzzyFinderDir call fuzzyfinders#command(g:fuzzyfinders_dir_cmd, 'Explore', 'directory > ')

" ------------------------------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

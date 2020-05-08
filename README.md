This is a minimalist's Vim plug-in that selects a sensible

- fuzzy matcher (by default, among, in this order, `sk`, `fzy`, `fzf` and `peco`) and
- file finder (by default, among, in this order, `fd`, `ripgrep`, `ag` and `find`, on Unix, or `dir`, on Microsoft Windows)

to provide

- commands `:FuzzyFinderFile` and `:FuzzyFinderDir` for fuzzy selecting a file respectively directory in the supplied directory, for example, `FuzzyFinderDir .`, and
- mappings `<Ctrl-P>` and `g<Ctrl-P>` in normal mode (in terminal Vim) that call `:FuzzyFinderFile` for fuzzy selecting a file in the current working directory respectively in that of the currently open buffer.

# Setup

To change the fuzzy matcher, change the values of `g:fuzzyfinders_matchers` in your `vimrc`;
by default set to

```vim
  let g:fuzzyfinders_matchers = [
  \ 'sk',
  \ 'fzy',
  \ 'fzf',
  \ 'peco',
  \ ]
```

To change the file finder, change the values of `g:fuzzyfinders_file_cmds` in your `vimrc`;
by default set to

```vim
  let g:fuzzyfinders_file_cmds = [
  \ 'fd -L --type file --hidden --no-ignore --exclude .git/ --color never ' . (has('win32') ? '--fixed-strings ' : '') . '"" .',
  \ 'rg --glob "" --files --hidden --no-ignore --iglob !.git/ --color never "" .' ,
  \ 'ag --files-with-matches --unrestricted --ignore .git/ --nocolor --silent --filename-pattern "" .',
  \ ]
```

To change the directory finder, change the values of `g:fuzzyfinders_dir_cmds` in your `vimrc`;
by default set to

```vim
  let g:fuzzyfinders_dir_cmds = [
        \ 'fd -L --type directory --hidden --no-ignore --exclude .git/ --color never ' . (has('win32') ? '--fixed-strings ' : '') . ' "" .',
        \ ]
```

To disable scheduling of the fuzzy finder (to avoid hogging the system's capacities), add to your `vimrc`

```vim
  let g:fuzzyfinders_use_scheduler = 0
```

To change the default mappings, change

```vim
nmap  <c-p>  <Plug>(FuzzyFinderFileWorkDir)
nmap g<c-p>  <Plug>(FuzzyFinderFileBufferDir)
```

in your `vimrc`.
For example, to disable the mapping `<c-p>`,

```vim
nmap  <sid>(DisableFuzzyFinderFileWorkDir)  <Plug>(FuzzyFinderFileWorkDir)
```

# Related

The plug-in [vim-picker](https://github.com/srstevenson/vim-picker) uses `git ls-files` whenever the directory is inside a Git repository, and `fd` otherwise.

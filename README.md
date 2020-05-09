This is a minimalist's Vim plug-in that selects a sensible

- fuzzy matcher (by default, among, in this order, [skim](https://github.com/lotabout/skim/releases/), [fzy](https://github.com/aperezdc/zsh-fzy), [fzf](https://github.com/junegunn/fzf-bin/releases), [gof](https://github.com/mattn/gof/releases) and [peco](https://github.com/peco/peco/)) and
- file finder (by default, among, in this order, [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), [ag](https://github.com/ggreer/the_silver_searcher) and [find](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html), on Unix, or `dir`, on Microsoft Windows)

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
  \ 'gof',
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

# Related Plug-ins

See [fuzzyfinders.sh](https://github.com/Konfekt/fuzzyfinders.sh) to add key bindings in `Bash` and `ZSH` to insert, right at the cursor position, a fuzzily found

- command line of the history ,
- file path,
- directory path ,
- the path of a recently changed file , or
- the path of a directory recently changed to or of a subdirectory in the current directory.

The plug-in [vim-picker](https://github.com/srstevenson/vim-picker) uses `git ls-files` whenever the directory is inside a Git repository, and `fd` otherwise.

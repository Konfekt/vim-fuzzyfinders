This is a minimalist's Vim plug-in that selects a sensible

- fuzzy matcher (among, in this order, `sk`, `fzy`, `fzf` and `peco`) and
- file finder (among, in this order, `fd`, `ripgrep`, `ag`, `find` and `dir`)

to provide

- commands `:FuzzyFinderFile` and `:FuzzyFinderDir` for fuzzy selecting a file respectively directory in the supplied directory, for example, `FuzzyFinderDir .`, and
- mappings `<c-p>` and `g<c-p>` in normal mode (in terminal Vim) that call `:FuzzyFinderFile` for fuzzy selecting a file in the current working directory respectively in that of the currently open buffer.

# Setup

To change the default fuzzy finder, change the value of `g:fuzzyfinders_matcher` in your `vimrc`.
For example,

```vim
let g:fuzzyfinders_matcher = 'poco'
```

To change the default mappings, change

```vim
nmap  <c-p>  <Plug>(FindWorkDir)
nmap g<c-p>  <Plug>(FindFileDir)
```

in your `vimrc`.
For example, to disable the mapping `<c-p>`,

```vim
nmap  <sid>(DisableFuzzyFindFileWorkDir)  <Plug>(FuzzyFindFileWorkDir)
```


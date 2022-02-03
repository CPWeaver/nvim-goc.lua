# nvim-goc.lua
Simple go coverage plugin that supports:
* running `go test --coverprofile` from the current file's directory,
  highlighting covered and not covered lines of the file
* clearing the coverage highlighting
* conveniently opening the `_test.go` file based on the current file
* opening the `_test.go` file in a split window (horizontal (default) or
  vertical)

## Install with vim-plug

Add to `init.vim`:
```
Plug 'jdstrand/nvim-goc.lua', { 'branch': 'jdstrand/main' }
```

Run:
```
$ nvim +PlugInstall +qall
```

## Setup

Add to `init.vim`:
```
lua <<EOF
  -- If set, when we switch between buffers, it will not split more than once
  -- and will switch to the existing buffer instead (ie, this allows
  -- goc.AlternateSplit to toggle between the windows)
  --vim.opt.switchbuf = 'useopen'

  local goc = require'nvim-goc'
  -- By default, goc.AlternateSplit will use a horizontal split. Adjust this to
  -- use a vertical split instead.
  goc.setup({ verticalSplit = false })

  -- nvim 0.6.1
  vim.api.nvim_set_keymap('n', '<leader>gcr', ':lua require("nvim-goc").Coverage()<CR>', {silent=true})
  vim.api.nvim_set_keymap('n', '<leader>gcc', ':lua require("nvim-goc").ClearCoverage()<CR>', {silent=true})
  vim.api.nvim_set_keymap('n', ']a', ':lua require("nvim-goc").Alternate()<CR>', {silent=true})
  vim.api.nvim_set_keymap('n', '[a', ':lua require("nvim-goc").Alternate(true)<CR>', {silent=true})

  -- nvim > 0.6.1
  --vim.keymap.set('n', '<leader>gcr', goc.Coverage, {silent=true})
  --vim.keymap.set('n', '<leader>gcc', goc.ClearCoverage, {silent=true})
  --vim.keymap.set('n', ']a', goc.Alternate, {silent=true})
  --vim.keymap.set('n', '[a', goc.AlternateSplit, {silent=true})

  -- default colors
  -- vim.highlight.link('GocNormal', 'Comment')
  -- vim.highlight.link('GocCovered', 'String')
  -- vim.highlight.link('GocUncovered', 'Error')
EOF
```

Can override the colors by setting the `GocNormal`, `GocCovered` and
`GocUncovered` highlights. Eg, in `init.vim` to set the colors directly:
```
highlight GocNormal ctermfg=DarkGray guifg=DarkGray
highlight GocCovered ctermfg=Green cterm=bold guifg=Green gui=bold
highlight GocUncovered ctermfg=Red cterm=bold guifg=Red gui=bold
```

or to use different highlight links:
```
highlight link GocNormal Comment
highlight link GocCovered Operator
highlight link GocUncovered Type
```

or via lua (note, `vim.highlight` not available from lua yet so need to use
`vim.cmd`):
```lua
  vim.cmd[[highlight GocNormal ctermfg=DarkGray guifg=DarkGray]]
  vim.cmd[[highlight GocCovered ctermfg=Green cterm=bold guifg=Green gui=bold]]
  vim.cmd[[highlight GocUncovered ctermfg=Red cterm=bold guifg=Red gui=bold]]
```

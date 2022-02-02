# nvim-goc.lua
easy go coverage

![image](https://user-images.githubusercontent.com/1598854/131515315-6178a680-cad1-4ccb-90e4-c61245f10b67.png)

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

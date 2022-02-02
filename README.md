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

```lua

-- if set, when we switch between buffers, it will not split more than once. It will switch to the existing buffer instead
vim.opt.switchbuf = 'useopen'

local goc = require'nvim-goc'
goc.setup({ verticalSplit = false })


vim.keymap.set('n', '<Leader>gcr', goc.Coverage, {silent=true})
vim.keymap.set('n', '<Leader>gcc', goc.ClearCoverage, {silent=true})
vim.keymap.set('n', ']a', goc.Alternate, {silent=true})
vim.keymap.set('n', '[a', goc.AlternateSplit, {silent=true})

-- default colors
-- vim.highlight.link('GocNormal', 'Comment')
-- vim.highlight.link('GocCovered', 'String')
-- vim.highlight.link('GocUncovered', 'Error')
```

# NVIM Buffer Browser Navigation

`:b#` on steroids. Browse your buffers like you browse history in a browser.

## Motivation

While `:bnext` and `:bprev` allows you to browse between buffers, it is not
very intuitive. Oftentimes I would jump to definitions, a different file
through netrw, an org file and then when using bprev I would end up in a
completely different file, because buffers are ordered by when they are opened. 
`:b#`, <Ctrl-I> and <Ctrl-O> works only assuming you didn't navigate one step 
further in the documentation.

I wanted to be able to browse buffers in a way that is similar to how you
browse tabs in a browser. 

## Usage

Install through any of your favorite plugin managers. For example, with
[lazy](https://www.lazyvim.org).

This plugin implements two functions: `require('buffer-browser').next()` and
`require('buffer-browser').prev()`.

You can easily map these to whatever you want. Here is an example `init.lua`:
```lua
vim.api.nvim_set_keymap('n', '<leader>b[', require("buffer-browser").next(), {desc = "Next [B]uffer [[]"})
vim.api.nvim_set_keymap('n', '<leader>b]', require("buffer-browser").prev(), {desc = "Previous [B]uffer []]"})
```

## Splits

This plugin works with splits. If you have multiple splits open, the plugin
will fork the split history and create a different "buffer history" for that 
particular split.

## Credits

The plugin is mostly based on [ton/vim-bufsurf](https://github.com/ton/vim-bufsurf), but rewritten in Lua. 

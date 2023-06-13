# NVIM Buffer Browse

`:b#` on steroids. Browse your buffers like you browse history in a browser.

## Motivation

While `:bnext` and `:bprev` allows you to browse between buffers, it is not
very intuitive. Oftentimes I jump to definitions and `:bprev` would then end up
in a completely different file, because buffers are ordered by when they are
opened, not by history. `:b#`, `<Ctrl-6>` and `<Ctrl-O>` works only
assuming you didn't navigate around further.

I wanted to be able to browse buffers in a way that is similar to how you
browse tabs in a browser.

## Usage

This plugin implements two functions: `require('buffer-browser').next()` and
`require('buffer-browser').prev()`.

You can easily map these to whatever you want. Here is an example `init.lua`:

```lua
vim.api.nvim_set_keymap('n', '<leader>b[', require("buffer_browser").next, {desc = "Next [B]uffer [[]"})
vim.api.nvim_set_keymap('n', '<leader>b]', require("buffer_browser").prev, {desc = "Previous [B]uffer []]"})
```

Use these to navigate your buffer history in the order that you opened them.

### Splits

If a split has been performed, the new split will not preserve any of the previous history.

## Installation

Install through any of your favorite plugin managers.

### [lazy](https://www.lazyvim.org).

Add the following line in your `require('lazy').setup` call

```lua
{
    'https://git.sr.ht/~marcc/BufferBrowser',
}
```

Then run somewhere in your init.lua run the setup:

```lua
require('buffer_browser').setup()
```

### Configuration

You can configure the `filetype_filters` by passing a table to the `setup`
function. This is the default config:

```lua
require('buffer-browser').setup({
    filetype_filters = {'gitcommit', 'TelescopePrompt'}
})
```

This can be used to filter out buffers you do not want in the history.

#### Removing Netrw buffers

By default, BufferBrowser will remember Netrw buffers. To immediately close
netrw after you have opened a file, you can add to init.lua

`vim.g.netrw_fastbrowse=0`

This will remove the netrw buffer and wipe it from the browser history when
you open a new file.

## Credits

The plugin is mostly a copy of
[ton/vim-bufsurf](https://github.com/ton/vim-bufsurf), but rewritten in Lua and
adds the ability to filter unwanted filetypes.

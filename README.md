# NVIM Buffer Browse 

`:b#` on steroids. Browse your buffers like you browse history in a browser.

## Motivation

While `:bnext` and `:bprev` allows you to browse between buffers, it is not
very intuitive. Oftentimes I jump to definitions, a different file through
netrw, an org file. `:bprev` would then end up in a completely different file,
because buffers are ordered by when they are opened, not by history. `:b#`,
<Ctrl-I>, <Ctrl-6> and <Ctrl-O> works only assuming you didn't navigate one step further
in the documentation.

I wanted to be able to browse buffers in a way that is similar to how you
browse tabs in a browser. 

## Usage

This plugin implements two functions: `require('buffer-browser').next()` and
`require('buffer-browser').prev()`.

You can easily map these to whatever you want. Here is an example `init.lua`:
```lua
vim.api.nvim_set_keymap('n', '<leader>b[', require("buffer_browser").next(), {desc = "Next [B]uffer [[]"})
vim.api.nvim_set_keymap('n', '<leader>b]', require("buffer_browser").prev(), {desc = "Previous [B]uffer []]"})
```

### Splits

If a split has been performed, the new split will not preserve any of the previous history.

## Insallation

Install through any of your favorite plugin managers. 

### [lazy](https://www.lazyvim.org). 

Make sure to run the setup function. For example with lazy:

```lua 
{
    'https://git.sr.ht/~marcc/BufferBrowser',
}
```

Then run 

```lua
require('buffer_browser').setup()
```


### Configuration 

You can configure the `filetype_filters` by passing a table to the `setup`
function. This is the default config:

```lua
require('buffer-browser').setup({
    -- '' + 'netrw' is used to filter out netrw.
    filetype_filters = ['', 'netrw', 'gitcommit', 'TelescopePrompt']
})
```

This can be used to filter out buffers you do not want in the history.

#### Limitation

To filter out netrw, we need to also filter out `''`, as the filetype
occassionally gets set to that by netrw (not sure why...). This means files
without filetype are filtered out.

## Credits 

The plugin is mostly a copy of
[ton/vim-bufsurf](https://github.com/ton/vim-bufsurf), but rewritten in Lua and
adds the ability to filter unwanted filetypes to get rid of netrw buffers. 


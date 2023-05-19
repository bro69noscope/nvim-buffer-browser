if exists('g:loaded_buffer_browser') | finish | endif " prevent loading file twice

" command to run our plugin
command! BufferBrowserNext lua require'buffer_browser'.next()
command! BufferBrowserPrevious lua require'buffer_browser'.prev()
command! BufferBrowserEcho lua require'buffer_browser'.printBrowserHistory()

let g:loaded_buffer_browser = 1

if exists('g:loaded_buffer_browser') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" command to run our plugin
command! BufferBrowserNext lua require'buffer_browser'.next()
command! BufferBrowserPrevious lua require'buffer_browser'.prev()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_whid = 1

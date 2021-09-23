command! -range=% Scpaste lua require("scpaste")(<line1>, <line2>)

" Don't use <Cmd> mapping so that we can use ranges
noremap <Plug>(scpaste) :Scpaste<CR>

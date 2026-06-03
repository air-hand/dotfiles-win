set ignorecase
" set smartcase
set showmode
" v to visual block (no use visual)
nnoremap v <c-v>

" reload vim config
let mapleader = "\<space>"
" space+r: source vimrk
nnoremap <leader>r :source $MYVIMRC<cr>

" clear last searched register
nnoremap <leader>c :let @/ = ""<cr>

set tabstop=4
set shiftwidth=4
set expandtab

set statusline+=%F
set laststatus=2
set number
"set belloff=all
set visualbell

let g:nvim_config_root = stdpath('config')
let s:config_files = [
    \ ]
for conf in s:config_files
    execute 'source ' . g:nvim_config_root . '/' . conf
endfor

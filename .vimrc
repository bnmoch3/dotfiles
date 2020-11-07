" CREDITS for initial settings, 
" - The fine folks at MIT's Missing Semester class
" - ThePrimeagen: www.youtube.com/watch?v=n9k9scbTuvQ

" set encoding to utf-8 because why not
set encoding=utf-8

" Switch from the default Vi-compatibility mode so as to enable useful
" Vim functionality.
set nocompatible

" Allow to cut/copy/paste to/from system clipboard
set clipboard=unnamed
noremap y "*y
noremap yy "*yy
noremap Y "*y$
noremap x "*x
noremap dd "*dd
noremap D "*D


" Center to line when searching
" currently disabling rest of options till I understand them
:nnoremap n nzz
:nnoremap N Nzz
" :nnoremap * *zz
" :nnoremap # #zz
" :nnoremap g* g*zz
" :nnoremap g# g#zz

" Disable the default Vim startup message.
set shortmess+=I

" Turn on syntax highlighting.
syntax on

" Set tabs to 4 characters, spaces long
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab 

" Enable sensible indentation and settings for python files
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix

" for python, mark extra whitespace as bad
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/


" Enable sensible indentation for html and css files
au BufNewFile,BufRead  *.html, *.css
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

" Enable vim to try do a smart job in indentations
set smartindent

" no swapfile, no backups
set noswapfile
set nobackup
set undodir=~/.vim/undodir " you have to mkdir
set undofile

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

" Show line numbers.
set number

" Enable relative line numbering mode.
set relativenumber

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" Make backspace behave more reasonably
set backspace=indent,eol,start

" Disable hiding buffers protection. See `:help hidden` for more information on this.
set hidden

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Enable mouse support
set mouse+=a

" no wrap if line goes over width of screen
set nowrap

" set width to 80 characters
set colorcolumn=80
highligh ColorColumn ctermbg=0 guibg=lightgrey

" Try to prevent bad habits like using the arrow keys for movement.
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>

" on splitting windows, open new file on right or below
set splitbelow
set splitright
" add key combos for navigating between split windows
nnoremap <C-J> <C-W><C-J> " ctrl+j move to split window below
nnoremap <C-K> <C-W><C-K> " ctrl+k move to split window above
nnoremap <C-L> <C-W><C-L> " ctrl+l move to split window on the right
nnoremap <C-H> <C-W><C-H> " ctrl+h move to spit window on the left

" enable folding
set foldmethod=indent
set foldlevel=99

"set up plugins - vim-plug
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree' "for filetree
Plug 'jistr/vim-nerdtree-tabs'
" add mappings for nerdtree file browser
" ctrl-n to toggle filetree
map <C-n> :NERDTreeToggle<CR> 
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

" Simplify folding
Plug 'tmhedberg/SimpylFold'
let g:SimpylFold_docstring_preview=1 " enable docstrings within folded code

" Better indentation for python files
Plug 'vim-scripts/indentpython.vim'

" Enable better syntax highlighting and PEP8 checking
Plug 'vim-syntastic/syntastic'
Plug 'nvie/vim-flake8'
let python_highlight_all=1
syntax on

call plug#end()

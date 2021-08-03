" Credits:
" - The fine folks at MIT's Missing Semester class
" - ThePrimeagen: www.youtube.com/watch?v=n9k9scbTuvQ
" - Practical Vim - Drew Neil

" set encoding to utf-8 because why not
set encoding=utf-8

" Switch from the default Vi-compatibility mode so as to enable useful
" Vim functionality.
set nocompatible

" By default, vim records and persists the last 20 commands.
" The configuration below increases this limit
set history=200

" Allow to cut/copy into system clipboard 
set clipboard=unnamedplus
noremap Y "+y
noremap YY "+yy
noremap D "*D
" noremap Y "*y$
" noremap x "*x
" noremap dd "*dd

" enable file detection and indent scripts
filetype on
filetype plugin indent on

" enable easy navigation of buffer list
noremap <silent> [b :bprevious<CR>
noremap <silent> ]b :bnext<CR>
noremap <silent> [B :bfirst<CR>
noremap <silent> ]B :blast<CR>

" make sure spacebar doesn't have any mapping beforehand
nnoremap <SPACE> <Nop>
" set mapleader key to spacebar
let mapleader=" "

" Add mapping for clearing highlighting after a search
nnoremap <silent> \ :<C-u>nohlsearch<CR>

" Adds visual-star search to vim. This inverts the default behaviour
" in vim which is: while in visual mode, doing a star-search searches 
" for all the words visually selected rather than the word directly
" under the cursor.
" xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
" xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" function! s:VSetSearch(cmdtype)
"   let temp = @s
"   norm! gv"sy
"   let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
"   let @s = temp
" endfunction

" Center to line when searching
" currently disabling rest of options till I understand them
:nnoremap n nzz
:nnoremap N Nzz
:nnoremap * *zz
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
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

" for python, mark extra whitespace as bad
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/


" Enable sensible indentation for html and css files
au BufNewFile,BufRead  *.html,*.css,*.js,*.ts,*.jsx,*.tsx
    \ set tabstop=2 |
    \ set shiftwidth=2 |
    \ set softtabstop=2

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
" set relativenumber

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
set hlsearch

" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Enable mouse support
set mouse+=a

" no wrap if line goes over width of screen
set nowrap

" set width to 80 characters
set colorcolumn=80
" highlight ColorColumn ctermbg=0 guibg=lightgrey
hi ColorColumn ctermbg=lightcyan guibg=blue

" Try to prevent bad habits like using the arrow keys for movement.
" nnoremap <Left>  :echoe "Use h"<CR>
" nnoremap <Right> :echoe "Use l"<CR>
" nnoremap <Up>    :echoe "Use k"<CR>
" nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
" inoremap <Left>  <ESC>:echoe "Use h"<CR>
" inoremap <Right> <ESC>:echoe "Use l"<CR>
" inoremap <Up>    <ESC>:echoe "Use k"<CR>
" inoremap <Down>  <ESC>:echoe "Use j"<CR>

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

" ripgrep
Plug 'jremmen/vim-ripgrep'

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

" For working with Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Run goimports along gofmt on each save
let g:go_fmt_command = "goimports"    
" Automatically get signature/type info for object under cursor
let g:go_auto_type_info = 1           

" customize status line
Plug 'vim-airline/vim-airline'

" add tim-pope's commentary plugin
Plug 'tpope/vim-commentary'

" add tim-pope's surround plugin to simplify quoting/wrapping text
Plug 'tpope/vim-surround'

" add git info
Plug 'tpope/vim-fugitive'

" add tim-pope's unimpaired plugin for quick navigation of lists
Plug 'tpope/vim-unimpaired'

" add syntax highlighting for tsx
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" for cpp dev
Plug 'ycm-core/YouCompleteMe'
" to enable syntastic:
" github.com/ycm-core/YouCompleteMe#user-content-the-gycm_show_diagnostics_ui-option
let g:ycm_show_diagnostics_ui = 0
Plug 'preservim/tagbar'
let syntastic_cpp_checkers = ['clang_tidy']
let syntastic_go_checkers = [ 'gofmt' ]
Plug 'rhysd/vim-clang-format'
let g:clang_format#auto_format = 1

    
" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" for searching files within vim
nnoremap <silent><leader>f :GFiles!<CR>
" search for open buffers with fzf
nnoremap <silent><leader>b :Buffers!<CR>
" search for code with Ag
nnoremap <silent><leader>c :Ag!<CR>
" search for marks with fzf
nnoremap <silent><leader>m :Marks!<CR>
" search lines within current file with fzf
nnoremap <silent><leader>l :BLines<CR>
" search windows & tabs with fzf
nnoremap <silent><leader>w :Windows<CR>

" add tmux navigation compatibility
Plug 'christoomey/vim-tmux-navigator'
let g:tmux_navigator_save_on_switch = 1  
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1
" Easily interact with tmux from vim
Plug 'preservim/vimux'
map <Leader>vp :VimuxPromptCommand<CR>
" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>
" Inspect runner pane
map <Leader>vi :VimuxInspectRunner<CR>
" Zoom the tmux runner pane
map <leader>vz :VimuxZoomRunner<CR>

call plug#end()

if executable('rg')
    let g:rg_derive_root='true'
endif

let g:ctrlp_user_command = ['.git', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

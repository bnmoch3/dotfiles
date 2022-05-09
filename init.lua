vim.cmd([===[
" MY VIMRC

"------------------------------------------------------------------------------ 
"            General
"------------------------------------------------------------------------------ 
" {{{
"
" switch from the default Vi-compatibility mode so as to enable useful
" vim functionality.
set nocompatible

" set leader and localleader keys
let mapleader = " "
let maplocalleader = ","

" clear autocmds in case file is sourced again
augroup my_autocmds 
    autocmd!
augroup END

" disable LSP features in ALE before plugins are loaded
let g:ale_disable_lsp = 1

" automatically install vim-plug
let s:data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(s:data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.s:data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

" disable the default Vim startup message.
" dont pass messages to |ins-completion-menu|
set shortmess+=I
set shortmess+=c

" without this option, whenever you switch buffers and your current buffer is 
" not saved, vim will prompt you to save the file
set hidden

" no swapfile, no backups
set noswapfile nobackup nowritebackup undofile
set undodir=~/.vim/undodir " you have to mkdir

" enable mouse support
set mouse+=a

" disable audible bell because it's annoying
set noerrorbells visualbell t_vb=

" set encoding to utf-8 because why not
set encoding=utf-8

" enable file detection and indent scripts
filetype on

" jump to the matching bracket briefly when a bracket is inserted
set showmatch matchtime=3 

" make backspace behave more reasonably
set backspace=indent,eol,start

" make vim paste copied text from the external program without
" having to use `=*p` or `=+p`
set clipboard=unnamed

" toggle word selection visually
nnoremap <localleader>v viW
vnoremap <localleader>v b
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Plugins
"------------------------------------------------------------------------------ 
" {{{
"
" add tim-pope's commentary plugin
Plug 'tpope/vim-commentary'

"" add tim-pope's surround plugin to simplify quoting/wrapping text
Plug 'tpope/vim-surround'

" for autoclosing {},(),[],"",'',``
Plug 'jiangmiao/auto-pairs'
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Styling
"------------------------------------------------------------------------------ 
" {{{
"
" add theme
Plug 'joshdick/onedark.vim'
Plug 'fxn/vim-monochrome'
Plug 'altercation/vim-colors-solarized'

" options: [light] morning, solarzed [dark] onedark, monochrome
set background=dark
let s:my_default_colorscheme = "monochrome"
let g:solarized_termcolors=256

" for toggling styles
let s:theme_index_dark = 0
let s:theme_index_light = 0
function! ToggleStyle(theme)
    echom "theme: ".a:theme
    let l:themes = {
        \ "dark": ["onedark", "monochrome"],
        \ "light": ["solarized", "morning"],
        \ }
    if a:theme ==# "dark"
        if s:theme_index_dark ==# len(l:themes.dark)
            let s:theme_index_dark = 0
        endif
        set background=dark
        execute "colorscheme ".l:themes.dark[s:theme_index_dark]
        let s:theme_index_dark = s:theme_index_dark + 1
        let g:lightline.colorscheme = 'srcery_drk'
    elseif a:theme ==# "light"
        if s:theme_index_light ==# len(l:themes.light)
            let s:theme_index_light = 0
        endif
        set background=light
        execute "colorscheme ".l:themes.light[s:theme_index_light]
        let s:theme_index_light = s:theme_index_light + 1
        let g:lightline.colorscheme = 'solarized'
    endif
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
endfunction
command! Dark call ToggleStyle("dark")
command! Light call ToggleStyle("light")

" turn on syntax highlighting
syntax on

" do not display mode in statusline, will be displayed by statusbar
set noshowmode

" remove default wrapping
set nowrap

" set width to 80 characters
set colorcolumn=80
" highlight ColorColumn ctermbg=0 guibg=lightgrey
highlight ColorColumn ctermbg=grey guibg=darkgrey

" add line numbering
set number numberwidth=5 
set relativenumber

" give more space for displaying messages
set cmdheight=1

" set signcolumn even if there's no error/warning
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" for showing git diff markers on curr buffer
Plug 'airblade/vim-gitgutter'

" for distraction free writing
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'
" Highlighting priority (default: 10)
" Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1
augroup my_autocmds
    autocmd! User GoyoEnter Limelight
    autocmd! User GoyoLeave Limelight!
augroup END

" command! Center :Goyo<cr>
command! Center Goyo
command! Focus Limelight!!
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Statusbar
"------------------------------------------------------------------------------ 
" {{{
"
" add statusline
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
let g:lightline = {
    \ 'colorscheme': 'srcery_drk',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             ['readonly', 'filename']],
    \   'right': [ 
    \              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \              [ 'percent', 'lineinfo'],
    \              [ 'buffer_number'],
    \              [ 'gitbranch']]
    \ },
    \ 'component': {
    \   'buffer_number': '[%n]' 
    \ },
    \ 'component_function': {
    \   'filename': 'LightlineFilename',
    \   'gitbranch': 'TrimmableGitBranchname',
    \ },
    \ }
let g:lightline.component_expand = {
    \  'linter_checking': 'lightline#ale#checking',
    \  'linter_infos': 'lightline#ale#infos',
    \  'linter_warnings': 'lightline#ale#warnings',
    \  'linter_errors': 'lightline#ale#errors',
    \  'linter_ok': 'lightline#ale#ok',
    \ }
let g:lightline.component_type = {
    \     'linter_checking': 'right',
    \     'linter_infos': 'right',
    \     'linter_warnings': 'warning',
    \     'linter_errors': 'error',
    \     'linter_ok': 'right',
    \ }
" trimmable git branch name
function! TrimmableGitBranchname()
  return winwidth(0) > 70 ? FugitiveHead() : ''
endfunction
" concat filename and modified status
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Folding
"------------------------------------------------------------------------------ 
" {{{
"
" for folding
set foldmethod=indent
set foldlevel=99

" toggle foldcolumn
nnoremap <localleader>f :call <SID>FoldColumnToggle()<cr>
function! s:FoldColumnToggle()
    if &foldcolumn
        setlocal foldcolumn=0
    else
        setlocal foldcolumn=4
    endif
endfunction
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Indenting
"------------------------------------------------------------------------------ 
" {{{
"
" set tabs to 4 characters, spaces
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" let vim try do a smart job in indentations
set smartindent

" enable autoindent
set autoindent
filetype plugin indent on
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Searching, Tags, Fzf
"------------------------------------------------------------------------------ 
" {{{
"
" incremental highlighting for search
set hlsearch incsearch

" for clearing highlighting after a search
nnoremap <silent> \ :<C-u>nohlsearch<CR>

" for browsing tags
Plug 'preservim/tagbar'
nnoremap <localleader>t :TagbarToggle<CR>

" use ripgrep for external grep
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" center to line when searching
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz

" ignorecase makes all searches case-insensitive
" smartcase overrides the ignorecase option if the search pattern contains
" at least one uppercase character. That is, if there's an uppercase
" character, the search becomes case-sensistive
" For situations where you want to override ignorecase for an all-lowercase
" search patter, append \C to the pattern, for example /foo\C will not match
" Foo and FOO
set ignorecase smartcase

nnoremap <leader>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <leader>g :<c-u>call <SID>GrepOperator(visualmode())<cr>

function! s:GrepOperator(type)
    let saved_unnamed_register = @@

    " get selected text
    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        " grep doesn't search across lines by default so having a 
        " newline in the search pattern doesn't make much sense i.e. 
        " when using linewise/blockwise visual mode
        return
    endif

    " echom "[" . shellescape(@@) . "]"
    silent execute "grep! " . shellescape(@@) . " ."
    let @@ = saved_unnamed_register
    redraw!
    copen
endfunction

" set up fzf
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" f for searching files within vim
" b search for open buffers with fzf
" c search for code with ripgrep 
" m search for marks with fzf
" l search lines within current file with fzf
" w search windows & tabs with fzf
nnoremap <silent><leader>f :Files!<CR> 	
nnoremap <silent><leader>b :Buffers!<CR> 	
nnoremap <silent><leader>c :Rg!<CR> 		
nnoremap <silent><leader>m :Marks!<CR> 		
nnoremap <silent><leader>l :BLines!<CR> 		
nnoremap <silent><leader>w :Windows!<CR> 	
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Navigation
"------------------------------------------------------------------------------ 
" {{{
"
" add tmux navigation compatibility
Plug 'christoomey/vim-tmux-navigator'
let g:tmux_navigator_save_on_switch = 1  
" disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" for toggling, displaying and navigating marks
Plug 'kshenoy/vim-signature'

" tim-pope's, for quick navigation of lists
Plug 'tpope/vim-unimpaired'

" add key combos for navigating between split windows
" ctrl+j move to split window below
" ctrl+k move to split window above
" ctrl+l move to split window on the right
" ctrl+h move to spit window on the left
nnoremap <C-J> <C-W><C-J> 
nnoremap <C-K> <C-W><C-K> 
nnoremap <C-L> <C-W><C-L> 
nnoremap <C-H> <C-W><C-H> 
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Nerdtree
"------------------------------------------------------------------------------ 
" {{{
"
" add nerdtree for file nav
Plug 'preservim/nerdtree'
" NERDTreeFind - find location of file in curr buffer
" NERDTreeToggle - open/close NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-c> :NERDTreeFind<CR>
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
" autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
"     \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" manage NERDTree and tabs painlessly
Plug 'jistr/vim-nerdtree-tabs'
" for displaying git status in nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'M',
                \ 'Staged'    :'+',
                \ 'Untracked' :'??',
                \ 'Renamed'   :'Renamed',
                \ 'Unmerged'  :'Unmerged',
                \ 'Deleted'   :'Deleted',
                \ 'Dirty'     :'Dirty',
                \ 'Ignored'   :'Ignored',
                \ 'Clean'     :'Clean',
                \ 'Unknown'   :'Unknown',
                \ }
" disable show ignored
let g:NERDTreeGitStatusShowIgnored = 0
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Quickfix
"------------------------------------------------------------------------------ 
" {{{
"
" toggle quickfix
nnoremap <leader>q :call <SID>QuickFixToggle()<cr>
let g:quickfix_is_open = 0
function! s:QuickFixToggle()
    if g:quickfix_is_open
        cclose
        let g:quickfix_is_open = 0
        execute g:quickfix_return_to_window . "wincmd w"
    else
        let g:quickfix_return_to_window = winnr()
        copen
        let g:quickfix_is_open = 1
    endif
endfunction
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Windows, Tabs, Buffers
"------------------------------------------------------------------------------ 
" {{{
"
" display buffer list on tabline
Plug 'ap/vim-buftabline'

" on splitting windows, open new file on right or below
set splitbelow
set splitright

" Unbind some useless/annoying default key bindings.
" 'Q' in normal mode enters Ex mode. You almost never want this.
nnoremap Q <Nop> 

" keep current buffer only
nnoremap <Leader>o :w<CR>:%bd \| e# \| bd# <CR>

" for resizing
nnoremap <Up> 5<C-W>+
nnoremap <Down> 5<C-W>-
nnoremap <Left> 5<C-W>>
nnoremap <Right> 5<C-W><
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Terminal
"------------------------------------------------------------------------------ 
" {{{
"
" for terminal
" Plug 'kassio/neoterm'

" launch terminal
nnoremap <C-Down> :sp \| terminal<CR>10<C-W>-
nnoremap <C-Right> :vs \| terminal<CR>40<C-W><

" TODO if was in insert mode in terminal, when navigating away then 
" back, maintain insert mode

" TODO add mapping for exiting terminal mode

" enable escape for terminal mode
" enable nav from terminal (while in terminal mode)
if has('nvim')
    tnoremap <Esc> <C-\><C-n>

    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
endif
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Linting, Fixing
"------------------------------------------------------------------------------ 
" {{{
"
" for linting + some fixing
" disable using ale for completion
let g:ale_completion_enabled = 0
let g:ale_linters = {
    \ 'python': ['flake8'],
    \ 'sh' : ['shellcheck'],
    \ 'lua': ['luacheck'],
    \ }
let g:ale_fixers = {
    \ 'python': ['black', 'trim_whitespace', 'isort'],
    \ 'html' : ['prettier'],
    \ 'json' : ['prettier'],
    \ 'lua' : ['stylua'],
    \ }
Plug 'dense-analysis/ale'
" only run linters and fixers that are specified
let g:ale_linters_explicit = 1
" edit print format
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '>>'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%:%severity%] %s'
" limit running of linters
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
 " run linter on opening a file
let g:ale_lint_on_enter = 1
" use quickfix list to navigate errors
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
" height for ALE list display
let g:ale_list_window_size = 5
" virtual env for ALE to use
let g:ale_python_black_executable = $HOME . '/venvs/nvim/bin/black'
let g:ale_python_black_use_global = 1
let g:ale_python_flake8_executable = $HOME . '/venvs/nvim/bin/flake8'
let g:ale_python_flake8_use_global = 1
let g:ale_python_isort_executable = $HOME . '/venvs/nvim/bin/isort'
let g:ale_python_isort_use_global = 1
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Git
"------------------------------------------------------------------------------ 
" {{{
"
" for working with git within vim
Plug 'tpope/vim-fugitive' 
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            LSP
"------------------------------------------------------------------------------ 
" {{{
"
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
nnoremap <silent> gd :call <SID>show_documentation()<CR>
nnoremap <silent> gD <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-rename)
nmap <silent> gR <Plug>(coc-references)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Vimrc
"------------------------------------------------------------------------------ 
" {{{
"
" for vim filetype, set foldmethod to marker
augroup my_autocmds
    autocmd Filetype vim setlocal foldmethod=marker
    autocmd BufReadPost *vimrc execute "normal zM"
augroup END

" save and source vimrc
nnoremap <localleader>s :w $MYVIMRC<cr>:source $MYVIMRC<cr>
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Python
"------------------------------------------------------------------------------ 
" {{{
"
" set python host
let g:python3_host_prog='~/venvs/nvim/bin/python'

" for better folding for python
Plug 'tmhedberg/SimpylFold'

" for better python indentation
Plug 'Vimjas/vim-python-pep8-indent'

" enable indentation for multiline strings (use autoindent)
let g:python_pep8_indent_multiline_string = -1

" for syntax support for jina templates
Plug 'lepture/vim-jinja'

highlight BadWhitespace ctermbg=red guibg=darkred

augroup my_autocmds
    " Enable sensible indentation and settings for python files
    autocmd BufNewFile,BufRead *.py
        \ set tabstop=4 |
        \ set softtabstop=4 |
        \ set shiftwidth=4 |
        \ set textwidth=79 |
        \ set expandtab |
        \ set fileformat=unix

    " mark extra whitespace as bad
    autocmd BufRead,BufNewFile *.py,*.pyw,*.c,*.h 
        \ match BadWhitespace /\s\+$/
augroup END
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Javascript, CSS, HTML 
"------------------------------------------------------------------------- 
" {{{
"
augroup my_autocmds 
    autocmd BufNewFile,BufRead *.html setlocal wrap

    autocmd BufNewFile,BufRead  *.html,*.css,*.js
        \ setlocal tabstop=2 | setlocal shiftwidth=2 | setlocal softtabstop=2
augroup END
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            Golang
"------------------------------------------------------------------------------ 
" {{{
"
" For working with Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_fmt_command = "goimports"    " Run goimports along gofmt on each save
let g:go_auto_type_info = 1           " Automatically get signature/type info for object under cursor
"
"
"
" }}}
"------------------------------------------------------------------------------ 
"            _
"------------------------------------------------------------------------------ 
" {{{
"
" ---
"
"
"
" }}}

call plug#end()

execute "colorscheme ".s:my_default_colorscheme
]===])

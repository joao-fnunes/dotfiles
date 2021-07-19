set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

Plugin 'airblade/vim-gitgutter'
Plugin 'editorconfig/editorconfig-vim'
"Plugin 'itchyny/lightline.vim' " Conflicts with airline
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
" Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-surround'
" Plugin 'w0rp/ale'

" Adds :BD for deleting buffer without closing window.
Plugin 'qpkorr/vim-bufkill' 

" tagbar
Plugin 'majutsushi/tagbar'

" Cscope
" Plugin 'gnattishness/cscope_maps'
" Plugin 'cscope.vim' Has better :cw integration but messes up tags. Use rtags
" instead.

" A (switch between source and header)
Plugin 'a.vim'

" Plugin 'file:///home/jp/projects/filter-graph.vim'

Plugin 'Shougo/deoplete.nvim'
Plugin 'zchee/deoplete-clang'

Plugin 'lyuts/vim-rtags'

Plugin 'henrik/vim-indexed-search'

Plugin 'sakhnik/nvim-gdb'
" Plugin 'cpiger/NeoDebug'

" Plugin 'Valloric/YouCompleteMe'

Plugin 'vim-airline/vim-airline'

Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'rodjek/vim-puppet'

Plugin 'PProvost/vim-ps1'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Custom
set incsearch
set hlsearch
set number
syntax on

let c_space_errors = 1
colorscheme peachpuff
hi Search cterm=NONE ctermfg=black ctermbg=yellow

set mouse=a

nnoremap <c-b><c-t> :NERDTreeToggle<cr>
nnoremap <c-b><c-f> :NERDTreeFind<cr>
"nnoremap <c-b><c-g> :TagbarOpen fj<cr><c-w>H25<c-w>\|
nnoremap <c-b><c-g> :TagbarToggle<cr>

" FZF
nnoremap <c-p> :FZF <cr>

" git-gutter
set updatetime=100

" fgraph
if has('nvim')
	if exists('vim.fgraph')
		lua fgraph = require "vim.fgraph"
		lua fgraph.load("callgraph")
		nnoremap <c-b>c :lua fgraph.draw()<cr>
		nnoremap <c-b>v :lua fgraph.draw{children = true}<cr>
		command! -nargs=? FGraph :lua fgraph.draw{max_depth = <args>}
		command! -nargs=? FGraphChildren :lua fgraph.draw{max_depth = <args>, children = true}
	endif
endif

" NERDTree
function! NERDTreeFindIfOpen()
	if exists("g:NERDTree") && g:NERDTree.IsOpen()
		NERDTreeFind
	endif
endfunction

augroup vimrc
	" Remove all vimrc autocommands
	autocmd!
	" autocmd BufWinEnter * call NERDTreeFindIfOpen()
augroup END

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='dark'
" let g:airline#extensions#syntastic#enabled = 1
set laststatus=2

" CtrlP
let g:ctrlp_by_filename=1

" Buffers
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <C-X> :BD<CR>
nnoremap <c-b><c-b> :CtrlPBuffer<CR>

set hidden
set confirm

set wildmode=longest:full,full

set background=dark " Fixes unreadable colors in dark blackground (dark blue).


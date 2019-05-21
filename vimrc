set nocompatible
set nostartofline
"if exists('$COLORTERM') && exists('$MRXVT_TABTITLE')
set t_Co=256
"endif
"set termguicolors
set viminfo='20,<1000,s1000,h
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm
set laststatus=2
set cmdheight=2
"set nowrapscan
set autoindent
set smartindent
set cindent
set noerrorbells
set backspace=indent,eol,start
set history=50
set ruler
set showcmd
set smartcase
set nobackup
set noswapfile
set shortmess=aI
set cmdheight=2

"set clipboard=autoselect
"set clipboard=unnamed
set title
set incsearch ignorecase hlsearch
" Press space to clear search highlighting and any message already displayed.
nnoremap <silent><Space> :silent noh<Bar>echo<CR>
autocmd BufRead *.cpp,*.h,*.c set textwidth=80
autocmd VimResized * wincmd =
autocmd BufReadPre make* setlocal textwidth=0
filetype plugin indent on
"set textwidth=80
set colorcolumn=+1
set cursorline
set confirm
set mouse=a
set expandtab
autocmd FileType make setlocal noexpandtab
set shiftwidth=4
set softtabstop=4
set showmatch
set wildmenu
set cpo+=n
syntax on
" intelligent comments
set comments=sl:/*,mb:\ *,elx:\ */
set viminfo='10,\"100,:20,%,n~/.viminfo

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode
set viminfo='10,\"100,:20,%,n~/.viminfo

function! ResCur()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction

augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END

set tags=tags
"if has('cscope')
"      set cscopetag cscopeverbose

"    if has('quickfix')
"          set cscopequickfix=s-,c-,d-,i-,t-,e-
"    endif

"    cnoreabbrev csa cs add
"    cnoreabbrev csf cs find
"    cnoreabbrev csk cs kill
"    cnoreabbrev csr cs reset
"    cnoreabbrev css cs show
"    cnoreabbrev csh cs help
   
"    command -nargs=0 Cscope cs add /auto/mcpbuilds/binos-snaps/polaris_dev/cscope.out   
"endif

if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/
set number
"set relativenumber

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:.

"--------------------Folds--------------------
set foldmethod=indent "fold based on indent
set foldnestmax=3  "deepest fold is 3 levels
set nofoldenable   "dont fold by default

"------------------Scrolling------------------
set scrolloff=8 "start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

syntax enable
if has('gui_running')
    set background=light
else
    set background=dark
endif
"let g:solarized_termcolors=16
"colorscheme default

"To enable indent on sh/bash scripts
let g:sh_indent_case_labels=1


" turn off search highlight with space key
nnoremap <leader><space> :nohlsearch<CR>
"colorscheme codeschool

"Scroolose/syntastic suggested settings
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"
"Persistent Undo
"if exists("&undodir")
set undodir=~/.vim/undo
set undofile          "Persistent undo! Pure money.
set undolevels=5000
set undoreload=5000
"endif

set ttyfast
set autoread | au CursorHold * checktime | call feedkeys("lh")
set mousehide             "hide mouse when typing

set guioptions+=F


autocmd BufRead,BufNewFile *sr?/server/*.py set colorcolumn=100
autocmd BufRead,BufNewFile *src/client/*.py set colorcolumn=120

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)
Plugin 'vim-scripts/indentpython.vim'
"Plugin 'vim-syntastic/syntastic'
"Plugin 'nvie/vim-flake8'
Plugin 'w0rp/ale'
Plugin 'google/yapf', { 'rtp': 'plugins/vim' }
Plugin 'mileszs/ack.vim'
let python_highlight_all=1
" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"http://liuchengxu.org/posts/use-vim-as-a-python-ide/
autocmd FileType python nnoremap <LocalLeader>= :0,$!yapf<CR>
" If you want to fix files automatically on save:
let g:ale_fix_on_save = 1

let g:ackprg = 'ag --nogroup --nocolor --column'

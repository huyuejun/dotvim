""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Gary's VIM configuration files, which is intended to be cross-platform.
"
" Created:      Dec 10th, 2010
" Last change:  Dec 10th, 2010
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""
""" Some default options
"""

" Use Vim settings, rather then Vi settings (much better!).
" This must tbe the first, because it changes other options as a side effect.
set nocompatible

" Allow backspacing over everthing in insert mode
set backspace=indent,eol,start

" No warning bell
set vb t_vb=

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup		" do not keep a backup file, use versions instead
set hidden          " Enable change buffer editing conviently.

colorscheme desert

set history=100		" keep 100 lines of command line history
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set incsearch		" do incremental searching
"set nu				" show line number
"set readonly		" set default to readonly
set tabstop=4		" set tab width to 4
set expandtab
set shiftwidth=4
set sw=4

set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
" if has('mouse')
"   set mouse=a
" endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Non-GUI setting
if !has('gui_running')
  " Do not increase the windows width in taglist
  let Tlist_Inc_Winwidth=0

  " Set text-mode menu
  if has('wildmenu')
    set wildmenu
    set cpoptions-=<
    set wildcharm=<C-Z>
    nmap <F10>      :emenu <C-Z>
    imap <F10> <C-O>:emenu <C-Z>
  endif

  " Change encoding according to the current console code page
"  if &termencoding != '' && &termencoding != &encoding
"    let &encoding=&termencoding
"    let &fileencodings='ucs-bom,utf-8,' . &encoding
"  endif
endif

" Display window width and height in GUI
if has('gui_running') && has('statusline')
  let &statusline=substitute(
                 \&statusline, '%=', '%=%{winwidth(0)}x%{winheight(0)}  ', '')
  set laststatus=2
endif

" Key mapping to toggle the display of status line for the last window
nmap <silent> <F6> :if &laststatus == 1<bar>
                     \set laststatus=2<bar>
                     \echo<bar>
                   \else<bar>
                     \set laststatus=1<bar>
                   \endif<CR>

" Settings for taglist
nmap tt :TlistToggle<CR>
let Tlist_WinWidth=48
if has('mac')
    " This version of ctags is installed from MacPort
    let Tlist_Ctags_Cmd='/opt/local/bin/ctags' 
endif

"
" Maximize the window when a file is opened in Windows Platform
"
if has("win32")
    source $VIMRUNTIME/mswin.vim
    behave mswin
    au GUIENTER * simalt ~x
endif

"""
""" Set fonts
"""
if has("mac")
    set guifont=consolas:h18
    set guifontwide=Yahei\ Consolas\ Hybrid:h18
else
    set guifont=consolas:h15
    set guifontwide=Yahei\ Consolas\ Hybrid:h15
endif

" The following setting seems only works on mac and windows
if has("win32") || has ("mac")
    set encoding=utf-8
    set fileencodings=utf-8,chinese,latin-1
    if has("win32")
        set fileencoding=chinese
    else
        set fileencoding=utf-8
    endif

    language messages zh_CN.utf-8
endif

"""
""" Some options from vim cast
"""
" Bind the Ctrl-D in insert mode to delete the backword character
imap <C-F> <ESC>la
imap <C-B> <ESC>i
imap <C-D> <ESC>lxi
imap <C-A> <ESC><S-I>
imap <C-E> <ESC><S-A>

" Source the vimrc file automatically after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Automatically open $MYVIMRC for editing
let mapleader = ","
nmap <leader>v :tabedit $MYVIMRC<CR>

" Evaluate the script copied in the register ""
nmap <leader>" :@"<CR>

" Buffer operations
nmap <F4> :bn<CR>
nmap <F3> :bp<CR>

"""
""" For c++ code completion
"""
set nocp
filetype plugin on

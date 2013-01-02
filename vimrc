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

" Store the swap file in ~/tmp
set swapfile
set dir=~/tmp

" Show line number
set nu

set hidden          " Enable change buffer editing conviently.

" Disable macvim schema
let macvim_skip_colorscheme=1
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

"set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set laststatus=2 

"""
""" Settings for taglist
"""
if has('mac')
    " This version of ctags is installed from MacPort
    let Tlist_Ctags_Cmd='/opt/local/bin/ctags' 
endif

let Tlist_WinWidth=42             
let Tlist_Show_One_File=1         "Only show the tags for the current window
let Tlist_Exit_OnlyWindow=1       "Exit vim if taglist is the last window
let Tlist_Use_Right_Window=1      "Show the taglist window on the right.
let Tlist_Show_Menu=1             "Show taglist menu
"let Tlist_Auto_Open=1

nmap tt :TlistToggle<CR>

"""
""" Setting for win manager
"""
let g:winManagerWindowLayout = "TagList|FileExplorer,BufExplorer"
let g:winManagerWidth = 42
nmap <silent> <F8> :WMToggle<cr>
map <c-w><c-f> :FirstExplorerWindow<cr>
map <c-w><c-b> :BottomExplorerWindow<cr>
map <c-w><c-t> :WMToggle<cr> 


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
    set guifont=consolas:h16
    set guifontwide=Yahei\ Consolas\ Hybrid:h16
else
    set guifont=consolas:h15
    set guifontwide=Yahei\ Consolas\ Hybrid:h15
endif

" The following setting seems only works on mac and windows
"if has("win32") || has ("mac")
"    set encoding=utf-8
"    set fileencodings=utf-8,chinese,latin-1
"    if has("win32")
"        set fileencoding=chinese
"    else
"        set fileencoding=utf-8
"    endif

"    language messages zh_CN.utf-8
"endif
set encoding=gbk
set fileencoding=gbk
set fileencodings=gbk,gb2312,utf-8

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
"nmap <F4> :bn<CR>
nmap <F3> :bp<CR>

"Enter buffer explorer
nmap <silent> <F4> :BufExplorer<CR>

"""
""" For c++ code completion
"""
set nocp
filetype plugin on

"""
""" Settings for the lookupfile
"""
let g:LookupFile_MinPatLength = 2               "最少输入2个字符才开始查找
let g:LookupFile_PreserveLastPattern = 0        "不保存上次查找的字符串
let g:LookupFile_PreservePatternHistory = 1     "保存查找历史
let g:LookupFile_AlwaysAcceptFirst = 1          "回车打开第一个匹配项目
let g:LookupFile_AllowNewFiles = 0              "不允许创建不存在的文件
if filereadable("./filenametags")                "设置tag文件的名字
let g:LookupFile_TagExpr = '"./filenametags"'
endif
"映射LookupFile为,lk
nmap <silent> <leader>lk :LUTags<cr>
"映射LUBufs为,ll
nmap <silent> <leader>ll :LUBufs<cr>
"映射LUWalk为,lw
nmap <silent> <leader>lw :LUWalk<cr>

" lookup file with ignore case
function! LookupFile_IgnoreCaseFunc(pattern)    
    let _tags = &tags    
    try        
        let &tags = eval(g:LookupFile_TagExpr)        
        let newpattern = '\c' . a:pattern        
        let tags = taglist(newpattern)    
    catch        
        echohl ErrorMsg | echo "Exception: " . v:exception | echohl NONE        
        return ""    
    finally        
        let &tags = _tags    
    endtry

    " Show the matches for what is typed so far.
    let files = map(tags, 'v:val["filename"]')
    return files
endfunction

let g:LookupFile_LookupFunc = 'LookupFile_IgnoreCaseFunc'


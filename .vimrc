"
" misof's .vimrc
" version 2.3 2019-03-05
"

" ======================================================================================================
" For starters, some settings that should be default, but one never knows: {{{
set nocompatible " we want new vim features whenever they are available
set bs=2         " backspace should work as we expect it to
set autoindent
set history=50   " remember last 50 commands
set ruler        " show cursor position in the bottom line
syntax on        " turn on syntax highlighting if not available by default
" }}}
" ======================================================================================================
" Small tweaks: my preferred indentation, colors, autowrite, status line, etc.:  {{{

" currently I prefer indent step 4 and spaces -- tabs are evil and should be avoided
set shiftwidth=4
set expandtab
set softtabstop=4

" when shifting a non-aligned set of lines, align them to the next tabstop
set shiftround

" by default, if I'm editing text, I want it to wrap
" set textwidth=100

" my terminal is dark, use an appropriate colorscheme
set background=dark
" use the following to force black background if necessary:
" highlight Normal guibg=black guifg=white ctermbg=black ctermfg=white 
" use the following to pick one of the fancier color schemes:
" colorscheme pablo

" automatically re-read files changed outside vim
set autoread

" automatically save before each make/execute command
set autowrite

" if I press <tab> in command line, show me all options if there is more than one
set wildmenu

" y and d put stuff into system clipboard (so that other apps can see it)
set clipboard=unnamed,unnamedplus

" <F12> toggles paste mode
set pastetoggle=<F12>

" while typing a command, show it in the bottom right corner
set showcmd

" adjust timeout for mapped commands: 300 milliseconds should be enough for everyone
set timeout
set timeoutlen=300

" an alias to convert a file to html, using vim syntax highlighting
command ConvertToHTML so $VIMRUNTIME/syntax/2html.vim

" text search settings
set incsearch  " show the first match already while I type
set ignorecase
set smartcase  " only be case-sensitive if I use uppercase in my query
set nohlsearch " I hate when half of the text lights up

" enough with the @@@s, show all you can if the last displayed line is too long
set display+=lastline
" show chars that cannot be displayed as <13> instead of ^M
set display+=uhex

" status line: we want it at all times -- white on blue, with ASCII code of the current letter
set statusline=%<%f%h%m%r%=char=%b=0x%B\ \ %l,%c%V\ %P
set laststatus=2
set highlight+=s:MyStatusLineHighlight
highlight MyStatusLineHighlight ctermbg=darkblue ctermfg=white

" tab line: blue as well to fit the theme
" (this is what appears instead of the status line when you use <tab> in command mode)
highlight TabLine ctermbg=darkblue ctermfg=gray
highlight TabLineSel ctermbg=darkblue ctermfg=yellow
highlight TabLineFill ctermbg=darkblue ctermfg=darkblue

" some tweaks taken from vimbits.com:
" reselect visual block after indent/outdent 
vnoremap < <gv
vnoremap > >gv
" make Y behave like other capitals 
map Y y$
" force saving files that require root permission 
cmap w!! %!sudo tee > /dev/null %

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Tell the folds to fold on file open.
set fdm=marker

" }}}
" ======================================================================================================
" <Tab> completion using tokens from the current file: {{{
function! My_Tab_Completion()
    if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
        return "\<C-P>"
    else
        return "\<Tab>"
endfunction
inoremap <Tab> <C-R>=My_Tab_Completion()<CR>
" }}}
" ======================================================================================================
" Specific settings for specific filetypes:  {{{
" note: These are my local settings. You probably do NOT want to copy them verbatim.
" Usual policy:
"   The ":mak[e]" command should look for a Makefile.
"   If it exists, call "make" with provided arguments (so that we can do stuff like ":make clean" from vim).
"   If it doesn't, call a custom compile command for that specific file type.

" Asymptote
function! ASYSET()
  runtime asy.vim " google 'asy.vim', download it and place it into ~/.vim/ for syntax highlighting to work
  set textwidth=0
  set nowrap
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ asy\ -noV\ -fpdf\ '%';fi
  set errorformat=%f:\ %l.%c:\ %m
endfunction

" Asymptote does not get recognized by default, fix it
augroup filetypedetect
autocmd BufNewFile,BufRead *.asy setfiletype asy
augroup END
filetype plugin on

" C
function! CSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ gcc\ -O2\ -g\ -Wall\ -Wextra\ -o'%:r'\ '%'\ -lm;fi
  set cindent
  set textwidth=0
  set nowrap
endfunction

" C++
function! CPPSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ g++\ -std=gnu++17\ -O2\ -g\ -Wall\ -Wextra\ -o'%:r'\ '%';fi
  set cindent
  set textwidth=0
  set nowrap
endfunction

" HTML/PHP
function! HTMLSET()
  set textwidth=0
  set nowrap
endfunction

" Java
function! JAVASET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ javac\ -g\ '%';fi
  set cindent
  set textwidth=0
  set nowrap
endfunction

" LaTeX
function! TEXSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ pdfcslatex\ -file-line-error-style\ '%';fi
  set textwidth=0
  set nowrap
endfunction

" Makefile
function! MAKEFILESET()
  set textwidth=0
  set nowrap
  " in a Makefile we need to use <Tab> to actually produce tabs
  set noexpandtab
  set softtabstop=8
  iunmap <Tab>
endfunction

" Pascal
function! PPSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ fpc\ -g\ -O2\ -o'%:r'\ '%';fi
  set textwidth=0
  set nowrap
  " note: we do NOT want cindent here
endfunction

" Python
function! PYSET()
  set textwidth=0
  set nowrap
endfunction

" vim scripts
function! VIMSET()
  set textwidth=0
  set nowrap
  set comments+=b:\"
endfunction

" XeLaTeX
function! XETEXSET()
  set makeprg=if\ \[\ -f\ \"Makefile\"\ \];then\ make\ $*;else\ xelatex\ -file-line-error-style\ '%';fi
  set textwidth=0
  set nowrap
endfunction

" Autocommands for all languages:
autocmd FileType asy    call ASYSET()
autocmd FileType c      call CSET()
autocmd FileType cc     call CPPSET()
autocmd FileType cpp    call CPPSET()
autocmd FileType html   call HTMLSET()
autocmd FileType java   call JAVASET()
autocmd FileType make   call MAKEFILESET()
autocmd FileType pascal call PPSET()
autocmd FileType php    call HTMLSET()
autocmd FileType python call PYSET()
autocmd FileType tex    call TEXSET()
autocmd FileType vim    call VIMSET()

" Note: In simpler cases you can have autocmd one-liners as follows:
" autocmd FileType c set makeprg=gcc\ -O2\ -g\ -Wall\ -Wextra\ '%'\ -lm

" Only now, handle xetex. The order is necessary to be able to "setfiletype tex" below.
augroup filetypedetect
autocmd BufNewFile,BufRead *.xtex setfiletype tex
autocmd BufNewFile,BufRead *.xtex call XETEXSET()
augroup END

" }}}
" ======================================================================================================
" Experimental section: vimgrep, cope, spellcheck {{{

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vimgrep searching and cope displaying
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>

" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" Vimgreps in the current file
map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=
" }}}
" ======================================================================================================


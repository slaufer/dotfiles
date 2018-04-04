execute pathogen#infect()

""""""""""""""""
" KEY MAPPINGS "
""""""""""""""""

map <ESC>[OA <c-Up>
map <ESC>[OB <c-Down>
map <ESC>[OC <c-Right>
map <ESC>[OD <c-Left>

nmap s <Plug>(easymotion-s2)

" F7: previous tab
nmap <F7> :tabprevious<cr>
imap <F7> <c-o>:tabprevious<cr>
vmap <F7> <esc>:tabprevious<cr>

" F8: next tab
nmap <F8> :tabnext<cr>
imap <F8> <c-o>:tabnext<cr>
vmap <F8> <esc>:tabnext<cr>

" Ctrl+u: toggle undo tree
nnoremap <leader>mu :UndotreeToggle<cr>
nnoremap <leader>mb :TagbarToggle<cr>

" Alt+Shift+j/k/l/; -- Scroll viewport left/down/up/right
nnoremap <a-s-j> 5zh
nnoremap <a-s-k> <c-e>
nnoremap <a-s-l> <c-y>
nnoremap <a-:> 5zl


""""""""""""
" SETTINGS "
""""""""""""


" basic settings
set nowrap
set number
set hlsearch
set sc
set textwidth=0
set backspace=2
set showtabline=2
set mouse=a
set laststatus=2
set stl=%n%Y%R%W:%<%f%M%=\ %c%V,%-5l\ %5o:%-3b\ (%P)
set list
set listchars=tab:\|\ ,trail:~,extends:>,precedes:<
" let &colorcolumn=join(range(121,999), ',')
syntax on

" plugin settings
let g:EasyMotion_smartcase = 1
let NERDTreeShowHidden = 1
let g:ctrlp_working_path_mode = '0'
let g:ctrlp_custom_ignore = 'node_modules\|.git\|.idea\|nytprof'
let g:indentLine_setColors = 0
let g:indentLine_char = '|'

let g:tabman_toggle = '<leader>mt'
let g:tabman_specials = 1
let g:tabman_number = 0

" platform-specific stuff
if has('gui_running') " gui stuff
	if has('win32')
		set clipboard=unnamed
		set guifont=Consolas:h11:cANSI
	elseif has("unix")
		set clipboard=unnamedplus
		set guifont=Fira\ Mono\ 13
	endif

	color vexing
	set guioptions-=T
	set guioptions-=e
	set guioptions-=m
else " console stuff
	" tmux drag compatibility
	if &term =~ '^screen'
		set ttymouse=xterm2
	endif

	" figure out terminal colors
	if &t_Co >= 256
		color vexing
	elseif &t_Co >= 8
		color torte
	endif

	behave xterm
endif

""""""""""""
" Commands "
""""""""""""

" purge non-visible buffers
func! BPURGE()
	for i in range(1,bufnr('$'))
		if buflisted(i) && !bufloaded(i)
			execute('bd '.i)
		endif
	endfor
endfun
com! Bpurge :call BPURGE()
com! Bpu :call BPURGE()

" displays info on the character under the cursor
func! CHARINFO()
	let char = matchstr(getline('.'), '\%' . col('.') . 'c.')
	echo printf("char '%s' (oct 0%o, dec %s, hex 0x%x) at line %s, column %s", char, char2nr(char), char2nr(char), char2nr(char), line('.'), virtcol('.'))
endfun
com! Ci call CHARINFO()
com! Cinfo call CHARINFO()
com! Charinfo call CHARINFO()

" saves a session
func! SAVESESSION()
	let old_ssop=&ssop
	set ssop=blank,buffers,curdir,folds,help,resize,tabpages,winpos,winsize
	mks! ~/.vimsession
	let &ssop=old_ssop
endfun
com! Ss call SAVESESSION()
com! Sse call SAVESESSION()
com! Savesession call SAVESESSION()

" transfers a register to the X11 clipboard
" takes a register as the first argument, otherwise uses the last register used
func! XCLIP(...)
	let reg = (len(a:000) ? a:1 : v:register)
	silent let output = system('xclip -i -selection clipboard', eval('@' . reg))
	if (v:shell_error)
		echo 'ERROR xclip exited with code ' . v:shell_error . ': ' . output
	else
		echo 'Copied contents of register ' . reg . ' to X11 clipboard '
	endif
endfun
com! -nargs=* Xcb call XCLIP(<f-args>)

""""""""""
" Events "
""""""""""

" dear vim: there is absolutely no situation where i want textwidth to be anything other than 0
autocmd FileType * :set textwidth=0
autocmd BufNewFile,BufRead *.coffee :set syntax=coffee

" when multiple files are opened from the command line, show them all in tabs
" FIXME: syntax highlighting is not turned on in any tab(/buffer?) except the first
func! VimEnterShowBuffers()
	if (argc() > 1)
		tab sba
	endif
endfun
autocmd VimEnter * :call VimEnterShowBuffers()

"""""""""""""""""
" Indent Config "
"""""""""""""""""

" this config has to come last, because otherwise it *will* get clobbered.
" set tabstop=4
" set shiftwidth=4
" set nocindent
" set nosmartindent
" set noautoindent
" set indentexpr=
" filetype indent off
" filetype plugin indent off

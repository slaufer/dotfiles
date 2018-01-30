execute pathogen#infect()

""""""""""""""""
" KEY MAPPINGS "
""""""""""""""""

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
map <c-u> :UndotreeToggle<cr>

" Ctrl+i: toggle tagbar
map <c-i> :TagbarToggle<cr>

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
set tabstop=4
set shiftwidth=4
set showtabline=2
set mouse=a
set laststatus=2
set stl=%n%Y%R%W:%<%f%M%=\ %c%V,%-5l\ %5o:%-3b\ (%P)
set list
set listchars=tab:>\ ,trail:~,extends:>,precedes:<
syntax on

" plugin settings
let g:EasyMotion_smartcase = 1
let NERDTreeShowHidden = 1
let g:ctrlp_working_path_mode = '0'

" platform-specific stuff
if has('gui_running') " gui stuff
	if has('win32')
		set clipboard=unnamed
		set guifont=Consolas:h11:cANSI
	elseif has("unix")
		set clipboard=unnamedplus
		set guifont=Fira\ Mono\ 13
	endif

	color desertEx-mod
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
		color desertEx-mod
		let &colorcolumn=join(range(121,999),',')
	else
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

autocmd FileType * :set textwidth=0 " STOP CHANGING MY FUCKING TEXTWIDTH VIM SYNTAX PLUGIN

" when multiple files are opened from the command line, show them all in tabs
func! VimEnterShowBuffers()
	if (argc() > 1)
		tab sba
	endif
endfun
autocmd VimEnter * :call VimEnterShowBuffers()

"""""""""""""""""
" Display Style "
"""""""""""""""""

" status line
"func! STL()
"	" base status line
"	let stl = '[%n] %<%f%m%= %c%V,%l(%P) %y%r%w'
"
"	" scrollbar -- this ended up being less useful than annoying
"	"let barsz = 20
"	"let pad = float2nr(round((line('.') - 1.0) / (line('$') - 1.0) * (barsz - 1)))
"	"let scrollbar = '['.repeat('-', pad).'#'.repeat('-', (barsz - 1) - pad).']'
"	"let stl .= scrollbar
"
"	return stl
"endfun
"set stl=%!STL()

" tab line
" this will take a non-trivial amount of code, putting it off for later
"func! TAL()
"	" base tabline
"	let tal = '%#TabLineFill#'
"
"	for i in range(tabpagenr('$'))
"		let tabno = i + 1
"		let winnr = tabpagewinnr(tabno)
"		let buflist = tabpagebuflist(tabno)
"		let bufcount = len(buflist)
"		let actbuf = buflist[winnr - 1]
"		let actname = bufname(actbuf)
"		let tabtitle = len(actname) ? actname : '?'
"		let modified = getbufvar(actbuf, "&mod")
"		let modflag = modified ? '+ ' : ''
"		
"		if tabno == tabpagenr()
"	      let tal .= '%#TabLineSel#'
"	    else
"	      let tal .= '%#TabLine#'
"		endif
"
"	    let tal .= '%' . tabno . 'T ' . modflag . tabtitle . ' %T'
"	endfor
"
"	let tal .= '%#TabLineFill#'
"	return tal
"endfun
"set tal=%!TAL() 



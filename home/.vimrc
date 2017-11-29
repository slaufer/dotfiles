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

" F6: follow ctag in new tab
" nmap <F6> <c-w>]<c-w>T

" Ctrl+u: toggle undo tree
map <c-u> :UndotreeToggle<cr>

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
set stl=%n%Y%R%W:%<%f%M%=\ %c%V,%l\ %O:%B\ (%P)
syntax on

" plugin settings
let g:EasyMotion_smartcase = 1
let NERDTreeShowHidden = 1

" misc stuff
autocmd FileType vim :set textwidth=0 " STOP CHANGING MY FUCKING TEXTWIDTH VIM SYNTAX PLUGIN

" platform-specific stuff
if has('gui_running') " gui stuff
	if has('win32')
		set clipboard=unnamed
		set guifont=Consolas:h11:cANSI
	elseif has("unix")
		set clipboard=unnamedplus
		set guifont=Inconsolata\ Medium\ 13
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
	for i in range(bufnr('$'))
		if buflisted(i) && !bufloaded(i)
			execute('bd '.i)
		endif
	endfor
endfun
com! Bpurge :call BPURGE()

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



execute pathogen#infect()

""""""""""""""""
" KEY MAPPINGS "
""""""""""""""""

nmap s <Plug>(easymotion-s2)

" F9: previous tab
nmap <F9> :tabprevious<cr>
imap <F9> <c-o>:tabprevious<cr>
vmap <F9> <esc>:tabprevious<cr>

" F10: next tab
nmap <F10> :tabnext<cr>
imap <F10> <c-o>:tabnext<cr>
vmap <F10> <esc>:tabnext<cr>

" Ctrl+u: toggle undo tree
nnoremap <leader>mu :UndotreeToggle<cr>
nnoremap <leader>ms :SignatureToggle<cr>

" Alt+Shift+j/k/l/; -- Scroll viewport left/down/up/right (normal mode)
nnoremap <a-s-j> 5zh
nnoremap <a-s-k> 3<c-e>
nnoremap <a-s-l> 3<c-y>
nnoremap <a-:> 5zl

" Ctrl+J -- Insert newline (normal mode)
nnoremap <C-j> i<CR><ESC>

""""""""""""
" SETTINGS "
""""""""""""


" basic settings
set nowrap
set number
set hlsearch
set showcmd
set textwidth=0
set backspace=2
set showtabline=2
set mouse=a
set laststatus=2
set statusline=%n%Y%R%W:%<%f%M%=\ %c%V,%-5l\ %5o:%-3b\ (%P)
set list
set listchars=tab:\|\ ,trail:~,extends:>,precedes:<
set scrolloff=5
set colorcolumn=121
syntax on

"""""""""""""""""""
" PLUGIN SETTINGS "
"""""""""""""""""""

" easymotion
let g:EasyMotion_smartcase = 1

" nerd tree
let NERDTreeShowHidden = 1

" ctrl-p
let g:ctrlp_working_path_mode = '0'
let g:ctrlp_custom_ignore = 'node_modules\|.git\|.idea\|nytprof'

" indentline
let g:indentLine_setColors = 0
let g:indentLine_char = '|'

" tabman
let g:tabman_toggle = '<leader>mt'
let g:tabman_specials = 1
let g:tabman_number = 0

" ag support for ack.vim
if executable('ag')
	let g:ackprg = 'ag --vimgrep --smart-case'
endif
cnoreabbrev ag Ack
cnoreabbrev aG Ack
cnoreabbrev Ag Ack
cnoreabbrev AG Ack

" javacomplete2
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" vebugger
nnoremap <Leader>db       :VBGtoggleBreakpointThisLine<CR>
nnoremap <Leader>du       :VBGstepOut<CR>
nnoremap <Leader>di       :VBGstepIn<CR>
nnoremap <Leader>do       :VBGstepOver<CR>
nnoremap <Leader>dc       :VBGcontinue<CR>
nnoremap <Leader>dt       :VBGtoggleTerminalBuffer<CR>
nnoremap <Leader>de       :VBGrawWrite 
nnoremap <Leader>dx       :VBGkill<CR>
nnoremap <Leader>dja      :call vebugger#jdb#attach('2181', { 'srcpath': [ 'adserver/src', 'adcore/src', 'admaster/src', 'common/src', 'src' ] })<CR>

"""""""""""""""""""""
" PLATFORM SETTINGS "
"""""""""""""""""""""

" torte #1 vim built-in color scheme for life
color torte

if has('gui_running') " gui stuff
	if has('win32')
		set clipboard=unnamed
		set guifont=Consolas:h11:cANSI
	elseif has("unix")
		set clipboard=unnamedplus
		set guifont=Fira\ Mono\ 13
	endif

	" get rid of all those useless toolbars
	set guioptions-=T
	set guioptions-=e
	set guioptions-=m
else " console stuff
	" tmux drag compatibility
	if &term =~ '^screen'
		set ttymouse=xterm2
	endif

	" if we can have lots of colors, switch to VEXING
	if &t_Co >= 256
		color vexing
	endif

	behave xterm
endif

""""""""""""
" Commands "
""""""""""""

" purge non-visible buffers
func! BPURGE()
	let l:count = 0
	for i in range(1,bufnr('$'))
		if buflisted(i) && !bufloaded(i)
			let l:count = l:count + 1
			execute('bd ' . i)
		endif
	endfor

	echo printf("%d buffers closed", l:count)
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

func! SETINDENT(...)
	set nosmartindent
	let &ts=a:2
	let &sw=a:2

	if (a:1[0] == "t")
		set noexpandtab
	elseif (a:1[0] == "s")
		set expandtab
	endif
endfun
com! -nargs=+ SetIndent call SETINDENT(<f-args>)
com! -nargs=+ In call SETINDENT(<f-args>)

""""""""""
" Events "
""""""""""

autocmd FileType * :set textwidth=0
autocmd BufNewFile,BufRead *.coffee :set syntax=coffee
" vim's json syntax defs suck so much
autocmd BufNewFile,BufRead *.json :set syntax=yaml

In s 2

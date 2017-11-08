execute pathogen#infect()

nmap s <Plug>(easymotion-s2)
let g:EasyMotion_smartcase = 1
let NERDTreeShowHidden = 1

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

" assorted settings
set nowrap
set nu
set hls
set sc
set backspace=2
set tabstop=4
set shiftwidth=4
set showtabline=2
set mouse=a
set laststatus=2
syntax on

" misc stuff
autocmd BufNewFile,BufRead *.json set ft=javascript

" platform-specific stuff
if has('gui_running')
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
" console-only stuff
else
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


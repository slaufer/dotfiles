" Vim color file
" Maintainer:	Scott Laufer <slaufer@gmail.com>
" Created:	2018-02-06
" Last Change:	2018-03-21
" neons and pastels on black
" optimized for radness

set background=dark
hi clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name="vexing"

highlight Normal         ctermfg=254 ctermbg=232
highlight Cursor         ctermfg=16  ctermbg=15

" highlight groups
highlight Conceal        ctermfg=235 ctermbg=232
highlight DiffAdd        ctermfg=16  ctermbg=83
highlight DiffDelete     ctermfg=16  ctermbg=160
highlight DiffChange     ctermfg=16  ctermbg=87
highlight DiffText       ctermfg=16  ctermbg=197
highlight ErrorMsg       ctermfg=231 ctermbg=196
highlight FoldColumn     ctermfg=16  ctermbg=177
highlight Folded         ctermfg=16  ctermbg=121
highlight IncSearch      ctermfg=16  ctermbg=123
highlight MatchParen     ctermfg=129 ctermbg=232
highlight ModeMsg        ctermfg=51  ctermbg=16
highlight MoreMsg        ctermfg=15  ctermbg=16
highlight NonText        ctermfg=23  ctermbg=16
highlight Question       ctermfg=15  ctermbg=16
highlight Search         ctermfg=16  ctermbg=123
highlight SpecialKey     ctermfg=235 ctermbg=232
highlight VertSplit      ctermfg=87  ctermbg=24  cterm=NONE
highlight Visual         ctermfg=159 ctermbg=38
highlight WarningMsg     ctermfg=231 ctermbg=196
highlight ColorColumn                ctermbg=60

" frame parts
highlight LineNr         ctermfg=23  ctermbg=16

highlight StatusLine     ctermfg=16  ctermbg=87  cterm=NONE
highlight StatusLineNC   ctermfg=234 ctermbg=24   cterm=NONE

highlight TabLineFill    ctermfg=15  ctermbg=16  cterm=NONE
highlight TabLine        ctermfg=239 ctermbg=16  cterm=NONE
highlight TabLineSel     ctermfg=16  ctermbg=6   cterm=NONE
highlight Title          ctermfg=250 ctermbg=16

" syntax highlighting groups
highlight Comment        ctermfg=60
highlight Constant       ctermfg=121
highlight Identifier     ctermfg=51
highlight Statement      ctermfg=215
highlight PreProc        ctermfg=74
highlight Type           ctermfg=35
highlight Special        ctermfg=220
highlight Todo           ctermfg=232 ctermbg=208


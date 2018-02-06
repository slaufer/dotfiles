" Vim color file
" Maintainer:	Scott Laufer <slaufer@gmail.com>
" Last Change:	2018-02-06
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
highlight DiffAdd        ctermfg=16  ctermbg=83
highlight DiffDelete     ctermfg=16  ctermbg=160
highlight DiffChange     ctermfg=16  ctermbg=87
highlight DiffText       ctermfg=16  ctermbg=197
highlight ErrorMsg       ctermfg=231 ctermbg=196
highlight FoldColumn     ctermfg=16  ctermbg=177
highlight Folded         ctermfg=16  ctermbg=121
highlight IncSearch      ctermfg=16  ctermbg=123
highlight LineNr         ctermfg=239 ctermbg=233
highlight MatchParen     ctermfg=16  ctermbg=46
highlight ModeMsg        ctermfg=25  ctermbg=16
highlight MoreMsg        ctermfg=15  ctermbg=16
highlight NonText        ctermfg=51  ctermbg=232
highlight Question       ctermfg=15  ctermbg=16
highlight Search         ctermfg=16  ctermbg=123
highlight SpecialKey     ctermfg=235 ctermbg=232
highlight StatusLine     ctermfg=6   ctermbg=234 cterm=NONE
highlight StatusLineNC   ctermfg=239 ctermbg=233 cterm=NONE
highlight Title          ctermfg=167 ctermbg=16
highlight VertSplit      ctermfg=233 ctermbg=233 cterm=NONE
highlight Visual         ctermfg=159 ctermbg=38
highlight WarningMsg     ctermfg=231 ctermbg=196
highlight colorcolumn    ctermbg=236

" syntax highlighting groups
highlight Comment        ctermfg=6
highlight Constant       ctermfg=35
highlight Identifier     ctermfg=38
highlight Statement      ctermfg=176
highlight PreProc        ctermfg=216
highlight Type           ctermfg=111
highlight Special        ctermfg=227
highlight Todo           ctermfg=10


highlight TabLineFill    ctermbg=0   ctermfg=231 cterm=NONE
highlight TabLine        ctermfg=210 ctermbg=236
highlight TabLineSel     ctermfg=16  ctermbg=180

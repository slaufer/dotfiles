" Vim color file
" Maintainer:	Scott Laufer <slaufer@gmail.com>
" vexing, rebuilt for a heavily redshifted display (redshift -O 1000 -b 0.7)
"
" At 1000K the display passes ~100% red, ~18% green, 0% blue, so hue is gone
" and contrast lives almost entirely in the red channel. Groups are therefore
" laid out on brightness tiers (by red value of the 256-color entry), with
" bold/italic/underline separating groups that share a tier:
"
"   T5 255  bold  Statement, Title          plain  String, Constant, Number
"   T4 215  bold  Type, StorageClass        plain  Normal, Identifier, Operator
"   T3 175        PreProc, Special, line UI
"   T2 135 italic Comment                         LineNr
"   T1  95        NonText, SpecialKey, ColorColumn, dark panel backgrounds
"
" Anything with "on" a colored background uses black (16) text.

set background=dark
hi clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name="vexing-reds"

highlight Normal              ctermfg=180 ctermbg=232
highlight Cursor              ctermfg=16  ctermbg=214

" highlight groups
highlight Conceal             ctermfg=52  ctermbg=232
highlight DiffAdd             ctermfg=16  ctermbg=172
highlight DiffDelete          ctermfg=88  ctermbg=52
highlight DiffChange          ctermfg=16  ctermbg=137
highlight DiffText            ctermfg=16  ctermbg=223 cterm=bold
highlight Error               ctermfg=16  ctermbg=196 cterm=bold
highlight ErrorMsg            ctermfg=16  ctermbg=196 cterm=bold
highlight FoldColumn          ctermfg=137 ctermbg=16
highlight Folded              ctermfg=137 ctermbg=52
highlight IncSearch           ctermfg=16  ctermbg=223 cterm=bold
highlight MatchParen          ctermfg=223 ctermbg=88  cterm=bold
highlight ModeMsg             ctermfg=214 ctermbg=16  cterm=bold
highlight MoreMsg             ctermfg=214 ctermbg=16
highlight NonText             ctermfg=52  ctermbg=16
highlight Question            ctermfg=214 ctermbg=16
highlight Search              ctermfg=16  ctermbg=137
highlight SpecialKey          ctermfg=52  ctermbg=232
highlight VertSplit           ctermfg=137 ctermbg=52  cterm=NONE
highlight Visual              ctermfg=16  ctermbg=180
highlight WarningMsg          ctermfg=16  ctermbg=172
highlight ColorColumn                     ctermbg=52

" groups vexing leaves at defaults, which are blue/magenta and vanish at 1000K
highlight Pmenu               ctermfg=180 ctermbg=52
highlight PmenuSel            ctermfg=16  ctermbg=214
highlight PmenuSbar                       ctermbg=52
highlight PmenuThumb                      ctermbg=137
highlight SpellBad            ctermfg=NONE ctermbg=NONE cterm=underline
highlight SpellCap            ctermfg=NONE ctermbg=NONE cterm=underline
highlight SpellRare           ctermfg=NONE ctermbg=NONE cterm=underline
highlight SpellLocal          ctermfg=NONE ctermbg=NONE cterm=underline
highlight CursorLineNr        ctermfg=214 ctermbg=16  cterm=bold
highlight WildMenu            ctermfg=16  ctermbg=214

" frame parts
highlight LineNr              ctermfg=94  ctermbg=16

highlight StatusLine          ctermfg=16  ctermbg=172 cterm=NONE
highlight StatusLineNC        ctermfg=137 ctermbg=52  cterm=NONE

highlight TabLineFill         ctermfg=137 ctermbg=16  cterm=NONE
highlight TabLine             ctermfg=137 ctermbg=16  cterm=NONE
highlight TabLineSel          ctermfg=16  ctermbg=172 cterm=NONE
highlight Title               ctermfg=223 ctermbg=16  cterm=bold

" syntax highlighting groups
highlight Comment             ctermfg=95  ctermbg=NONE cterm=italic
highlight Constant            ctermfg=214
highlight Identifier          ctermfg=173
highlight Statement           ctermfg=209 cterm=bold
highlight PreProc             ctermfg=137
highlight Type                ctermfg=172 cterm=bold
highlight Special             ctermfg=131
highlight Todo                ctermfg=16  ctermbg=214 cterm=bold
highlight Operator            ctermfg=180
highlight Noise               ctermfg=94
highlight StorageClass        ctermfg=172 cterm=bold

highlight Number              ctermfg=215
highlight Float               ctermfg=215
highlight String              ctermfg=214
highlight Character           ctermfg=214
highlight Boolean             ctermfg=215

" vim-signature colors
highlight SignColumn          ctermfg=180 ctermbg=16
highlight SignatureMarkText   ctermfg=214 ctermbg=16
highlight SignatureMarkerText ctermfg=137 ctermbg=16

" vim-javascript colors
highlight jsFunction          ctermfg=209 cterm=bold
highlight jsFuncName          ctermfg=223
highlight jsFuncArgs          ctermfg=137
highlight jsFuncCall          ctermfg=223
highlight jsObjectKey         ctermfg=173

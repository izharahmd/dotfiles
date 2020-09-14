syntax on
set nu
set ruler
" Show trailing whitespace except when inserting at end of line
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhiteSpace /\s\+\%#\@<!$/
set hlsearch

" Language: jdoc (zon documents). Port of pkg/system/host/vim/jdoc.vim.
if exists('b:current_syntax')
  finish
endif

syn match jdocOther contained "^[A-Z_]\+:"
syn match jdocField contained "^\(TITLE\|AUTHOR\|OWNER\|NOTIFY\|FILES\|SHELL_UPDATE\|SHELL_CHECK\|OPTIONS\|SQL_LAYOUT\|SQL_TABLE\|UPDATE_MONGO\):"
syn region jdocHeader start='^TITLE:' skip='^\s' end='^$' contains=jdocField,jdocOther

hi def link jdocField Keyword
hi def link jdocOther Identifier
hi def link jdocHeader Title

let b:current_syntax = 'jdoc'

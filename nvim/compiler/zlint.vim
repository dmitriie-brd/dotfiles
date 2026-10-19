" Compiler: zlint (zon JS linter). Use :compiler zlint, then :make (or :make -c).
" Output format (pkg/util/lint.js): file:line:col: [ERROR|WARN][rule] message
if exists('current_compiler')
  finish
endif
let current_compiler = 'zlint'

CompilerSet makeprg=zlint\ $*\ %:S
CompilerSet errorformat=%f:%l:%c:\ [%tRROR]%m,%f:%l:%c:\ [%tARN]%m,%-G%f:\ OK,%-G%.%#

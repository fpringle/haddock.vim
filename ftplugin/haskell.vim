" Only load once
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" default mappings
if !hasmapto('<Plug>HaddockDeclaration')
  map <buffer> <localleader>hd <Plug>HaddockDeclaration
endif

" Backup line-continuation settings
let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_haddock")
  finish
endif
let g:loaded_haddock = 1

" either "dashes" or "curly"
if !exists("g:HaddockToolkit_style")
    let g:HaddockToolkit_style = "dashes"
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Starting from the current line, move upwards until we find the
" declaration of the current block of code. If we hit a different
" declaration, echo an error and return -1.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:FindDeclarationStart()
    " echom "FindDeclarationStart"
    let l:lineNum = line(".")
    let l:lineBuffer = getline(l:lineNum)

    " go up until we find a line with no indentation

    while l:lineNum > 0 && s:IsIndented(l:lineBuffer)
        let l:lineNum = l:lineNum - 1
        let l:lineBuffer = getline(l:lineNum)
    endwhile

    if l:lineNum == 0
        " hit the top, but no declaration
        if s:IsIndented(l:lineBuffer)
            echoerr "invalid syntax: reached top of page but can't find declaration"
            return -1
        endif

        " hit the top, found declaration
        return 0
    endif

    " echom "found non-indented line at line " . lineNum

    " now we have the start of our current indentation block. We need to find
    " the start of the declaration.
    " there are 2 cases: the start of the current block is necessarily the
    " start of the declaration (eg "data MyType = ...")
    " otherwise, the declaration is a function declaration.

    let l:firstWord = split(l:lineBuffer)[0]
    if (l:firstWord ==# "data"
                \ || l:firstWord ==# "pattern"
                \ || l:firstWord ==# "newtype"
                \ || l:firstWord ==# "type"
                \ || l:firstWord ==# "class"
                \ || l:firstWord ==# "instance")
        " echom "type 1"
        return l:lineNum
    elseif (l:firstWord ==# "import" || l:firstWord ==# "module")
        echoerr "no declaration available to document!"
        return -1
    endif

    " echom "type 2"

    " move upwards, taking note of all non-indented lines. Once we hit 0 or
    " find a non-indented line with a different first word to l:firstWord,
    " then we know the last occurrence of l:firstWord was the start of the
    " declaration.
    
    let l:lastOccurrence = l:lineNum
    while l:lineNum > 0
        if !s:IsIndented(l:lineBuffer)
            " echom l:lineBuffer
            if l:firstWord ==# split(l:lineBuffer)[0]
                let l:lastOccurrence = l:lineNum
            else
                return l:lastOccurrence
            endif
        endif

        let l:lineNum = l:lineNum - 1
        let l:lineBuffer = getline(l:lineNum)
    endwhile

    return 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Check if a line is indented, i.e. starts with a space
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:IsIndented(line)
    return match(a:line, '^\S') ==# -1
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Insert the docstring start in "dashes" style and enter insert mode.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:InsertDashesDocstring()
    " echom "InsertDashesDocstring"
    let l:lineNum = line(".")
    call append(l:lineNum - 1, "-- | ")
    call setpos(".", [0, l:lineNum, 0, 0])
    startinsert!
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Insert the docstring start in "curly" style and enter insert mode.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:InsertCurlyDocstring()
    " echom "InsertCurlyDocstring"
    let l:lineNum = line(".")
    call append(l:lineNum - 1, ["{-|", "  ", "-}"])
    call setpos(".", [0, l:lineNum + 1, 0, 0])
    startinsert!
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Insert the docstring start and enter insert mode.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:InsertTopLevelDocstring()
    " echom "InsertTopLevelDocstring"

    if g:HaddockToolkit_style ==# "dashes"
        call s:InsertDashesDocstring()
    elseif g:HaddockToolkit_style ==# "curly"
        call s:InsertCurlyDocstring()
    else
        echoerr "invalid value for g:HaddockToolkit_style: \""
                    \ . g:HaddockToolkit_style
                    \ . "\". Please set either \"dashes\" (default) or \"curly\"."
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Start a Haddock comment for a top-level declaration and leave the
" user in insert mode.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>Declaration()
    " move upwards to find start of declaration
    let l:declaration_start = s:FindDeclarationStart()
    if l:declaration_start ==# -1
        return
    endif

    " echom "declaration starts at line " . l:declaration_start
    call setpos(".", [0, l:declaration_start, 0, 0])

    " insert docstring and enter insert mode
    call s:InsertTopLevelDocstring()
endfunction

" Commands
if !exists(":Declaration")
    command -nargs=0 HaddockDeclaration :call <SID>Declaration()
endif

" Mappings
nnoremap <SID>Declaration :call <SID>Declaration()<CR>
nnoremap <silent> <script> <Plug>HaddockDeclaration <SID>Declaration

" Restore line-continuation settings
let &cpo = s:save_cpo
unlet s:save_cpo

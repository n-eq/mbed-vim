" mbed.vim
" author: marrakchino (nabilelqatib@gmail.com)
" version: 0.0
"
" This file contains routines that may be used to execute mbed CLI commands
" from within VIM. It depends on mbed OS. You must have mbed CLI correctly
" installed (see https://github.com/ARMmbed/mbed-cli#installation).
"
" In command mode:
" <leader>c:  Compile the current application
" <leader>cv: Compile the current application in verbose mode
" <leader>cV: Compile the current application in very verbose mode
" <leader>cc: Clean the build directory and compile the current application
" <leader>cf: Compile and flash the built firmware onto a connected target
" <leader>n:  Create a new mbed program or library
" <leader>s:  Synchronize all library and dependency references
" <F9>:       Close the error buffer (when open)
" <F11>:      Set the current application's target and toolchain
"

" Global variables
" XXX: variables should be local to the current window or global?
if !exists( "g:mbed_target" )
  let g:mbed_target = ""
endif

if !exists( "g:mbed_toolchain" )
  let g:mbed_toolchain = ""
endif

function! MbedGetTargetandToolchain( force )
  if g:mbed_target == "" || a:force != 0
    " if has("win32") " TODO
    let l:target = system('mbed target')
    " no target set
    if l:target == "" 
      " XXX: no need for a second argument??
      let g:mbed_target = input( "Please enter your mbed target name: ", l:target) 
    else
      let g:mbed_target = l:target
    endif
  endif

  if g:mbed_toolchain == "" || a:force != 0
    " if has("win32") " TODO
    let l:toolchain = system('mbed toolchain')
    if l:toolchain == "" " no toolchain set
      " XXX: no need for the second argument ??
      let g:mbed_toolchain = input( "Please choose a toolchain (ARM, GCC_ARM, IAR): ", l:toolchain) 
    else
      let g:mbed_toolchain = l:toolchain
    endif
  endif
endfunction

function! MbedNew()
  execute "!mbed new ."
endfunction

function! MbedSync()
  execute "!mbed sync"
endfunction

function! MbedDeploy()
  execute "!mbed deploy"
endfunction

function! MbedCompile()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  let @o = system("mbed compile")
  if !empty(@o)
    " pattern not found
    if match(getreg("o"), "Image") == -1
      new 
      let g:error_buffer_number = bufnr('%')
      set buftype=nofile
      silent put=@o
      execute "g/^$/d"
      normal 1G
    else
      echo "Compilation ended successfully."
    endif
  endif
  " horizontal split -> vertical split, TODO: do it more elegantly....
  normal <C-w>t<C-w>H 
  " TODO: find "Image: " pattern in output and don't split (compilation 100%
  " OK) if no compilation error
endfunction

" Close compilation error buffer opened due to mbed compile call
function! CloseErrorBuffer()
  if (exists("g:error_buffer_number"))
    execute "bdelete " . g:error_buffer_number
  endif
endfunction

function! MbedCompileClean()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  execute '!mbed compile -c'
endfunction

function! MbedCompileFlash()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  execute '!mbed compile -f'
endfunction

function! MbedCompileVerbose()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  execute '!mbed compile -v'
endfunction

function! MbedCompileVVerbose()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  execute '!mbed compile -vv'
endfunction

function! MbedAddLibary(libraryName)
  " XXX: maybe define the command as a variable and then execute it?
  " let @t = "mbed add " . a:libraryName
  " normal @t
  execute '!mbed add ' . a:libraryName
endfunction

function! MbedAddLibary()
  call PromptForLibraryToAdd()
endfunction

function! PromptForLibraryToAdd()
  let l:library_name = input("Please enter the name/URL of the library to add: ")
  call MbedAddLibary(l:library_name)
endfunction

function! MbedRemoveLibary(libraryName)
  execute '!mbed remove ' . a:libraryName
endfunction

function! MbedRemoveLibary()
  call PromptForLibraryToRemove()
endfunction

function! PromptForLibraryToRemove()
  let l:library_name = input("Please enter the name/URL of the library to remove: ")
  call MbedRemoveLibary(l:library_name)
endfunction

function! MbedList()
  let @o = system("mbed ls")
  " XXX: if @o == "" ??
  if !empty(@o)
    " no output 
    new
    silent put=@o
    " Delete empty lines
    execute "g/^$/d"
    normal 1G
    let l:newheight = line("$")
    let l:newheight += 1
    " winheight: hight of the current window
    if l:newheight < winheight(0)
      execute "resize " . l:newheight
    endif
  else
    echo "@o is empty.."
  endif
endfunction

" TODO: remove?
function! ConfigureOutputWindow()
  set buftype=nofile
  normal $G
  while getline(".") == "."
    normal dd
  endwhile
  normal 1G
  " total number of lines
  let l:newheight = line("$")
  " if # of lines < height of the buffer
  if l:newheight < winheight(0)
    " increase buffer height
    execute "resize " . l:newheight
  endif
endfunction


" command-mode mappings
map <F11> :call MbedGetTargetandToolchain(1)<CR>
map <leader>c  :call MbedCompile()<CR>
map <leader>cc :call MbedCompileClean()<CR>
map <leader>cf :call MbedCompileFlash()<CR>
map <leader>cv :call MbedCompileVerbose()<CR>
map <leader>cV :call MbedCompileVVerbose()<CR>
map <leader>n  :call MbedNew()<CR>
map <leader>n  :call MbedSync()<CR>
map <F10> :call CloseErrorBuffer<CR>

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
" <leader>C:  Clean the build directory and compile the current application
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

" TODO: test
function! MbedGetTargetandToolchain( force )
  let l:mbed_tools_exist = system("which mbed")
  if l:mbed_tools_exist == ""
    echoe "Couldn't find mbed CLI tools."
  else
    if g:mbed_target == "" || a:force != 0
      " if has("win32") " TODO
      let l:target = system('mbed target')
      " no target set
      if l:target == "" 
        let g:mbed_target = input("Please enter your mbed target name: ") 
      elseif match(l:target, "ERROR") != -1
        return
      else
        let g:mbed_target = l:target
      endif
    endif

    if g:mbed_toolchain == "" || a:force != 0
      " if has("win32") " TODO
      let l:toolchain = system('mbed toolchain')
      if l:toolchain == "" " no toolchain set
        let g:mbed_toolchain = input("Please choose a toolchain (ARM, GCC_ARM, IAR): ") 
      elseif match(l:toolchain, "ERROR") != -1
        return
      else
        let g:mbed_toolchain = l:toolchain
      endif
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

" TODO: refactor the buffer-related code below by creating a special function
function! MbedCompile()
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  let @o = system("mbed compile")
  " If the error buffer is visible (e.g. vsplit), we should simply switch to
  " it and erase its content, then the content of the register can be freely
  " pasted. In the case where the buffer doesn't exist (g:error_buffer_number = -1),
  " it should be vnew'ed and the previously described process should continue.
  if !empty(@o)
    " <Image> pattern not found
    if match(getreg("o"), "Image") == -1
      if exists("g:error_buffer_number")
        if bufexists(g:error_buffer_number)
          " buffer exists and is visible
          if bufwinnr(g:error_buffer_number) > 0
            call CleanErrorBuffer()
          else
            execute "vert belowright sb " . g:error_buffer_number
          endif
        else
          vnew
          let g:error_buffer_number = bufnr('%')
          set buftype=nofile
        endif
      else
        vnew
        let g:error_buffer_number = bufnr('%')
        set buftype=nofile
      endif
      execute "set switchbuf+=useopen"
      execute "sbuffer " . g:error_buffer_number
      " paste register content to buffer
      silent put=@o
      " delete empty lines
      execute "g/^$/d"
      " go to last line
      normal G
    else
      echo "Compilation ended successfully."
    endif
  endif
endfunction

" Clear the error buffer's content
function! CleanErrorBuffer()
  " see  https://stackoverflow.com/questions/28392784/vim-drop-for-buffer-jump-to-window-if-buffer-is-already-open-with-tab-autoco
  execute "set switchbuf+=useopen"
  execute "sbuffer " . g:error_buffer_number
  normal ggdG
endfunction

" Close compilation error buffer opened due to mbed compile call
function! CloseErrorBuffer()
  if (exists("g:error_buffer_number"))
    execute "bdelete " . g:error_buffer_number
    let g:error_buffer_number = -1
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
map <leader>C :call MbedCompileClean()<CR>
map <leader>cf :call MbedCompileFlash()<CR>
map <leader>cv :call MbedCompileVerbose()<CR>
map <leader>cV :call MbedCompileVVerbose()<CR>
map <leader>n  :call MbedNew()<CR>
map <leader>s  :call MbedSync()<CR>
map <F9> :call CloseErrorBuffer()<CR>

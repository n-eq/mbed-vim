" mbed.vim
" author: marrakchino (nabilelqatib@gmail.com)
" version: 0.1
"
" This file contains routines that may be used to execute mbed CLI commands
" from within VIM. It depends on mbed OS. Therefore, 
" you must have mbed CLI correctly installed 
" (see https://github.com/ARMmbed/mbed-cli#installation).
"
" In command mode:
" <leader>c:  Compile the current application
" <leader>C:  Clean the build directory and compile the current application
" <leader>cf: Compile and flash the built firmware onto a connected target
" <leader>cv: Compile the current application in verbose mode
" <leader>cV: Compile the current application in very verbose mode
" <leader>n:  Create a new mbed program or library
" <leader>s:  Synchronize all library and dependency references
" <leader>t:  Find, build and run tests
" <leader>d:  Import missing dependencies
" <leader>a:  Prompt for an mbed library to add
" <leader>r:  Prompt for an mbed library to remove
" <F9>:       Close the error buffer (when open)
" <F11>:      Set the current application's target and toolchain 
"
" Add <library_name> --       Add the specified library. When no argument is given,
"                             you are prompted for the name of the library
" Remove <library_name> --    Remove the specified library. When no argument is given,
"                             you are prompted for the name of the library
" SetToolchain <toolchain> -- Set a toolchain (ARM, GCC_ARM, IAR)
" SetTarget <target> --       Set a target
"
" Additionally, you can specify the values of these variables in your vim
" configuration file, to suit this plugin to your needs (in case you always
" use the same mbed target/toolchain):
"   g:mbed_target --      The name of your target. mbed CLI doesn't check that your
"                         target name is correct, so make sure you don't misspell it.
"   g:mbed_toolchain --   The name of the used toolchain (ARM, GCC_ARM, IAR).
"
" Notes:
"   When you execute an unsuccessful "compile" command an "error buffer" is open 
"   at the left of the current Vim window (otherwise a message is echoed when 
"   the compilation was successful). This buffer is a scratch and can't be
"   saved. You can re-compile your program with this buffer still open, it 
"   will refresh with the new output reloaded, and no additional buffer
"   is opened. You can close this buffer with <F9>. 
"


" TODO: transform MbedAdd* and MbedRemove* functions to take a variable number
" of arguments (libraries to add/remove), see vim varags
" (http://learnvimscriptthehardway.stevelosh.com/chapters/24.html)


" Global variables
" XXX: variables should be local to the current window or global?
if !exists( "g:mbed_target" )
  let g:mbed_target = ""
endif

if !exists( "g:mbed_toolchain" )
  let g:mbed_toolchain = ""
endif

function! MbedGetTargetandToolchain( force )
  let l:mbed_tools_exist = system("which mbed")
  if l:mbed_tools_exist == ""
    echoe "Couldn't find mbed CLI tools."
  else
    if g:mbed_target == "" || a:force != 0
      " if has("win32") " TODO (one day)
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
      " if has("win32") " TODO (one day)
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

function! PasteContentToErrorBuffer()
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
    set buftype=nofile
    let g:error_buffer_number = bufnr('%')
  endif

  call CleanErrorBuffer()

  " paste register content to buffer
  silent put=@o
  " go to last line
  normal G
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

" Compile the current program with the given flag (-f, -c, -v, -vv)
function! MbedCompile(flag)
  call MbedGetTargetandToolchain ( 0 ) 
  execute 'wa'
  let @o = system("!mbed compile" . a:flag)
  if !empty(@o)
    " <Image> pattern not found
    if match(getreg("o"), "Image") == -1
      call PasteContentToErrorBuffer()
    else
      echo "Compilation ended successfully."
    endif
  endif
endfunction

function! MbedAddLibary(libraryName)
  if a:libraryName == ""
    call PromptForLibraryToAdd()
  else
    execute '!mbed add ' . a:libraryName
  endif
endfunction

function! PromptForLibraryToAdd()
  let l:library_name = input("Please enter the name/URL of the library to add: ")
  call MbedAddLibary(l:library_name)
endfunction

function! MbedRemoveLibary(libraryName)
  if a:libraryName == ""
    call PromptForLibraryToRemove()
  else
    execute '!mbed remove ' . a:libraryName
  endif
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

" TODO
function! MbedTest()
  execute 'wa'
  let @t = system("!mbed test")
  if !empty(@t)
    " TODO: find a pattern in the output to notify that the tests were
    " successful
    vnew
    set buftype=nofile
    silent put=@t
    normal G
  endif
endfunction

" command-mode mappings
map <leader>c  :call MbedCompile("")<CR>
map <leader>C  :call MbedCompile("-c")<CR>
map <leader>cf :call MbedCompile("-f")<CR>
map <leader>cv :call MbedCompile("-v")<CR>
map <leader>cV :call MbedCompile("-vv")<CR>
map <leader>n  :call MbedNew()<CR>
map <leader>s  :call MbedSync()<CR>
map <leader>t  :call MbedTest()<CR>
map <leader>d  :call MbedDeploy()<CR>
map <leader>a  :call MbedAddLibary("")<CR>
map <leader>r  :call MbedRemoveLibary("")<CR>
map <F9>       :call CloseErrorBuffer()<CR>
map <F11>      :call MbedGetTargetandToolchain(1)<CR>

" commands
command! -nargs=? Add :call MbedAddLibary("<args>")
command! -nargs=? Remove :call MbedRemoveLibary("<args>")
command! -nargs=1 SetToolchain :let g:mbed_toolchain="<args>"
command! -nargs=1 SetTarget :let g:mbed_target="<args>"

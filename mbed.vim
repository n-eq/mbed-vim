" mbed.vim
" author: marrakchino (nabilelqatib@gmail.com)
" version: 0.0
"
" This file contains routines that may be used to execute mbed CLI commands
" from within VIM. It depends on mbed OS. You must have mbed CLI correctly
" installed (see https://github.com/ARMmbed/mbed-cli#installation).
" XXX: does it work without 'workon mbed-os' previously executed??
"
" In command mode:
"		<leader>mb: run 'mbed compile' on the current application
"		<leader>mbv: run 'mbed compile -v' on the current application
"		<leader>mbV: run 'mbed compile -vv' on the current application
"		<leader>mbc: run 'mbed compile -c' on the current application
"		<F11>: set the current application target and toolchain
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

" Execute 'mbed compile' in the background
function! MbedCompile()
	call MbedGetTargetandToolchain ( 0 ) 
	execute 'wa <ESC> :!mbed compile'
endfunction

" Execute 'mbed compile -c' in the background
function! MbedCompileClean()
	call MbedGetTargetandToolchain ( 0 ) 
	execute 'wa <ESC> :! mbed compile -c'
endfunction

" Execute 'mbed compile -v' in the background
function! MbedCompileVerbose()
	call MbedGetTargetandToolchain ( 0 ) 
	execute 'wa <ESC> :! mbed compile -v'
endfunction

" Execute 'mbed compile -vv' in the background
function! MbedCompileVVerbose()
	call MbedGetTargetandToolchain ( 0 ) 
	execute 'wa <ESC> :! mbed compile -vv'
endfunction

" command-mode mappings
map <F11> :call MbedGetTargetandToolchain(1)<CR>
map <leader>mb :call MbedCompile()<CR>
map <leader>mbc :call MbedCompileClean()<CR>
map <leader>mbv :call MbedCompileVerbose()<CR>
map <leader>mbV :call MbedCompileVVerbose()<CR>

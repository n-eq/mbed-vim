# mbed-vim

[![version](https://img.shields.io/badge/version-v0.2-red.svg)](https://github.com/nelqatib/mbed-vim/releases)
[![Build Status](https://travis-ci.org/nelqatib/mbed-vim.svg?branch=master)](https://travis-ci.org/nelqatib/mbed-vim)
[![license](http://img.shields.io/badge/license-mit-blue.svg)](https://opensource.org/licenses/MIT)


Execute mbed-CLI commands from within Vim.

## Installation

* By cloning the repository
```sh
$ git clone git@github.com:marrakchino/mbed-vim.git
$ cp mbed-vim/plugin/mbed.vim ~/.vim/plugin
```

* By downloading and saving the plugin file in your `plugin` directory

```sh
$ wget https://raw.githubusercontent.com/nelqatib/mbed-vim/master/plugin/mbed.vim -O ~/.vim/plugin/mbed.vim
```

## Features

* Compiling the current application with different options (clean, verbose mode, etc.) and displaying the
output when the compilation is unsuccessful.

* Adding/Removing a library.

* Setting the application's target/toolchain.

* Synchronizing the different dependencies.

* Running tests and displaying the results.

### Default key mappings

```vim
<leader>c:   Compile the current application.
<leader>C:   Clean the build directory and compile the current application.
<leader>cf:  Compile and flash the built firmware onto a connected target.
<leader>cv:  Compile the current application in verbose mode.
<leader>cV:  Compile the current application in very verbose mode.
<leader>n:   Create a new mbed program or library.
<leader>s:   Synchronize all library and dependency references.
<leader>t:   Find, build and run tests.
<leader>d:   Import missing dependencies.
<leader>a:   Prompt for an mbed library to add.
<leader>r:   Prompt for an mbed library to remove.
<leader>l:   Display dependency tree
<F9>:        Close the error buffer (when open).
<F12>:       Set the current application's target and toolchain.
```

### Commands

```vim
Add <library_name>        Add the specified library. When no argument is given,
                            you are prompted for the name of the library.
Remove <library_name>     Remove the specified library. When no argument is given,
                            you are prompted for the name of the library.
SetToolchain <toolchain>  Set a toolchain (ARM, GCC_ARM, IAR).
SetTarget <target>        Set a target.
```

## Contributing

Feel free to contribute to this project, either by [opening issues](https://github.com/nelqatib/mbed-vim/issues/new) or by [forking](https://github.com/nelqatib/mbed-vim#fork-destination-box) the repository and [opening pull requests](https://github.com/nelqatib/mbed-vim/compare). 

## License

This project is licensed under MIT, see `LICENSE` file for more.

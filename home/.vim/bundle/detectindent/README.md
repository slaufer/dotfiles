# DetectIndent

*A [Vim](http://www.vim.org/) plugin for automatically detecting indent settings*

This script provides a command which will attempt to guess the correct indent settings for an open file, for use when there is no modeline available. Specifically, the command sets the following buffer-local options for you:

* [`'expandtab'`](http://vimdoc.sourceforge.net/htmldoc/options.html#%27expandtab%27) (tabs vs. spaces)
* [`'shiftwidth'`](http://vimdoc.sourceforge.net/htmldoc/options.html#%27shiftwidth%27) (width of indentation)
* [`'tabstop'`](http://vimdoc.sourceforge.net/htmldoc/options.html#%27tabstop%27) (width of a tab character)
* [`'softtabstop'`](http://vimdoc.sourceforge.net/htmldoc/options.html#%27softtabstop%27) (number of spaces that <kbd>Tab</kbd> inserts)

Note that this is a pure Vim implementation, and doesn’t require any external applications or interpreters.

## Usage

    :DetectIndent

May also be used in an autocommand. For example, you might want to put this in your `vimrc`:

    augroup DetectIndent
       autocmd!
       autocmd BufReadPost *  DetectIndent
    augroup END

## Options

The plugin provides some options you can set to configure what settings are chosen in edge cases or to constrain the range of indent widths allowed. Read about these options in the docs [on GitHub](https://github.com/roryokane/detectindent/blob/master/doc/detectindent.txt) or with `:help detectindent` in Vim.

## Installation

With [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone https://github.com/roryokane/detectindent.git

With [Vundle](https://github.com/gmarik/Vundle.vim):

    Bundle 'roryokane/detectindent'

## About this fork

[The original plugin](https://github.com/ciaranm/detectindent) (the one [in the official Vim plugin repository](http://www.vim.org/scripts/script.php?script_id=1171)) seems to be abandoned. So this is a fork of [Raymond Ko’s version](https://github.com/raymond-w-ko/detectindent), which was the most polished and complete of the forks at that time, and included some merged commits that gave this plugin much more robust detection of indentation style than the original. His README said this:

> I merged all the forks that I found were semi-reasonable in the GitHub network graph.
> This was done in less than 15 minutes, so expect bugs!

My fork’s additions to Raymond’s fork:

* a full README for GitHub, with a description and installation instructions
* automated tests of the plugin
* require only a majority, not an entirety, of lines to use tabs for tabs to be selected
* detect the indent width when tabs are detected, not only when spaces are detected
* set -1 for `softtabstop` when Vim supports it, to make it easier for users to manually change indentation
* remove the option `g:detectindent_preferred_expandtab`, which is redundant with the global setting `&g:expandtab`
* gracefully exit on old Vim versions known to not work (< 7.0)
* better wording of verbose log messages
* various refactorings
* style and formatting fixes in code and documentation

Feel free to submit [pull requests](https://github.com/roryokane/detectindent/pulls) or file [issues](https://github.com/roryokane/detectindent/issues), such as if DetectIndent wrongly guesses the indentation of a file you tried to edit in Vim.

This folder, `tests`, contains the executable tests for DetectIndent.

## Running the tests

As a prerequisite, the [Vader](https://github.com/junegunn/vader.vim) testing plugin must be installed.

To run the tests, `cd` so your working is the root folder `detectindent`, *not* this `tests` folder. Then run the following:

    $ tests/run-all-tests

You should see output like the following:

    VIM - Vi IMproved 7.4 (2013 Aug 10, compiled Oct 25 2015 23:15:39)
    MacOS X (unix) version
    Included patches: 1-898
    
    [… a bunch of details about the version of Vim the tests are being run with …]
    
    Starting Vader: 3 suite(s), 23 case(s)
      Starting Vader: /Users/roryokane/.vim/bundle/detectindent/tests/all-options-are-set.vader
        (1/2) [EXECUTE] reset indent options to initial values
        (2/2) [EXECUTE] check that all four options are changed to a correct value
      Success/Total: 2/2
      Starting Vader: /Users/roryokane/.vim/bundle/detectindent/tests/config-options-are-respected.vader
        (1/7) [EXECUTE] reset indent options to initial values
        (2/7) [EXECUTE] g:detectindent_preferred_indent is respected
        (3/7) [EXECUTE] g:detectindent_min_indent is respected for space indentation
        (4/7) [EXECUTE] g:detectindent_max_indent is respected for space indentation
        (5/7) [EXECUTE] g:detectindent_max_indent is respected for mixed-space-and-tab indentation with a tab majority
        (6/7) [EXECUTE] g:detectindent_max_indent is ignored in favor of global options for pure-tab indentation
        (7/7) [EXECUTE] g:detect_min_indent and max_indent, when combined, override too-low detected indentation
      Success/Total: 7/7
      Starting Vader: /Users/roryokane/.vim/bundle/detectindent/tests/fixtures-detected-correctly.vader
        ( 1/14) [EXECUTE] reset indent options to initial values
        ( 2/14) [EXECUTE] Coursera-The_Hardware-Software_Interface-lab1-bits.c
        ( 2/14) [EXECUTE] (X) 1 should be equal to 2
        ( 3/14) [EXECUTE] FountainMusic-FMDisplayItem.c
        ( 3/14) [EXECUTE] (X) 4 should be equal to 8
        ( 4/14) [EXECUTE] FountainMusic-FMDisplayItem.h
        ( 5/14) [EXECUTE] GameOfLife.plaid – badly mixed indentation
        ( 6/14) [EXECUTE] general-level-1.indentc
        ( 7/14) [EXECUTE] haml-action_view.haml
        ( 8/14) [EXECUTE] haml-render_layout.haml
        ( 9/14) [EXECUTE] jSnake-demo.html
        (10/14) [EXECUTE] jSnake-snake3.js
        (11/14) [EXECUTE] parslet-scope.rb
        (12/14) [EXECUTE] semver.md – no indentation at all
        (13/14) [EXECUTE] starbuzz_beverage_cost_calculator-core.clj
        (13/14) [EXECUTE] (X) 1 should be equal to 2
        (14/14) [EXECUTE] vared.fish
        (14/14) [EXECUTE] (X) 40 should be equal to 8
      Success/Total: 10/14
    Success/Total: 19/23 (assertions: 37/41)
    Elapsed time: 2.109866 sec.

That’s right, not all of the tests currently pass. Some edge cases, such as Lisp-like indentation, are currently detected wrong. I figured it was better to put them in the tests so I can at least know about them, and test whether they are fixed later when I improve the algorithm.

There is also a command `tests/run-fixtures-test`. I made a convenient separate command for running those particular tests because they are the only tests that can run on older versions of DetectIndent without changes. I sometimes want to run those tests on older versions to compare their performance with the current version.

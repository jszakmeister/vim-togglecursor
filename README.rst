togglecursor
============

This plugin aims to provide the ability to change the cursor when entering Vim's
insert mode on terminals that support it.  Currently, that's limited to iTerm,
Konsole, and xterm is partially supported (creates an underline cursor instead
of line, by default).

Installation
------------

Unzip into ``~/.vim`` (or ``%USERPROFILE%\vimfiles`` on Windows).  You may also
install it under pathogen by extracting it into it's own directory under
``bundle``, such as ``~/.vim/bundle/vim-togglecursor``.

The latest version can be obtained from:
    https://github.com/jszakmeister/vim-togglecursor

Hints 'n' Tips
--------------

By default, on most systems, the cursor behavior introduced by this plugin for
iTerm will not continue if you ssh to another system, because the
``$TERM_PROGRAM`` environment variable will not be passed, which is what
vim-togglecursor uses to check if it is running inside iTerm. However, if you
modify ssh_config for the client::

  SendEnv TERM_PROGRAM

And /etc/ssh/sshd_config for the server::

  AcceptEnv LANG LC_* TERM_PROGRAM

... then the TERM_PROGRAM environment variable will be passed, and
vim-togglecursor should work on the target system.

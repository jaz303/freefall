Freefall
========

Another Ruby on Rails CMS.

Will be compatible with MySQL and PostgreSQL, and ready for deployment to Heroku.

This is a work in progress, until this message is removed don't bother cloning unless you want to hack on it. I promise it will be good, though.

Installation
------------

    $ rails foo
    $ cd foo
    $ git clone ... vendor/gems/freefall-4.0.0
    $ echo "require 'vendor/gems/freefall-4.0.0/lib/tasks'" >> Rakefile
    $ rake ff:setup
    $ script/server

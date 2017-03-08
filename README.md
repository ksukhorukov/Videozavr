# Videozavr

Create custom text watermarks on custom video files

## Requirements

* Ruby version 2.3.0


## System dependencies


Install ffmpeg with ``--with-freetype`` option 

For instance on Mac OS X it can be done with such command:

``brew install ffpmpeg --with-freetype``

## Install and deploy

Execute the following commands in the main folder of the project

* bundle install
* rake db:setup
* brew install redis
* redis-server
* bundle exec sidekiq
* rails s

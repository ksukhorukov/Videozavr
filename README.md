# Videozavr

Create custom text watermarks on custom video files

* Ruby version

2.3.0

* System dependencies

ffmpeg

* Configuration

Install ffmpeg with '--with-freetype' option 

For instance on Mac OS X it can be done with such command:

$ brew install ffpmpeg --with-freetype

* Database creation

$ rake db:setup

* Services (job queues, cache servers, search engines, etc.)

$ brew install redis
$ redis-server
$ bundle exec sidekiq

* Deployment instructions

$ rails s



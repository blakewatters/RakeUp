RakeUp
======

RakeUp provides a set of turn-key [Rake](http://rake.rubyforge.org/) tasks for running a local [Rack](http://rack.github.io/) based server application. By configuring a single block in your Rakefile, you will have access to a rich set of tasks for start, stopping, and monitoring your server. These tasks are essentially thin wrappers around the `rackup` command and are useful for running lightweight applications that are used for local development and testing.

This project was developed for use with the test server of the [RestKit](http://restkit.org/) project on iOS. RestKit runs numerous tests over HTTP against a local server and RakeUp provides the management of that server instance.

## Example Rakefile

``` ruby
require 'rubygems'
require 'bundler/setup'
require 'rakeup'

RakeUp::ServerTask.new do |t|
  t.port = 8558
  t.pid_file = 'tmp/server.pid'
  t.rackup_file = 'server.ru'
  t.server = :thin
end
```

After configuring the task, you can run `rake -T server` to see your new server management tasks:

```
rake server                       # Run the server in the foreground
rake server:abort_unless_running  # Abort the task chain unless the server is running
rake server:autostart             # Starts the server if there is not already an instance running
rake server:autostop              # Stops the server if executed via autostart
rake server:restart               # Restart the server daemon
rake server:start                 # Start the server daemon
rake server:status                # Check the status of the server daemon
rake server:stop                  # Stop the server daemon
```

If you wish to synthesize your tasks under a name other than 'server' you can provide a string when initializing the server task: `RakeUp::ServerTask.new("other_name")`.

## Installation

To add RakeUp to your application, edit your Gemfile to import the RakeUp gem:

```ruby
gem 'rakeup', '~> 1.0'
```

And then edit your Rakefile to import the RakeUp library and configure your server tasks:

```ruby
require 'rubygems'
require 'bundler/setup'
require 'rakeup'

RakeUp::ServerTask.new do |t|
  t.port = 8558
  t.pid_file = 'Tests/Server/server.pid'
  t.rackup_file = 'Tests/Server/server.ru'
  t.server = :thin # Or puma, mongrel, etc.
end
```

## Supported Web Servers

Any web server that is imported by your Gemfile and has a Rack handler available is available for execute. Commonly used servers are thin, mongrel, webrick, and puma. See `rakeup --help` for more examples.

## Customizing the Tasks

At its core, RakeUp is simply a convenience wrapper around rackup commandline invocations. You can customize the rake tasks by overriding the run, start, stop, and restart commands when configuring the server:

```ruby
RakeUp::ServerTask.new do |t|
  t.port = 8558
  t.pid_file = 'Tests/Server/server.pid'
  t.rackup_file = 'Tests/Server/server.ru'
  t.log_file = 'Tests/Server/server.log'
  
  # Run Thin directly
  t.run_command = "thin -r #{t.rackup_file} -P #{t.pid_file} -p #{t.port} start"
  t.start_command = "thin -r #{t.rackup_file} -P #{t.pid_file} -p #{t.port} start -D"
  t.stop_command = "thin -r #{t.rackup_file} -P #{t.pid_file} -p #{t.port} stop"
  t.restart_command = "thin -r #{t.rackup_file} -P #{t.pid_file} -p #{t.port} restart"
end
```

## Contact

Blake Watters

- http://github.com/blakewatters
- http://twitter.com/blakewatters
- blakewatters@gmail.com

## License

RakeUp is available under the Apache 2 License. See the LICENSE file for more info.

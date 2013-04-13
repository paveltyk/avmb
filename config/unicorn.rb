preload_app true
worker_processes 3
timeout 30

before_fork do |server, worker|
  if defined?(Mongoid)
    Mongoid.master.connection.close if Mongoid.master.connection.connected?
  end
end

after_fork do |server, worker|
  if defined?(Mongoid)
    Mongoid.master.connection.connect unless Mongoid.master.connection.connected?
  end
end
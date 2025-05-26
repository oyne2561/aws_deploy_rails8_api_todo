app_path = File.expand_path('..', __dir__)

worker_processes 1
working_directory app_path
listen "0.0.0.0:3000", tcp_nopush: true

# CloudWatch Logsで見えるように修正
stderr_path "/dev/stderr"
stdout_path "/dev/stdout"

# PIDファイルの場所を明示的に指定
pid "/app/tmp/pids/unicorn.pid"

timeout 600
preload_app true

GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true
check_client_connection false

before_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end

# アプリケーションのルートパスを設定
# 現在のディレクトリ（__dir__）の一つ上の階層を取得
app_path = File.expand_path('..', __dir__)

# Unicornのワーカープロセス数を1に設定
# ワーカープロセスとは、実際にリクエストを処理する作業単位
worker_processes 1

# 作業ディレクトリをアプリケーションのパスに設定
working_directory app_path

# Unicornがリクエストを受け付けるポート番号（3000番）を指定
listen 3000

# Unicornのプロセスを実行中の識別番号（PID）を保存するファイルのパスを指定
pid "#{app_path}/tmp/pids/unicorn.pid"

# エラーログの出力先を指定
stderr_path "#{app_path}/log/unicorn.stderr.log"

# 標準出力ログの出力先を指定
stdout_path "#{app_path}/log/unicorn.stdout.log"

# リクエスト処理のタイムアウト時間を600秒（10分）に設定
timeout 600

# アプリケーションをプリロード（事前読み込み）するかどうかを設定
# trueにすると起動時に一度だけアプリを読み込み、メモリを節約できる
preload_app true

# Rubyのガベージコレクション（不要なメモリを解放する機能）の設定
# copy_on_write_friendly設定が利用可能なら有効にする
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

# クライアント接続のチェックを無効に設定
check_client_connection false

# 一度だけ実行するためのフラグを設定
run_once = true

# ワーカープロセスをフォークする前に実行される処理
before_fork do |server, worker|
  # ActiveRecordが定義されていれば、データベース接続を切断
  # これにより親プロセスの接続を子プロセスが引き継がないようにする
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  # 一度だけ実行するフラグを管理
  if run_once
    run_once = false
  end

  # 古いUnicornプロセスの終了処理
  # デプロイ時など、新しいUnicornを起動する際に古いプロセスを適切に終了させる
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      # 適切なシグナルを送信して古いプロセスを終了させる
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH => e
      # エラーが発生した場合はログに記録
      logger.error e
    end
  end
end

# ワーカープロセスがフォークされた後に実行される処理
after_fork do |_server, _worker|
  # ActiveRecordが定義されていれば、データベース接続を再確立
  # 各ワーカープロセスが独自のデータベース接続を持つようにする
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

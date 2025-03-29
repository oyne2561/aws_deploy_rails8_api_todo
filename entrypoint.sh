#!/bin/bash
set -e

# データベースが起動するまで待つ
until pg_isready -h db -U postgres; do
  echo "Waiting for postgres..."
  sleep 2
done

# 初回起動時のセットアップを追加したい場合ここに書く

exec "$@"

### 新規作成時のディレクトリ構成
以下を手動作成
```
.
├── Dockerfile.dev - 記述
├── Gemfile - 記述
├── Gemfile.lock
├── README.md
├── docker-compose.yml - 記述
└── entrypoint.sh - 記述
```

### 初回コマンド
1. ビルド

```
docker-compose build
```
2. Railsアプリの作成（初回のみ）
```
docker-compose run api rails new . --api --force --no-deps --database=postgresql
```
3. 再ビルド（Gemfile変更後など）
```
docker-compose build
```
4. DB設定を修正（config/database.yml）
defaultのhostを `db` にする（docker-composeのサービス名）
database.yml の例：
```
default: &default
  adapter: postgresql
  encoding: unicode
  username: postgres
  password: password
  host: db

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test
```

### 起動
```
docker-compose run api rails db:create
```
```
docker-compose up
```


### コンテナの中に入るコマンド
```
docker-compose exec api bash
```

### その他
1. **entrypoint.sh**
この entrypoint.sh スクリプトは、Docker コンテナ起動時に実行される 初期化スクリプト です。特に Rails コンテナが PostgreSQL に依存しているときに、DBが起動するのを待ってから Rails サーバーなどを実行するために使います。

2. **.dockerignore**
これは .dockerignore ファイルの内容で、Docker イメージを作るときに除外したいファイルやディレクトリを指定するものです。

言い換えると、.dockerignore は Git の .gitignore に似た仕組みで、Docker ビルド時に不要なものを含めないためのフィルターです。
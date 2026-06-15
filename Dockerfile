# microsocks をビルドする alpine ベースの SOCKS5 プロキシ
FROM alpine:3.20 AS build

# ビルドに必要なツールを導入
RUN apk add --no-cache build-base git

# microsocks のソースを取得してビルド
RUN git clone --depth 1 https://github.com/rofl0r/microsocks.git /src \
    && make -C /src

# 実行用の軽量イメージ
FROM alpine:3.20

# ビルド済みバイナリのみコピー
COPY --from=build /src/microsocks /usr/local/bin/microsocks

# 非 root ユーザーで実行
RUN adduser -D -H proxy
USER proxy

# SOCKS5 待ち受けポート
EXPOSE 1080

# 認証なし・全インターフェースで待ち受け
ENTRYPOINT ["/usr/local/bin/microsocks", "-i", "0.0.0.0", "-p", "1080"]

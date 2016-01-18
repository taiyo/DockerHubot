FROM node:latest

# コンテナにHubotアプリケーションを持っていく
RUN mkdir /bot && cd /bot  
ADD . /bot

EXPOSE 9999

WORKDIR /bot

# docker runした時の実行コマンド
CMD ["bin/hubot", "--adapter", "slack"]

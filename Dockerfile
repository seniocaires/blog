FROM debian:stretch

ADD . /app

RUN apt update && apt install -y gcc ruby-full make zlib1g-dev \
    && gem install jekyll && gem install bundler \
    && cd /tmp && jekyll new stub && cd /tmp/stub && bundler exec jekyll build && rm -rf /tmp/stub \
    && cd /app && ./scripts/install

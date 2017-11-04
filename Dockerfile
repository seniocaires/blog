FROM debian:stretch

RUN apt update && apt install -y gcc ruby-full make && gem install jekyll && gem install bundler \
    && cd /tmp && jekyll new stub && cd /tmp/stub && bundler exec jekyll build && rm -rf /tmp/stub

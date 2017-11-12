FROM debian:stretch

ADD . /app

ENV JEKYLL_ENV production

RUN apt update && apt install -y gcc ruby-full make zlib1g-dev \
    && gem install jekyll && gem install bundler \
    && cd /tmp && jekyll new stub && cd /tmp/stub && bundler exec jekyll build && rm -rf /tmp/stub \
    && cd /app && ./scripts/install && jekyll build

WORKDIR /app

EXPOSE 4000

ENTRYPOINT ["jekyll","serve","-H","0.0.0.0"]

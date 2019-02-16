FROM bitwalker/alpine-elixir-phoenix:latest

MAINTAINER Wietse Wind <mail@wietse.com>

ENV PORT=4000 MIX_ENV=dev

COPY entrypoint /entrypoint.sh
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

# Install App node depdendencies
RUN cd /usr/src/app && \
    cd assets && \
    npm install

# Install App Elixir dependencies
RUN cd /usr/src/app && \
    mix local.hex --force && \
    mix deps.get && \
    mix local.rebar --force && \
    mix deps.update bcrypt_elixir

RUN rm -rf /var/cache/apk/*

# Run application
EXPOSE 4000

ENTRYPOINT [ "/entrypoint.sh" ]

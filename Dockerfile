# syntax=docker/dockerfile:1
FROM ruby:3.3-alpine

ENV ENV="/root/.ashrc"

COPY <<-EOT /root/.ashrc
alias be='bundle exec'
alias ll='ls -lah'

export TITLEBAR='\\[\\033]2;\\u@\\H\\007\\]'
export PS1="\${TITLEBAR}\\[\\033[73m\\][\\A]\\[\\033[36m\\][\\[\\033[\33m\\]\${RAILS_ENV}\\[\\033[1;37m\\]@\\[\\033[34m\\]\\H:\\[\\033[35m\\]\\w\\[\\033[36m\\]]\\[\\033[35m\\]\\n\\\\$\\[\\033[0m\\] "
EOT

RUN apk add --no-cache build-base libc-dev make
WORKDIR /usr/src/app
COPY . .
RUN gem install bundler && bundle install
EXPOSE 4567

CMD ["bundle", "exec", "rackup", "csp_reporter.rb"]

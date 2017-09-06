FROM ruby:alpine

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

# Update and install all of the required packages.
# At the end, remove the apk cache
#RUN apk update && \
#    apk upgrade && \
#    apk add $BUILD_PACKAGES && \
#    apk add $RUBY_PACKAGES && \
#    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
RUN mkdir /usr/app/public
WORKDIR /usr/app

COPY server/Gemfile /usr/app/
COPY server/Gemfile.lock /usr/app/
COPY server/api.rb /usr/app/
COPY server/public/ /usr/app/public

RUN bundle install

CMD ["ruby", "api.rb"]

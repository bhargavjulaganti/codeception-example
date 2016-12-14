FROM php:7.1.0-cli
MAINTAINER clample@saucelabs.com

RUN mkdir -p /root/codeception-example
ADD . /root/codeception-example
WORKDIR /root/codeception-example

RUN /root/codeception-example/codecept.phar build

CMD /root/codeception-example/codecept.phar run
FROM ubuntu:16.04
MAINTAINER Akhil Raj <akhilrajmailbox@gmail.com>

RUN apt-get update && apt-get install -y nano sudo apache2 libldap-2.4-2 iputils-ping
RUN cp -r /etc/apache2 /root/apache2

ADD start.sh /root/start.sh
RUN chmod a+x /root/start.sh

ENTRYPOINT "/root/start.sh"


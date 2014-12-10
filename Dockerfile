FROM phusion/baseimage:latest
MAINTAINER "Fawad Shah <https://github.com/1fawadshah>"

# Install Java 7 #
RUN sudo add-apt-repository -y ppa:webupd8team/java
RUN sudo apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && sudo apt-get -y install oracle-java7-installer

# Install and Configure Elaticsearch 1.1.1 #
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo 'deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list
RUN sudo apt-get update
RUN sudo apt-get -y install elasticsearch=1.1.1
ADD elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# Install and Configure Kibana 3.0.1 #
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz
RUN tar xvf kibana-3.0.1.tar.gz
RUN sudo mkdir -p /var/www/kibana3
RUN sudo cp -R kibana-3.0.1/* /var/www/kibana3/
ADD kibana/config.js /var/www/kibana3/config.js

# Install and Configure Nginx #
RUN sudo apt-get -y install nginx
ADD nginx/nginx.conf /etc/nginx/sites-available/default
ADD nginx/kibana.htpasswd /etc/nginx/conf.d/kibana.htpasswd

# Install and Configure Logsatsh 1.4.2 #
RUN echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
RUN sudo apt-get update
RUN sudo apt-get -y install logstash=1.4.2-1-2c0f5a1
RUN sudo mkdir -p /etc/pki/tls/certs
RUN sudo mkdir /etc/pki/tls/private
ADD logstash/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
ADD logstash/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
ADD logstash/01-lumberjack-input.conf /etc/logstash/conf.d/01-lumberjack-input.conf
# ADD 10-structured.conf /etc/logstash/conf.d/10-structured.conf
ADD logstash/30-lumberjack-output.conf /etc/logstash/conf.d/30-lumberjack-output.conf

# Ports (80/nginx, 9200,9300,54328/elasticsearch, 9301/logstash, 5000/lumberjack ) #
EXPOSE 80 9200 9300 9301 5000 54328/udp

ENTRYPOINT service elasticsearch restart && service logstash restart && service nginx restart && tail -f /var/log/nginx/kibana.error.log

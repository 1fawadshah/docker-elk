- Setup:
========
    * Create Data Directory (on Docker Host):
        # mkdir -p /opt/elk
    
    * Build Docker Image (on Docker Host):
        # docker build -t deployment/elk .
        
    * Run Docker Container (on Docker Host):
        # docker run --name elk --privileged -d -v /opt/elk:/var/lib/elasticsearch -v /opt/elk:/var/log/elasticsearch -v /opt/elk:/var/log/nginx -v /opt/elk:/var/log/logstash -p 80:80 -p 9200:9200 -p 9300:9300 -p 9301:9301 -p 5000:5000 -p 54328:54328/udp -t deployment/elk
        
    All logs and Elasticsearch data are persistent, in case docker container goes down all logs and ES data will be available in /opt/elk direcory on Docker host
    Kibana user credentials are; {User : admin} {Password : admin}
    To ship logs into ELK you need to setup logstash-forwarder on all server from where you want to forward logs to ELK container (Lumberjack port is 5000)

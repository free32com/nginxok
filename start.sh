#!/bin/sh
### tsharp Docker

#docker run -it --privileged -d --name=nginx -p 9000:80 -v /volume2/Data/tsharp/userdata:/var/www/html --restart unless-stopped nginx:latest
docker run -dit --privileged -d --name=nginx -p 80:80 --restart unless-stopped nginx:test 


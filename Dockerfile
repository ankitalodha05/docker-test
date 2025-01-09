#FROM ubuntu/apache2:latest
#ADD . /var/www/html/
#EXPOSE 80
#CMD apachectl -D FOREGROUND

FROM nginx:latest
ADD index.html /usr/share/nginx/html/index.html
EXPOSE 80

FROM ubuntu/apache2:latest
ADD . /var/www/html/
EXPOSE 80
CMD apachectl -D FOREGROUND

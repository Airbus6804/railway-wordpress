FROM wordpress:latest

ARG MYSQLPASSWORD
ARG MYSQLHOST
ARG MYSQLPORT
ARG MYSQLDATABASE
ARG MYSQLUSER
ARG SIZE_LIMIT

ENV WORDPRESS_DB_HOST=$MYSQLHOST:$MYSQLPORT
ENV WORDPRESS_DB_NAME=$MYSQLDATABASE
ENV WORDPRESS_DB_USER=$MYSQLUSER
ENV WORDPRESS_DB_PASSWORD=$MYSQLPASSWORD
ENV WORDPRESS_TABLE_PREFIX="RW_"

RUN echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf
RUN echo "DirectoryIndex index.php index.html" >> /etc/apache2/apache2.conf

# Set the maximum upload file size directly in the PHP configuration
RUN echo "upload_max_filesize = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini

# Configure Apache DocumentRoot to Laravel's public directory

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Update Apache vhost configs to use the Laravel public directory as DocumentRoot
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf

# Update main apache config and other conf-available files
RUN sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy and setup entrypoint script (fixes MPM at runtime - Railway re-enables modules)

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]

# Folosim o imagine oficială Nginx foarte mică și rapidă
FROM nginx:alpine

# Ștergem fișierele implicite Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiem toate fișierele din repo-ul nostru (inclusiv index.html, preview.js, folderul client etc.)
# în folderul din care Nginx servește paginile web
COPY . /usr/share/nginx/html/

# Suprascriem configurarea default a Nginx ca să asculte dinamic pe portul dat de Northflank (sau implicit 8080)
# Aceasta e o practică bună pentru cloud deployment.
RUN echo "server { \
    listen ${PORT:-8080}; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files \$uri \$uri/ /index.html; \
    } \
}" > /etc/nginx/conf.d/default.conf

# Setăm comanda de pornire (va înlocui variabila $PORT la runtime și va porni nginx)
CMD /bin/sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp && mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

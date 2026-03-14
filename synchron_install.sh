#!/bin/bash
#проверка что пользователь запустивший админ
if id -nG | grep -qw "astra-admin"; then
    echo ok
else 
    zenity --info --text="Пользователь не принадлежит группе astra-admin. Необходимо зайди под пользователем с правами администратора."
    exit 1
fi
$(zenity --info --text="Вас приветствует программа установки и настройки вашего собственного облачного хранилища!!" --height=200 --width=300)
#проверка наличия интернета
    form_data=$(zenity --forms --title="Введите данные" --text="Введите данные:" \
        --add-password="Введите пароль Администратора" \
        --add-combo="Выберете версию ALSE" \
        --combo-values="1.7.x|1.8.x" \
        --add-combo="Необходимо обновить систему с интернет репозиториев?" \
        --combo-values="Да|Нет" \ )
    passwd=$(echo "$form_data" | awk -F '|' '{print $1}')
    alse_version=$(echo "$form_data" | awk -F '|' '{print $2}')
    alse_update=$(echo "$form_data" | awk -F '|' '{print $3}')
    #проверка правильности введеного пароля
    echo "$passwd" | sudo -Sv >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                if [ "$alse_version" = "1.7.x" ]; then
                    PHP_VER=8.1
                    #установка сертификатов
                    if [ "$alse_update" = "Да" ]; then
                    (
                        echo $passwd | sudo -S bash -c "echo -e 'deb http://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/ 1.7_x86-64 main contrib non-free' > /etc/apt/sources.list"
                        echo $passwd | sudo -S apt update -y
                        echo $passwd | sudo -S apt install ca-certificates -y
                        #установка репозиториев 1.7.4
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/ 1.7_x86-64 main contrib non-free' > /etc/apt/sources.list"
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/ 1.7_x86-64 main contrib non-free' >> /etc/apt/sources.list"
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/ 1.7_x86-64 main contrib non-free' >> /etc/apt/sources.list"
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 main contrib non-free' >> /etc/apt/sources.list"
                        echo $passwd | sudo -S apt update -y
                        echo $passwd | sudo -S apt install astra-update -y
                        echo $passwd | sudo -S astra-update -A -r -T
                        exit_code=$?
                        # Проверка кода завершения и отображение соответствующего сообщения
                            if [ $exit_code -eq 0 ]; then
                                zenity --info --title="Успех" --text="Система успешно обновлена!"
                            else
                                zenity --error --title="Ошибка" --text="Ошибка при установке обновления."
                            fi
                    ) | zenity --progress --pulsate --auto-close
                    else
                    echo ok
                    fi
                else 
                    PHP_VER=8.3
                    if [ "$alse_update" = "Да" ]; then
                    (
                        #установка сертификатов
                        echo $passwd | sudo -S bash -c "echo -e 'deb http://dl.astralinux.ru/astra/stable/1.8_x86-64/repository-main/ 1.8_x86-64 main contrib non-free' > /etc/apt/sources.list"
                        echo $passwd | sudo -S apt update -y
                        echo $passwd | sudo -S apt install ca-certificates -y
                        #установка репозиториев 1.8.1
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.8_x86-64/repository-main/ 1.8_x86-64 main contrib non-free' >> /etc/apt/sources.list"           
                        echo $passwd | sudo -S bash -c "echo -e 'deb [arch=amd64] https://dl.astralinux.ru/astra/stable/1.8_x86-64/repository-extended/ 1.8_x86-64 main contrib non-free' >> /etc/apt/sources.list"
                        echo $passwd | sudo -S apt update -y
                        echo $passwd | sudo -S apt install astra-update -y
                        echo $passwd | sudo -S astra-update -A -r -T
                        exit_code=$?
                        # Проверка кода завершения и отображение соответствующего сообщения
                            if [ $exit_code -eq 0 ]; then
                                zenity --info --title="Успех" --text="Система успешно обновлена!"
                            else
                                zenity --error --title="Ошибка" --text="Ошибка при установке обновления."
                            fi
                    ) | zenity --progress --pulsate --auto-close
                    else
                    echo ok
                    fi
                fi
            form_data=$(zenity --forms --title="Введите данные" --text="Введите данные:" \
            --add-password="Введите пароль для администратора базы данных" \
            --add-entry="Введите имя базы данных для создания" \
            --add-entry="Введите имя пользователя для базы данных" \
            --add-password="Введите пароль для пользователя созданного выше" \
            --add-entry="Введите имя вашего будущего облачного сервера типа: nextcloud.domain.ru" \
            --add-entry="Введите краткое имя вашего будущего облачного сервера типа: nextcloud" \ )
            # Разбиение строки с данными на отдельные переменные
            password_base=$(echo "$form_data" | awk -F '|' '{print $1}')
            name_base=$(echo "$form_data" | awk -F '|' '{print $2}')
            name_user_base=$(echo "$form_data" | awk -F '|' '{print $3}')
            password_user_base=$(echo "$form_data" | awk -F '|' '{print $4}')
            fqdn=$(echo "$form_data" | awk -F '|' '{print $5}')
            small_fqdn=$(echo "$form_data" | awk -F '|' '{print $6}')
            echo $passwd | sudo -S bash -c "echo '$name_base' >> /home/$USER/Desktop/info.txt"
            echo $passwd | sudo -S bash -c "echo '$name_user_base' >> /home/$USER/Desktop/info.txt"
            echo $passwd | sudo -S bash -c "echo '$password_user_base' >> /home/$USER/Desktop/info.txt"
            zenity --progress --pulsate --title="Установка пакета" --text="Подождите, идет установка..." --auto-close &
            (
            #переименовываем сервер
            echo $passwd | sudo -S hostnamectl set-hostname $fqdn
            echo $passwd | sudo -S sed -i '/^127\.0\.0\.1/d' /etc/hosts
            echo $passwd | sudo -S bash -c "echo '127.0.0.1 $fqdn' >> /etc/hosts"
            #установка базы данных
            echo $passwd | sudo -S apt install mariadb-server -y
            echo $passwd | sudo -S systemctl enable mariadb
            echo $passwd | sudo -S systemctl start mariadb
            #создание базы для nextcloud
            echo $passwd | sudo -S mysql -uroot -p$password_base -e "CREATE DATABASE $name_base DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
            echo $passwd | sudo -S mysql -uroot -p$password_base -e "GRANT ALL PRIVILEGES ON $name_base.* TO $name_user_base@localhost IDENTIFIED BY '$password_user_base';"
            #установка php
            echo $passwd | sudo -S apt install php${PHP_VER}-fpm php${PHP_VER}-common php${PHP_VER}-zip php${PHP_VER}-xml php${PHP_VER}-intl php${PHP_VER}-gd php${PHP_VER}-mysql php${PHP_VER}-mbstring php${PHP_VER}-curl php${PHP_VER}-imagick php${PHP_VER}-gmp php${PHP_VER}-bcmath libmagickcore-6.q16-6-extra -y
            STRING="env[PATH] = /usr/local/bin:/usr/bin:/bin"
            echo $passwd | sudo -S sed -i "s/;$STRING/$STRING/g" /etc/php/"$PHP_VER"/fpm/pool.d/www.conf
            STRING1=";opcache.enable_cli=0"
            STRING1_1=";opcache.enable_cli=1"
            STRING2=";opcache.interned_strings_buffer=8"
            STRING2_2=";opcache.interned_strings_buffer=32"
            STRING3=";opcache.revalidate_freq=2"
            STRING3_1=";opcache.revalidate_freq=1"
            echo $passwd | sudo -S sed -i "s/;$STRING1/$STRING1_1/g" /etc/php/${PHP_VER}/fpm/php.ini
            echo $passwd | sudo -S sed -i "s/;$STRING2/$STRING2_2/g" /etc/php/${PHP_VER}/fpm/php.ini
            echo $passwd | sudo -S sed -i "s/;$STRING3/$STRING3_1/g" /etc/php/${PHP_VER}/fpm/php.ini
            echo $passwd | sudo -S systemctl enable php${PHP_VER}-fpm
            echo $passwd | sudo -S systemctl restart php${PHP_VER}-fpm
            #установка nginx
            echo $passwd | sudo -S apt install nginx firefox -y
            echo $passwd | sudo -S sh -c 'cat > /etc/nginx/sites-enabled/nextcloud.conf <<EOF
server {
    listen 80;
    listen 443 ssl;
    server_name test;

    test0
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/cert.key;

    root /var/www/nextcloud;

    add_header Strict-Transport-Security '\''max-age=31536000; includeSubDomains'\'' always;
    client_max_body_size 10G;
    fastcgi_buffers 64 4K;

    rewrite ^/caldav(.*)$ /remote.php/caldav\$1 redirect;
    rewrite ^/carddav(.*)$ /remote.php/carddav\$1 redirect;
    rewrite ^/webdav(.*)$ /remote.php/webdav\$1 redirect;

    index index.php;
    error_page 403 = /core/templates/403.php;
    error_page 404 = /core/templates/404.php;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~ ^/(data|config|\.ht|db_structure\.xml|README) {
        deny all;
    }

    location ^~ /.well-known {
        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }
        location = /.well-known/webfinger  { return 301 /index.php/.well-known/webfinger; }
        location = /.well-known/nodeinfo  { return 301 /index.php/.well-known/nodeinfo; }
        location ^~ /.well-known{ return 301 /index.php/\$uri; }
        try_files \$uri \$uri/ =404;
    }

    location / {
        rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
        rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
        rewrite ^(/core/doc/[^\/]+/)$ \$1/index.html;
        try_files \$uri \$uri/ index.php;
    }

    location ~ ^(.+?\.php)(/.*)?$ {
        test5
        include fastcgi_params;
        test2
        test3
        fastcgi_param HTTPS on;
        fastcgi_pass unix:/run/php/php'"${PHP_VER}"'-fpm.sock;
    }

    location ~* ^.+\.(jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
        expires modified +30d;
        access_log off;
    }
}
EOF'

        #кромешный ад лучше не смотри\
        scheme='$scheme'
        test0='test0'
        test0_1="if ($scheme = 'http') {"
        test2='test2'
        test2_1='fastcgi_param SCRIPT_FILENAME $document_root$1;'
        test3='test3'
        test3_1='fastcgi_param PATH_INFO $2;'
        test5='test5'
        test5_1='try_files $1 = 404;'
        echo $passwd | sudo -S sed -i "s/server_name test/server_name $fqdn/g" /etc/nginx/sites-enabled/nextcloud.conf
        echo $passwd | sudo -S sed -i "s/$test0/$test0_1/g" /etc/nginx/sites-enabled/nextcloud.conf
        echo $passwd | sudo -S sed -i "s/$test2/$test2_1/g" /etc/nginx/sites-enabled/nextcloud.conf
        echo $passwd | sudo -S sed -i "s/$test3/$test3_1/g" /etc/nginx/sites-enabled/nextcloud.conf
        echo $passwd | sudo -S sed -i "s/$test5/$test5_1/g" /etc/nginx/sites-enabled/nextcloud.conf
        echo $passwd | sudo -S mkdir /etc/nginx/ssl 
        #самоподписанный сертификат
        echo $passwd | sudo -S openssl req -new -x509 -days 1461 -nodes -out /etc/nginx/ssl/cert.pem -keyout /etc/nginx/ssl/cert.key -subj "/C=RU/ST=Rus/L=Rus/O=Astra Linux/OU=IT Department/CN=$fqdn/CN=$small_fqdn"   
        echo $passwd | sudo -S systemctl stop apache2
        echo $passwd | sudo -S systemctl disable apache2
        echo $passwd | sudo -S systemctl restart nginx
        echo $passwd | sudo -S systemctl enable nginx
        echo $passwd | sudo -S apt install unzip -y
        echo $passwd | sudo -S wget https://download.nextcloud.com/server/releases/latest.zip -P /tmp/
        echo $passwd | sudo -S unzip /tmp/latest.zip -d /tmp/
        echo $passwd | sudo -S mv /tmp/nextcloud /var/www
        echo $passwd | sudo -S chown -R www-data:www-data /var/www/nextcloud
        exit_code=$?
        # Проверка кода завершения и отображение соответствующего сообщения
        if [ $exit_code -eq 0 ]; then
            zenity --info --title="Успех" --text="Облачное хранилище успешно установлено"
        else
            zenity --error --title="Ошибка" --text="Ошибка при установке облачного хранилища."
        fi
        ) | zenity --progress --pulsate --auto-close
        $(zenity --info --title="Информация для заполнения" --text="На рабочем столе в файле info.txt лежат данные для заполнения в админин панели nextcloud, которая сейчас откроется." --height=300 --width=400)
        
        firefox -new-tab $fqdn
        else
            zenity --info --text="Неправильный пароль от sudo. Перезапустите скрипт."
            exit 1
        fi

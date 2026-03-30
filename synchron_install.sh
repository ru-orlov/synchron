#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Функция для безопасного выполнения команд с sudo
sudo_run() {
    echo "$passwd" | sudo -S bash -c "$1"
    if [ $? -ne 0 ]; then
        zenity --error --text="Ошибка при выполнении: $1"
        exit 1
    fi
}

# Функция для проверки наличия интернета
check_internet() {
    wget -q --spider http://google.com
    if [ $? -ne 0 ]; then
        zenity --error --text="Нет подключения к интернету. Пожалуйста, проверьте соединение."
        exit 1
    fi
}

# Основная часть скрипта
# Проверка, что пользователь в группе astra-admin
if id -nG | grep -qw "astra-admin"; then
    echo "Пользователь в группе astra-admin"
else
    zenity --info --text="Пользователь не принадлежит группе astra-admin. Необходимо зайти под пользователем с правами администратора."
    exit 1
fi

# Приветствие
zenity --info --text="Вас приветствует программа установки и настройки вашего собственного облачного хранилища Nextcloud!" --height=200 --width=300

# Проверка интернета
check_internet

# Запрос данных с автоматическим определением версии Astra
form_data=$(zenity --forms --title="Введите данные" --text="Введите данные:" \
    --add-password="Введите пароль Администратора" \
    --add-combo="Выберете версию ALSE (выбрана 1.8.x для вашего форка)" \
    --combo-values="1.8.x" \
    --add-combo="Необходимо обновить систему с интернет репозиториев?" \
    --combo-values="Да|Нет")

# Разбор данных
passwd=$(echo "$form_data" | awk -F '|' '{print $1}')
selected_version=$(echo "$form_data" | awk -F '|' '{print $2}')
alse_update=$(echo "$form_data" | awk -F '|' '{print $3}')

# Фиксируем версию PHP для Astra 1.8.x
PHP_VER="8.2"

# Проверка пароля sudo
echo "$passwd" | sudo -Sv >/dev/null 2>&1
if [ $? -eq 0 ]; then

    # Настройка репозиториев и обновление системы (если выбрано)
    if [ "$alse_update" = "Да" ]; then
        (
        # Установка сертификатов
        echo "Настройка репозиториев..."
        sudo_run "apt update -y" #+
        sudo_run "apt install ca-certificates apt-transport-https -y" #+

        # Настройка репозиториев для Astra 1.8
        sudo_run "cat > /etc/apt/sources.list <<EOF
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/repository-main/ 1.8_x86-64 main contrib non-free
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/repository-extended/ 1.8_x86-64 main contrib non-free
EOF"

        sudo_run "apt update -y"

        # Обновление системы
        echo "Обновление системы..."
        sudo_run "apt upgrade -y"

        # Проверка наличия astra-update и выполнение обновления (если есть)
        if apt-cache show astra-update >/dev/null 2>&1; then
            sudo_run "apt install astra-update -y"
            sudo_run "astra-update -A -r -T"
        fi

        ) | zenity --progress --pulsate --auto-close --title="Обновление системы" --text="Настройка репозиториев и обновление системы..."
    fi

    # Запрос данных для базы данных и сервера
    form_data=$(zenity --forms --title="Введите данные" --text="Введите данные для базы данных и сервера:" \
        --add-password="Введите пароль для администратора базы данных (root)" \
        --add-entry="Введите имя базы данных для создания (nextcloud)" \
        --add-entry="Введите имя пользователя для базы данных (nextcloud)" \
        --add-password="Введите пароль для пользователя базы данных" \
        --add-entry="Введите имя вашего будущего облачного сервера (FQDN): nextcloud.domain.ru" \
        --add-entry="Введите краткое имя сервера: nextcloud")

    # Разбиение строки с данными на отдельные переменные
    password_base=$(echo "$form_data" | awk -F '|' '{print $1}')
    name_base=$(echo "$form_data" | awk -F '|' '{print $2}')
    name_user_base=$(echo "$form_data" | awk -F '|' '{print $3}')
    password_user_base=$(echo "$form_data" | awk -F '|' '{print $4}')
    fqdn=$(echo "$form_data" | awk -F '|' '{print $5}')
    small_fqdn=$(echo "$form_data" | awk -F '|' '{print $6}')

    # Установка значений по умолчанию, если поля пустые
    if [ -z "$name_base" ]; then name_base="nextcloud"; fi
    if [ -z "$name_user_base" ]; then name_user_base="nextcloud"; fi

    # Сохранение данных на рабочем столе
    REAL_USER=${SUDO_USER:-$USER}
    DESKTOP_DIR="/home/$REAL_USER/Desktop"
    sudo_run "mkdir -p '$DESKTOP_DIR'"
    sudo_run "echo '=== ДАННЫЕ ДЛЯ УСТАНОВКИ NEXTCLOUD ===' > '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'Имя базы данных: $name_base' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'Пользователь БД: $name_user_base' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'Пароль пользователя БД: $password_user_base' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'URL сервера: $fqdn' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo '' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo '=== ДАННЫЕ ДЛЯ ВХОДА В АДМИНКУ ===' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'Логин администратора: admin' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "echo 'Пароль: (придумайте при первой установке)' >> '$DESKTOP_DIR/info.txt'"
    sudo_run "chmod 600 '$DESKTOP_DIR/info.txt'"

    # Основной процесс установки
    (
        echo "Настройка имени хоста..."
        sudo_run "hostnamectl set-hostname $fqdn"
        sudo_run "sed -i '/^127\.0\.0\.1/d' /etc/hosts"
        sudo_run "echo '127.0.0.1 $fqdn' >> /etc/hosts"

        echo "Установка MariaDB..."
        sudo_run "DEBIAN_FRONTEND=noninteractive apt install mariadb-server -y"
        sudo_run "systemctl enable mariadb"
        sudo_run "systemctl start mariadb"

        echo "Создание базы данных $name_base..."
        sudo_run "mysql -uroot -p$password_base -e \"CREATE DATABASE IF NOT EXISTS $name_base CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;\""
        sudo_run "mysql -uroot -p$password_base -e \"CREATE USER IF NOT EXISTS '$name_user_base'@'localhost' IDENTIFIED BY '$password_user_base';\""
        sudo_run "mysql -uroot -p$password_base -e \"GRANT ALL PRIVILEGES ON $name_base.* TO '$name_user_base'@'localhost';\""
        sudo_run "mysql -uroot -p$password_base -e \"FLUSH PRIVILEGES;\""

        echo "Установка PHP $PHP_VER и модулей..."
        sudo_run "DEBIAN_FRONTEND=noninteractive apt install -y php${PHP_VER}-fpm php${PHP_VER}-common php${PHP_VER}-zip php${PHP_VER}-xml php${PHP_VER}-intl php${PHP_VER}-gd php${PHP_VER}-mysql php${PHP_VER}-mbstring php${PHP_VER}-curl php${PHP_VER}-imagick php${PHP_VER}-gmp php${PHP_VER}-bcmath php${PHP_VER}-redis libmagickcore-6.q16-6-extra -y"

        echo "Настройка PHP-FPM..."
        # Добавляем PATH в конфигурацию FPM
        sudo_run "sed -i 's/^;env\[PATH\]/env[PATH] = \/usr\/local\/bin:\/usr\/bin:\/bin/' /etc/php/${PHP_VER}/fpm/pool.d/www.conf"

        # Настройка php.ini для Nextcloud
        sudo_run "sed -i 's/^memory_limit = .*/memory_limit = 512M/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 16G/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^post_max_size = .*/post_max_size = 16G/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^max_execution_time = .*/max_execution_time = 3600/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^;opcache.enable=.*/opcache.enable=1/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=32/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/' /etc/php/${PHP_VER}/fpm/php.ini"
        sudo_run "sed -i 's/^;opcache.enable_cli=.*/opcache.enable_cli=1/' /etc/php/${PHP_VER}/fpm/php.ini"

        echo "Запуск PHP-FPM..."
        sudo_run "systemctl enable php${PHP_VER}-fpm"
        sudo_run "systemctl restart php${PHP_VER}-fpm"

        echo "Установка Redis..."
        sudo_run "DEBIAN_FRONTEND=noninteractive apt install redis-server -y"
        sudo_run "systemctl enable redis-server"
        sudo_run "systemctl start redis-server"

        echo "Установка Nginx..."
        sudo_run "DEBIAN_FRONTEND=noninteractive apt install nginx firefox unzip curl wget -y"

        echo "Создание SSL сертификата..."
        sudo_run "mkdir -p /etc/nginx/ssl"
        sudo_run "openssl req -new -x509 -days 3650 -nodes -out /etc/nginx/ssl/cert.pem -keyout /etc/nginx/ssl/cert.key -subj \"/C=RU/ST=Moscow/L=Moscow/O=Astra Linux/OU=IT Department/CN=$fqdn/CN=$small_fqdn\""

        echo "Настройка Nginx для Nextcloud..."
        sudo_run "cat > /etc/nginx/sites-available/nextcloud <<'EOF'
upstream php-handler {
    server unix:/run/php/php${PHP_VER}-fpm.sock;
}

server {
    listen 80;
    listen [::]:80;
    server_name $fqdn;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $fqdn;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/cert.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security \"max-age=15768000; includeSubDomains; preload;\" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header X-Robots-Tag \"noindex, nofollow\" always;

    root /var/www/nextcloud;
    client_max_body_size 16G;
    fastcgi_buffers 64 4K;

    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ^~ /apps/ { deny all; }
    location ^~ /build/ { deny all; }
    location ^~ /core/skeleton/ { deny all; }
    location ^~ /l10n/ { deny all; }
    location ^~ /tests/ { deny all; }
    location ^~ /config/ { deny all; }
    location ^~ /data/ { deny all; }

    location / {
        rewrite ^ /index.php;
    }

    location ~ ^\\/(?:build|tests|config|lib|3rdparty|templates|data)\\/ {
        deny all;
    }

    location ~ ^\\/(?:\\.|autotest|occ|issue|indie|db_|console) {
        deny all;
    }

    location ~ \\.php(?:$|\\/) {
        try_files \$fastcgi_script_name =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_pass php-handler;
    }

    location ~* \\.(css|js|svg|gif|png|html|ttf|woff|ico|jpg|jpeg|webp)$ {
        try_files \$uri /index.php\$request_uri;
        add_header Cache-Control \"public, max-age=15778463\";
        expires 6M;
        access_log off;
    }

    location = /.well-known/carddav {
        return 301 \$scheme://\$host/remote.php/dav;
    }
    location = /.well-known/caldav {
        return 301 \$scheme://\$host/remote.php/dav;
    }
}
EOF"

        # Активация конфигурации
        sudo_run "ln -sf /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/"
        sudo_run "rm -f /etc/nginx/sites-enabled/default"

        # Отключение Apache
        sudo_run "systemctl stop apache2 2>/dev/null || true"
        sudo_run "systemctl disable apache2 2>/dev/null || true"

        echo "Скачивание nextcloud (форк Nextcloud)..."
        # Скачивание с вашего репозитория
        sudo_run "wget -O /tmp/nextcloud.zip https://github.com/ru-orlov/nextcloud/archive/refs/heads/main.zip"
        sudo_run "unzip -q /tmp/nextcloud.zip -d /tmp/"
        sudo_run "rm -rf /var/www/nextcloud 2>/dev/null || true"
        sudo_run "mv /tmp/nextcloud-main /var/www/nextcloud"
        sudo_run "rm /tmp/nextcloud.zip"

        # Настройка прав
        echo "Настройка прав доступа..."
        sudo_run "mkdir -p /var/www/nextcloud/data"
        sudo_run "mkdir -p /var/www/nextcloud/config"
        sudo_run "chown -R www-data:www-data /var/www/nextcloud"
        sudo_run "chmod -R 755 /var/www/nextcloud"
        sudo_run "chmod -R 770 /var/www/nextcloud/data"
        sudo_run "chmod -R 770 /var/www/nextcloud/config"

        # Настройка cron для фоновых задач
        sudo_run "echo '*/5 * * * * www-data php -f /var/www/nextcloud/cron.php > /dev/null 2>&1' > /etc/cron.d/nextcloud"

        # Перезапуск сервисов
        echo "Завершение настройки..."
        sudo_run "systemctl restart php${PHP_VER}-fpm"
        sudo_run "systemctl restart nginx"

        # Создание occ алиаса для удобства
        sudo_run "echo 'alias nextcloud-occ=\"sudo -u www-data php /var/www/nextcloud/occ\"' > /etc/profile.d/nextcloud.sh"
        sudo_run "chmod +x /etc/profile.d/nextcloud.sh"

        # Проверка установки
        if [ -f /var/www/nextcloud/occ ]; then
            exit_code=0
        else
            exit_code=1
        fi

    ) | zenity --progress --pulsate --auto-close --title="Установка nextcloud" --text="Установка облачного хранилища nextcloud... Пожалуйста, подождите."

    if [ $? -eq 0 ]; then
        zenity --info --title="Успех" --text="Облачное хранилище nextcloud успешно установлено!\n\nДанные для входа сохранены на рабочем столе в файле info.txt\n\nТеперь вам нужно открыть браузер и завершить установку, создав администратора."

        zenity --info --title="Информация" --text="Сейчас откроется браузер с вашим сервером. Завершите установку:\n1. Создайте учётную запись администратора\n2. Введите данные базы данных (они есть в info.txt)\n3. Нажмите 'Завершить установку'" --height=250 --width=400

        firefox -new-tab "https://$fqdn" 2>/dev/null || firefox -new-tab "http://$fqdn"
    else
        zenity --error --title="Ошибка" --text="Ошибка при установке облачного хранилища. Проверьте журнал ошибок."
        exit 1
    fi

else
    zenity --info --text="Неправильный пароль от sudo. Перезапустите скрипт."
    exit 1
fi
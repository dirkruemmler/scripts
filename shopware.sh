#!/usr/bin/env bash

if [ $# -lt 2 ]
  then
    echo "Not enough or too many arguments supplied"
    exit 1
fi

case $1 in
  install)
    echo "installing $2"

    mkdir -p ~/Sites/sw_$2dev

    composer create-project --no-interaction shopware/production ~/Sites/sw_$2dev

    cd ~/Sites/sw_$2dev
    
    sed -i -e 's;DATABASE_URL=.*$;DATABASE_URL=mysql://root:root@127.0.0.1:3306/sw_'"$2"'dev;' .env
    sed -i -e 's;APP_URL=.*$;APP_URL=https://sw-'"$2"'dev.dr;' .env
    sed -i -e 's;# MAILER_DSN=.*$;MAILER_DSN=smtp://mailhog:1025;' .env
    sed -i -e 's;MAILER_URL=.*$;MAILER_URL=smtp://mailhog:1025;' .env
    sed -i -e "s;APP_ENV=.*$;APP_ENV=dev;" .env
    sed -i -e "s;SHOPWARE_ES_THROW_EXCEPTION=.*$;SHOPWARE_ES_THROW_EXCEPTION=0;" .env
    sed -i -e "s;SHOPWARE_HTTP_CACHE_ENABLED=.*$;SHOPWARE_HTTP_CACHE_ENABLED=0;" .env
    echo "" >> .env
    echo 'COMPOSER_HOME='"$HOME"'/.composer' >> .env
    echo 'SHOPWARE_ADMIN_BUILD_ONLY_EXTENSIONS=1' >> .env
    
    bin/console system:install --basic-setup --create-database --drop-database

    composer config --no-interaction allow-plugins.bamarni/composer-bin-plugin true
    composer config --no-interaction allow-plugins.phpstan/extension-installer true

    composer req --dev shopware/dev-tools phpstan/phpstan phpstan/extension-installer bamarni/composer-bin-plugin phpstan/phpstan-doctrine phpstan/phpstan-phpunit phpstan/phpstan-symfony friendsofphp/php-cs-fixer

    bin/console framework:demodata --env=prod
    bin/console dal:refresh:index

    osascript -e 'display notification "Installation von Shopware abgeschlossen!" with title "Done" subtitle "Shopware installed" sound name "Submarine"'
  ;;

  update)
    echo "updating"

    cd ~/Sites/sw_$2dev

    bin/console system:update:prepare
    composer update
    bin/console system:update:finish

    osascript -e 'display notification "Update von Shopware abgeschlossen!" with title "Done" subtitle "Shopware updated" sound name "Submarine"' 
  ;;

  *)
    echo "don\'t know"
    echo "use 'shopware.sh' install|update version"
  ;;
esac

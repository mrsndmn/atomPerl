 #!/bin/bash

#echo $1;

echo "Копирование";

list=`ls ./../Technosfera-perl/homeworks/ | grep ^$1`

echo -e "\033[1;32m$list\033[0m"

echo -n 'В каталог: '

echo -e "\033[1;33m `pwd` \033[0m"

echo -n "Продолжить? (y/n) "

read item

 case "$item" in
     y|Y)   echo "Копирование..."
            cp -R ./../Technosfera-perl/homeworks/$list ./
        ;;
    *) echo -e "Ok, bye\n"
        ;;
esac


 #!/bin/bash

#echo $1;
sample=$1
# while [$sample = "\n"]
#     do  
#     echo "Print sample:"
#     read $sample
#     echo "$sample"
#     done

echo "Копирование"

list=`ls ./../Technosfera-perl/homeworks/ | grep ^$sample`

echo -e "\033[1;32m$list\033[0m"

echo -n 'В каталог: '

echo -e "\033[1;33m `pwd` \033[0m"

echo -n "Продолжить? (y/n) "

read item

 case "$item" in
     y|Y)   echo "Копирование..."
            cp -R ./../Technosfera-perl/homeworks/$1 ./
        ;;
    *) echo -e "Ok, bye\n"
        ;;
esac

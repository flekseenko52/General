#!/bin/bash

#Для запуска скрипта необходимо указать аргумент - список пользователей
if [ -z "$1" ]; then
    echo "Ошибка: Не указан файл со списком пользователей!"
    exit 1  # Завершаем скрипт с кодом ошибки
fi

#Номер тикета, по которому выполнется задача
read -p "Введите номер, в рамках которого выполняется задача: " number_of_ticket

#Файл со списком пользователей
userlist="$1"

#Дата для истечения пароля
new_date=$(date -d "+90 days" +%Y%m%d%H%M%SZ)

while IFS=';' read -r username name surname email phone pager department
do
    if 
        ipa user-find "$username" > /dev/null 2>&1 
    then
        echo "$username создавался ранее"  >> users_was_created_$number_of_ticket.txt
    else
        password=$(pwgen -1 -y -B 16)
        echo "|login: $username|" "|email: $email|" "|password: $password|" >> login_password_$number_of_ticket.txt
        echo $password | ipa user-add $username --first="$name" --last="$surname" --email="$email" --phone="$phone" --pager="$pager" --orgunit="$(echo $department | xargs)" --password
        ipa user-mod $username --password-expiration $new_date
        ipa group-add-member  группа --users=$username
    fi
done < "$userlist"
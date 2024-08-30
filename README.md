Публикация на IIS  
Создается папка 1C_REPOSITORY в папке публикаций wwwroot, в неё копируются все файлы 

![50 3 wwwroot](https://github.com/user-attachments/assets/7649551b-f97b-4602-b00d-6940f51b0e12)

далее настраивается конфигурационный файл В конфигурационном файле указываем:

•	где находится директория с ИБ Хранилищ

•	где будет лежать html шаблон

•	где будет лежать сам html - файл со списком ИБ Хранилищ

![50 2 Конфигурационный файл](https://github.com/user-attachments/assets/8f34d70f-b4a3-440a-8f87-8f4fd2b98a59)

Добавление приложения в IIS

![50 4 Добавление приложения в IIS](https://github.com/user-attachments/assets/7f0fc0b1-1b00-4cff-bb9c-31d5c35aa59a)

![50 5 Параметры приложения](https://github.com/user-attachments/assets/c991774b-c3bd-42ee-8985-3fa19905ff55)

Перезагрузка службы IIS iisreset

Можно посмотреть результат на момент публикации 

https://serp-debug.github.io/1C_REPOSITORY/

Запуск скрипта из командной строки 

![55 Обязательный параметр](https://github.com/user-attachments/assets/555240f9-36d8-451e-9b7c-aae95cdcd535)




ver:1.0.1.
Исправлена сортировка по атрибуту CreationTime - дате создания 
(раньше сортировка работала по дате изменения)

![Сортировка списка баз](https://github.com/user-attachments/assets/4b786936-88b5-49d3-965a-509fe119ae64)

Доработан внешний вид html- документа – текст выровнен по центру. 

![Центровка](https://github.com/user-attachments/assets/daf3113d-ff78-45cd-a929-b9e95016b20b)

ver:1.0.0.
Публикация на IIS  
Создается папка 1C_REPOSITORY в папке публикаций wwwroot, в неё копируются все файлы 

![50 3 wwwroot](https://github.com/user-attachments/assets/7649551b-f97b-4602-b00d-6940f51b0e12)

далее настраивается конфигурационный файл В конфигурационном файле указываем:

•	где находится директория с ИБ Хранилищ

•	где будет лежать html шаблон

•	где будет лежать сам html - файл со списком ИБ Хранилищ

![55 config](https://github.com/user-attachments/assets/bbcc2170-83a3-43c5-9862-1c6a0a464918)

Добавление приложения в IIS

![50 4 Добавление приложения в IIS](https://github.com/user-attachments/assets/7f0fc0b1-1b00-4cff-bb9c-31d5c35aa59a)

![50 5 Параметры приложения](https://github.com/user-attachments/assets/c991774b-c3bd-42ee-8985-3fa19905ff55)

Перезагрузка службы IIS iisreset

Можно посмотреть результат на момент публикации 
https://serp-debug.github.io/1C_REPOSITORY/

Запуск скрипта из командной строки 
![55 Обязательный параметр](https://github.com/user-attachments/assets/555240f9-36d8-451e-9b7c-aae95cdcd535)


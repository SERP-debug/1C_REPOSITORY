Публикация на IIS  
Создается папка 1C_REPOSITORY в папке публикаций wwwroot, в неё копируются все файлы 

![50 3 wwwroot](https://github.com/user-attachments/assets/7649551b-f97b-4602-b00d-6940f51b0e12)

далее настраивается конфигурационный файл В конфигурационном файле указываем:
•	где находится директория с ИБ Хранилищ
•	где будет лежать html шаблон
•	где будет лежать сам html - файл со списком ИБ Хранилищ

![50 2 Конфигурационный файл](https://github.com/user-attachments/assets/e54346c8-7ea2-4f5d-b742-5a9cb81560a1)

Добавление приложения в IIS

![50 4 Добавление приложения в IIS](https://github.com/user-attachments/assets/7f0fc0b1-1b00-4cff-bb9c-31d5c35aa59a)

![50 5 Параметры приложения](https://github.com/user-attachments/assets/c991774b-c3bd-42ee-8985-3fa19905ff55)

Перезагрузка службы IIS iisreset

![50 6 Рузультат](https://github.com/user-attachments/assets/ebc3156f-1e05-479a-8dba-517aff3db4a3)

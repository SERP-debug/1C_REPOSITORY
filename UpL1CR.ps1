# [CmdletBinding()]

# Логирование
$Logfile = $PSScriptRoot + "\UpL1CR.log"
# Проверка есть ли файл для логирования - если нет то логирования не будет 
if (Test-Path -Path $Logfile) {
    $LogfileExists = $true}
else { 
    $LogfileExists = $false
}   


function WriteLog() {
    #Функция записи Лог-файла 
    Param ([string]$LogString)

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage -Encoding UTF8
}

if ($LogfileExists) {
    WriteLog ("Скрипт запущен”)
}

#Не показывает не критические ошибки 
$ErrorActionPreference = 'SilentlyContinue'
# Проверка считалось ли переменная среды  
if ($null -eq $env:ConfigListRepository) {
    #Если переменная среды не считалось - настройки ищутся в папке рядом со скриптом  
    if ($LogfileExists) {
        WriteLog "Не найдена переменная среды, ищуются настройки в папке рядом со скриптом”
    }
    $PathIniFile        = $PSScriptRoot + "\config.ini" 
    $DescriptionJson    = $PSScriptRoot + "\Description.json"    
    if ((Test-Path -Path $PathIniFile)-and (Test-Path -Path $DescriptionJson)) {
        #Файлы найдены рядом со скриптом
        true}
    else { 
        #Логирование 
        if ($LogfileExists) {
            WriteLog "Скрипт остановлен по ошибке - не найдены файлы рядом со скриптом”
        }
        $ErrorActionPreference = 'Stop'
    }   
} 
else {
    # Считываение пути папки с настройками - из Переменной среды
    $PathIniFile        = $env:ConfigListRepository + "\config.ini"
    $DescriptionJson    = $env:ConfigListRepository + "\Description.json"
    if ((Test-Path -Path $PathIniFile)-and (Test-Path -Path $DescriptionJson)) {
        if ($LogfileExists) {
            WriteLog ("Пути до настроек получены из переменной среды - ” + $PathIniFile + ", " +$DescriptionJson)
        }
    }
    else {#Логирование
        if ($LogfileExists) {
            WriteLog ("Скрипт остановлен по ошибке - не найдены файлы по пути полученному из переменной среды - ”+$PathIniFile + ", " +$DescriptionJson)
        }
        $ErrorActionPreference = 'Stop'
    }  
}

function ApplyTmp() {
    #Применение шаблона к считанному массиву ИБ 
    $ReplaceableText = ""
    $table | ForEach-Object {
    $ReplaceableText += 
        "`n`t`t`t`t<tr onmouseover=""this.classList.add('highlight');"" onmouseout=""this.classList.remove('highlight');"" class="""">`n"+
        "`t`t`t`t`t<td style=""max-width: 50px; font-size:14px"">"+$_.Name+"</td>`n"+
        "`t`t`t`t`t<td style=""white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 50px;""><input type=""text"" class=""SERP"" value=""tcp://vcs/"+$_.Name+""" id="""+$_.Name+""" readonly style=""text-align: left; width: 100%;""></td>`n"+
        "`t`t`t`t`t<td style=""text-align: center; width: 40px;"">`n"+
        "`t`t`t`t`t`t<div class=""tooltip"">`n"+
        "`t`t`t`t`t`t`t<button onclick=""myFunction('"+$_.Name+"','"+$_.Name+"_')"" onmouseout=""outFunc1('"+$_.Name+"_')"">`n"+
        "`t`t`t`t`t`t`t`t<span class=""tooltiptext"" id="""+$_.Name+"_"">Скопировать to clipboard</span>`n"+
        "`t`t`t`t`t`t`t`t`t<svg xmlns=""http://www.w3.org/2000/svg"" width=""12"" height=""12"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2"" stroke-linecap=""round"" stroke-linejoin=""round"" class=""feather feather-copy"">`n"+
        "`t`t`t`t`t`t`t`t`t`t<rect x=""9"" y=""9"" width=""13"" height=""13"" rx=""2"" ry=""2""></rect>`n"+
        "`t`t`t`t`t`t`t`t`t`t<path d=""M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1""></path>`n"+
        "`t`t`t`t`t`t`t`t`t</svg>`n"+
        "`t`t`t`t`t`t`t</button>`n"+  
        "`t`t`t`t`t`t</div>`n"+
        "`t`t`t`t`t</td>`n"+
        "`t`t`t`t`t<td class=""wrappable"" style=""max-width: 120px; font-size:12px"">"+$_.Description+"</td>`n"+
        "`t`t`t`t</tr>`n"
    
    }
    return $ReplaceableText
}

function SendMail($MailBody) {

    #Читаем почтовый настройки 
    $ServerSmtp         = $h.Get_Item("ServerSmtp")
    $Port               = $h.Get_Item("Port")
    $From               = $h.Get_Item("From")
    $To                 = $h.Get_Item("To")
    $Subject            = $h.Get_Item("Subject")
    $User               = $h.Get_Item("User")
    $Pass               = $h.Get_Item("Pass")
     #Формируем данные для отправки
    $mes = New-Object System.Net.Mail.MailMessage   
    $mes.From = $from
    $mes.To.Add($to) 
    $mes.Subject = $subject 
    $mes.IsBodyHTML = $true 
    $mes.Body = $MailBody
    #Создаем экземпляр класса подключения к SMTP серверу 
    $smtp = New-Object Net.Mail.SmtpClient($serverSmtp, $port)
    #Сервер использует SSL 
    $smtp.EnableSSL = $true 
    #Создаем экземпляр класса для авторизации на сервере яндекса
    $smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass);
    #Отправляем письмо, освобождаем память
    $smtp.Send($mes) 
    $att.Dispose()
    
}

#Получение параметров из config.ini
Get-Content $PathIniFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$DirREPOSITORY      = $h.Get_Item("DirREPOSITORY")
$TmpHTML            = $h.Get_Item("TmpHTML")
$ResultHTML         = $h.Get_Item("HTML")

# Чтение списка ИБ из файла - загруженные в прошлый раз  
$beforelist = Import-Clixml .\beforelist.xml

# Загрузка и сортировка папок ИБ 
$bsort = Get-Childitem -Path $DirREPOSITORY -Directory | Sort-Object -Property CreationTime -Descending

# Сравнение массивов, если пустой значит новых репозиториев нет
$Compare = Compare-Object -ReferenceObject $beforelist -DifferenceObject $bsort -Property name 

if (($Compare.count -eq 0) -or ($beforelist.Count -eq 0))
{#Новых репозиториев нет или несчем сравнивать     
}
else {#Есть новые/удаленные репозитории 
    
    $TextREPOSITORY = ""
    foreach ($item in $Compare) {
    if ( $item.SideIndicator -eq "=>")
    {
        # Есть добавленные репозитории 
        $TextREPOSITORY = $TextREPOSITORY + "Новый репозиторий: " + $h.Get_Item("PrefixBase") + $item.name + "<br>`n"
    }
    else
    {
        # Есть удаленные репозитории 
        $TextREPOSITORY = $TextREPOSITORY + "Удален репозиторий: " + $h.Get_Item("PrefixBase") + $item.name + "<br>`n"
    }
    }

    $TextREPOSITORY = "<h2>Здравствуйте!</h2>`n" +
    $TextREPOSITORY +
    "<br><a href="+$h.Get_Item("PathRepos")+">Актуальный список хранилищ конфигураций 1С</a><br>`n" +
    "<h4><br>Не забудьте занести описание новому репозиторию<br></h4>`n" +  
    "<h4>Данное письмо носит информационный харектер. Пожалуйста, не отвечайте на него</h4>`n"  

    SendMail ($TextREPOSITORY)          

}

# Запись в файл состояния списка
$bsort | Export-Clixml .\beforelist.xml  

#Формирование структуры таблицы с Описанием
$table = New-Object System.Data.DataTable
[void]$table.Columns.Add("Name")
[void]$table.Columns.Add("CreationTime")
[void]$table.Columns.Add("Description")

#Заполнение таблицы строками полученными из массива $bsort
foreach ($item in $bsort) {
    [void]$table.Rows.Add($item.Name,$item.CreationTime)
}

#Парсим JSON
$JSON = Get-Content $DescriptionJson -Raw -Encoding UTF8 | ConvertFrom-Json

#Добавление Описаний ИБ для которых задоно 
foreach ($item in $table) {
    foreach ($itemDescr in $JSON.Values) {
            # Условие если описание в json - есть, то оно записывается в Таблицу
            if ($itemDescr.Path -eq $item.Name) {
                $item.Description = $itemDescr.description
            }
    }
}

# Если есть изменения в списке, то обновляем файл с описаниями 
if ($Compare.count -ne 0){
    # $jsonBase = @{}
    $list = New-Object System.Collections.ArrayList
        foreach ($item in $table) {
            # >$Null - чтобы в консоль ничего не выводилось 
            $list.Add(@{"Path"=$item.name;"description"=$item.Description;})>$Null    
        }
    $Description = @{"Values"=$list;}
    #$jsonBase.Add("Data",$customers)
    $Description | ConvertTo-Json -Depth 10 | Out-File $DescriptionJson
}


# Получение текста замены
$ReplaceText = ApplyTmp
# Получение html-шаблона 
$Content = Get-Content $TmpHTML
# Подставка текста замены в шаблон и запись в итоговый файл
$Content.replace(‘<div>anchor</div>’,$ReplaceText)| Out-File -Encoding utf8 $ResultHTML

if ($LogfileExists) {
    WriteLog ("Скрипт выполнен успешно”)
}

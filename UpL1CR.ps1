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
    WriteLog "Скрипт запущен”
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

#Получение параметров из config.ini
Get-Content $PathIniFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$DirREPOSITORY      = $h.Get_Item("DirREPOSITORY")
$TmpHTML            = $h.Get_Item("TmpHTML")
$ResultHTML         = $h.Get_Item("HTML")

# Загрузка и сортировка папок ИБ 
$bsort = Get-Childitem -Path $DirREPOSITORY -Directory | Sort-Object -Property CreationTime -Descending

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

# Полечение текста замены
$ReplaceText = ApplyTmp
# Получение шаблона
$Content = Get-Content $TmpHTML
# Подставка текста замены в шаблон и запись в итоговый файл
$Content.replace(‘<div>anchor</div>’,$ReplaceText)| Out-File -Encoding utf8 $ResultHTML

if ($LogfileExists) {
    WriteLog "Скрипт выполнен успешно”
}

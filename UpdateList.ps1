[CmdletBinding()]

Param (
[Parameter (Mandatory=$true, Position=1)]
[string]$PathIniFile
)

#Получение параметров из config.ini
Get-Content $PathIniFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$DirREPOSITORY = $h.Get_Item("DirREPOSITORY")
$TmpHTML       = $h.Get_Item("TmpHTML")
$ResultHTML    = $h.Get_Item("HTML")

# Загрузка и сортировка папок ИБ 
$bsort = Get-Childitem -Path $DirREPOSITORY -Directory | Sort-Object -Property LastWriteTime -Descending

# Полечение текста замены
$ReplaceText = ApplyTmp
# Получение шаблона
$Content = Get-Content $TmpHTML
# Подставка текста замены в шаблон и запись в итоговый файл
$Content.replace(‘<div>anchor</div>’,$ReplaceText)| Out-File -Encoding utf8 $ResultHTML

function ApplyTmp
{
#Применение шаблона к считанному массиву ИБ 
$ReplaceableText = ""
$bsort | ForEach-Object{
$ReplaceableText += 
    "<div>`n"+
        "<input type=""text"" value="""+"$_"+""" readonly>`n"+
        "<input type=""text"" class=""SERP"" id="""+$_+""" value= ""tcp://vcs/"+"$_"+""" readonly>`n"+""+
        "<button onclick=""copy('"+"$_"+"')""><svg xmlns=""http://www.w3.org/2000/svg"" width=""12"" height=""12"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2"" stroke-linecap=""round"" stroke-linejoin=""round"" class=""feather feather-copy""><rect x=""9"" y=""9"" width=""13"" height=""13"" rx=""2"" ry=""2""></rect><path d=""M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1""></path></svg></button>`n"+
    "<div>`n"
}
    return $ReplaceableText
}

function Get-IniFile 
{  
    param(  
        [parameter(Mandatory = $true)] [string] $filePath  
    )  
    
    $anonymous = "NoSection"
  
    $ini = @{}  
    switch -regex -file $filePath  
    {  
        "^\[(.+)\]$" # Section  
        {  
            $section = $matches[1]  
            $ini[$section] = @{}  
            $CommentCount = 0  
        }  

        "^(;.*)$" # Comment  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $value = $matches[1]  
            $CommentCount = $CommentCount + 1  
            $name = "Comment" + $CommentCount  
            $ini[$section][$name] = $value  
        }   

        "(.+?)\s*=\s*(.*)" # Key  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $name,$value = $matches[1..2]  
            $ini[$section][$name] = $value  
        }  
    }  

    return $ini  
}  
$SettingsIni = Get-IniFile "C:\_PowerShell\List of Catologists in the clipboard\configfile.ini"

$DirREPOSITORY = $SettingsIni.database.DirREPOSITORY
$TmpHTML       = $SettingsIni.database.TmpHTML
$HTML          = $SettingsIni.database.HTML

$bsort = Get-Childitem -Path $DirREPOSITORY -Directory | Sort-Object -Property LastWriteTime -Descending
 
$string = ""
$bsort | ForEach-Object {$string += "<div>`n"+
"<input type=""text"" value="""+"$_"+""" readonly>`n"+
"<input type=""text"" class=""SERP"" id="""+$_+""" value= ""tcp://vcs/"+"$_"+""" readonly>`n"+""+
"<button onclick=""copy('"+"$_"+"')""><svg xmlns=""http://www.w3.org/2000/svg"" width=""12"" height=""12"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2"" stroke-linecap=""round"" stroke-linejoin=""round"" class=""feather feather-copy""><rect x=""9"" y=""9"" width=""13"" height=""13"" rx=""2"" ry=""2""></rect><path d=""M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1""></path></svg></button>`n"+
"<div>`n"}

$Content = Get-Content $TmpHTML
$Content.replace(‘<div>anchor</div>’,$string)| Out-File -Encoding utf8 $HTML
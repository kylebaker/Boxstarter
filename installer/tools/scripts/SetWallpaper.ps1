#https://stackoverflow.com/questions/33551934/script-to-change-wallpaper-in-windows-10

#Function Set-WallPaper($Value)
# {
#    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
#    rundll32.exe user32.dll, UpdatePerUserSystemParameters
# }

 #$image = $pwd.Path + "\wallpaper.jpg"
 #Write-Host $image

 #Set-WallPaper -value $image

 # Set desktop background to black
set-itemproperty -path 'HKCU:\Control Panel\Colors' -name Background -value "0 0 0"
set-itemproperty -path 'HKCU:\Control Panel\Desktop' -name Wallpaper -value ""
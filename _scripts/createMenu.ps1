$jpgFile = Get-ChildItem  -Filter *.jpg | Select-Object -First 1 

$strFileName = $jpgFile.Name

& "bin\ffmpeg.exe" -loop 1 -i $strFileName -r 30 -frames:v 300 -aspect 16:9 -y -target ntsc-dvd "menu.m2v" #-vcodec mpeg2video -b 800k  -s 720x480 "menu.m2v"

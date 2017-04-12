$sourceDir = "_transcoding"
$ffmpeg = "bin\ffmpeg.exe "

$filesToConcat = Get-ChildItem $sourceDir -Filter *.mpg | foreach-object { "$sourceDir\$($_.Name)"}
$filesStr = $filesToConcat -join "|"

& $ffmpeg -i "concat:$filesStr" -c copy -target ntsc-dvd -y "$sourceDir\transcoded-FULL.mpg"
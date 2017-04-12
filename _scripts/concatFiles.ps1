$sourceDir = "_transcoding"
$ffmpeg = "bin\ffmpeg.exe "

$filesToConcat = Get-ChildItem $sourceDir -Filter *.mpg | foreach-object {$_.FullName}
$filesStr = $filesToConcat -join "|"

$concatArgs = "-i ""concat:$filesStr"" -c copy $sourceDir\transcoded-FULL.mpg"
& $ffmpeg -i "concat:$filesStr" -c copy "$sourceDir\transcoded-FULL.mpg"
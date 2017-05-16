param ($outputFolder) 

$outputFolder = Join-Path -Path $outputFolder -childPath '\DVD_OUTPUT'

IF(Test-Path $outputFolder){
    Remove-Item -Recurse -Force $outputFolder 
}
New-Item -ItemType Directory -Force -Path $outputFolder

[Environment]::SetEnvironmentVariable("VIDEO_FORMAT", "NTSC", "User")
& "bin\dvdauthor.exe" -o $outputFolder -x "_transcoding\dvd.xml"
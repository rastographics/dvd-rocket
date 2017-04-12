$strFolderName = "DVD_OUTPUT"
IF(Test-Path $strFolderName){
    Remove-Item -Recurse -Force $strFolderName 
}
[Environment]::SetEnvironmentVariable("VIDEO_FORMAT", "NTSC", "User")
& "bin\dvdauthor.exe" -o $strFolderName -x "_transcoding\dvd.xml"
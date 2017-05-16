Import-Module .\_scripts\OpenFileDialog.psm1 -Force

$inputFile = Get-File "\\dvr-win10\video" "MOV (*.mov)| *.mov"
If(!$inputFile){ 
  exit 
}

$outputFolder = Get-Folder
If(!$outputFolder){
  exit
}

& .\_scripts\transcode.ps1 -inputFile $inputFile
#& .\_scripts\concatFiles.ps1 
& .\_scripts\createDVD.ps1 -outputFolder $outputFolder
Param(
  [string]$inputRoot,
  [int]$segments
)
Import-Module .\_scripts\OpenFileDialog.psm1 -Force

if(!$inputRoot){
  $inputRoot = "\\dvr-win10\video"
  $exists = test-path $inputroot
  if(!$exists){
    $inputRoot = "MyComputer"
  }
}

$inputFile = Get-File $inputRoot "MOV (*.mov)| *.mov"
If(!$inputFile){ 
  exit 
}

$outputFolder = Get-Folder
If(!$outputFolder){
  exit
}

if(!$segments){
  $segments = 4
}

& .\_scripts\transcode.ps1 -inputFile $inputFile -segmentsCount $segments
# & .\_scripts\concatFiles.ps1 
& .\_scripts\createDVD.ps1 -outputFolder $outputFolder
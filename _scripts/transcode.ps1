#$movDirectory = (get-item $PSScriptRoot).Parent
Import-Module .\_scripts\OpenFileDialog.psm1 -Force

$outputDirectory = "_transcoding"
$outputFilePrefix = "transcoded"
$ffmpeg = "bin\ffmpeg.exe"
$ffprobe = "bin\ffprobe.exe"
$isTest = $FALSE

#Split this input file into segments to utilize more CPU power on multi-core machines. (Optimal # on i7 cpu is 5 or 6)
$segmentsCount = 4 

#Set this to 0 to encode the entire file (normal operation)
$onlyEncodeFirstN = 0 # ONLY ENCODE THE FIRST ___ SECONDS OF VIDEO from the input file. 

$enableDenoiseFilter = $TRUE

#**************************************************************************************
# DO NOT CHANGE ANYTHING BELOW THIS LINE




IF(Test-Path $outputDirectory){
    Remove-Item -Recurse -Force $outputDirectory 
}

$strFileName = Open-FileDialog "\\dvr-win10\video" "MOV (*.mov)| *.mov"

If(!$strFileName){ 
  exit 
}

# $inputVideoFile = Get-ChildItem  -Filter *.mov | Select-Object -First 1 

# $strFileName = $inputVideoFile.Name

$probeArgs = " -i ""$strFileName"" -show_format" # | grep duration"



#Transcode times (SD w/ denoise)
# Combined rates of all processes, after running for 30 seconds:
# i5 @ 1 segment = 3.77x
# i5 @ 2 segments = 7.01x (3.41x + 3.6x)
# i5 @ 3 segments = 9.87x (3.2x + 3.34x + 3.33x)
# i5 @ 4 segments = 10x (2.4x + 2.6x + 2.4x + 2.6x)  #after 1 min 2.65 2.7 2.6 2.6 (10.55x)
# i5 @ 5 segments = 9.1x (1.6 1.7 1.9 2.0 1.9)

#i7 3.7, 3.5, 3.8, 3.9 || 3.97, 3.83, 3.65, 3.7
#i7 3.55, 3.18, 3.22, 3.23, 3.18 || 3.63, 3.31, 3.35, 3.29, 3.28
#i7 6 segments @ 30sec = 17.4x (3.15, 2.87, 2.88, 2.75, 2.87, 2.88)
#i7: 6 segments @ 1min = 17.76x (3.26, 2.9, 2.96, 2.83, 2.89, 2.92)
#i7: 7 segments @ 1min = 18.17x (2.55, 2.54, 2.58, 2.55 2.48 2.51 2.96)


# REALTIME TEST - actual time measured for 50min 11sec input file: **************

#** WITH DENOISE
#i7: 6 segments = 17.2x @ 2:55
#i7: 7 segments = 18.02x @ 2:47
#i7: 8 segments = 18.02x @ 2:47

# **DENOISE DISABLED
#i7: 7 segments = 20.76x @ 2:25





#$fileLength = Start-Process $ffprobe $probeArgs -NoNewWindow -Wait
$command = $ffprobe + $probeArgs
$fileProperties = Invoke-Expression $command
$durationObj = @($fileProperties) -match 'duration=*'  #substring this after the equals sign, convert to decimal, and then divide by # of segments
$durationTotal = [decimal]$durationObj[0].Replace("duration=","")
if($onlyEncodeFirstN){
  $durationTotal = $onlyEncodeFirstN
}
$segmentLength = [Math]::Floor($durationTotal / $segmentsCount) 

#The remainder will be added to the last (or first) segment
$durRemainder = $durationTotal % $segmentsCount

#Set the ffmpeg arguments
$baseOptions = ""
# if($isTest){
#   $baseOptions += "-ss 00:10:00 " #skip first n minutes
#   $baseOptions += "-t 00:01:00 " #only process segment of n minutes length
# }
$baseOptions += " -i ""$strFileName"" " #input filename
$baseOptions += " -aspect 16:9 " #aspect ratio
if($enableDenoiseFilter) {
  $baseOptions += " -vf ""hqdn3d=4:4:3:3"" " #denoise filtering
}
$baseOptions += " -target ntsc-dvd " #dvd preset for bitrate, resolution, etc
$baseOptions += " -y " #overwrite output file if it already exists
# if($isTest){
#   $baseOptions += " ""$outputDirectory\test SD.mpg"" " #name of output file
# }

#$options = " -t $segmentLength " + $baseOptions + "  $outputDirectory\captured-transcoded"
$segmentArray = @()

For ($i=0; $i -lt $segmentsCount; $i++){
  $partNumber = $i + 1;
  $segmentStart = $segmentLength * $i
  $segmentDuration = $segmentLength
  if($i -eq ($segmentsCount - 1) -and -not $onlyEncodeFirstN)
  {
    #If this is the last segment, then don't limit the diration (go to end of file)
    $segmentDuration = 0;# $segmentLength + $durRemainder
    #except, if $onlyEncodeFirstN has a value, then make sure we cut off 
  }
  $outputFilePath = "$outputDirectory\$outputFilePrefix-part$partNumber.mpg"
  $segmentOption = " -ss $segmentStart"
  if($segmentDuration){
    $segmentOption += " -t $segmentDuration"
  }  
  $segmentOption += $baseOptions + """$outputFilePath""";
  $segmentArray += @{
    options = $segmentOption
    partNumber = $partNumber
    outputFilePath = $outputFilePath
  }
}


#If the temp directory doesnt exist, create it. (TODO: clean the directory if it does already exist?)
IF(!(Test-Path $outputDirectory)){
  #  Remove-Item -Recurse -Force $strFolderName 
  New-Item $outputDirectory -ItemType Directory
}

$filepath = "$outputDirectory\dvd.xml"
$xml = New-Object System.Xml.XmlTextWriter($filePath,$Null)
$xml.Formatting = "Indented"
$xml.Indentation = "4"
$xml.WriteStartDocument()
$xml.WriteStartElement("dvdauthor")
  $xml.WriteElementString("vmgm","")
  $xml.WriteStartElement("titleset")
    $xml.WriteStartElement("titles")
    $xml.WriteStartElement("video")
      $xml.WriteAttributeString("format","ntsc")
      $xml.WriteAttributeString("aspect","16:9")
    $xml.WriteEndElement()
    $xml.WriteStartElement("pgc")
    $segmentArray | foreach {
      $xml.WriteStartElement("vob")
      $xml.WriteAttributeString("file",$_.get_item("outputFilePath"))
      # if($_.get_item("partNumber") -eq 1){
      #   $xml.WriteAttributeString("chapters","0")
      # }
      $xml.WriteEndElement()
    }
    $xml.WriteEndElement()
  $xml.WriteEndElement()
$xml.WriteEndElement()
$xml.WriteEndDocument()
# $xml.Finalize()
$xml.Flush()
$xml.Close()



$segmentArray | foreach {
  Start-Process $ffmpeg $_.get_item("options")
}

Wait-Process -name "ffmpeg"

# -t '00:00:30' #this will transcode only first 30 seconds of the file
# -minrate 1000k -maxrate 1000k -bufsize 1835k
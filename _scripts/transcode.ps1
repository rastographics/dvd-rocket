#$movDirectory = (get-item $PSScriptRoot).Parent
$outputDirectory = "_transcoding\_temp"
$ffmpeg = "bin\ffmpeg.exe"
$ffprobe = "bin\ffprobe.exe"

$isTest = $FALSE

$enableDenoiseFilter = $TRUE

$inputVideoFile = Get-ChildItem  -Filter *.mov | Select-Object -First 1 

$strFileName = $inputVideoFile.Name

$probeArgs = " -i ""$strFileName"" -show_format" # | grep duration"

#Transcode times (SD w/ denoise)
# Combined rates of all processes, after running for 30 seconds:
# i5 @ 1 segment = 3.77x
# i5 @ 2 segments = 7.01x (3.41x + 3.6x)
# i5 @ 3 segments = 9.87x (3.2x + 3.34x + 3.33x)
# i5 @ 4 segments = 10x (2.4x + 2.6x + 2.4x + 2.6x)  #after 1 min 2.65 2.7 2.6 2.6 (10.55x)
# i5 @ 5 segments = 9.1x (1.6 1.7 1.9 2.0 1.9)

$segmentsCount = 5 #Split this input file into segments to utilize more CPU power on multi-core machines. (Optimal # on i7 cpu is 5 or 6)
#$fileLength = Start-Process $ffprobe $probeArgs -NoNewWindow -Wait
$command = $ffprobe + $probeArgs
$fileProperties = Invoke-Expression $command
$durationObj = @($fileProperties) -match 'duration=*'  #substring this after the equals sign, convert to decimal, and then divide by # of segments
$durationTotal = [decimal]$durationObj[0].Replace("duration=","")
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
  if($i -eq ($segmentsCount - 1))
  {
    $segmentDuration = $segmentLength + $durRemainder
  }
  $segmentOption = "-ss $segmentStart -t $segmentDuration " + $baseOptions + "$outputDirectory\captured-transcoded-part$partNumber.mpg";
  $segmentArray += $segmentOption
}
#2. Create an array of arguments with number of elements that matches the number of segments, each one:
  #A. Seeks to (StartofPrevSegment + Duration): -ss 
  #B. Sets duration to length specified above: -t
  #c: increments the filename by 1: -part2.mpg

#3. Start it up and run Start-Process for every array item

#4. Create a dvdauthor.xml file that has the same number of vob entries as we have number of segments.



# $options = " -t 00:10:00 " + $baseOptions + "  $outputDirectory\captured-transcoded"

# $part1Options = "-ss 00:00:00 " + $options + "-part1.mpg";
# $part2Options = "-ss 00:10:00 " + $options + "-part2.mpg";
# $part3Options = "-ss 00:20:00 " + $options + "-part3.mpg";
# $part4Options = "-ss 00:30:00 " + $options + "-part4.mpg";
# $part5Options = "-ss 00:40:00 " + $options + "-part5.mpg";
# $part6Options = "-ss 00:50:00 " + $options + "-part6.mpg";


#If the temp directory doesnt exist, create it. (TODO: clean the directory if it does already exist?)
IF(!(Test-Path $outputDirectory)){
  #  Remove-Item -Recurse -Force $strFolderName 
  New-Item $outputDirectory -ItemType Directory
}

$segmentArray | foreach {
  Start-Process $ffmpeg $_
}


# If (!$isTest)
# {
#   Start-Process $ffmpeg $part1Options
# Start-Process $ffmpeg $part2Options
# Start-Process $ffmpeg $part3Options
# Start-Process $ffmpeg $part4Options
# Start-Process $ffmpeg $part5Options
# } else {
#   Start-Process $ffmpeg $baseOptions
# }


# -t '00:00:30' #this will transcode only first 30 seconds of the file
# -minrate 1000k -maxrate 1000k -bufsize 1835k
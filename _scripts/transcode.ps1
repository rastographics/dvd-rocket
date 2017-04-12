#$movDirectory = (get-item $PSScriptRoot).Parent
$strTemp = "E:\_transcoding\_temp"
$ffmpegPath = "bin\ffmpeg.exe"
$ffprobePath = "bin\ffprobe.exe"

$isTest = $TRUE

$movFile = Get-ChildItem  -Filter *.mov | Select-Object -First 1 

$strFileName = $movFile.Name

$probeArgs = " -i ""$strFileName"" -show_format" # | grep duration"
# TODO: 
$segmentsCount = 5 #For flexibility the "divisible by" number should be a variable (so we can vary between 4 or 6 processes).
#$fileLength = Start-Process $ffprobePath $probeArgs -NoNewWindow -Wait
$command = $ffprobePath + $probeArgs
$fileProperties = Invoke-Expression $command
$durationStr = @($fileProperties) -match 'duration=*'  #substring this after the equals sign, convert to decimal, and then divide by # of segments
#1. Get the length of the video, and divide by 5. The result will be the length of each segment. (55:00 / 5 = 11:00 each segment)
  #A. First reduce the "length" to be divisible by 5 evenly. Then take the difference and add it onto the last segment. (58:30 - 03:30 = 55:00. 11:00/segment, but last segment is 14:30)

#2. Create an array of arguments with number of elements that matches the number of segments, each one:
  #A. Seeks to (StartofPrevSegment + Duration): -ss 
  #B. Sets duration to length specified above: -t
  #c: increments the filename by 1: -part2.mpg

#3. Start it up and run Start-Process for every array item

#4. Create a dvdauthor.xml file that has the same number of vob entries as we have number of segments.
$baseOptions = ""
if($isTest){
  $baseOptions += "-ss 00:10:00 " #skip first n minutes
  $baseOptions += "-t 00:01:00 " #only process segment of n minutes length
}
$baseOptions += " -i $strFileName " #input filename
$baseOptions += " -aspect 16:9 " #aspect ratio
$baseOptions += " -vf ""hqdn3d=4:4:3:3"" " #denoise filtering
$baseOptions += " -target ntsc-dvd " #dvd preset for bitrate, resolution, etc
$baseOptions += " -y " #overwrite output file if it already exists
if($isTest){
  $baseOptions += " ""$strTemp\test SD.mpg"" " #name of output file
}


$options = " -t 00:10:00 " + $baseOptions + "  $strTemp\captured-transcoded"

$part1Options = "-ss 00:00:00 " + $options + "-part1.mpg";
$part2Options = "-ss 00:10:00 " + $options + "-part2.mpg";
$part3Options = "-ss 00:20:00 " + $options + "-part3.mpg";
$part4Options = "-ss 00:30:00 " + $options + "-part4.mpg";
$part5Options = "-ss 00:40:00 " + $options + "-part5.mpg";
$part6Options = "-ss 00:50:00 " + $options + "-part6.mpg";



IF(!(Test-Path $strTemp)){
  #  Remove-Item -Recurse -Force $strFolderName 
  New-Item $strTemp -ItemType Directory
}

If (!$isTest)
{
  Start-Process $ffmpegPath $part1Options
Start-Process $ffmpegPath $part2Options
Start-Process $ffmpegPath $part3Options
Start-Process $ffmpegPath $part4Options
Start-Process $ffmpegPath $part5Options
} else {
  Start-Process $ffmpegPath $baseOptions
}


# -t '00:00:30' #this will transcode only first 30 seconds of the file
# -minrate 1000k -maxrate 1000k -bufsize 1835k
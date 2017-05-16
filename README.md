# dvd-rocket
Powershell scripts to automate transcoding and authoring DVDs

## My use case
We are recording live video with Wirecast to .mov files (MJPEG codec).

We needed a way to automate the conversion of those recordings to Ready-to-burn DVD files (VIDEO_TS), complete with automatic chapters and menus.

These scripts run with one click.

# Instructions 
1. Copy your .mov file into the root folder.
2. Right-click on `ConvertToDVD.ps1` and choose Run Powershell Script
3. DVD video files will be created in the DVD-OUTPUT folder.



#HOw it works

## Step 1: Transcode
- Transcodes the file sitting in the root folder to dvd-ready mpeg2 file.
- Splits up input file to utilize as much cpu power as possible.

### TODO:
- If more than 1 input file detected, concat them before transcoding. (order by date, oldest first).
- This will allow us to record directly to this folder, and have multiple recordings (like choir special on Sundays) that get merged together.
- Make a chapter point for each input file

## Step 2: Concatenate outputs
Merge all transcoded files together.

TODO: Look into getting rid of this step...dvdauthor is able to handle multiple files just fine?


#TODO:
- Menu creation


#Resources:

[Creating DVD VIdeo with Linux](https://radagast.ca/linux/dvd_authoring/dvd_authoring.html)
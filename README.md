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
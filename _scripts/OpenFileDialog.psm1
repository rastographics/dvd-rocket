Function Get-File($initialDirectory, $filter)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Select video file to convert"
    $OpenFileDialog.initialDirectory = $initialDirectory
    if($filter){
        $OpenFileDialog.filter = $filter    
    }
    
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Function Get-Folder($rootFolder)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.rootfolder = "MyComputer"
    if($rootFolder){
        $OpenFolderDialog.rootfolder = $rootFolder
    }
    $OpenFolderDialog.Description = "Choose folder to save the VIDEO_TS to:"
    $OpenFolderDialog.ShowNewFolderButton = $true
    $OpenFolderDialog.ShowDialog() | Out-Null
    $OpenFolderDialog.SelectedPath
    
}
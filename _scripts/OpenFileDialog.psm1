Function Open-FileDialog($initialDirectory, $filter)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    if($filter){
        $OpenFileDialog.filter = $filter    
    }
    
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}
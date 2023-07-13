######## PARAMETERS
$size_value = '63'
$output_catalog_name = 'barostackgen_output'
$mod_name = 'Max Stack Size'
######## END PARAMETERS

if (Test-Path -Path $output_catalog_name) {
    "Folder $($output_catalog_name) already exists. Delete it and run the script again."
} else {
    New-Item -ItemType Directory $output_catalog_name
    $filelist_path = ".\$($output_catalog_name)\filelist.xml"
    New-Item -Path $filelist_path -Value "<contentpackage name=`"$($mod_name)`"></contentpackage>"
    $filelist = [xml](Get-Content -Path $filelist_path)

    Get-ChildItem -Recurse -Filter *.xml -Exclude Legacy* | ForEach-Object {
        $xml = [xml](Get-Content -Path $_.FullName)
        $nodes = $xml.Items.Item | where {$_.maxstacksize}
        $filename = $_.Name
        $nodes | ForEach-Object {
            $_.maxstacksize = $size_value
        }
        if ($nodes -ne $null) {  
            $output_filepath = ".\$($output_catalog_name)\$($filename)"
            New-Item -Path $output_filepath -Value "<Override></Override>"
            $target = [xml](Get-Content $output_filepath)
            foreach ($node in $nodes) {
                $target.SelectSingleNode('//Override').AppendChild($target.ImportNode($node,$true))
            }
            $target.Save($output_filepath)
            
            $new_filelist_element = $filelist.CreateElement("Item")
            $new_filelist_element.SetAttribute("file", "%ModDir%/$($filename)")
            $filelist.SelectSingleNode('contentpackage').AppendChild($new_filelist_element)
        }
    }
    $filelist.Save($filelist_path)
}
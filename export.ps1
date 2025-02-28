$EXPORT_FILE = $PSScriptRoot + "\export.json";
$EXCLUDE_FILE = $PSScriptRoot + "\exclude.txt";
$jsonDepth = 5;
$packagesSkipped = @();

function alterExport {
    $fileJson = Get-Content -path ${EXPORT_FILE}  -Encoding UTF8
    $data = $fileJson | ConvertFrom-Json -Depth $jsonDepth

    [array]$packages = $data.Sources.Packages | Where-Object {
        if ([System.IO.File]::Exists($EXCLUDE_FILE)) {
            [string[]]$excludePackages = Get-Content -Path $EXCLUDE_FILE | Select-String -NotMatch "^#|^$";

            foreach ($i in $excludePackages) {
                if ($i -in $_.PackageIdentifier) { 
                    $packagesSkipped += $i;
                
                    return $false 
                }
            }
        }
        $true
    }


    $data.Sources[0].Packages = $packages;
    $data | ConvertTo-Json -Depth $jsonDepth | Set-Content $EXPORT_FILE -Encoding UTF8

    if ($packagesSkipped.Count -gt 0) {
        Write-Output "$($packagesSkipped.Count) package(s) skipped:";
        $packagesSkipped | Join-String -Separator ', '
    }

}


Write-Output "Exporting packages";
winget export `
    --accept-source-agreements `
    --disable-interactivity `
    --nowarn `
    -s winget `
    -o $EXPORT_FILE

alterExport;

Write-Output "Exported to: $EXPORT_FILE";
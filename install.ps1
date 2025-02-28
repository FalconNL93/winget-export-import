$EXPORT_DIR = $PSScriptRoot;
$EXPORT_FILE = $PSScriptRoot + "\export.json";

if (![System.IO.File]::Exists($EXPORT_FILE)) {
    Write-Output "Required file 'export.json' not found";
    exit 1;
}

Winget import `
    --disable-interactivity `
    --ignore-unavailable `
    --accept-source-agreements `
    --accept-package-agreements `
    -i $EXPORT_FILE
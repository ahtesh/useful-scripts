$sourceFolder = "$(Agent.BuildDirectory)\$(Build.DefinitionName)\$(Build.BuildNumber)\b"
$zipFileName = "MyBinaryFiles.zip"

# Load the 7-Zip executable path
$7ZipExe = "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
if (-Not (Test-Path $7ZipExe)) {
    Write-Host "7-Zip executable not found. Please make sure 7-Zip is installed."
    exit 1
}

# Specify the files to zip
$filesToZip = @("a.bin", "c.hex")

# Create a "Prod" folder
$prodFolder = Join-Path -Path $sourceFolder -ChildPath "Prod"
New-Item -Path $prodFolder -ItemType Directory -Force

# Move files to the "Prod" folder
$filesToZip | ForEach-Object {
    $sourceFile = Join-Path -Path $sourceFolder -ChildPath $_
    $destinationFile = Join-Path -Path $prodFolder -ChildPath $_
    Move-Item -Path $sourceFile -Destination $destinationFile -Force
}

# Zip the files
if (Test-Path $sourceFolder) {
    try {
        & $7ZipExe a -tzip "$sourceFolder\$zipFileName" "$sourceFolder\*"
        Write-Host "Files zipped successfully."

        # Remove the "Prod" folder
        Remove-Item -Path $prodFolder -Recurse -Force
        Write-Host "Removed $prodFolder"
    } catch {
        Write-Host "Error occurred while zipping files: $_"
        exit 1
    }
} else {
    Write-Host "Source folder not found."
    exit 1
}
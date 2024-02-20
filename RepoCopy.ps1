function Copy-ApplicationPackage {
    param (
        [string[]]$softwareFolders,
        [string[]]$packageNumbers,
        [string[]]$prodPackageFolders,
        [string]$prodPath,
        [string]$livePath,
        [string]$decomPath
    )

    try {
        for ($i = 0; $i -lt $softwareFolders.Count; $i++) {
            $softwareFolder = $softwareFolders[$i]
            $packageNumber = $packageNumbers[$i]
            $prodPackageFolder = $prodPackageFolders[$i]

            # Process 1: Delete existing package from decom inside software folder
            $decomFolder = Join-Path -Path $decomPath -ChildPath $softwareFolder
            if (Test-Path -Path $decomFolder) {
                Remove-Item -Path $decomFolder -Recurse -Force -ErrorAction Stop
                Write-Host "Existing package deleted from $decomFolder"
            }

            # Process 2: Move existing package(s) from live to decom
            $liveFolders = Get-ChildItem -Path $livePath -Directory
            if ($liveFolders) {
                foreach ($folder in $liveFolders) {
                    Move-Item -Path $folder.FullName -Destination $decomPath -Force -ErrorAction Stop
                    Write-Host "Folder moved from $($folder.FullName) to $decomPath"
                }
            } else {
                Write-Host "No folders found in live location to move to decom."
            }

            # Process 3: Copy prod folder content to live location software folder inside the name of package number
            $prodFolder = Join-Path -Path $prodPath -ChildPath "$softwareFolder\$prodPackageFolder"
            $liveFolder = Join-Path -Path $livePath -ChildPath "$softwareFolder\$packageNumber"
            if (-not (Test-Path -Path $liveFolder)) {
                Write-Host "Live folder does not exist. Creating folder..."
                New-Item -Path $liveFolder -ItemType Directory -ErrorAction Stop | Out-Null
            }
            Copy-Item -Path $prodFolder\* -Destination $liveFolder -Recurse -Force -ErrorAction Stop
            Write-Host "New package copied from $prodFolder to $liveFolder"
        }
    }
    catch {
        Write-Host "Error occurred: $_"
    }
}

# Read CSV file
$csvFile = "C:\path\to\your\file.csv"
$data = Import-Csv $csvFile

# Populate arrays from CSV data
$softwareFolders = $data.SoftwareFolder
$packageNumbers = $data.PackageNumber
$prodPackageFolders = $data.ProdPackageFolder

# Define other parameters
$prodPath = "\\server\prod"
$livePath = "\\server\live"
$decomPath = "\\server\decom"

# Call function
Copy-ApplicationPackage -softwareFolders $softwareFolders -packageNumbers $packageNumbers -prodPackageFolders $prodPackageFolders -prodPath $prodPath -livePath $livePath -decomPath $decomPath
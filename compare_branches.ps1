$env:TEMP = $env:TEMP
$thangPath = "$env:TEMP\thang_files.txt"
$mainPath = "$env:TEMP\main_files.txt"

# Read files
$thangFiles = Get-Content $thangPath | Where-Object { $_ -ne '' } | Sort-Object
$mainFiles = Get-Content $mainPath | Where-Object { $_ -ne '' } | Sort-Object

Write-Host "=== Files in thang but NOT in main ==="
$diff = Compare-Object -ReferenceObject $mainFiles -DifferenceObject $thangFiles
$diff | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object { $_.InputObject }

Write-Host ""
Write-Host "=== Files in main but NOT in thang ==="
$diff | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object { $_.InputObject }

if (-not $diff) {
    Write-Host "No differences found - both branches have identical file sets."
}

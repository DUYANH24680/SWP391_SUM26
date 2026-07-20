param([int]$Port = 8081)

Write-Host "Scanning for processes on port $Port..."

try {
    $lines = netstat -ano | Select-String (":$Port\s+.*LISTENING")
    if (-not $lines) {
        Write-Host "No process found on port $Port. Port is free."
        exit 0
    }

    $pidList = $lines | ForEach-Object {
        ($_.ToString().Trim() -split '\s+')[-1]
    } | Sort-Object -Unique

    foreach ($pidVal in $pidList) {
        if ($pidVal -and $pidVal -ne '0') {
            try {
                Stop-Process -Id ([int]$pidVal) -Force -ErrorAction Stop
                Write-Host "Killed PID $pidVal on port $Port"
            } catch {
                Write-Host "Could not kill PID $pidVal - $($PSItem.Message)"
            }
        }
    }

    Start-Sleep -Seconds 2

    $check = netstat -ano | Select-String (":$Port\s+.*LISTENING")
    if ($check) {
        Write-Host "WARNING: Port $Port still in use!"
        exit 1
    } else {
        Write-Host "Port $Port is now free."
        exit 0
    }
} catch {
    Write-Host "Error: $($PSItem.Message)"
    exit 1
}

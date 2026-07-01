$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

$workbook = $excel.Workbooks.Open("C:\Users\admin\Downloads\ProjectTracking SWP (1).xlsx")

foreach ($sheet in $workbook.Sheets) {
    Write-Host "=== SHEET: $($sheet.Name) ==="
    $usedRange = $sheet.UsedRange
    
    for ($row = 1; $row -le $usedRange.Rows.Count; $row++) {
        $rowData = @()
        for ($col = 1; $col -le $usedRange.Columns.Count; $col++) {
            $cell = $sheet.Cells.Item($row, $col)
            $rowData += $cell.Text
        }
        Write-Host ($rowData -join " | ")
    }
    Write-Host ""
}

$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Host "Excel file read complete."

# PowerShell Runner for KEC Academic Evaluation System (R2024)
Set-Location -Path $PSScriptRoot

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  Checking Database Engine (Port 3307)..." -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan

$conn = Get-NetTCPConnection -LocalPort 3307 -State Listen -ErrorAction SilentlyContinue
if (-not $conn) {
    Write-Host "Starting local MySQL Server on port 3307..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\Program Files\MySQL\MySQL Server 26.10\bin\mysqld.exe" `
        -ArgumentList "--datadir=`"$PSScriptRoot\test_db`" --port=3307 --mysqlx-port=33070 --console" `
        -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

Write-Host "[OK] Database engine is active and ready." -ForegroundColor Green
Write-Host "Compiling Java sources..." -ForegroundColor Cyan

javac -cp "lib/*" -d out src\DBConnection.java src\StudentDAO.java src\AcademicDAO.java src\MainApp.java
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Compilation Successful! Launching MainApp..." -ForegroundColor Green
    java -cp "out;lib/*" MainApp
} else {
    Write-Host "[ERROR] Compilation Failed. Check errors above." -ForegroundColor Red
}

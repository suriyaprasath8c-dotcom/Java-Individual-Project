@echo off
title KEC R2024 Academic Evaluation System
cd /d "%~dp0"

echo ====================================================================
echo  Checking Database Engine (Port 3307)...
echo ====================================================================

netstat -ano | findstr /R ":3307 .*LISTENING" >nul
if %ERRORLEVEL% NEQ 0 (
    echo Starting local MySQL Server on port 3307...
    start "" /b "C:\Program Files\MySQL\MySQL Server 26.10\bin\mysqld.exe" --datadir="%~dp0test_db" --port=3307 --mysqlx-port=33070
    timeout /t 3 /nobreak >nul
)

echo [OK] Database engine is active and ready.
echo.
echo ====================================================================
echo  Compiling Java Source Files...
echo ====================================================================
javac -cp "lib/*" -d out src\DBConnection.java src\StudentDAO.java src\AcademicDAO.java src\MainApp.java
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed.
    pause
    exit /b %ERRORLEVEL%
)

echo [OK] Compilation successful.
echo.
echo ====================================================================
echo  Launching KEC R2024 Academic Evaluation System...
echo ====================================================================
java -cp "out;lib/*" MainApp
pause

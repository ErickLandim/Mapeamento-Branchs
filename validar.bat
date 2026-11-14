@echo off
chcp 65001 >nul
setlocal
set PYTHONIOENCODING=utf-8
cd /d "%~dp0"
echo.
python scripts\validate_verbose.py --abrir %*
set RC=%ERRORLEVEL%
echo.
if %RC%==0 (echo [FIM] Validacao concluida com sucesso.) else (echo [FIM] Validacao encontrou divergencias. Codigo %RC%.)
echo.
pause
exit /b %RC%

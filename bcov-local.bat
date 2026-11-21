@echo off
setlocal EnableDelayedExpansion
title BCov - analise local

rem Analisa localmente qualquer projeto Delphi e abre o relatorio.
rem Todas as perguntas tem resposta padrao: aperte Enter para aceitar.

set "AQUI=%~dp0"
set "EXE=%AQUI%tools\bcovscan\bcovscan.exe"

if not exist "%EXE%" (
  where go >nul 2>nul
  if errorlevel 1 (
    echo Nao achei o bcovscan.exe e o Go nao esta instalado para compilar.
    echo Instale o Go ^(https://go.dev/dl^) ou copie o bcovscan.exe para tools\bcovscan\.
    pause
    exit /b 1
  )
  echo Compilando o bcovscan...
  pushd "%AQUI%tools\bcovscan"
  go build -o bcovscan.exe .
  if errorlevel 1 (
    popd
    echo Falhou ao compilar.
    pause
    exit /b 1
  )
  popd
)

echo.
echo === BCov: analise local ===
echo.
set "RAIZ="
set /p "RAIZ=Pasta do projeto [%CD%]: "
if "!RAIZ!"=="" set "RAIZ=%CD%"
set "RAIZ=!RAIZ:"=!"

set "SRC="
set /p "SRC=Pasta do codigo de producao, relativa ao projeto [src]: "
if "!SRC!"=="" set "SRC=src"

set "TESTES="
set /p "TESTES=Pasta dos testes, relativa ao projeto [tests]: "
if "!TESTES!"=="" set "TESTES=tests"

set "IGN="
set /p "IGN=Ignorar (extensao .dfm, pasta legado/ ou padrao; varios separados por virgula) [nada]: "

echo.
echo Para olhar so uma parte, preencha abaixo (Enter deixa tudo):
set "UNIT="
set /p "UNIT=  Nome da unit (ex.: uRegras): "
set "CLASSE="
set /p "CLASSE=  Classe (ex.: TPedido): "
set "METODO="
set /p "METODO=  Nome do metodo (ex.: Confirmar): "
set "LINHA="
set /p "LINHA=  Linha dentro do metodo: "

echo.
set "MODO=tudo"
set "BASE="
set /p "DIFF=So o que mudou em relacao a uma branch? (s/N): "
if /i "!DIFF!"=="s" (
  set "MODO=diff"
  set /p "BASE=  Branch base [main]: "
  if "!BASE!"=="" set "BASE=main"
)

set "SAIDA=!RAIZ!\.bcov\local"
set ARGS=run --root "!RAIZ!" --src "!SRC!" --tests "!TESTES!" --modo !MODO! --out "!SAIDA!"
if not "!BASE!"=="" set ARGS=!ARGS! --base "!BASE!"
if not "!UNIT!"=="" set ARGS=!ARGS! --unit "!UNIT!"
if not "!CLASSE!"=="" set ARGS=!ARGS! --class "!CLASSE!"
if not "!METODO!"=="" set ARGS=!ARGS! --method "!METODO!"
if not "!LINHA!"=="" set ARGS=!ARGS! --line !LINHA!
if not "!IGN!"=="" (
  for %%R in (!IGN!) do set ARGS=!ARGS! --ignorar "%%R"
)

echo.
echo Rodando: bcovscan !ARGS!
echo.
chcp 65001 >nul
"%EXE%" !ARGS!
set "RC=!ERRORLEVEL!"

echo.
if exist "!SAIDA!\relatorio.html" (
  echo Abrindo o relatorio...
  start "" "!SAIDA!\relatorio.html"
) else (
  echo O relatorio nao foi gerado. Veja a mensagem acima.
)
pause
exit /b !RC!

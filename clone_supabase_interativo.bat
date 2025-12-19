@echo off
title Clone Completo do Supabase - Interativo
color 0A

echo ================================================
echo       CLONE COMPLETO DO SUPABASE - INTERATIVO
echo ================================================
echo.

:: Perguntar PROJETO ORIGEM
set /p ORIGEM=Digite o PROJECT_ID de ORIGEM (que será clonado): 

:: Perguntar PROJETO DESTINO
set /p DESTINO=Digite o PROJECT_ID de DESTINO (que vai receber o clone): 

:: Perguntar se deseja limpar destino
set /p APAGAR=Deseja APAGAR/LIMPAR o projeto de destino antes? (sim/nao): 

:: Gerar pasta com data
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
   set DD=%%a
   set MM=%%b
   set YY=%%c
)
set OUTPUT_FOLDER=backup_%YY%%MM%%DD%

echo Criando pasta %OUTPUT_FOLDER%...
mkdir %OUTPUT_FOLDER%
echo.

:: ==============================
:: LOGIN
:: ==============================
echo [1/7] Efetuando login...
supabase login
IF %ERRORLEVEL% NEQ 0 (
    echo Erro no login. Abortando.
    pause
    exit /b
)
echo Login OK.
echo.

:: ==============================
:: LINKAR PROJETO ORIGEM
:: ==============================
echo [2/7] Conectando ao projeto origem %ORIGEM% ...
supabase link --project-ref %ORIGEM%
IF %ERRORLEVEL% NEQ 0 (
    echo Erro ao conectar a origem. Abortando.
    pause
    exit /b
)
echo Origem OK.
echo.

:: ==============================
:: BACKUP DO BANCO
:: ==============================
echo [3/7] Criando backup completo do banco origem...
supabase db dump -f %OUTPUT_FOLDER%\backup.sql
echo Backup do banco criado.
echo.

echo [4/7] Criando backup do schema origem...
supabase db dump -s public -f %OUTPUT_FOLDER%\schema.sql
echo Schema criado.
echo.

:: ==============================
:: BACKUP DO STORAGE
:: ==============================
echo Listando buckets...
supabase storage list-buckets > %OUTPUT_FOLDER%\buckets.txt

echo.
echo Buckets detectados:
type %OUTPUT_FOLDER%\buckets.txt
echo.

echo Iniciando download dos buckets...
for /f %%B in (%OUTPUT_FOLDER%\buckets.txt) do (
    echo Baixando bucket: %%B
    supabase storage download %%B "%OUTPUT_FOLDER%\storage_%%B"
)
echo Storage baixado.
echo.

:: ==============================
:: PERGUNTA SOBRE LIMPAR DESTINO
:: ==============================
if "%APAGAR%"=="sim" (
    echo Limpando destino %DESTINO% completamente...
    :: Conectar destino
    supabase link --project-ref %DESTINO%

    :: DROPAR TODAS AS TABELAS DO DESTINO
    echo drop schema public cascade; create schema public; > %OUTPUT_FOLDER%\reset.sql
    psql -h db.%DESTINO%.supabase.co -U postgres -d postgres -f %OUTPUT_FOLDER%\reset.sql

    echo Destino limpo!
) else (
    echo Continuando sem limpar destino.
)

echo.

:: ==============================
:: RESTAURAR BANCO DE DADOS NO DESTINO
:: ==============================
echo [5/7] Restaurando banco no destino %DESTINO%...
psql -h db.%DESTINO%.supabase.co -U postgres -d postgres -f %OUTPUT_FOLDER%\backup.sql
echo Banco restaurado.
echo.

:: ==============================
:: ENVIAR STORAGE PARA O DESTINO
:: ==============================
echo [6/7] Enviando storage para destino %DESTINO%...

:: Reconectar destino
supabase link --project-ref %DESTINO%

for /f %%B in (%OUTPUT_FOLDER%\buckets.txt) do (
    echo Subindo bucket: %%B
    supabase storage upload %%B "%OUTPUT_FOLDER%\storage_%%B" --recursive
)

echo Storage enviado.
echo.

:: ==============================
:: ZIP FINAL
:: ==============================
echo [7/7] Compactando backup...
powershell Compress-Archive -Path %OUTPUT_FOLDER% -DestinationPath %OUTPUT_FOLDER%.zip -Force

echo.
echo ===================================================
echo    CLONE CONCLUÍDO COM SUCESSO!
echo    Origem:  %ORIGEM%
echo    Destino: %DESTINO%
echo    Backup salvo na pasta: %OUTPUT_FOLDER%
echo ===================================================
pause
exit /b

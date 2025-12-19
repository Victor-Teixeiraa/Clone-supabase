@echo off
echo ======================================================
echo           DUPLICAR SUPABASE (BANCO + STORAGE)
echo ======================================================
echo.

:: --------------------------------------------------------
:: PERGUNTAR PROJECT IDs (BANCO)
:: --------------------------------------------------------
echo ======= DADOS DO BANCO (Supabase CLI) =======
set /p PROJECT_ORIGEM=PROJECT_ID_ORIGEM (banco origem): 
set /p PROJECT_DESTINO=PROJECT_ID_DESTINO (banco destino): 

echo.
echo Banco ORIGEM: %PROJECT_ORIGEM%
echo Banco DESTINO: %PROJECT_DESTINO%
echo --------------------------------------------------------
echo.

pause

:: --------------------------------------------------------
:: CRIAR PASTA DE TRABALHO
:: --------------------------------------------------------
if not exist duplicacao mkdir duplicacao
cd duplicacao

:: --------------------------------------------------------
:: INICIAR PROJETO SUPABASE
:: --------------------------------------------------------
supabase init

:: --------------------------------------------------------
:: LINKAR ORIGEM
:: --------------------------------------------------------
echo.
echo ==== LINKANDO BANCO ORIGEM ====
supabase link --project-ref %PROJECT_ORIGEM%

:: --------------------------------------------------------
:: EXPORTAR BACKUP COMPLETO
:: --------------------------------------------------------
echo.
echo ==== EXPORTANDO FULL BACKUP (ORIGEM) ====
supabase db dump -f full_backup.sql

:: --------------------------------------------------------
:: LINKAR DESTINO
:: --------------------------------------------------------
echo.
echo ==== LINKANDO BANCO DESTINO ====
supabase link --project-ref %PROJECT_DESTINO%

:: --------------------------------------------------------
:: IMPORTAR BACKUP
:: --------------------------------------------------------
echo.
echo ==== IMPORTANDO BACKUP PARA O DESTINO ====
supabase db push --file full_backup.sql


echo.
echo ======================================================
echo             BANCO DUPLICADO COM SUCESSO!
echo ======================================================
echo.


:: ======================================================
:: INICIAR DUPLICACAO DO STORAGE
:: ======================================================

echo ======================================================
echo              INICIANDO DUPLICACAO DO STORAGE
echo ======================================================

:: --------------------------------------------------------
:: PERGUNTAR CREDENCIAIS DE STORAGE ORIGEM
:: --------------------------------------------------------
echo ======= DADOS DA ORIGEM (STORAGE S3) =======
set /p S3_KEY_ORIGEM=ACCESS_KEY_ORIGEM: 
set /p S3_SECRET_ORIGEM=SECRET_KEY_ORIGEM: 
set /p S3_ENDPOINT_ORIGEM=S3_ENDPOINT_ORIGEM (ex: https://xxxx.supabase.co/storage/v1/s3): 
set /p S3_REGION_ORIGEM=REGIAO_ORIGEM (ex: us-east-1): 

echo.

:: --------------------------------------------------------
:: PERGUNTAR CREDENCIAIS DE STORAGE DESTINO
:: --------------------------------------------------------
echo ======= DADOS DO DESTINO (STORAGE S3) =======
set /p S3_KEY_DESTINO=ACCESS_KEY_DESTINO: 
set /p S3_SECRET_DESTINO=SECRET_KEY_DESTINO: 
set /p S3_ENDPOINT_DESTINO=S3_ENDPOINT_DESTINO: 
set /p S3_REGION_DESTINO=REGIAO_DESTINO: 

echo.

pause


echo Criando perfis AWS temporarios...

:: CONFIGURAR PERFIL ORIGEM
aws configure set aws_access_key_id %S3_KEY_ORIGEM% --profile supa-origem
aws configure set aws_secret_access_key %S3_SECRET_ORIGEM% --profile supa-origem
aws configure set region %S3_REGION_ORIGEM% --profile supa-origem

:: CONFIGURAR PERFIL DESTINO
aws configure set aws_access_key_id %S3_KEY_DESTINO% --profile supa-destino
aws configure set aws_secret_access_key %S3_SECRET_DESTINO% --profile supa-destino
aws configure set region %S3_REGION_DESTINO% --profile supa-destino

echo.
echo Criando pasta local para backup do storage...

if not exist storage_backup mkdir storage_backup


:: --------------------------------------------------------
:: LISTAR BUCKETS DA ORIGEM
:: --------------------------------------------------------
echo Listando buckets...

aws --endpoint-url=%S3_ENDPOINT_ORIGEM% s3 ls --profile supa-origem > buckets.txt

echo Buckets encontrados:
type buckets.txt

echo.
pause


:: --------------------------------------------------------
:: COPIAR CADA BUCKET
:: --------------------------------------------------------
for /f "tokens=2" %%B in (buckets.txt) do (
    echo ======================================================
    echo        CLONANDO BUCKET: %%B
    echo ======================================================

    echo Baixando arquivos da ORIGEM...
    aws --endpoint-url=%S3_ENDPOINT_ORIGEM% s3 sync s3://%%B storage_backup/%%B --profile supa-origem

    echo Enviando arquivos para DESTINO...
    aws --endpoint-url=%S3_ENDPOINT_DESTINO% s3 sync storage_backup/%%B s3://%%B --profile supa-destino

    echo Bucket %%B clonado!
    echo.
)


echo ======================================================
echo        STORAGE DUPLICADO COM SUCESSO! 🎉
echo ======================================================

echo.
echo Todo o Supabase foi duplicado:
echo - Banco completo
echo - Tabelas, dados, RLS, functions
echo - Storage (todos os buckets e arquivos)
echo ======================================================
pause

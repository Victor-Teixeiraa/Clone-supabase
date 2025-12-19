@echo off
echo ================================================
echo      CLONAR STORAGE DO SUPABASE (BUCKETS)
echo ================================================
echo.

:: --------------------------------------
:: PERGUNTAR INFORMACOES DA ORIGEM
:: --------------------------------------
echo ======= DADOS DO PROJETO ORIGEM =======
set /p PROJECT_ORIGEM=PROJECT_ID_ORIGEM: 
set /p S3_KEY_ORIGEM=ACCESS_KEY_ORIGEM: 
set /p S3_SECRET_ORIGEM=SECRET_KEY_ORIGEM: 
set /p S3_ENDPOINT_ORIGEM=S3_ENDPOINT_ORIGEM (ex: https://xxxxx.supabase.co/storage/v1/s3): 
set /p S3_REGION_ORIGEM=REGIAO_ORIGEM (ex: us-east-1): 

echo.

:: --------------------------------------
:: PERGUNTAR INFORMACOES DO DESTINO
:: --------------------------------------
echo ======= DADOS DO PROJETO DESTINO =======
set /p PROJECT_DESTINO=PROJECT_ID_DESTINO: 
set /p S3_KEY_DESTINO=ACCESS_KEY_DESTINO: 
set /p S3_SECRET_DESTINO=SECRET_KEY_DESTINO: 
set /p S3_ENDPOINT_DESTINO=S3_ENDPOINT_DESTINO: 
set /p S3_REGION_DESTINO=REGIAO_DESTINO: 

echo.

pause

echo.
echo Criando perfis temporarios no AWS CLI...
echo.

:: Criar perfis AWS CLI para ORIGEM
aws configure set aws_access_key_id %S3_KEY_ORIGEM% --profile supa-origem
aws configure set aws_secret_access_key %S3_SECRET_ORIGEM% --profile supa-origem
aws configure set region %S3_REGION_ORIGEM% --profile supa-origem

:: Criar perfis AWS CLI para DESTINO
aws configure set aws_access_key_id %S3_KEY_DESTINO% --profile supa-destino
aws configure set aws_secret_access_key %S3_SECRET_DESTINO% --profile supa-destino
aws configure set region %S3_REGION_DESTINO% --profile supa-destino


:: --------------------------------------
:: CRIAR PASTA LOCAL TEMPORÁRIA
:: --------------------------------------
echo Criando pasta local de backup...
if not exist storage_backup mkdir storage_backup

echo.

:: --------------------------------------
:: LISTAR BUCKETS DA ORIGEM
:: --------------------------------------
echo Listando buckets da origem...

aws --endpoint-url=%S3_ENDPOINT_ORIGEM% s3 ls --profile supa-origem > buckets.txt

echo Os buckets encontrados foram:
type buckets.txt

echo.
pause

:: --------------------------------------
:: CLONAR CADA BUCKET
:: --------------------------------------
echo Iniciando clonagem bucket por bucket...
echo.

for /f "tokens=2" %%B in (buckets.txt) do (
    echo ================================================
    echo Clonando bucket: %%B
    echo ================================================
    
    echo Baixando da ORIGEM...
    aws --endpoint-url=%S3_ENDPOINT_ORIGEM% s3 sync s3://%%B storage_backup/%%B --profile supa-origem

    echo Enviando para o DESTINO...
    aws --endpoint-url=%S3_ENDPOINT_DES

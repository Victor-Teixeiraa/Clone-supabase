💻 Clone Supabase (Script de Automação .bat)
Este projeto é um utilitário escrito em Windows Batch Script (.bat) projetado para automatizar interações com o ecossistema Supabase. Ele facilita a execução de tarefas repetitivas [como clonar o banco de dados / configurar ambiente local / realizar backups] diretamente do Prompt de Comando do Windows, sem a necessidade de configurações manuais complexas.

⚡ Funcionalidades
Automação: Executa sequências de comandos do Supabase CLI ou chamadas de API automaticamente.

Facilidade de Uso: Interface simples via menu no terminal ou execução direta.

Portátil: Não requer instalação de dependências pesadas (Node/Python), apenas as ferramentas nativas e a CLI.

[Insira aqui sua função principal]: Ex: Clona tabelas de produção para local em um comando.

⚙️ Pré-requisitos
Para que o script funcione corretamente no seu ambiente Windows, você precisa ter instalado:

Windows 10 ou 11.

Supabase CLI (Necessário se o script usa comandos supabase).

Instale via Scoop: scoop bucket add supabase https://github.com/supabase/scoop-bucket.git && scoop install supabase

Docker Desktop (Se o script rodar instâncias locais).

cURL (Geralmente já vem no Windows, usado para requisições API).

🚀 Como Configurar
Clone este repositório (ou baixe o arquivo .bat):

DOS

git clone https://github.com/seu-usuario/clone-supabase.git
cd clone-supabase
Configuração de Credenciais:

Edite o arquivo config.bat (ou crie um se indicado) para definir suas variáveis de ambiente, para não precisar digitá-las toda vez:

DOS

:: Exemplo de configuração dentro do script ou arquivo separado
SET SUPABASE_ACCESS_TOKEN=seu_token_aqui
SET PROJECT_REF=seu_project_id_aqui
SET DB_PASSWORD=sua_senha_banco
🖥️ Como Usar
Abra a pasta do projeto.

Você pode clicar duas vezes no arquivo clone-supabase.bat ou executá-lo via terminal:

DOS

.\clone-supabase.bat
Exemplos de Comandos Suportados
(Edite esta seção conforme o que seu script faz)

Opção 1: Iniciar ambiente local.

Opção 2: Baixar schema do projeto remoto.

Opção 3: Resetar banco de dados.

⚠️ Solução de Problemas Comuns
Erro "comando não reconhecido": Certifique-se de que o Docker e o Supabase CLI estão nas Variáveis de Ambiente (PATH) do Windows.

Permissão Negada: Tente executar o prompt de comando (CMD) ou PowerShell como Administrador.

Docker não roda: Verifique se o Docker Desktop está aberto e com o status "Running".

🛠️ Estrutura do Script
O arquivo principal clone-supabase.bat opera da seguinte forma:

Verifica as variáveis de ambiente.

Testa a conexão com o Docker/Internet.

Executa a lógica de [Backup / Clone / Sync].

Gera logs de operação na pasta ./logs.

🤝 Contribuição
Contribuições são bem-vindas, especialmente para portar funcionalidades para PowerShell (.ps1) ou Shell Script (.sh) para Linux/Mac.

Fork o projeto.

Crie sua feature branch (git checkout -b feature/novo-comando).

Commit suas mudanças (git commit -m 'Add: novo comando de backup').

Push para a branch (git push origin feature/novo-comando).

Abra um Pull Request.

📝 Licença
Distribuído sob a licença MIT. Veja LICENSE para mais informações.

O que você acha deste formato?
Como projetos em .bat geralmente interagem com outras ferramentas, você gostaria que eu criasse um esqueleto do código .bat para validar se o Docker está rodando ou para fazer um menu de seleção simples?

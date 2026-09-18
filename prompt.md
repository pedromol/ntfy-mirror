Você tem acesso completo ao repositório message-mirror (Flutter + Kotlin) que hoje faz POST das notificações/SMS para um endpoint HTTP configurado pelo usuário, sem suporte a autenticação.

Implemente a funcionalidade “Optional auth headers” descrita no roadmap do projeto, permitindo que o usuário configure autenticação para o endpoint HTTP. Requisitos:

A cada etapa realizada, descoberta feita ou problema encontrado, MUST escrever no final do arquivo prompt.md
NAO APAGUE O CONTEÚDO ORIGINAL!!
NAO APAGUE O CONTEÚDO ORIGINAL!!

Funcionalidade
Tipos de autenticação suportados

Nenhum (comportamento atual)

Bearer token

API key (header customizado)

Basic auth (usuário + senha)

Armazenamento seguro

Use EncryptedDataStore / Android Keystore ou mecanismo já usado no projeto para guardar:

bearer token

API key + nome do header

usuário e senha do Basic

Não logar nem expor esses valores em texto claro.

Envio nas requisições HTTP

No código Dart que faz o POST (função que envia notificações/SMS para o endpoint):

Se Nenhum: manter comportamento atual.

Se Bearer: adicionar header
Authorization: Bearer <token>

Se API key: adicionar header customizado, ex.:
<Header-Name>: <API-Key>
(permitir configurar nome do header e valor).

Se Basic: adicionar header
Authorization: Basic <base64(usuario:senha)>

Garantir que isso seja aplicado em todas as requisições HTTP de envio de notificações/SMS.

UI “linda” e intuitiva

Adicionar uma seção “Autenticação HTTP” na tela de configuração do endpoint.

UX sugerida:

Dropdown/SegmentedButton para escolher o tipo: Nenhum | Bearer | API key | Basic.

Campos dinâmicos conforme a escolha:

Bearer: campo “Token”.

API key: campos “Nome do header” e “Valor da chave”.

Basic: campos “Usuário” e “Senha”.

Ícones de “olho” para mostrar/ocultar tokens/senhas.

Validação básica (ex.: não permitir salvar sem token/chave/credenciais quando um tipo com auth estiver selecionado).

Manter o estilo visual já usado no app (tema, cores, tipografia), mas caprichar em:

espaçamento

hierarquia visual (títulos, descrições curtas)

estados de erro/sucesso claros.

Compatibilidade

Manter compatibilidade com configurações antigas:

Se o usuário já tinha endpoint configurado e não tem auth, deve continuar funcionando como “Nenhum”.

Não quebrar nenhum fluxo existente de envio de notificações/SMS.

Testes e robustez

Garantir que:

requisições com auth funcionem corretamente (pode adicionar logs internos opcionais, sem expor segredos).

falhas de autenticação (401/403) sejam tratadas de forma clara (ex.: mensagem de “Autenticação falhou – verifique suas credenciais”).

Manter a lógica de retry/backoff já existente, apenas passando os headers adicionais.

Entregáveis
Código Dart atualizado:

Modelos/settings para os novos campos de auth.

UI de configuração com os campos dinâmicos.

Lógica de envio HTTP incluindo os headers de autenticação.

Se necessário, pequenos ajustes em Kotlin (ex.: para armazenamento seguro), mas mantendo a lógica principal em Dart.

Instruções curtas no README (ou em um arquivo AUTH.md) explicando:

como configurar auth no app

exemplos de uso com ntfy self-hosted (Bearer/Basic).

Objetivo final: o usuário poder apontar o app para um ntfy self-hosted com autenticação (ou qualquer webhook protegido) e configurar de forma simples, segura e visualmente agradável o tipo de auth e suas credenciais.

Quando estiver 100% concluído, diga somente TASK_IS_DONE
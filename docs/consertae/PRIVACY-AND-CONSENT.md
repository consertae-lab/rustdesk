# Privacidade e consentimento — especificação pendente

**Status:** minuta de preparação. Não anunciar como política pública definitiva antes de validar o comportamento do cliente e as operações do servidor.

O cliente Consertaê Suporte Remoto destina-se a atendimento técnico assistido, com solicitação de consentimento da pessoa responsável pelo equipamento. O código configura servidores de intermediação e relay em `remote.consertae.tec.br`. A utilização dessas funções pode transmitir metadados de conexão e, quando necessário, tráfego da sessão pela infraestrutura da Consertaê.

## Condutas esperadas — a testar no executável
- Aprovação explícita e revogável para cada sessão.
- Encerramento visível e imediato de uma sessão pelo usuário.
- As configurações de código incluem `approve-mode=click`, `verification-method=use-temporary-password`, e bloqueio de alteração da senha permanente. Isso **não substitui teste real**, especialmente em instalações ou reinicializações.
- Acesso não assistido, transferência de arquivos e outras funcionalidades dependem de avaliação específica de consentimento.
- Não presumir ausência de telemetria, logs, analytics ou compartilhamento com terceiros sem inspeção dinâmica de rede.

## Pendências antes de publicar política definitiva
1. Nomear controlador e contato para questões de privacidade.
2. Auditar dados registrados por HBBS/HBBR, aplicativo, Windows e serviços de diagnóstico.
3. Definir finalidades, bases legais, retenção, acesso, exclusão e proteção dos registros.
4. Mapear chamadas de rede a terceiros e serviços de atualização, analytics ou crash.
5. Validar telas de autorização, cancelamento e encerramento, em Windows limpo.
6. Publicar política revisada no site de download e na documentação do projeto.

Nunca ocultar conexões, habilitar senha persistente sem autorização específica ou orientar clientes a desativar o Windows Defender.

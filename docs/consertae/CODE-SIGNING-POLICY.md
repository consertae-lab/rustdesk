# Code signing policy — Consertaê Suporte Remoto

**Estado:** proposta para candidatura ao SignPath Foundation. A Consertaê **ainda não recebeu certificado SignPath** e **não possui release assinada** neste repositório.

## Projeto e fonte
- Nome: Consertaê Suporte Remoto, baseado em RustDesk OSS.
- Repositório: https://github.com/consertae-lab/rustdesk (fork público do RustDesk).
- Upstream: https://github.com/rustdesk/rustdesk; AGPL-3.0 preservada em `LICENCE`.
- Binários existentes em `https://suporte.consertae.tec.br` não foram assinados pelo SignPath Foundation.
- Fonte e manifesto 1.4.9: `docs/SOURCE-PROVENANCE.md`, `scripts/consertae/release-patch-manifest.json`.

## Papéis de segurança
- Mantenedor: organização GitHub `consertae-lab`.
- Autores/committers e revisores: **a designar formalmente**.
- Aprovador de assinatura: **a designar formalmente**.
- MFA deve ser verificado para todos os membros autorizados.
- Branches de release devem exigir revisão e aprovação. Estas medidas ainda precisam ser configuradas.

## Política proposta
1. Compilar a partir de commits revisados e imutáveis em runner hospedado pelo GitHub.
2. Validar código, procedência, licença, arquivos sensíveis e testes.
3. Carregar o artefato unsigned como saída do **mesmo workflow** usado para pedir a assinatura e verificar sua origem.
4. Exigir aprovação manual para cada versão, usando política de release restrita.
5. Verificar Authenticode, timestamp, SHA-256 e integridade do conteúdo após assinatura.
6. Fazer QA funcional e de privacidade antes de qualquer mudança no portal.
7. Manter fonte correspondente, instruções de uso e de desinstalação disponíveis.

## Privacidade e consentimento
Ver [especificação de privacidade](PRIVACY-AND-CONSENT.md), ainda pendente de validação técnica.

## Condições da assinatura gratuita
**Se** aprovado, a política pública será atualizada para conter a referência exigida:
> Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org).

Essa frase não indica que já temos o serviço. O certificado gratuito usa o nome de editor **SignPath Foundation**, não Consertaê.

Requisitos: https://signpath.org/terms.html ; https://docs.signpath.io/trusted-build-systems/github .

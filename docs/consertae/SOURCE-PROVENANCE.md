# Procedência do código — Consertaê 1.4.9

Base oficial: [RustDesk 1.4.9](https://github.com/rustdesk/rustdesk/commit/6c57829). A branch `consertae-suporte-1.4.9` incorpora 27 arquivos alterados ou gerados no cliente, cujo inventário e SHA-256 constam em `scripts/consertae/release-patch-manifest.json`.

Biblioteca comum: fork público [consertae-lab/hbb_common](https://github.com/consertae-lab/hbb_common) fixado como submódulo Git no commit indicado pelo manifesto. A diferença da biblioteca corresponde a um arquivo de configuração personalizado.

O histórico oficial e a licença AGPL-3.0 foram preservados. A base personalizada segue em homologação. A existência de código-fonte público e de uma compilação não implica que o executável já tenha recebido assinatura digital válida.

Testes de build anteriores foram executados em repositório privado de auditoria. Uma compilação pública reproduzível e um pedido de assinatura SignPath precisam ocorrer em um workflow do fork; a aprovação do SignPath é externa e não está concedida.

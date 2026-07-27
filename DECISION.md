# Architecture Decision Records (ADR) - Recurring Billing Api

Este documento registra todas as decisões de arquitetura, padrões de projeto e escolhas tecnológicas adotadas durante a evolução deste sistema de cobrança recorrente.

---

## ADR 001: Escolha do Framework Rails em Modo API (`--api`)
* **Status:** Aceito
* **Data:** 2026-03
* **Contexto:** Necessidade de criar um microserviço de cobrança recorrente focado em alta performance de endpoints e desacoplamento do front-end.
* **Decisão:** Utilização do Ruby on Rails com a flag `--api`.
* **Justificativa:** Remove middlewares desnecessários de renderização HTML/Views (Asset Pipeline, Session, Cookies), tornando a aplicação mais leve, rápida e aderente aos padrões de APIs RESTful.

---

## ADR 002: Suíte de Testes com RSpec, VCR e WebMock
* **Status:** Aceito
* **Data:** 2026-03
* **Contexto:** Garantir a estabilidade e previsibilidade do sistema ao integrar com chamadas externas de pagamento (Stripe API).
* **Decisão:** Substituir Minitest por RSpec e utilizar VCR + WebMock para interceptar requisições HTTP externas nos testes.
* **Justificativa:** O RSpec possui sintaxe expressiva ideal para testes BDD. O VCR permite gravar as respostas da API do Stripe em arquivos "cassette" `.yml`, garantindo que a suíte de testes rode de forma rápida, determinística e offline, sem consumir endpoints de teste reais do Stripe a cada execução.

---

## ADR 003: Armazenamento de Variáveis Sensíveis com `dotenv-rails`
* **Status:** Aceito
* **Data:** 2026-03
* **Contexto:** Isolar credenciais bancárias e chaves de API (`STRIPE_SECRET_KEY`) fora do controle de versão Git.
* **Decisão:** Uso da gem `dotenv-rails` alimentando o arquivo `.env` (ignorado no `.gitignore`).
* **Justificativa:** Atende aos princípios do *12-Factor App* sobre configuração isolada por ambiente.
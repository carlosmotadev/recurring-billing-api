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

---

## ADR 004: Modelagem de Dados para Assinaturas e Recorrência
* **Status:** Aceito
* **Data:** 2026-07
* **Contexto:** Necessidade de armazenar histórico de faturamento, assinaturas ativas e vínculo seguro com a API de gateway externo.
* **Decisão:** Modelagem com tabelas dedicadas (`customers`, `plans`, `subscriptions`, `invoices`) mantendo IDs externos do Stripe (`stripe_customer_id`, `stripe_subscription_id`, `stripe_invoice_id`) e enums indexados para status.
* **Justificativa:** Garante integridade referencial no PostgreSQL, busca performática indexada por tokens externos e rastreabilidade total de faturas geradas por assinatura.

---

## ADR 005: Encapsulamento de APIs Financeiras com Service Objects
* **Status:** Aceito
* **Data:** 2026-07
* **Contexto:** Isolar regras de negócio transacionais e chamadas de API externa de pagamentos (Stripe).
* **Decisão:** Criação de Service Objects dedicados (`Stripe::CreateSubscriptionService`) retornando `OpenStruct` com o resultado do fluxo.
* **Justificativa:** 
  1. **Princípio de Responsabilidade Única (SRP):** Mantém controllers enxutos, focados apenas em receber a requisição HTTP e responder JSON, delegando a complexidade do ciclo financeiro.
  2. **Facilidade de Testabilidade:** Permite desacoplar chamadas de rede e simular cenários de falha ou erro de cartão de forma independente da interface HTTP.

---

## ADR 006: Processamento Assíncrono de Webhooks com Sidekiq
* **Status:** Aceito
* **Data:** 2026-07
* **Contexto:** Garantir tempo de resposta imediato para os Webhooks do Stripe e resiliência no processamento financeiro.
* **Decisão:** O controller do Webhook apenas valida a assinatura/payload, responde `200 OK` e delega a regra de negócio para o `StripeWebhookJob` no Sidekiq.
* **Justificativa:** Previne timeouts HTTP do Stripe, gerencia retentativas automáticas (*retries*) em caso de falha transitória do banco de dados e mantém a API altamente responsiva.
# Architecture Decision Records (ADR) — Recurring Billing API

Este documento registra as principais decisões arquiteturais, padrões de projeto e escolhas tecnológicas adotadas durante a evolução da **Recurring Billing API**.

---

# ADR 001 — Escolha do Rails em Modo API (`--api`)

**Status:** Aceito
**Data:** 2026-03

## Contexto

Havia a necessidade de desenvolver um microserviço de cobrança recorrente focado em alta performance, comunicação via APIs REST e desacoplamento da camada de front-end.

## Decisão

Utilizar **Ruby on Rails** em **API Mode** (`rails new --api`).

## Justificativa

* Remove middlewares voltados para renderização HTML.
* Elimina Asset Pipeline, Sessions e Cookies por padrão.
* Reduz o consumo de memória.
* Melhora o desempenho da aplicação.
* Segue as boas práticas para construção de APIs RESTful.

---

# ADR 002 — Suíte de Testes com RSpec, VCR e WebMock

**Status:** Aceito
**Data:** 2026-03

## Contexto

Garantir estabilidade, previsibilidade e rapidez na execução dos testes envolvendo integrações externas com a Stripe API.

## Decisão

Substituir o **Minitest** por **RSpec** e utilizar **VCR** juntamente com **WebMock**.

## Justificativa

* Sintaxe mais expressiva para testes BDD.
* Isolamento de chamadas HTTP externas.
* Execução dos testes sem depender da disponibilidade da Stripe.
* Redução do tempo de execução da suíte.

As respostas da Stripe são gravadas em arquivos *cassette* (`.yml`) e reutilizadas nas próximas execuções.

---

# ADR 003 — Gerenciamento de Variáveis de Ambiente

**Status:** Aceito
**Data:** 2026-03

## Contexto

As credenciais da aplicação não devem ficar armazenadas no repositório Git.

## Decisão

Utilizar a gem **dotenv-rails** juntamente com um arquivo `.env`, ignorado pelo Git.

## Justificativa

* Mantém segredos fora do código-fonte.
* Facilita a configuração entre ambientes.
* Segue os princípios do **12-Factor App**.

Exemplos de variáveis:

* `STRIPE_SECRET_KEY`
* `STRIPE_WEBHOOK_SECRET`
* `REDIS_URL`

---

# ADR 004 — Modelagem do Domínio de Assinaturas

**Status:** Aceito
**Data:** 2026-07

## Contexto

Era necessário armazenar clientes, planos, assinaturas e histórico completo de faturamento mantendo sincronização com a Stripe.

## Decisão

Modelagem baseada nas entidades:

* Customers
* Plans
* Subscriptions
* Invoices

Os identificadores externos da Stripe também são persistidos:

* `stripe_customer_id`
* `stripe_subscription_id`
* `stripe_invoice_id`

Os estados da aplicação utilizam **Enums** indexados.

## Justificativa

* Integridade referencial no PostgreSQL.
* Consultas rápidas utilizando índices.
* Rastreabilidade completa entre banco local e Stripe.

---

# ADR 005 — Encapsulamento da Integração com Stripe em Service Objects

**Status:** Aceito
**Data:** 2026-07

## Contexto

Evitar que regras financeiras e chamadas externas ficassem concentradas nos controllers.

## Decisão

Criar Service Objects dedicados, por exemplo:

```ruby
Stripe::CreateSubscriptionService
```

Os serviços retornam objetos contendo o resultado da operação.

## Justificativa

### Single Responsibility Principle (SRP)

Controllers permanecem responsáveis apenas por:

* receber requisições HTTP;
* validar parâmetros;
* retornar respostas JSON.

Toda a lógica de negócio permanece isolada na camada de serviços.

### Facilidade de Testes

Permite:

* simular falhas da Stripe;
* testar cenários de cartão recusado;
* desacoplar completamente a camada HTTP.

---

# ADR 006 — Processamento Assíncrono de Webhooks

**Status:** Aceito
**Data:** 2026-07

## Contexto

Os Webhooks da Stripe exigem respostas rápidas para evitar reenvios e timeouts.

## Decisão

O controller do Webhook:

1. valida assinatura e payload;
2. responde imediatamente com **HTTP 200**;
3. delega o processamento para um **Sidekiq Job**.

Exemplo:

```ruby
StripeWebhookJob.perform_async(...)
```

## Justificativa

* Evita timeout dos Webhooks.
* Mantém baixa latência.
* Aproveita o sistema de retries automáticos do Sidekiq.
* Aumenta a resiliência do processamento financeiro.

---

# ADR 007 — Redis como Infraestrutura para Background Jobs

**Status:** Aceito
**Data:** 2026-07

## Contexto

O Sidekiq necessita de um armazenamento rápido para filas de processamento.

## Decisão

Utilizar o **Redis** como banco em memória, executando na porta padrão **6379**.

## Justificativa

* Altíssimo throughput.
* Baixa latência.
* Baixo consumo de CPU.
* Solução oficialmente recomendada pelo Sidekiq.

---

# ADR 008 — Documentação da API com Rswag (OpenAPI)

**Status:** Aceito
**Data:** 2026-07

## Contexto

Disponibilizar documentação sempre sincronizada com a implementação da API.

## Decisão

Utilizar:

* rswag-api
* rswag-ui

Gerando automaticamente uma especificação **OpenAPI 3.0**.

## Justificativa

A documentação segue a filosofia **Docs as Code**.

As especificações são escritas juntamente com os testes de integração e geradas automaticamente a partir do RSpec, garantindo que a documentação represente fielmente o comportamento da API.

---

# ADR 009 — Middleware de Sessão para Ferramentas Administrativas

**Status:** Aceito
**Data:** 2026-07

## Contexto

Embora o Rails em modo API seja stateless, o painel web do Sidekiq necessita de suporte a sessões baseadas em cookies.

## Decisão

Adicionar seletivamente os middlewares:

* `ActionDispatch::Cookies`
* `ActionDispatch::Session::CookieStore`

no arquivo `config/application.rb`.

## Justificativa

Essa abordagem permite utilizar interfaces administrativas, como o **Sidekiq::Web**, sem alterar o comportamento stateless dos endpoints REST da aplicação.

---

# Resumo das Decisões

| ADR     | Decisão                                                      |
| ------- | ------------------------------------------------------------ |
| ADR-001 | Rails em modo API                                            |
| ADR-002 | RSpec + VCR + WebMock                                        |
| ADR-003 | dotenv-rails para variáveis sensíveis                        |
| ADR-004 | Modelagem do domínio com entidades dedicadas                 |
| ADR-005 | Integração com Stripe através de Service Objects             |
| ADR-006 | Webhooks processados via Sidekiq                             |
| ADR-007 | Redis como backend de filas                                  |
| ADR-008 | Documentação OpenAPI com Rswag                               |
| ADR-009 | Middleware de sessão apenas para ferramentas administrativas |

# 💳 Recurring Billing API

API RESTful de alta performance desenvolvida em **Ruby on Rails 8 (API Mode)** para gerenciamento de cobranças recorrentes e assinaturas, totalmente integrada à **Stripe API**.

O projeto conta com:

* Processamento assíncrono de Webhooks via **Sidekiq + Redis**
* Documentação interativa via **Swagger UI**
* Cobertura completa de testes automatizados com **RSpec + VCR**

---

# 🚀 Arquitetura e Tecnologias

| Categoria                | Tecnologia                            |
| ------------------------ | ------------------------------------- |
| Linguagem                | Ruby 3.x                              |
| Framework                | Ruby on Rails 8.x (`--api`)           |
| Banco de Dados           | PostgreSQL                            |
| Processamento Assíncrono | Sidekiq + Redis                       |
| Gateway de Pagamento     | Stripe API (`stripe gem`)             |
| Documentação             | Rswag / OpenAPI 3.0 (Swagger UI)      |
| Testes                   | RSpec, VCR, WebMock, Shoulda Matchers |

---

# 📍 Endpoints e Painéis (Ambiente Local)

Com a aplicação rodando através do `rails server`, os seguintes serviços estarão disponíveis:

| Serviço           | URL                            | Descrição                                               |
| ----------------- | ------------------------------ | ------------------------------------------------------- |
| Swagger UI        | http://localhost:3000/api-docs | Documentação interativa para testar os endpoints da API |
| Sidekiq Dashboard | http://localhost:3000/sidekiq  | Monitoramento das filas e processamento de jobs         |
| Healthcheck       | http://localhost:3000/up       | Status da aplicação                                     |

---

# 🛠️ Como Rodar o Projeto Localmente

## 1. Pré-requisitos

Certifique-se de possuir instalado:

* Ruby 3.x
* PostgreSQL
* Redis Server

---

## 2. Clonar o Repositório e Instalar Dependências

```bash
git clone https://github.com/seu-usuario/recurring-billing-api.git

cd recurring-billing-api

bundle install
```

---

# 3. Configurar Variáveis de Ambiente

Crie o arquivo `.env` baseado no exemplo:

```bash
cp .env.example .env
```

Configure as variáveis necessárias:

```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
REDIS_URL=redis://localhost:6379/0
```

---

# 4. Configurar Banco de Dados

Crie o banco e execute as migrations:

```bash
rails db:create db:migrate db:seed
```

Caso esteja utilizando PostgreSQL local, confirme as configurações em:

```bash
config/database.yml
```

Exemplo:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: recurring_billing_api_development
  username: seu_usuario
  password: sua_senha
  host: localhost
```

---

# 5. Iniciar o Redis

Verifique se o Redis está executando:

```bash
sudo service redis-server start
```

Teste a conexão:

```bash
redis-cli ping
```

Resposta esperada:

```text
PONG
```

---

# 6. Iniciar os Serviços

Execute cada serviço em um terminal separado.

## Terminal 1 — Servidor Rails

```bash
rails server
```

---

## Terminal 2 — Worker Sidekiq

```bash
bundle exec sidekiq
```

---

# 🧪 Testes Automatizados

A aplicação utiliza:

* RSpec para testes
* VCR para interceptação de chamadas externas
* WebMock para controle das requisições HTTP

Execute:

```bash
bundle exec rspec
```

---

# 📚 Atualizar Documentação OpenAPI (Swagger)

Caso alguma spec de documentação seja alterada, gere novamente o arquivo Swagger:

```bash
SWAGGER_DRY_RUN=0 RAILS_ENV=test bundle exec rspec \
spec/requests/api/v1/subscriptions_swagger_spec.rb \
--format Rswag::Specs::SwaggerFormatter
```

---

# 📌 Diferenciais Arquiteturais

## Webhooks Seguros e Assíncronos

Processamento idempotente de eventos Stripe utilizando Sidekiq.

Eventos suportados incluem:

* `invoice.payment_succeeded`
* `customer.subscription.deleted`

---

## Isolamento com VCR

As chamadas reais para a Stripe API são gravadas em cassettes, permitindo:

* Testes determinísticos
* Execução rápida
* Ausência de dependência externa durante a suíte

---

## Service Objects Pattern

As integrações externas ficam isoladas em:

```
app/services/stripe/
```

Mantendo:

* Controllers enxutos
* Regras de negócio organizadas
* Código mais fácil de testar e manter

---


---

# 📄 Licença

Este projeto está em desenvolvimento e destinado a fins de estudo e demonstração de arquitetura backend com Ruby on Rails.

# 💳 Recurring Billing API (Stripe + Rails 8 API)

API RESTful robusta e de alta performance para gerenciamento de cobranças recorrentes, assinaturas e faturamento integrado à **Stripe API**, com processamento assíncrono de Webhooks via **Sidekiq** e cobertura total de testes automatizados com **RSpec & VCR**.

---

## 🚀 Tecnologias e Ferramentas

* **Ruby:** 3.x
* **Ruby on Rails:** 8.x (modo `--api`)
* **Banco de Dados:** PostgreSQL
* **Background Jobs & Cache:** Sidekiq & Redis
* **Gateway de Pagamento:** Stripe API (Gem `stripe`)
* **Testes Automatizados:** RSpec, VCR, WebMock, Shoulda Matchers
* **Controle de Configuração:** `dotenv-rails`

---

## 🏛️ Decisões de Arquitetura (ADRs)

Todas as decisões técnicas, padrões de projeto e escolhas de arquitetura estão documentadas em detalhes no arquivo [`DECISIONS.md`](./DECISIONS.md).

Principais destaques:
* **ADR 001:** Rails em Modo API (`--api`) para leveza e desacoplamento do front-end.
* **ADR 002:** Suíte de testes determinística e offline com RSpec + VCR/WebMock.
* **ADR 005:** Encapsulamento de integrações financeiras via Service Objects (`Stripe::CreateSubscriptionService`).
* **ADR 006:** Processamento assíncrono e resiliente de Webhooks do Stripe utilizando Sidekiq.

---

## 🛠️ Como Executar o Projeto Localmente

### Pré-requisitos
* Ruby instalados
* PostgreSQL rodando
* Redis rodando

### 1. Clonar o Repositório e Instalar Dependências
```bash
git clone [https://github.com/seu-usuario/recurring-billing-api.git](https://github.com/seu-usuario/recurring-billing-api.git)
cd recurring-billing-api
bundle install

<div align="center">
  <img src="https://fiscal.mateusemth.dev/icon-master.png" width="120" alt="Monitor Fiscal Logo" />

  <h1>Monitor Fiscal API - Exemplos de Integração Oficiais</h1>

  <p><strong>Automatize a inteligência tributária e o monitoramento da SEFAZ direto no seu ERP.</strong></p>

  <p>
    <a href="https://fiscal.mateusemth.dev/conta-api">
      <img src="https://img.shields.io/badge/API-Gratuita-2eb67d.svg?style=for-the-badge" alt="API Gratuita" />
    </a>
    <a href="https://fiscal.mateusemth.dev/conta-api">
      <img src="https://img.shields.io/badge/Rate_Limit-120_req/min-0052cc.svg?style=for-the-badge" alt="Rate Limit: 120 req/min" />
    </a>
    <a href="https://fiscal.mateusemth.dev/api-docs">
      <img src="https://img.shields.io/badge/Documentação-OpenAPI-black.svg?style=for-the-badge" alt="Documentação OpenAPI" />
    </a>
    <a href="https://github.com/mateusemth/api-monitor-sefaz">
      <img src="https://img.shields.io/badge/Repositório-GitHub-181717.svg?style=for-the-badge&logo=github" alt="Repositório GitHub" />
    </a>
  </p>

  <p>
    <a href="https://fiscal.mateusemth.dev/conta-api">
      <img src="https://img.shields.io/badge/Gerar_API_Key-2eb67d?style=for-the-badge" alt="Gerar API Key" />
    </a>
    <a href="https://fiscal.mateusemth.dev/api-docs">
      <img src="https://img.shields.io/badge/Ver_Documentação-0052cc?style=for-the-badge" alt="Ver documentação" />
    </a>
    <a href="#linguagens">
      <img src="https://img.shields.io/badge/Executar_Exemplos-181717?style=for-the-badge" alt="Executar exemplos" />
    </a>
  </p>
</div>

---

Exemplos de consumo da API pública do Monitor Fiscal em JavaScript, Python, C#, PHP, Go, C++ e Delphi.

A API ajuda sistemas fiscais, ERPs e rotinas internas a consultar documentos técnicos monitorados, status de portais SEFAZ/SVRS, comparações de documentos persistidos e notificações vinculadas a uma API Key.

## Links rápidos

| Recurso | Link |
| :--- | :--- |
| Conta API | https://fiscal.mateusemth.dev/conta-api |
| Documentação OpenAPI | https://fiscal.mateusemth.dev/api-docs |
| Base da API | `https://fiscal.mateusemth.dev/api` |

## O que os exemplos demonstram

- Validar a API Key e consultar escopos em `GET /api/fiscal-api-keys/scopes`.
- Consultar status de um portal em `GET /api/fiscal-status?portal=nfe`.
- Listar documentos persistidos em `GET /api/fiscal-documents?portal=nfe&limit=3`.
- Buscar documentos diretamente na fonte monitorada em `GET /api/fiscal-api?portal=nfe`.
- Ler notificações da chave autenticada em `GET /api/fiscal-notifications`.
- Consultar comparações textuais em `GET /api/fiscal-document-comparisons`.

O Monitor Fiscal não é um serviço oficial da SEFAZ. Ele organiza informações públicas monitoradas e expõe uma camada de consulta para integração. Decisões fiscais e operacionais críticas devem considerar a fonte oficial correspondente.

## Linguagens

| Linguagem | Como executar | Observações |
| :--- | :--- | :--- |
| JavaScript | `node javascript/index.js` | Usa `fetch` nativo do Node atual. |
| Python | `python3 python/main.py` | Requer `requests`. |
| C# (.NET) | Use `csharp/Program.cs` em um projeto console | Usa `HttpClient` e `System.Text.Json`. |
| PHP | `php php/index.php` | Usa a extensão `cURL`. |
| Go | `go run go/main.go` | Usa `net/http` e `encoding/json`. |
| C++ | Compile vinculando com `-lcpr` | Usa [libcpr](https://github.com/libcpr/cpr). |
| Delphi | Compile a unit no RAD Studio | Usa `TRESTClient`. |

## Autenticação

Todos os exemplos exigem uma API Key. Gere uma chave em https://fiscal.mateusemth.dev/conta-api e substitua `SUA_API_KEY_AQUI` no arquivo desejado.

Header usado pelos samples:

```http
Authorization: Bearer SUA_API_KEY_AQUI
```

A API também aceita `x-api-token` em rotas públicas documentadas.

## Endpoints usados

### `GET /api/fiscal-api-keys/scopes`

Valida a chave atual e retorna metadados como `tokenPrefix`, `name`, `isActive`, `scopes`, `rateLimitMax`, `rateLimitWindowMs` e `scopeDescriptions`.

### `GET /api/fiscal-status`

Consulta o status do portal informado. O retorno pode incluir `status`, `statusSource`, `maintenance`, `availability` e `contingency`, conforme a fonte disponível.

Valores principais de `status`:

- `operational`
- `scheduled`
- `outage`

### `GET /api/fiscal-documents`

Lista documentos já persistidos no banco.

Campos principais de cada documento:

- `id`
- `portalSlug`
- `portal`
- `sistema`
- `tipo`
- `nome`
- `description`
- `url`
- `data`

### `GET /api/fiscal-api`

Busca documentos em tempo real no portal fiscal suportado. O formato de documento segue os campos `sistema`, `tipo`, `nome`, `description`, `url` e `data`.

### `GET /api/fiscal-notifications`

Lista notificações da API Key autenticada. Ao consultar a lista ou o detalhe, notificações com status `enviado` passam para `recebido`.

Estados possíveis:

- `enviado`: notificação criada para a chave.
- `recebido`: a chave consultou a lista ou o detalhe.
- `lido`: marcado manualmente com `POST /api/fiscal-notifications`.

### `GET /api/fiscal-document-comparisons`

Retorna comparações textuais entre documentos persistidos, quando há histórico compatível. A geração ou atualização de análise por IA depende de configuração do ambiente e dos parâmetros documentados.

## Rate limit e erros

O limite padrão pode ser consultado no endpoint de scopes. Algumas chaves podem ter limite customizado.

Códigos que os exemplos tratam como erro:

- `401`: token ausente ou inválido.
- `403`: token sem acesso, suspenso ou bloqueado.
- `429`: limite de requisições excedido.
- `5xx`: falha temporária da API ou de fonte externa consultada.

Em produção, trate `429` com espera progressiva antes de tentar novamente.

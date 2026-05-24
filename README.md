<div align="center">
  <img src="https://fiscal.mateusemth.dev/icon-master.png" width="120" alt="Monitor Fiscal Logo" />
  
  # Monitor Fiscal API - Exemplos de Integração Oficiais

  **Automatize a inteligência tributária e o monitoramento da SEFAZ direto no seu ERP.**

  [![API Gratuita](https://img.shields.io/badge/API-Gratuita-2eb67d.svg?style=for-the-badge)](https://fiscal.mateusemth.dev/conta-api)
  [![Limites](https://img.shields.io/badge/Rate_Limit-120_req/min-0052cc.svg?style=for-the-badge)](https://fiscal.mateusemth.dev/conta-api)
  [![Documentação](https://img.shields.io/badge/Documentação-OpenAPI-black.svg?style=for-the-badge)](https://fiscal.mateusemth.dev/api-docs)
  [![Repositório](https://img.shields.io/badge/Repositório-GitHub-181717.svg?style=for-the-badge&logo=github)](https://github.com/mateusemth/api-monitor-sefaz)

</div>

---

## 📖 O que é este repositório?

<img align="right" src="https://fiscal.mateusemth.dev/mascot-ops.png" width="160" alt="Mascote Monitor Fiscal Operacional" />

Este repositório contém a **coleção oficial de exemplos de integração** da API do **Monitor Fiscal**. A nossa missão é descomplicar a vida de desenvolvedores fiscais e de Software Houses. 

Se o seu ERP (sistema de gestão) sofre com instabilidades na autorização de NF-e, se o seu time de suporte perde horas tentando descobrir se a Sefaz do estado X está fora do ar, ou se você é sempre pego de surpresa quando o fisco publica um novo Schema XML, esta API foi feita para você.

Aqui você encontrará códigos prontos em **JavaScript, Python, C#, PHP, Go, C++ e Delphi**, focados em demonstrar como acionar nossos endpoints de maneira profissional, segura e assíncrona.

<br clear="all" />

---

## 🚀 O que a API resolve na prática?

<img align="left" src="https://fiscal.mateusemth.dev/mascot-found.png" width="160" alt="Mascote Documentos" style="margin-right: 20px" />

Ao incorporar esses exemplos no seu sistema, você passa a ter superpoderes fiscais de forma programática:

1. **Auto-Contingência:** Cheque a disponibilidade dos portais (ex: SVRS, Sefaz-SP) e altere a emissão para contingência *antes* do cliente ligar reclamando de timeout.
2. **Webhooks e Notificações:** Consuma a fila de alertas para ser avisado sobre instabilidades assim que elas são identificadas.
3. **Download de NTs e Schemas:** Extraia links, manuais, Notas Técnicas e atualizações de Schemas (NF-e, CT-e, MDF-e, NFC-e) lendo um JSON limpo, sem precisar fazer web-scraping em portais governamentais lentos.
4. **"Diffs" Fiscais Automáticos:** Compare versões antigas com as versões novas das Notas Técnicas publicadas.

<br clear="all" />

---

## 💻 Linguagens Suportadas

Desenvolvemos classes "Client" completas e com tratamento de erros. Escolha o seu ecossistema:

| Linguagem | Como executar o exemplo | Tecnologias Nativas/Libs Utilizadas |
| :--- | :--- | :--- |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/javascript/javascript-original.svg" width="20" /> **Node.js** | `node javascript/index.js` | Fetch API, Promises, ES6 Classes |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="20" /> **Python** | `python python/main.py` | `requests` |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/csharp/csharp-original.svg" width="20" /> **C# (.NET)** | `dotnet run` (na pasta csharp) | `HttpClient`, `System.Text.Json` |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/php/php-original.svg" width="20" /> **PHP** | `php php/index.php` | Extensão `cURL` pura |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/go/go-original.svg" width="20" /> **Go** | `go run go/main.go` | `net/http`, `encoding/json` |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/cplusplus/cplusplus-original.svg" width="20" /> **C++** | Compile vinculando com `-lcpr` | [libcpr](https://github.com/libcpr/cpr) (C++ Requests) |
| 🪟 **Delphi** | Compile e execute a `Unit` RAD | `TRESTClient`, Data.Bind, REST.Types |

---

## 🔌 Entendendo os Endpoints Utilizados

Os scripts de exemplo fazem uma "tour" (passeio) completa pelos 6 pilares da [documentação OpenAPI](https://fiscal.mateusemth.dev/api-docs):

### 1. `GET /api/fiscal-api-keys/scopes` (Validação de Token)
**Objetivo:** Verificar se sua API Key é válida e quais são as suas permissões.  
**Uso Prático:** No startup do seu ERP, valide a conexão com o Monitor Fiscal e verifique se o seu token não está bloqueado e qual o seu limite de requisições por janela temporal (ex: 120 requisições por minuto).

### 2. `GET /api/fiscal-status` (Monitoramento Sefaz)
**Objetivo:** Retorna o status de contingência e manutenção dos webservices de autorização.  
**Uso Prático:** Antes de iniciar a rotina de transmissão em lote de 1.000 NF-es, você chama esta rota. Se a SEFAZ estiver com `status: "offline"`, seu sistema automaticamente represa as notas ou aciona emissão em contingência.

### 3. `GET /api/fiscal-documents` (Busca de Base Histórica)
**Objetivo:** Lista documentos que já foram mapeados e organizados pelo nosso banco de dados.  
**Uso Prático:** Criar uma "Timeline" interna no seu software house com as últimas Notas Técnicas de NF-e, contendo links de download direto para o PDF da Receita.

### 4. `GET /api/fiscal-api` (Scraper em Tempo Real)
**Objetivo:** Aciona os rastreadores do Monitor Fiscal para buscar a versão da fonte em tempo real.  
**Uso Prático:** Garantir que o seu sistema saiba imediatamente sobre a alteração de um layout sem precisar esperar a atualização dos caches globais.

### 5. `GET /api/fiscal-notifications` (Caixa de Entrada de Alertas)
**Objetivo:** Consulta fila de eventos pendentes da sua conta (Novas Notas, Queda brusca da Sefaz).  
**Uso Prático:** Seu ERP faria polling (`cron-job`) desta rota a cada X minutos. Ao encontrar um evento, ele processa a leitura, avisa os operadores do seu sistema, e a nossa API marca automaticamente a notificação como lida.

### 6. `GET /api/fiscal-document-comparisons` (Diffs Fiscais)
**Objetivo:** Fornece um "De/Para" inteligente comparando Notas Técnicas passadas com a atual.  
**Uso Prático:** Mostrar de forma visual na sua área restrita para o time de desenvolvimento exatamente as tags XML ou as regras de rejeição que mudaram da NT anterior para a recém-publicada.

---

## 🔑 Autenticação (Como começar)

A integração via API **exige** o uso da sua API Key para se proteger de bloqueios por IP e garantir seus limites estipulados. **Todos os exemplos no repositório exigem que você configure a variável `API_KEY`.**

**1. Gere sua chave gratuitamente:**
Acesse o [Painel do Desenvolvedor - Conta API](https://fiscal.mateusemth.dev/conta-api) no Monitor Fiscal, cadastre seu sistema (Bot) e gere seu token.

**2. Envie sua chave no cabeçalho:**
Nossos exemplos já fazem isso por você, inserindo a API Key via HTTP Headers (Padrão OAuth2):
```http
Authorization: Bearer SUA_API_KEY_AQUI
```

**3. Teste os scripts:**
Altere a string `"SUA_API_KEY_AQUI"` dentro de qualquer arquivo baixado para a chave que você gerou, e rode a aplicação para ver a mágica acontecer no seu terminal!

---

## 🛡️ Rate Limit e Prevenção de Bloqueios

Para garantir a estabilidade do sistema para toda a comunidade, a API implementa um controle rigoroso de requisições. 

### Headers de Controle (Transparência Total)
Todas as respostas da API incluem cabeçalhos HTTP para você monitorar seu consumo em tempo real:
*   `X-RateLimit-Limit`: Seu limite total de requisições na janela de tempo atual.
*   `X-RateLimit-Remaining`: Quantas requisições você ainda pode fazer antes de ser bloqueado.
*   `X-RateLimit-Reset`: Timestamp de quando a sua janela será zerada e você poderá fazer novas chamadas.

### Entendendo os Bloqueios (Status Codes)
O seu script deve estar preparado para lidar com os seguintes cenários descritos na nossa OpenAPI:
*   **`401 Unauthorized`**: Token ausente ou inválido (ex: enviou string vazia ou token revogado).
*   **`403 Forbidden`**: Token bloqueado por abuso ou suspenso.
*   **`429 Too Many Requests`**: Você ultrapassou o seu `X-RateLimit-Limit`. O sistema bloqueará temporariamente novas chamadas até o tempo definido em `X-RateLimit-Reset`. Respeite este código no seu ERP implementando *Exponential Backoff* ou pausando os jobs.

---

## 📈 Custos e Ambientes de Produção

*   **Gratuidade Certa:** O projeto foi criado pela comunidade técnica para a comunidade técnica. O serviço oferece um limite inicial de **120 requisições por minuto (RPM) 100% gratuitamente**.
*   **Aumento de Cotas (Produção Escalonada):** Caso o seu ERP ou sua Software House processe milhares de CNPJs e precise de um volume de monitoramento muito agressivo (ou webhooks simultâneos para N instâncias), não há problema.

> **Precisa de mais escala ou SLA corporativo?** 
> Entre em contato por e-mail em **[me@mateusemth.dev](mailto:me@mateusemth.dev)**. Analisaremos o seu caso de uso para ajustar o seu limite para o tráfego em produção de forma adequada.

---

<p align="center">
  <b>Feito com ⚡️ para turbinar a rotina dos desenvolvedores fiscais do Brasil</b><br>
  <i>Não passe nervoso lidando com indisponibilidade de Sefaz. Automatize.</i>
</p>

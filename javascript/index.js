const API_BASE_URL = 'https://fiscal.mateusemth.dev/api';
const API_KEY = 'SUA_API_KEY_AQUI';

if (API_KEY === 'SUA_API_KEY_AQUI') {
  console.error('ERRO: A autenticação é obrigatória. Configure sua API_KEY.');
  process.exit(1);
}

const headers = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${API_KEY}`
};

class MonitorFiscalClient {
  static async request(endpoint) {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, { headers });
    if (!response.ok) {
      throw new Error(`Falha na requisição [${response.status}]: ${await response.text()}`);
    }
    return response.json();
  }

  static async verifyToken() {
    console.log('\n--- Verificando API Key ---');
    const data = await this.request('/fiscal-api-keys/scopes');
    const rateLimit = data.rateLimitMax ?? 'padrão do sistema';
    console.log(`Token Ativo: ${data.isActive} | Limite: ${rateLimit}`);
  }

  static async checkStatus(portal = 'nfe') {
    console.log(`\n--- Status do Portal: ${portal.toUpperCase()} ---`);
    const data = await this.request(`/fiscal-status?portal=${portal}`);
    console.log('Status geral:', data.status);
  }

  static async getRecentDocuments(portal = 'nfe', limit = 5) {
    console.log(`\n--- Últimos Documentos: ${portal.toUpperCase()} ---`);
    const data = await this.request(`/fiscal-documents?portal=${portal}&limit=${limit}`);
    (data.documents || []).forEach(doc => {
      console.log(`[${doc.tipo}] ${doc.nome} -> ${doc.url}`);
    });
  }

  static async getRealtimeDocuments(portal = 'nfe') {
    console.log(`\n--- Busca em Tempo Real (Scraper): ${portal.toUpperCase()} ---`);
    const data = await this.request(`/fiscal-api?portal=${portal}`);
    console.log(`${data.documents?.length || 0} documentos extraídos agora da SEFAZ.`);
  }

  static async getNotifications(includeRead = false) {
    console.log(`\n--- Notificações do Sistema ---`);
    const data = await this.request(`/fiscal-notifications?includeRead=${includeRead}`);
    const notifs = data.notifications || [];
    console.log(`Total na fila: ${notifs.length}`);
    notifs.forEach(n => console.log(`[${n.status}] ${n.title}`));
  }

  static async getComparisons(portal = 'nfe', limit = 3) {
    console.log(`\n--- Comparações textuais: ${portal.toUpperCase()} ---`);
    const data = await this.request(`/fiscal-document-comparisons?portal=${portal}&limit=${limit}`);
    const comps = data.comparisons || [];
    console.log(`${comps.length} comparações encontradas.`);
  }
}

// Execução sequencial dos endpoints
(async () => {
  try {
    await MonitorFiscalClient.verifyToken();
    await MonitorFiscalClient.checkStatus('nfe');
    await MonitorFiscalClient.getRecentDocuments('nfe', 3);
    await MonitorFiscalClient.getRealtimeDocuments('nfe');
    await MonitorFiscalClient.getNotifications();
    await MonitorFiscalClient.getComparisons('nfe', 3);
  } catch (error) {
    console.error('Erro na integração:', error.message);
  }
})();

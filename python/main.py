import sys
import requests

API_BASE_URL = "https://fiscal.mateusemth.dev/api"
API_KEY = "SUA_API_KEY_AQUI"

if API_KEY == "SUA_API_KEY_AQUI":
    print("ERRO: A autenticação é obrigatória. Configure sua API_KEY.")
    sys.exit(1)

class MonitorFiscalClient:
    def __init__(self, base_url, api_key):
        self.base_url = base_url
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }

    def _request(self, endpoint, method="GET"):
        url = f"{self.base_url}{endpoint}"
        response = requests.request(method, url, headers=self.headers)
        if not response.ok:
            raise Exception(f"Falha na requisição [{response.status_code}]: {response.text}")
        return response.json()

    def verify_token(self):
        print("\n--- Verificando API Key ---")
        data = self._request("/fiscal-api-keys/scopes")
        rate_limit = data.get("rateLimitMax") or "padrão do sistema"
        print(f"Token Ativo: {data.get('isActive')} | Limite: {rate_limit}")

    def check_status(self, portal="nfe"):
        print(f"\n--- Status do Portal: {portal.upper()} ---")
        data = self._request(f"/fiscal-status?portal={portal}")
        print("Status geral:", data.get("status"))

    def get_recent_documents(self, portal="nfe", limit=5):
        print(f"\n--- Últimos Documentos: {portal.upper()} ---")
        data = self._request(f"/fiscal-documents?portal={portal}&limit={limit}")
        for doc in data.get("documents", []):
            print(f"[{doc.get('tipo')}] {doc.get('nome')} -> {doc.get('url')}")

    def get_realtime_documents(self, portal="nfe"):
        print(f"\n--- Busca em Tempo Real (Scraper): {portal.upper()} ---")
        data = self._request(f"/fiscal-api?portal={portal}")
        docs = data.get("documents", [])
        print(f"{len(docs)} documentos extraídos agora da SEFAZ.")

    def get_notifications(self, include_read=False):
        print("\n--- Notificações do Sistema ---")
        param = "true" if include_read else "false"
        data = self._request(f"/fiscal-notifications?includeRead={param}")
        notifs = data.get("notifications", [])
        print(f"Total na fila: {len(notifs)}")
        for n in notifs:
            print(f"[{n.get('status')}] {n.get('title')}")

    def get_comparisons(self, portal="nfe", limit=3):
        print(f"\n--- Comparações textuais: {portal.upper()} ---")
        data = self._request(f"/fiscal-document-comparisons?portal={portal}&limit={limit}")
        comps = data.get("comparisons", [])
        print(f"{len(comps)} comparações encontradas.")

if __name__ == "__main__":
    try:
        client = MonitorFiscalClient(API_BASE_URL, API_KEY)
        client.verify_token()
        client.check_status("nfe")
        client.get_recent_documents("nfe", 3)
        client.get_realtime_documents("nfe")
        client.get_notifications()
        client.get_comparisons("nfe", 3)
    except Exception as e:
        print("Erro na integração:", e)

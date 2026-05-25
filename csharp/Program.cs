using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;

namespace MonitorFiscal.Samples
{
    class Program
    {
        private const string ApiBaseUrl = "https://fiscal.mateusemth.dev/api";
        private const string ApiKey = "SUA_API_KEY_AQUI";
        private static readonly HttpClient client = new HttpClient();

        static async Task Main(string[] args)
        {
            if (ApiKey == "SUA_API_KEY_AQUI")
            {
                Console.WriteLine("ERRO: A autenticação é obrigatória. Configure sua API_KEY.");
                Environment.Exit(1);
            }

            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ApiKey);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            try
            {
                await VerifyTokenAsync();
                await CheckStatusAsync("nfe");
                await GetRecentDocumentsAsync("nfe", 3);
                await GetRealtimeDocumentsAsync("nfe");
                await GetNotificationsAsync();
                await GetComparisonsAsync("nfe", 3);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro na integração: {ex.Message}");
            }
        }

        static async Task<JsonElement> RequestAsync(string endpoint)
        {
            var response = await client.GetAsync($"{ApiBaseUrl}{endpoint}");
            var content = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"Falha na requisição [{(int)response.StatusCode}]: {content}");
            }
            return JsonDocument.Parse(content).RootElement;
        }

        static async Task VerifyTokenAsync()
        {
            Console.WriteLine("\n--- Verificando API Key ---");
            var data = await RequestAsync("/fiscal-api-keys/scopes");
            var limit = data.GetProperty("rateLimitMax").GetInt32();
            var active = data.GetProperty("isActive").GetBoolean();
            Console.WriteLine($"Token Ativo: {active} | Limite: {limit} reqs por janela");
        }

        static async Task CheckStatusAsync(string portal)
        {
            Console.WriteLine($"\n--- Status do Portal: {portal.ToUpper()} ---");
            var data = await RequestAsync($"/fiscal-status?portal={portal}");
            Console.WriteLine($"Status geral: {data.GetProperty("status").GetString()}");
        }

        static async Task GetRecentDocumentsAsync(string portal, int limit)
        {
            Console.WriteLine($"\n--- Últimos Documentos: {portal.ToUpper()} ---");
            var data = await RequestAsync($"/fiscal-documents?portal={portal}&limit={limit}");
            if (data.TryGetProperty("documents", out var docs))
            {
                foreach (var doc in docs.EnumerateArray())
                {
                    Console.WriteLine($"[{doc.GetProperty("tipo").GetString()}] {doc.GetProperty("nome").GetString()}");
                    Console.WriteLine($"Link: {doc.GetProperty("url").GetString()}\n");
                }
            }
        }

        static async Task GetRealtimeDocumentsAsync(string portal)
        {
            Console.WriteLine($"\n--- Busca em Tempo Real (Scraper): {portal.ToUpper()} ---");
            var data = await RequestAsync($"/fiscal-api?portal={portal}");
            if (data.TryGetProperty("documents", out var docs))
            {
                Console.WriteLine($"Foram encontrados {docs.GetArrayLength()} documentos no portal agora.");
            }
        }

        static async Task GetNotificationsAsync(bool includeRead = false)
        {
            Console.WriteLine("\n--- Notificações do Sistema ---");
            var data = await RequestAsync($"/fiscal-notifications?includeRead={includeRead.ToString().ToLower()}");
            if (data.TryGetProperty("notifications", out var notifs))
            {
                Console.WriteLine($"Total na fila: {notifs.GetArrayLength()}");
                foreach (var n in notifs.EnumerateArray())
                {
                    Console.WriteLine($"[{n.GetProperty("status").GetString()}] {n.GetProperty("title").GetString()}");
                }
            }
        }

        static async Task GetComparisonsAsync(string portal, int limit)
        {
            Console.WriteLine($"\n--- Comparações textuais: {portal.ToUpper()} ---");
            var data = await RequestAsync($"/fiscal-document-comparisons?portal={portal}&limit={limit}");
            if (data.TryGetProperty("comparisons", out var comps))
            {
                Console.WriteLine($"{comps.GetArrayLength()} comparações encontradas.");
            }
        }
    }
}

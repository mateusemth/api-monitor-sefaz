using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

class Program
{
    static async Task<int> Main(string[] args)
    {
        try
        {
            var token = Environment.GetEnvironmentVariable("MONITOR_FISCAL_API_KEY");
            if (string.IsNullOrWhiteSpace(token)) throw new Exception("Configure a variável MONITOR_FISCAL_API_KEY.");
            var validas = "AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO".Split(' ');
            var ufs = (args.Length > 0 ? args[0] : string.Join(",", validas)).Split(',').Select(uf => uf.Trim().ToUpperInvariant()).ToArray();
            if (ufs.Distinct().Count() != ufs.Length || ufs.Any(uf => !validas.Contains(uf)))
                throw new Exception("Informe UFs válidas, sem repetição.");
            var destino = args.Length > 1 ? args[1] : "tabelas-ibpt.zip";
            using var cliente = new HttpClient { Timeout = TimeSpan.FromSeconds(120) };
            cliente.DefaultRequestHeaders.Add("x-api-token", token);
            using var resposta = await cliente.GetAsync("https://fiscal.mateusemth.dev/api/ibpt/latest?uf=" + Uri.EscapeDataString(string.Join(",", ufs)));
            resposta.EnsureSuccessStatusCode();
            var dados = await resposta.Content.ReadAsByteArrayAsync();
            if (dados.Length < 4 || dados[0] != 'P' || dados[1] != 'K' || dados[2] != 3 || dados[3] != 4)
                throw new Exception("A resposta não é um ZIP válido.");
            using (var arquivo = new FileStream(destino, FileMode.CreateNew, FileAccess.Write)) await arquivo.WriteAsync(dados, 0, dados.Length);
            Console.WriteLine($"ZIP IBPT salvo em {destino} ({dados.Length} bytes).");
            return 0;
        }
        catch (Exception erro) { Console.Error.WriteLine($"Erro: {erro.Message}"); return 1; }
    }
}

#include <cpr/cpr.h>
#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>

int main(int argc, char* argv[]) {
    try {
        const char* token = std::getenv("MONITOR_FISCAL_API_KEY");
        if (!token || !*token) throw std::runtime_error("Configure a variável MONITOR_FISCAL_API_KEY.");
        const std::string todas = "AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN,RS,RO,RR,SC,SP,SE,TO";
        const std::set<std::string> validas = {"AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"};
        std::stringstream entrada(argc > 1 ? argv[1] : todas);
        std::string uf, selecionadas;
        std::set<std::string> usadas;
        while (std::getline(entrada, uf, ',')) {
            auto first = uf.find_first_not_of(" \t\r\n"), last = uf.find_last_not_of(" \t\r\n");
            uf = first == std::string::npos ? "" : uf.substr(first, last - first + 1);
            std::transform(uf.begin(), uf.end(), uf.begin(), [](unsigned char c){ return static_cast<char>(std::toupper(c)); });
            if (!validas.count(uf) || !usadas.insert(uf).second) throw std::runtime_error("Informe UFs válidas, sem repetição.");
            if (!selecionadas.empty()) selecionadas += ',';
            selecionadas += uf;
        }
        if (selecionadas.empty() || (argc > 1 && !std::string(argv[1]).empty() && std::string(argv[1]).back() == ',')) throw std::runtime_error("Informe UFs válidas.");
        auto resposta = cpr::Get(cpr::Url{"https://fiscal.mateusemth.dev/api/ibpt/latest"},
            cpr::Parameters{{"uf", selecionadas}}, cpr::Header{{"x-api-token", token}}, cpr::Timeout{120000});
        if (resposta.error) throw std::runtime_error("Falha de conexão: " + resposta.error.message);
        if (resposta.status_code < 200 || resposta.status_code >= 300) throw std::runtime_error("Falha HTTP: " + std::to_string(resposta.status_code));
        if (resposta.text.size() < 4 || resposta.text.compare(0, 4, "PK\x03\x04", 4) != 0) throw std::runtime_error("A resposta não é um ZIP válido.");
        const char* destino = argc > 2 ? argv[2] : "tabelas-ibpt.zip";
        FILE* arquivo = std::fopen(destino, "wbx");
        if (!arquivo) throw std::runtime_error("Não foi possível criar o arquivo; verifique se ele já existe.");
        const auto escritos = std::fwrite(resposta.text.data(), 1, resposta.text.size(), arquivo);
        const int resultado = std::fclose(arquivo);
        if (escritos != resposta.text.size() || resultado != 0) throw std::runtime_error("Falha ao gravar o arquivo.");
        std::cout << "ZIP IBPT salvo em " << destino << " (" << escritos << " bytes).\n";
        return 0;
    } catch (const std::exception& erro) { std::cerr << "Erro: " << erro.what() << '\n'; return 1; }
}

#include <iostream>
#include <string>
// Instalação do CPR recomendada: https://github.com/libcpr/cpr
#include <cpr/cpr.h>

const std::string API_BASE_URL = "https://fiscal.mateusemth.dev/api";
const std::string API_KEY = "SUA_API_KEY_AQUI";

cpr::Header getHeaders() {
    return cpr::Header{
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer " + API_KEY}
    };
}

void verifyToken() {
    std::cout << "\n--- Verificando API Key ---" << std::endl;
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-api-keys/scopes"}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

void checkStatus(const std::string& portal = "nfe") {
    std::cout << "\n--- Status do Portal: " << portal << " ---" << std::endl;
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-status?portal=" + portal}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

void getRecentDocuments(const std::string& portal = "nfe", int limit = 5) {
    std::cout << "\n--- Ultimos Documentos: " << portal << " ---" << std::endl;
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-documents?portal=" + portal + "&limit=" + std::to_string(limit)}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

void getRealtimeDocuments(const std::string& portal = "nfe") {
    std::cout << "\n--- Busca em Tempo Real (Scraper): " << portal << " ---" << std::endl;
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-api?portal=" + portal}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

void getNotifications(bool includeRead = false) {
    std::cout << "\n--- Notificacoes do Sistema ---" << std::endl;
    std::string param = includeRead ? "true" : "false";
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-notifications?includeRead=" + param}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

void getComparisons(const std::string& portal = "nfe", int limit = 3) {
    std::cout << "\n--- Comparacoes textuais: " << portal << " ---" << std::endl;
    cpr::Response r = cpr::Get(cpr::Url{API_BASE_URL + "/fiscal-document-comparisons?portal=" + portal + "&limit=" + std::to_string(limit)}, getHeaders());
    std::cout << "Response:\n" << r.text << std::endl;
}

int main(int argc, char** argv) {
    if (API_KEY == "SUA_API_KEY_AQUI") {
        std::cerr << "ERRO: A autenticacao e obrigatoria. Configure sua API_KEY." << std::endl;
        return 1;
    }

    try {
        verifyToken();
        checkStatus("nfe");
        getRecentDocuments("nfe", 3);
        getRealtimeDocuments("nfe");
        getNotifications();
        getComparisons("nfe", 3);
    } catch (const std::exception& e) {
        std::cerr << "Erro na integracao: " << e.what() << std::endl;
    }
    return 0;
}

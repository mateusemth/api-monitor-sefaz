package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

const ApiBaseUrl = "https://fiscal.mateusemth.dev/api"
const ApiKey = "SUA_API_KEY_AQUI"

func doRequest(url string) ([]byte, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+ApiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("falha na requisição [%d]", resp.StatusCode)
	}

	return io.ReadAll(resp.Body)
}

func verifyToken() {
	fmt.Println("\n--- Verificando API Key ---")
	body, err := doRequest(ApiBaseUrl + "/fiscal-api-keys/scopes")
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data map[string]interface{}
	json.Unmarshal(body, &data)
	rateLimit := data["rateLimitMax"]
	if rateLimit == nil {
		rateLimit = "padrão do sistema"
	}
	fmt.Printf("Token Ativo: %v | Limite: %v\n", data["isActive"], rateLimit)
}

func checkStatus(portal string) {
	fmt.Printf("\n--- Status do Portal: %s ---\n", portal)
	body, err := doRequest(ApiBaseUrl + "/fiscal-status?portal=" + portal)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data map[string]interface{}
	json.Unmarshal(body, &data)
	fmt.Println("Status geral:", data["status"])
}

func getRecentDocuments(portal string, limit int) {
	fmt.Printf("\n--- Últimos Documentos: %s ---\n", portal)
	url := fmt.Sprintf("%s/fiscal-documents?portal=%s&limit=%d", ApiBaseUrl, portal, limit)
	body, err := doRequest(url)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data struct {
		Documents []struct {
			Tipo string `json:"tipo"`
			Nome string `json:"nome"`
			Url  string `json:"url"`
		} `json:"documents"`
	}
	json.Unmarshal(body, &data)

	for _, doc := range data.Documents {
		fmt.Printf("[%s] %s -> %s\n", doc.Tipo, doc.Nome, doc.Url)
	}
}

func getRealtimeDocuments(portal string) {
	fmt.Printf("\n--- Busca em Tempo Real (Scraper): %s ---\n", portal)
	body, err := doRequest(ApiBaseUrl + "/fiscal-api?portal=" + portal)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data struct {
		Documents []interface{} `json:"documents"`
	}
	json.Unmarshal(body, &data)
	fmt.Printf("%d documentos extraídos agora da SEFAZ.\n", len(data.Documents))
}

func getNotifications(includeRead bool) {
	fmt.Println("\n--- Notificações do Sistema ---")
	url := fmt.Sprintf("%s/fiscal-notifications?includeRead=%t", ApiBaseUrl, includeRead)
	body, err := doRequest(url)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data struct {
		Notifications []struct {
			Status  string `json:"status"`
			Title   string `json:"title"`
		} `json:"notifications"`
	}
	json.Unmarshal(body, &data)
	fmt.Printf("Total na fila: %d\n", len(data.Notifications))
	for _, n := range data.Notifications {
		fmt.Printf("[%s] %s\n", n.Status, n.Title)
	}
}

func getComparisons(portal string, limit int) {
	fmt.Printf("\n--- Comparações textuais: %s ---\n", portal)
	url := fmt.Sprintf("%s/fiscal-document-comparisons?portal=%s&limit=%d", ApiBaseUrl, portal, limit)
	body, err := doRequest(url)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	var data struct {
		Comparisons []interface{} `json:"comparisons"`
	}
	json.Unmarshal(body, &data)
	fmt.Printf("%d comparações encontradas.\n", len(data.Comparisons))
}

func main() {
	if ApiKey == "SUA_API_KEY_AQUI" {
		fmt.Println("ERRO: A autenticação é obrigatória. Configure sua API_KEY.")
		os.Exit(1)
	}
	verifyToken()
	checkStatus("nfe")
	getRecentDocuments("nfe", 3)
	getRealtimeDocuments("nfe")
	getNotifications(false)
	getComparisons("nfe", 3)
}

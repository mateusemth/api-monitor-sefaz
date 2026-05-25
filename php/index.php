<?php

define('API_BASE_URL', 'https://fiscal.mateusemth.dev/api');
define('API_KEY', 'SUA_API_KEY_AQUI');

if (API_KEY === 'SUA_API_KEY_AQUI') {
    die("ERRO: A autenticação é obrigatória. Configure sua API_KEY.\n");
}

function doRequest($endpoint) {
    $url = API_BASE_URL . $endpoint;
    $headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " . API_KEY
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    if ($error) {
        throw new Exception("Erro cURL: " . $error);
    }
    if ($httpCode >= 400) {
        throw new Exception("Falha na requisição [$httpCode]: $response");
    }

    return json_decode($response, true);
}

function verifyToken() {
    echo "\n--- Verificando API Key ---\n";
    $data = doRequest('/fiscal-api-keys/scopes');
    $isActive = isset($data['isActive']) && $data['isActive'] ? 'true' : 'false';
    if (isset($data['rateLimitMax'])) {
        echo "Token Ativo: $isActive | Limite: " . $data['rateLimitMax'] . " reqs por janela\n";
    }
}

function checkStatus($portal = 'nfe') {
    echo "\n--- Status do Portal: " . strtoupper($portal) . " ---\n";
    $data = doRequest('/fiscal-status?portal=' . $portal);
    if (isset($data['status'])) {
        echo "Status geral: " . $data['status'] . "\n";
    }
}

function getRecentDocuments($portal = 'nfe', $limit = 5) {
    echo "\n--- Últimos Documentos: " . strtoupper($portal) . " ---\n";
    $data = doRequest('/fiscal-documents?portal=' . $portal . '&limit=' . $limit);
    if (isset($data['documents']) && is_array($data['documents'])) {
        foreach ($data['documents'] as $doc) {
            echo "[" . $doc['tipo'] . "] " . $doc['nome'] . " -> " . $doc['url'] . "\n";
        }
    }
}

function getRealtimeDocuments($portal = 'nfe') {
    echo "\n--- Busca em Tempo Real (Scraper): " . strtoupper($portal) . " ---\n";
    $data = doRequest('/fiscal-api?portal=' . $portal);
    if (isset($data['documents'])) {
        echo count($data['documents']) . " documentos extraídos agora da SEFAZ.\n";
    }
}

function getNotifications($includeRead = false) {
    echo "\n--- Notificações do Sistema ---\n";
    $param = $includeRead ? 'true' : 'false';
    $data = doRequest('/fiscal-notifications?includeRead=' . $param);
    if (isset($data['notifications']) && is_array($data['notifications'])) {
        echo "Total na fila: " . count($data['notifications']) . "\n";
        foreach ($data['notifications'] as $n) {
            echo "[" . $n['status'] . "] " . $n['title'] . "\n";
        }
    }
}

function getComparisons($portal = 'nfe', $limit = 3) {
    echo "\n--- Comparações textuais: " . strtoupper($portal) . " ---\n";
    $data = doRequest('/fiscal-document-comparisons?portal=' . $portal . '&limit=' . $limit);
    if (isset($data['comparisons']) && is_array($data['comparisons'])) {
        echo count($data['comparisons']) . " comparações encontradas.\n";
    }
}

try {
    verifyToken();
    checkStatus('nfe');
    getRecentDocuments('nfe', 3);
    getRealtimeDocuments('nfe');
    getNotifications();
    getComparisons('nfe', 3);
} catch (Exception $e) {
    echo "Erro na integração: " . $e->getMessage() . "\n";
}

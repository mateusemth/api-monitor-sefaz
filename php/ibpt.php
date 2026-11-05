<?php
$token = getenv('MONITOR_FISCAL_API_KEY');
$validas = explode(' ', 'AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO');
$ufs = array_map(fn($uf) => strtoupper(trim($uf)), explode(',', $argv[1] ?? implode(',', $validas)));
$destino = $argv[2] ?? 'tabelas-ibpt.zip';
try {
    if (!$token) throw new RuntimeException('Configure a variável MONITOR_FISCAL_API_KEY.');
    if (count(array_unique($ufs)) !== count($ufs) || array_diff($ufs, $validas))
        throw new RuntimeException('Informe UFs válidas, sem repetição, separadas por vírgula.');
    $ch = curl_init('https://fiscal.mateusemth.dev/api/ibpt/latest?' . http_build_query(['uf' => implode(',', $ufs)]));
    curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_HTTPHEADER => ['x-api-token: ' . $token], CURLOPT_TIMEOUT => 120]);
    $dados = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $erro = curl_error($ch);
    curl_close($ch);
    if ($dados === false) throw new RuntimeException('Falha de conexão: ' . $erro);
    if ($status < 200 || $status >= 300) throw new RuntimeException("Falha ao consultar IBPT (HTTP $status).");
    if (substr($dados, 0, 4) !== "PK\x03\x04") throw new RuntimeException('A resposta não é um ZIP válido.');
    $arquivo = fopen($destino, 'xb');
    if ($arquivo === false) throw new RuntimeException('Não foi possível criar o arquivo.');
    try {
        $offset = 0;
        while ($offset < strlen($dados)) {
            $escritos = fwrite($arquivo, substr($dados, $offset));
            if ($escritos === false || $escritos === 0) throw new RuntimeException('Falha ao gravar o arquivo.');
            $offset += $escritos;
        }
    } finally { fclose($arquivo); }
    echo "ZIP IBPT salvo em $destino (" . strlen($dados) . " bytes).\n";
} catch (Throwable $erro) {
    fwrite(STDERR, 'Erro: ' . $erro->getMessage() . "\n");
    exit(1);
}

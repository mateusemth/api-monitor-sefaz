package main

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "Erro:", err)
		os.Exit(1)
	}
}

func run() error {
	token := os.Getenv("MONITOR_FISCAL_API_KEY")
	if token == "" {
		return fmt.Errorf("configure a variável MONITOR_FISCAL_API_KEY")
	}
	validas := strings.Fields("AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO")
	entrada, destino := strings.Join(validas, ","), "tabelas-ibpt.zip"
	if len(os.Args) > 1 {
		entrada = os.Args[1]
	}
	if len(os.Args) > 2 {
		destino = os.Args[2]
	}
	permitidas, usadas := map[string]bool{}, map[string]bool{}
	for _, uf := range validas {
		permitidas[uf] = true
	}
	ufs := strings.Split(entrada, ",")
	for i, uf := range ufs {
		uf = strings.ToUpper(strings.TrimSpace(uf))
		if !permitidas[uf] || usadas[uf] {
			return fmt.Errorf("informe UFs válidas, sem repetição")
		}
		usadas[uf], ufs[i] = true, uf
	}
	endereco := "https://fiscal.mateusemth.dev/api/ibpt/latest?" + url.Values{"uf": {strings.Join(ufs, ",")}}.Encode()
	req, err := http.NewRequest("GET", endereco, nil)
	if err != nil {
		return err
	}
	req.Header.Set("x-api-token", token)
	resposta, err := (&http.Client{Timeout: 120 * time.Second}).Do(req)
	if err != nil {
		return err
	}
	defer resposta.Body.Close()
	if resposta.StatusCode < 200 || resposta.StatusCode >= 300 {
		return fmt.Errorf("falha ao consultar IBPT (HTTP %d)", resposta.StatusCode)
	}
	dados, err := io.ReadAll(resposta.Body)
	if err != nil {
		return err
	}
	if !bytes.HasPrefix(dados, []byte{'P', 'K', 3, 4}) {
		return fmt.Errorf("a resposta não é um ZIP válido")
	}
	arquivo, err := os.OpenFile(destino, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0666)
	if err != nil {
		return err
	}
	_, err = arquivo.Write(dados)
	closeErr := arquivo.Close()
	if err != nil {
		return err
	}
	if closeErr != nil {
		return closeErr
	}
	fmt.Printf("ZIP IBPT salvo em %s (%d bytes).\n", destino, len(dados))
	return nil
}

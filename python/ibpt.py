import os
import sys
from pathlib import Path
import requests

UFS = set('AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO'.split())


def main():
    token = os.environ.get('MONITOR_FISCAL_API_KEY')
    if not token:
        raise ValueError('Configure a variável MONITOR_FISCAL_API_KEY.')
    ufs = [uf.strip().upper() for uf in (sys.argv[1] if len(sys.argv) > 1 else ','.join(sorted(UFS))).split(',')]
    if any(uf not in UFS for uf in ufs) or len(set(ufs)) != len(ufs):
        raise ValueError('Informe UFs válidas, sem repetição, separadas por vírgula.')
    destino = Path(sys.argv[2] if len(sys.argv) > 2 else 'tabelas-ibpt.zip')
    response = requests.get('https://fiscal.mateusemth.dev/api/ibpt/latest',
                            headers={'x-api-token': token}, params={'uf': ','.join(ufs)}, timeout=120)
    response.raise_for_status()
    if not response.content.startswith(b'PK\x03\x04'):
        raise ValueError('A resposta da API não é um arquivo ZIP válido.')
    with destino.open('xb') as arquivo:
        arquivo.write(response.content)
    print(f'ZIP IBPT salvo em {destino} ({len(response.content)} bytes).')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, requests.RequestException) as exc:
        print(f'Erro: {exc}', file=sys.stderr)
        sys.exit(1)

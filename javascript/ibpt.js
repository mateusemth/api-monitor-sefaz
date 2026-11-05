const fs = require('node:fs/promises');
const path = require('node:path');

const API_URL = 'https://fiscal.mateusemth.dev/api/ibpt/latest';
const UFS = new Set('AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO'.split(' '));

async function baixarIbpt({ token, ufs, destino, fetchImpl = fetch }) {
  if (!token) throw new Error('Configure a variável MONITOR_FISCAL_API_KEY.');
  if (!ufs.length || ufs.some(uf => !UFS.has(uf)) || new Set(ufs).size !== ufs.length) {
    throw new Error('Informe UFs válidas, sem repetição, separadas por vírgula.');
  }
  const url = new URL(API_URL);
  url.searchParams.set('uf', ufs.join(','));
  const response = await fetchImpl(url, {
    headers: { 'x-api-token': token },
    signal: AbortSignal.timeout(120000),
  });
  if (!response.ok) throw new Error(`Falha ao consultar IBPT (HTTP ${response.status}).`);
  const bytes = Buffer.from(await response.arrayBuffer());
  if (bytes.length < 4 || bytes.readUInt32LE(0) !== 0x04034b50) {
    throw new Error('A resposta da API não é um arquivo ZIP válido.');
  }
  await fs.writeFile(destino, bytes, { flag: 'wx' });
  return bytes.length;
}

async function main() {
  const ufs = (process.argv[2] || [...UFS].join(',')).split(',').map(uf => uf.trim().toUpperCase());
  const destino = path.resolve(process.argv[3] || 'tabelas-ibpt.zip');
  const tamanho = await baixarIbpt({ token: process.env.MONITOR_FISCAL_API_KEY, ufs, destino });
  console.log(`ZIP IBPT salvo em ${destino} (${tamanho} bytes).`);
}

if (require.main === module) {
  main().catch(erro => { console.error(`Erro: ${erro.message}`); process.exitCode = 1; });
}

module.exports = { baixarIbpt };

const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const { baixarIbpt } = require('./ibpt');

test('baixa o ZIP autenticado com as UFs selecionadas', async t => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'ibpt-'));
  t.after(() => fs.rm(dir, { recursive: true, force: true }));
  const destino = path.join(dir, 'ibpt.zip');
  const zip = Buffer.from([0x50, 0x4b, 0x03, 0x04, 0x00]);
  const fetchImpl = async (url, options) => {
    assert.equal(url.searchParams.get('uf'), 'SP,RJ');
    assert.equal(options.headers['x-api-token'], 'teste');
    return { ok: true, arrayBuffer: async () => zip };
  };
  assert.equal(await baixarIbpt({ token: 'teste', ufs: ['SP', 'RJ'], destino, fetchImpl }), zip.length);
  assert.deepEqual(await fs.readFile(destino), zip);
  await assert.rejects(baixarIbpt({ token: 'teste', ufs: ['SP', 'RJ'], destino, fetchImpl }), { code: 'EEXIST' });
});

test('rejeita UF inválida, erro HTTP e resposta que não é ZIP', async () => {
  const args = { token: 'teste', ufs: ['SP'], destino: 'não-deve-ser-criado.zip' };
  await assert.rejects(baixarIbpt({ ...args, ufs: ['XX'] }), /UFs válidas/);
  await assert.rejects(baixarIbpt({ ...args, fetchImpl: async () => ({ ok: false, status: 401 }) }), /HTTP 401/);
  await assert.rejects(baixarIbpt({ ...args, fetchImpl: async () => ({ ok: true, arrayBuffer: async () => Buffer.from('erro') }) }), /ZIP válido/);
});

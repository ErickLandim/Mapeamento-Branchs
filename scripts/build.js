// Compila o bcovscan (Go) para bin/. Usado no postinstall e na primeira execução.
const { spawnSync } = require('child_process');
const path = require('path');

const root = path.join(__dirname, '..');
const exe = path.join(root, 'bin', process.platform === 'win32' ? 'bcovscan.exe' : 'bcovscan');

function build() {
  const r = spawnSync('go', ['build', '-o', exe, '.'], {
    cwd: path.join(root, 'tools', 'bcovscan'),
    stdio: 'inherit',
  });
  return r.status === 0;
}

module.exports = { build, exe };

if (require.main === module) {
  const ok = build();
  if (!ok) {
    console.error('\nbcov: não consegui compilar. Instale o Go (https://go.dev/dl) e rode "bcov" de novo.');
    if (!process.argv.includes('--soft')) process.exit(1);
  }
}

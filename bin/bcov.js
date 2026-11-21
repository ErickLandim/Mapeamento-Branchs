#!/usr/bin/env node
// bcov <opções>  ->  bcovscan run <opções>   (compila na primeira vez)
const { spawnSync } = require('child_process');
const fs = require('fs');
const { build, exe } = require('../scripts/build.js');

if (!fs.existsSync(exe)) {
  console.error('bcov: compilando na primeira execução...');
  if (!build()) {
    console.error('bcov: instale o Go (https://go.dev/dl) para compilar.');
    process.exit(1);
  }
}
const args = process.argv.slice(2);
const r = spawnSync(exe, args[0] === 'run' ? args : ['run', ...args], { stdio: 'inherit' });
process.exit(r.status === null ? 1 : r.status);

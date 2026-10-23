#!/usr/bin/env node
// Verify that a RustDesk single-file portable EXE embeds the exact client
// bundle produced by an unsigned Windows CI build. Never executes the EXE.
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const zlib = require('zlib');

if (process.argv.length !== 4) {
  console.error('Usage: node verify_portable_bundle.js <portable.exe> <bundle_directory>');
  process.exit(2);
}
const exePath = process.argv[2];
const bundleDir = path.resolve(process.argv[3]);
const exe = fs.readFileSync(exePath);
const magic = Buffer.from('rustdesk');

function md5(data) {
  return crypto.createHash('md5').update(data).digest('hex');
}
function listFiles(root, relative='') {
  return fs.readdirSync(path.join(root,relative),{withFileTypes:true}).flatMap(e => {
    const p = path.posix.join(relative,e.name);
    return e.isDirectory() ? listFiles(root,p) : e.isFile() ? [p] : [];
  });
}
const originals = new Set(listFiles(bundleDir));
function attempt(start) {
  let offset = start + magic.length;
  const checked = new Set();
  for (let i=0;i<500;i++) {
    if (offset+magic.length > exe.length) return null;
    if (exe.subarray(offset,offset+8).equals(magic)) {
      offset += 8;
      const trailer = exe.toString('utf8',offset,Math.min(offset+120,exe.length)).split('\x00')[0];
      return {count:checked.size,missing:[...originals].filter(n=>!checked.has(n)),trailer};
    }
    if (offset+4>exe.length) return null;
    const pathLength = exe.readUInt32BE(offset);offset+=4;
    if (!pathLength || pathLength>500 || offset+pathLength+4>exe.length) return null;
    const rawPath = exe.toString('utf8',offset,offset+pathLength);offset+=pathLength;
    const normalized = rawPath.replace(/\\/g,'/').replace(/^\.\//,'');
    if (!originals.has(normalized)||checked.has(normalized)) return null;
    const packedLength=exe.readUInt32BE(offset);offset+=4;
    if(!packedLength||packedLength>60*1024*1024||offset+packedLength+32>exe.length) return null;
    const compressed=exe.subarray(offset,offset+packedLength);offset+=packedLength;
    const checksum=exe.toString('ascii',offset,offset+32);offset+=32;
    if (!/^[a-f0-9]{32}$/.test(checksum)) return null;
    let decompressed;
    try { decompressed=zlib.brotliDecompressSync(compressed) } catch { return null }
    if (md5(decompressed)!==checksum) return null;
    if (!decompressed.equals(fs.readFileSync(path.join(bundleDir,normalized)))) return null;
    checked.add(normalized);
  }
  return null;
}
let result=null;
for(let idx=exe.indexOf(magic); idx>=0; idx=exe.indexOf(magic,idx+1)){
  result=attempt(idx);
  if(result)break;
}
if(!result){console.error('Portable payload could not be validated');process.exit(1)}
console.log(JSON.stringify({portable_bytes:exe.length,verified_files:result.count,original_bundle_files:originals.size,missing:result.missing.length,exe_trailer:result.trailer},null,2));
if(result.missing.length!==0||result.count<90||!result.trailer.startsWith('.\\Consertae-Suporte.exe')&&!result.trailer.startsWith('./Consertae-Suporte.exe')) process.exit(1);
console.log('PASS: extracted payload hashes match every original Windows bundle file.');

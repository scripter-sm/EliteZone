const fs = require('fs');
const path = require('path');

const source_path = path.join(__dirname, '..', 'Sources', 'window', 'library.lua');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'window_library.lua');
const version_path = path.join(__dirname, '..', 'Dependencies', 'version.dat');
const library_version_path = path.join(__dirname, '..', 'Dependencies', 'window_library_version.dat');

function read(file) {
    let str = fs.readFileSync(file, { encoding: 'utf8' }).replace(/\r\n/g, '\n');
    if (str.charCodeAt(0) === 0xFEFF) str = str.substring(1);
    return str.trim();
}

function bump_library_version() {
    let current = 'v0.0';
    if (fs.existsSync(library_version_path)) current = read(library_version_path);

    const [major, minor] = current.slice(1).split('.').map(Number);
    const next_minor = minor + 1;

    const next = next_minor >= 10 ? `v${major + 1}.0` : `v${major}.${next_minor}`;
    fs.writeFileSync(library_version_path, next, 'utf8');
    return next;
}

const version = read(version_path);
const library_version = bump_library_version();

const compiled = [
    `-- This file was compiled by Elite Zone's Compiler. [${version}]`,
    `--Library Version (Used for caching purposes.) ${library_version}`,
].join('\n') + '\n\n' + read(source_path) + '\n';

fs.mkdirSync(path.dirname(output_path), { recursive: true });
fs.writeFileSync(output_path, compiled, 'utf8');
console.log('Compiled window library to window_library.lua');

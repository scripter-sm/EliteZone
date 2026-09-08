const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, '..', 'Sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui_library.lua');
const version_path = path.join(__dirname, '..', 'Dependencies', 'version.dat');

function read(file) {
    let str = fs.readFileSync(file, { encoding: 'utf8' }).replace(/\r\n/g, '\n');
    if (str.charCodeAt(0) === 0xFEFF) str = str.substring(1);
    return str.trim();
}

const version = JSON.parse(read(version_path)).version;

const compiled = [
    `-- This file was compiled by Elite Zone's Compiler. [${version}]`,
    '--[[ Library ]]',
    read(path.join(gui_path, 'library.lua')),
    '--[[ Save Manager ]]',
    read(path.join(gui_path, 'save_manager.lua')),
    '--[[ Theme Manager ]]',
    read(path.join(gui_path, 'theme_manager.lua')),
    'return EZ',
].join('\n\n') + '\n';

fs.mkdirSync(path.dirname(output_path), { recursive: true });
fs.writeFileSync(output_path, compiled, 'utf8');
console.log('Compiled GUI library to gui_library.lua');

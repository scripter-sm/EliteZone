const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, '..', 'Sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui_library.lua');
const version_path = path.join(__dirname, '..', 'Dependencies', 'version.dat');

const cloneref_block = 'local cloneref = cloneref or function(obj)\n\treturn obj\nend';
const httpservice_line = "local HttpService = cloneref(game:GetService('HttpService'));";

function read(file) {
    let str = fs.readFileSync(file, { encoding: 'utf8' }).replace(/\r\n/g, '\n');
    if (str.charCodeAt(0) === 0xFEFF) str = str.substring(1);
    return str;
}

function strip_shared(src, seen) {
    let i = src.indexOf(cloneref_block);
    if (i !== -1) {
        src = src.slice(0, i) + src.slice(i + cloneref_block.length);
    }
    src = src.replace(/^\n+/, '');
    if (seen.http) {
        src = src.replace(httpservice_line + '\n', '').replace(httpservice_line, '');
    } else if (src.includes(httpservice_line)) {
        seen.http = true;
    }
    return src.replace(/^\n+/, '');
}

function strip_return(src, name) {
    return src.replace(new RegExp('\\n*return ' + name + ';?\\s*$'), '\n');
}

const seen = { http: false };

let library = strip_return(read(path.join(gui_path, 'library.lua')), 'EZ');
if (library.includes(httpservice_line)) seen.http = true;

const save_manager = strip_return(strip_shared(read(path.join(gui_path, 'save_manager.lua')), seen), 'SaveManager');
const theme_manager = strip_return(strip_shared(read(path.join(gui_path, 'theme_manager.lua')), seen), 'ThemeManager');

const version = JSON.parse(read(version_path)).version;

const compiled = `-- This file was compiled by Elite Zone's Compiler. [${version}]\n`
    + library.trimEnd() + '\n\n'
    + save_manager.trim() + '\n\n'
    + theme_manager.trim() + '\n\n'
    + 'return EZ\n';

fs.mkdirSync(path.dirname(output_path), { recursive: true });
fs.writeFileSync(output_path, compiled, 'utf8');
console.log('Compiled GUI library to gui_library.lua');

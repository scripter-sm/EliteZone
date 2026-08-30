const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, 'Dependencies', 'gui');
const output_path = path.join(__dirname, 'Dependencies', 'libraries', 'gui.lua');

function getFiles(dir, ext) {
    const files = [];
    const items = fs.readdirSync(dir);
    
    for (const item of items) {
        const itemPath = path.join(dir, item);
        const stat = fs.statSync(itemPath);
        
        if (stat.isDirectory()) {
            const sub = getFiles(itemPath, ext);
            for (const f of sub) {
                files.push(f);
            }
        } else if (item.endsWith('.' + ext)) {
            files.push(itemPath);
        }
    }
    
    return files;
}

function compile() {
    const files = getFiles(gui_path, 'lua');
    files.sort();
    
    let combined = '-- Elite Zone GUI\n-- ' + new Date().toISOString() + '\n\n';
    
    for (const f of files) {
        const content = fs.readFileSync(f, 'utf8');
        const rel = f.substring(gui_path.length + 1);
        combined += '-- ' + rel + '\n' + content + '\n\n';
    }
    
    fs.writeFileSync(output_path, combined, 'utf8');
    console.log('Compiled ' + files.length + ' files to gui.lua (' + combined.length + ' bytes)');
}

compile();
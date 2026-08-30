const fs = require('fs');
const path = require('path');

function removeBOM(str) {
    if (str.charCodeAt(0) === 0xFEFF) {
        return str.substring(1);
    }
    return str;
}

function processDirectory(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            processDirectory(fullPath);
        } else if (file.endsWith('.lua')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            const newContent = removeBOM(content);
            if (content !== newContent) {
                fs.writeFileSync(fullPath, newContent, 'utf8');
                console.log(`Removed BOM from: ${fullPath}`);
            }
        }
    }
}

processDirectory(path.join(__dirname, '..', 'Sources', 'gui'));
console.log('BOM removal complete');

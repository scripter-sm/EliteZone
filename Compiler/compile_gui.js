const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, '..', 'Sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui.lua');

function removeBOM(str) {
    if (str.charCodeAt(0) === 0xFEFF) {
        return str.substring(1);
    }
    return str;
}

function compile() {
    const components = [], libraries = [], overlays = [];
    const component_path = path.join(gui_path, 'components');
    const library_path = path.join(gui_path, 'libraries');
    const overlay_path = path.join(gui_path, 'overlays');
    
    // Read libraries
    if (fs.existsSync(library_path)) {
        for (const library of fs.readdirSync(library_path)) {
            if (library.endsWith('.lua')) {
                libraries.push({
                    name: library.substring(0, library.length - 4),
                    data: removeBOM(fs.readFileSync(path.join(library_path, library), {encoding: 'utf8'}))
                });
            }
        }
    }
    
    // Read overlays
    if (fs.existsSync(overlay_path)) {
        for (const overlay of fs.readdirSync(overlay_path)) {
            if (overlay.endsWith('.lua')) {
                overlays.push({
                    name: overlay.substring(0, overlay.length - 4),
                    data: removeBOM(fs.readFileSync(path.join(overlay_path, overlay), {encoding: 'utf8'}))
                });
            }
        }
    }
    
    // Read components
    if (fs.existsSync(component_path)) {
        for (const component of fs.readdirSync(component_path)) {
            if (component.endsWith('.lua')) {
                const cname = component.substring(0, component.length - 4);
                let data = removeBOM(fs.readFileSync(path.join(component_path, component), {encoding: 'utf8'}));
                data = data.split('\n').map((line) => '\t\t' + line).join('\n');
                components.push({
                    name: cname,
                    data
                });
            }
        }
    }
    
    libraries.sort((a, b) => a.name.localeCompare(b.name));
    overlays.sort((b, a) => a.name.localeCompare(b.name));
    components.sort((a, b) => a.name.localeCompare(b.name));
    
    let init_data = removeBOM(fs.readFileSync(path.join(gui_path, 'init.lua'), {encoding: 'utf8'}));
    let base_data = removeBOM(fs.readFileSync(path.join(gui_path, 'base.lua'), {encoding: 'utf8'}));
    
    // Replace markers like VapeBundler does.
    // NOTE: pass a function as the replacement so JS never interprets `$`
    // sequences (e.g. `$'`, `$&`) that legitimately appear in Lua patterns.
    const overlays_block = overlays.map((data) => {
        return 'run(function()\n' + data.data.split('\n').map((line) => '\t' + line).join('\n') + '\nend)';
    }).join('\n\n');
    init_data = init_data.replace('--Overlays', () => overlays_block);

    init_data = init_data.split('\n').map((line) => '\t' + line).join('\n');

    const libraries_block = `${libraries.map((data) => {
        return data.data;
    }).join('\n\n')}\n\nEZ.Libraries = {\n${libraries.map(data => {
        return '\t' + data.name + ' = ' + data.name + ',';
    }).join('\n')}\n}`;
    base_data = base_data.replace('--Libraries', () => libraries_block);

    const components_block = `components = {\n${components.map((data) => {
        return '\t' + data.name + ' = function(props, children, api)\n' + data.data + '\n\tend,';
    }).join('\n')}\n}`;
    base_data = base_data.replace('--Components', () => components_block);

    base_data = base_data.replace('--Init', () => init_data);
    
    base_data = removeBOM(base_data);
    fs.writeFileSync(output_path, base_data, 'utf8');
    console.log('Compiled GUI to gui.lua');
}

compile();
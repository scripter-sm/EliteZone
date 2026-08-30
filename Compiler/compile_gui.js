const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, '..', 'Dependencies', 'sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui.lua');

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
    const components = [], libraries = [], overlays = [];
    const component_path = path.join(gui_path, 'components');
    const library_path = path.join(gui_path, 'libraries');
    const overlay_path = path.join(gui_path, 'overlays');
    
    // Read libraries
    if (fs.existsSync(library_path)) {
        for (const library of fs.readdirSync(library_path)) {
            libraries.push({
                name: library.substring(0, library.length - 4),
                data: fs.readFileSync(path.join(library_path, library), {encoding: 'utf8'})
            });
        }
    }
    
    // Read overlays
    if (fs.existsSync(overlay_path)) {
        for (const overlay of fs.readdirSync(overlay_path)) {
            overlays.push({
                name: overlay.substring(0, overlay.length - 4),
                data: fs.readFileSync(path.join(overlay_path, overlay), {encoding: 'utf8'})
            });
        }
    }
    
    // Read components
    if (fs.existsSync(component_path)) {
        for (const component of fs.readdirSync(component_path)) {
            const cname = component.substring(0, component.length - 4);
            let data = fs.readFileSync(path.join(component_path, component), {encoding: 'utf8'});
            data = data.split('\n').map((line) => '\t\t' + line).join('\n');
            components.push({
                name: cname,
                data
            });
        }
    }
    
    libraries.sort((a, b) => a.name.localeCompare(b.name));
    overlays.sort((b, a) => a.name.localeCompare(b.name));
    components.sort((a, b) => a.name.localeCompare(b.name));
    
    let init_data = fs.readFileSync(path.join(gui_path, 'init.lua'), {encoding: 'utf8'});
    let base_data = fs.readFileSync(path.join(gui_path, 'base.lua'), {encoding: 'utf8'});
    
    // Replace markers like VapeBundler does
    init_data = init_data.replace('--Overlays', overlays.map((data) => {
        return 'run(function()\n' + data.data.split('\n').map((line) => '\t' + line).join('\n') + '\nend)';
    }).join('\n\n'));
    
    init_data = init_data.split('\n').map((line) => '\t' + line).join('\n');
    
    base_data = base_data.replace('--Libraries', libraries.map((data) => {
        return data.data;
    }).join('\n\n') + '\n\nEZ.Libraries = {\n' + libraries.map(data => {
        return '\t' + data.name + ' = ' + data.name + ',';
    }).join('\n') + '\n}');
    
    base_data = base_data.replace('--Components', 'components = {\n' + components.map((data) => {
        return '\t' + data.name + ' = function(props, children, api)\n' + data.data + '\n\tend,';
    }).join('\n') + '\n}');
    
    base_data = base_data.replace('--Init', init_data);
    
    // Remove return statements except final one
    const lines = base_data.split('\n');
    const filtered_lines = [];
    let return_count = 0;
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.includes('return')) {
            return_count++;
            if (return_count > 1) {
                continue; // Skip extra return statements
            }
        }
        filtered_lines.push(line);
    }
    
    // Ensure final return statement
    if (!filtered_lines[filtered_lines.length - 1].includes('return EZ')) {
        filtered_lines.push('return EZ');
    }
    
    base_data = filtered_lines.join('\n');
    
    // Add asset loading at the top
    const asset_loader = `local function load_assets()
    local assets_url = "https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/"
    local assets_path = "Elite Zone/Assets"
    
    if not isfolder(assets_path) then
        makefolder(assets_path)
    end
    
    local function download_asset(file_name)
        local url = assets_url .. file_name
        local file_path = assets_path .. "/" .. file_name
        
        if not isfile(file_path) then
            local success, content = pcall(function()
                return game:HttpGet(url, true)
            end)
            
            if success then
                writefile(file_path, content)
            end
        end
        
        return getcustomasset and getcustomasset(file_path) or file_path
    end
    
    local function get_ez_asset(asset_path)
        local file_name = asset_path:match("([^/]+)$")
        return download_asset(file_name)
    end
    
    return get_ez_asset
end

local get_ez_asset = load_assets()
`;
    
    base_data = asset_loader + '\n' + base_data;
    
    fs.writeFileSync(output_path, base_data, 'utf8');
    console.log('Compiled GUI to gui.lua');
    
    // Remove gui folder from libraries if it exists
    const gui_folder = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui');
    if (fs.existsSync(gui_folder)) {
        fs.rmSync(gui_folder, { recursive: true, force: true });
        console.log('Removed gui folder from libraries');
    }
}

compile();
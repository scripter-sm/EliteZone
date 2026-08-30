const fs = require('fs');
const path = require('path');

const gui_path = path.join(__dirname, '..', 'Sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui.lua');

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
    
    // Add asset loading at the top with configurable script name
    const asset_loader = `EZ.script_name = "Elite Zone"
EZ.active_binds = {}
EZ.categories = {}
EZ.gui_color = {
	hue = 0.46,
	sat = 0.96,
	value = 0.52
}
EZ.held_keybinds = {}
EZ.loaded = false
EZ.libraries = {}
EZ.modules = {}
EZ.place = game.PlaceId
EZ.config = 'default'
EZ.rainbow_sliders = {}
EZ.settings = {}
EZ.setting_toggle_notifications = {}
EZ.thread_fix = setthreadidentity and true or false
EZ.toggle_notifications = {}
EZ.version = '1.0'
EZ.windows = {}

local function load_assets()
    local assets_url = "https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/"
    local assets_path = EZ.script_name .. "/Assets"
    local config_path = EZ.script_name .. "/Configs"
    local cache_path = EZ.script_name .. "/Cache"
    local themes_path = EZ.script_name .. "/Themes"
    
    if not isfolder(assets_path) then
        makefolder(assets_path)
    end
    
    if not isfolder(config_path) then
        makefolder(config_path)
    end
    
    if not isfolder(cache_path) then
        makefolder(cache_path)
    end
    
    if not isfolder(themes_path) then
        makefolder(themes_path)
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
    
    -- Autoload functionality
    local function load_autoload()
        local autoload_file = cache_path .. "/__autoload.json"
        if isfile(autoload_file) then
            local success, data = pcall(function()
                return http_service:JSONDecode(readfile(autoload_file))
            end)
            if success and type(data) == "table" then
                return data
            end
        end
        return {autoload_config = nil, autoload_theme = nil}
    end
    
    local function save_autoload(data)
        local autoload_file = cache_path .. "/__autoload.json"
        writefile(autoload_file, http_service:JSONEncode(data))
    end
    
    return get_ez_asset, config_path, cache_path, themes_path, load_autoload, save_autoload
end

local get_ez_asset, config_path, cache_path, themes_path, load_autoload, save_autoload = load_assets()
EZ.config_path = config_path
EZ.cache_path = cache_path
EZ.themes_path = themes_path
EZ.autoload_data = load_autoload()
EZ.LoadAutoload = save_autoload
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
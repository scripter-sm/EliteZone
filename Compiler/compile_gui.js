const fs = require('fs');
const path = require('path');

const sources_path = path.join(__dirname, '..', 'Dependencies', 'sources', 'gui');
const output_path = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui.lua');
const assets_path = path.join(__dirname, '..', 'Dependencies', 'assets');

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
    const files = getFiles(sources_path, 'lua');
    files.sort();
    
    let combined = 'local EZ = {}\nlocal function load_assets()\n';
    
    // Add asset download function
    combined += `    local assets_url = "https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/"
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
    
    // Process each file
    for (const f of files) {
        let content = fs.readFileSync(f, 'utf8');
        const rel = f.substring(sources_path.length + 1);
        
        // Replace vape with EZ
        content = content.replace(/\bvape\b/g, 'EZ');
        content = content.replace(/\bVape\b/g, 'EZ');
        content = content.replace(/\bVAPE\b/g, 'EZ');
        
        // Replace getvapeasset with get_ez_asset
        content = content.replace(/getvapeasset/g, 'get_ez_asset');
        
        // Replace asset paths
        content = content.replace(/newvape\/assets\/new/g, 'Elite Zone/Assets');
        
        // Replace vapeAssets with ez_assets
        content = content.replace(/vapeAssets/g, 'ez_assets');
        
        // Convert camelCase to snake_case for common variables
        content = content.replace(/tweenService/g, 'tween_service');
        content = content.replace(/inputService/g, 'input_service');
        content = content.replace(/textService/g, 'text_service');
        content = content.replace(/guiService/g, 'gui_service');
        content = content.replace(/runService/g, 'run_service');
        content = content.replace(/httpService/g, 'http_service');
        content = content.replace(/fontsize/g, 'font_size');
        content = content.replace(/clickgui/g, 'click_gui');
        content = content.replace(/scaledgui/g, 'scaled_gui');
        content = content.replace(/toolblur/g, 'tool_blur');
        content = content.replace(/TextGUI/g, 'text_gui');
        content = content.replace(/ActiveBinds/g, 'active_binds');
        content = content.replace(/GUIColor/g, 'gui_color');
        content = content.replace(/HeldKeybinds/g, 'held_keybinds');
        content = content.replace(/RainbowSliders/g, 'rainbow_sliders');
        content = content.replace(/SettingToggleNotifications/g, 'setting_toggle_notifications');
        content = content.replace(/ThreadFix/g, 'thread_fix');
        content = content.replace(/ToggleNotifications/g, 'toggle_notifications');
        content = content.replace(/GUIBind/g, 'gui_bind');
        content = content.replace(/GUIEnabled/g, 'gui_enabled');
        content = content.replace(/GUIVisible/g, 'gui_visible');
        content = content.replace(/LegitVisible/g, 'legit_visible');
        content = content.replace(/uipallet/g, 'ui_pallet');
        content = content.replace(/getfontbounds/g, 'get_font_bounds');
        
        combined += '-- ' + rel + '\n' + content + '\n\n';
    }
    
    // Add return statement
    combined += '\nreturn EZ';
    
    fs.writeFileSync(output_path, combined, 'utf8');
    console.log('Compiled ' + files.length + ' files to gui.lua (' + combined.length + ' bytes)');
    
    // Remove gui folder from libraries if it exists
    const gui_folder = path.join(__dirname, '..', 'Dependencies', 'libraries', 'gui');
    if (fs.existsSync(gui_folder)) {
        fs.rmSync(gui_folder, { recursive: true, force: true });
        console.log('Removed gui folder from libraries');
    }
}

compile();
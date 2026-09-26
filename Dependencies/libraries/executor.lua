--[[ environment ]]

local genv = _G
for _, getter in { getgenv, getfenv and function() return getfenv(0) end } do
    local ok, env = pcall(getter)
    if ok and type(env) == "table" then
        pcall(function() env.__ez_env_probe = true end)
        local seen = __ez_env_probe == true
        pcall(function() env.__ez_env_probe = nil end)
        if seen then
            genv = env
            break
        end
    end
end

local function find(path)
    local target = genv
    for part in path:gmatch("[^%.]+") do
        if type(target) ~= "table" then
            return
        end
        local ok, value = pcall(function() return target[part] end)
        if not ok then
            return
        end
        target = value
    end
    return type(target) == "function" and target or nil
end

--[[ aliases ]]

local aliases = {
    request = { "http_request", "syn.request", "http.request", "fluxus.request" },
    setclipboard = { "set_clipboard", "toclipboard", "Clipboard.set" },
    protectgui = { "protect_gui", "syn.protect_gui" },
    gethui = { "get_hidden_gui", "gethiddengui" },
    queue_on_teleport = { "queueonteleport", "syn.queue_on_teleport", "fluxus.queue_on_teleport" },
    getthreadidentity = { "get_thread_identity", "getidentity", "getthreadcontext", "syn.get_thread_identity" },
    setthreadidentity = { "set_thread_identity", "setidentity", "setthreadcontext", "syn.set_thread_identity" },
    getconnections = { "get_signal_cons" },
    hookfunction = { "replaceclosure" },
    getrawmetatable = { "debug.getmetatable" },
    setrawmetatable = { "debug.setmetatable" },
    getgc = { "get_gc_objects" },
    getnilinstances = { "get_nil_instances" },
    getscriptclosure = { "getscriptfunction" },
    fireclickdetector = { "click_detector" },
    isfunctionhooked = { "is_function_hooked" },
}

for name, list in aliases do
    if not find(name) then
        for _, alt in list do
            local fn = find(alt)
            if fn then
                genv[name] = fn
                break
            end
        end
    end
end

if not genv.loadstring and load then
    genv.loadstring = load
end

if not find("appendfile") and find("readfile") and find("writefile") and find("isfile") then
    genv.appendfile = function(path, data)
        writefile(path, (isfile(path) and readfile(path) or "") .. data)
    end
end

--[[ wrappers ]]

local function fix_path(path)
    return (path:gsub("\\", "/"))
end

for _, name in { "readfile", "writefile", "appendfile", "delfile", "delfolder", "makefolder", "loadfile", "isfile", "isfolder", "listfiles", "getcustomasset" } do
    local fn = find(name)
    if fn then
        genv[name] = function(path, ...)
            return fn(type(path) == "string" and path:find("\\", 1, true) and fix_path(path) or path, ...)
        end
    end
end

if find("getcustomasset") and find("isfile") and find("readfile") and find("writefile") then
    local get_asset = genv.getcustomasset
    local http = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
    genv.getcustomasset = function(path, fresh)
        if fresh and isfile(path) then
            local copy = path:gsub("[^/\\]*$", "") .. http:GenerateGUID(false) .. (path:match("%.[^%./\\]+$") or "")
            writefile(copy, readfile(path))
            return get_asset(copy)
        end
        return get_asset(path)
    end
end

--[[ stubs ]]

local noop = function() end
local stubs = {
    getconnections = function() return {} end,
    hookmetamethod = function() end,
    hookfunction = function(original) return original end,
    newcclosure = function(f) return f end,
    getnamecallmethod = function() return "" end,
    firetouchinterest = noop,
    firesignal = noop,
    setclipboard = noop,
    cloneref = function(o) return o end,
    gethui = noop,
    protectgui = noop,
    checkcaller = function() return false end,
    clonefunction = function(f) return f end,
    getrawmetatable = getmetatable,
    setrawmetatable = setmetatable,
    setreadonly = noop,
    isreadonly = function() return false end,
    getgc = function() return {} end,
    filtergc = function() return {} end,
    replicatesignal = noop,
    fireclickdetector = noop,
    fireproximityprompt = noop,
    getthreadidentity = function() return 0 end,
    setthreadidentity = noop,
    getsenv = function() return {} end,
    getscriptfromthread = noop,
    getcallbackvalue = noop,
    getnilinstances = function() return {} end,
    getinstances = function() return {} end,
    isfunctionhooked = function() return false end,
    restorefunction = noop,
}

local stubbed = {}

for name, stub in stubs do
    if not find(name) then
        genv[name] = stub
        stubbed[name] = true
    end
end

local executor_name = string.lower(identifyexecutor and identifyexecutor() or "")
if executor_name:find("solara") or executor_name:find("xeno") then
    genv.firetouchinterest = noop
    stubbed.firetouchinterest = true
end

for _, name in { "queue_on_teleport", "sethiddenproperty", "gethiddenproperty", "getrenv", "getcallingscript", "request", "appendfile" } do
    if not find(name) then
        stubbed[name] = true
    end
end

local ok, env = pcall(getgenv)
if not (ok and env == genv) then
    stubbed.getgenv = true
end

local debug_ext = {}
for _, name in { "getupvalue", "getupvalues", "setupvalue", "getconstant", "getconstants", "setconstant", "getprotos", "getproto", "getstack", "info" } do
    debug_ext["debug." .. name] = type(debug[name]) == "function"
end

--[[ caps ]]

local caps = {
    stubbed = stubbed,
    executor = executor_name,
    fix_path = fix_path,
    file_type = function(path)
        path = fix_path(path)
        return isfile(path) and "file" or isfolder(path) and "folder" or "unknown"
    end,
    file_ext = function(path)
        return path:match("%.([^%./\\]+)$")
    end,
    file_name = function(path)
        return path:match("([^/\\]+)$")
    end,
    valid_name = function(name)
        return #name > 0 and not name:find('[<>:"/\\|%?%*%c]') and not name:find("[%. ]$")
    end,
    has = function(name)
        if stubbed[name] then
            return false
        end
        local known = debug_ext[name]
        if known ~= nil then
            return known
        end
        return find(name) ~= nil
    end,
}

genv.EZ_CAPS = caps

return caps

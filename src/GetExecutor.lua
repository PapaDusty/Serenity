-- Get Executor (heuristic)
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return true, res end
    return false, nil
end

local function try_call(name)
    if type(_G[name]) == "function" then
        local ok, r = safe_pcall(_G[name])
        if ok and r ~= nil then
            return tostring(r)
        end
    end
    return nil
end

local function global_exists(name)
    if rawget(_G, name) ~= nil then return true end
    if _G[name] ~= nil then return true end
    if type(getgenv) == "function" then
        local ok, genv = safe_pcall(getgenv)
        if ok and type(genv) == "table" and genv[name] ~= nil then
            return true
        end
    end

    local lower = name:lower()
    if rawget(_G, lower) ~= nil or _G[lower] ~= nil then return true end

    return false
end

local signatures = {
    ["Synapse X / Synapse Z / Synapse Mac"] = {
        function() return global_exists("syn") or global_exists("synapse") or global_exists("synx") end,
        function() return type(getgenv) == "function" end,
        function() return try_call("getexecutor") and string.find(try_call("getexecutor"):lower(), "synapse") end,
    },
    ["KRNL"] = {
        function() return global_exists("Krnl") or global_exists("KRNL") or global_exists("krnl") end,
        function() return try_call("getexecutor") and string.find(try_call("getexecutor"):lower(), "krnl") end,
    },
    ["JJSploit / WeAreDevs"] = {
        function() return global_exists("JJSploit") or global_exists("jjsploit") or global_exists("wearedevs") end,
        function() return try_call("getexecutor") and string.find((try_call("getexecutor") or ""):lower(), "jj") end,
    },
    ["Sentinel"] = {
        function() return global_exists("Sentinel") or global_exists("sentinel") end,
        function() return try_call("getexecutor") and string.find((try_call("getexecutor") or ""):lower(), "sentinel") end,
    },
    ["Delta"] = {
        function() return global_exists("Delta") or global_exists("delta") end,
        function() return try_call("getexecutor") and string.find((try_call("getexecutor") or ""):lower(), "delta") end,
    },
    ["Zenith"] = {
        function() return global_exists("Zenith") or global_exists("zenith") end,
    },
    ["Volcano"] = {
        function() return global_exists("Volcano") or global_exists("volcano") end,
    },
    ["Velocity"] = {
        function() return global_exists("Velocity") or global_exists("velocity") end,
    },
    ["Swift"] = {
        function() return global_exists("Swift") or global_exists("swift") end,
    },
    ["Seliware"] = {
        function() return global_exists("Seliware") or global_exists("seliware") end,
    },
    ["Valex"] = {
        function() return global_exists("Valex") or global_exists("valex") end,
    },
    ["Potassium"] = {
        function() return global_exists("Potassium") or global_exists("potassium") end,
    },
    ["Solara"] = {
        function() return global_exists("Solara") or global_exists("solara") end,
    },
    ["Xeno"] = {
        function() return global_exists("Xeno") or global_exists("xeno") end,
    },
    ["bunni.lol"] = {
        function() return global_exists("bunni") or global_exists("bunni_dot_lol") or global_exists("bunni_lol") end,
    },
    ["SirHunt"] = {
        function() return global_exists("SirHunt") or global_exists("sirhunt") or global_exists("sir_hunt") end,
    },
    ["Hydrogen"] = {
        function() return global_exists("Hydrogen") or global_exists("hydrogen") end,
    },
    ["Codex"] = {
        function() return global_exists("Codex") or global_exists("codex") end,
    },
    ["Cryptic"] = {
        function() return global_exists("Cryptic") or global_exists("cryptic") end,
    },
    ["Opiumware"] = {
        function() return global_exists("Opiumware") or global_exists("opiumware") end,
    },
    ["Macsploit"] = {
        function() return global_exists("Macsploit") or global_exists("macsploit") or global_exists("SynapseMac") end,
    },
    ["WeAreDevs API (WeAreDevs/WeAreDevs API)"] = {
        function() return global_exists("wearedevs") or global_exists("Exploit") end,
    },
    ["Generic: exposes getgenv/getreg/getrenv/getgc"] = {
        function() return type(getgenv) == "function" or type(getrenv) == "function" or type(getreg) == "function" end,
    },
}

local function detect_executor()
    local ok, gen = safe_pcall(function()
        if type(getexecutor) == "function" then
            return tostring(getexecutor())
        elseif type(identifyexecutor) == "function" then
            return tostring(identifyexecutor())
        end
        return nil
    end)
    if ok and gen and gen ~= "" then
        local g = gen:lower()
        if string.find(g, "syn") or string.find(g, "synapse") then return "Synapse X / Synapse Z / Synapse Mac ("..gen..")" end
        if string.find(g, "krnl") then return "KRNL ("..gen..")" end
        if string.find(g, "jjsploit") or string.find(g, "wearedevs") then return "JJSploit / WeAreDevs ("..gen..")" end
        if string.find(g, "sentinel") then return "Sentinel ("..gen..")" end
        return gen
    end

    for exeName, tests in pairs(signatures) do
        for _, test in ipairs(tests) do
            local ok, res = pcall(test)
            if ok and res then
                return exeName
            end
        end
    end

    local extras = {"hookfunction","hookmetamethod","request","http_request","http","getrawmetatable","getgc","getreg"}
    for _, n in ipairs(extras) do
        if global_exists(n) then
            return "Unknown executor (exposes "..n..")"
        end
    end

    return "Unknown"
end

local detected = detect_executor()

return detected

-- Keybind component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    
    local Keybind = {
        Type = "Keybind",
        Value = Config.Default or "LeftControl"
    }
    
    -- Keybind implementation would go here
    
    return Keybind
end

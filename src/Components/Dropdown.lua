-- Dropdown component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    
    local Dropdown = {
        Type = "Dropdown",
        Value = Config.Default,
        Values = Config.Values or {},
        Opened = false
    }
    
    -- Dropdown implementation would go here
    -- This ensures the component exists
    
    return Dropdown
end

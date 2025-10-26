-- Slider component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    
    local Slider = {
        Type = "Slider",
        Value = Config.Default or Config.Min or 0,
        Min = Config.Min or 0,
        Max = Config.Max or 100,
        Rounding = Config.Rounding or 1
    }
    
    -- Slider implementation would go here
    
    return Slider
end

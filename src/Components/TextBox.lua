-- TextBox component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    
    local TextBox = {
        Type = "TextBox",
        Value = Config.Default or ""
    }
    
    -- TextBox implementation would go here
    
    return TextBox
end

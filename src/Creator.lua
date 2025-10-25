local Creator = {}

function Creator.New(className, properties, children)
    local instance = Instance.new(className)
    
    if properties then
        for property, value in pairs(properties) do
            if property == "Parent" then
                instance.Parent = value
            else
                instance[property] = value
            end
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    
    return instance
end

return Creator

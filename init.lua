local module = {}
module._vars = {}
module.bus   = "org.awesomewm.conky"
module.vars  = setmetatable({}, { __index = function(...) return module._get_var(...) end })

local capi = { dbus = dbus }

function module._get_var(t, k)
    var = module._vars[k]
    if var then return var end
    -- Return an empty string to avoid errors trying to access values that havent been updated yet
    return ""
end

function module.update_vars(data, ...)
    local args = {...}
    -- Arguments are sent in pairs in a single message: name value name value ...
    for i = 1, #args, 2 do
        name  = args[i]
        value = args[i+1]
        module._vars[name] = value
    end
end

-- Register dbus bus
capi.dbus.request_name("session", module.bus)
capi.dbus.connect_signal(module.bus, module.update_vars)

return module

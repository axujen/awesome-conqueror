local module = {}

local capi  = { dbus = dbus }
local awful = require('awful')
local timer = require('gears.timer')

module.dbus  = {
    iface = "org.awesomewm.conqueror",
    conky = "org.awesomewm.conky",
    path  = "/"
}
module._vars   = {}
module._updates = 0

-- Parse a conky 
function module.register(expr, args)
    local args    = args or {}
    local name    = args.name or expr
    local timeout = args.timeout or 1
    local default = args.default or ""
    local started = args.started or true

    if not module._vars[name] then
        module._vars[name] = { expr = expr, timeout = timeout, started = started, value = default }

        if not module._timer then -- create one
            module._timer  = timer{ timeout = 1, autostart = false, callback = module._conky_update }
        end
        if not module._timer.started and started then -- start updating
            module._timer:start()
        end
    end

    return module._vars[name]
end

-- function called to query conky for updates
function module._conky_update()
    if not next(module._vars) then 
        module._timer:stop()
    else
        for name,t in pairs(module._vars) do
            if t.started and module._updates % t.timeout == 0 then -- Expression specific timeout
                capi.dbus.emit_signal("session",module.dbus.path,module.dbus.conky,
                "conky_parse", "s", name, "s", t.expr)
            end
        end
    end
    module._updates = module._updates + 1
end


-- parse conky dbus messages
function module._parse_dbus(data, ...)
    if data.type == 'method_call' then
        if data.member == 'parse_result' then
            local args = {...}
            local name, value = args[1], args[2]
            module._vars[name].value = value
        end
    end
end

-- Register dbus bus
-- TODO: Verify that we have a connection, otherwise dont load the module
connected = capi.dbus.request_name("session", module.dbus.iface)
capi.dbus.connect_signal(module.dbus.iface, module._parse_dbus)

-- Start the special conky "server"
-- TODO: Figure out how to stop conky with awesome
local path     = package.searchpath('conqueror', package.path)
local cdcmd    = string.format([[cd "$(dirname '%s')/conky"]], path)
local conkycmd = [[conky -qdc conkyrc]]
awful.spawn.with_shell(string.format("%s && %s", cdcmd, conkycmd))

return module

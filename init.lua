-- [[
-- Licensed under GNU General Public License v2       
--  Copyright (C) 2017 axujen@autistici.org
-- ]]

-- TODO: Documentation, possibly LDoc?
local module = {}

local capi  = { dbus = dbus }
local awful = require('awful')
local wibox = require('wibox')

module.dbus  = {
    iface = "org.awesomewm.conqueror",
    conky = "org.awesomewm.conky",
    path  = "/"
}
module._vars      = {}
module._callbacks = {}
module._interval  = 0.5

-- Register a callback to be called everytime conky sends an update
function module.on_update(callback)
    table.insert(module._callbacks, callback)
    callback()  -- Run the callback so it can register new expressions with conky
end

-- Create a wibox.widget.textbox that will get updated through conky
function module.textbox(expr, ...)
    conkywidget = wibox.widget.textbox(nil, ...)
    module.on_update(function() conkywidget:set_markup(module._get_var(expr)) end)
    return conkywidget
end

-- Change conky's update interval
-- TODO: Proper OOP?
function module.set_interval(interval)
    module._interval = interval
    module._emit_signal('update_interval', interval)
end

function module.get_interval()
    return module._interval
end

-- Fetch the value of a conky expression, register it if its not already registered
function module._get_var(expr, init_value)
    local init_value = init_value or ""
    return module._vars[expr] or module._register_var(expr, init_value)
end

-- register a conky expression to be parsed
function module._register_var(expr, init_value)
    module._vars[expr] = init_value
    module._emit_signal('register', expr)

    return module._vars[expr]
end

-- emit a signal to conky
-- emit_signal(signal, args)
-- @args can either be a single argument or a table, all argments are passed as strings to dbus
function module._emit_signal(signal, args)
    if args then
        local out_args = {}
        if type(args) == 'table' then
            for _,arg in pairs(args) do
                table.insert(out_args, "s")
                table.insert(out_args, tostring(arg))
            end
        else
            out_args = { 's', tostring(args) }
        end
        capi.dbus.emit_signal("session",module.dbus.path, module.dbus.conky, signal, unpack(out_args))
    else
        capi.dbus.emit_signal("session",module.dbus.path, module.dbus.conky, signal)
    end
end

-- parse conky dbus messages
function module._parse_dbus(data, ...)
    if data.type == 'method_call' then
        if data.member == 'conky_results' then
            module._on_conky_results({...})
        elseif data.member == 'get_vars' then
            module._on_get_vars({...})
        end
    end
end

-- Called by conky to send its results
function module._on_conky_results(results)
    -- Update our variables
    for i = 1,#results,2 do
        local expr, value = results[i], results[i+1]
        module._vars[expr] = value
    end

    -- Fire callbacks
    for _,callback in pairs(module._callbacks) do
        callback()
    end
end

-- Called by conky on startup
function module._on_get_vars()
    for expr,_ in pairs(module._vars) do
        module._emit_signal('register', expr)
    end
end

--[[
    Conky and dbus initialization
--]]

-- Register dbus bus
-- TODO: Verify that we have the connection, otherwise dont load the module and throw and error
connected = capi.dbus.request_name("session", module.dbus.iface)
capi.dbus.connect_signal(module.dbus.iface, module._parse_dbus)

-- Start the special conky "server"
local path     = package.searchpath('conqueror', package.path)
local cdcmd    = string.format([[cd "$(dirname '%s')/conky"]], path)
local conkycmd = [[conky -qdc conkyrc]]
awful.spawn.with_shell(string.format("%s && %s", cdcmd, conkycmd))

-- Stop conky with awesome
-- TODO: Make this work when killing xephyr
awesome.connect_signal("exit", function(restart)
    if not restart then -- stop conky
        module._emit_signal("exit")
    end
end)

return setmetatable(module, { __call = function(_, ...) return module._get_var(...) end } )

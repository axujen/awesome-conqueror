local os    = require('os')
local ldbus = require('ldbus')
local dbus  = {
    conn = assert(ldbus.bus.get("session")),
    bus  = "org.conky.awesomewm",
    dest = "org.awesomewm.conky"
}

ret = ldbus.bus.request_name(dbus.conn, dbus.bus)
if ret ~= 'primary_owner' then
    print('Cannot connect to dbus')
    os.exit()
end

-- Emit a method_call through dbus
-- args is the list of the method args
function dbus.emit_method(dest, path, iface, method, args)
    local msg = ldbus.message.new_method_call(dest, path, iface, method)
    local iter = ldbus.message.iter.new()
    msg:iter_init_append(iter)

    for _,arg in pairs(args) do
        iter:append_basic(arg)
    end

    dbus.conn:send(msg)
    -- conn:flush() -- This is not needed?
end

local vars = {}
function register_var(var, eval)
    vars[var] = { eval = eval, value = nil }
end

function conky_update_awesome()
    local args = {}
    for name,var in pairs(vars) do
        var.value = conky_parse(var.eval)
        table.insert(args, name)
        table.insert(args, var.value)
    end
    -- contruct a single message with all the values to be sent to awesome
    dbus.emit_method(dbus.dest, "/", dbus.dest, "update_awesome", args)
end

register_var("CPU", "${cpu}")
register_var("MEM", "${mem}")

local dbus  = {}
local ldbus = require('ldbus')
local os    = require('os')

dbus.iface = "org.awesomewm.conky"
dbus.dest  = "org.awesomewm.conqueror"
dbus.path  = "/"

-- Initialize the dbus connection
function dbus.connect(name)
    name = name or dbus.iface

    ret, err = ldbus.bus.get("session")
    assert(ret, err)
    own, err = ldbus.bus.request_name(ret, name)
    assert(own, err)
    if own ~= 'primary_owner' then -- probably another conky instance is already running
        print('Conqueror: cannot connect to dbus interface, most likely another conky service is running')
        os.exit(1)
    end

    assert(ldbus.bus.add_match(ret, string.format("type='signal',path='%s',interface='%s'", dbus.path, dbus.iface)))
    return ret
end

-- Emit a method_call through dbus
-- args is the list of the method args
function dbus.send(method, args)
    local msg  = ldbus.message.new_method_call(dbus.dest, dbus.path, dbus.dest, method)

    if args then
        local iter = ldbus.message.iter.new()
        msg:iter_init_append(iter)
        for _,arg in pairs(args) do
            iter:append_basic(arg)
        end
    end

    dbus.conn:send(msg)
end

function dbus._parse_msg(msg)
    local iter   = ldbus.message.iter.new()
    local args   = msg:iter_init(iter)
    local member = msg:get_member()

    if args then
        args = { iter:get_basic() }
        while iter:next() do
            table.insert(args, iter:get_basic()) -- TODO Type validation here
        end
    end
    return member, args
end

-- Wait for dbus input from iface
function dbus.listen(iface)
    local iface = iface or dbus.iface

    while dbus.conn:read_write(0) do
        local msg = dbus.conn:pop_message()
        if msg then
            if msg:get_interface() == iface then -- just to make sure
                return dbus._parse_msg(msg)
            else
                return nil
            end
        end
        return
    end
end

dbus.conn = dbus.connect()
return setmetatable(dbus, { __call = dbus.connect })

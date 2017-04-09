local conky = {}
local dbus = require('dbus')

function conky.parse(eval)
    return conky_parse(eval)
end
function conky.update_awesome()
    method, args = dbus.listen()
    if not method then return end

    if method == 'conky_parse' then
        assert(args, 'conky_parse expecting argument for conky_parse') -- TODO Handle this
        local name, expr = args[1], args[2]
        value = conky.parse(expr)
        dbus.send('parse_result', {name, value} )
    end
end

function conky_mainloop()
    conky.update_awesome()
end

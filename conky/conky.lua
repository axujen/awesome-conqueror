local conky = { vars = {} }
local dbus  = require('dbus')
local os    = require('os')

function conky.listen_awesome()
    method, args = dbus.listen()

    if method == 'exit' then
        os.exit()
    elseif method == 'update_interval' then
        conky_set_update_interval(tonumber(args[1]))
    elseif method == 'register' then
        local expr = args[1]
        conky.vars[expr] = 1 -- storing expressions in keys so they're unique
    end
end

function conky.update_awesome()
    local results = {}

    for expr, _ in pairs(conky.vars) do
        local value = conky_parse(expr)
        table.insert(results, expr)
        table.insert(results, value)
    end

    if next(results) then
        dbus.send('conky_results', results)
    end
end

function conky_startup()
    -- request new values from awesome if awesome was already running
    dbus.send('get_vars')
end

function conky_mainloop()
    conky.listen_awesome()
    conky.update_awesome()
end

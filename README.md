Conqueror
=========
Conqueror is an [awesome](https://github.com/awesomeWM/awesome) module that allows you to use conky as a data source, enabling you to leverage the power of conky directly inside awesome to create any widget you wish.

Requirements
------------
 * [conky](https://github.com/brndnmtthws/conky)
 * [lua-ldbus](https://github.com/daurnimator/ldbus)

Installation
------------
Clone or download this repo to <pre>~/.config/awesome/<b>conqueror</b></pre>

Make sure the directory is called conqueror, otherwise conky will not launch automatically with awesome. (still working on that sorry :/)

Usage
-----
First you have to tell the module which conky [variables](http://conky.sourceforge.net/variables.html) you want to have available.
For now this is done thorugh ``conqueror/conky/conky.lua`` in the bottom add
``register_var(varname, expr)``

where name is the name you will use to access it inside rc.lua and expr is any conky expression you may wish to use.


then in ``rc.lua``

```lua
conky = require('conqueror').vars
```

this will let you access any value you registered through
```lua
conky.varname
```

note conky.value will return an empty string for any var accessed (even if its not registered). this is done to avoid errors at startup when conky has not updated anything yet.

Example
------------
-- ``conqueror/conky/conky.lua``

```lua
register_var("CPU", "{$cpu}")
register_var("MEM", "{$mem}")
```

-- ``rc.lua``

```lua
timer = require('gears.timer')
wibox = require('wibox')
conky = require('conqueror').vars

mycpuwidget = wibox.widget.textbox()
mymemwidget = wibox.widget.textbox()

cputimer = timer({ timeout = 5, autostart = true, callback = function() mycpuwidget:set_markup(conky.CPU) end })
memtimer = timer({ timeout = 5, autostart = true, callback = function() mymemwidget:set_markup(conky.MEM) end })
```

This will create two simple cpu and memory widgets that use conky as a data source, now of course you can do much more with conky so this is only an example to show you how to use the module.

TODO
--------
* Proper dbus error handling
* Allow registering conky vars inside awesome
* Replace lua-ldbus with lgi
* Provide more elaborate example widgets

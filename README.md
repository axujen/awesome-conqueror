Conqueror
=========
Conqueror is an [awesome](https://github.com/awesomeWM/awesome) module that allows you to use conky as a data source, enabling you to leverage the power of conky directly inside awesome to create any widget you wish.

Why use conqueror/conky instead of various widget libraries?
---------------------------------
- Also because conky has more [data](http://conky.sourceforge.net/variables.html) than your average widget library
- Because you can have widgets that update every 0.5 seconds and slow down your computer to a halt :)

But if you're looking for pre canned widgets then you're in the wrong place, conqueror is made to provide awesome with data, you can then use that data to make any kind of widget you want.

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
Conqueror will start its own conky instance, and communicate with it using dbus, conky will be stopped if awesome had a clean exit, if not then you should check your background processes to see if conky is still running.

Note that the conky started through conqueror will not interfere with your regular conky config, so you can still use conky normally if you wish.

Conqueror has three important functions to use:
* ``conqueror.textbox(expression)`` will return a ``wibox.widget.textbox`` that is automatically updated with ``expression`` being evaluated by conky
* conqueror(expression) will return the value of ``expression`` after conky evaluates it
* ``conqueror.on_update(callback)`` will execute callback for every conky update interval, you can then use ``conqueror(expression)`` inside the callback to update your widget more elaborately

Note that ``conqueror(expression)`` will by default return an empty string the first time it is ran on a new ``expression``, this is because conqueror will first have to tell conky to start updating evaluating the new expression.

Technically ``conqueror(expression)`` will return the last value that was sent by conky so it might take a couple of calls at first to get the value.

You can also set the conky update interval, which is set to 0.5 by default using ``conqueror.set_interval(interval)``, however this function is rather buggy at this moment so i dont recommend using it, instead change i suggest to change it in conqueror/conkyrc

Examples
------------

This will create a textwidget that will update with cpu memory and information plus a clock.

```lua
conqueror = require('conqueror')

myconkywidget = conqueror.textbox('$cpu% | $mem | $time)
```


To create a simple mpd widget with notifications from scratch
```lua
conqueror = require('conqueror')

mympdwidget = wibox.widget.textbox()
last_title = ""
conqueror.on_update(function() 
        local status = conqueror("$mpd_status")
        local title = conqueror("$mpd_title")
        local text = conqueror("$mpd_smart")

        if last_title ~= title and status == "Playing" then
        naughty.notify{ text = text }
        end
        last_title = title

        mympdwidget:set_markup(text)
end)
```


TODO
--------
* Proper dbus error handling
* Replace lua-ldbus with lgi (This possibly might never happen)
* Provide more elaborate example widgets
* Provide more complete documentation

Contact
-------
You can contact me through github or you can find me the on the awesome [irc channel](https://webchat.oftc.net/?channels=awesome) as axujen, usually idling so just highlight me and ill get back at you as soon as possible.

# Conqueror
Conqueror is an [awesome](https://github.com/awesomeWM/awesome) module that allows you to use conky as a data source, enabling you to create widgets that using conky expressions as their data.

# Table of Contents
1. [Why conqueror/conky](#why)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Loading](#loading)
5. [Usage](#usage)
6. [Examples](#examples)
7. [TODO](#todo)
8. [Contact](#contact)

## Why conqueror/conky <a name="why"></a>
- Conqueror allows you to build your own widgets using conky as a [data](http://conky.sourceforge.net/variables.html) source
- Because conky is faster than shell scripts and you can have widgets that update every 0.5 seconds and not slow down your computer to a halt :)

However if you're looking for pre-canned widgets then conqueror is not for your, conqueror does not provide any widgets on its own, it simply gives you the easily build practically any widget you wish.

## Requirements <a name="requirements"></a>
 * [conky](https://github.com/brndnmtthws/conky)
 * [lua-ldbus](https://github.com/daurnimator/ldbus)

## Installation <a name="installation"></a>
Clone or download this repo to <pre>~/.config/awesome/<b>conqueror</b></pre>

Make sure the directory is called conqueror, otherwise conky will not launch automatically with awesome. (still working on that sorry :/)

## Loading <a name="loading"></a>
Currently conqueror is loaded in two steps
first the awesome module is loaded the usual way by adding `require('conqueror')` to rc.lua

The second step is starting conky.
- For systems with awesome compiled with lua5.2 or higher, this can be done automatically by adding `conqueror.conky_launch()` to rc.lua

- For systems with lua5.1 or lower this has to be done manually for the time being by starting conky and pointing it to the shipped [conkyrc](https://github.com/axujen/awesome-conqueror/blob/master/conky/conkyrc). in the conky directory.
	
    A shell script to do this would look like:
	```sh
	#!/bin/env sh
	cd path/to/conqueror/conky
	conky -qdc ./conkyrc
	```
	NOTE: you must be in the conqueror/conky directory before you start conky. otherwise it will fail to load its lua module

## Usage <a name="usage"></a>
Conqueror will start its own conky instance, and communicate with it using dbus, conky will be stopped if awesome had a clean exit, if not then you should check your background processes to see if conky is still running.

Note that the conky started through conqueror will not interfere with your regular conky config, so you can still use conky normally if you wish.

Conqueror has three important functions to use:
* `conqueror.textbox(expression)` will return a ``wibox.widget.textbox`` that is automatically updated with [expression](http://conky.sourceforge.net/variables.html) being evaluated by conky
* `conqueror(expression)` will return the value of `expression` after conky evaluates it
* `conqueror.on_update(callback)` will execute callback for every conky update interval, you can then use `conqueror(expression)` inside the callback function to update your widgets more elaborately

Note that `conqueror(expression)` will by default return an empty string the first time it is ran on any new `expression`, this is because conqueror will first have to tell conky to start evaluating the new expression, and its new value will be fetched the next time conky sends an update.

Technically `conqueror(expression)` will return the last value that was sent by conky so it might take a couple of calls at first to get the value.

You can also set the conky update interval, which is set to 0.5 by default using `conqueror.set_interval(interval)`, however this function is rather buggy at this moment so i dont recommend using it, instead i suggest to change it in conqueror/conkyrc


## Examples <a name="examples"></a>
The following examples assume you are running awesome compiled with lua5.2.
If you have lua5.1 or lower remove `conqueror.conky_launch()` and start conky manually. See [Loading](#loading) for more details.

- Create a textwidget that will update with cpu memory and information plus a clock.

	```lua
    conqueror = require('conqueror')
    conqueror.conky_launch()
    
    myconkywidget = conqueror.textbox('$cpu% | $mem | $time)
    ```


- Create a simple mpd widget with notifications from scratch
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
## TODO <a name="todo"></a>
* Proper dbus error handling
* Load conky automatically in systems with lua5.1
* Provide more elaborate example widgets
* Provide more complete documentation
* Replace lua-ldbus with lgi (This possibly might never happen)

## Contact <a name="contact"></a>
You can contact me through github or you can find me the on the awesome [irc channel](https://webchat.oftc.net/?channels=awesome) as axujen, usually idling so just highlight me and ill get back at you as soon as possible.
# evil-weather
DFHack LUA script to find regions with evil weather

# install
Requires that DFHack be installed

Place evil-weather.lua in hack/scripts

Launch Dwarf Fortress with DFHack

Load your world in Legends mode

Type "evil-weather" into DFHack console

# output
Lists evil weather types in your world. Under each type are some details. For example, a world with one evil weather type may show:

> EVIL_RAIN_11	[STATE_NAME:LIQUID:malodorous ooze]
> 	(no syndrome effects)
>
> 	The Mucous Winter

This means:
* EVIL_RAIN_11 is how Dwarf Fortress identifies this weather internally
* It is a liquid weather (as opposed to gas cloud)
* It is called "malodorous ooze"
* It does not cause any magical effects by touching creatures
* There is an area of the world called "The Mucous Winter" where this weather occurs

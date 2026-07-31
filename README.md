# evil-weather
DFHack LUA script to find regions with evil weather.

Tested with Dwarf Fortress v53.15

# install
Requires that DFHack be installed

Place evil-weather.lua in hack/scripts

Launch Dwarf Fortress with DFHack

Load your world in Legends mode

Type "evil-weather" into DFHack console

# output
Lists evil weather types in your world, and the regions where each one occurs. For example, a world with one evil weather type may show:

> found evil weather in:
>  The Mucous Winter - 84% dead - reanimating
>
> \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
> \* weather details:
> \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
> EVIL_CLOUD_1	gas	evil smoke
>
> \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
> \* syndrome caused by weather:
> \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*
> 	[CE_NECROSIS:SEV:100:PROB:100:START:0:PEAK:200:END:2158:LOCALIZED:VASCULAR_ONLY]

This means:
* There is an area of the world called "The Mucous Winter" where this weather occurs
* 84% of the plants there are dead, and corpses become undead monsters
* EVIL_CLOUD_1 is how Dwarf Fortress identifies this weather internally
* It is a gas cloud (as opposed to liquid rain)
* It is called "evil smoke"
* Touching it causes necrosis

A weather type that causes no magical effects shows "(no syndrome effects)" instead.

# subcommands
* `evil-weather reanimating` - regions where corpses become undead monsters
* `evil-weather dead` - regions where the plants are dying
* `evil-weather cloud` - only evil clouds
* `evil-weather rain` - only evil rain

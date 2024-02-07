#include "void.qh"

#ifdef SVQC

/*QUAKED func_void (.5 .2 0) ?
for holes into which one should not fall

Texture this with black (or sky?) and cover the bottom of the pit with it.  Automatically offsets its own visual model upward, to hide pesky heads and scrag corpses underneath.  Also automatically spawns a start-of-plunge trigger of the same size "height" units above itself that plays a yell sound and fades out the view of clients as they start to fall in.

The player's view will have faded completely by the time they touch the bottom, so we hold them in stasis for a little while longer there before splatting them, to imply the pit is deeper than it really is. The player can therefore feel like they fall for a long time before crash landing in darkness without you having to build a pit that deep.

Keyvalues
"delay" how long the player should 'fall' before the splat, default 3
"height" how high above the func_void the plunge trigger should spawn. do not make this high enough that players will touch it without falling in or they'll hear random screaming noises as they walk around and that'll be strange. default 128
"lip" distance to raise the visual model, default 32
"fadecolor" color to fade the screen to while falling, default black
"noise"/"noise2" override fall and splat sounds

Fires all "target"s/"killtarget"s when a client touches the plunge trigger (ie the yell, not the splat).
If the func_void's first target is an info_teleport_destination, it will hurt the player for "dmg" damage and teleport him to the destination. If "dmg" is enough to kill the player when he falls in, it continues with the fade and splat as normal.
*/
/*FGD
@SolidClass base(Target, Appearflags) color(128 50 0) = func_void : 
"for holes into which one should not fall

Texture this with black (or sky?) and cover the bottom of the pit with it.  Automatically offsets its own visual model upward, to hide pesky heads and scrag corpses underneath.  Also automatically spawns a start-of-plunge trigger of the same size 'height' units above itself that plays a yell sound and fades out the view of clients as they start to fall in.

The player's view will have faded completely by the time they touch the bottom, so we hold them in stasis for a little while longer there before splatting them, to imply the pit is deeper than it really is. The player can therefore feel like they fall for a long time before crash landing in darkness without you having to build a pit that deep.

Fires all targets when a client touches the plunge trigger (ie the yell, not the splat).

If the func_void's first target is an info_teleport_destination, it will hurt the player and teleport him to the destination. If the damage is enough to kill the player, it continues with the fade and splat as normal without teleporting."
[
	delay(string) : "how long the player should 'fall' before the splat" : "3"
	height(integer) : "how high above the func_void the plunge trigger should spawn. do not make this high enough that players will touch it without falling in or they'll hear random screaming noises as they walk around and that'll be strange." : 128
	lip(integer) : "distance to raise the visual model" : 32
	dmg(integer) : "pain to apply before salvation teleport" : 60
	fadecolor(string) : "color to fade the screen to while falling" : "0 0 0"
	noise(string) : "fall sound" : "player/q3fall.wav"
	noise2(string) : "splat sound" : "player/splat1.wav"
]
*/
spawnfunc(trigger_hurt);
spawnfunc(func_void)
{
	this.dmg = 5000;

	this.spawnfunc_checked = true;
	spawnfunc_trigger_hurt(this);
}

#endif

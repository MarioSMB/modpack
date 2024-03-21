#ifdef SVQC

void trigger_skill_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	cvar_set("skill", this.message);
}

/*QUAKED trigger_setskill(.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
spawnfunc(trigger_setskill)
{
	InitTrigger(this);
	settouch(this, trigger_skill_touch);
}


void target_setskill_use(entity this, entity actor, entity trigger)
{
	if(!IS_PLAYER(actor))
		return;

	cvar_set("skill", this.message);
}

/*FGD
@baseclass = Setskill [
	message(choices) : "Skill" : 0 = [
		0 : "Easy"
		1 : "Normal"
		2 : "Hard"
		3 : "NIGHTMAAARE"
	]
]
*/

/*QUAKED target_setskill (.65 .0 .65) (-8 -8 -8) (8 8 8)
Sets skill level to the value of "message". Only used on start map.

Keys:
"message"
    sets skill level
    0 = easy
    1 = normal
    2 = hard
    3 = nightmare
*/
/*FGD
@PointClass base(Setskill, Targetname) color(160 0 160) = target_setskill : "Target: Set Skill" []
*/
spawnfunc(target_setskill)
{
	this.use = target_setskill_use;
}

#endif

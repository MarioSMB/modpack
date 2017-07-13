// Random.qc

// =======================================================
// Random Items!
// =======================================================

// equal divisions of 1:
// 5: 0.2, 0.4, 0.6, 0.8, 1
// 6: 0.16, 0.33, 0.48, 0.66, 0.83, 1
// 7: 0.14, 0.28, 0.43, 0.56, 0.71, 0.86, 1
// 8: 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1
void random_pick_type(entity this)
{
	float randItem = random();
	
	settouch(this, powerup_touch);
	setsize(this, '-16 -16 -24', '16 16 32');

	if(randItem < 0.2)
	{
		settouch(this, newitems_touch);
		this.noise = "shield/pickup.wav";
		_setmodel(this, "progs/shield.mdl");
		this.netname = "Power Shield";
		this.items = IT_SHIELD;
//		if(norandom == 1)
//			this.classname = "item_powerup_shield";
	}
	else if(randItem < 0.4)
	{
		settouch(this, newitems_touch);
		this.noise = "belt/pickup.wav";
		_setmodel(this, "progs/beltup.mdl");
		this.netname = "Anti-Grav Belt";
		this.items = IT_ANTIGRAV;
//		if(norandom == 1)
//			this.classname = "item_powerup_belt";
	}
	else if(randItem < 0.6)
	{
		this.noise = "items/protect.wav";
		_setmodel(this, "progs/invulner.mdl");
		this.netname = "Pentagram of Protection";
		this.items = IT_INVULNERABILITY;
//		if(norandom == 1)
//			this.classname = "item_artifact_invulnerability";
	}
	else if(randItem < 0.8)
	{
		this.noise = "items/inv1.wav";
		_setmodel(this, "progs/invisibl.mdl");
		this.netname = "Ring of Shadows";
		this.items = IT_INVISIBILITY;
//		if(norandom == 1)
//			this.classname = "item_artifact_invisibility";
	}
	else
	{
		this.noise = "items/damage.wav";
		_setmodel(this, "progs/quaddama.mdl");
		this.netname = "Quad Damage";
		this.items = IT_QUAD;
//		if(norandom == 1)
//			this.classname = "item_artifact_super_damage";
	}
}

/*QUAKED item_random_powerup (0 .5 .8) (-16 -16 -24) (16 16 32)
The Random Box!

Contains a random powerup.
*/
spawnfunc(item_random_powerup)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(!deathmatch) { delete(this); return; }
	
	// Precache the lot of it....
	precache_model("progs/shield.mdl");
	precache_model("progs/p_shield.mdl");
	precache_model("progs/beltup.mdl");
	precache_model("progs/invulner.mdl");
	precache_model("progs/invisibl.mdl");
	precache_model("progs/quaddama.mdl");

	precache_sound("items/inv1.wav");
	precache_sound("items/inv2.wav");
	precache_sound("items/inv3.wav");
	precache_sound("items/protect.wav");
	precache_sound("items/protect2.wav");
	precache_sound("items/protect3.wav");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");

	precache_sound("belt/pickup.wav");
	precache_sound("belt/use.wav");
	precache_sound("belt/fadeout.wav");
	precache_sound("shield/pickup.wav");
	precache_sound("shield/hit.wav");
	precache_sound("shield/fadeout.wav");

	random_pick_type(this);
	StartItem(this);
}

void random_regen(entity this)
{
	random_pick_type(this);
	SUB_regen(this);
}

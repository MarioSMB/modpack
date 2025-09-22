#include "shub.qh"

#ifdef SVQC
const int anim_old_old = 0; //'0 45 0'
const int anim_old_shake = 46; //'46 65 0'

const float ATTN_SHUB = 0.05; // almost infinite but not quite

.float strength;

void shub_lightstyle(entity this, int lightnum, string lightid)
{
	if(this.charmed || (this.target == "" || !this.target) || (world.model != "maps/end.bsp" && world.model != "maps/udobend.bsp"))
		return;
	lightstyle(lightnum, lightid);
}

//void old_stand(entity this) { set_animofs(this, anim_old_old, 1, old_stand); }

void old_idle1(entity this);
void old_idle46(entity this) { set_animofs(this, anim_old_old, 46, old_idle1); }
void old_idle45(entity this) { set_animofs(this, anim_old_old, 45, old_idle46); }
void old_idle44(entity this) { set_animofs(this, anim_old_old, 44, old_idle45); }
void old_idle43(entity this) { set_animofs(this, anim_old_old, 43, old_idle44); }
void old_idle42(entity this) { set_animofs(this, anim_old_old, 42, old_idle43); }
void old_idle41(entity this) { set_animofs(this, anim_old_old, 41, old_idle42); }
void old_idle40(entity this) { set_animofs(this, anim_old_old, 40, old_idle41); }
void old_idle39(entity this) { set_animofs(this, anim_old_old, 39, old_idle40); }
void old_idle38(entity this) { set_animofs(this, anim_old_old, 38, old_idle39); }
void old_idle37(entity this) { set_animofs(this, anim_old_old, 37, old_idle38); }
void old_idle36(entity this) { set_animofs(this, anim_old_old, 36, old_idle37); }
void old_idle35(entity this) { set_animofs(this, anim_old_old, 35, old_idle36); }
void old_idle34(entity this) { set_animofs(this, anim_old_old, 34, old_idle35); }
void old_idle33(entity this) { set_animofs(this, anim_old_old, 33, old_idle34); }
void old_idle32(entity this) { set_animofs(this, anim_old_old, 32, old_idle33); }
void old_idle31(entity this) { set_animofs(this, anim_old_old, 31, old_idle32); }
void old_idle30(entity this) { set_animofs(this, anim_old_old, 30, old_idle31); }
void old_idle29(entity this) { set_animofs(this, anim_old_old, 29, old_idle30); }
void old_idle28(entity this) { set_animofs(this, anim_old_old, 28, old_idle29); }
void old_idle27(entity this) { set_animofs(this, anim_old_old, 27, old_idle28); }
void old_idle26(entity this) { set_animofs(this, anim_old_old, 26, old_idle27); }
void old_idle25(entity this) { set_animofs(this, anim_old_old, 25, old_idle26); }
void old_idle24(entity this) { set_animofs(this, anim_old_old, 24, old_idle25); }
void old_idle23(entity this) { set_animofs(this, anim_old_old, 23, old_idle24); }
void old_idle22(entity this) { set_animofs(this, anim_old_old, 22, old_idle23); }
void old_idle21(entity this) { set_animofs(this, anim_old_old, 21, old_idle22); }
void old_idle20(entity this) { set_animofs(this, anim_old_old, 20, old_idle21); }
void old_idle19(entity this) { set_animofs(this, anim_old_old, 19, old_idle20); }
void old_idle18(entity this) { set_animofs(this, anim_old_old, 18, old_idle19); }
void old_idle17(entity this) { set_animofs(this, anim_old_old, 17, old_idle18); }
void old_idle16(entity this) { set_animofs(this, anim_old_old, 16, old_idle17); }
void old_idle15(entity this) { set_animofs(this, anim_old_old, 15, old_idle16); }
void old_idle14(entity this) { set_animofs(this, anim_old_old, 14, old_idle15); }
void old_idle13(entity this) { set_animofs(this, anim_old_old, 13, old_idle14); }
void old_idle12(entity this) { set_animofs(this, anim_old_old, 12, old_idle13); }
void old_idle11(entity this) { set_animofs(this, anim_old_old, 11, old_idle12); }
void old_idle10(entity this) { set_animofs(this, anim_old_old, 10, old_idle11); }
void old_idle9(entity this) { set_animofs(this, anim_old_old, 9, old_idle10); }
void old_idle8(entity this) { set_animofs(this, anim_old_old, 8, old_idle9); }
void old_idle7(entity this) { set_animofs(this, anim_old_old, 7, old_idle8); }
void old_idle6(entity this) { set_animofs(this, anim_old_old, 6, old_idle7); }
void old_idle5(entity this) { set_animofs(this, anim_old_old, 5, old_idle6); }
void old_idle4(entity this) { set_animofs(this, anim_old_old, 4, old_idle5); }
void old_idle3(entity this) { set_animofs(this, anim_old_old, 3, old_idle4); }
void old_idle2(entity this) { set_animofs(this, anim_old_old, 2, old_idle3); }
void old_idle1(entity this) { set_animofs(this, anim_old_old, 1, old_idle2); }

void old_thrash1(entity this);
void old_thrash20(entity this)
{
	set_animofs(this, anim_old_shake, 20, old_thrash20);
#if 0
	if(!(this.spawnflags & 1) && this.health <= 0)
	{
		if(this.strength > 0)
		{
			this.strength -= 1;
			setthink(this, old_thrash1);
		}
		return;
	}
#endif
	sound(this, CH_TRIGGER_SINGLE, SND_Null, 1, ATTN_SHUB);
	if(this.strength > 0 && this.health > 0)
	{
		shub_lightstyle(this, 0, "m");
		setthink(this, old_idle1);
		return;
	}
	finale_4(this);
}
void old_thrash19(entity this) { set_animofs(this, anim_old_shake, 19, old_thrash20); shub_lightstyle(this, 0, "a"); }
void old_thrash18(entity this) { set_animofs(this, anim_old_shake, 18, old_thrash19); shub_lightstyle(this, 0, "b"); }
void old_thrash17(entity this) { set_animofs(this, anim_old_shake, 17, old_thrash18); shub_lightstyle(this, 0, "c"); }
void old_thrash16(entity this) { set_animofs(this, anim_old_shake, 16, old_thrash17); shub_lightstyle(this, 0, "g"); }
void old_thrash15(entity this)
{
	set_animofs(this, anim_old_shake, 15, old_thrash16);
	shub_lightstyle(this, 0, "m");
	if(!(this.spawnflags & 1) && this.health <= 0)
	{
		this.cnt += 1;
		if(this.cnt < 3)
			setthink(this, old_thrash1);
	}
}
void old_thrash14(entity this) { set_animofs(this, anim_old_shake, 14, old_thrash15); shub_lightstyle(this, 0, "m"); }
void old_thrash13(entity this) { set_animofs(this, anim_old_shake, 13, old_thrash14); shub_lightstyle(this, 0, "k"); }
void old_thrash12(entity this) { set_animofs(this, anim_old_shake, 12, old_thrash13); shub_lightstyle(this, 0, "i"); }
void old_thrash11(entity this) { set_animofs(this, anim_old_shake, 11, old_thrash12); shub_lightstyle(this, 0, "g"); }
void old_thrash10(entity this) { set_animofs(this, anim_old_shake, 10, old_thrash11); shub_lightstyle(this, 0, "e"); }
void old_thrash9(entity this) { set_animofs(this, anim_old_shake, 9, old_thrash10); shub_lightstyle(this, 0, "c"); }
void old_thrash8(entity this) { set_animofs(this, anim_old_shake, 8, old_thrash9); shub_lightstyle(this, 0, "a"); }
void old_thrash7(entity this) { set_animofs(this, anim_old_shake, 7, old_thrash8); shub_lightstyle(this, 0, "c"); }
void old_thrash6(entity this) { set_animofs(this, anim_old_shake, 6, old_thrash7); shub_lightstyle(this, 0, "e"); }
void old_thrash5(entity this) { set_animofs(this, anim_old_shake, 5, old_thrash6); shub_lightstyle(this, 0, "g"); }
void old_thrash4(entity this) { set_animofs(this, anim_old_shake, 4, old_thrash5); shub_lightstyle(this, 0, "i"); }
void old_thrash3(entity this) { set_animofs(this, anim_old_shake, 3, old_thrash4); shub_lightstyle(this, 0, "k"); }
void old_thrash2(entity this) { set_animofs(this, anim_old_shake, 2, old_thrash3); shub_lightstyle(this, 0, "k"); }
void old_thrash1(entity this)
{
	set_animofs(this, anim_old_shake, 1, old_thrash2);
	shub_lightstyle(this, 0, "m");
	_sound(this, CH_TRIGGER_SINGLE, "boss2/death.wav", 1, ATTN_SHUB);

	// only do epic screen shakes on special ending maps
	if(world.model == "maps/end.bsp" || world.model == "maps/udobend.bsp")
		screenshake_oneshot(this, 0.2, 0.8, 0.8, 1.5);
}

//============================================================================

void shub_dudecycle(entity this)
{
	this.frame += 1;
	if(autocvar_skill > 2)
	{
		if(this.frame > 28)
			this.frame = 17;
	}
	else
	{
		if(this.frame > 16)
			this.frame = 12; 
	}
	this.nextthink = time + 0.1;
}

void finale_intermission(entity this)
{
	intermission_exittime = time + 10000000;	// never allow exit
	intermission_running = 1;

	server_reset();

	// find the intermission spot
	entity pos = FindIntermission(this);
	entity pl = find(NULL, classname, "misc_teleporttrain");
	if(pl)
	{
		if(pl.buddy)
		{
			stopsound(pl.buddy, CH_TRIGGER_SINGLE);
			delete(pl.buddy);
		}
		stopsound(pl, CH_TRIGGER_SINGLE);
		delete(pl);
	}

	WriteByte(MSG_ALL, SVC_FINALE);
	WriteString(MSG_ALL, "");

	intermission_moveplayers(pos);
}

void finale_1(entity this, entity inflictor, entity attacker, int deathtype)
{
	bool no_end = !find(NULL, classname, "trigger_changelevel");

	if(!this.charmed && ((this.target && this.target != "") || no_end))
		finale_intermission(this);

	// make fake versions of all players as standins, and move the real
	// players to the intermission spot

	// used later to tell if a telefragging player should appear
	this.count = (!this.charmed && ((this.target && this.target != "") || no_end) && deathtype == DEATH_TELEFRAG.m_id);
	
	// wait for 1 second
	entity timer = spawn();
	timer.owner = this;
	timer.enemy = attacker;
	timer.nextthink = time + 1;
	setthink(timer, finale_2);
}

void finale_2(entity this)
{
	// start a teleport splash inside shub
	entity shub = this.owner;

	vector org = shub.origin - '0 100 0';
	setorigin(this, org);

	if(this.count)
	{
		te_teleport(org);
		sound(shub, CH_VOICE, SND_TELE1, 1, ATTN_NORM);
	}
	
	this.nextthink = time + 2;
	setthink(this, finale_3);
}

void finale_3(entity this)
{
	entity shub = this.owner;
	shub.enemy = this.enemy;
	// start shub thrashing wildly
	setthink(shub, old_thrash1);
	shub_lightstyle(this, 0, "abcdefghijklmlkjihgfedcb");	
	delete(this);
}

void finale_4(entity this)
{
	//entity shub = this.owner;

	// throw tons of meat chunks
	_sound(this, CH_TRIGGER_SINGLE, "boss2/pop2.wav", 1, ATTN_SHUB);
	
	vector oldo = this.origin;

	float zz = 16;
	while(zz <= 144)
	{
		float xx = -64;
		while(xx <= 64)
		{
			float yy = -64;
			while(yy <= 64)
			{
				this.origin_x = oldo_x + xx;
				this.origin_y = oldo_y + yy;
				this.origin_z = oldo_z + zz;

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, this, "progs/gib1.mdl", -999);
				else if(r < 0.6)
					ThrowGib(this, this, "progs/gib2.mdl", -999);
				else
					ThrowGib(this, this, "progs/gib3.mdl", -999);
				yy = yy + 32;
			}
			xx = xx + 32;
		}
		zz = zz + 96;
	}
	if(!this.charmed && this.target && this.target != "")
	{
		if(this.health > 0 && !intermission_running)
			finale_intermission(this);

		// start the end text
		WriteByte(MSG_ALL, SVC_FINALE);
		WriteString(MSG_ALL, "Congratulations and well done! You have\nbeaten the hideous Shub-Niggurath, and\nher hundreds of ugly changelings and\nmonsters. You have proven that your\nskill and your cunning are greater than\nall the powers of Quake. You are the\nmaster now. Team Xonotic salutes you.");
		// put a player model down, but only if it was a telefrag!
		if(this.count)
		{
			entity n = spawn();
			if(this.enemy)
			{
				_setmodel(n, get_playermodel(this.enemy));
				n.colormap = this.enemy.colormap;
			}
			else
			{
				_setmodel(n, "progs/player.mdl");
				n.colormap = 1024;
			}
			if(autocvar_skill > 2)	// axe on nightmare because you are very badass
			{
				n.angles_y -= 35;
				n.frame = 17 + floor(random() * 9.9);
			}
			else
			{
				n.angles_y += 25;
				n.frame = 12 + floor(random() * 2.9);
			}
			makevectors(this.angles);
			n.angles = this.angles;
			setorigin(n, oldo + v_forward * 128);
			setthink(n, shub_dudecycle);
			n.nextthink = time + 0.1;
			//oldo = oldo - '32 264 0';
			//setorigin(n, oldo);
			//n.angles = '0 290 0';
			n.frame = 1;
		}

		// switch cd track
	#if 0
		WriteByte(MSG_ALL, SVC_CDTRACK);
		WriteByte(MSG_ALL, 3);
		WriteByte(MSG_ALL, 3);
	#else
		SendCDTrack(NULL, 3);
	#endif
	}
	shub_lightstyle(this, 0, "m");

	delete(this);

	// NOTE: disabled as classic engines do not support credits (TODO: xonotic does? maybe make use of it!)
	// instead of sitting here forever, run the quake ex credits and send the user back to start
	//entity timer = spawn();
	//timer.nextthink = time + 1;
	//setthink(timer, finale_5);
}

void shub_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(intermission_running)
		return; // don't trigger twice

	if((this.spawnflags & 1) && !this.charmed)
		finale_4(this);
	else
		finale_1(this, inflictor, attacker, deathtype);
}

void shub_use(entity this, entity actor, entity trigger)
{
	if(this.health <= 0 || this.strength <= 0)
		return;
	this.strength -= 1;
	this.enemy = actor;
	if(this.strength <= 0 && IS_PLAYER(actor))
		this.count = 1;
	old_thrash1(this);
}

//============================================================================


/*QUAKED monster_oldone(1 0 0)(-16 -16 -24)(16 16 32)
*/
spawnfunc(monster_oldone) { monster_start(this, true, MON_SHUB); }

// Ritual compat
spawnfunc(monster_newone) { monster_start(this, true, MON_SHUB); }
#endif // SVQC

#ifdef SVQC
METHOD(Shub, mr_setup, bool(Shub this, entity actor))
{
	TC(Shub, this);

	precache_sound("boss2/death.wav");
	precache_sound("boss2/idle.wav");
	precache_sound("boss2/pop2.wav");

	if(!actor.strength)
		actor.strength = 3;

	actor.health = 4000;
	actor.th_stand = old_idle1;
	actor.th_walk = old_idle1;
	actor.th_run = old_idle1;
	actor.nextthink = time + 0.1;	
	actor.takedamage = DAMAGE_YES;
	actor.th_pain = func_null;
	actor.th_die = shub_die;

	actor.use = shub_use;

	return true;
}
#endif

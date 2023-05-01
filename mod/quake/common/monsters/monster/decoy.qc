#include "decoy.qh"

#ifdef SVQC
const int anim_decoy_axrun1 = 0;
const int anim_decoy_rockrun1 = 6;
const int anim_decoy_stand1 = 12;
const int anim_decoy_axstnd1 = 17;

void decoy_stand1(entity this)
{
	set_anim(this, anim_decoy_axstnd1, decoy_stand1);
	changeyaw(this);
	if(this.walkframe >= 5)
		this.walkframe = 0;
	this.frame = anim_decoy_stand1 + this.walkframe;
	this.walkframe = this.walkframe + 1;
	if(this.pausetime != -1 && time > this.pausetime)
		this.th_walk(this);
}

void decoy_pain(entity this, entity attacker, float damage)
{
	decoy_stand1(this);
}

void decoy_die(entity this, entity inflictor, entity attacker)
{
	decoy_stand1(this);
}

void decoy_walk1(entity this)
{
	set_anim(this, anim_decoy_rockrun1, decoy_walk1);
//   local vector a;
	movetogoal(this, 12);
//   a = '0 0 0';
//   a_y = this.ideal_yaw;
//   makevectors(a);
//   this.velocity = 1*v_forward;
	this.weaponframe = 0;
	if(this.walkframe == 6)
		this.walkframe = 0;
	if(this.walkframe == 2 || this.walkframe == 5)
	{
		float r = random();
		if(r < 0.14)
			_sound(this, CH_VOICE, "misc/foot1.wav", 0.5, ATTN_NORM);
		else if(r < 0.29)
			_sound(this, CH_VOICE, "misc/foot2.wav", 0.5, ATTN_NORM);
		else if(r < 0.43)
			_sound(this, CH_VOICE, "misc/foot3.wav", 0.5, ATTN_NORM);
		else if(r < 0.58)
			_sound(this, CH_VOICE, "misc/foot4.wav", 0.5, ATTN_NORM);
		else if(r < 0.72)
			_sound(this, CH_VOICE, "misc/foot5.wav", 0.5, ATTN_NORM);
		else if(r < 0.86)
			_sound(this, CH_VOICE, "misc/foot6.wav", 0.5, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "misc/foot7.wav", 0.5, ATTN_NORM);
	}
	this.frame = this.frame + this.walkframe;
	this.walkframe = this.walkframe + 1;
}

void become_decoy(string targ, vector orig)
{
	entity decoy = new(monster_decoy);
	setorigin(decoy, orig);
	decoy.target = targ;
	monster_start(decoy, MON_DECOY);
}

/*QUAKED monster_decoy (1 0 0) (-16 -16 -24) (16 16 40)
*/
spawnfunc(monster_decoy)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	monster_start(this, MON_DECOY);
}
#endif // SVQC

#ifdef SVQC
METHOD(Decoy, mr_setup, bool(Decoy this, entity actor))
{
    TC(Decoy, this);

	_setmodel(actor, "progs/player.mdl");
	setsize(actor, VEC_HULL_MIN, VEC_HULL_MAX);
	actor.view_ofs = '0 0 22';

	actor.solid = SOLID_SLIDEBOX;
	set_movetype(actor, MOVETYPE_STEP);

	actor.health = 3000000;

	actor.th_stand = decoy_stand1;
	actor.th_walk = decoy_walk1;
	actor.th_run = decoy_walk1;
	actor.th_missile = decoy_stand1;
	actor.th_pain = decoy_pain;
	actor.th_die = decoy_die;

	// TODO: multiplayer?
	entity pl = NULL;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		pl = it;
		break;
	});
	actor.colormap = pl.colormap;

    return true;
}
#endif

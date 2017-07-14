/*
==============================================================================

PLAYER decoy

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base
$skin skin

//
// running
//

const int anim_decoy_axrun1 = 0;
#if 0
const int anim_decoy_axrun2 = 1;
const int anim_decoy_axrun3 = 2;
const int anim_decoy_axrun4 = 3;
const int anim_decoy_axrun5 = 4;
const int anim_decoy_axrun6 = 5;
#endif

const int anim_decoy_rockrun1 = 6;
#if 0
const int anim_decoy_rockrun2 = 7;
const int anim_decoy_rockrun3 = 8;
const int anim_decoy_rockrun4 = 9;
const int anim_decoy_rockrun5 = 10;
const int anim_decoy_rockrun6 = 11;
#endif


//
// standing
//

const int anim_decoy_stand1 = 12;
#if 0
const int anim_decoy_stand2 = 13;
const int anim_decoy_stand3 = 14;
const int anim_decoy_stand4 = 15;
const int anim_decoy_stand5 = 16;
#endif

const int anim_decoy_axstnd1 = 17;
#if 0
const int anim_decoy_axstnd2 = 18;
const int anim_decoy_axstnd3 = 19;
const int anim_decoy_axstnd4 = 20;
const int anim_decoy_axstnd5 = 21;
const int anim_decoy_axstnd6 = 22;
const int anim_decoy_axstnd7 = 23;
const int anim_decoy_axstnd8 = 24;
const int anim_decoy_axstnd9 = 25;
const int anim_decoy_axstnd10 = 26;
const int anim_decoy_axstnd11 = 27;
const int anim_decoy_axstnd12 = 28;
#endif

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

void decoy_die(entity this, entity attacker)
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

void setup_decoy(entity decoy)
{
	decoy.classname = "monster_decoy";
	_setmodel(decoy, "progs/player.mdl");
	setsize(decoy, VEC_HULL_MIN, VEC_HULL_MAX);
	decoy.view_ofs = '0 0 22';

	// decoys are part of cutscenes, don't try to kill them!
	//if(!decoy.damagedbycontents)
		//IL_PUSH(g_damagedbycontents, decoy);
	//decoy.damagedbycontents	= true;

	decoy.solid = SOLID_SLIDEBOX;
	set_movetype(decoy, MOVETYPE_STEP);

	decoy.health = 3000000;

	decoy.th_stand = decoy_stand1;
	decoy.th_walk = decoy_walk1;
	decoy.th_run = decoy_walk1;
	decoy.th_missile = decoy_stand1;
	decoy.th_pain = decoy_pain;
	decoy.th_die = decoy_die;

	entity pl = NULL;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		pl = it;
		break;
	});
	decoy.colormap = pl.colormap;
}

/*QUAKED monster_decoy (1 0 0) (-16 -16 -24) (16 16 40)
*/
spawnfunc(monster_decoy)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	setup_decoy(this);

	monster_start(this, FL_DECOY); // to avoid counting
}

void become_decoy(string targ, vector orig)
{
	entity decoy = spawn();

	setup_decoy(decoy);
	setorigin(decoy, orig);
	decoy.origin = orig;
	decoy.target = targ;
	decoy.takedamage = DAMAGE_AIM;
	decoy.ideal_yaw = decoy.angles * '0 1 0';
	if(!decoy.yaw_speed)
		decoy.yaw_speed = 20;

	decoy.use = monster_use;
	decoy.flags |= FL_MONSTER;

	if(decoy.target)
	{
		decoy.goalentity = decoy.movetarget = find(NULL, targetname, decoy.target);
		decoy.ideal_yaw = vectoyaw(decoy.goalentity.origin - decoy.origin);
		if(!decoy.movetarget)
			LOG_DEBUGF("Monster can't find target at %s\n", vtos(decoy.origin));
// this used to be an objerror
		if(decoy.movetarget.classname == "path_corner")
			decoy.th_walk(decoy);
		else
		{
			decoy.pausetime = -1;
			decoy.th_stand(decoy);
		}
	}
	else
	{
		decoy.pausetime = -1;
		decoy.th_stand(decoy);
	}

// spread think times so they don't all happen at same time
	decoy.nextthink = decoy.nextthink + random() * 0.5;
}

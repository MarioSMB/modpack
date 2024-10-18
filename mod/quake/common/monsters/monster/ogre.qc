#include "ogre.qh"

#include "cook.qh"

#ifdef SVQC
const int anim_ogre_stand = 0; //'0 8 0'
const int anim_ogre_walk = 9; //'9 24 0'
const int anim_ogre_run = 25; //'25 32 0'
const int anim_ogre_swing = 33; //'33 46 0'
const int anim_ogre_smash = 47; //'47 60 0'
const int anim_ogre_shoot = 61; //'61 66 0'
const int anim_ogre_pain = 67; //'67 71 0'
const int anim_ogre_painb = 72; //'72 74 0'
const int anim_ogre_painc = 75; //'75 80 0'
const int anim_ogre_paind = 81; //'81 96 0'
const int anim_ogre_paine = 97; //'97 111 0'
const int anim_ogre_death = 112; //'112 125 0'
const int anim_ogre_bdeath = 126; //'126 135 0'
const int anim_ogre_pull = 136; //'136 146 0'

//=============================================================================

const int OGRE_BOSS = BIT(1);
const int OGRE_NORMAL = BIT(2);

void OgreGrenadeExplode(entity this)
{
	float damg = (this.dmg) ? this.dmg : 40;
	T_RadiusDamage(this, this.owner, damg, this.projectiledeathtype, NULL);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void OgreGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode(this);
		return;
	}
	_sound(this, CH_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

/*
================
OgreFireGrenade
================
*/
void MultiGrenadeTouch(entity this, entity toucher);
void MultiGrenadeExplode(entity this);

void OgreFireGrenade(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_OGRE.m_id;
	missile.classname = "ogre_grenade";
	missile.dmg = 40;
		
// set missile speed	

	fixedmakevectors(this.angles);

	missile.velocity = normalize(this.enemy.origin - this.origin);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	if((this.spawnflags & OGRE_BOSS))
	{
		settouch(missile, MultiGrenadeTouch);
		missile.nextthink = time + 2.5;
		setthink(missile, MultiGrenadeExplode);
		_setmodel(missile, "progs/mervup.mdl");
		setsize(missile, '0 0 0', '0 0 0');
		missile.classname = "MultiGrenade";
	}
	else
	{
		settouch(missile, OgreGrenadeTouch);
		missile.nextthink = time + 2.5;
		setthink(missile, OgreGrenadeExplode);
		_setmodel(missile, "progs/grenade.mdl");
		setsize(missile, '0 0 0', '0 0 0');		
		setorigin(missile, this.origin);
	}
}


//=============================================================================

/*
================
chainsaw
FIXME
================
*/
void chainsaw(entity this, float side)
{
	if(!this.enemy)
		return;
	if(!CanDamage(this.enemy, this))
		return;

	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 4;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_OGRE.m_id);
	
	if(side)
	{
		fixedmakevectors(this.angles);
		if(side == 1)
			SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
		else
			SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
	}
}

void ogre_stand1(entity this);
void ogre_stand9(entity this) { set_animofs(this, anim_ogre_stand, 9, ogre_stand1); ai_stand(this); }
void ogre_stand8(entity this) { set_animofs(this, anim_ogre_stand, 8, ogre_stand9); ai_stand(this); }
void ogre_stand7(entity this) { set_animofs(this, anim_ogre_stand, 7, ogre_stand8); ai_stand(this); }
void ogre_stand6(entity this) { set_animofs(this, anim_ogre_stand, 6, ogre_stand7); ai_stand(this); }
void ogre_stand5(entity this)
{
	set_animofs(this, anim_ogre_stand, 5, ogre_stand6);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}
void ogre_stand4(entity this) { set_animofs(this, anim_ogre_stand, 4, ogre_stand5); ai_stand(this); }
void ogre_stand3(entity this) { set_animofs(this, anim_ogre_stand, 3, ogre_stand4); ai_stand(this); }
void ogre_stand2(entity this) { set_animofs(this, anim_ogre_stand, 2, ogre_stand3); ai_stand(this); }
void ogre_stand1(entity this) { set_animofs(this, anim_ogre_stand, 1, ogre_stand2); ai_stand(this); }

void ogre_walk1(entity this);
void ogre_walk16(entity this) { set_animofs(this, anim_ogre_walk, 16, ogre_walk1); ai_walk(this, 4); }
void ogre_walk15(entity this) { set_animofs(this, anim_ogre_walk, 15, ogre_walk16); ai_walk(this, 3); }
void ogre_walk14(entity this) { set_animofs(this, anim_ogre_walk, 14, ogre_walk15); ai_walk(this, 3); }
void ogre_walk13(entity this) { set_animofs(this, anim_ogre_walk, 13, ogre_walk14); ai_walk(this, 3); }
void ogre_walk12(entity this) { set_animofs(this, anim_ogre_walk, 12, ogre_walk13); ai_walk(this, 3); }
void ogre_walk11(entity this) { set_animofs(this, anim_ogre_walk, 11, ogre_walk12); ai_walk(this, 2); }
void ogre_walk10(entity this) { set_animofs(this, anim_ogre_walk, 10, ogre_walk11); ai_walk(this, 1); }
void ogre_walk9(entity this) { set_animofs(this, anim_ogre_walk, 9, ogre_walk10); ai_walk(this, 3); }
void ogre_walk8(entity this) { set_animofs(this, anim_ogre_walk, 8, ogre_walk9); ai_walk(this, 2); }
void ogre_walk7(entity this) { set_animofs(this, anim_ogre_walk, 7, ogre_walk8); ai_walk(this, 3); }
void ogre_walk6(entity this)
{
	set_animofs(this, anim_ogre_walk, 6, ogre_walk7);
	ai_walk(this, 5);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
}
void ogre_walk5(entity this) { set_animofs(this, anim_ogre_walk, 5, ogre_walk6); ai_walk(this, 2); }
void ogre_walk4(entity this) { set_animofs(this, anim_ogre_walk, 4, ogre_walk5); ai_walk(this, 2); }
void ogre_walk3(entity this)
{
	set_animofs(this, anim_ogre_walk, 3, ogre_walk4);
	ai_walk(this, 2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
}
void ogre_walk2(entity this) { set_animofs(this, anim_ogre_walk, 2, ogre_walk3); ai_walk(this, 2); }
void ogre_walk1(entity this) { set_animofs(this, anim_ogre_walk, 1, ogre_walk2); ai_walk(this, 3); }

void ogre_run1(entity this);
void ogre_run8(entity this) { set_animofs(this, anim_ogre_run, 8, ogre_run1); ai_run(this, 9); }
void ogre_run7(entity this) { set_animofs(this, anim_ogre_run, 7, ogre_run8); ai_run(this, 12); }
void ogre_run6(entity this) { set_animofs(this, anim_ogre_run, 6, ogre_run7); ai_run(this, 8); }
void ogre_run5(entity this) { set_animofs(this, anim_ogre_run, 5, ogre_run6); ai_run(this, 22); }
void ogre_run4(entity this) { set_animofs(this, anim_ogre_run, 4, ogre_run5); ai_run(this, 16); }
void ogre_run3(entity this) { set_animofs(this, anim_ogre_run, 3, ogre_run4); ai_run(this, 4); }
void ogre_run2(entity this) { set_animofs(this, anim_ogre_run, 2, ogre_run3); ai_run(this, 13); }
void ogre_run1(entity this)
{
	set_animofs(this, anim_ogre_run, 1, ogre_run2);
	ai_run(this, 24);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
}

void ogre_swing14(entity this) { set_animofs(this, anim_ogre_swing, 14, ogre_run1); ai_charge(this, 9); }
void ogre_swing13(entity this) { set_animofs(this, anim_ogre_swing, 13, ogre_swing14); ai_charge(this, 8); }
void ogre_swing12(entity this) { set_animofs(this, anim_ogre_swing, 12, ogre_swing13); ai_charge(this, 3); }
void ogre_swing11(entity this) { set_animofs(this, anim_ogre_swing, 11, ogre_swing12); chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing10(entity this) { set_animofs(this, anim_ogre_swing, 10, ogre_swing11); chainsaw(this, -200); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing9(entity this) { set_animofs(this, anim_ogre_swing, 9, ogre_swing10); chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing8(entity this) { set_animofs(this, anim_ogre_swing, 8, ogre_swing9); chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing7(entity this) { set_animofs(this, anim_ogre_swing, 7, ogre_swing8); chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing6(entity this) { set_animofs(this, anim_ogre_swing, 6, ogre_swing7); chainsaw(this, 200); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing5(entity this) { set_animofs(this, anim_ogre_swing, 5, ogre_swing6); ai_charge(this, 9); chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void ogre_swing4(entity this) { set_animofs(this, anim_ogre_swing, 4, ogre_swing5); ai_charge(this, 13); }
void ogre_swing3(entity this) { set_animofs(this, anim_ogre_swing, 3, ogre_swing4); ai_charge(this, 4); }
void ogre_swing2(entity this) { set_animofs(this, anim_ogre_swing, 2, ogre_swing3); ai_charge(this, 1); }
void ogre_swing1(entity this)
{
	set_animofs(this, anim_ogre_swing, 1, ogre_swing2);
	ai_charge(this, 11);
	_sound(this, CH_WEAPON_SINGLE, "ogre/ogsawatk.wav", 1, ATTN_NORM);
}

void ogre_smash14(entity this) { set_animofs(this, anim_ogre_smash, 14, ogre_run1); ai_charge(this, 12); }
void ogre_smash13(entity this) { set_animofs(this, anim_ogre_smash, 13, ogre_smash14); ai_charge(this, 4); }
void ogre_smash12(entity this) { set_animofs(this, anim_ogre_smash, 12, ogre_smash13); ai_charge(this, 0); }
void ogre_smash11(entity this) { set_animofs(this, anim_ogre_smash, 11, ogre_smash12); chainsaw(this, 2); this.nextthink = this.nextthink + random() * 0.2; /* slight variation */ }
void ogre_smash10(entity this) { set_animofs(this, anim_ogre_smash, 10, ogre_smash11); chainsaw(this, 1); }
void ogre_smash9(entity this) { set_animofs(this, anim_ogre_smash, 9, ogre_smash10); ai_charge(this, 13); chainsaw(this, 0); }
void ogre_smash8(entity this) { set_animofs(this, anim_ogre_smash, 8, ogre_smash9); ai_charge(this, 10); chainsaw(this, 0); }
void ogre_smash7(entity this) { set_animofs(this, anim_ogre_smash, 7, ogre_smash8); ai_charge(this, 4); chainsaw(this, 0); }
void ogre_smash6(entity this) { set_animofs(this, anim_ogre_smash, 6, ogre_smash7); ai_charge(this, 4); chainsaw(this, 0); }
void ogre_smash5(entity this) { set_animofs(this, anim_ogre_smash, 5, ogre_smash6); ai_charge(this, 4); }
void ogre_smash4(entity this) { set_animofs(this, anim_ogre_smash, 4, ogre_smash5); ai_charge(this, 1); }
void ogre_smash3(entity this) { set_animofs(this, anim_ogre_smash, 3, ogre_smash4); ai_charge(this, 0); }
void ogre_smash2(entity this) { set_animofs(this, anim_ogre_smash, 2, ogre_smash3); ai_charge(this, 0); }
void ogre_smash1(entity this)
{
	set_animofs(this, anim_ogre_smash, 1, ogre_smash2);
	ai_charge(this, 6);
	_sound(this, CH_WEAPON_SINGLE, "ogre/ogsawatk.wav", 1, ATTN_NORM);
}

void ogre_nail7(entity this) { set_animofs(this, anim_ogre_shoot, 6, ogre_run1); ai_face(this); }
void ogre_nail6(entity this) { set_animofs(this, anim_ogre_shoot, 5, ogre_nail7); ai_face(this); }
void ogre_nail5(entity this) { set_animofs(this, anim_ogre_shoot, 4, ogre_nail6); ai_face(this); }
void ogre_nail4(entity this) { set_animofs(this, anim_ogre_shoot, 3, ogre_nail5); ai_face(this); OgreFireGrenade(this); }
void ogre_nail3(entity this) { set_animofs(this, anim_ogre_shoot, 2, ogre_nail4); ai_face(this); }
void ogre_nail2(entity this) { set_animofs(this, anim_ogre_shoot, 2, ogre_nail3); ai_face(this); }
void ogre_nail1(entity this) { set_animofs(this, anim_ogre_shoot, 1, ogre_nail2); ai_face(this); }

void ogre_pain5(entity this) { set_animofs(this, anim_ogre_pain, 5, ogre_run1); }
void ogre_pain4(entity this) { set_animofs(this, anim_ogre_pain, 4, ogre_pain5); }
void ogre_pain3(entity this) { set_animofs(this, anim_ogre_pain, 3, ogre_pain4); }
void ogre_pain2(entity this) { set_animofs(this, anim_ogre_pain, 2, ogre_pain3); }
void ogre_pain1(entity this) { set_animofs(this, anim_ogre_pain, 1, ogre_pain2); }

void ogre_painb3(entity this) { set_animofs(this, anim_ogre_painb, 3, ogre_run1); }
void ogre_painb2(entity this) { set_animofs(this, anim_ogre_painb, 2, ogre_painb3); }
void ogre_painb1(entity this) { set_animofs(this, anim_ogre_painb, 1, ogre_painb2); }

void ogre_painc6(entity this) { set_animofs(this, anim_ogre_painc, 6, ogre_run1); }
void ogre_painc5(entity this) { set_animofs(this, anim_ogre_painc, 5, ogre_painc6); }
void ogre_painc4(entity this) { set_animofs(this, anim_ogre_painc, 4, ogre_painc5); }
void ogre_painc3(entity this) { set_animofs(this, anim_ogre_painc, 3, ogre_painc4); }
void ogre_painc2(entity this) { set_animofs(this, anim_ogre_painc, 2, ogre_painc3); }
void ogre_painc1(entity this) { set_animofs(this, anim_ogre_painc, 1, ogre_painc2); }

void ogre_paind16(entity this) { set_animofs(this, anim_ogre_paind, 16, ogre_run1); }
void ogre_paind15(entity this) { set_animofs(this, anim_ogre_paind, 15, ogre_paind16); }
void ogre_paind14(entity this) { set_animofs(this, anim_ogre_paind, 14, ogre_paind15); }
void ogre_paind13(entity this) { set_animofs(this, anim_ogre_paind, 13, ogre_paind14); }
void ogre_paind12(entity this) { set_animofs(this, anim_ogre_paind, 12, ogre_paind13); }
void ogre_paind11(entity this) { set_animofs(this, anim_ogre_paind, 11, ogre_paind12); }
void ogre_paind10(entity this) { set_animofs(this, anim_ogre_paind, 10, ogre_paind11); }
void ogre_paind9(entity this) { set_animofs(this, anim_ogre_paind, 9, ogre_paind10); }
void ogre_paind8(entity this) { set_animofs(this, anim_ogre_paind, 8, ogre_paind9); }
void ogre_paind7(entity this) { set_animofs(this, anim_ogre_paind, 7, ogre_paind8); }
void ogre_paind6(entity this) { set_animofs(this, anim_ogre_paind, 6, ogre_paind7); }
void ogre_paind5(entity this) { set_animofs(this, anim_ogre_paind, 5, ogre_paind6); }
void ogre_paind4(entity this) { set_animofs(this, anim_ogre_paind, 4, ogre_paind5); ai_pain(this, 4); }
void ogre_paind3(entity this) { set_animofs(this, anim_ogre_paind, 3, ogre_paind4); ai_pain(this, 9); }
void ogre_paind2(entity this) { set_animofs(this, anim_ogre_paind, 2, ogre_paind3); ai_pain(this, 10); }
void ogre_paind1(entity this) { set_animofs(this, anim_ogre_paind, 1, ogre_paind2); }

void ogre_paine15(entity this) { set_animofs(this, anim_ogre_paine, 15, ogre_run1); }
void ogre_paine14(entity this) { set_animofs(this, anim_ogre_paine, 14, ogre_paine15); }
void ogre_paine13(entity this) { set_animofs(this, anim_ogre_paine, 13, ogre_paine14); }
void ogre_paine12(entity this) { set_animofs(this, anim_ogre_paine, 12, ogre_paine13); }
void ogre_paine11(entity this) { set_animofs(this, anim_ogre_paine, 11, ogre_paine12); }
void ogre_paine10(entity this) { set_animofs(this, anim_ogre_paine, 10, ogre_paine11); }
void ogre_paine9(entity this) { set_animofs(this, anim_ogre_paine, 9, ogre_paine10); }
void ogre_paine8(entity this) { set_animofs(this, anim_ogre_paine, 8, ogre_paine9); }
void ogre_paine7(entity this) { set_animofs(this, anim_ogre_paine, 7, ogre_paine8); }
void ogre_paine6(entity this) { set_animofs(this, anim_ogre_paine, 6, ogre_paine7); }
void ogre_paine5(entity this) { set_animofs(this, anim_ogre_paine, 5, ogre_paine6); }
void ogre_paine4(entity this) { set_animofs(this, anim_ogre_paine, 4, ogre_paine5); ai_pain(this, 4); }
void ogre_paine3(entity this) { set_animofs(this, anim_ogre_paine, 3, ogre_paine4); ai_pain(this, 9); }
void ogre_paine2(entity this) { set_animofs(this, anim_ogre_paine, 2, ogre_paine3); ai_pain(this, 10); }
void ogre_paine1(entity this) { set_animofs(this, anim_ogre_paine, 1, ogre_paine2); }

void ogre_pain(entity this, entity attacker, float damage, int deathtype)
{
// don't make multiple pain sounds right after each other
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	float r = random();
	
	if(r < 0.25)
	{
		ogre_pain1(this);
		this.pain_finished = time + 1;
	}
	else if(r < 0.5)
	{
		ogre_painb1(this);
		this.pain_finished = time + 1;
	}
	else if(r < 0.75)
	{
		ogre_painc1(this);
		this.pain_finished = time + 1;
	}
	else if(r < 0.88)
	{
		ogre_paind1(this);
		this.pain_finished = time + 2;
	}
	else
	{
		ogre_paine1(this);
		this.pain_finished = time + 2;
	}
}

void ogre_die14(entity this)
{
	set_animofs(this, anim_ogre_death, 14, ogre_die14);
	CorpseThink(this);
}
void ogre_die13(entity this) { set_animofs(this, anim_ogre_death, 13, ogre_die14); }
void ogre_die12(entity this) { set_animofs(this, anim_ogre_death, 12, ogre_die13); }
void ogre_die11(entity this) { set_animofs(this, anim_ogre_death, 11, ogre_die12); }
void ogre_die10(entity this) { set_animofs(this, anim_ogre_death, 10, ogre_die11); }
void ogre_die9(entity this) { set_animofs(this, anim_ogre_death, 9, ogre_die10); }
void ogre_die8(entity this) { set_animofs(this, anim_ogre_death, 8, ogre_die9); }
void ogre_die7(entity this) { set_animofs(this, anim_ogre_death, 7, ogre_die8); }
void ogre_die6(entity this) { set_animofs(this, anim_ogre_death, 6, ogre_die7); }
void ogre_die5(entity this) { set_animofs(this, anim_ogre_death, 5, ogre_die6); }
void ogre_die4(entity this) { set_animofs(this, anim_ogre_death, 4, ogre_die5); }
void ogre_die3(entity this)
{
	set_animofs(this, anim_ogre_death, 3, ogre_die4);
	if((this.spawnflags & OGRE_BOSS))
		this.ammo_multi_rockets = 2;
	else
		this.ammo_rockets = 2;
	STAT(WEAPONS, this) = WEP_CHAINSAW.m_wepset;
	DropBackpack(this);
}
void ogre_die2(entity this) { set_animofs(this, anim_ogre_death, 2, ogre_die3); }
void ogre_die1(entity this) { set_animofs(this, anim_ogre_death, 1, ogre_die2); this.solid = SOLID_NOT; }

void ogre_bdie10(entity this)
{
	set_animofs(this, anim_ogre_bdeath, 10, ogre_bdie10);
	CorpseThink(this);
}
void ogre_bdie9(entity this) { set_animofs(this, anim_ogre_bdeath, 9, ogre_bdie10); }
void ogre_bdie8(entity this) { set_animofs(this, anim_ogre_bdeath, 8, ogre_bdie9); }
void ogre_bdie7(entity this) { set_animofs(this, anim_ogre_bdeath, 7, ogre_bdie8); ai_forward(this, 25); }
void ogre_bdie6(entity this) { set_animofs(this, anim_ogre_bdeath, 6, ogre_bdie7); ai_forward(this, 7); }
void ogre_bdie5(entity this) { set_animofs(this, anim_ogre_bdeath, 5, ogre_bdie6); ai_forward(this, 3); }
void ogre_bdie4(entity this) { set_animofs(this, anim_ogre_bdeath, 4, ogre_bdie5); ai_forward(this, 1); }
void ogre_bdie3(entity this)
{
	set_animofs(this, anim_ogre_bdeath, 3, ogre_bdie4);
	this.solid = SOLID_NOT;
	if((this.spawnflags & OGRE_BOSS))
		this.ammo_multi_rockets = 2;
	else
		this.ammo_rockets = 2;
	// TODO: make optional?
	STAT(WEAPONS, this) = WEP_CHAINSAW.m_wepset;
	DropBackpack(this);
}
void ogre_bdie2(entity this) { set_animofs(this, anim_ogre_bdeath, 2, ogre_bdie3); ai_forward(this, 5); }
void ogre_bdie1(entity this) { set_animofs(this, anim_ogre_bdeath, 1, ogre_bdie2); }

void ogre_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -80)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_ogre.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

	_sound(this, CH_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	
	if(random() < 0.5)
		ogre_die1(this);
	else
		ogre_bdie1(this);
}

void ogre_melee(entity this)
{
	if(random() > 0.5)
		ogre_smash1(this);
	else
		ogre_swing1(this);
}

/*
===========
OgreCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool OgreCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
	float chance = 0;
	if(this.enemy_range == RANGE_NEAR)
		chance = 0.10;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	this.attack_state = AS_MISSILE;
	float extra_delay = 3;
	this.attack_finished = time + (1 * extra_delay * random());
	return true;
}

/*QUAKED monster_ogre(1 0 0)(-32 -32 -24)(32 32 64) Ambush Boss Normal
The Ogre

Boss: (rogue only) use the modified skin and fire multigrenades.
Normal: use the original skin and fire normal grenades.
*/
spawnfunc(monster_ogre)
{
	if(random() < 0.2 && fexists("progs/cook.mdl"))
	{
		monster_start(this, true, MON_COOK);
		return;
	}
	monster_start(this, true, MON_OGRE);
}
spawnfunc(monster_ogre_marksman)
{
	this.classname = "monster_ogre_marksman"; // TODO: separate monster?
	monster_start(this, true, MON_OGRE);
}

// alkaline
spawnfunc(monster_ogreb) { monster_start(this, true, MON_OGRE); }
#endif // SVQC

#ifdef SVQC
METHOD(Ogre, mr_setup, bool(Ogre this, entity actor))
{
    TC(Ogre, this);

	precache_model("progs/grenade.mdl");

	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogsawatk.wav");

	// none specified - choose random. 25% boss on normal, hard, bloodbath
	if((actor.spawnflags <= 1) && autocvar_skill > 0 && random() <= 0.25 && IsRogueMap())
		actor.spawnflags |= OGRE_BOSS;

	if(actor.spawnflags & OGRE_BOSS)
		actor.skin = 1;

    actor.health = 200;
    actor.th_stand = ogre_stand1;
	actor.th_walk = ogre_walk1;
	actor.th_run = ogre_run1;
	actor.th_die = ogre_die;
	actor.th_melee = ogre_melee;
	actor.th_missile = ogre_nail1;
	actor.th_pain = ogre_pain;

	actor.checkattack = OgreCheckAttack;

    return true;
}
#endif

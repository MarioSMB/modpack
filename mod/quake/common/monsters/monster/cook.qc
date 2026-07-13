#include "cook.qh"

#ifdef SVQC
bool cook_ai_checksmalldist(entity this)
{
	if(!this.cook_target || !visible(this, this.cook_target))
		return false;
	return (vdist(this.cook_target.origin - this.origin, <, 100));
}

void cook_ai_jump(entity this, vector vec, float num, vector dave)
{
	if(this.flags & FL_SWIM)
		return;
	if(!IS_ONGROUND(this))
		return;
	makevectors('0 1 0' * vec.y);
	setorigin(this, this.origin + '0 0 1');
	this.velocity = v_forward * num + dave;
	UNSET_ONGROUND(this);
}

void cook_ai_face(entity this)
{
	this.ideal_yaw = vectoyaw(this.cook_target.origin - this.origin);
	changeyaw(this);
}

void cook_ai_melee(entity this, int deathtype)
{
	if(!this.enemy || this.enemy.health <= 0)
		return;		// removed before stroke

	if(vdist(this.enemy.origin - this.origin, >, 120))
		return;

	if(W_Parry(this, this.enemy))
		return;

	float ldmg = (random() + random() + random()) * 3;
	float num = random();
	ldmg += 3;
	if(ldmg >= this.enemy.health)
		_sound(this, CH_VOICE, "cook/dpong.wav", 1, ATTN_IDLE);
	else if(num < 0.3)
		_sound(this, CH_PAIN, "cook/ping1.wav", 1, ATTN_IDLE);
	else if(num < 0.7)
		_sound(this, CH_VOICE, "cook/ping2.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_PAIN, "cook/pong1.wav", 1, ATTN_IDLE);
	T_Damage(this.enemy, this, this, ldmg, deathtype);
}

void Cook_FindTarget(entity this)
{
	if(this.charmed)
	{
		FindTarget(this);
		return;
	}

	entity client = t_checkclient(this);
	if(!client || client == this.cook_target)
		return;

	//bool nyx_invis = (client.m_champion == CHAMPION_Nyx && STAT(NYX_INVIS, client));
	if((client.flags & FL_NOTARGET) || StatusEffects_active(STATUSEFFECT_Invisibility, client))
		return;
	int r = range(this, client);
	if(r == RANGE_FAR || !visible(this, client))
		return;

	if(r == RANGE_MID && !infront(this, client))
		return;

	this.cook_target = client;
}

void cook_nowalk(entity this)
{
	this.goalentity = NULL;
	setthink(this, this.th_stand);
	this.nextthink = time + 0.1;
}

void cook_think(entity this)
{
	//FindTarget(this);
	//bool nyx_invis = (this.cook_target.m_champion == CHAMPION_Nyx && STAT(NYX_INVIS, this.cook_target));
	if(this.cook_target.health <= 0 || (this.charmed && (this.charmer == this.cook_target)) || (this.cook_target.flags & FL_NOTARGET))
		this.cook_target = NULL;
	if(this.cook_target)
	{
		if(visible(this, this.cook_target))
			this.search_time = time + 5;
	}
	if(!this.cook_target || this.search_time < time)
		Cook_FindTarget(this);

	if(!this.enemy && cook_ai_checksmalldist(this))
		cook_notice(this);
}

void cook_control1(entity this)
{
	_sound(this, CH_VOICE, "cook/pansiz1.wav", 1, ATTN_IDLE);
	float num = random();
	if(num < 0.5)
	{
		cook_cook(this);
		return;
	}
	if(num < 0.8)
	{
		cook_oshake(this);
		return;
	}
	cook_flip1(this);
}

void cook_cook(entity this)
{
	if(this.walkframe >= 8)
	{
		this.walkframe = 0;
		cook_control1(this);
		return;
	}
	set_anim(this, 0, cook_cook);
	this.frame = 0 + this.walkframe;
	this.walkframe += 1;
	cook_think(this);
}

void cook_flip1(entity this)
{
	if(this.walkframe >= 11)
	{
		this.walkframe = 0;
		cook_control1(this);
		return;
	}
	set_anim(this, 64, cook_flip1);
	this.frame = 18 + this.walkframe;
	this.walkframe += 1;
}

void cook_control2(entity this)
{
	cook_ai_face(this);
	cook_checkcooks(this);
	if(this.walkframe >= 21)
	{
		this.walkframe = 0;
		if(visible(this, this.cook_target))
		{
			if(this.aflag == 0)
			{
				if(random() > 0.4)
				{
					this.cnt += 1;
					if(cook_WAVS(this, this.cnt))
					{
						set_anim(this, 34, cook_run1);
						return;
					}
					this.aflag = 444;
				}
				else if(!cook_ai_checksmalldist(this))
				{
					this.goalentity = this.cook_target;
					cook_scoot1(this);
					return;
				}
			}
			else if(this.aflag == 444)
				this.aflag = 0;
		}
	}
	set_anim(this, 34, cook_control2);
	int num = this.walkframe;
	if(num >= 7)
		num -= 7;
	if(num >= 7)
		num -= 7;
	this.frame = 34 + num;
	this.walkframe += 1;
	if(this.aflag == 444 && this.skin == 0)
	{
		this.skin = 1;
		return;
	}
	this.skin = 0;
}

void cook_checkcooks(entity this)
{
	FOREACH_ENTITY_CLASS("monster_cook", it.health > 0 && it.cnt > 8 && it.cook_target,
	{
		if(visible(it, this.cook_target))
		{
			this.cnt = 10;
			break;
		}
	});
}

void cook_wins(entity this)
{
	this.enemy = NULL;
	this.goalentity = NULL;
	this.cook_target = NULL;
	this.walkframe = 0;
	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "cook/daddy.wav", 1, ATTN_IDLE);
	else if(r < 0.50)
		_sound(this, CH_VOICE, "cook/cannot.wav", 1, ATTN_IDLE);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "cook/mademe.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_VOICE, "cook/pity01.wav", 1, ATTN_IDLE);

	cook_stand(this);
}

void cook_stand(entity this)
{
	if(this.walkframe >= 7)
		this.walkframe = 0;
	set_anim(this, 34, cook_stand);
	this.frame = 34 + this.walkframe;
	this.walkframe = this.walkframe + 1;
	ai_stand(this);
}

void cook_shake(entity this)
{
	if(this.walkframe >= 6)
	{
		this.walkframe = 0;
		cook_control1(this);
		return;
	}
	set_anim(this, 8, cook_shake);
	this.frame = 8 + this.walkframe;
	this.walkframe += 1;
}

void cook_oshake4(entity this)
{
	float num = random();
	if(num < 0.4)
	{
		set_anim(this, 17, cook_oshake3);
		return;
	}
	else if(num < 0.7)
	{
		set_anim(this, 17, cook_oshake);
		return;
	}
	set_anim(this, 17, cook_control1);
}

void cook_oshake3(entity this)
{
	set_anim(this, 16, cook_oshake4);
}

void cook_oshake2(entity this)
{
	if(random() < 0.5)
	{
		set_anim(this, 15, cook_oshake);
		_sound(this, CH_WEAPON_SINGLE, "cook/pansiz2.wav", 1, ATTN_IDLE);
		return;
	}
	set_anim(this, 15, cook_oshake3);
}

void cook_oshake(entity this)
{
	set_anim(this, 14, cook_oshake2);
}

void cook_run8(entity this)
{
	set_anim(this, 48, cook_run1);
	ai_run(this, 24);
}

void cook_run7(entity this)
{
	set_anim(this, 47, cook_run8);
	ai_run(this, 13);
}

void cook_run6(entity this)
{
	set_anim(this, 46, cook_run7);
	ai_run(this, 4);
}

void cook_run5(entity this)
{
	set_anim(this, 45, cook_run6);
	ai_run(this, 16);
	if(random() < 0.1 && !visible(this, this.enemy))
		_sound(this, CH_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
}

void cook_run4(entity this)
{
	set_anim(this, 44, cook_run5);
	ai_run(this, 22);
}

void cook_run3(entity this)
{
	set_anim(this, 43, cook_run4);
	ai_run(this, 8);
}

void cook_run2(entity this)
{
	set_anim(this, 42, cook_run3);
	ai_run(this, 12);
}

void cook_run1(entity this)
{
	if(this.enemy && this.enemy.health <= 0 && IS_PLAYER(this.enemy) && visible(this, this.enemy))
	{
		cook_wins(this);
		return;
	}
	set_anim(this, 41, cook_run2);
	ai_run(this, 9);
	if(random() < 0.2)
	{
		if(random() < 0.66)
			cook_WAVS(this, floor(random() * 8) + 1);
		else
			_sound(this, CH_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
	}
	this.cook_target = NULL;
}

void cook_scoot8(entity this)
{
	set_anim(this, 48, cook_control2);
	t_movetogoal(this, 24);
}

void cook_scoot7(entity this)
{
	set_anim(this, 47, cook_scoot8);
	t_movetogoal(this, 13);
}

void cook_scoot6(entity this)
{
	set_anim(this, 46, cook_scoot7);
	t_movetogoal(this, 4);
}

void cook_scoot5(entity this)
{
	set_anim(this, 45, cook_scoot6);
	t_movetogoal(this, 16);
}

void cook_scoot4(entity this)
{
	set_anim(this, 44, cook_scoot5);
	t_movetogoal(this, 22);
}

void cook_scoot3(entity this)
{
	set_anim(this, 43, cook_scoot4);
	t_movetogoal(this, 8);
}

void cook_scoot2(entity this)
{
	set_anim(this, 42, cook_scoot3);
	t_movetogoal(this, 12);
}

void cook_scoot1(entity this)
{
	set_anim(this, 41, cook_scoot2);
	t_movetogoal(this, 9);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
}

void cook_notice5(entity this)
{
	this.cnt = 0;
	this.aflag = 0;
	set_anim(this, 33, cook_control2);
}

void cook_notice4(entity this)
{
	set_anim(this, 32, cook_notice5);
	cook_ai_face(this);
}

void cook_notice3(entity this)
{
	set_anim(this, 31, cook_notice4);
	cook_ai_face(this);
}

void cook_notice2(entity this)
{
	set_anim(this, 30, cook_notice3);
	cook_ai_face(this);
	_sound(this, CH_VOICE, "cook/panup.wav", 1, ATTN_IDLE);
}

void cook_notice(entity this)
{
	set_anim(this, 29, cook_notice2);
	cook_ai_face(this);
	this.th_stand = cook_stand;
}

void cook_paina2(entity this) { set_anim(this, 64, cook_run1); }
void cook_paina1(entity this) { set_anim(this, 63, cook_paina2); }

void cook_painb5(entity this) { set_anim(this, 70, cook_run1); }
void cook_painb4(entity this) { set_anim(this, 69, cook_painb5); }
void cook_painb3(entity this) { set_anim(this, 68, cook_painb4); }
void cook_painb2(entity this) { set_anim(this, 67, cook_painb3); }
void cook_painb1(entity this) { set_anim(this, 66, cook_painb2); }

void cook_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "ogre/ogpain1.wav", 1, ATTN_IDLE);
	this.pain_finished = time + 0.9;
	this.th_stand = cook_stand;
	if(random() < 0.5)
		set_anim(this, 62, cook_paina1);
	else
		set_anim(this, 65, cook_painb1);
}

void cook_die7(entity this)
{
	set_anim(this, 77, cook_die7);
	CorpseThink(this);
}

void cook_die6(entity this)
{
	set_anim(this, 76, cook_die7);
}

void cook_die5(entity this)
{
	set_anim(this, 75, cook_die6);
}

void cook_die4(entity this)
{
	set_anim(this, 74, cook_die5);
}

void cook_die3(entity this)
{
	set_anim(this, 73, cook_die4);
}

void cook_die2(entity this)
{
	set_anim(this, 72, cook_die3);
}

void cook_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	Inventory_new(this);
	Inventory_add(WEP_PAN, this, ITEM_OWNED);
	DropBackpack(this);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/h_ogre.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	if(random() <= 0.2)
		_sound(this, CH_VOICE, "cook/cannot.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	set_anim(this, 71, cook_die2);
	this.solid = SOLID_NOT;
}

void cook_pong(entity this)
{
	if(this.walkframe >= 7)
	{
		this.walkframe = 0;
		cook_run1(this);
		return;
	}
	set_anim(this, 55, cook_pong);
	this.frame = 55 + this.walkframe;
	this.walkframe += 1;
	ai_charge(this, 10);
	if(this.walkframe == 1 || this.walkframe == 4)
	{
		W_Parry_Trigger(this, 0);
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_IDLE);
	}
	if(this.walkframe == 3 || this.walkframe == 6)
		cook_ai_melee(this, DEATH_MONSTER_COOK.m_id);
}

void cook_ping5(entity this)
{
	set_anim(this, 52, cook_run1);
}

void cook_ping4(entity this)
{
	set_anim(this, 53, cook_ping5);
	ai_charge(this, 8);
	cook_ai_melee(this, DEATH_MONSTER_COOK.m_id);
}

void cook_ping3(entity this)
{
	W_Parry_Trigger(this, 0);
	set_anim(this, 52, cook_ping4);
	ai_charge(this, 8);
}

void cook_ping2(entity this)
{
	set_anim(this, 51, cook_ping3);
	ai_charge(this, 8);
}

void cook_ping(entity this)
{
	set_anim(this, 50, cook_ping2);
	ai_charge(this, 8);
	_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_IDLE);
}

void cook_melee(entity this)
{
	this.walkframe = 0;
	if(random() < 0.4)
		cook_ai_jump(this, this.angles, 225, '0 0 250');
	if(random() < 0.5)
		set_anim(this, 49, cook_ping);
	else
		set_anim(this, 54, cook_pong);
}

bool CookCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}
	return false;
}

bool cook_WAVS4(entity this, int index)
{
	switch(index)
	{
		case 1: _sound(this, CH_VOICE, "cook/comm3.wav", 1, ATTN_IDLE); break;
		case 2: _sound(this, CH_VOICE, "cook/idiot.wav", 1, ATTN_IDLE); break;
		case 3: _sound(this, CH_VOICE, "cook/you.wav", 1, ATTN_IDLE); break;
		case 4: _sound(this, CH_VOICE, "cook/idiot.wav", 1, ATTN_IDLE); break;
		case 5: _sound(this, CH_VOICE, "cook/skull2.wav", 1, ATTN_IDLE); break;
		case 6:
		{
			_sound(this, CH_VOICE, "cook/makemad.wav", 1, ATTN_IDLE);
			cook_ai_jump(this, this.angles, 200, '0 0 230');
			break;
		}
		case 7: _sound(this, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_IDLE); break;
		case 8: _sound(this, CH_VOICE, "cook/comm1.wav", 1, ATTN_IDLE); break;
	}
	return (index > 8);
}

bool cook_WAVS3(entity this, int index)
{
	switch(index)
	{
		case 1: _sound(this, CH_VOICE, "cook/goway.wav", 1, ATTN_IDLE); break;
		case 2: _sound(this, CH_VOICE, "cook/comm2.wav", 1, ATTN_IDLE); break;
		case 3: _sound(this, CH_VOICE, "cook/you.wav", 1, ATTN_IDLE); break;
		case 4: _sound(this, CH_VOICE, "cook/idiot.wav", 1, ATTN_IDLE); break;
		case 5: _sound(this, CH_VOICE, "cook/listen.wav", 1, ATTN_IDLE); break;
		case 6:
		{
			_sound(this, CH_VOICE, "cook/comm5.wav", 1, ATTN_IDLE);
			cook_ai_jump(this, this.angles, 200, '0 0 230');
			break;
		}
		case 7: _sound(this, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_IDLE); break;
		case 8: _sound(this, CH_VOICE, "cook/moron.wav", 1, ATTN_IDLE); break;
	}
	return (index > 8);
}

bool cook_WAVS2(entity this, int index)
{
	switch(index)
	{
		case 1: _sound(this, CH_VOICE, "cook/whatu.wav", 1, ATTN_IDLE); break;
		case 2: _sound(this, CH_VOICE, "cook/you.wav", 1, ATTN_IDLE); break;
		case 3: _sound(this, CH_VOICE, "cook/moron.wav", 1, ATTN_IDLE); break;
		case 4: _sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE); break;
		case 5: _sound(this, CH_VOICE, "cook/skull.wav", 1, ATTN_IDLE); break;
		case 6:
		{
			_sound(this, CH_VOICE, "cook/makemad.wav", 1, ATTN_IDLE);
			cook_ai_jump(this, this.angles, 200, '0 0 240');
			break;
		}
		case 7: _sound(this, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_IDLE); break;
		case 8: _sound(this, CH_VOICE, "cook/skull2.wav", 1, ATTN_IDLE); break;
	}
	return (index > 8);
}

bool cook_WAVS(entity this, int index)
{
	int mysounds = floor(random() * 4);
	switch(mysounds)
	{
		case 1: return cook_WAVS2(this, index);
		case 2: return cook_WAVS3(this, index);
		case 3: return cook_WAVS4(this, index);
	}

	switch(index)
	{
		case 1: _sound(this, CH_VOICE, "cook/comm3.wav", 1, ATTN_IDLE); break;
		case 2: _sound(this, CH_VOICE, "cook/comm1.wav", 1, ATTN_IDLE); break;
		case 3: _sound(this, CH_VOICE, "cook/comm2.wav", 1, ATTN_IDLE); break;
		case 4: _sound(this, CH_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE); break;
		case 5: _sound(this, CH_VOICE, "cook/comm4.wav", 1, ATTN_IDLE); break;
		case 6:
		{
			_sound(this, CH_VOICE, "cook/makemad.wav", 1, ATTN_IDLE);
			cook_ai_jump(this, this.angles, 200, '0 0 225');
			break;
		}
		case 7: _sound(this, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_IDLE); break;
		case 8: _sound(this, CH_VOICE, "cook/comm5.wav", 1, ATTN_IDLE); break;
	}
	return (index > 8);
}

spawnfunc(monster_cook) { monster_start(this, true, MON_COOK); }
#endif // SVQC

#ifdef SVQC
METHOD(Cook, mr_setup, bool(Cook this, entity actor))
{
    TC(Cook, this);

	precache_model("progs/cook.mdl");
	precache_model("progs/h_ogre.mdl");
	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogwake.wav");
	precache_sound("cook/comm1.wav");
	precache_sound("cook/comm2.wav");
	precache_sound("cook/comm3.wav");
	precache_sound("cook/comm4.wav");
	precache_sound("cook/comm5.wav");
	precache_sound("cook/daddy.wav");
	precache_sound("cook/mademe.wav");
	precache_sound("cook/listen.wav");
	precache_sound("cook/goway.wav");
	precache_sound("cook/you.wav");
	precache_sound("cook/whatu.wav");
	precache_sound("cook/idiot.wav");
	precache_sound("cook/moron.wav");
	precache_sound("cook/cannot.wav");
	precache_sound("cook/skull.wav");
	precache_sound("cook/skull2.wav");
	precache_sound("cook/makemad.wav");
	precache_sound("cook/pansiz1.wav");
	precache_sound("cook/pansiz2.wav");
	precache_sound("cook/ping1.wav");
	precache_sound("cook/ping2.wav");
	precache_sound("cook/pong1.wav");
	precache_sound("cook/dpong.wav");
	precache_sound("cook/panup.wav");
	precache_sound("cook/pity01.wav");
	precache_sound("knight/sword1.wav");

	// unique to the weird logic used by nehahra
	actor.cnt = 0;
	actor.aflag = 0;

    actor.health = 280;
    actor.gibhealth = -80;
    actor.th_stand = cook_control1;
	actor.th_walk = cook_nowalk;
	actor.th_run = cook_run1;
	actor.th_die = cook_die;
	actor.th_melee = cook_melee;
	actor.th_pain = cook_pain;

	actor.checkattack = CookCheckAttack;

    return true;
}
METHOD(Cook, mr_sight, bool(Cook this, entity actor))
{
	TC(Cook, this);

	_sound(actor, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);

	return true;
}
#endif

// kirby power
#ifdef CSQC
PRECACHE(Star_Cook)
{
	precache_model("progs/v_star_cook.mdl");
}
#endif

#ifdef SVQC
PRECACHE(Star_Cook)
{
	precache_model("progs/cauldron.mdl");
	precache_sound("enviro/pinhead/pindef.wav");
	precache_sound("enviro/pinhead/pinback.wav");
	precache_sound("ambient/runwater.wav");

	precache_model("progs/goofygib_burger.mdl");
	precache_sound("kirby/bite.wav");
}

void cauldron_spawnfood(entity this, vector org, bool btype)
{
	entity item = spawn();
	item.classname = "item_health";
	settouch(item, horde_health_touch); // abuse a fellow abuser
	setcefc(item, health_customize);
	_setmodel(item, "progs/goofygib_burger.mdl");
	setsize(item, '0 0 -8', '32 32 48');
	item.noise = "kirby/bite.wav";
	item.healamount = 25;
	item.healtype = 2; // always heal
	setorigin(item, org);
	set_movetype(item, MOVETYPE_TOSS);
	item.solid = SOLID_TRIGGER;
	item.flags = FL_ITEM;
	item.modelflags = MF_ROTATE;
	item.effects = EF_FULLBRIGHT;

	if(btype)
	{
		item.scale = 3;
		item.healamount = 50;
		setsize(item, '0 0 -16', '32 32 48');
	}

	item.velocity = randomvec() * 250;
	item.velocity_z = 320;
	setthink(item, SUB_Remove);
	item.nextthink = time + 10;
}

.entity star_cauldron;
void cauldron_think(entity this)
{
	this.nextthink = time;

	if(time > this.wait || !this.owner || this.owner.star_cauldron != this || this.owner.health < 1)
	{
		Send_Effect(EFFECT_EXPLOSION, this.origin + '0 0 16', '0 0 0', 1);
		stopsound(this, CH_WEAPON_SINGLE);
		if(this.owner.star_cauldron == this)
			this.owner.star_cauldron = NULL;
		delete(this);
		return;
	}

	if(!this.state)
		return;

	if(time < this.delay)
		return;
	this.delay = time + 0.5;

	if(this.count > 0)
	{
		bool superburger = false;
		if(this.count >= 10)
		{
			superburger = true;
			this.count -= 10;
		}
		else
			this.count -= 1;
		// poot out a food item
		vector org = (this.absmin + this.absmax) * 0.5;
		cauldron_spawnfood(this, org + '0 0 12', superburger);

		_sound(this, CH_SHOTS, "enviro/pinhead/pinback.wav", 1, ATTN_NORM);
	}

	FOREACH_ENTITY_RADIUS(this.origin, 200, it != this,
	{
		if(it.takedamage && it.health > 0 && it != this.owner && Damage_ValidTarget(it, this.owner))
		{
			T_Damage(it, this, this.owner, 40, WEP_STAR.m_id);
		}
	});
}

void cauldron_setup(entity this)
{
	this.owner.star_cauldron = this;

	this.classname = "cauldron";
	//set_movetype(this, MOVETYPE_NONE);
	setthink(this, cauldron_think);
	this.nextthink = time + 0.1;
	this.solid = SOLID_TRIGGER;
	settouch(this, func_null);
	this.candrag = true;
	setorigin(this, this.origin); // relink

	this.delay = time + 0.1;
	this.monster_attack = true;
	this.health = 200; // just for monsters to think it's an enemy (TODO)
	this.max_health = this.health;
	this.takedamage = DAMAGE_NO;
	this.count = 0;
	this.state = 0;

	this.wait = time + 10;
}

void cauldron_projectile_touch(entity this, entity toucher)
{
	if(toucher && toucher.solid != SOLID_BSP)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// TODO: bumping sound?
}

void cauldron_projectile_think(entity this)
{
	this.nextthink = time;
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	if(!IS_ONGROUND(this))
		return;

	sound(this, CH_WEAPON_B, SND_CANNON_LAND, 1, ATTN_NORM);
	cauldron_setup(this);
}

void star_cook_cauldron_drop(entity actor, .entity weaponentity)
{
	entity cauldron = spawn();
	cauldron.classname = "cauldron_projectile";
	cauldron.owner = actor;
	cauldron.realowner = actor;
	set_movetype(cauldron, MOVETYPE_TOSS);
	cauldron.solid = SOLID_BBOX;
	_setmodel(cauldron, "progs/cauldron.mdl");
	//setsize(cauldron, '-8 -8 -16', '8 8 8');
	vector cmin = actor.mins, cmax = actor.maxs;
	// some basic sanity, but otherwise use player's hitbox to avoid exploits
	cmin.z = 0;
	cmax.z = 16;
	setsize(cauldron, cmin, cmax);
	settouch(cauldron, cauldron_projectile_touch);
	setthink(cauldron, cauldron_projectile_think);
	cauldron.wait = time + 3;
	cauldron.nextthink = time;

	vector org = actor.origin + (actor.view_ofs * 0.75);
	setorigin(cauldron, org);
	cauldron.angles = actor.angles;
	cauldron.pos2 = cauldron.angles;
	makevectors(actor.angles);
	cauldron.velocity = v_forward * 200 + v_up * 20;
}

void star_cook_aggro(entity actor)
{
	entity this = actor.star_cauldron;

	FOREACH_ENTITY_RADIUS(this.origin, 512, true,
	{
		if(IS_MONSTER(it) && it.health > 0 && it.enemy && !it.charmed && !(it.effects & EF_NODRAW) && !it.is_frozen && !it.elec && it.enemy.classname != this.classname && !wasfreed(it.enemy))
		{
			if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
				continue;
			if(!checkpvs(this.origin, it))
				continue;
			it.aggro_time = time;
			if(IS_PLAYER(it.enemy))
				it.oldenemy = it.enemy;
			it.enemy = this;
			FoundTarget(it);
		}
	});
}

void star_cook_clack_frame(entity this)
{
	entity actor = this.owner;
	//.entity weaponentity = this.weaponentity_fld;

	if(this.m_frame == 2 && actor.star_cauldron)
	{
		sound7(actor.star_cauldron, CH_WEAPON_SINGLE, "ambient/runwater.wav", 1, ATTN_NORM, 75, 0);
		actor.star_cauldron.state = 1; // enable cooking mode
	}

	switch(this.m_frame)
	{
		case 2:
		case 4:
		case 6:
		{
			// we may have moved, so aggro every time
			if(actor.star_cauldron)
				star_cook_aggro(actor);
			_sound(actor, CH_WEAPON_A, "enviro/pinhead/pindef.wav", 1, ATTN_NORM);
			break;
		}
	}

	if(this.m_frame >= 8)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, star_cook_clack_frame);
}

void star_cook_clack(entity actor, .entity weaponentity)
{
	actor.(weaponentity).m_frame = 0;
	wep_set_anim(actor.(weaponentity), actor.(weaponentity).m_frame, star_cook_clack_frame);

	if(IS_PLAYER(actor))
		player_shot1(actor);

	weapon_prepareattack(WEP_STAR, actor, weaponentity, 1);
}

void star_cook_throw(entity actor, .entity weaponentity)
{
	sound(actor, CH_WEAPON_B, SND_CANNON_DROP, 1, ATTN_NORM);

	actor.(weaponentity).m_frame = 0;

	if(IS_PLAYER(actor))
		player_shot1(actor);

	star_cook_cauldron_drop(actor, weaponentity);

	weapon_prepareattack(WEP_STAR, actor, weaponentity, 1);
}

METHOD(Cook, star_fire, void(Cook this, entity actor, .entity weaponentity))
{
	// we're always going to do *something*, so always cancel out of flight now
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
		STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;

	if(actor.star_cauldron)
	{
		star_cook_clack(actor, weaponentity);
		return;
	}

	star_cook_throw(actor, weaponentity);
}
#endif

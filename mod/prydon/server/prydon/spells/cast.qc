#include "cast.qh"

#include "_mod.qh"
#include "../anim/_mod.qh"
#include "../inv/dur.qh"
#include "../items/encode.qh"
#include "../items/map.qh"
#include "../npcs/mspawn.qh"
#include "../player/spawn.qh"
#include "../spells/_mod.qh"
#include "../stats/stats.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"

.entity warp_target;

void spell_fire(entity this, float sp)
{
	entity e, m;
	float lev, man, dam;
	int runaway = 0;

	if(!this.enemy && cast_aground(sp) != 1)
		return;
	if(sp & SP_ITEM_CAST)
	{
		lev = floor(sp / 256);
		if(sp & SP_SCROLL_OF)
		{
			if(!takeammo(this.owner, IT_SCROLL))
			{
				sprint(this, "No ammo\n");
				return;
			}
		}
		else
		{
			sp = sp & 63;
			if(!TakeCharges(this.owner, sp))
			{
				man = mana_for_spell(sp, lev);
			 	if(this.owner.mana < man)
			 	{
		 			if(this.owner.classname == "player")
						sprint(this.owner, "not enough mana\n");
					return;
				}
				this.owner.mana = this.owner.mana - man;
			}
		}
		man = 0;
	}
	else
	{
		lev = GetSpellLevel(this.owner, sp);
		man = mana_for_spell(sp, lev);
	
	 	if(this.owner.mana < man)
	 	{
	 		if(this.owner.classname == "player")
				sprint(this.owner, "not enough mana\n");
			return;
		}
		this.owner.mana = this.owner.mana - man;
	}
	sp = sp & 63;
		
	if(sp == SP_FIREBALL)
		fireball_go(this, lev);
	else if(sp == SP_ZAP)
		zap_go(this, lev);
	else if(sp == SP_ICEBLAST)
		iceblast_go(this, lev);
	else if(sp == SP_WARP)
	{

		e = this.warp_target;
		do
			this.warp_target = find(this.warp_target, classname, "dummy");
		while(this.warp_target == this);
		
		if(e == NULL)
		{
			e = find_spawn(this);
			setorigin(this, e.origin);
		}
		else
		{
			e = find_spot(e);
			setorigin(this, e.origin);
			delete(e);
		}
		_sound(e, CH_WEAPON_SINGLE, "spells/warp.wav", 1, ATTN_NORM);
	}
	else if(sp == SP_POISONBALL)
		poisonball_go(this, lev);
	else if(sp == SP_LEECH)
	{
		if(!this.enemy.takedamage)
			return;
		dam = ceil(lev * lev / 2) + 2;
		T_Damage(this, this.enemy, dam, 5);
		_sound(this, CH_WEAPON_SINGLE, "spells/leech.wav", 1, ATTN_NORM);
		
		e = this;
		if(e.owner)
			e = e.owner;
		if(lev >= 5)
		{
			if(random() < (lev * 0.05))
			{
				if(this.enemy.owner.flags & FL_CLIENT)
					sprint(this.enemy.owner, "You have sustained a mortal wound.\n");
				this.enemy.misc = e.player.misc | MISC_MORTAL_WOUND;
				this.enemy.poison_inflictor = this;
				this.enemy.mortal_factor = this.enemy.owner.health;
			}
		}
		e.health = e.health + dam;
		boundstats(e);
	}
	else if(sp == SP_HEAL)
	{
	
		if(lev >= 5)
		{
			e = findradius(this.origin, 386);
			while(e)
			{
				m = e;
		
				if(friendly(e, this))
				{
					if(e.owner)
						e = e.owner;
					if(e.health >= 1)
					{
						if(e.health < e.max_health)
						{
							_sound(this, CH_WEAPON_SINGLE, "spells/heal.wav", 1, ATTN_NORM);
							runaway = (lev + 4) / 2;
							e.health = e.health + ceil(runaway * runaway) + 5;

							boundstats(e);
						}
					}
				}
				e = m.chain;
			}
		}
		else if((this.enemy.owner.health < this.enemy.owner.max_health) && (friendly(this.enemy, this)))
		{
			e = this.enemy;
			if(e.owner)
				e = e.owner;
			runaway = (lev + 4) / 2;
			e.health = e.health + ceil(runaway * runaway) + 5;
			_sound(this, CH_WEAPON_SINGLE, "spells/heal.wav", 1, ATTN_NORM);
			boundstats(e);
		}
		else
		{
			e = this;
			if(e.owner)
				e = e.owner;
			runaway = (lev + 4) / 2;
			e.health = e.health + ceil(runaway * runaway) + 5;
			_sound(this, CH_WEAPON_SINGLE, "spells/heal.wav", 1, ATTN_NORM);
			boundstats(e);
		}
	}
	else if(sp == SP_SHIELD)
	{
	
		if((friendly(this.enemy, this)))
		{
			e = this.enemy.owner;
			if(e)
			{
				e.shield_time = time + 8 + lev * 2.5;
				e.shield_factor = (lev + 1) * 0.25;
			}
			_sound(this.enemy, CH_WEAPON_SINGLE, "spells/shield.wav", 1, ATTN_NORM);
		}
		else if(this.owner)
		{
			this.owner.shield_time = time + 8 + lev * 2.5;
			this.owner.shield_factor = (lev + 1) * 0.25;
			_sound(this, CH_WEAPON_SINGLE, "spells/shield.wav", 1, ATTN_NORM);
		}
	}
	else if(sp == SP_TRANSMUTE)
	{
		if(this.enemy)
		{
			it_simplestat(this, this.enemy.slot1);
			it_itemstat(this);
			
			if(!(this.enemy.menu))
			if(stat_it < IT_GOLD)
			{
				_sound(this.enemy, CHAN_AUTO, "spells/tranmute.wav", 1, ATTN_NORM);
			
				stat_it = IT_GOLD;
				stat_id = true;
				stat_pref = stat_suf = 0;
				stat_dur = ceil((stat_price/2) * lev/10);
				if(stat_dur > 10000)
					stat_dur = 10000;
				this.enemy.items = 0;
				this.enemy.slot1 = it_setstat();
				spawnfunc_item(this.enemy);
			}
		}
	}
	else if(sp == SP_REPEL)
	{
		_sound(this, CHAN_AUTO, "spells/repel.wav", 1, ATTN_NORM);
		
		e = findradius(this.origin, (5 + lev * lev * 0.2) * 20);
		while(e)
		{
		
			if(!friendly(e, this))
			{
				if(e.takedamage)
				{
					e.flags = e.flags - (e.flags & FL_ONGROUND);
					e.velocity = e.velocity + normalize(e.origin - this.origin) * (200 + (lev * 30));
					e.velocity_z = 212;
					if(lev > 3)
					{
						e.daze_time = time + lev * 2;
					}
				}
			}
			e = e.chain;
		}
	}
	else if(sp == SP_NOVA)
		nova_go(this, lev);
	else if(sp == SP_TELEPORT)
	{
		if(this.enemy == NULL)
			this.enemy = this.owner.wayp;
		e = find_spot(this);
		setorigin(this, e.origin);
		_sound(this, CHAN_AUTO, "spells/warp.wav", 1, ATTN_NORM);
		delete(e);
	}
	else if(sp == SP_TWISTER)
		twister_go(this, lev);
	else if(sp == SP_SUMMON)
		summon_go(this, lev);
	else if(sp == SP_METEOR)
	{
		vector v = '-80 0 0';
		v.y = random()* 360;
		makevectors(v);
		traceline(this.enemy.origin, this.enemy.origin + v_forward * 5000, true, this);
		runaway = 5 - (vlen(this.enemy.origin - trace_endpos) / 1000);
		e = spawn();
		setorigin(e, trace_endpos);
		setthink(e, meteor_go);
		e.nextthink = time + runaway;
		e.finalangle = v_forward * -1000;
		e.ac = time + 5;
		e.owner = this;
		e.frags = lev;
		e.team = this.team;
		_sound(e, CH_WEAPON_SINGLE, "spells/meteor1.wav", 1, ATTN_NORM);
		
	}
	else if(sp == SP_EVILE)
	{
		e = spawn();
		if(lev > 7)
			lev = 7;
		setorigin(e, this.enemy.origin);
		e.dama = lev * 3;
		e.summon_count = (5 + lev * lev * 0.2) * 5;
		setthink(e, evile_go);
		e.nextthink = time;
		e.team = this.team;
		e.owner = this;
		e.ltime = time + (3 / (8 - lev));
		_sound(e, CH_VOICE, "spells/evile.wav", 1, ATTN_NORM);
	}
	else if(sp == SP_SPRINT)
	{
		lev = this.owner.spec;	
		this.owner.spec = this.owner.spec | SPEC_KNOCKBACK;
		if(Hit(this, this.enemy, SKILL_SPRINT))
			_sound(this, CH_WEAPON_SINGLE, "player/hit.wav", 1, ATTN_NORM);
		this.owner.spec = lev;
		this.misc = this.misc - (this.misc & MISC_SPRINT_DONE);
	}
	else if(sp == SP_FLAME_ARROW)
	{
		bowattack1(this);
	}
	else if(sp == SP_BRAWL)
	{
		brawl1(this);
	}
	else if(sp == SP_FRENZY)
	{
		frenzy1(this);
	}
	else if(sp == SP_HEALOTHER)
	{
		e = findradius(this.origin, 386);
		while(e)
		{
			m = e;
	
			if(friendly(e, this))
			{
				if(e.owner)
					e = e.owner;
				if(e.health >= 1)
				{
					if(e.health < e.max_health)
					{
						_sound(this, CH_WEAPON_SINGLE, "spells/heal.wav", 1, ATTN_NORM);
						runaway = (lev + 4) / 2;
						e.health = e.health + ceil(runaway * runaway) + 5;

						boundstats(e);
						break;
					}
				}
			}
			e = m.chain;
		}
	}
	else if(sp == SP_BRIBE)
		bribe_go(this, lev);
	else if(sp == SP_SUMMON_LOCAL)
	{
		e = find_spot(this);
		monster_spawn_go(e);
		
		e.droprandom = 0;
		te_teleport(e.origin);
		_sound(e, CH_WEAPON_SINGLE, "spells/warp.wav", 1, ATTN_NORM);
	}
	else if(sp == SP_IDENTIFY)
	{
		it_simplestat(this, this.enemy.slot1);
		if(!(this.enemy.menu))
		if(!stat_id)
		{
			_sound(this.enemy, CHAN_AUTO, "spells/tranmute.wav", 1, ATTN_NORM);
			stat_id = true;
			this.enemy.items = 0;
			this.enemy.slot1 = it_setstat();
			spawnfunc_item(this.enemy);
		}
	}
	else if(sp == SP_FREEZE)
	{
		if(this.enemy.cold_time < time)
		{	
			_sound(this.enemy, CHAN_AUTO, "spells/freeze.wav", 1, ATTN_NORM);
		
			te_teleport(this.enemy.origin);
		}
		this.enemy.cold_time = time + 5;
		this.enemy.cold_factor = this.enemy.cold_factor * 0.5;
		if(this.enemy.cold_factor < 0)
			this.enemy.cold_factor = 0;
	}
	else if(sp == SP_AWAKEMONSTERS)
	{
		e = findradius(this.origin, 128);
		while(e)
		{
		
			if(!friendly(e, this))
			{
				if(e.takedamage && e.ai)
				{
					e.enemy = this;
					e.goalentity = NULL;
				}
			}
			e = e.chain;
		}
	}
}

void spell_cast(entity this, entity towhom, float m)
{
	int n = m & 63;
	this.enemy = towhom;
	if(n == SP_GOTO)
		return;
	else if(n == SP_GOTO2)
		return;
	else if(n == SP_FOLLOW)
		return;
	else if(n == SP_AWAKEMONSTERS)
		spell_fire(this, m);
	else if(n == SP_ACTIVATE)
	{
		if(towhom.action)
			towhom.action(towhom, this);
	}
	else if(n == SP_ACTIVATE_SELF)
	{
		// little security check
		if(!(this.m_subject))
		{
			if(this.action)
				this.action(this, towhom);
		}
	}
	else if(n == SP_FIGHT_MELEE)
		attack1(this);
	else if(n == SP_FIGHT_BOW)
		bowattack1(this);
	else if(n == SP_FIGHT_CBOW)
		cbowattack1(this);
	else if(n == SP_THROW)
		throw1(this);
	else if(n == SP_THROW_CHAKRAM)
		chakram1(this);
	else if(n == SP_JUMP)
		jump1(this);
	else
	{
		if(!(m & SP_ITEM_CAST)) // scrolls are always usable
		{
			if(this.owner.mana < mana_for_spell(m, GetSpellLevel(this.owner, m)))
			{
				if(this.owner.classname == "player")
					sprint(this.owner, "not enough mana\n");
				return;
			}
		}
		if(n == SP_SPRINT)
		{
			if(this.misc & MISC_SPRINT_DONE)
			{
				spell_fire(this, m);
			}
		}
		else if(n == SP_BRAWL)
		{
			if(this.owner.altaction & 63 == SP_FIGHT_MELEE)
				spell_fire(this, m);
		}
		else if(n == SP_FRENZY)
		{
			if(this.owner.altaction & 63 == SP_FIGHT_MELEE)
				spell_fire(this, m);
		}
		else if(n == SP_FLAME_ARROW)
		{
			// make sure player can use this, has bow equipped
			if(this.owner.altaction & 63 == SP_FIGHT_BOW)
				spell_fire(this, m);
			else if(this.owner.altaction & 63 == SP_FIGHT_CBOW)
				spell_fire(this, m);
		}
		else
			cast1(this);
	}
}

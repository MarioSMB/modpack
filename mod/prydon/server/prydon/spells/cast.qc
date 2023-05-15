.entity warp_target;



void(float sp) spell_fire =
{
	local entity e, m;
	local float lev, man, dam;
	float runaway;
	local vector v;

	if (cast_aground(sp) != TRUE)
		if (!self.enemy)
			return;
	if (sp & SP_ITEM_CAST)
	{
		lev = floor(sp / 256);
		if (sp & SP_SCROLL_OF)
		{
			if (!takeammo(IT_SCROLL))
			{
				sprint(self, "No ammo\n");
				return;
			}
		}
		else
		{
			sp = sp & 63;
			if (!TakeCharges(sp))
			{
				man = mana_for_spell(sp, lev);
			 	if (self.owner.mana < man)
			 	{
		 			if (self.owner.classname == "player")
						sprint(self.owner, "not enough mana\n");
					return;
				}
				self.owner.mana = self.owner.mana - man;
			}
		}
		man = 0;
	}
	else
	{
		lev = GetSpellLevel(self.owner, sp);
		man = mana_for_spell(sp, lev);
	
	 	if (self.owner.mana < man)
	 	{
	 		if (self.owner.classname == "player")
				sprint(self.owner, "not enough mana\n");
			return;
		}
		self.owner.mana = self.owner.mana - man;
	}
	sp = sp & 63;
		
	if (sp == SP_FIREBALL)
		fireball_go(lev);
	else if (sp == SP_ZAP)
		zap_go(lev);
	else if (sp == SP_ICEBLAST)
		iceblast_go(lev);
	else if (sp == SP_WARP)
	{

		e = self.warp_target;
		do
			self.warp_target = find(self.warp_target, classname, "dummy");
		while(self.warp_target == self);
		
		if (e == world)
		{
			e = find_spawn();
			setorigin(self, e.origin);
		}
		else
		{
			m = self;
			self = e;
			e = find_spot();
			self = m;
			setorigin(self, e.origin);
			remove(e);
		}
		sound(e, CHAN_WEAPON, "spells/warp.wav", 1, ATTN_NORM);
	}
	else if (sp == SP_POISONBALL)
		poisonball_go(lev);
	else if (sp == SP_LEECH)
	{
		if (!self.enemy.takedamage)
			return;
		dam = ceil(lev * lev / 2) + 2;
		T_Damage(self, self.enemy, dam, 5);
		sound(self, CHAN_WEAPON, "spells/leech.wav", 1, ATTN_NORM);
		
		e = self;
		if (e.owner)
			e = e.owner;
		if (lev >= 5)
		{
			if (random() < (lev * 0.05))
			{
				if (self.enemy.owner.flags & FL_CLIENT)
					sprint(self.enemy.owner, "You have sustained a mortal wound.\n");
				self.enemy.misc = e.player.misc | MISC_MORTAL_WOUND;
				self.enemy.poison_inflictor = self;
				self.enemy.mortal_factor = self.enemy.owner.health;
			}
		}
		e.health = e.health + dam;
		boundstats(e);
	}
	else if (sp == SP_HEAL)
	{
	
		if (lev >= 5)
		{
			e = findradius(self.origin, 386);
			while(e)
			{
				m = e;
		
				if (friendly(e, self))
				{
					if (e.owner)
						e = e.owner;
					if (e.health >= 1)
					{
						if (e.health < e.max_health)
						{
							sound(self, CHAN_WEAPON, "spells/heal.wav", 1, ATTN_NORM);
							runaway = (lev + 4) / 2;
							e.health = e.health + ceil(runaway * runaway) + 5;

							boundstats(e);
						}
					}
				}
				e = m.chain;
			}
		}
		else if ((self.enemy.owner.health < self.enemy.owner.max_health) && (friendly(self.enemy, self)))
		{
			e = self.enemy;
			if (e.owner)
				e = e.owner;
			runaway = (lev + 4) / 2;
			e.health = e.health + ceil(runaway * runaway) + 5;
			sound(self, CHAN_WEAPON, "spells/heal.wav", 1, ATTN_NORM);
			boundstats(e);
		}
		else
		{
			e = self;
			if (e.owner)
				e = e.owner;
			runaway = (lev + 4) / 2;
			e.health = e.health + ceil(runaway * runaway) + 5;
			sound(self, CHAN_WEAPON, "spells/heal.wav", 1, ATTN_NORM);
			boundstats(e);
		}
	}
	else if (sp == SP_SHIELD)
	{
	
		if ((friendly(self.enemy, self)))
		{
			e = self.enemy.owner;
			if (e)
			{
				e.shield_time = time + 8 + lev * 2.5;
				e.shield_factor = (lev + 1) * 0.25;
			}
			sound(self.enemy, CHAN_WEAPON, "spells/shield.wav", 1, ATTN_NORM);
		}
		else if (self.owner)
		{
			self.owner.shield_time = time + 8 + lev * 2.5;
			self.owner.shield_factor = (lev + 1) * 0.25;
			sound(self, CHAN_WEAPON, "spells/shield.wav", 1, ATTN_NORM);
		}
	}
	else if (sp == SP_TRANSMUTE)
	{
		if (self.enemy)
		{
			
			it_simplestat(self.enemy.slot1);
			it_itemstat();
			
			if (!(self.enemy.menu))
			if (stat_it < IT_GOLD)
			{
				sound(self.enemy, CHAN_AUTO, "spells/tranmute.wav", 1, ATTN_NORM);
			
				stat_it = IT_GOLD;
				stat_id = TRUE;
				stat_pref = stat_suf = 0;
				stat_dur = ceil((stat_price/2) * lev/10);
				if (stat_dur > 10000)
					stat_dur = 10000;
				self.enemy.items = 0;
				self.enemy.slot1 = it_setstat();
				call(item, self.enemy);
			}
		}
	}
	else if (sp == SP_REPEL)
	{
		sound(self, CHAN_AUTO, "spells/repel.wav", 1, ATTN_NORM);
		
		e = findradius(self.origin, (5 + lev * lev * 0.2) * 20);
		while (e)
		{
		
			if (!friendly(e, self))
			{
				if (e.takedamage)
				{
					e.flags = e.flags - (e.flags & FL_ONGROUND);
					e.velocity = e.velocity + normalize(e.origin - self.origin) * (200 + (lev * 30));
					e.velocity_z = 212;
					if (lev > 3)
					{
						e.daze_time = time + lev * 2;
					}
				}
			}
			e = e.chain;
		}
	}
	else if (sp == SP_NOVA)
		nova_go(lev);
	else if (sp == SP_TELEPORT)
	{
		if (self.enemy == world)
			self.enemy = self.owner.wayp;
		e = find_spot();
		setorigin(self, e.origin);
		sound(self, CHAN_AUTO, "spells/warp.wav", 1, ATTN_NORM);
		remove(e);
	}
	else if (sp == SP_TWISTER)
		twister_go(lev);
	else if (sp == SP_SUMMON)
		summon_go(lev);
	else if (sp == SP_METEOR)
	{
		v = '-80 0 0';
		v_y = random()* 360;
		makevectors(v);
		traceline(self.enemy.origin, self.enemy.origin + v_forward * 5000, TRUE, self);
		runaway = 5 - (vlen(self.enemy.origin - trace_endpos) / 1000);
		e = spawn();
		setorigin(e, trace_endpos);
		e.think = meteor_go;
		e.nextthink = time + runaway;
		e.finalangle = v_forward * -1000;
		e.ac = time + 5;
		e.owner = self;
		e.frags = lev;
		e.team = self.team;
		sound(e, CHAN_WEAPON, "spells/meteor1.wav", 1, ATTN_NORM);
		
	}
	else if (sp == SP_EVILE)
	{
		e = spawn();
		if (lev > 7)
			lev = 7;
		setorigin(e, self.enemy.origin);
		e.dama = lev * 3;
		e.summon_count = (5 + lev * lev * 0.2) * 5;
		e.think = evile_go;
		e.nextthink = time;
		e.team = self.team;
		e.owner = self;
		e.ltime = time + (3 / (8 - lev));
		sound(e, CHAN_VOICE, "spells/evile.wav", 1, ATTN_NORM);

	}
	else if (sp == SP_SPRINT)
	{
		lev = self.owner.spec;	
		self.owner.spec = self.owner.spec | SPEC_KNOCKBACK;
		if(Hit(self, self.enemy, SKILL_SPRINT))
			sound(self, CHAN_WEAPON, "player/hit.wav", 1, ATTN_NORM);
		self.owner.spec = lev;
		self.misc = self.misc - (self.misc & MISC_SPRINT_DONE);
	}
	else if (sp == SP_FLAME_ARROW)
	{
		bowattack1();
	}
	else if (sp == SP_BRAWL)
	{
		brawl1();
	}
	else if (sp == SP_FRENZY)
	{
		frenzy1();
	}
	else if (sp == SP_HEALOTHER)
	{
		e = findradius(self.origin, 386);
		while(e)
		{
			m = e;
	
			if (friendly(e, self))
			{
				if (e.owner)
					e = e.owner;
				if (e.health >= 1)
				{
					if (e.health < e.max_health)
					{
						sound(self, CHAN_WEAPON, "spells/heal.wav", 1, ATTN_NORM);
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
	else if (sp == SP_BRIBE)
		bribe_go(lev);
	else if (sp == SP_SUMMON_LOCAL)
	{
		e = find_spot();
		call(monster_spawn_go, e);
		
		e.droprandom = 0;
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_TELEPORT);
		WriteCoord (MSG_BROADCAST, e.origin_x);
		WriteCoord (MSG_BROADCAST, e.origin_y);
		WriteCoord (MSG_BROADCAST, e.origin_z);
		sound(e, CHAN_WEAPON, "spells/warp.wav", 1, ATTN_NORM);
	}
	else if (sp == SP_IDENTIFY)
	{
		it_simplestat(self.enemy.slot1);
		if (!(self.enemy.menu))
		if (!stat_id)
		{
			sound(self.enemy, CHAN_AUTO, "spells/tranmute.wav", 1, ATTN_NORM);
			stat_id = TRUE;
			self.enemy.items = 0;
			self.enemy.slot1 = it_setstat();
			call(item, self.enemy);
		}
	}
	else if (sp == SP_FREEZE)
	{
		if (self.enemy.cold_time < time)
		{	
			sound(self.enemy, CHAN_AUTO, "spells/freeze.wav", 1, ATTN_NORM);
		
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_TELEPORT);
			WriteCoord (MSG_BROADCAST, self.enemy.origin_x);
			WriteCoord (MSG_BROADCAST, self.enemy.origin_y);
			WriteCoord (MSG_BROADCAST, self.enemy.origin_z);
		}
		self.enemy.cold_time = time + 5;
		self.enemy.cold_factor = self.enemy.cold_factor * 0.5;
		if (self.enemy.cold_factor < 0)
			self.enemy.cold_factor = 0;
	}
	else if (sp == SP_AWAKEMONSTERS)
	{
		e = findradius(self.origin, 128);
		while (e)
		{
		
			if (!friendly(e, self))
			{
				if (e.takedamage && e.ai)
				{
					e.enemy = self;
					e.goalentity = world;
				}
			}
			e = e.chain;
		}
	}
};
void(entity towhom, float m) spell_cast =
{
	local entity e;
	local float n;
	n = m & 63;
	self.enemy = towhom;
	e = self;
	if (n == SP_GOTO)
		return;
	else if (n == SP_GOTO2)
		return;
	else if (n == SP_FOLLOW)
		return;
	else if (n == SP_AWAKEMONSTERS)
		spell_fire(m);
	else if (n == SP_ACTIVATE)
	{
		other = self;
		self = towhom;
		if (self.action)
			self.action();
		self = e;
	}
	else if (n == SP_ACTIVATE_SELF)
	{
		// little security check
		if (!(self.m_subject))
		{
			other = towhom;
			if (self.action)
				self.action();
		}
	}
	else if (n == SP_FIGHT_MELEE)
		attack1();
	else if (n == SP_FIGHT_BOW)
		bowattack1();
	else if (n == SP_FIGHT_CBOW)
		cbowattack1();
	else if (n == SP_THROW)
		throw1();
	else if (n == SP_THROW_CHAKRAM)
		chakram1();
	else if (n == SP_JUMP)
		jump1();
	else
	{
		if (!(m & SP_ITEM_CAST)) // scrolls are always usable
		{
			if (self.owner.mana < mana_for_spell(m, GetSpellLevel(self.owner, m)))
			{
				if (self.owner.classname == "player")
					sprint(self.owner, "not enough mana\n");
				return;
			}
		}
		if (n == SP_SPRINT)
		{
			if (self.misc & MISC_SPRINT_DONE)
			{
				spell_fire(m);
			}
		}
		else if (n == SP_BRAWL)
		{
			if (self.owner.altaction & 63 == SP_FIGHT_MELEE)
				spell_fire(m);
		}
		else if (n == SP_FRENZY)
		{
			if (self.owner.altaction & 63 == SP_FIGHT_MELEE)
				spell_fire(m);
		}
		else if (n == SP_FLAME_ARROW)
		{
			// make sure player can use this, has bow equipped
			if (self.owner.altaction & 63 == SP_FIGHT_BOW)
				spell_fire(m);
			else if (self.owner.altaction & 63 == SP_FIGHT_CBOW)
				spell_fire(m);
		}
		else
			cast1();
	}

};

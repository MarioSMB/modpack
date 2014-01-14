.vector spawn_origin, spawn_angles;

void physical_item_think()
{
	self.nextthink = time;

	self.alpha = self.owner.alpha; // apply fading and ghosting

	if(!self.cnt) // map item, not dropped
	{
		// copy ghost item properties
		self.colormap = self.owner.colormap;
		self.colormod = self.owner.colormod;
		self.glowmod = self.owner.glowmod;

		// if the item is not spawned, make sure the invisible / ghost item returns to its origin and stays there
		if(autocvar_g_physical_items_reset)
		{
			if(self.owner.nextthink > time) // awaiting respawn
			{
				setorigin(self, self.spawn_origin);
				self.angles = self.spawn_angles;
				self.solid = SOLID_NOT;
				self.movetype = MOVETYPE_NONE;
			}
			else
			{
				self.solid = SOLID_CORPSE;
				self.movetype = MOVETYPE_PHYSICS;
			}
		}
	}

	if(!self.owner.modelindex)
		remove(self); // the real item is gone, remove this
}

void physical_item_touch()
{
	if(!self.cnt) // not for dropped items
	if (ITEM_TOUCH_NEEDKILL())
	{
		setorigin(self, self.spawn_origin);
		self.angles = self.spawn_angles;
	}
}

void physical_item_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(!self.cnt) // not for dropped items
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
	{
		setorigin(self, self.spawn_origin);
		self.angles = self.spawn_angles;
	}
}

MUTATOR_HOOKFUNCTION(item_spawning)
{
	if(self.owner == world && autocvar_g_physical_items <= 1)
		return FALSE;
	if (self.spawnflags & 1) // floating item
		return FALSE;

	// The actual item can't be physical and trigger at the same time, so make it invisible and use a second entity for physics.
	// Ugly hack, but unless SOLID_TRIGGER is gotten to work with MOVETYPE_PHYSICS in the engine it can't be fixed.
	entity wep;
	wep = spawn();
	setmodel(wep, self.model);
	setsize(wep, self.mins, self.maxs);
	setorigin(wep, self.origin);
	wep.angles = self.angles;
	wep.velocity = self.velocity;

	wep.owner = self;
	wep.solid = SOLID_CORPSE;
	wep.movetype = MOVETYPE_PHYSICS;
	wep.takedamage = DAMAGE_AIM;
	wep.effects |= EF_NOMODELFLAGS; // disable the spinning
	wep.colormap = self.owner.colormap;
	wep.glowmod = self.owner.glowmod;
	wep.damageforcescale = autocvar_g_physical_items_damageforcescale;
	wep.dphitcontentsmask = self.dphitcontentsmask;
	wep.cnt = (self.owner != world);

	wep.think = physical_item_think;
	wep.nextthink = time;
	wep.touch = physical_item_touch;
	wep.event_damage = physical_item_damage;

	wep.spawn_origin = self.origin;
	wep.spawn_angles = self.angles;

	self.effects |= EF_NODRAW; // hide the original weapon
	self.movetype = MOVETYPE_FOLLOW;
	self.aiment = wep; // attach the original weapon

	return FALSE;
}

MUTATOR_DEFINITION(mutator_physical_items)
{
	MUTATOR_HOOK(Item_Spawn, item_spawning, CBC_ORDER_ANY);

	// check if we have a physics engine
	MUTATOR_ONADD
	{
		if (!(autocvar_physics_ode && checkextension("DP_PHYSICS_ODE")))
		{
			dprint("Warning: Physical items are enabled but no physics engine can be used. Reverting to old items.\n");
			return -1;
		}
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// nothing to roll back
	}

	MUTATOR_ONREMOVE
	{
		print("This cannot be removed at runtime\n");
		return -1;
	}

	return 0;
}

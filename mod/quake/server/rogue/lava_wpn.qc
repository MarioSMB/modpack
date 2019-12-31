// LAVA Weapon Routines

/*
===============
launch_lava_spike

Used for both the player and the ogre
===============
*/
void lavaspike_touch(entity this, entity toucher);
entity launch_lava_spike(entity this, vector org, vector dir)
{
	entity newmis = new(lava_spike);
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	settouch(newmis, lavaspike_touch);
	setthink(newmis, SUB_Remove);
	newmis.nextthink = time + 6;
	_setmodel(newmis, "progs/lspike.mdl");	
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;

	return newmis;
}

void superlavaspike_touch(entity this, entity toucher);
void W_FireSuperLavaSpikes(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_lava_nails = this.ammo_lava_nails - 2;
	
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_lava_spike(this, this.origin + '0 0 16', dir);
	settouch(newmis, superlavaspike_touch);

//	setmodel(newmis, "progs/lspike.mdl");			

	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

void W_FireLavaSpikes(entity this, float ox)
{
	makevectors(this.v_angle);
	
	if(this.ammo_lava_nails >= 2 && this.weapon == WEP_LAVA_SUPER_NAILGUN)
	{
		W_FireSuperLavaSpikes(this);
		return;
	}

	if(this.ammo_lava_nails < 1)
	{
		sprint(this, "Out of Lava Nails\n");
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_lava_nails = this.ammo_lava_nails - 1;
	
	vector dir = qc_aim(this, 1000);
	launch_lava_spike(this, this.origin + this.view_ofs + v_up * -8 + v_right * ox, dir);//Seven

	this.punchangle_x = -2;
}

// =============== Lava Spike Touch Routines

void lavaspike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 9);
		if(IS_PLAYER(toucher))
		{
			float old_armortype = toucher.armortype;
			float old_armorvalue = toucher.armorvalue;
			int old_armormask = toucher.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
			toucher.armortype = 0;
			toucher.armorvalue = 0;
			T_Damage(toucher, this, this.owner, 9);
			toucher.armortype = old_armortype;
			toucher.armorvalue = old_armorvalue;
			toucher.items |= old_armormask;
		}
		else		// is a monster
		{
			if(toucher.classname != "monster_lava_man")
				T_Damage(toucher, this, this.owner, 15);
		}
	}
	else
	{
		if(this.classname == "wizspike")
			te_wizspike(this.origin);
		else if(this.classname == "knightspike")
			te_knightspike(this.origin);
		else
			te_spike(this.origin);
	}

	delete(this);
}

void superlavaspike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage)
	{
		spawn_touchblood(this, 18);
		
		// halve the effectiveness of the armor for players..
		if(IS_PLAYER(toucher))
		{
			// save the old armor values...
			float old_armortype = toucher.armortype;
//			old_armorvalue = toucher.armorvalue;
			toucher.armortype = toucher.armortype * 0.5;
//			toucher.armorvalue = 0;
			T_Damage(toucher, this, this.owner, 18);
			
			// if the damage didn't wipe out the armor, armortype 
			if(toucher.armortype != 0)
			{
				toucher.armortype = old_armortype;
//				toucher.armorvalue = old_armorvalue;
			}
		}
		else		// is a monster, do 50% more damage
		{
			if(toucher.classname != "monster_lava_man")
			{
				T_Damage(toucher, this, this.owner, 30);
			}
		}
	}
	else
		te_superspike(this.origin);

	delete(this);
}

#include "gravity_gun.qh"

#include "../../monsters/_mod.qh"

#ifdef SVQC
void wep_gravgun_shot4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_gravgun_shot3(entity this) { wep_set_anim(this, 3, wep_gravgun_shot4); }
void wep_gravgun_shot2(entity this) { wep_set_anim(this, 2, wep_gravgun_shot3); }
void wep_gravgun_shot1(entity this) { wep_set_anim(this, 1, wep_gravgun_shot2); this.owner.effects |= EF_MUZZLEFLASH; }

PRECACHE(GravityGun)
{
	precache_model("progs/g_gravgun.mdl");
	precache_model("progs/v_gravgun.mdl");

	precache_sound("weapons/grav_grab.wav");
	precache_sound("weapons/grav_throw.wav");

}

// handle attacks in PlayerPostFrame instead of wr_think
// as we need to know when to drop the target
void gravgun_postthink(entity this)
{
	Drag(this, false, false); // execute dragging
}

float Drag(entity this, float force_allow_pick, float ischeat)
{
	// returns true when an entity has been picked up
	// If pick is true, the object can also be picked up if it's not being held already
	// If pick is false, only keep dragging the object if it's already being held

	switch(0)
	{
		default:
			if(Drag_IsDragging(this))
			{
				if(PHYS_INPUT_BUTTON_ATCK(this))
				{
#if 0
					if(this.impulse == 10 || this.impulse == 15 || this.impulse == 18)
					{
						Drag_MoveForward(this);
						this.impulse = 0;
					}
					else if(this.impulse == 12 || this.impulse == 16 || this.impulse == 19)
					{
						Drag_MoveBackward(this);
						this.impulse = 0;
					}
					else if(this.impulse >= 1 && this.impulse <= 9)
					{
						Drag_SetSpeed(this, this.impulse - 1);
					}
					else if(this.impulse == 14)
					{
						Drag_SetSpeed(this, 9);
					}
#endif

					if(frametime)
						Drag_Update(this);
				}
				else
				{
					Drag_Finish(this);
				}
			}
			else if(Drag_CanDrag(this) && PHYS_INPUT_BUTTON_ATCK(this))
			{
				crosshair_trace_plusvisibletriggers(this);
				entity e = trace_ent;
				float pick = force_allow_pick;
				if (e && !pick && vdist(this.origin - e.origin, <=, autocvar_sv_quake_gravitygun_range))
				{
					// pick is true if the object can be picked up. While an object is being carried, the Drag() function
					// must execute for it either way, otherwise it would cause bugs if it went out of the player's trace.
					// This also makes sure that an object can only pe picked up if in range, but does not get dropped if
					// it goes out of range while slinging it around.

					pick = true;
				}
				// Find e and pick
				if(e && pick && Drag_IsDraggable(e, this))
				{
					if(e.draggedby)
						Drag_Finish(e.draggedby);
					if(e.tag_entity)
						detach_sameorigin(e);
					Drag_Begin(this, e, trace_endpos);
					return true;
				}
			}
			break;
	}
	return false;
}

void Drag_Begin(entity dragger, entity draggee, vector touchpoint)
{
	float tagscale;

	draggee.dragmovetype = draggee.move_movetype;
	draggee.draggravity = draggee.gravity;
	set_movetype(draggee, MOVETYPE_WALK);
	draggee.gravity = 0.00001;
	UNSET_ONGROUND(draggee);
	draggee.draggedby = dragger;

	dragger.dragentity = draggee;

	dragger.dragdistance = vlen(touchpoint - dragger.origin - dragger.view_ofs);
	dragger.draglocalangle = draggee.angles.y - dragger.v_angle.y;
	touchpoint = touchpoint - gettaginfo(draggee, 0);
	tagscale = (vlen(v_forward) ** -2);
	dragger.draglocalvector_x = touchpoint * v_forward * tagscale;
	dragger.draglocalvector_y = touchpoint * v_right * tagscale;
	dragger.draglocalvector_z = touchpoint * v_up * tagscale;

	dragger.dragspeed = 64;

	if(IS_PLAYER(dragger) && dragger.health > 0)
	{
		W_Attack(dragger, false);
		player_shot1(dragger);
	}
	.entity weaponentity = weaponentities[0]; // WEAPONTODO
	if(dragger.(weaponentity))
		wep_gravgun_shot1(dragger.(weaponentity));

	_sound(dragger, CH_WEAPON_SINGLE, "weapons/grav_grab.wav", VOL_BASE, ATTEN_NORM);
}

void Drag_Finish(entity dragger)
{
	entity draggee;
	draggee = dragger.dragentity;
	if(dragger)
		dragger.dragentity = NULL;
	draggee.draggedby = NULL;
	set_movetype(draggee, draggee.dragmovetype);
	draggee.gravity = draggee.draggravity;

	switch(draggee.move_movetype)
	{
		case MOVETYPE_TOSS:
		case MOVETYPE_WALK:
		case MOVETYPE_STEP:
		case MOVETYPE_FLYMISSILE:
		case MOVETYPE_BOUNCE:
		case MOVETYPE_BOUNCEMISSILE:
		case MOVETYPE_PHYSICS:
			break;
		default:
			draggee.velocity = '0 0 0';
			break;
	}

	if((draggee.flags & FL_ITEM) && (vdist(draggee.velocity, <, 32)))
	{
		draggee.velocity = '0 0 0';
		//SET_ONGROUND(draggee); // floating items are FUN
	}

	if(draggee.classname == "misc_explobox" || draggee.classname == "misc_explobox2")
		set_movetype(draggee, MOVETYPE_TOSS);

	if(dragger && dragger.health > 0)
	{
		if(IS_PLAYER(dragger))
			player_shot1(dragger);
		.entity weaponentity = weaponentities[0]; // WEAPONTODO
		wep_gravgun_shot1(dragger.(weaponentity));

		_sound(dragger, CH_WEAPON_SINGLE, "weapons/grav_throw.wav", VOL_BASE, ATTEN_NORM);
	}
}

bool Drag_IsDraggable(entity draggee, entity dragger)
{
	if(!draggee)
		return false;
	if(vdist(dragger.origin - draggee.origin, >, autocvar_sv_quake_gravitygun_range * 2))
		return false;
	if(IS_PLAYER(draggee) && draggee != dragger && dragger.maycheat && !STAT(CANNON, draggee))
		return true; // hehe
	if(draggee.classname == "cannon")
		return true; // what if there's a player inside lol
	if(draggee.classname == "block")
		return true; // yay steve
	if(draggee.classname == "nuke")
		return true; // sorry oppenheimer
	if(draggee.classname == "teddy")
		return true;
	if(draggee.classname == "chicken_egg")
		return true; // BUCKAW
	// items?
	if(draggee.flags & FL_ITEM)
	{
		// rough check for picked up items
		if(draggee.solid == SOLID_NOT)
			return false;
		// don't move important items as they are necessary for progression
		if(draggee.target && draggee.target != "")
			return false;
		if((draggee.items & IT_KEY1) || (draggee.items & IT_KEY2) || (draggee.items & IT_KEY3))
			return false;
		if(draggee.classname == "item_sigil")
			return false;
		if(draggee.weapon && !weapon_customize(draggee, dragger))
			return false;
		return true;
	}
	// let players throw explosive boxes around (fun)
	if(draggee.classname == "misc_explobox" || draggee.classname == "misc_explobox2")
		return true;
	// SOME monsters
	if(draggee.flags & FL_MONSTER)
	{
		if(draggee.health <= 0)
			return false;
		// don't move important monsters as they are necessary for progression
		if(draggee.target && draggee.target != "")
			return false;
		if((draggee.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (draggee.monsterdef.spawnflags & MON_FLAG_STATIONARY) || ((draggee.monsterdef.spawnflags & MONSTER_TYPE_DECOY)))
			return false;
		return true;
	}

	return false;
}

float Drag_MayChangeAngles(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(substring(draggee.model, 0, 1) == "*")
		return false;
	if(IS_MONSTER(draggee))
		return false; // monsters may face their target
	return true;
}

void Drag_MoveForward(entity dragger)
{
	dragger.dragdistance += dragger.dragspeed;
}

void Drag_SetSpeed(entity dragger, float s)
{
	dragger.dragspeed = (2 ** s);
}

void Drag_MoveBackward(entity dragger)
{
	dragger.dragdistance = max(0, dragger.dragdistance - dragger.dragspeed);
}

void Drag_Update(entity dragger)
{
	vector curorigin, neworigin, goodvelocity;
	float f;
	entity draggee;

	draggee = dragger.dragentity;
	UNSET_ONGROUND(draggee);

	curorigin = gettaginfo(draggee, 0);
	curorigin = curorigin + v_forward * dragger.draglocalvector.x + v_right * dragger.draglocalvector.y + v_up * dragger.draglocalvector.z;
	makevectors(dragger.v_angle);
	neworigin = dragger.origin + dragger.view_ofs + v_forward * dragger.dragdistance;
	goodvelocity = (neworigin - curorigin) * (1 / frametime);

	while(draggee.angles.y - dragger.v_angle.y - dragger.draglocalangle > 180)
		dragger.draglocalangle += 360;
	while(draggee.angles.y - dragger.v_angle.y - dragger.draglocalangle <= -180)
		dragger.draglocalangle -= 360;

	f = min(frametime * 10, 1);
	draggee.velocity = draggee.velocity * (1 - f) + goodvelocity * f;

	if(Drag_MayChangeAngles(draggee))
		draggee.angles_y = draggee.angles.y * (1 - f) + (dragger.v_angle.y + dragger.draglocalangle) * f;

	draggee.ltime = max(servertime + serverframetime, draggee.ltime); // fixes func_train breakage

	//vector vecs = '0 0 0';
	.entity weaponentity = weaponentities[0]; // TODO: unhardcode
	//if(dragger.(weaponentity).movedir.x > 0)
		//vecs = dragger.(weaponentity).movedir;

	//vector dv = v_right * -vecs_y + v_up * vecs_z;

	te_lightning1(draggee, W_Shotorg(dragger, weaponentity) + v_forward * 32 + v_right * 12, curorigin);
}

float Drag_CanDrag(entity dragger)
{
	.entity weaponentity = weaponentities[0]; // WEAPONTODO
	if(dragger.(weaponentity).m_weapon != WEP_GRAVITY_GUN)
		return false;
	if(STAT(CANNON, dragger))
		return false;
	if(STAT(ITEMS, dragger) & IT_TANK)
		return false;
	if(STAT(CLOCKWORK, dragger))
		return false;
	if(dragger.m_transform)
		return false;
	return (dragger.health > 0 && IS_PLAYER(dragger));
}

float Drag_IsDragging(entity dragger)
{
	if(!dragger.dragentity)
		return false;
	if(wasfreed(dragger.dragentity) || dragger.dragentity.draggedby != dragger)
	{
		dragger.dragentity = NULL;
		return false;
	}
	if(!Drag_CanDrag(dragger) || !Drag_IsDraggable(dragger.dragentity, dragger))
	{
		Drag_Finish(dragger);
		return false;
	}
	return true;
}

void Drag_MoveDrag(entity from, entity to)
{
	if(from.draggedby)
	{
		to.draggedby = from.draggedby;
		to.draggedby.dragentity = to;
		from.draggedby = NULL;
	}
}

METHOD(GravityGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	// handle attacks in PlayerPostFrame instead of wr_think
	// as we need to know when to drop the target
}
METHOD(GravityGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// does not use ammo
	return true;
}
METHOD(GravityGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(GravityGun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

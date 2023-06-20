#include "weaponsystem.qh"

bool CL_Weaponentity_CustomizeEntityForClient(entity this, entity client)
{
	this.viewmodelforclient = this.owner;
	return false;
}

.float m_alpha;
.string w_weaponname;
.int w_dmg;
.int w_deadflag;

void CL_Weaponentity_Think(entity this)
{
	this.nextthink = time;
	if (this.owner.(weaponentity) != this)
	{
		// owner has new gun; remove old one
		delete(this);
		return;
	}
	if (this.owner.health <= 0 || STAT(SKATING, this.owner))
	{
		// owner died; disappear
		this.model = "";
		return;
	}
	if (this.w_weaponname != this.weaponname || this.w_dmg != this.modelindex || this.w_deadflag != this.deadflag)
	{
		// owner changed weapons; update appearance
		this.w_weaponname = this.weaponname;
		this.w_dmg = this.modelindex;
		this.w_deadflag = this.deadflag;

		CL_WeaponEntity_SetModel(this, this.weaponname);
	}

	this.alpha = -1;  // TODO: don't render this entity at all
}

// spawning weaponentity for client
void CL_SpawnWeaponentity(entity actor)
{
	entity w_ent = actor.(weaponentity) = new(weaponentity);
	w_ent.solid = SOLID_NOT;
	w_ent.owner = actor;
	setmodel(w_ent, MDL_Null);  // precision set when changed
	setorigin(w_ent, '0 0 0');
	setthink(w_ent, CL_Weaponentity_Think);
	w_ent.nextthink = time;
	w_ent.viewmodelforclient = actor;
	setcefc(w_ent, CL_Weaponentity_CustomizeEntityForClient);

	wepent_link(w_ent);
}

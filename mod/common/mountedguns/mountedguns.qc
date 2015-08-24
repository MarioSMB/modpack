string W_Sound(string input)
{
	return strcat("weapons/", input, ".wav");
}

#include "mountedguns.qh"

#include "unit/all.qc"

#ifdef SVQC

void mg_common_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, string tagname)
{
	entity e;
	vector org;
		
	org = gettaginfo(casingowner, gettagindex(casingowner, tagname));

	if(!sound_allowed(MSG_BROADCAST, casingowner))
		casingtype |= 0x80;

	e = spawn();
	e.state = casingtype;
	setorigin(e, org);
	e.velocity = vel;
	e.angles = ang;
	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, TRUE, 0.2, Casing_SendEntity);
		// 0.2s should be enough time for all clients to receive this ent once, do the gibbage and be done with it
}

void mg_common_AttachToShotorg(entity flash, vector offset, string tagname, entity attach)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;


	setattachment(flash, self, tagname);
	setorigin(flash, offset);

	xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = self;

	setattachment(xflash, attach, tagname);
	setorigin(xflash, offset);
}


#endif

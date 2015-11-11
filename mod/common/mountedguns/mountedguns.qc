#include "mountedguns.qh"

#include "unit/all.qc"

#ifdef SVQC

void mg_common_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, int casingtype, entity casingowner, string tagname)
{
    vector org = gettaginfo(casingowner, gettagindex(casingowner, tagname));

    if (!sound_allowed(MSG_BROADCAST, casingowner))
        casingtype |= 0x80;

    WriteHeader(MSG_ALL, casings);
    WriteByte(MSG_ALL, casingtype);
    WriteCoord(MSG_ALL, org.x);
    WriteCoord(MSG_ALL, org.y);
    WriteCoord(MSG_ALL, org.z);
    WriteShort(MSG_ALL, compressShortVector(vel)); // actually compressed velocity
    WriteByte(MSG_ALL, ang.x * 256 / 360);
    WriteByte(MSG_ALL, ang.y * 256 / 360);
    WriteByte(MSG_ALL, ang.z * 256 / 360);
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

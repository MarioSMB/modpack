#ifdef SVQC

void vwep_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, int casingtype, entity casingowner, string tagname)
{
	if(autocvar_g_casings < 2)
		return;

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

void vwep_AttachToShotorg(entity this, entity flash, vector offset, string tagname, entity attach)
{
	flash.owner = this;
	flash.angles_z = random() * 360;

	setattachment(flash, this, tagname);
	setorigin(flash, offset);

	entity xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = this;

	setattachment(xflash, attach, tagname);
	setorigin(xflash, offset);
}

#endif

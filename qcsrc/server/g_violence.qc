float Violence_GibSplash_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GIBSPLASH);
	WriteByte(MSG_ENTITY, self.state); // actually type
	WriteByte(MSG_ENTITY, bound(1, self.cnt * 16, 255)); // gibbage amount multiplier
	WriteShort(MSG_ENTITY, floor(self.origin_x / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, floor(self.origin_y / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, floor(self.origin_z / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteShort(MSG_ENTITY, self.oldorigin_x); // acrually compressed velocity
	return TRUE;
}

// TODO maybe convert this to a TE?
void Violence_GibSplash_At(vector org, vector dir, float type, float amount, entity gibowner, entity attacker)
{
	if(g_cts) // no gibs in CTS
		return;

	entity e;

	e = spawn();
	e.classname = "gibsplash";
	e.cnt = amount;
	e.state = type; // should stay smaller than 15
	if(!sound_allowed(MSG_BROADCAST, gibowner) || !sound_allowed(MSG_BROADCAST, attacker))
		e.state |= 0x40; // "silence" bit
	e.state |= 8 * self.species; // gib type, ranges from 0 to 15

	// if this is a copied dead body, send the num of its player instead
	// TODO: remove this field, read from model txt files
	if(self.classname == "body")
		e.team = num_for_edict(self.enemy);
	else
		e.team = num_for_edict(self);

	setorigin(e, org);
	e.velocity = dir;

	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, FALSE, 0.2, Violence_GibSplash_SendEntity);
}

void Violence_GibSplash(entity source, float type, float amount, entity attacker)
{
	Violence_GibSplash_At(source.origin + source.view_ofs, source.velocity, type, amount, source, attacker);
}

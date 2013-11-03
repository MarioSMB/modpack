/**
 * The point of these entities is to avoid the problems
 * with clientprediction.
 * If you add SendEntity to players, the engine will not
 * do any prediction anymore, and you'd have to write the whole
 * prediction code in CSQC, you want that? :P
 * Data can depend on gamemode. For now, it serves as GPS entities
 * in onslaught... YAY ;)
 */

// Beware: do not redefine those in other files
// and NO, you cannot use ".version", which already exists (at least
// it did when I added this) But you have to use .Version
// Capital V

.entity entcs;

void entcs_init()
{
	print("Initializing ClientSide information entities\n");
}

float entcs_customize()
{
	entity o;
	o = self.owner;
	if(o.deadflag != DEAD_NO)
		return FALSE;
	if (!IS_PLAYER(o))
		return FALSE;
	if(other == o)
		return FALSE;
	if((IS_PLAYER(other)) || other.caplayer)
		if(!teamplay || o.team != other.team)
			if (!radar_showennemies)
				return FALSE;
	return TRUE;
}

float entcs_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_ENTCS);
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
		WriteByte(MSG_ENTITY, num_for_edict(self.owner)-1);
	if(sf & 2)
	{
		WriteShort(MSG_ENTITY, self.origin_x);
		WriteShort(MSG_ENTITY, self.origin_y);
		WriteShort(MSG_ENTITY, self.origin_z);
	}
	if(sf & 4)
		WriteByte(MSG_ENTITY, self.angles_y * 256.0 / 360);
	if(sf & 8)
		WriteByte(MSG_ENTITY, self.health / 10); // FIXME use a better scale?
	if(sf & 16)
		WriteByte(MSG_ENTITY, self.armorvalue / 10); // FIXME use a better scale?
	return TRUE;
}

void entcs_think()
{
	self.nextthink = time + 0.033333333333; // increase this to like 0.15 once the client can do smoothing

	entity o;
	o = self.owner;

	if(o.origin != self.origin)
	{
		setorigin(self, o.origin);
		self.SendFlags |= 2;
	}
	if(o.angles_y != self.angles_y)
	{
		self.angles = o.angles;
		self.SendFlags |= 4;
	}
	if(o.health != self.health)
	{
		self.health = o.health;
		self.SendFlags |= 8;
	}
	if(o.armorvalue != self.armorvalue)
	{
		self.armorvalue = o.armorvalue;
		self.SendFlags |= 16;
	}
}

entity attach_entcs()
{
	entity ent;

	ent = spawn();
	ent.classname = "entcs_sender_v2";
	ent.owner = self;
	ent.think = entcs_think;
	ent.nextthink = time;

	Net_LinkEntity(ent, FALSE, 0, entcs_send);
	ent.customizeentityforclient = entcs_customize;

	self.entcs = ent;

	return ent;
}

void detach_entcs()
{
	remove(self.entcs);
	self.entcs = world;
}

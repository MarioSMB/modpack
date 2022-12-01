.IntrusiveList collected; // keep track of who collected what

bool item_customize(entity this, entity client)
{
	if(!this.collected)
		return false; // not sure how, but let's be safe
	return !(IL_CONTAINS(this.collected, client));
}

void base_item(entity this)
{
	this.solid = SOLID_TRIGGER;
	this.scale = 3;
	setsize(this, '-20 -20 0', '20 20 48');
	if(!this.collected)
		this.collected = IL_NEW();
	setcefc(this, item_customize);
	set_movetype(this, MOVETYPE_NONE); // add to the moveable items list so that we can access it when disconnecting the player
}

void heart_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(IL_CONTAINS(this.collected, toucher)) return;
	
	sound(toucher, CHAN_AUTO, SND_SWORD_PICKUP, 1, ATTEN_NORM);
	pointparticles(EFFECT_ITEM_PICKUP, this.origin + '0 0 24', '0 0 100', 1);
	toucher.max_health += 1;
	toucher.health = toucher.max_health;
	msg_entity = toucher;
	WriteHeader(MSG_ONE, TE_CSQC_ITEMPICKUP);
	WriteByte(MSG_ONE, 1);
	IL_PUSH(this.collected, toucher);
}

spawnfunc(item_heart) 
{
	setmodel(this, MDL_HEART);
	settouch(this, heart_touch);
	base_item(this);
}

void feather_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(IL_CONTAINS(this.collected, toucher)) return;
	
	sound(toucher, CHAN_AUTO, SND_SWORD_PICKUP, 1, ATTEN_NORM);
	pointparticles(EFFECT_ITEM_PICKUP, this.origin + '0 0 24', '0 0 100', 1);
	STAT(FEATHER, toucher) += 1;
	msg_entity = toucher;
	WriteHeader(MSG_ONE, TE_CSQC_ITEMPICKUP);
	WriteByte(MSG_ONE, 2);
	IL_PUSH(this.collected, toucher);
}

spawnfunc(item_feather)
{
	setmodel(this, MDL_FEATHER);
	
	settouch(this, feather_touch);
	base_item(this);
}

void sword_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher)) return;
	if(IL_CONTAINS(this.collected, toucher)) return;
	
	sound(toucher, CHAN_AUTO, SND_SWORD_PICKUP, 1, ATTEN_NORM);
	pointparticles(EFFECT_ITEM_PICKUP, this.origin + '0 0 24', '0 0 100', 1);
	STAT(SWORDPOWER, toucher) += 1;
	msg_entity = toucher;
	WriteHeader(MSG_ONE, TE_CSQC_ITEMPICKUP);
	WriteByte(MSG_ONE, 3);
	IL_PUSH(this.collected, toucher);
}

spawnfunc(item_sword)
{
	setmodel(this, MDL_SWORD);
	
	settouch(this, sword_touch);
	base_item(this);
}

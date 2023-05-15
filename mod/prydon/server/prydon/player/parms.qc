#include "parms.qh"

void prydon_SetNewParms()
{
	ENGINE_EVENT();
	if(!this)
		return;
	this.health = 27;
	this.max_health = 25;
	this.mana = 2;
	this.exp = 1;
	this.str = 0;
	this.dex = 0;
	this.mag = 0;
	this.agil = 0;
	this.lvl = 1;
	this.luck = 0;
	this.questlog = 2;
	this.spells1 = 0;
	this.spells2 = 0;
	this.spell = 0;
	this.ptd = 5;
	this.gp = 12;
	this.equip = 3;
	this.slot1_x = IT_ITHAELS_ROBE;
	this.slot1_y = encode(0, 0, 1);
	this.slot1_z = 6;

	this.slot2_x = IT_CLUB;
	this.slot2_y = encode(PF_CHEAP, SF_SPELL + SP_FIREBALL, 1);
	this.slot2_z = 8;
	this.slot3 = this.slot4 = this.slot5 = this.slot6 = this.slot7 = this.slot8 = IV_NULL;

	this.sounds = 1;
}

void ConvertParms(entity this, float from)
{
	// new system
	if(from >= 2)
		return;
	localcmd("echo converting old save file...\n");
	GetParms(this, from);
	SetParms(this);
}

void SetParms(entity this)
{
	if(this.authed != AUTH_YES && mplayer)
		return;
	parm_save_begin(this);
	if(fileaccess)
	{
		qwrite(ftos(this.pin));
		parm2 = this.pin;
	}
	parm_save(this.health, 256);
	parm_save(this.max_health, 256);
	parm_save(this.mana, 256);
	parm_save(this.questlog/2, 2);
	parm_save(this.exp, 1048576);
	parm_save(this.str, 256);
	parm_save(this.mag, 256);
	parm_save(this.dex, 256);
	parm_save(this.vit, 256);
	parm_save(this.agil, 256);
	parm_save(this.luck, 256);
	parm_save(this.ptd, 128);
	parm_save(this.options, 32);
	for(int i = 1; i <= 16; i = i + 1)
		parm_save(GetSpellLevel(this, i), 8);
	parm_save(this.spell & 63, 64);
	parm_save(this.gp, 32768);
	parm_save(this.equip, 65536);
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
		encodeitem(GetSlot(this, i));

	dprint_lhbitparms_space(0, 23);
	parm_save_end();
	if(mplayer)
		strfree(this.username);
}

void prydon_SetChangeParms(entity this)
{
	regain_body(this);
	
	// update the total running time
	savedata();
	if(saveversion != SAVE_VERSION)
		ConvertParms(this, saveversion);
	if(world.map != "" || mapname == "save")
	{
		SetParms(this);
		return;
	}
	// remove all equipment so the player's stats will return to 'base'
	Unstat(this);
	SetParms(this);

}
void GetParms(entity this, float ver)
{
	if(ver == 0)
		legacy_parmsv0(this);
	else if(ver == 1)
		legacy_parmsv1(this);
	else if(ver == 2)
		legacy_parmsv2(this);
}

void DecodeLevelParms(entity this)
{
	if(!parm1 && !mplayer)
	{
		__self = this;
		SetNewParms();
	}
	else
		GetParms(this, saveversion);
	if(this.health < 1)
		this.health = 1;
	if(world.map)
		return;
	// restore player's equip effects
	this.title = '0 0 -1';
	titleupdate(this);
	Restat(this);
}

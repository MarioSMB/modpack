#include "parmsv2.qh"

#include "../spells/spells.qh"
#include "../stats/exp.qh"
#include "../subs/parms.qh"

void legacy_parmsv2(entity this)
{	
/* Prydon 1.5 */
	if(parm_load_begin(this))
	{
		if(fileaccess)
			qread(); // read past pin

		this.health = 		parm_load(256);
		this.max_health = 	parm_load(256);
		this.mana =		parm_load(256);
		this.questlog =		parm_load(2) * 2;
		this.experience = 		parm_load(1048576);
		this.str = 		parm_load(256);
		this.mag =		parm_load(256);
		this.dex = 		parm_load(256);
		this.vit = 		parm_load(256);
		this.agil = 		parm_load(256);
		this.luck =		parm_load(256);
		this.ptd =		parm_load(128);
		this.options =          parm_load(32);

		for(int i = 1; i <= 16; i = i + 1)
			SetSpellLevel(this, i, parm_load(8));
		
		this.spell =		parm_load(64);
		this.gp =		parm_load(32768);
		this.equip =		parm_load(65536);
		for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
			SetSlot(this, i, decodeitem());
	
		parm_load_end();
	}
	else
	{
		__self = this;
		SetNewParms();
	}
	if(!this.experience)
		this.experience = 1;
	this.lvl = LvlForExp(this.experience);
}

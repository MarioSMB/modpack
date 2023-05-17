#include "npc.qh"

void legacy_fixinv(entity this)
{
	if(this.slot1_x > BASEITEMS)
		this.slot1 = legacy_itemv1(this.slot1_x);
	if(this.slot2_x > BASEITEMS)
		this.slot2 = legacy_itemv1(this.slot2_x);
	if(this.slot3_x > BASEITEMS)
		this.slot3 = legacy_itemv1(this.slot3_x);
	if(this.slot4_x > BASEITEMS)
		this.slot4 = legacy_itemv1(this.slot4_x);
	if(this.slot5_x > BASEITEMS)
		this.slot5 = legacy_itemv1(this.slot4_x);
	if(this.slot6_x > BASEITEMS)
		this.slot6 = legacy_itemv1(this.slot4_x);
	if(this.slot7_x > BASEITEMS)
		this.slot7 = legacy_itemv1(this.slot4_x);
	if(this.slot8_x > BASEITEMS)
		this.slot8 = legacy_itemv1(this.slot4_x);

}
void legacy_npc(entity this)
{
	if(this.rightarm_x > IT_SPEARS)
		this.rightarm_x = this.rightarm_x + 32;
	if(this.leftarm_x > IT_SPEARS)
		this.leftarm_x = this.leftarm_x + 32;
		
	legacy_fixinv(this);

	if(this.spec & SPEC_SPEED)
		this.aspeed = this.aspeed + 33;
	if(this.gotstuff > 16)
		this.altaction = this.gotstuff + 8;
	else
		this.altaction = this.gotstuff;
	if(this.spell > 16)
		this.spell = this.spell + 8;
	if(this.spells1 > 7 || this.spells2 > 7)
		decompress_spells(this);
	if(this.message == "talk")
		this.message = "l_talk";
}

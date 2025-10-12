#include "loosecannon.qh"

#ifdef SVQC
PRECACHE(LooseCannon)
{
	precache_model("progs/v_loosecannon.mdl");
	precache_model("progs/g_loosecannon.mdl");

	precache_model("progs/s_explo2.spr");

	precache_model("progs/donk_ball.mdl");
	precache_model("progs/donk_ball_crit.mdl");
	precache_model("progs/s_donk.spr");
	precache_sound("pirate/double_donk.wav");

	precache_sound("pirate/loose_cannon_charge.wav");	
	precache_sound("pirate/loose_cannon_fire.wav");
}

////////////////////////////////////////////////////////////////////////////////////////////////
// TF2 loose cannon remake by Kebby
////////////////////////////////////////////////////////////////////////////////////////////////

void DonkTouchCrit(entity this, entity toucher);
void DonkTouchDud(entity this, entity toucher);

void saf(entity this, float float_finish);
void snt(entity this, float float_think);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void p_loose_41(entity this);
void interrupt_loose_charge(entity this, float fuse_time)
{
	entity actor = this.owner;
	if(!actor.button0 || actor.impulse)
	{
		saf(this, 0.5);
		p_loose_41(this);
		W_FireLooseCannon(actor, fuse_time, this.weaponentity_fld);
		actor.effects |= EF_MUZZLEFLASH;
	} 
}

void p_loose_50(entity this) { wep_set_anim(this, 50, w_ready); snt(this, 0.05); }
void p_loose_49(entity this) { wep_set_anim(this, 49, p_loose_50); snt(this, 0.05); }
void p_loose_48(entity this) { wep_set_anim(this, 48, p_loose_49); snt(this, 0.05); }
void p_loose_47(entity this) { wep_set_anim(this, 47, p_loose_48); snt(this, 0.05); }
void p_loose_46(entity this) { wep_set_anim(this, 46, p_loose_47); snt(this, 0.05); }
void p_loose_45(entity this) { wep_set_anim(this, 45, p_loose_46); snt(this, 0.05); }
void p_loose_44(entity this) { wep_set_anim(this, 44, p_loose_45); snt(this, 0.05); }
void p_loose_43(entity this) { wep_set_anim(this, 43, p_loose_44); snt(this, 0.05); }
void p_loose_42(entity this) { wep_set_anim(this, 42, p_loose_43); snt(this, 0.05); }
void p_loose_41(entity this) { wep_set_anim(this, 41, p_loose_42); snt(this, 0.05); }

void p_loose_40(entity this) { wep_set_anim(this, 40, p_loose_41); snt(this, 0.025); saf(this, 0.5); W_FireLooseCannon(this.owner, 40, this.weaponentity_fld); this.owner.effects |= EF_MUZZLEFLASH; }
void p_loose_39(entity this) { wep_set_anim(this, 39, p_loose_40); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 39); }
void p_loose_38(entity this) { wep_set_anim(this, 38, p_loose_39); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 38); }
void p_loose_37(entity this) { wep_set_anim(this, 37, p_loose_38); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 37); }
void p_loose_36(entity this) { wep_set_anim(this, 36, p_loose_37); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 36); }
void p_loose_35(entity this) { wep_set_anim(this, 35, p_loose_36); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 35); }
void p_loose_34(entity this) { wep_set_anim(this, 34, p_loose_35); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 34); }
void p_loose_33(entity this) { wep_set_anim(this, 33, p_loose_34); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 33); }
void p_loose_32(entity this) { wep_set_anim(this, 32, p_loose_33); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 32); }
void p_loose_31(entity this) { wep_set_anim(this, 31, p_loose_32); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 31); }
void p_loose_30(entity this) { wep_set_anim(this, 30, p_loose_31); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 30); }
void p_loose_29(entity this) { wep_set_anim(this, 29, p_loose_30); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 29); }
void p_loose_28(entity this) { wep_set_anim(this, 28, p_loose_29); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 28); }
void p_loose_27(entity this) { wep_set_anim(this, 27, p_loose_28); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 27); }
void p_loose_26(entity this) { wep_set_anim(this, 26, p_loose_27); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 26); }
void p_loose_25(entity this) { wep_set_anim(this, 25, p_loose_26); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 25); }
void p_loose_24(entity this) { wep_set_anim(this, 24, p_loose_25); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 24); }
void p_loose_23(entity this) { wep_set_anim(this, 23, p_loose_24); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 23); }
void p_loose_22(entity this) { wep_set_anim(this, 22, p_loose_23); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 22); }
void p_loose_21(entity this) { wep_set_anim(this, 21, p_loose_22); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 21); }
void p_loose_20(entity this) { wep_set_anim(this, 20, p_loose_21); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 20); }
void p_loose_19(entity this) { wep_set_anim(this, 19, p_loose_20); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 19); }
void p_loose_18(entity this) { wep_set_anim(this, 18, p_loose_19); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 18); }
void p_loose_17(entity this) { wep_set_anim(this, 17, p_loose_18); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 17); }
void p_loose_16(entity this) { wep_set_anim(this, 16, p_loose_17); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 16); }
void p_loose_15(entity this) { wep_set_anim(this, 15, p_loose_16); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 15); }
void p_loose_14(entity this) { wep_set_anim(this, 14, p_loose_15); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 14); }
void p_loose_13(entity this) { wep_set_anim(this, 13, p_loose_14); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 13); }
void p_loose_12(entity this) { wep_set_anim(this, 12, p_loose_13); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 12); }
void p_loose_11(entity this) { wep_set_anim(this, 11, p_loose_12); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 11); }
void p_loose_10(entity this) { wep_set_anim(this, 10, p_loose_11); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 10); }
void p_loose__9(entity this) { wep_set_anim(this, 9, p_loose_10); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 9); }
void p_loose__8(entity this) { wep_set_anim(this, 8, p_loose__9); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 8); }
void p_loose__7(entity this) { wep_set_anim(this, 7, p_loose__8); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 7); }
void p_loose__6(entity this) { wep_set_anim(this, 6, p_loose__7); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 6); }
void p_loose__5(entity this) { wep_set_anim(this, 5, p_loose__6); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 5); }
void p_loose__4(entity this) { wep_set_anim(this, 4, p_loose__5); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 4); }
void p_loose__3(entity this) { wep_set_anim(this, 3, p_loose__4); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 3); }
void p_loose__2(entity this) { wep_set_anim(this, 2, p_loose__3); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 2); }
void p_loose__1(entity this) { wep_set_anim(this, 1, p_loose__2); snt(this, 0.025); saf(this, 0.05); interrupt_loose_charge(this, 1); }

//=============================================================================================


void s_donk6(entity this) { set_anim(this, 0, SUB_Remove); }
void s_donk5(entity this) { set_anim(this, 0, s_donk6); }
void s_donk4(entity this) { set_anim(this, 0, s_donk5); }
void s_donk3(entity this) { set_anim(this, 0, s_donk4); }
void s_donk2(entity this) { set_anim(this, 0, s_donk3); }
void s_donk1(entity this) { set_anim(this, 0, s_donk2); }

//=============================================================================================
// p_donk  1-24 check if hit enemy (0.6)
// always WEAK --> 1-40

void touch_donk(entity this) { this.nextthink = time + 0.025; settouch(this, DonkTouchDud); }
void touch_donkcrit(entity this) { this.nextthink = time + 0.025; settouch(this, DonkTouchCrit); }

void DonkExplodeCrit(entity this);
void DonkExplodeDud(entity this);
void p_donk_40(entity this) { set_anim(this, 40, DonkExplodeDud); touch_donkcrit(this); this.enemy = NULL; }
void p_donk_39(entity this) { set_anim(this, 39, p_donk_40); touch_donkcrit(this); }
void p_donk_38(entity this) { set_anim(this, 38, p_donk_39); touch_donkcrit(this); }
void p_donk_37(entity this) { set_anim(this, 37, p_donk_38); touch_donkcrit(this); }
void p_donk_36(entity this) { set_anim(this, 36, p_donk_37); touch_donkcrit(this); }
void p_donk_35(entity this) { set_anim(this, 35, p_donk_36); touch_donkcrit(this); }
void p_donk_34(entity this) { set_anim(this, 34, p_donk_35); touch_donkcrit(this); }
void p_donk_33(entity this) { set_anim(this, 33, p_donk_34); touch_donkcrit(this); }
void p_donk_32(entity this) { set_anim(this, 32, p_donk_33); touch_donkcrit(this); }
void p_donk_31(entity this) { set_anim(this, 31, p_donk_32); touch_donkcrit(this); }
void p_donk_30(entity this) { set_anim(this, 30, p_donk_31); touch_donkcrit(this); }
void p_donk_29(entity this) { set_anim(this, 29, p_donk_30); touch_donkcrit(this); }
void p_donk_28(entity this) { set_anim(this, 28, p_donk_29); touch_donkcrit(this); }
void p_donk_27(entity this) { set_anim(this, 27, p_donk_28); touch_donkcrit(this); }
void p_donk_26(entity this) { set_anim(this, 26, p_donk_27); touch_donkcrit(this); }
void p_donk_25(entity this) { set_anim(this, 25, p_donk_26); touch_donkcrit(this); }

void p_donk_24(entity this) { set_anim(this, 2, p_donk_25); touch_donk(this); }
void p_donk_23(entity this) { set_anim(this, 2, p_donk_24); touch_donk(this); }
void p_donk_22(entity this) { set_anim(this, 2, p_donk_23); touch_donk(this); }
void p_donk_21(entity this) { set_anim(this, 2, p_donk_22); touch_donk(this); }
             
void p_donk_20(entity this) { set_anim(this, 20, p_donk_21); touch_donk(this); }
void p_donk_19(entity this) { set_anim(this, 19, p_donk_20); touch_donk(this); }
void p_donk_18(entity this) { set_anim(this, 18, p_donk_19); touch_donk(this); }
void p_donk_17(entity this) { set_anim(this, 17, p_donk_18); touch_donk(this); }
void p_donk_16(entity this) { set_anim(this, 16, p_donk_17); touch_donk(this); }
void p_donk_15(entity this) { set_anim(this, 15, p_donk_16); touch_donk(this); }
void p_donk_14(entity this) { set_anim(this, 14, p_donk_15); touch_donk(this); }
void p_donk_13(entity this) { set_anim(this, 13, p_donk_14); touch_donk(this); }
void p_donk_12(entity this) { set_anim(this, 12, p_donk_13); touch_donk(this); }
void p_donk_11(entity this) { set_anim(this, 11, p_donk_12); touch_donk(this); }
void p_donk_10(entity this) { set_anim(this, 10, p_donk_11); touch_donk(this); }
void p_donk__9(entity this) { set_anim(this, 9, p_donk_10); touch_donk(this); }
void p_donk__8(entity this) { set_anim(this, 8, p_donk__9); touch_donk(this); }
void p_donk__7(entity this) { set_anim(this, 7, p_donk__8); touch_donk(this); }
void p_donk__6(entity this) { set_anim(this, 6, p_donk__7); touch_donk(this); }
void p_donk__5(entity this) { set_anim(this, 5, p_donk__6); touch_donk(this); }
void p_donk__4(entity this) { set_anim(this, 4, p_donk__5); touch_donk(this); }
void p_donk__3(entity this) { set_anim(this, 3, p_donk__4); touch_donk(this); }
void p_donk__2(entity this) { set_anim(this, 2, p_donk__3); touch_donk(this); }
void p_donk__1(entity this) { set_anim(this, 1, p_donk__2); touch_donk(this); }
  
             
//=============================================================================================
// p_donk 25-40 check if hit enemy
// if NO  --> WEAK 1-40                                          

void p_donkdud_40(entity this) { set_anim(this, 20, DonkExplodeDud); snt(this, 0.025); }
void p_donkdud_39(entity this) { set_anim(this, 19, p_donkdud_40); snt(this, 0.025); }
void p_donkdud_38(entity this) { set_anim(this, 18, p_donkdud_39); snt(this, 0.025); }
void p_donkdud_37(entity this) { set_anim(this, 17, p_donkdud_38); snt(this, 0.025); }
void p_donkdud_36(entity this) { set_anim(this, 16, p_donkdud_37); snt(this, 0.025); }
void p_donkdud_35(entity this) { set_anim(this, 15, p_donkdud_36); snt(this, 0.025); }
void p_donkdud_34(entity this) { set_anim(this, 14, p_donkdud_35); snt(this, 0.025); }
void p_donkdud_33(entity this) { set_anim(this, 13, p_donkdud_34); snt(this, 0.025); }
void p_donkdud_32(entity this) { set_anim(this, 12, p_donkdud_33); snt(this, 0.025); }
void p_donkdud_31(entity this) { set_anim(this, 11, p_donkdud_32); snt(this, 0.025); }
void p_donkdud_30(entity this) { set_anim(this, 10, p_donkdud_31); snt(this, 0.025); }
void p_donkdud_29(entity this) { set_anim(this, 9, p_donkdud_30); snt(this, 0.025); }
void p_donkdud_28(entity this) { set_anim(this, 8, p_donkdud_29); snt(this, 0.025); }
void p_donkdud_27(entity this) { set_anim(this, 7, p_donkdud_28); snt(this, 0.025); }
void p_donkdud_26(entity this) { set_anim(this, 6, p_donkdud_27); snt(this, 0.025); }
void p_donkdud_25(entity this) { set_anim(this, 5, p_donkdud_26); snt(this, 0.025); }
void p_donkdud_24(entity this) { set_anim(this, 4, p_donkdud_25); snt(this, 0.025); }
void p_donkdud_23(entity this) { set_anim(this, 3, p_donkdud_24); snt(this, 0.025); }
void p_donkdud_22(entity this) { set_anim(this, 2, p_donkdud_23); snt(this, 0.025); }
void p_donkdud_21(entity this) { set_anim(this, 1, p_donkdud_22); snt(this, 0.025); }

void p_donkdud_20(entity this) { set_anim(this, 20, p_donkdud_21); snt(this, 0.025); }
void p_donkdud_19(entity this) { set_anim(this, 19, p_donkdud_20); snt(this, 0.025); }
void p_donkdud_18(entity this) { set_anim(this, 18, p_donkdud_19); snt(this, 0.025); }
void p_donkdud_17(entity this) { set_anim(this, 17, p_donkdud_18); snt(this, 0.025); }
void p_donkdud_16(entity this) { set_anim(this, 16, p_donkdud_17); snt(this, 0.025); }
void p_donkdud_15(entity this) { set_anim(this, 15, p_donkdud_16); snt(this, 0.025); }
void p_donkdud_14(entity this) { set_anim(this, 14, p_donkdud_15); snt(this, 0.025); }
void p_donkdud_13(entity this) { set_anim(this, 13, p_donkdud_14); snt(this, 0.025); }
void p_donkdud_12(entity this) { set_anim(this, 12, p_donkdud_13); snt(this, 0.025); }
void p_donkdud_11(entity this) { set_anim(this, 11, p_donkdud_12); snt(this, 0.025); }
void p_donkdud_10(entity this) { set_anim(this, 10, p_donkdud_11); snt(this, 0.025); }
void p_donkdud__9(entity this) { set_anim(this, 9, p_donkdud_10); snt(this, 0.025); }
void p_donkdud__8(entity this) { set_anim(this, 8, p_donkdud__9); snt(this, 0.025); }
void p_donkdud__7(entity this) { set_anim(this, 7, p_donkdud__8); snt(this, 0.025); }
void p_donkdud__6(entity this) { set_anim(this, 6, p_donkdud__7); snt(this, 0.025); }
void p_donkdud__5(entity this) { set_anim(this, 5, p_donkdud__6); snt(this, 0.025); }
void p_donkdud__4(entity this) { set_anim(this, 4, p_donkdud__5); snt(this, 0.025); }
void p_donkdud__3(entity this) { set_anim(this, 3, p_donkdud__4); snt(this, 0.025); }
void p_donkdud__2(entity this) { set_anim(this, 2, p_donkdud__3); snt(this, 0.025); }
void p_donkdud__1(entity this) { set_anim(this, 1, p_donkdud__2); snt(this, 0.025); }


//=============================================================================================
// p_donk 25-40 check if hit enemy (last 0.4)
// if YES --> CRITAL 21-40


//void()	p_donkcrit_21 =		[21, p_donkcrit_22	] 	{snt(0.025); }
//void()	p_donkcrit_22 =		[22, p_donkcrit_23	] 	{snt(0.025); }
//void()	p_donkcrit_23 =		[23, p_donkcrit_24	] 	{snt(0.025); }
//void()	p_donkcrit_24 =		[24, p_donkcrit_25	] 	{snt(0.025); }

void p_donkcrit_40(entity this) { set_anim(this, 40, DonkExplodeCrit); snt(this, 0.025); this.enemy = NULL; }
void p_donkcrit_39(entity this) { set_anim(this, 39, p_donkcrit_40); snt(this, 0.025); }
void p_donkcrit_38(entity this) { set_anim(this, 38, p_donkcrit_39); snt(this, 0.025); }
void p_donkcrit_37(entity this) { set_anim(this, 37, p_donkcrit_38); snt(this, 0.025); }
void p_donkcrit_36(entity this) { set_anim(this, 36, p_donkcrit_37); snt(this, 0.025); }
void p_donkcrit_35(entity this) { set_anim(this, 35, p_donkcrit_36); snt(this, 0.025); }
void p_donkcrit_34(entity this) { set_anim(this, 34, p_donkcrit_35); snt(this, 0.025); }
void p_donkcrit_33(entity this) { set_anim(this, 33, p_donkcrit_34); snt(this, 0.025); }
void p_donkcrit_32(entity this) { set_anim(this, 32, p_donkcrit_33); snt(this, 0.025); }
void p_donkcrit_31(entity this) { set_anim(this, 31, p_donkcrit_32); snt(this, 0.025); }
void p_donkcrit_30(entity this) { set_anim(this, 30, p_donkcrit_31); snt(this, 0.025); }
void p_donkcrit_29(entity this) { set_anim(this, 29, p_donkcrit_30); snt(this, 0.025); }
void p_donkcrit_28(entity this) { set_anim(this, 28, p_donkcrit_29); snt(this, 0.025); }
void p_donkcrit_27(entity this) { set_anim(this, 27, p_donkcrit_28); snt(this, 0.025); }
void p_donkcrit_26(entity this) { set_anim(this, 26, p_donkcrit_27); snt(this, 0.025); }
void p_donkcrit_25(entity this) { set_anim(this, 25, p_donkcrit_26); snt(this, 0.025); }

void DonkExplodeCrit(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "pirate/double_donk.wav", 1, ATTN_NORM);
	
	T_RadiusDamage(this, this.realowner, 140, WEP_LOOSECANNON.m_id, this.enemy);

	te_explosion(this.origin);
	
	_setmodel(this, "progs/s_donk.spr");
	setsize(this, '0 0 0', '0 0 0');
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	this.solid = SOLID_NOT;
	s_donk1(this);
}

//=============================================================================================

void DonkTouchCrit(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(toucher.takedamage == DAMAGE_AIM)
	{
		float damage = 80;
		damage *= 2; // double donkers!
		spawn_touchblood(this, damage, toucher);
		this.enemy = toucher;
		T_Damage(toucher, this, this.realowner, damage, WEP_LOOSECANNON.m_id);

		setthink(this, DonkExplodeCrit);
		this.nextthink = time;
		settouch(this, func_null);
		return;
	}
	else if(toucher.takedamage != DAMAGE_AIM)	// this prevents DOUBLE DONK when ball hits the world before enemy
	{
		_setmodel(this, "progs/donk_ball.mdl");
		setsize(this, '0 0 0', '0 0 0');
		DonkTouchDud(this, toucher);
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';	
}
////////////////////////////////////////////////////////////////////////////////////////////////

void DonkExplodeDud(entity this)
{
	T_RadiusDamage(this, this.realowner, 80, WEP_LOOSECANNON.m_id, this.enemy);

	te_explosion(this.origin);

	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	
	this.velocity = '0 0 0';
	settouch(this, func_null);
	set_movetype(this, MOVETYPE_NONE);
	_setmodel(this, "progs/s_explo2.spr");
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

//=============================================================================================

void DonkTouchDud(entity this, entity toucher)
{
	if(toucher == this.owner )
		return;
	if(toucher.takedamage == DAMAGE_AIM)
	{
		this.velocity = '0 0 0';	//'0 0 0' stops bomb dead and falls to enemy feet
		this.enemy = toucher;
		spawn_touchblood(this, 20, toucher);
		T_Damage(toucher, this, this.realowner, 20, WEP_LOOSECANNON.m_id);
		setthink(this, DonkExplodeDud);
		this.nextthink = time;
		settouch(this, func_null);
		return;
	}
		// play animation regardless if enemy or world
		// this prevents DOUBLE DONK when ball hits the world before enemy
#if 0
		if(this.frame ==  1)	{p_donkdud__1(this); }
		else if(this.frame ==  2)	{p_donkdud__2(this); }
		else if(this.frame ==  3)	{p_donkdud__3(this); }
		else if(this.frame ==  4)	{p_donkdud__4(this); }
		else if(this.frame ==  5)	{p_donkdud__5(this); }
		else if(this.frame ==  6)	{p_donkdud__6(this); }
		else if(this.frame ==  7)	{p_donkdud__7(this); }
		else if(this.frame ==  8)	{p_donkdud__8(this); }
		else if(this.frame ==  9)	{p_donkdud__9(this); }
		else if(this.frame == 10)	{p_donkdud_10(this); }
		else if(this.frame == 11)	{p_donkdud_11(this); }
		else if(this.frame == 12)	{p_donkdud_12(this); }
		else if(this.frame == 13)	{p_donkdud_13(this); }
		else if(this.frame == 14)	{p_donkdud_14(this); }
		else if(this.frame == 15)	{p_donkdud_15(this); }
		else if(this.frame == 16)	{p_donkdud_16(this); }
		else if(this.frame == 17)	{p_donkdud_17(this); }
		else if(this.frame == 18)	{p_donkdud_18(this); }
		else if(this.frame == 19)	{p_donkdud_19(this); }
		else if(this.frame == 20)	{p_donkdud_20(this); }

		else if(this.frame == 21)	{p_donkdud_21(this); }
		else if(this.frame == 22)	{p_donkdud_22(this); }
		else if(this.frame == 23)	{p_donkdud_23(this); }
		else if(this.frame == 24)	{p_donkdud_24(this); }
		else if(this.frame == 25)	{p_donkdud_25(this); }
		else if(this.frame == 26)	{p_donkdud_26(this); }
		else if(this.frame == 27)	{p_donkdud_27(this); }
		else if(this.frame == 28)	{p_donkdud_28(this); }
		else if(this.frame == 29)	{p_donkdud_29(this); }
		else if(this.frame == 30)	{p_donkdud_30(this); }
		else if(this.frame == 31)	{p_donkdud_31(this); }
		else if(this.frame == 32)	{p_donkdud_32(this); }
		else if(this.frame == 33)	{p_donkdud_33(this); }
		else if(this.frame == 34)	{p_donkdud_34(this); }
		else if(this.frame == 35)	{p_donkdud_35(this); }
		else if(this.frame == 36)	{p_donkdud_36(this); }
		else if(this.frame == 37)	{p_donkdud_37(this); }
		else if(this.frame == 38)	{p_donkdud_38(this); }
		else if(this.frame == 39)	{p_donkdud_39(this); }
		else if(this.frame == 40)	{p_donkdud_40(this); }	//DonkExplodeDud();
#endif

	_sound(this, CH_WEAPON_SINGLE, "weapons/bounce.wav", 1, ATTN_NORM);
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

entity Launch_Donk(entity this, vector org, vector vel)
{
	entity grenade = launch_spike(this, org, vel);
	grenade.velocity = vel;
	set_movetype(grenade, MOVETYPE_BOUNCE);
	grenade.projectiledeathtype = WEP_LOOSECANNON.m_id;
	grenade.avelocity = '300 300 300';
	_setmodel(grenade, "progs/donk_ball.mdl");
	setsize(grenade, '0 0 0', '0 0 0');
	settouch(grenade, func_null);
	setthink(grenade, SUB_Remove);
	grenade.nextthink = time;
	
	return grenade;
}

void W_FireLooseCannon(entity actor, int fuse_time, .entity weaponentity)
{
	if(actor.ammo_rockets < 1)
	{
		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;
		W_SwitchWeapon(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		return;
	}

	W_TakeAmmo(actor, ammo_rockets, 1);

	if(IS_PLAYER(actor))
		player_shot1(actor);

	_sound(actor, CH_WEAPON_B, "weapons/grenade.wav", 1, ATTN_NORM);
	_sound(actor, CH_WEAPON_SINGLE, "pirate/loose_cannon_fire.wav", 1, ATTN_NORM);
	actor.punchangle_x = -2;

	// set grenade speed	
	makevectors(actor.v_angle);
	
	float base = 200;
	float baseforward = base * max(1, (fuse_time / 40) * 3);
	vector gvel;
	if(actor.v_angle_x) 
		gvel = v_forward * baseforward * 3 + v_up * base + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		gvel = qc_aim(actor, 2048);
		gvel = gvel * baseforward * 3;
		gvel.z = base;
	}
	
	entity g = Launch_Donk(actor, W_Shotorg(actor, weaponentity), gvel);

#if 0
	if(fuse_time ==  1) { setthink(g, p_donk__1); }
	else if(fuse_time ==  2) { setthink(g, p_donk__2); }
	else if(fuse_time ==  3) { setthink(g, p_donk__3); }
	else if(fuse_time ==  4) { setthink(g, p_donk__4); }
	else if(fuse_time ==  5) { setthink(g, p_donk__5); }
	else if(fuse_time ==  6) { setthink(g, p_donk__6); }
	else if(fuse_time ==  7) { setthink(g, p_donk__7); }
	else if(fuse_time ==  8) { setthink(g, p_donk__8); }
	else if(fuse_time ==  9) { setthink(g, p_donk__9); }
	else if(fuse_time == 10) { setthink(g, p_donk_10); }
	else if(fuse_time == 11) { setthink(g, p_donk_11); }
	else if(fuse_time == 12) { setthink(g, p_donk_12); }
	else if(fuse_time == 13) { setthink(g, p_donk_13); }
	else if(fuse_time == 14) { setthink(g, p_donk_14); }
	else if(fuse_time == 15) { setthink(g, p_donk_15); }
	else if(fuse_time == 16) { setthink(g, p_donk_16); }
	else if(fuse_time == 17) { setthink(g, p_donk_17); }
	else if(fuse_time == 18) { setthink(g, p_donk_18); }
	else if(fuse_time == 19) { setthink(g, p_donk_19); }
	else if(fuse_time == 20) { setthink(g, p_donk_20); }
			
	else if(fuse_time == 21) { setthink(g, p_donk_21); }
	else if(fuse_time == 22) { setthink(g, p_donk_22); }
	else if(fuse_time == 23) { setthink(g, p_donk_23); }
	else if(fuse_time == 24) { setthink(g, p_donk_24); }
	
	else if(fuse_time == 25) { setthink(g, p_donk_25); }
	else if(fuse_time == 26) { setthink(g, p_donk_26); }
	else if(fuse_time == 27) { setthink(g, p_donk_27); }
	else if(fuse_time == 28) { setthink(g, p_donk_28); }
	else if(fuse_time == 29) { setthink(g, p_donk_29); }
	else if(fuse_time == 30) { setthink(g, p_donk_30); }
	else if(fuse_time == 31) { setthink(g, p_donk_31); }
	else if(fuse_time == 32) { setthink(g, p_donk_32); }
	else if(fuse_time == 33) { setthink(g, p_donk_33); }
	else if(fuse_time == 34) { setthink(g, p_donk_34); }
	else if(fuse_time == 35) { setthink(g, p_donk_35); }
	else if(fuse_time == 36) { setthink(g, p_donk_36); }
	else if(fuse_time == 37) { setthink(g, p_donk_37); }
	else if(fuse_time == 38) { setthink(g, p_donk_38); }
	else if(fuse_time == 39) { setthink(g, p_donk_39); }
	else if(fuse_time == 40) { setthink(g, p_donk_40); }	//DonkExplodeDud();
#else
	if(fuse_time == 40)
		setthink(g, DonkExplodeDud);
	else if(fuse_time >= 25)
		setthink(g, p_donk_25);
	else
		setthink(g, p_donk__1);
#endif
}

METHOD(LooseCannon, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		p_loose__1(actor.(weaponentity));
		_sound(actor, CH_WEAPON_SINGLE, "pirate/loose_cannon_charge.wav", 1, ATTN_NORM);
	}
}
METHOD(LooseCannon, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(LooseCannon, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(LooseCannon, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

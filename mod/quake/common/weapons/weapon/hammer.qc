#include "hammer.qh"

#ifdef SVQC
PRECACHE(Hammer)
{
	precache_sound("weapons/axhit1.wav");
	precache_sound("weapons/axhit2.wav");

	precache_model("progs/spark_red.mdl");
	precache_model("progs/spark_blue.mdl");
	precache_model("progs/spark_yellow.mdl");
	precache_model("progs/s_blood_64x.spr");
	precache_model("progs/s_blood_96x.spr");
	precache_model("progs/s_blood_128x.spr");
	
	precache_model("progs/v_hammer_default.mdl");
	precache_model("progs/g_hammer_default.mdl");
	precache_model("progs/v_hammer_mace.mdl");
	precache_model("progs/g_hammer_mace.mdl");
	precache_model("progs/v_hammer_jester_mallet.mdl");
	precache_model("progs/g_hammer_jester_mallet.mdl");
	precache_model("progs/v_hammer_alkaline_axe.mdl");
	precache_model("progs/g_hammer_alkaline_axe.mdl");
	precache_model("progs/v_hammer_baseball.mdl");
	precache_model("progs/g_hammer_baseball.mdl");
	precache_model("progs/v_hammer_blocky_axe.mdl");
	precache_model("progs/g_hammer_blocky_axe.mdl");
	precache_model("progs/v_hammer_default_bloody.mdl");
	precache_model("progs/g_hammer_default_bloody.mdl");
	precache_model("progs/v_hammer_dwarven.mdl");
	precache_model("progs/g_hammer_dwarven.mdl");
	precache_model("progs/v_hammer_guitar.mdl");
	precache_model("progs/g_hammer_guitar.mdl");
	precache_model("progs/v_hammer_moving_past_it.mdl");
	precache_model("progs/g_hammer_moving_past_it.mdl");
	precache_model("progs/v_hammer_copper_axe.mdl");
	precache_model("progs/g_hammer_copper_axe.mdl");
	precache_model("progs/v_hammer_error.mdl");
	precache_model("progs/g_hammer_error.mdl");
	precache_model("progs/v_hammer_mailbox.mdl");
	precache_model("progs/v_hammer_heavy_rocket.mdl");
	precache_model("progs/v_hammer_brown_brick.mdl");
	precache_model("progs/v_hammer_burger.mdl");
	precache_model("progs/v_hammer_buster_sword.mdl");
	precache_model("progs/v_hammer_pickaxe.mdl");
	precache_model("progs/v_hammer_sailor_sceptre.mdl");
	precache_model("progs/v_hammer_floyd.mdl");
	precache_model("progs/v_hammer_default_gold.mdl");
	precache_model("progs/v_hammer_default_gold_bloody.mdl");
	precache_model("progs/g_hammer_mailbox.mdl");
	precache_model("progs/g_hammer_heavy_rocket.mdl");
	precache_model("progs/g_hammer_brown_brick.mdl");
	precache_model("progs/g_hammer_burger.mdl");
	precache_model("progs/g_hammer_buster_sword.mdl");
	precache_model("progs/g_hammer_pickaxe.mdl");
	precache_model("progs/g_hammer_sailor_sceptre.mdl");
	precache_model("progs/g_hammer_floyd.mdl");
	precache_model("progs/g_hammer_default_gold.mdl");
	precache_model("progs/g_hammer_default_gold_bloody.mdl");
	
//	precache_model("progs/v_hammer_error.mdl");
//	precache_model("progs/g_hammer_error.mdl");
	precache_model("progs/v_hammer_katana.mdl");
	precache_model("progs/g_hammer_katana.mdl");
	precache_model("progs/v_hammer_kebby_gears.mdl");
	precache_model("progs/g_hammer_kebby_gears.mdl");
	precache_model("progs/v_hammer_pirate_skull.mdl");
	precache_model("progs/g_hammer_pirate_skull.mdl");
	precache_model("progs/v_hammer_sblade.mdl");
	precache_model("progs/g_hammer_sblade.mdl");
	precache_model("progs/v_hammer_sentinel.mdl");
	precache_model("progs/g_hammer_sentinel.mdl");
	precache_model("progs/v_hammer_squeaky.mdl");
	precache_model("progs/g_hammer_squeaky.mdl");
	precache_model("progs/v_hammer_stop_sign.mdl");
	precache_model("progs/g_hammer_stop_sign.mdl");
	precache_model("progs/kanji.mdl");
	
	
	precache_sound("hammer/hammer_clang.wav");
	precache_sound("hammer/hammer_clang2.wav");
	precache_sound("hammer/frying_pan.wav");
	precache_sound("hammer/slice1.wav");
	precache_sound("hammer/slice2.wav");
	precache_sound("hammer/slice3.wav");
	precache_sound("hammer/slice_hit1.wav");
	precache_sound("hammer/slice_hit2.wav");
	precache_sound("hammer/slice_hit3.wav");
	precache_sound("hammer/charge_full.wav");
	precache_sound("hammer/charge_med.wav");
	precache_sound("hammer/guitar_a.wav");
	precache_sound("hammer/guitar_b.wav");
	precache_sound("hammer/guitar_d.wav");
	precache_sound("hammer/guitar_e.wav");

	precache_sound("hammer/hammer_clang_guitar.wav");
	precache_sound("hammer/hammer_clang2_guitar.wav");
	precache_sound("hammer/axhit1_guitar.wav");
	precache_sound("hammer/axhit2_guitar.wav");
	precache_sound("hammer/charge_full_guitar.wav");
	precache_sound("hammer/charge_med_guitar.wav");
	precache_sound("hammer/katana_secret.wav");

	precache_sound("hammer/axhit1_error.wav");
	precache_sound("hammer/axhit2_error.wav");
	precache_sound("hammer/hammer_clang2_error.wav");
	precache_sound("hammer/hammer_clang_error.wav");
	precache_sound("hammer/charge_med_error.wav");
	precache_sound("hammer/charge_full_error.wav");

	precache_sound("hammer/axhit1_floyd.wav");
	precache_sound("hammer/hammer_clang2_floyd.wav");
	precache_sound("hammer/hammer_clang_floyd.wav");
	precache_sound("hammer/charge_med_floyd.wav");
	precache_sound("hammer/charge_full_floyd.wav");

	precache_sound("hammer/charge_med_sceptre.wav");
	precache_sound("hammer/charge_full_sceptre.wav");

	precache_sound("hammer/axhit1_ff7.wav");
	precache_sound("hammer/ff7_kill.wav");
	precache_sound("hammer/hammer_clang2_ff7.wav");
	precache_sound("hammer/hammer_clang_ff7.wav");
	precache_sound("hammer/charge_med_ff7.wav");
	precache_sound("hammer/charge_full_ff7.wav");

	precache_sound("hammer/charge_full_katana.wav");
	precache_sound("hammer/charge_med_katana.wav");
	precache_sound("hammer/charge_full_katana.wav");
	precache_sound("hammer/charge_med_katana.wav");
	precache_sound("hammer/katana_kill1.wav");
	precache_sound("hammer/katana_kill2.wav");
	precache_sound("hammer/axhit1_katana.wav");
	precache_sound("hammer/axhit2_katana.wav");
	precache_sound("hammer/hammer_clang_katana.wav");
	precache_sound("hammer/hammer_clang2_katana.wav");

	precache_sound("hammer/axhit1_squeaky.wav");
	precache_sound("hammer/axhit2_squeaky.wav");
	precache_sound("hammer/squeaky_kill.wav");
	precache_sound("hammer/charge_med_squeaky.wav");
	precache_sound("hammer/charge_full_squeaky.wav");
	precache_sound("hammer/hammer_clang_squeaky.wav");
	precache_sound("hammer/hammer_clang2_squeaky.wav");
}

void player_hammer6(entity this) { set_anim(this, anim_player_axatt1 + 2, player_run); }
void player_hammer5(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer6); }
void player_hammer4(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer5); }
void player_hammer3(entity this) { set_anim(this, anim_player_axatt1 + 2, player_hammer4); }
void player_hammer2(entity this) { set_anim(this, anim_player_axatt1 + 1, player_hammer3); }
void player_hammer1(entity this) { set_anim(this, anim_player_axatt1 + 3, player_hammer2); }

void swf(entity this, int float_frame) { this.m_frame = float_frame; }
void swf1(entity this) { this.m_frame += 1; }
void saf(entity this, float float_finish)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	ATTACK_FINISHED(actor, weaponentity) = time + float_finish + PHYS_INPUT_TIMELENGTH;
}
void snt(entity this, float float_think) { this.weapon_nextthink = time + float_think; }
void st(entity this, void(entity) goto_think) { this.weapon_think = goto_think; }
void interrupt(entity this, void(entity) hotswap_release_skip, float saf_time)
{
	if(!this.owner.button0)
	{
		hotswap_release_skip(this);
		saf(this, saf_time);
	}
}
void self1(entity this) { if(IS_PLAYER(this.owner)) player_hammer1(this.owner); }
void muzzleflash(entity this) { this.owner.effects |= EF_MUZZLEFLASH; }

void Hammer_Whiff_Sound(entity this) { _sound(this.owner, CH_WEAPON_B, "weapons/ax1.wav", 1, ATTN_NORM); }

void Hammer_Dash_Sound(entity this, int charge_multi)
{
	entity actor = this.owner;
	if(charge_multi == hammer_charge_LOW) _sound(actor, CH_WEAPON_B, "hammer/slice1.wav", 0.25, ATTN_NORM);	//  LOW
	else if(charge_multi == hammer_charge_MED) _sound(actor, CH_WEAPON_B, "hammer/slice2.wav", 0.5, ATTN_NORM);	//  MED
	else _sound(actor, CH_WEAPON_B, "hammer/slice3.wav", 1, ATTN_NORM);	//  HIGH
}

void Hammer_Hit_Enemy_Sound(entity this)
{
	entity actor = this.owner;
	SuperDamageSound(actor);

	if(this.hammer_skin == SKIN_GUITAR)
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_guitar.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_guitar.wav", 1, ATTN_NORM);
	}
	if(this.hammer_skin == SKIN_BUSTER)
	{
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_ff7.wav", 1, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_KATANA)
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_katana.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_katana.wav", 1, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_FLOYD)
	{
		_sound(actor, CH_WEAPON_B, "hammer/axhit1_floyd.wav", 1, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_ERROR)
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_error.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_error.wav", 1, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_SQUEAKY)
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_squeaky.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_squeaky.wav", 1, ATTN_NORM);
	else
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "weapons/axhit1.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "weapons/axhit2.wav", 1, ATTN_NORM);
	}
}

void Katana_Kill_Sound(entity this, float v);
void Play_Guitar_Chord(entity this);
void Hammer_Kill_Enemy_Sound(entity this, int charge_multi)
{
	entity actor = this.owner;

	if(this.hammer_skin == SKIN_GUITAR)
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_guitar.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_guitar.wav", 1, ATTN_NORM);

		if(charge_multi == hammer_charge_LOW)
		{
			Play_Guitar_Chord(this);
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_guitar.wav", 0.25, ATTN_NORM);	//  LOW
		}			
		else if(charge_multi == hammer_charge_MED)
		{
			Play_Guitar_Chord(this);
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_guitar.wav", 0.5, ATTN_NORM);	//  MED
		}
		else
		{
			Play_Guitar_Chord(this);
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_guitar.wav", 1, ATTN_NORM);		//  HIGH
		}
	}
	else if(this.hammer_skin == SKIN_KATANA)
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "hammer/axhit1_katana.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/axhit2_katana.wav", 1, ATTN_NORM);

		if(charge_multi == hammer_charge_LOW)
			Katana_Kill_Sound(this, 0.15);
		else if(charge_multi == hammer_charge_MED)
			Katana_Kill_Sound(this, 0.50);
		else
			Katana_Kill_Sound(this, 0.85);
	}
	else if(this.hammer_skin == SKIN_FLOYD)
	{
		_sound(actor, CH_WEAPON_B, "hammer/axhit1_floyd.wav", 1, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_SQUEAKY)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/squeaky_kill.wav", 0.25, ATTN_NORM);
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/squeaky_kill.wav", 0.3, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "hammer/squeaky_kill.wav", 0.9, ATTN_NORM);
	}
	else if(this.hammer_skin == SKIN_BUSTER)
		_sound(actor, CH_WEAPON_B, "hammer/ff7_kill.wav", 1, ATTN_NORM);
	else if(this.hammer_skin == SKIN_ERROR)
		return;
	else
	{
		if(random() < 0.5)
			_sound(actor, CH_WEAPON_B, "weapons/axhit1.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_WEAPON_B, "weapons/axhit2.wav", 1, ATTN_NORM);

		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/frying_pan.wav", 0.25, ATTN_NORM);	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/frying_pan.wav", 0.5, ATTN_NORM);	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/frying_pan.wav", 1, ATTN_NORM);		//  HIGH
	}
}

void Katana_Kill_Sound(entity this, float v)
{
	entity actor = this.owner;
	if(random() < .5)
		_sound(actor, CH_WEAPON_B, "hammer/katana_kill1.wav", v, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_B, "hammer/katana_kill2.wav", v, ATTN_NORM);
}

void kanji_th(entity this);
void katana_kanji(entity this, entity whatmon) //knock a dang kanji out of big dudes
{
	if(this.hammer_skin != SKIN_KATANA)
		return;
	if(!(whatmon.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
		return;

	entity actor = this.owner;

	entity kanji = spawn();
	kanji.classname = "kanji";
	_setmodel(kanji, "progs/kanji.mdl");

	kanji.alpha = 0.6;

	setthink(kanji, kanji_th);
	kanji.nextthink = time + 0.05;

	_sound(actor, CH_WEAPON_B, "hammer/katana_secret.wav", 1, ATTN_NORM);

	setsize(kanji, '0 0 0', '0 0 0');

	setorigin(kanji, whatmon.origin + '0 0 40');
	makevectors(actor.angles);
	kanji.realowner = actor;
	kanji.enemy = whatmon;

	set_movetype(kanji, MOVETYPE_NOCLIP);
	kanji.solid = SOLID_NOT;

	kanji.angles = vectoangles(v_forward * -1);
}

void kanji_th(entity this)
{
	if((this.alpha <= 1) && (this.wait < 1))
	{
		this.alpha = this.alpha + 0.05;
		this.wait = this.wait + 0.05;
	}
	else
	{
		this.alpha = this.alpha - 0.05;
	}

	if(this.alpha > 1.1) //stay at 100% alpha for a sec before going down
		this.wait = 1;

	if(this.alpha <= 0 || this.enemy.health <= 0)
	{
		delete(this);
		return;
	}

	makevectors(this.realowner.angles);
	this.angles = vectoangles(v_forward * -1);
	this.velocity = v_forward * 150;
	this.velocity_z = 15; 

	this.frame++;

	this.nextthink = time + .02;
}

void Play_Guitar_Chord(entity this)
{
	entity actor = this.owner;
	float r = random();
	if((r < 0.25) && (this.lastnote != 1))
	{
		this.lastnote = 1;
		_sound(actor, CH_WEAPON_B, "hammer/guitar_a.wav", .9, ATTN_NORM);
	}
	else if((r < 0.5) && (this.lastnote != 2))
	{
		this.lastnote = 2;
		_sound(actor, CH_WEAPON_B, "hammer/guitar_b.wav", .9, ATTN_NORM);
	}
	else if((r < 0.75) && (this.lastnote != 3))
	{
		this.lastnote = 3;
		_sound(actor, CH_WEAPON_B, "hammer/guitar_d.wav", .9, ATTN_NORM);
	}
	else if((r < 0.75) && (this.lastnote != 4))
	{
		this.lastnote = 4;
		_sound(actor, CH_WEAPON_B, "hammer/guitar_e.wav", .9, ATTN_NORM);
	}
	else
		Play_Guitar_Chord(this);
}

void Hammer_Hit_World_Sound(entity this, int charge_multi)
{
	entity actor = this.owner;

	if(this.hammer_skin == SKIN_GUITAR)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_guitar.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_guitar.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_guitar.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_FLOYD)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_floyd.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_floyd.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_floyd.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_BUSTER)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_ff7.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_ff7.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_ff7.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_KATANA)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_katana.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_katana.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_katana.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_SQUEAKY)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_squeaky.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_squeaky.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_squeaky.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_ERROR)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_error.wav", 0.5, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2_error.wav", 0.8, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang_error.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2.wav", 0.3, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang2.wav", 0.6, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/hammer_clang.wav", 0.8, ATTN_NORM); 	//  HIGH
	}
}

void Hammer_Charging_Sound(entity this, int charge_multi)
{
	entity actor = this.owner;

	if(this.hammer_skin == SKIN_GUITAR)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_guitar.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_guitar.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_guitar.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_ERROR)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_error.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_error.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_error.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_FLOYD)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_floyd.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_floyd.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_floyd.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_SAILOR)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_sceptre.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_sceptre.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_sceptre.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_BUSTER)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_ff7.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_ff7.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_ff7.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_KATANA)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_katana.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_katana.wav", 0.6, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_katana.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else if(this.hammer_skin == SKIN_SQUEAKY)
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_squeaky.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med_squeaky.wav", 1, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full_squeaky.wav", 1, ATTN_NORM); 	//  HIGH
	}
	else
	{
		if(charge_multi == hammer_charge_LOW)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med.wav", 0, ATTN_NORM); 	//  LOW
		else if(charge_multi == hammer_charge_MED)
			_sound(actor, CH_WEAPON_B, "hammer/charge_med.wav", 0.4, ATTN_NORM); 	//  MED
		else
			_sound(actor, CH_WEAPON_B, "hammer/charge_full.wav", 0.8, ATTN_NORM); 	//  HIGH
	}	
}

void p_hammer_dash_low(entity this);
void p_hammer_dash_med(entity this);
void p_hammer_dash_high(entity this);
void p_hammer_whiff_low(entity this);
void p_hammer_whiff_med(entity this);
void p_hammer_whiff_high(entity this);
void p_hammer_kill_low(entity this);
void p_hammer_kill_med(entity this);
void p_hammer_kill_high(entity this);
void hithammer(entity this, entity hitent, vector org, vector dir, float charge_multi, float hitfloor);
void W_SwingHammer(entity this, int charge_multi)
{
	entity actor = this.owner;
	bool hitfloor = false;

	entity hitent1 = NULL, hitent2 = NULL;
	vector hitpos1 = '0 0 0', hitpos2 = '0 0 0';
	float shortest_hit1 = 1000;
	float shortest_hit2 = 1000;
	
	makevectors(actor.v_angle);
	vector source = actor.origin + actor.view_ofs - v_up*6;

	traceline(source, source + v_forward*64 - v_right*16, false, actor);
	if(trace_fraction < 1)
	{
		shortest_hit1 = vlen(trace_endpos - source);
		hitent1 = trace_ent;
		hitpos1 = trace_endpos;
 	}

	traceline(source, source + v_forward*96 - v_right*8, false, actor);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward*128, false, actor);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
		if((trace_fraction < 1) && (trace_plane_normal_z > 0.71))
		{
			hitfloor = 1;
		}
	}

	traceline(source, source + v_forward*96 + v_right*8, false, actor);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward*64 + v_right*16, false, actor);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	if(shortest_hit1 == 1000 && shortest_hit2 == 1000) // if don't hit anything, horizontal dash instead
	{
		if(!IS_ONGROUND(actor))
		{			
			if(charge_multi == hammer_charge_LOW)
			{
				p_hammer_dash_low(this);
				Hammer_Dash_Sound(this, hammer_charge_LOW);
			} //  LOW
			else if(charge_multi == hammer_charge_MED)
			{
				p_hammer_dash_med(this);
				Hammer_Dash_Sound(this, hammer_charge_MED);
			} //  MED 
			else
			{
				p_hammer_dash_high(this);
				Hammer_Dash_Sound(this, hammer_charge_HIGH);
			} //  HIGH
			
			actor.velocity = actor.velocity + v_forward * (charge_multi * hammer_dash_forward); //  LOW  MED  HIGH
			if(charge_multi > hammer_charge_LOW)
				actor.velocity_z = hammer_dash_upward;
			
			//actor.velocity_z = actor.velocity_z + v_forward *	(charge_multi * hammer_dash_upward); //(UNCAPPED vertical veloctiy)
		}
		else	// empty swing, whiff = no hit, no kill, no dash, no hop
		{
			if(charge_multi == hammer_charge_LOW)
				p_hammer_whiff_low(this);	//  LOW
			else if(charge_multi == hammer_charge_MED)
				p_hammer_whiff_med(this);	//  MED
			else
				p_hammer_whiff_high(this);	//  HIGH
		}		
		return;
	}

	actor.show_hostile = time + 1; // hit something, so alert monsters
	
	vector dir = v_right * 20 - v_up * 5; // direction for blood particles

	if(shortest_hit1 < 1000)
		hithammer(this, hitent1, hitpos1 - v_forward*4, dir, charge_multi, hitfloor);
	if(shortest_hit2 < 1000 && hitent1 != hitent2)
		hithammer(this, hitent2, hitpos2 - v_forward*4, dir, charge_multi, hitfloor);
}

void p_hammer_hit_low(entity this);
void p_hammer_hit_med(entity this);
void p_hammer_hit_high(entity this);
void p_hammer_hop_low(entity this);
void p_hammer_hop_med(entity this);
void p_hammer_hop_high(entity this);
void hithammer(entity this, entity hitent, vector org, vector dir, float charge_multi, float hitfloor)
{
	entity actor = this.owner;

	if(hitent.takedamage) // compare charge level with remaining enemy health to only overkill when they are 1 hit away from death (force gib)
	{
		if((charge_multi == hammer_charge_LOW) && (hitent.health <= hammer_damage_LOW) && IS_MONSTER(hitent))
		{
			katana_kanji(this, hitent);
			SpawnBlood(org, dir, (hammer_damage_LOW) * 2, hitent);
			T_Damage(hitent, actor, actor, (hammer_damage_LOW) * 2, WEP_HAMMER.m_id);			
			Hammer_Kill_Enemy_Sound(this, hammer_charge_LOW);
			p_hammer_kill_low(this);
		}
		else if	((charge_multi == hammer_charge_MED) && (hitent.health <= hammer_damage_MED) && IS_MONSTER(hitent))
		{
			katana_kanji(this, hitent);
			SpawnBlood(org, dir, (hammer_damage_MED) * 2, hitent);
			T_Damage(hitent, actor, actor, (hammer_damage_MED) * 2, WEP_HAMMER.m_id);			
			Hammer_Kill_Enemy_Sound(this, hammer_charge_MED);
			p_hammer_kill_med(this);
		}	
		else if	((charge_multi == hammer_charge_HIGH) && (hitent.health <= hammer_damage_HIGH) && IS_MONSTER(hitent))
		{
			katana_kanji(this, hitent);
			SpawnBlood(org, dir, (hammer_damage_HIGH) * 2, hitent);
			T_Damage(hitent, actor, actor, (hammer_damage_HIGH) * 2, WEP_HAMMER.m_id);			
			Hammer_Kill_Enemy_Sound(this, hammer_charge_HIGH);
			p_hammer_kill_high(this);
		}	
		
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				
		if(StatusEffects_active(STATUSEFFECT_Quad, actor)) // do big knockback with a quad
		{
			if((hitent.move_movetype == MOVETYPE_STEP || hitent.move_movetype == MOVETYPE_WALK) && 
				hitent.maxs_x <= 32 && hitent.health > 0 && !(hitent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
				// don't swat bosses
			{
				vector toss = v_forward;
				toss.z = 0;

				toss = normalize(toss) * (charge_multi * hammer_knockback_quad);
				toss.z = 		 (charge_multi * hammer_knockback_quad_up);
								
				hitent.origin_z = hitent.origin_z + 1;
				hitent.velocity = toss;
				UNSET_ONGROUND(hitent);
			}
		}		
		else // still do knockback but less strong
		{
			if((hitent.move_movetype == MOVETYPE_STEP || hitent.move_movetype == MOVETYPE_WALK) && 
				hitent.maxs_x <= 32 && hitent.health > 0 && !(hitent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
			{
				vector toss = v_forward;
				toss.z = 0;
				
				toss = normalize(toss) * (charge_multi * hammer_knockback);
				toss.z = 		 (charge_multi * hammer_knockback_up);
				
				hitent.origin_z = hitent.origin_z + 1;
				hitent.velocity = toss;
				UNSET_ONGROUND(hitent);
			}
		}
		
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			
		if(charge_multi == hammer_charge_LOW)
		{
			SpawnBlood(org, dir, hammer_damage_LOW, hitent);
			T_Damage(hitent, actor, actor, hammer_damage_LOW, WEP_HAMMER.m_id);			
			p_hammer_hit_low(this);
		}
		else if(charge_multi == hammer_charge_MED)
		{
			SpawnBlood(org, dir, hammer_damage_MED, hitent);
			T_Damage(hitent, actor, actor, hammer_damage_MED, WEP_HAMMER.m_id);			
			p_hammer_hit_med(this);
		}
		else
		{
			SpawnBlood(org, dir, hammer_damage_HIGH, hitent);
			T_Damage(hitent, actor, actor, hammer_damage_HIGH, WEP_HAMMER.m_id);
			p_hammer_hit_high(this);
		}
		
		Hammer_Hit_Enemy_Sound(this);
		return;
	}
	else // hit world = hammer hop
	{
		dir = v_forward;
		float desired_height;

		if(charge_multi == hammer_charge_LOW)
		{
			desired_height = hammer_hop_upward_LOW;
			Hammer_Hit_World_Sound(this, hammer_charge_LOW);
			p_hammer_hop_low(this);
		}
		else if(charge_multi == hammer_charge_MED)
		{
			//T_GibDownedZombies(actor.origin, 200);
			desired_height = hammer_hop_upward_MED;
			Hammer_Hit_World_Sound(this, hammer_charge_MED);
			p_hammer_hop_med(this);
		}
		else
		{	
			//T_GibDownedZombies(actor.origin, 200);
			desired_height = hammer_hop_upward_HIGH;
			Hammer_Hit_World_Sound(this, hammer_charge_HIGH);
			p_hammer_hop_high(this);
		}

		traceline(actor.origin - '0 0 24', actor.origin - '0 0 88', MOVE_NOMONSTERS, actor);
		
		actor.velocity = actor.velocity + (dir * (charge_multi * hammer_hop_backward)); //add sideways velocity
		if((trace_fraction < 1) && (hitfloor == 1)) //check if player is looking at the floor
			actor.velocity_z = sqrt(2 * ((desired_height + 32) - (trace_fraction * 64)) * 800); //add upward velocity
		UNSET_ONGROUND(actor);

		te_gunshot(org);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Animation chains for 1st person BONK Hammer
////////////////////////////////////////////////////////////////////////////////////////////////
/*
	    0	 idle
	  1-14	 charge LOW
	 15-27	 charge MED
	 28-29	 charge HIGH
	 30-39	 loop HIGH
	
	    40	 release HIGH
	 41-49	 hit HIGH
	 50-58	 kill HIGH
	 59-67	 dash HIGH
	 68-76	 hop HIGH
	
	    77	 release MED
	 78-86	 hit MED
	 87-95	 kill MED
	 96-104	 dash MED
	105-113	 hop MED
	
	    114	 release LOW
	115-123	 hit LOW
	124-132	 kill LOW
	133-141	 dash LOW
	142-150	 hop LOW
	
	151-158	 cooldown > idle
	
	159-167	 whiff HIGH
	168-176	 whiff MED
	177-185	 whiff LOW
	
	186-201  spinny (spammable)
	202-254  pickup/inspect
*/
////////////////////////////////////////////////////////////////////////////////////////////////
// Animation chains for 3rd person BONK Player
////////////////////////////////////////////////////////////////////////////////////////////////
/*
	    0	 axrun
	  6-11	 rockrun
	 12-16	 stand
	 17-28	 axstand
	 29-34	 axpain
	 35-40   pain
	 
	 41-49   axdeth
	 50-60   deatha
	 61-69   deathb
	 70-84   deathc
	 85-93   deathd
	 94-102  deathe
	 
	103,104  nailatt
	105,106  light
	107-112  rockatt
	113-118  shotatt
	
	119-132  charge LOW
	133-145  charge MED
	146,147  charge HIGH
	148-157  loop HIGH
	
	158-167  release HIGH
	168-177  release MED
	178-187  release LOW
	
	188-195  cooldown > idle
	
	196-211  spinny (spammable)
	212-254  pickup/inspect
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	  1-14	 charge LOW
void p_hammer_release_low(entity this);
void p_hammer_charge_med_01(entity this);
void p_hammer_charge_low_14(entity this) { wep_set_anim(this, 132, p_hammer_charge_med_01); swf(this, 14); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_13(entity this) { wep_set_anim(this, 131, p_hammer_charge_low_14); swf(this, 13); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_12(entity this) { wep_set_anim(this, 130, p_hammer_charge_low_13); swf(this, 12); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_11(entity this) { wep_set_anim(this, 129, p_hammer_charge_low_12); swf(this, 11); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_10(entity this) { wep_set_anim(this, 128, p_hammer_charge_low_11); swf(this, 10); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_09(entity this) { wep_set_anim(this, 127, p_hammer_charge_low_10); swf(this,  9); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_08(entity this) { wep_set_anim(this, 126, p_hammer_charge_low_09); swf(this,  8); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_07(entity this) { wep_set_anim(this, 125, p_hammer_charge_low_08); swf(this,  7); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_06(entity this) { wep_set_anim(this, 124, p_hammer_charge_low_07); swf(this,  6); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_05(entity this) { wep_set_anim(this, 123, p_hammer_charge_low_06); swf(this,  5); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_04(entity this) { wep_set_anim(this, 122, p_hammer_charge_low_05); swf(this,  4); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_03(entity this) { wep_set_anim(this, 121, p_hammer_charge_low_04); swf(this,  3); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_02(entity this) { wep_set_anim(this, 120, p_hammer_charge_low_03); swf(this,  2); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); }
void p_hammer_charge_low_01(entity this) { wep_set_anim(this, 119, p_hammer_charge_low_02); swf(this,  1); snt(this, 0.05); interrupt(this, p_hammer_release_low, 0.1); saf(this, 0.05); Hammer_Charging_Sound(this, hammer_charge_LOW); }

//=============================================================================================
//	 15-27	 charge MED
void p_hammer_release_med(entity this);
void p_hammer_charge_high_01(entity this);
void p_hammer_charge_med_13(entity this) { wep_set_anim(this, 145, p_hammer_charge_high_01); swf(this, 27); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_12(entity this) { wep_set_anim(this, 144, p_hammer_charge_med_13); swf(this, 26); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_11(entity this) { wep_set_anim(this, 143, p_hammer_charge_med_12); swf(this, 25); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_10(entity this) { wep_set_anim(this, 142, p_hammer_charge_med_11); swf(this, 24); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_09(entity this) { wep_set_anim(this, 141, p_hammer_charge_med_10); swf(this, 23); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_08(entity this) { wep_set_anim(this, 140, p_hammer_charge_med_09); swf(this, 22); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_07(entity this) { wep_set_anim(this, 139, p_hammer_charge_med_08); swf(this, 21); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_06(entity this) { wep_set_anim(this, 138, p_hammer_charge_med_07); swf(this, 20); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_05(entity this) { wep_set_anim(this, 137, p_hammer_charge_med_06); swf(this, 19); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_04(entity this) { wep_set_anim(this, 136, p_hammer_charge_med_05); swf(this, 18); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_03(entity this) { wep_set_anim(this, 135, p_hammer_charge_med_04); swf(this, 17); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_02(entity this) { wep_set_anim(this, 134, p_hammer_charge_med_03); swf(this, 16); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); }
void p_hammer_charge_med_01(entity this) { wep_set_anim(this, 133, p_hammer_charge_med_02); swf(this, 15); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_med, 0.1); Hammer_Charging_Sound(this, hammer_charge_MED); }
                                     
//=============================================================================================
//	 28-29	 charge HIGH
void p_hammer_release_high(entity this);
void p_hammer_charge_loop_01(entity this);
void p_hammer_charge_high_02(entity this) { wep_set_anim(this, 147, p_hammer_charge_loop_01); swf(this, 29); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_high_01(entity this) { wep_set_anim(this, 146, p_hammer_charge_high_02); swf(this, 28); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); Hammer_Charging_Sound(this, hammer_charge_HIGH); }

//	 30-39	 loop HIGH
void p_hammer_charge_loop_10(entity this) { wep_set_anim(this, 157, p_hammer_charge_loop_01); swf(this, 39); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_09(entity this) { wep_set_anim(this, 156, p_hammer_charge_loop_10); swf(this, 38); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_08(entity this) { wep_set_anim(this, 155, p_hammer_charge_loop_09); swf(this, 37); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_07(entity this) { wep_set_anim(this, 154, p_hammer_charge_loop_08); swf(this, 36); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_06(entity this) { wep_set_anim(this, 153, p_hammer_charge_loop_07); swf(this, 35); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_05(entity this) { wep_set_anim(this, 152, p_hammer_charge_loop_06); swf(this, 34); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_04(entity this) { wep_set_anim(this, 151, p_hammer_charge_loop_05); swf(this, 33); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_03(entity this) { wep_set_anim(this, 150, p_hammer_charge_loop_04); swf(this, 32); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_02(entity this) { wep_set_anim(this, 149, p_hammer_charge_loop_03); swf(this, 31); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }
void p_hammer_charge_loop_01(entity this) { wep_set_anim(this, 148, p_hammer_charge_loop_02); swf(this, 30); snt(this, 0.05); saf(this, 0.05); interrupt(this, p_hammer_release_high, 0.1); }

//=============================================================================================//=============================================================================================
//	    114	 release LOW
void p_hammer_hit_low(entity this);
void p_hammer_tracer_low(entity this);
void p_hammer_autoanim_01(entity this);
void p_hammer_release_low(entity this) { wep_set_anim(this, 178, p_hammer_tracer_low); swf(this, 114); snt(this, 0.025); Hammer_Whiff_Sound(this); }
void p_hammer_tracer_low(entity this) { wep_set_anim(this, 178, p_hammer_hit_low); swf(this, 114); snt(this, 0.025); W_SwingHammer(this, hammer_charge_LOW); saf(this, hammer_swing_cooldown); } // check to see what hit, SKIP to target chain

void p_hammer_hit_low(entity this) { wep_set_anim(this, 179, p_hammer_autoanim_01); swf(this, 115); snt(this, 0.025); }
void p_hammer_kill_low(entity this) { wep_set_anim(this, 179, p_hammer_autoanim_01); swf(this, 124); snt(this, 0.025); Spark_Activate(this, 0, 1);}
void p_hammer_dash_low(entity this) { wep_set_anim(this, 179, p_hammer_autoanim_01); swf(this, 133); snt(this, 0.025); Spark_Activate(this, 1, 1);}
void p_hammer_hop_low(entity this) { wep_set_anim(this, 179, p_hammer_autoanim_01); swf(this, 142); snt(this, 0.025); Spark_Activate(this, 2, 1); muzzleflash(this); }
void p_hammer_whiff_low(entity this) { wep_set_anim(this, 179, p_hammer_autoanim_01); swf(this, 177); snt(this, 0.025); }

//=============================================================================================	
//	    77	 release MED
void p_hammer_tracer_med(entity this);
void p_hammer_hit_med(entity this);
void p_hammer_release_med(entity this) { wep_set_anim(this, 168, p_hammer_tracer_med); swf(this, 77); snt(this, 0.025); Hammer_Whiff_Sound(this); }
void p_hammer_tracer_med(entity this) { wep_set_anim(this, 168, p_hammer_hit_med); swf(this, 77); snt(this, 0.025);	W_SwingHammer(this, hammer_charge_MED); saf(this, hammer_swing_cooldown); } // check to see what hit, SKIP to target chain

void p_hammer_hit_med(entity this) { wep_set_anim(this, 169, p_hammer_autoanim_01); swf(this, 78); snt(this, 0.025); }
void p_hammer_kill_med(entity this) { wep_set_anim(this, 169, p_hammer_autoanim_01); swf(this, 87); snt(this, 0.025); Spark_Activate(this, 0, 2);}
void p_hammer_dash_med(entity this) { wep_set_anim(this, 169, p_hammer_autoanim_01); swf(this, 96); snt(this, 0.025); Spark_Activate(this, 1, 2);}
void p_hammer_hop_med(entity this) { wep_set_anim(this, 169, p_hammer_autoanim_01); swf(this, 105); snt(this, 0.025); Spark_Activate(this, 2, 2); muzzleflash(this); }
void p_hammer_whiff_med(entity this) { wep_set_anim(this, 169, p_hammer_autoanim_01); swf(this, 168); snt(this, 0.025); }
	
//=============================================================================================
//	    40	 release HIGH
void p_hammer_hit_high(entity this);
void p_hammer_tracer_high(entity this);
void p_hammer_release_high(entity this) { wep_set_anim(this, 158, p_hammer_tracer_high); swf(this, 40); snt(this, 0.025); Hammer_Whiff_Sound(this); }
void p_hammer_tracer_high(entity this) { wep_set_anim(this, 158, p_hammer_hit_high); swf(this, 40); snt(this, 0.025);	W_SwingHammer(this, hammer_charge_HIGH); saf(this, hammer_swing_cooldown); } // check to see what hit, SKIP to target chain

void p_hammer_hit_high(entity this) { wep_set_anim(this, 159, p_hammer_autoanim_01); swf(this, 41); snt(this, 0.025); }
void p_hammer_kill_high(entity this) { wep_set_anim(this, 159, p_hammer_autoanim_01); swf(this, 50); snt(this, 0.025); Spark_Activate(this, 0, 3);}
void p_hammer_dash_high(entity this) { wep_set_anim(this, 159, p_hammer_autoanim_01); swf(this, 59); snt(this, 0.025); Spark_Activate(this, 1, 3);}
void p_hammer_hop_high(entity this) { wep_set_anim(this, 159, p_hammer_autoanim_01); swf(this, 68); snt(this, 0.025); Spark_Activate(this, 2, 3); muzzleflash(this); }
void p_hammer_whiff_high(entity this) { wep_set_anim(this, 159, p_hammer_autoanim_01); swf(this, 159); snt(this, 0.025); }

//=============================================================================================
//    186-201     spinny (spammable)
void p_hammer_spin_anim(entity this);
void p_hammer_spin(entity this) { wep_set_anim(this, 196, p_hammer_spin_anim); swf(this, 186); snt(this, 0.05); saf(this, 0.4); }
void p_hammer_spin_anim(entity this)
{    
	//hotswap(this, 0); 									// cancel spinny if player switches weapons

	if(this.m_frame >= 201) { w_ready(this); return; } 				// loop until end of anim
	else { st(this, p_hammer_spin_anim); swf1(this); snt(this, 0.05); }			// advance weapon animations +1
}

//=============================================================================================
//    202-254     pickup/inspect
void p_hammer_inspect_anim(entity this);
void p_hammer_inspect_anim2(entity this);
void p_hammer_inspect(entity this) { wep_set_anim(this, 212, p_hammer_inspect_anim); swf(this, 202); snt(this, 0.08); saf(this, 0.8); }
void p_hammer_inspect_anim(entity this)
{   
	if(this.m_frame >= 244) { this.m_frame = 17; p_hammer_inspect_anim2(this); } 	// loop anim frame +1 but it's 10 frames short, so play axstand to fill time
	else { st(this, p_hammer_inspect_anim); swf1(this); snt(this, 0.08);}			// advance weapon and player animations +1
}
void p_hammer_inspect_anim2(entity this)
{
	if(this.m_frame >= 254) { w_ready(this); return; } 				// end loop at last frame of inspect
	else { st(this, p_hammer_inspect_anim2); swf1(this); snt(this, 0.08);}			// advance weapon and player animations +1	
}

//=============================================================================================//=============================================================================================
//	auto animate swings and player (swf+=1 x9)
void p_hammer_cooldown_01(entity this);
void p_hammer_autoanim_08(entity this) { st(this, p_hammer_cooldown_01); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_07(entity this) { st(this, p_hammer_autoanim_08); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_06(entity this) { st(this, p_hammer_autoanim_07); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_05(entity this) { st(this, p_hammer_autoanim_06); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_04(entity this) { st(this, p_hammer_autoanim_05); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_03(entity this) { st(this, p_hammer_autoanim_04); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_02(entity this) { st(this, p_hammer_autoanim_03); swf1(this); snt(this, 0.05); }
void p_hammer_autoanim_01(entity this) { st(this, p_hammer_autoanim_02); swf1(this); self1(this); snt(this, 0.025); }

//=============================================================================================
//	151-158	cooldown > idle
void p_hammer_cooldown_08(entity this) { wep_set_anim(this, 195, w_ready); swf(this, 158); snt(this, 0.05); }
void p_hammer_cooldown_07(entity this) { wep_set_anim(this, 194, p_hammer_cooldown_08); swf(this, 157); snt(this, 0.05); }
void p_hammer_cooldown_06(entity this) { wep_set_anim(this, 193, p_hammer_cooldown_07); swf(this, 156); snt(this, 0.05); }
void p_hammer_cooldown_05(entity this) { wep_set_anim(this, 192, p_hammer_cooldown_06); swf(this, 155); snt(this, 0.05); }
void p_hammer_cooldown_04(entity this) { wep_set_anim(this, 191, p_hammer_cooldown_05); swf(this, 154); snt(this, 0.05); }
void p_hammer_cooldown_03(entity this) { wep_set_anim(this, 190, p_hammer_cooldown_04); swf(this, 153); snt(this, 0.05); }
void p_hammer_cooldown_02(entity this) { wep_set_anim(this, 189, p_hammer_cooldown_03); swf(this, 152); snt(this, 0.05); }
void p_hammer_cooldown_01(entity this) { wep_set_anim(this, 188, p_hammer_cooldown_02); swf(this, 151); snt(this, 0.05); }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Spark effects for different swings

//=============================================================================================
// Spark / Blood Sprite Auto Animate and Remove

//  0-6   low
//  7-13  med
// 14-20  high

// 20 FPS
void x_spark_07(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, SUB_Remove); }
void x_spark_06(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_spark_07); }
void x_spark_05(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_spark_06); }
void x_spark_04(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_spark_05); }
void x_spark_03(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_spark_04); }
void x_spark_02(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_spark_03); }
void x_spark_01(entity this) {                  this.nextthink = time + 0.05; setthink(this, x_spark_02); }

void x_spark_01_touch(entity this, entity toucher) { x_spark_01(this); }

// Fast at start 40 FPS then slower 20 FPS
void x_blood_15(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, SUB_Remove); }
void x_blood_14(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_15); }
void x_blood_13(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_14); }
void x_blood_12(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_13); }
void x_blood_11(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_12); }
void x_blood_10(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_11); }
void x_blood_09(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_10); }
void x_blood_08(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_09); }
void x_blood_07(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_08); }
void x_blood_06(entity this) { self.frame += 1; this.nextthink = time + 0.05; setthink(this, x_blood_07); }
void x_blood_05(entity this) { self.frame += 1; this.nextthink = time + 0.025; setthink(this, x_blood_06); }
void x_blood_04(entity this) { self.frame += 1; this.nextthink = time + 0.025; setthink(this, x_blood_05); }
void x_blood_03(entity this) { self.frame += 1; this.nextthink = time + 0.025; setthink(this, x_blood_04); }
void x_blood_02(entity this) { self.frame += 1; this.nextthink = time + 0.025; setthink(this, x_blood_03); }
void x_blood_01(entity this) {                  this.nextthink = time + 0.025; setthink(this, x_blood_02); }

void Spark_Activate(entity this, float spark_type, float spark_charge)
{
	if(spark_type == 0)
		return;
	entity actor = this.owner;
	
	//sound (actor, CHAN_AUTO, ".wav", 1, ATTN_NORM);
	
	entity spark = spawn();
	spark.classname = "spark";
	spark.owner = actor;
	set_movetype(spark, MOVETYPE_NONE);
	spark.solid = SOLID_NOT;
		
	makevectors(actor.v_angle);

	spark.velocity = qc_aim(actor, 1000);
	spark.velocity = (spark.velocity * 1000);
	spark.avelocity = '0 0 0'; //roll
	
	spark.angles = vectoangles(spark.velocity);

	if(spark_type == 1)	// Dash
	{
		settouch(spark, x_spark_01_touch);
		setthink(spark, x_spark_01);
		spark.nextthink = time;
		_setmodel(spark, "progs/spark_blue.mdl");
		setorigin(spark, actor.origin + v_forward * 32 + '0 0 16');
		
		spark.frame = 14;
		if(spark_charge == 1)
			spark.frame = 0;
		else if(spark_charge == 2)
			spark.frame = 7;
	}	
	else			// Hop	
	{
		settouch(spark, x_spark_01_touch);
		setthink(spark, x_spark_01);
		spark.nextthink = time;
		_setmodel(spark, "progs/spark_yellow.mdl");
		setorigin(spark, actor.origin + v_forward * 32 + '0 0 16');

		spark.frame = 14;
		if(spark_charge == 1)
			spark.frame = 0;
		else if(spark_charge == 2)
			spark.frame = 7;
	}	

	setsize(spark, '0 0 0', '0 0 0');
}

METHOD(Hammer, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	Weapon oldwep = actor.(weaponentity).hammer_prevwep;
	actor.(weaponentity).hammer_prevwep = actor.(weaponentity).m_weapon;

	if(oldwep != WEP_HAMMER) // only plays once!!
	{
		p_hammer_spin(actor.(weaponentity));
		return;
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_hammer1(actor);
		p_hammer_charge_low_01(actor.(weaponentity));
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}

	if(fire & 2)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(!(time < actor.attack2_finished))
	{
		actor.(weaponentity).hammer_skin += 1;
		if(actor.(weaponentity).hammer_skin > SKIN_LAST)
			actor.(weaponentity).hammer_skin = SKIN_DEFAULT;
		actor.attack2_finished = time + 0.25;
	}
}
METHOD(Hammer, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// while weapon does use ammo, also works fine without!
	return true;
}
METHOD(Hammer, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Hammer, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

string hammer_getskin(int skinid)
{
	switch(skinid)
	{
		default:
		case SKIN_DEFAULT: return "hammer_default";
		case SKIN_BLOODY: return "hammer_default_bloody";
		case SKIN_ALK: return "hammer_alkaline_axe";
		case SKIN_BASEBALL: return "hammer_baseball";
		case SKIN_FODDY: return "hammer_moving_past_it";
		case SKIN_MAILBOX: return "hammer_mailbox";
		case SKIN_ROCKET: return "hammer_heavy_rocket";
		case SKIN_BRICK: return "hammer_brown_brick";
		case SKIN_SBLADE: return "hammer_sblade";
		case SKIN_BURGER: return "hammer_burger";
		case SKIN_BUSTER: return "hammer_buster_sword";
		case SKIN_GUITAR: return "hammer_guitar";
		case SKIN_PICKAXE: return "hammer_pickaxe";
		case SKIN_DWARVEN: return "hammer_dwarven";
		case SKIN_JESTER: return "hammer_jester_mallet";
		case SKIN_ERROR: return "hammer_error";
		case SKIN_SAILOR: return "hammer_sailor_sceptre";
		case SKIN_FLOYD: return "hammer_floyd";
		case SKIN_KEBBY: return "hammer_kebby_gears";
		case SKIN_SQUEAKY: return "hammer_squeaky";
		case SKIN_DOOMYTURNEL: return "hammer_sentinel";
		case SKIN_KATANA: return "hammer_katana";
		case SKIN_PIRATE: return "hammer_pirate_skull";
		case SKIN_GOLD: return "hammer_default_gold";
		case SKIN_GOLDB: return "hammer_default_gold_bloody";
		case SKIN_BLOCKY: return "hammer_blocky_axe";
		case SKIN_MACE: return "hammer_mace";
		case SKIN_STOP: return "hammer_stop_sign";
		case SKIN_COPPER: return "hammer_copper_axe";
	}
	return "hammer_default";
}

#ifdef CSQC
METHOD(Hammer, wr_viewmodel, string(Hammer this, entity wep))
{
	return hammer_getskin(wep.hammer_skin);
}
#endif

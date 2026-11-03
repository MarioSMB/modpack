#include "speaknspell.qh"

#ifdef SVQC
PRECACHE(SpeakNSpell)
{
	precache_model("progs/g_speaknspell.mdl");
	precache_model("progs/v_speaknspell.mdl");

	precache_model("progs/s6_circleburst.spr");

	precache_sound("weapons/speaknspell_startup.wav");
	precache_sound("weapons/speaknspell_levelup.wav");
	precache_sound("weapons/speaknspell_allkeys.wav");
	//precache_sound("weapons/keyboard_slamming.wav");
	
	precache_sound("weapons/speaknspell_a.wav");
	precache_sound("weapons/speaknspell_b.wav");
	precache_sound("weapons/speaknspell_c.wav");
	precache_sound("weapons/speaknspell_d.wav");
	precache_sound("weapons/speaknspell_e.wav");
	precache_sound("weapons/speaknspell_f.wav");
	precache_sound("weapons/speaknspell_g.wav");
	precache_sound("weapons/speaknspell_h.wav");
	precache_sound("weapons/speaknspell_i.wav");
	precache_sound("weapons/speaknspell_j.wav");
	precache_sound("weapons/speaknspell_k.wav");
	precache_sound("weapons/speaknspell_l.wav");
	precache_sound("weapons/speaknspell_m.wav");
	precache_sound("weapons/speaknspell_n.wav");
	precache_sound("weapons/speaknspell_o.wav");
	precache_sound("weapons/speaknspell_p.wav");
	precache_sound("weapons/speaknspell_q.wav");
	precache_sound("weapons/speaknspell_r.wav");
	precache_sound("weapons/speaknspell_s.wav");
	precache_sound("weapons/speaknspell_t.wav");
	precache_sound("weapons/speaknspell_u.wav");
	precache_sound("weapons/speaknspell_v.wav");
	precache_sound("weapons/speaknspell_w.wav");
	precache_sound("weapons/speaknspell_x.wav");
	precache_sound("weapons/speaknspell_y.wav");
	precache_sound("weapons/speaknspell_z.wav");
}

// SPEAK N SPELL ========================================================================================================================================================

//void() player_speaknspell_finger_lift = {self.weaponframe = 0 ; self.nextthink = time + 0.5 ; self.think = ;}

void sns_atktime(entity this, float atime)
{
	.entity weaponentity = this.weaponentity_fld;
	if(!this.owner.button0 || STAT(MANA, this.owner) < 1)
	{
		w_ready(this);
		return;
	}
	ATTACK_FINISHED(this.owner, weaponentity) = time + atime;
}

const float SNS_RATE = 0.4;

void wep_speaknspell_end1(entity this);
void wep_speaknspell_z(entity this) { wep_set_anim(this, 26, wep_speaknspell_end1); W_FireSpeaknSpell(this.owner, 1.2, "weapons/speaknspell_z.wav", this.weaponentity_fld); }
void wep_speaknspell_yy(entity this) { wep_set_anim(this, 27, wep_speaknspell_z); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_y(entity this) { wep_set_anim(this, 25, wep_speaknspell_yy); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_y.wav", this.weaponentity_fld); }
void wep_speaknspell_xx(entity this) { wep_set_anim(this, 27, wep_speaknspell_y); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_x(entity this) { wep_set_anim(this, 24, wep_speaknspell_xx); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_x.wav", this.weaponentity_fld); }
void wep_speaknspell_ww(entity this) { wep_set_anim(this, 27, wep_speaknspell_x); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_w(entity this) { wep_set_anim(this, 23, wep_speaknspell_ww); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_w.wav", this.weaponentity_fld); }
void wep_speaknspell_vv(entity this) { wep_set_anim(this, 27, wep_speaknspell_w); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_v(entity this) { wep_set_anim(this, 22, wep_speaknspell_vv); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_v.wav", this.weaponentity_fld); }
void wep_speaknspell_uu(entity this) { wep_set_anim(this, 27, wep_speaknspell_v); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_u(entity this) { wep_set_anim(this, 21, wep_speaknspell_uu); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_u.wav", this.weaponentity_fld); }
void wep_speaknspell_tt(entity this) { wep_set_anim(this, 27, wep_speaknspell_u); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_t(entity this) { wep_set_anim(this, 20, wep_speaknspell_tt); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_t.wav", this.weaponentity_fld); }
void wep_speaknspell_ss(entity this) { wep_set_anim(this, 27, wep_speaknspell_t); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_s(entity this) { wep_set_anim(this, 19, wep_speaknspell_ss); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_s.wav", this.weaponentity_fld); }
void wep_speaknspell_rr(entity this) { wep_set_anim(this, 27, wep_speaknspell_s); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_r(entity this) { wep_set_anim(this, 18, wep_speaknspell_rr); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_r.wav", this.weaponentity_fld); }
void wep_speaknspell_qq(entity this) { wep_set_anim(this, 27, wep_speaknspell_r); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_q(entity this) { wep_set_anim(this, 17, wep_speaknspell_qq); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_q.wav", this.weaponentity_fld); }
void wep_speaknspell_pp(entity this) { wep_set_anim(this, 27, wep_speaknspell_q); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_p(entity this) { wep_set_anim(this, 16, wep_speaknspell_pp); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_p.wav", this.weaponentity_fld); }
void wep_speaknspell_oo(entity this) { wep_set_anim(this, 27, wep_speaknspell_p); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_o(entity this) { wep_set_anim(this, 15, wep_speaknspell_oo); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_o.wav", this.weaponentity_fld); }
void wep_speaknspell_nn(entity this) { wep_set_anim(this, 27, wep_speaknspell_o); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_n(entity this) { wep_set_anim(this, 14, wep_speaknspell_nn); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_n.wav", this.weaponentity_fld); }
void wep_speaknspell_mm(entity this) { wep_set_anim(this, 27, wep_speaknspell_n); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_m(entity this) { wep_set_anim(this, 13, wep_speaknspell_mm); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_m.wav", this.weaponentity_fld); }
void wep_speaknspell_ll(entity this) { wep_set_anim(this, 27, wep_speaknspell_m); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_l(entity this) { wep_set_anim(this, 12, wep_speaknspell_ll); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_l.wav", this.weaponentity_fld); }
void wep_speaknspell_kk(entity this) { wep_set_anim(this, 27, wep_speaknspell_l); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_k(entity this) { wep_set_anim(this, 11, wep_speaknspell_kk); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_k.wav", this.weaponentity_fld); }
void wep_speaknspell_jj(entity this) { wep_set_anim(this, 27, wep_speaknspell_k); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_j(entity this) { wep_set_anim(this, 10, wep_speaknspell_jj); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_j.wav", this.weaponentity_fld); }
void wep_speaknspell_ii(entity this) { wep_set_anim(this, 27, wep_speaknspell_j); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_i(entity this) { wep_set_anim(this, 9, wep_speaknspell_ii); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_i.wav", this.weaponentity_fld); }
void wep_speaknspell_hh(entity this) { wep_set_anim(this, 27, wep_speaknspell_i); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_h(entity this) { wep_set_anim(this, 8, wep_speaknspell_hh); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_h.wav", this.weaponentity_fld); }
void wep_speaknspell_gg(entity this) { wep_set_anim(this, 27, wep_speaknspell_h); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_g(entity this) { wep_set_anim(this, 7, wep_speaknspell_gg); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_g.wav", this.weaponentity_fld); }
void wep_speaknspell_ff(entity this) { wep_set_anim(this, 27, wep_speaknspell_g); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_f(entity this) { wep_set_anim(this, 6, wep_speaknspell_ff); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_f.wav", this.weaponentity_fld); }
void wep_speaknspell_ee(entity this) { wep_set_anim(this, 27, wep_speaknspell_f); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_e(entity this) { wep_set_anim(this, 5, wep_speaknspell_ee); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_e.wav", this.weaponentity_fld); }
void wep_speaknspell_dd(entity this) { wep_set_anim(this, 27, wep_speaknspell_e); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_d(entity this) { wep_set_anim(this, 4, wep_speaknspell_dd); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_d.wav", this.weaponentity_fld); }
void wep_speaknspell_cc(entity this) { wep_set_anim(this, 27, wep_speaknspell_d); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_c(entity this) { wep_set_anim(this, 3, wep_speaknspell_cc); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_c.wav", this.weaponentity_fld); }
void wep_speaknspell_bb(entity this) { wep_set_anim(this, 27, wep_speaknspell_c); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_b(entity this) { wep_set_anim(this, 2, wep_speaknspell_bb); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_b.wav", this.weaponentity_fld); }
void wep_speaknspell_aa(entity this) { wep_set_anim(this, 27, wep_speaknspell_b); sns_atktime(this, SNS_RATE); }
void wep_speaknspell_a(entity this) { wep_set_anim(this, 1, wep_speaknspell_aa); W_FireSpeaknSpell(this.owner, SNS_RATE, "weapons/speaknspell_a.wav", this.weaponentity_fld); }

void wep_speaknspell_end14(entity this) { wep_set_anim(this, 40, w_ready); _sound(this.owner, CH_WEAPON_A, "weapons/speaknspell_levelup.wav", 1, ATTN_NORM); }
void wep_speaknspell_end13(entity this) { wep_set_anim(this, 39, wep_speaknspell_end14); }
void wep_speaknspell_end12(entity this) { wep_set_anim(this, 38, wep_speaknspell_end13); }
void wep_speaknspell_end11(entity this) { wep_set_anim(this, 37, wep_speaknspell_end12); }
void wep_speaknspell_end10(entity this) { wep_set_anim(this, 36, wep_speaknspell_end11); }
void wep_speaknspell_end9(entity this) { wep_set_anim(this, 35, wep_speaknspell_end10); }
void wep_speaknspell_end8(entity this) { wep_set_anim(this, 34, wep_speaknspell_end9); }
void wep_speaknspell_end7(entity this) { wep_set_anim(this, 33, wep_speaknspell_end8); }
void wep_speaknspell_end6(entity this) { wep_set_anim(this, 32, wep_speaknspell_end7); }
void wep_speaknspell_end5(entity this) { wep_set_anim(this, 31, wep_speaknspell_end6); }
void wep_speaknspell_end4(entity this) { wep_set_anim(this, 30, wep_speaknspell_end5); W_FireSpeaknSepll_AllKeys(this.owner, this.weaponentity_fld); _sound(this.owner, CH_WEAPON_A, "weapons/speaknspell_allkeys.wav", 1, ATTN_NORM); }
void wep_speaknspell_end3(entity this) { wep_set_anim(this, 29, wep_speaknspell_end4); }
void wep_speaknspell_end2(entity this) { wep_set_anim(this, 28, wep_speaknspell_end3); }
void wep_speaknspell_end1(entity this) { wep_set_anim(this, 27, wep_speaknspell_end2); }

/*
================================================================================================================

	SPEAK AND SPELL

================================================================================================================
*/
void BecomeSpeaknSpellExplosion(entity this)
{
	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/s6_circleburst.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	//setorigin(newmis, findbetterlocation(this.origin, 8));
	setorigin(newmis, this.origin); // most calls to this already adjust position
	//newmis.angles = this.angles;
	//newmis.colormod = this.colormod;
	s_explode1(newmis);

	delete(this);
}

void T_SpeaknSpellTouch(entity this, entity toucher)
{
	float damg = 15;	

	if(toucher == this.owner)
		return;		

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, damg, WEP_SPEAKNSPELL.m_id);
		this.enemy = toucher;
		BecomeSpeaknSpellExplosion(this);
		return;
	}
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
	/*
	if (toucher.health)
	{
		if (toucher.classname == "monster_shambler")
			damg = damg * 2;				// DOUBLE DAMAGE ON SHAMBLER
		T_Damage (toucher, self, self.owner, damg );
		BecomeSpeaknSpellExplosion();	
	}
	*/
	//BecomeSpeaknSpellExplosion();					// REMOVE THIS FOR BOUNCY PEWS!!!!
	
}

Projectile Projectile_FromLetter(int letter)
{
	switch(letter)
	{
		default:
		case 0: return PROJECTILE_LETTER_A;
		case 1: return PROJECTILE_LETTER_B;
		case 2: return PROJECTILE_LETTER_C;
		case 3: return PROJECTILE_LETTER_D;
		case 4: return PROJECTILE_LETTER_E;
		case 5: return PROJECTILE_LETTER_F;
		case 6: return PROJECTILE_LETTER_G;
		case 7: return PROJECTILE_LETTER_H;
		case 8: return PROJECTILE_LETTER_I;
		case 9: return PROJECTILE_LETTER_J;
		case 10: return PROJECTILE_LETTER_K;
		case 11: return PROJECTILE_LETTER_L;
		case 12: return PROJECTILE_LETTER_M;
		case 13: return PROJECTILE_LETTER_N;
		case 14: return PROJECTILE_LETTER_O;
		case 15: return PROJECTILE_LETTER_P;
		case 16: return PROJECTILE_LETTER_Q;
		case 17: return PROJECTILE_LETTER_R;
		case 18: return PROJECTILE_LETTER_S;
		case 19: return PROJECTILE_LETTER_T;
		case 20: return PROJECTILE_LETTER_U;
		case 21: return PROJECTILE_LETTER_V;
		case 22: return PROJECTILE_LETTER_W;
		case 23: return PROJECTILE_LETTER_X;
		case 24: return PROJECTILE_LETTER_Y;
		case 25: return PROJECTILE_LETTER_Z;
	}

	return PROJECTILE_Null; // ???
}

void W_FireSpeaknSepll_AllKeys(entity actor, .entity weaponentity) // Shotgun at End of Z --------------------------------------------
{
	//entity this = actor.(weaponentity);

	//if(!actor.button0)
	//{
		//w_ready(this);
		//return;
	//}

	//W_TakeMana(actor, 5);

	if(IS_PLAYER(actor))
		player_nail1(actor);

	int multi_shot = 0;
	
	while(multi_shot < 26)
	{
		multi_shot += 1;
		
		entity letter = spawn();
		letter.owner = actor;
		letter.flags = FL_PROJECTILE;
		letter.clipgroup = actor.clipgroup;
		letter.realowner = actor;
		set_movetype(letter, MOVETYPE_BOUNCE);
		letter.solid = SOLID_BBOX;
		letter.classname = "grenade";
		makevectors(actor.v_angle);
		if(actor.v_angle_x)
		{
			letter.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 200 + crandom() * v_up * 200;
		}
		else
		{
			letter.velocity = qc_aim(actor, 10000);
			letter.velocity *= 600;
			letter.velocity_z = 200;
		}
		letter.avelocity = '0 0 0';
		letter.angles = vectoangles(letter.velocity);
		settouch(letter, T_SpeaknSpellTouch);
		letter.nextthink = time + 1.5;
		setthink(letter, BecomeSpeaknSpellExplosion);
		setorigin(letter, actor.origin + '0 0 12'); 
		setsize(letter, '0 0 0', '0 0 0');

		IL_PUSH(g_projectiles, letter);

		int letternum = floor(random() * 26);
		Projectile letterproj = Projectile_FromLetter(letternum);

		CSQCProjectile(letter, true, letterproj, true);
	}
}

void W_FireSpeaknSpell(entity actor, float atime, string asnd, .entity weaponentity) // Hold for stream of ABC letters --------------------------------------------
{
	entity this = actor.(weaponentity);

	if(!actor.button0 || STAT(MANA, actor) < 1)
	{
		w_ready(this);
		return;
	}

	W_TakeMana(actor, 1);

	if(IS_PLAYER(actor))
		player_nail1(actor);

	ATTACK_FINISHED(actor, weaponentity) = time + atime;

	_sound(actor, CH_WEAPON_A, asnd, 1, ATTN_NORM);

	entity letter = spawn();
	letter.flags = FL_PROJECTILE;
	letter.clipgroup = actor.clipgroup;
	letter.owner = actor;
	letter.realowner = actor;
	set_movetype(letter, MOVETYPE_BOUNCE);
	letter.solid = SOLID_BBOX;
	letter.classname = "grenade";
	makevectors(actor.v_angle);
	if(actor.v_angle_x)
	{
		letter.velocity = v_forward * 600 + v_up * 300 + crandom() * v_right * 50 + crandom() * v_up * 50;
	}
	else
	{
		letter.velocity = qc_aim(actor, 10000);
		letter.velocity = letter.velocity * 600;
		letter.velocity_z = 200;
	}
	letter.avelocity = '0 0 0';
	letter.angles = vectoangles(letter.velocity);
	settouch(letter, T_SpeaknSpellTouch);
	letter.nextthink = time + 1.5;
	setthink(letter, BecomeSpeaknSpellExplosion);
	setorigin(letter, actor.origin + '0 0 12'); 

	setsize(letter, '0 0 0', '0 0 0');

	IL_PUSH(g_projectiles, letter);

	int letternum = actor.(weaponentity).m_frame - 1;
	Projectile letterproj = Projectile_FromLetter(letternum);

	CSQCProjectile(letter, true, letterproj, true);
}

METHOD(SpeakNSpell, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	Weapon oldwep = actor.(weaponentity).speaknspell_prevwep;
	actor.(weaponentity).speaknspell_prevwep = actor.(weaponentity).m_weapon;

	if(oldwep != WEP_SPEAKNSPELL && !music_playing(actor)) // only plays once!!
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/speaknspell_startup.wav", 1, ATTN_NORM);
		return;
	}

	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 1)
	{
		wep_speaknspell_a(actor.(weaponentity));
	}
}
METHOD(SpeakNSpell, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(SpeakNSpell, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(SpeakNSpell, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif

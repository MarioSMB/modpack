#include "speaknspell.qh"

#ifdef SVQC
PRECACHE(SpeakNSpell)
{
	precache_model("progs/g_speaknspell.mdl");
	precache_model("progs/v_speaknspell.mdl");

	precache_model("progs/s6_circleburst.spr");
	precache_model("progs/s_sns_a.spr");
	precache_model("progs/s_sns_b.spr");
	precache_model("progs/s_sns_c.spr");
	precache_model("progs/s_sns_d.spr");
	precache_model("progs/s_sns_e.spr");
	precache_model("progs/s_sns_f.spr");
	precache_model("progs/s_sns_g.spr");
	precache_model("progs/s_sns_h.spr");
	precache_model("progs/s_sns_i.spr");
	precache_model("progs/s_sns_j.spr");
	precache_model("progs/s_sns_k.spr");
	precache_model("progs/s_sns_l.spr");
	precache_model("progs/s_sns_m.spr");
	precache_model("progs/s_sns_n.spr");
	precache_model("progs/s_sns_o.spr");
	precache_model("progs/s_sns_p.spr");
	precache_model("progs/s_sns_q.spr");
	precache_model("progs/s_sns_r.spr");
	precache_model("progs/s_sns_s.spr");
	precache_model("progs/s_sns_t.spr");
	precache_model("progs/s_sns_u.spr");
	precache_model("progs/s_sns_v.spr");
	precache_model("progs/s_sns_w.spr");
	precache_model("progs/s_sns_x.spr");
	precache_model("progs/s_sns_y.spr");
	precache_model("progs/s_sns_z.spr");

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
	set_movetype(this, MOVETYPE_NONE);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s6_circleburst.spr");
	setsize(this, '0 0 0', '0 0 0');
	this.solid = SOLID_NOT;
	s_explode1(this);
}

void T_SpeaknSpellTouch(entity this, entity toucher)
{
	float damg = 10;	

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
		float r = random();	
		
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

		if(r < 0.03846)      { _setmodel(letter, "progs/s_sns_a.spr");}
		else if(r < 0.07692) { _setmodel(letter, "progs/s_sns_b.spr");}
		else if(r < 0.11538) { _setmodel(letter, "progs/s_sns_c.spr");}
		else if(r < 0.15384) { _setmodel(letter, "progs/s_sns_d.spr");}
		else if(r < 0.19230) { _setmodel(letter, "progs/s_sns_e.spr");}
		else if(r < 0.23076) { _setmodel(letter, "progs/s_sns_f.spr");}
		else if(r < 0.26923) { _setmodel(letter, "progs/s_sns_g.spr");}
		else if(r < 0.30769) { _setmodel(letter, "progs/s_sns_h.spr");}
		else if(r < 0.34615) { _setmodel(letter, "progs/s_sns_i.spr");}
		else if(r < 0.38461) { _setmodel(letter, "progs/s_sns_j.spr");}
		else if(r < 0.42307) { _setmodel(letter, "progs/s_sns_k.spr");}
		else if(r < 0.46153) { _setmodel(letter, "progs/s_sns_l.spr");}
		else if(r < 0.5)     { _setmodel(letter, "progs/s_sns_m.spr");}
		else if(r < 0.53846) { _setmodel(letter, "progs/s_sns_n.spr");}
		else if(r < 0.57692) { _setmodel(letter, "progs/s_sns_o.spr");}
		else if(r < 0.61538) { _setmodel(letter, "progs/s_sns_p.spr");}
		else if(r < 0.65384) { _setmodel(letter, "progs/s_sns_q.spr");}
		else if(r < 0.69230) { _setmodel(letter, "progs/s_sns_r.spr");}
		else if(r < 0.73076) { _setmodel(letter, "progs/s_sns_s.spr");}
		else if(r < 0.76923) { _setmodel(letter, "progs/s_sns_t.spr");}
		else if(r < 0.80769) { _setmodel(letter, "progs/s_sns_u.spr");}
		else if(r < 0.84615) { _setmodel(letter, "progs/s_sns_v.spr");}
		else if(r < 0.88461) { _setmodel(letter, "progs/s_sns_w.spr");}
		else if(r < 0.92307) { _setmodel(letter, "progs/s_sns_x.spr");}
		else if(r < 0.96153) { _setmodel(letter, "progs/s_sns_y.spr");}
		else  	             { _setmodel(letter, "progs/s_sns_z.spr");}	
		setsize(letter, '0 0 0', '0 0 0');

		IL_PUSH(g_projectiles, letter);
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

	switch(actor.(weaponentity).m_frame)
	{
		case 1:  _setmodel(letter, "progs/s_sns_a.spr"); break;
		case 2:  _setmodel(letter, "progs/s_sns_b.spr"); break;
		case 3:  _setmodel(letter, "progs/s_sns_c.spr"); break;
		case 4:  _setmodel(letter, "progs/s_sns_d.spr"); break;
		case 5:  _setmodel(letter, "progs/s_sns_e.spr"); break;
		case 6:  _setmodel(letter, "progs/s_sns_f.spr"); break;
		case 7:  _setmodel(letter, "progs/s_sns_g.spr"); break;
		case 8:  _setmodel(letter, "progs/s_sns_h.spr"); break;
		case 9:  _setmodel(letter, "progs/s_sns_i.spr"); break;
		case 10: _setmodel(letter, "progs/s_sns_j.spr"); break;
		case 11: _setmodel(letter, "progs/s_sns_k.spr"); break;
		case 12: _setmodel(letter, "progs/s_sns_l.spr"); break;
		case 13: _setmodel(letter, "progs/s_sns_m.spr"); break;
		case 14: _setmodel(letter, "progs/s_sns_n.spr"); break;
		case 15: _setmodel(letter, "progs/s_sns_o.spr"); break;
		case 16: _setmodel(letter, "progs/s_sns_p.spr"); break;
		case 17: _setmodel(letter, "progs/s_sns_q.spr"); break;
		case 18: _setmodel(letter, "progs/s_sns_r.spr"); break;
		case 19: _setmodel(letter, "progs/s_sns_s.spr"); break;
		case 20: _setmodel(letter, "progs/s_sns_t.spr"); break;
		case 21: _setmodel(letter, "progs/s_sns_u.spr"); break;
		case 22: _setmodel(letter, "progs/s_sns_v.spr"); break;
		case 23: _setmodel(letter, "progs/s_sns_w.spr"); break;
		case 24: _setmodel(letter, "progs/s_sns_x.spr"); break;
		case 25: _setmodel(letter, "progs/s_sns_y.spr"); break;
		default:
		case 26: _setmodel(letter, "progs/s_sns_z.spr"); break;
	}
	setsize(letter, '0 0 0', '0 0 0');

	IL_PUSH(g_projectiles, letter);
}

METHOD(SpeakNSpell, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	Weapon oldwep = actor.(weaponentity).speaknspell_prevwep;
	actor.(weaponentity).speaknspell_prevwep = actor.(weaponentity).m_weapon;

	if(oldwep != WEP_SPEAKNSPELL) // only plays once!!
	{
		_sound(actor, CH_WEAPON_B, "weapons/speaknspell_startup.wav", 1, ATTN_NORM);
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

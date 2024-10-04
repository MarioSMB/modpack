#include "mime.qh"

#ifdef SVQC
void BallTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM && Damage_ValidTarget(toucher, this.owner))
		T_Damage(toucher, this, this.owner, 30, this.projectiledeathtype);

	if(this.attack_finished < time)
		_sound(this, CH_WEAPON_SINGLE, "player_mime/bounce.wav", 0.7, ATTN_NORM);	// bounce sound
	this.attack_finished = time + 0.1;
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void Mime_ThrowBall(entity this)
{
	.entity weaponentity = weaponentities[0]; // TODO?
	entity missile = new(ball);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MIMEBALL.m_id;
	missile.bouncefactor = 1;
	missile.bouncestop = 0.1;
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*120 + crandom()*v_up*120;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600 + randomvec() * 300;
		missile.velocity_z = 500;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, BallTouch);
	
// set missile duration
	missile.scale = 0.75; // TODO: resize model!
	vector mycolor;
	mycolor.x = max(0.25, random() * 5);
	mycolor.y = max(0.25, random() * 5);
	mycolor.z = max(0.25, random() * 5);
	missile.colormod = mycolor;
	missile.nextthink = time + 7;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/ball.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, W_Shotorg(this, weaponentity));
}

METHOD(Mime, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Mime, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		_sound(actor, CH_WEAPON_B, "weapons/sword_swing.wav", 1, ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		Mime_ThrowBall(actor);
	}
}

METHOD(Mime, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death2.wav", ATTN_NORM);
	actor.mime_cannon = true;
}

METHOD(Mime, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.mime_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.mime_cannon = false;
	return false;
}

METHOD(Mime, m_condition, bool(Champions this, entity actor))
{
	if(autocvar_sv_allow_customplayermodels_mime == "")
		return true;
	return !PlayerInList(actor, autocvar_sv_allow_customplayermodels_mime);
}
#endif

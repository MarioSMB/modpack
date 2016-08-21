#ifdef SVQC
float autocvar_g_dotc_item_lifetime = 25;

.float lifetime;

// ================
// Removal handling
// ================

void dotc_CreditRemove(entity this)
{
	if(!this || wasfreed(this))
	{
		LOG_DEBUG("Warning: trying to remove a non-existant this, aborting\n");
		return;
	}
	Send_Effect(EFFECT_ITEM_PICKUP, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	remove(this);
}

void dotc_CreditRemove_Reset(entity this) { dotc_CreditRemove(this); }


// ===============
// Pickup handling
// ===============

void dotc_CreditTouch(entity this, entity toucher)
{
	if(ITEM_TOUCH_NEEDKILL())
	{
		dotc_CreditRemove(this);
		return;
	}

	if( (!IS_PLAYER(toucher))
	||	(STAT(FROZEN, toucher))
	||	(toucher.deadflag != DEAD_NO)
	||	(SAME_TEAM(toucher, this))
	||	(time < this.item_spawnshieldtime)
	) { return; }

	sound(this, CH_TRIGGER, SND_DOTC_CREDIT_PICKUP, VOL_BASE, ATTN_NORM);
	Send_Effect(EFFECT_ITEM_PICKUP, CENTER_OR_VIEWOFS(this), '0 0 0', 1);

	entity core = dotc_GetCore(toucher.team);
	float need_credits = (core.dotc_nextlevel - core.dotc_credits);

	if(need_credits > 0)
		core.dotc_credits += this.cnt;

	PlayerScore_Add(toucher, SP_DOTC_CREDITS_TAKEN, this.cnt);
	PlayerScore_Add(toucher, SP_SCORE, +1);

	dotc_CreditRemove(this);
}


// =================
// Main credit setup
// =================

bool dotc_CreditSend(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_DOTC_CREDIT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & DOTC_CREDIT_SF_INIT)
	{
		WriteByte(MSG_ENTITY, this.team - 1);
		WriteCoord(MSG_ENTITY, this.origin_x);
		WriteCoord(MSG_ENTITY, this.origin_y);
		WriteCoord(MSG_ENTITY, this.origin_z);
		WriteCoord(MSG_ENTITY, this.velocity_x);
		WriteCoord(MSG_ENTITY, this.velocity_y);
		WriteCoord(MSG_ENTITY, this.velocity_z);
		WriteByte(MSG_ENTITY, autocvar_sv_simple_items);
	}

	if(sf & DOTC_CREDIT_SF_TEAM)
	{
		WriteByte(MSG_ENTITY, this.team - 1);
	}

	if(sf & DOTC_CREDIT_SF_MOVE)
	{
		WriteCoord(MSG_ENTITY, this.origin_x);
		WriteCoord(MSG_ENTITY, this.origin_y);
		WriteCoord(MSG_ENTITY, this.origin_z);
		WriteCoord(MSG_ENTITY, this.velocity_x);
		WriteCoord(MSG_ENTITY, this.velocity_y);
		WriteCoord(MSG_ENTITY, this.velocity_z);
	}

	return true;
}

void dotc_CreditUpdate(entity this)
{
	if(this.origin != this.dotc_credit_origin)
	{
		this.dotc_credit_origin = this.origin;
		this.SendFlags |= DOTC_CREDIT_SF_MOVE;
	}
	if(this.team != this.dotc_credit_team)
	{
		this.dotc_credit_team = this.team;
		this.SendFlags |= DOTC_CREDIT_SF_TEAM;
	}
}

void dotc_CreditThink(entity this)
{
	this.nextthink = time;

	if(time >= this.lifetime)
	{
		dotc_CreditRemove(this);
		return;
	}

	dotc_CreditUpdate(this);
}

entity dotc_CreditSpawn(entity dropper, vector where, int value)
{
	entity credit = spawn();

	setsize(credit, DOTC_CREDIT_MINS, DOTC_CREDIT_MAXS);

	credit.team 		= dropper.team;
	credit.solid 		= SOLID_TRIGGER;
	set_movetype(credit, MOVETYPE_TOSS);
	credit.cnt 			= value;
	credit.team 		= dropper.team;
	settouch(credit, dotc_CreditTouch);
	setthink(credit, dotc_CreditThink);
	credit.lifetime 	= time + autocvar_g_dotc_item_lifetime;
	credit.nextthink 	= time;

	setorigin(credit, where);
	credit.dotc_credit_origin = where;
	credit.dotc_credit_team = credit.team;

	credit.reset = dotc_CreditRemove_Reset;
	credit.gravity = 1;
	credit.velocity = randomvec() * 175 + '0 0 325';
	credit.item_spawnshieldtime = time + 0.7;

	Net_LinkEntity(credit, false, 0, dotc_CreditSend);

	credit.SendFlags |= DOTC_CREDIT_SF_INIT;
	
	return credit;
}

#elif defined(CSQC)

void dotc_CreditDraw(entity this)
{
	// team draw
	if(this.team == myteam)
	{
		this.colormod = '0.1 0.1 0.1';
		this.alpha = 0.7;
	}
	else
	{
		this.colormod = '0 0 0';
		this.alpha = 1;
	}

	if(autocvar_cl_animate_items)
	if(!this.dotc_credit_simple)
	{
		this.avelocity = DOTC_CREDIT_AVELOCITY;
		this.angles += this.avelocity * frametime;
		setorigin(this, '0 0 10' + this.oldorigin + '0 0 8' * sin(time * 2));
	}
}

void dotc_Credit_UpdateModel(entity this)
{
	string mymodel = MDL_DOTC_CREDIT.model_str();
	string mysimplemodel = strcat(substring(mymodel, 0, strlen(mymodel) - 4), "_simple.md3");
	precache_model(mysimplemodel);

	this.model = mymodel;

	if(this.dotc_credit_simple)
	if(fexists(mysimplemodel) && autocvar_cl_simple_items)
		this.model = mysimplemodel;
	else
		this.dotc_credit_simple = false;

	_setmodel(this, this.model);
	setsize(this, DOTC_CREDIT_MINS, DOTC_CREDIT_MAXS);
}

void dotc_Credit_UpdateTeam(entity this, int teamnumber)
{
	this.glowmod = (teamnumber) ? Team_ColorRGB(teamnumber) : '1 1 1';
}

NET_HANDLE(ENT_CLIENT_DOTC_CREDIT, bool isnew)
{
	int sf = ReadByte();

	if(sf & DOTC_CREDIT_SF_INIT)
	{
		this.draw = dotc_CreditDraw;
		this.drawmask = MASK_NORMAL;
		if (isnew) IL_PUSH(g_drawables, this);
		this.gravity = 1;
		set_movetype(this, MOVETYPE_TOSS);

		this.team = ReadByte();
		this.origin_x = ReadCoord();
		this.origin_y = ReadCoord();
		this.origin_z = ReadCoord();
		setorigin(this, this.origin);
		this.oldorigin = this.origin;
		this.velocity_x = ReadCoord();
		this.velocity_y = ReadCoord();
		this.velocity_z = ReadCoord();
		this.dotc_credit_simple = ReadByte();
		dotc_Credit_UpdateModel(this);
		dotc_Credit_UpdateTeam(this, this.team);
	}

	if(sf & DOTC_CREDIT_SF_TEAM)
	{
		this.team = ReadByte();
		dotc_Credit_UpdateTeam(this, this.team);
	}

	if(sf & DOTC_CREDIT_SF_MOVE)
	{
		this.origin_x = ReadCoord();
		this.origin_y = ReadCoord();
		this.origin_z = ReadCoord();
		this.velocity_x = ReadCoord();
		this.velocity_y = ReadCoord();
		this.velocity_z = ReadCoord();
		setorigin(this, this.origin);
		this.oldorigin = this.origin;
	}

	return true;
}
#endif

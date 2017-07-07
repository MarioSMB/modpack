// dmatch - general deathmatch additions

// =======================================
// =======================================
void tag_token_respawn()
{
	entity tagToken = find(NULL, classname, "dmatch_tag_token");
	if(tagToken == NULL)
		return;
		
	entity spawnPoint = SelectSpawnPoint(NULL);
	setorigin(tagToken, spawnPoint.origin);
	tag_token_owner = NULL;
	tagToken.solid = SOLID_TRIGGER;
	settouch(tagToken, tag_token_touch);
	setthink(tagToken, func_null);
	tagToken.nextthink = 0;
	tagToken.owner = NULL;
	tagToken.tag_frags = 0;
	WITHSELF(tagToken, builtin_droptofloor());
}

void respawn_tagtoken(entity this)
{
	tag_token_respawn();
}

// =======================================
// =======================================
void tag_token_fall(entity this)
{
	this.tag_frags = 0;
	setthink(this, respawn_tagtoken);
	this.nextthink = time + 30;
	WITHSELF(this, builtin_droptofloor());
}

// =======================================
// =======================================
void tag_token_drop()
{
	entity tagToken = find(NULL, classname, "dmatch_tag_token");
	if(tagToken == NULL)
		return;
		
	bprint(tagToken.owner.netname);
	bprint(" lost the tag token!\n");
	tagToken.tag_frags = 0;
	tagToken.solid = SOLID_TRIGGER;
	tagToken.owner = NULL;
	settouch(tagToken, tag_token_touch);
	setthink(tagToken, tag_token_fall);
	tagToken.nextthink = time + 0.1;
}

// =======================================
// =======================================
void tag_token_think(entity this)
{
	if(this.owner.health > 0)
	{
		if(this.tag_message_time < time)
		{
			bprint(this.owner.netname);
			bprint(" has the tag token!\n");
			this.tag_message_time = time + 30;
		}
		
		setorigin(this, this.owner.origin + '0 0 48');
		setthink(this, tag_token_think);
		this.nextthink = time + 0.1;
	}
	else
		tag_token_drop();
}

// =======================================
// =======================================
void tag_token_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
		
	tag_token_owner = toucher;
	this.tag_frags = 0;
	
	_sound(this, CHAN_AUTO, "runes/end1.wav", 1, ATTN_NORM);

	bprint(toucher.netname);
	bprint(" got the tag token!\n");
	this.tag_message_time = time + 30;
	
	this.owner = toucher;
	this.solid = SOLID_NOT;
	settouch(this, func_null);
	setthink(this, tag_token_think);
	this.nextthink = time + 0.1;
}

/*QUAKED dmatch_tag_token (1 1 0) (-16 -16 -16) (16 16 16)
The deathmatch tag token.
*/
spawnfunc(dmatch_tag_token)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	if(cvar("teamplay") != TEAM_DMATCH_TAG)
	{
		delete(this);
		return;
	}
	
	precache_model("progs/sphere.mdl");
	precache_sound("runes/end1.wav");
	_setmodel(this, "progs/sphere.mdl");
	this.skin = 1;
	setsize(this, '-16 -16 -16', '16 16 16');
	settouch(this, tag_token_touch);
	this.effects |= EF_DIMLIGHT;
	StartItem(this);
}

// =======================================
// =======================================
void dmatch_score(entity targ, entity attacker)
{
	if(teamplay == TEAM_DMATCH_TAG)
	{
		entity tagToken = find(NULL, classname, "dmatch_tag_token");
		if(tagToken == NULL)
		{
			attacker.frags = attacker.frags + 1;
			return;
		}
		
		if(attacker == tag_token_owner)
		{
			tagToken.tag_frags = tagToken.tag_frags + 1;
			attacker.frags = attacker.frags + 3;
			if(tagToken.tag_frags == 5)
			{
				sprint(attacker, "You got the Quad Damage\n");
				attacker.items |= IT_QUAD;
				stuffcmd(attacker, "bf\n");
				_sound(attacker,CHAN_VOICE,"items/damage.wav", 1, ATTN_NORM);
				attacker.super_time = 1;
				attacker.super_damage_finished = time + 30;
			}
			else if(tagToken.tag_frags == 10)
			{
				bprint(attacker.netname);
				bprint(" lost the tag token\n");
				tagToken.solid = SOLID_TRIGGER;
				tagToken.tag_frags = 0;
				settouch(tagToken, tag_token_touch);
				tag_token_respawn();
			}
		}
		else
		{
			if(targ == tag_token_owner)
			{
				attacker.frags = attacker.frags + 5;
				_sound(targ, CHAN_AUTO, "runes/end1.wav", 1, ATTN_NORM);
				if(IS_PLAYER(attacker))
				{
					tag_token_owner = attacker;
					
					tagToken.tag_frags = 0;	
					tagToken.tag_message_time = time + 0.5;
					tagToken.owner = attacker;
					tagToken.solid = SOLID_NOT;
					settouch(tagToken, func_null);
					setthink(tagToken, tag_token_think);
					tagToken.nextthink = time + 0.1;
				}	
			}
			else
				attacker.frags = attacker.frags + 1;
		}
	}
} 



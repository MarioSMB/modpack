#ifdef SVQC

// shorthand for turning -1 to 0 for keyvalues for which 0 is a valid non-default selection
float zeroconvert(float in)
{
	if(in == -1)
		return 0;
	return in;
}
float zeroconvertdefault(float in, float def)
{
	if(in == -1)
		return 0;
	if(in == 0)
		return def;
	return in;
}

//count -4 = numclients in coop
void playercount_convert(entity this, .float fld)
{
	if(this.(fld) != -4)
		return;
	if(!coop)
		this.(fld) = 1;
	else
	{
		int clients = 0;
		// let's not count bots
		FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it),
		{
			++clients;
		});
		// limit this because we can't assume a max of 8 coop players (... thanks decino)
		if(clients <= 4)
			this.(fld) = clients;
		else if(clients >= 20)
			this.(fld) = 10;	// hard cap of 10 @ 20 players
		else if(clients >= 16)
			this.(fld) = 9;
		else if(clients >= 12)
			this.(fld) = 8;
		else if(clients >= 10)
			this.(fld) = 7;
		else if(clients >= 8)
			this.(fld) = 6;
		else if(clients >= 6)
			this.(fld) = 5;
		/*
			this.(fld) =	// magic formula ...
				min(4, clients)	+							// first four clients count full
				floor(max(0, min(12, clients) - 4) / 2) +	// clients above 4th count half
				floor(max(0, clients - 12) / 4);			// clients above 12th count quarter
		*/
	}
}

/*! The translation table between the graphical font and plain ASCII  --KB */
const int qfont_table[256] = {
	'\0', '#',  '#',  '#',  '#',  '.',  '#',  '#',
	'#',  9,    10,   '#',  ' ',  13,   '.',  '.',
	'[',  ']',  '0',  '1',  '2',  '3',  '4',  '5',
	'6',  '7',  '8',  '9',  '.',  '<',  '=',  '>',
	' ',  '!',  '"',  '#',  '$',  '%',  '&',  '\'',
	'(',  ')',  '*',  '+',  ',',  '-',  '.',  '/',
	'0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',
	'8',  '9',  ':',  ';',  '<',  '=',  '>',  '?',
	'@',  'A',  'B',  'C',  'D',  'E',  'F',  'G',
	'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',
	'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',
	'X',  'Y',  'Z',  '[',  '\\', ']',  '^',  '_',
	'`',  'a',  'b',  'c',  'd',  'e',  'f',  'g',
	'h',  'i',  'j',  'k',  'l',  'm',  'n',  'o',
	'p',  'q',  'r',  's',  't',  'u',  'v',  'w',
	'x',  'y',  'z',  '{',  '|',  '}',  '~',  '<',

	'<',  '=',  '>',  '#',  '#',  '.',  '#',  '#',
	'#',  '#',  ' ',  '#',  ' ',  '>',  '.',  '.',
	'[',  ']',  '0',  '1',  '2',  '3',  '4',  '5',
	'6',  '7',  '8',  '9',  '.',  '<',  '=',  '>',
	' ',  '!',  '"',  '#',  '$',  '%',  '&',  '\'',
	'(',  ')',  '*',  '+',  ',',  '-',  '.',  '/',
	'0',  '1',  '2',  '3',  '4',  '5',  '6',  '7',
	'8',  '9',  ':',  ';',  '<',  '=',  '>',  '?',
	'@',  'A',  'B',  'C',  'D',  'E',  'F',  'G',
	'H',  'I',  'J',  'K',  'L',  'M',  'N',  'O',
	'P',  'Q',  'R',  'S',  'T',  'U',  'V',  'W',
	'X',  'Y',  'Z',  '[',  '\\', ']',  '^',  '_',
	'`',  'a',  'b',  'c',  'd',  'e',  'f',  'g',
	'h',  'i',  'j',  'k',  'l',  'm',  'n',  'o',
	'p',  'q',  'r',  's',  't',  'u',  'v',  'w',
	'x',  'y',  'z',  '{',  '|',  '}',  '~',  '<'
};

//=============================================================================

void DelayThink(entity this)
{
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}

string process_string(string input)
{
	string utf8_enable_save = cvar_string("utf8_enable");
	cvar_set("utf8_enable", "0");
	string output = "";
	FOREACH_CHAR(input, true,
	{
		output = strcat(output, chr2str(qfont_table[it]));
	});
	cvar_set("utf8_enable", utf8_enable_save);
	return output;
}

float autocvar_sv_quake_message_range = 512;
float autocvar_sv_quake_message_range_retrigger = 32;
void centerprint_proximity(entity player, string input, entity source)
{
	centerprint(player, input); // always send to the player no matter what
	float mrange = autocvar_sv_quake_message_range;
	// if the original source will be triggered again, skip proximity messages
	if(source.wait > 0 && source.wait < 999)
	{
		mrange = autocvar_sv_quake_message_range_retrigger;
		if(mrange <= 0)
			return;
	}
	FOREACH_CLIENT(IS_PLAYER(it) && IS_REAL_CLIENT(it) && it != player && vdist(it.origin - player.origin, <=, mrange),
	{
		centerprint(it, input);
	});
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If this.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any this.message to the activator.

Removes all entities with a targetname that match this.killtarget,
and removes them, so some events can remove other triggers.

Search for(string)targetname in all entities that
match(string)this.target and call their .use function

==============================
*/
void SUB_UseTargets_Ex(entity this, entity actor, entity trigger, int skiptargets, bool nomessage)
{
//
// check for a delay
//
	if(this.delay)
	{
	// create a temp object to fire at a later time
		entity t = new_pure(DelayedUse);
		t.nextthink = time + this.delay;
		setthink(t, DelayThink);
		t.enemy = actor;
		if(!nomessage)
			t.message = this.message;
		t.killtarget = this.killtarget;
		if(!(skiptargets & BIT(1))) t.target = this.target;
		if(!(skiptargets & BIT(2))) t.target2 = this.target2;
		if(!(skiptargets & BIT(3))) t.target3 = this.target3;
		if(!(skiptargets & BIT(4))) t.target4 = this.target4;
		t.use = func_null;
		return;
	}
	
	
//
// print the message
//
	if(!nomessage && IS_PLAYER(actor) && this.message != "")
	if(IS_REAL_CLIENT(actor))
	{
		centerprint_proximity(actor, process_string(this.message), this);
		if(!this.noise || this.noise == "")
			_sound(actor, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
		else
			_sound(actor, CH_INFO, this.noise, 1, ATTN_NORM);

		if(actor.m_champion && actor.m_champion.m_triggermessage)
			actor.m_champion.m_triggermessage(actor.m_champion, actor, this);
	}

//
// kill the killtagets
//

	string s;
	s = this.killtarget;
	if(s && s != "")
	{
		for(entity t = NULL; (t = find(t, targetname, s)); )
		{
			//if(t.trigger_field)
				//delete(t.trigger_field);
			delete(t);
		}
	}
	
//
// fire targets
//

	if(this.target_random)
		RandomSelection_Init();

	for(int i = 0; i < 4; ++i)
	{
		if(skiptargets & BIT(i + 1))
			continue;
		switch(i)
		{
			default:
			case 0: s = this.target; break;
			case 1: s = this.target2; break;
			case 2: s = this.target3; break;
			case 3: s = this.target4; break;
		}
		if(s != "")
		{
			for(entity t = NULL; (t = find(t, targetname, s)); )
			{
				if(t != this && t.use)
				{
					if(this.target_random)
						RandomSelection_AddEnt(t, 1, 0);
					else
						t.use(t, actor, this);
				}
			}
		}
	}

	if(this.target_random && RandomSelection_chosen_ent)
		RandomSelection_chosen_ent.use(RandomSelection_chosen_ent, actor, this);
}

void SUB_UseTargets(entity this, entity actor, entity trigger) { SUB_UseTargets_Ex(this, actor, trigger, 0, false); }
void SUB_UseTargetsSilent(entity this, entity actor, entity trigger) { SUB_UseTargets_Ex(this, actor, trigger, 0, true); }

bool SUB_UseTargets_CopperAlt(entity this, entity actor, entity trigger, int skiptargets)
{
	if(!(this.spawnflags & SPAWN_ALT_TARG))
		return false;
	SUB_UseTargets_Ex(this, actor, trigger, skiptargets, false);
	return true;
}

/*
================
SUB_SwitchTargets
================
*/

void SUB_SwitchTargets(.string field, string oldtarget, string newtarget)
{
	FOREACH_ENTITY_STRING(targetname, oldtarget,
	{
		it.(field) = newtarget;
	});
}

/*
================
SUB_SetWorldType
================
*/

void SUB_SetWorldtype(entity this)
{
	if(this.worldtype)
		this.worldtype--;
	else
		this.worldtype = world.worldtype;
}

#endif

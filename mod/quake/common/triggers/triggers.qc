#include "triggers.qh"

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

#ifdef SVQC
void generic_setactive(entity this, int act)
{
	if(act == ACTIVE_TOGGLE)
	{
		if(this.active == ACTIVE_ACTIVE)
		{
			this.active = ACTIVE_NOT;
		}
		else
		{
			this.active = ACTIVE_ACTIVE;
		}
	}
	else
	{
		this.active = act;
	}
}

void generic_netlinked_setactive(entity this, int act)
{
	int old_status = this.active;
	generic_setactive(this, act);

	if (this.active != old_status)
	{
		this.SendFlags |= SF_TRIGGER_UPDATE;
	}
}

void generic_netlinked_reset(entity this)
{
	if(this.targetname && this.targetname != "")
	{
		if(this.spawnflags & START_ENABLED)
		{
			this.active = ACTIVE_ACTIVE;
		}
		else
		{
			this.active = ACTIVE_NOT;
		}
	}
	else
	{
		this.active = ACTIVE_ACTIVE;
	}

	this.SendFlags |= SF_TRIGGER_UPDATE;
}

// Compatibility with old maps
void generic_netlinked_legacy_use(entity this, entity actor, entity trigger)
{
	//LOG_WARNF("Entity %s was (de)activated by a trigger, please update map to use relays", this.targetname);
	generic_netlinked_setactive(this, ACTIVE_TOGGLE);
}

void trigger_link(entity this, bool(entity this, entity to, int sendflags) sendfunc)
{
	setSendEntity(this, sendfunc);
	this.SendFlags = 0xFFFFFF;
}

void trigger_common_write(entity this, bool withtarget)
{
	int f = 0;
	//if(this.warpzone_isboxy)
	//	BITSET_ASSIGN(f, 1);
	if(this.origin != '0 0 0')
		BITSET_ASSIGN(f, 4);
	if(this.movedir != '0 0 0')
		BITSET_ASSIGN(f, 8);
	if(this.angles != '0 0 0')
		BITSET_ASSIGN(f, 16);
	WriteByte(MSG_ENTITY, f);

	if(withtarget)
	{
		// probably some way to clean this up...
		int targbits = 0;
		if(this.target && this.target != "") targbits |= BIT(0);
		if(this.target2 && this.target2 != "") targbits |= BIT(1);
		if(this.target3 && this.target3 != "") targbits |= BIT(2);
		if(this.target4 && this.target4 != "") targbits |= BIT(3);
		if(this.targetname && this.targetname != "") targbits |= BIT(4);
		if(this.killtarget && this.killtarget != "") targbits |= BIT(5);

		WriteByte(MSG_ENTITY, targbits);

		if(targbits & BIT(0))
			WriteString(MSG_ENTITY, this.target);
		if(targbits & BIT(1))
			WriteString(MSG_ENTITY, this.target2);
		if(targbits & BIT(2))
			WriteString(MSG_ENTITY, this.target3);
		if(targbits & BIT(3))
			WriteString(MSG_ENTITY, this.target4);
		if(targbits & BIT(4))
			WriteString(MSG_ENTITY, this.targetname);
		if(targbits & BIT(5))
			WriteString(MSG_ENTITY, this.killtarget);
	}

	if(f & 4)
		WriteVector(MSG_ENTITY, this.origin);

	if(f & 8)
		WriteVector(MSG_ENTITY, this.movedir);

	if(f & 16)
		WriteVector(MSG_ENTITY, this.angles);

	WriteShort(MSG_ENTITY, this.modelindex);
	WriteVector(MSG_ENTITY, this.mins);
	WriteVector(MSG_ENTITY, this.maxs);
	WriteByte(MSG_ENTITY, bound(1, this.scale * 16, 255));
}

#elif defined(CSQC)

void trigger_common_read(entity this, bool withtarget)
{
	int f = ReadByte();
	//this.warpzone_isboxy = (f & 1);

	if(withtarget)
	{
		strfree(this.target);
		strfree(this.target2);
		strfree(this.target3);
		strfree(this.target4);
		strfree(this.targetname);
		strfree(this.killtarget);

		int targbits = ReadByte();

		this.target = ((targbits & BIT(0)) ? strzone(ReadString()) : string_null);
		this.target2 = ((targbits & BIT(1)) ? strzone(ReadString()) : string_null);
		this.target3 = ((targbits & BIT(2)) ? strzone(ReadString()) : string_null);
		this.target4 = ((targbits & BIT(3)) ? strzone(ReadString()) : string_null);
		this.targetname = ((targbits & BIT(4)) ? strzone(ReadString()) : string_null);
		this.killtarget = ((targbits & BIT(5)) ? strzone(ReadString()) : string_null);
	}

	if(f & 4)
		this.origin = ReadVector();
	else
		this.origin = '0 0 0';
	setorigin(this, this.origin);

	if(f & 8)
		this.movedir = ReadVector();
	else
		this.movedir = '0 0 0';

	if(f & 16)
		this.angles = ReadVector();
	else
		this.angles = '0 0 0';

	this.modelindex = ReadShort();
	if (this.modelindex)
		setmodelindex(this, this.modelindex);
	this.mins = ReadVector();
	this.maxs = ReadVector();
	this.scale = ReadByte() / 16;
	setsize(this, this.mins, this.maxs);
}

void trigger_remove_generic(entity this)
{
	strfree(this.target);
	strfree(this.target2);
	strfree(this.target3);
	strfree(this.target4);
	strfree(this.targetname);
	strfree(this.killtarget);
}
#endif

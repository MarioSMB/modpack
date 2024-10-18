#include "fog.qh"

#ifdef SVQC
const int FORCE_SET_FOG = 1;

void stuffcmd_digit(entity this, float f)
{
	float d;
	d = floor(f);
	d = (d % 10);

	if(d == 0)
		stuffcmd(this, "0");
	else if(d == 1)
		stuffcmd(this, "1");
	else if(d == 2)
		stuffcmd(this, "2");
	else if(d == 3)
		stuffcmd(this, "3");
	else if(d == 4)
		stuffcmd(this, "4");
	else if(d == 5)
		stuffcmd(this, "5");
	else if(d == 6)
		stuffcmd(this, "6");
	else if(d == 7)
		stuffcmd(this, "7");
	else if(d == 8)
		stuffcmd(this, "8");
	else if(d == 9)
		stuffcmd(this, "9");	
}

void stuffcmd_int(entity this, float f, float numdigits)
{
	float tmp;

	if(f == 0)
	{
		stuffcmd(this, "0");
		return;
	}

	if(f < 0)
	{
		// Yeah sure.
		stuffcmd(this, "-");
		f = fabs(f);
	}
	
	if(numdigits <= 0)
	{
		tmp = f;
		numdigits = 1;
		while(tmp >= 1)
		{
			tmp = tmp / 10;
			numdigits = numdigits * 10;
		}
	}
	//I need to do this to get zero-padding to work.

	while(numdigits > 1)
	{
		numdigits = numdigits / 10;
		tmp = f / numdigits;
		stuffcmd_digit(this, tmp);
	}
}

void stuffcmd_float(entity client, float f)
{
	bool isNegative = false;
	
	if(f == 0)
	{
		stuffcmd( client, "0");
		return;
	}
	
	if(f < 0)
	{
		// easier this way
		isNegative = true;
		f = fabs(f);
	}

    // 1: stuff the sign.
	if(isNegative) 
    stuffcmd( client, "-");

    // 2: stuff the integer part.
	int intpart = floor(f);
	stuffcmd_int( client, intpart, 0);

	// 3: stuff the decimal point.
	stuffcmd( client, ".");

	// 4: stuff the decimal part.
	float decpart = (f % 1);
	decpart = decpart * 10000;
	stuffcmd_int( client, decpart, 10000);
}

void SetFog(entity client, float density, vector thecolor, float transitionTime)
{
	client.fog_density = density;
	client.fog_color = thecolor;
	stuffcmd(client, "\nfog ");
	stuffcmd_float(client, density);
	stuffcmd(client, " ");
	stuffcmd_float(client, thecolor.x);
	stuffcmd(client, " ");
	stuffcmd_float(client, thecolor.y);
	stuffcmd(client, " ");
	stuffcmd_float(client, thecolor.z);
	if(transitionTime > 0)
	{
		stuffcmd(client, " ");
		stuffcmd_float(client, transitionTime);
	}
	stuffcmd(client, "\n");
}	

entity GetFogInfoEntity(entity e, .string field)
{
	if(e.field)
	{
		e = find(NULL, targetname, e.(field));
		if(e.classname == "info_fog")
		{
			return e;
		}
	}
	return NULL;
}

bool FogPushSettingsFrom(entity client, entity source, float transitionTime)
{
	if(!IS_PLAYER(client) || !IS_REAL_CLIENT(client))
		return false;
	source = GetFogInfoEntity(source, fog_info_entity);
	if(!source)
		return false;
	if(source.fog_density || source.fog_color || (source.spawnflags & FORCE_SET_FOG))
	{
		SetFog(client, source.fog_density, source.fog_color, transitionTime);
		return true;
	}
	return false;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

/*QUAKED info_fog (0.5 .5 .8) (-8 -8 -8) (8 8 8)
Fog value definition
wait: fog density
dest: fog color
*/

spawnfunc(info_fog)
{
	if(!this.fog_density)
		this.fog_density = 0.05;
	else if(this.fog_color_x > 1.0 || this.fog_color_y > 1.0 || this.fog_color_z > 1.0) //Not in 0..1 range?
		this.fog_color = this.fog_color * (1.0 / 255);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

void trigger_fog_activate(entity this, entity actor, entity trigger)
{
    if(this == actor.fog_active_fog_trigger)
    	return;
	if(!IS_PLAYER(actor)) // Yoder add, 27/09/2020 to fix crash
		return;
	actor.fog_active_fog_trigger = this;
	FogPushSettingsFrom(actor, this, this.delay);
}

void trigger_fog_activate_touch(entity this, entity toucher)
{
	trigger_fog_activate(this, toucher, this);
}

/*QUAKED trigger_fog (0.5 .5 .8) (? ? ?) (? ? ?)
Trigger to transition fog
fog_info_entity: info_fog that contains values this trigger should use.
delay: time to fade the transition over
*/
spawnfunc(trigger_fog)
{
	// Fog is set on the server, so transitions and triggers work really bad in multiplayer. 
	// Just remove ourself if we're in multiplayer.
	if(coop || deathmatch) 
	{
		delete(this);
		return;
	}

	if(!this.delay)
		this.delay = 0.5;	
	this.use = trigger_fog_activate;
	if (!(this.spawnflags & SPAWNFLAG_NOTOUCH))
		settouch(this, trigger_fog_activate_touch);
	InitTrigger(this);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////

float trigger_fog_transition_touch_get_tween(entity this, entity pl)
{
	vector t = pl.origin - this.mins;
	vector b = this.size;
	float tween = 0;

	if(this.style == 0)
		tween = t_x / b_x;
	else if(this.style == 1)
		tween = t_y / b_y;
	else if(this.style == 2)
		tween = t_z / b_z;

	if(tween < 0)
		tween = 0;
	if(tween > 1)
		tween = 1;

	return tween;
}

void trigger_fog_transition_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	
	float tween = trigger_fog_transition_touch_get_tween(this, toucher);
	
	entity fog1 = GetFogInfoEntity(this, fog_info_entity);
	entity fog2 = GetFogInfoEntity(this, target);

	float density = ((1 - tween) * fog1.fog_density) + (tween * fog2.fog_density);
	vector thecolor = ((1 - tween) * fog1.fog_color) + (tween * fog2.fog_color);

	SetFog(toucher, density, thecolor, 0);
}

/*QUAKED trigger_fog_transition (0.5 .5 .8) (? ? ?) (? ? ?)
Trigger to transition fog between two sides.
fog_info_entity: info_fog that contains values this trigger should use on the 'left' side.
target: info_fog that contains values this trigger should use on the 'right' side.
style: Which axis this trigger fades across. 0 = X, 1 = Y, 2 = Z
*/
spawnfunc(trigger_fog_transition)
{
	// Fog is set on the server, so transitions and triggers work really bad in multiplayer. 
	// Just remove ourself if we're in multiplayer.
	if(coop || deathmatch) 
	{
		delete(this);
		return;
	}

	if(this.style < 0 || this.style > 2)
	{
		objerror(this, "Invalid style for trigger_fog_transition. Needs to be 0, 1 or 2.");
		return;
	}
	settouch(this, trigger_fog_transition_touch);
    InitTrigger(this);
}
#endif

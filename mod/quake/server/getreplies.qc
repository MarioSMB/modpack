#include "getreplies.qh"

// =========================================================
//  Reply messages for common commands, re-worked by Samual
//  Last updated: December 30th, 2011
// =========================================================

// These strings are set usually during init in world.qc,
// or also by some game modes or other functions manually,
// and their purpose is to output information to clients
// without using any extra processing time.

// See common.qc for their proper commands

/*
=============
GetCvars
=============
Superseded by REPLICATE
Called with:
  0:  sends the request
  >0: receives a cvar from name=argv(f) value=argv(f+1)
*/
void GetCvars_handleString(entity this, entity store, string thisname, float f, .string field, string name)
{
	if (f < 0)
	{
		strfree(store.(field));
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			strcpy(store.(field), argv(f + 1));
		}
	}
	else
		stuffcmd(this, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleString_Fixup(entity this, entity store, string thisname, float f, .string field, string name, string(entity, string) func)
{
	GetCvars_handleString(this, store, thisname, f, field, name);
	if (f >= 0) // also initialize to the fitting value for "" when sending cvars out
		if (thisname == name)
		{
			string s = func(this, strcat1(store.(field)));
			if (s != store.(field))
			{
				strcpy(store.(field), s);
			}
		}
}
void GetCvars_handleFloat(entity this, entity store, string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
			store.(field) = stof(argv(f + 1));
	}
	else
		stuffcmd(this, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleFloatOnce(entity this, entity store, string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if (!store.(field))
			{
				store.(field) = stof(argv(f + 1));
				if (!store.(field))
					store.(field) = -1;
			}
		}
	}
	else
	{
		if (!store.(field))
			stuffcmd(this, strcat("cl_cmd sendcvar ", name, "\n"));
	}
}

/**
 * @param f -1: cleanup, 0: request, 1: receive
 */
void GetCvars(entity this, entity store, int f)
{
	string s = string_null;

	if (f == 0)
		LOG_INFO("Warning: requesting cvar values is deprecated. Client should send them automatically using REPLICATE.\n");

	if (f > 0)
		s = strcat1(argv(f));

	Notification_GetCvars(this, store, s, f);

	ReplicateVars(this, store, s, f);
	if (f > 0)
		ReplicateVars_ApplyChange(this, store, s, f);
}

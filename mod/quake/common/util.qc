#include "util.qh"

#ifdef GAMEQC
int Mod_Q1BSP_SuperContentsFromNativeContents(int nativecontents)
{
	switch(nativecontents)
	{
		case CONTENT_EMPTY:
			return 0;
		case CONTENT_SOLID:
			return DPCONTENTS_SOLID | DPCONTENTS_OPAQUE;
		case CONTENT_WATER:
			return DPCONTENTS_WATER;
		case CONTENT_SLIME:
			return DPCONTENTS_SLIME;
		case CONTENT_LAVA:
			return DPCONTENTS_LAVA | DPCONTENTS_NODROP;
		case CONTENT_SKY:
			return DPCONTENTS_SKY | DPCONTENTS_NODROP | DPCONTENTS_OPAQUE; // to match behaviour of Q3 maps, let sky count as opaque
	}
	return 0;
}

int Mod_Q1BSP_NativeContentsFromSuperContents(int supercontents)
{
	if(supercontents & (DPCONTENTS_SOLID | DPCONTENTS_BODY))
		return CONTENT_SOLID;
	if(supercontents & DPCONTENTS_SKY)
		return CONTENT_SKY;
	if(supercontents & DPCONTENTS_LAVA)
		return CONTENT_LAVA;
	if(supercontents & DPCONTENTS_SLIME)
		return CONTENT_SLIME;
	if(supercontents & DPCONTENTS_WATER)
		return CONTENT_WATER;
	return CONTENT_EMPTY;
}
#endif

float cvar_settemp(string tmp_cvar, string tmp_value)
{
	float created_saved_value;

	created_saved_value = 0;

	if (!(tmp_cvar || tmp_value))
	{
		LOG_TRACE("Error: Invalid usage of cvar_settemp(string, string); !");
		return 0;
	}

	if(!cvar_type(tmp_cvar))
	{
		LOG_INFOF("Error: cvar %s doesn't exist!\n", tmp_cvar);
		return 0;
	}

	IL_EACH(g_saved_cvars, it.netname == tmp_cvar,
	{
		created_saved_value = -1; // skip creation
		break; // no need to continue
	});

	if(created_saved_value != -1)
	{
		// creating a new entity to keep track of this cvar
		entity e = new_pure(saved_cvar_value);
		IL_PUSH(g_saved_cvars, e);
		e.netname = strzone(tmp_cvar);
		e.message = strzone(cvar_string(tmp_cvar));
		created_saved_value = 1;
	}

	// update the cvar to the value given
	cvar_set(tmp_cvar, tmp_value);

	return created_saved_value;
}

int cvar_settemp_restore()
{
	int j = 0;
	// FIXME this new-style loop fails!
#if 0
	FOREACH_ENTITY_CLASS("saved_cvar_value", true,
	{
		if(cvar_type(it.netname))
		{
			cvar_set(it.netname, it.message);
			strunzone(it.netname);
			strunzone(it.message);
			delete(it);
			++j;
		}
		else
			LOG_INFOF("Error: cvar %s doesn't exist anymore! It can still be restored once it's manually recreated.\n", it.netname);
	});

#else
	entity e = NULL;
	while((e = find(e, classname, "saved_cvar_value")))
	{
		if(cvar_type(e.netname))
		{
			cvar_set(e.netname, e.message);
			delete(e);
			++j;
		}
		else
			print(sprintf("Error: cvar %s doesn't exist anymore! It can still be restored once it's manually recreated.\n", e.netname));
	}
#endif

	return j;
}

float shutdown_running;
#ifdef SVQC
void SV_Shutdown()
#endif
#ifdef CSQC
void CSQC_Shutdown()
#endif
#ifdef MENUQC
void m_shutdown()
#endif
{
	if(shutdown_running)
	{
		LOG_INFO("Recursive shutdown detected! Only restoring cvars...\n");
	}
	else
	{
		shutdown_running = 1;
		//Shutdown();
		shutdownhooks();
	}
	cvar_settemp_restore(); // this must be done LAST, but in any case
}

#include "editor.qh"

#ifdef SVQC

// This must be called in SV_ParseClientCommand
// input entity this
// input string cmd: same as in SV_ParseClientCommand
// output bool: true if command was handled, false if not
bool sv_editor_command(entity this, string cmd, float argc)
{
	switch(cmd)
	{
		case "editor":
		{
			sprint(this, "You found something!\n");
			return true;
		}
	}
	return false;
}
#endif

#ifdef CSQC
void editor_draw()
{

}

STATIC_INIT_LATE(editor_init)
{
	localcmd("\nalias editor \"cmd editor ${* ?}\"\n");
}
#endif

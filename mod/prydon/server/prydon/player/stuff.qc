#include "stuff.qh"

void h_stuff(entity this)
{
	if(this.fadetime < time)
	{
		if(this.fade > 0)
		{
			stuffcmd(this, sprintf("v_cshift 0 0 0 %d\n", this.fade));
			
			this.fade = this.fade - 10;
			this.fadetime = time + 0.1;
		}
		else if(this.fade < 0)
		{
			stuffcmd(this, sprintf("v_cshift 0 0 0 %d\n", this.fade + 245));
			
			this.fade = this.fade + 10;
			this.fadetime = time + 0.1;
			if(this.fade == 0)
			{
				if(nextmap)
					changelevel(nextmap);
				else
					this.fade = 250; // fade back in
			}
		}
		else
		{
			this.fade = 0;
			this.fadetime = 0;
		}
	}
	if(this.gotstuff && this.gotstuff < time)
	{
		if(music)
			_sound(NULL, CH_BGM_SINGLE, music, 1, ATTN_NONE);
		if(lastmap == 1)
			this.fade = 250;
		else
			stuffcmd(this, "v_cshift 0 0 0 0\n");
		this.gotstuff = 0;
		if(fileaccess)
		{
			if(this.sounds && mplayer)
				GetParms(this, saveversion);
			this.sounds = 0;
		}
	}
}

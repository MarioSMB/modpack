#include "skins.qh"

void updateskins(entity this)
{
	if(this.misc & MISC_FULL_SKINS)
	{
		// fix me, hard coded hackage
		if(this.cold_time > time)
			this.skin = this.oldskin;
		else if(this.poison_count > 0 )
			this.skin = this.oldskin + 7;
		else
			this.skin = this.oldskin + 14;
	}
	else if(this.misc & MISC_NO_SKINS)
		this.skin = this.oldskin;
	else if(this.cold_time > time)
		this.skin = 0;
	else if(this.poison_count > 0 )
		this.skin = 1;
	else
		this.skin = 2 + this.oldskin;
}

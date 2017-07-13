bool autocvar_hud_contents;
float autocvar_hud_contents_fadeintime;
float autocvar_hud_contents_fadeouttime;
float autocvar_hud_contents_lava_alpha;
string autocvar_hud_contents_lava_color;
float autocvar_hud_contents_slime_alpha;
string autocvar_hud_contents_slime_color;
float autocvar_hud_contents_water_alpha;
string autocvar_hud_contents_water_color;

float contentavgalpha, liquidalpha_prev;
vector liquidcolor_prev;

void HUD_Contents()
{
	// improved polyblend
	if(autocvar_hud_contents)
	{
		float contentalpha_temp, incontent, liquidalpha, contentfadetime;
		vector liquidcolor;

		switch(pointcontents(getpropertyvec(VF_ORIGIN)))
		{
			case CONTENT_WATER:
				liquidalpha = autocvar_hud_contents_water_alpha;
				liquidcolor = stov(autocvar_hud_contents_water_color);
				incontent = 1;
				break;

			case CONTENT_LAVA:
				liquidalpha = autocvar_hud_contents_lava_alpha;
				liquidcolor = stov(autocvar_hud_contents_lava_color);
				incontent = 1;
				break;

			case CONTENT_SLIME:
				liquidalpha = autocvar_hud_contents_slime_alpha;
				liquidcolor = stov(autocvar_hud_contents_slime_color);
				incontent = 1;
				break;

			default:
				liquidalpha = 0;
				liquidcolor = '0 0 0';
				incontent = 0;
				break;
		}

		if(incontent) // fade in/out at different speeds so you can do e.g. instant fade when entering water and slow when leaving it.
		{ // also lets delcare previous values for blending properties, this way it isn't reset until after you have entered a different content
			contentfadetime = autocvar_hud_contents_fadeintime;
			liquidalpha_prev = liquidalpha;
			liquidcolor_prev = liquidcolor;
		}
		else
			contentfadetime = autocvar_hud_contents_fadeouttime;

		contentalpha_temp = bound(0, drawframetime / max(0.0001, contentfadetime), 1);
		contentavgalpha = contentavgalpha * (1 - contentalpha_temp) + incontent * contentalpha_temp;

		if(contentavgalpha)
			drawfill('0 0 0', vec2(autocvar_vid_conwidth, autocvar_vid_conheight), liquidcolor_prev, contentavgalpha * liquidalpha_prev, DRAWFLAG_NORMAL);
	}
}

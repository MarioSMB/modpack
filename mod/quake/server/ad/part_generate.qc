#include "part_generate.qh"

#include "part_manage.qh"

/*======================================================================
 Particle explosion
 
 e_org		: center of particle explosion
 e_qty		: quantity of particle burst
 e_time		: lifespan of particle (time + random()*time)
 p_style	: sprite style (check function particle_style above)
 e_style	: explosion style (pre-defined in part_manage.qc)
======================================================================*/
void particle_explode(vector e_org, float e_qty, float e_time, float p_style, float e_style)
{
	// Can only have integer particle quantity
	e_qty = rint(e_qty);

	// DP hammer impact, 1=regular 2=shockwave
	if(e_style & PARTICLE_BURST_SHOCKWAVE)
	{
		if(e_style & 1)
			Send_Effect(EFFECT_DPP_BURSTSHOCKWAVE1, e_org, '0 0 0', 1);
		else
			Send_Effect(EFFECT_DPP_BURSTSHOCKWAVE1, e_org, '0 0 0', 1);
	}
	else
	{
		// Setup DP particle style based on supplied style
		entity dpp_string;
		if(p_style & PARTICLE_BURST_YELLOW) dpp_string = EFFECT_DPP_BURSTPARTY;
		else if(p_style & PARTICLE_BURST_GREEN) dpp_string = EFFECT_DPP_BURSTPARTG;
		else if(p_style & PARTICLE_BURST_RED) dpp_string = EFFECT_DPP_BURSTPARTR;
		else if(p_style & PARTICLE_BURST_BLUE) dpp_string = EFFECT_DPP_BURSTPARTB;
		else if(p_style & PARTICLE_BURST_PURPLE) dpp_string = EFFECT_DPP_BURSTPARTP;
		else dpp_string = EFFECT_DPP_BURSTPARTW;
		Send_Effect(dpp_string, e_org, '0 0 0', e_qty);
	}
}

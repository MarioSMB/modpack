#include "bigjohn.qh"

#ifdef SVQC
METHOD(BigJohn, m_activate, void(BigJohn this, entity actor))
{
	player_sound(actor, CH_VOICE, ((random() < 0.5) ? "bigjabl1.wav" : "bigjabl2.wav"), ATTN_NORM);
}

METHOD(BigJohn, m_playerthink, void(BigJohn this, entity actor))
{
	actor.armorvalue = min(actor.armorvalue, 50); 
}
#endif

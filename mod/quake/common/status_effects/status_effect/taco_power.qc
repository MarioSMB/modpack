#include "inked.qh"

#ifdef SVQC
METHOD(TacoPower, m_tick, void(StatusEffects this, entity actor))
{
	SUPER(TacoPower).m_tick(this, actor);
}
#endif

#ifdef CSQC
PRECACHE(TacoPower_effect)
{
	precache_pic("gfx/quake/inv_taco");
}

const int MAX_TACO = 15;
vector taco_slots[MAX_TACO];
float taco_time[MAX_TACO];
const float TACO_SPEED = 250;
const float TACO_TURNSPEED = 2;
const float TACO_SIZE = 0.075;
const float TACO_CHANCE = 0.35;
float tacos_spawntime;
void TacoDisplay()
{
	for(int j = MAX_TACO - 1; j >= 0; --j)
	{
		vector slot = taco_slots[j];
		if(slot.y)
			slot.y -= TACO_SPEED * frametime;
		if(slot.x)
			slot.x += cos(TACO_TURNSPEED * M_PI * time);
		//slot.x += slot.z * TACO_SPEED * frametime;

		if(slot.y <= 0 || time >= taco_time[j])
			slot = '0 0 0';

		if(slot == '0 0 0')
		{
			if(random() <= TACO_CHANCE && time > tacos_spawntime) // low chance to spawn!
			{
				slot.x = bound(vid_conwidth * 0.01, (random() * vid_conwidth), vid_conwidth * 0.99);
				slot.y = vid_conheight * 0.99; // start it off 0 so we can use it
				slot.z = random() * 360;
				taco_time[j] = time + max(0.5, random() * 2);
				tacos_spawntime = time + max(0.1, random() * 0.75); // prevent spawning another one for this amount of time!
			}
		}
		else
		{
			vector splash_size = '0 0 0';
			splash_size.x = max(vid_conwidth, vid_conheight) * TACO_SIZE;
			splash_size.y = max(vid_conwidth, vid_conheight) * TACO_SIZE;
			drawpic_aspect(vec2(slot), "gfx/quake/inv_taco", vec2(splash_size), '1 1 1', 0.95, DRAWFLAG_NORMAL);
			//drawrotpic(vec2(slot), slot.z, "gfx/quake/inv_taco", vec2(splash_size), vec2(splash_size) * 0.5, '1 1 1', 0.95, DRAWFLAG_NORMAL);
		}

		taco_slots[j] = slot;
	}
}

METHOD(TacoPower, m_tick, void(StatusEffects this, entity actor))
{
	TacoDisplay();
	SUPER(TacoPower).m_tick(this, actor);
}
#endif

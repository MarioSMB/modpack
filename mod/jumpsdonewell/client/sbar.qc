PRECACHE(hud_icons)
{
	precache_pic("textures/emptyheart");
	precache_pic("textures/fullheart");

	precache_pic("textures/emptyfeather");
	precache_pic("textures/fullfeather");

	precache_pic("textures/glowingsword");
	precache_pic("textures/fullsword");
}

void draw_health()
{
	float num_hearts = min(STAT(HEALTH), 100);
	float max_hearts = min(STAT(MAXHEALTH), 100);

	float size = 32;
	float xpos = vid_conwidth - size;
	float ypos = 0;
	for(int j = 0; j < max_hearts; j++)
	{
		drawpic(vec3(xpos, ypos, 0), "textures/emptyheart", vec2(size, size), '1 1 1', 0.8, DRAWFLAG_NORMAL);
		float offset = (j > 10) ? 0.1 : 1;
		xpos -= size * offset;
	}
	vector col = '1 1 1';
	float alpha = 0.8;
	xpos = vid_conwidth - size;
	for(int j = 0; j < num_hearts; j++)
	{
		if(num_hearts == 1)
		{
			col = '0.5 0.5 0.5';
			alpha = 0.5 * sin(j * 1.5 + time * 5) + 0.75;
		}
		drawpic(vec3(xpos, ypos, 0), "textures/fullheart", vec2(size, size), col, alpha, DRAWFLAG_NORMAL);
		float offset = (j > 10) ? 0.1 : 1;
		xpos -= size * offset;
	}
}

float old_jumps;
float jump_time;
void draw_feathers()
{
	int num_jumps = min(STAT(JUMPS), 100);
	int max_jumps = min(STAT(FEATHER), 100);

	float size = 32;
	float xpos = vid_conwidth - size;
	float ypos = 32;
	for(int j = 0; j < max_jumps - 1; j++)
	{
		drawpic(vec3(xpos, ypos, 0), "textures/emptyfeather", vec2(size, size), '1 1 1', 0.8, DRAWFLAG_NORMAL);
		float offset = (j > 10) ? 0.1 : 0.5;
		xpos -= size * offset;
	}
	vector col = '1 1 1';
	float alpha = 0.8;
	xpos = vid_conwidth - size;
	int count = (num_jumps == max_jumps) ? num_jumps - 1 : num_jumps;
	for(int j = 0; j < count; j++)
	{
		drawpic(vec3(xpos, ypos, 0), "textures/fullfeather", vec2(size, size), col, alpha, DRAWFLAG_NORMAL);
		float offset = (j > 10) ? 0.1 : 0.5;
		xpos -= size * offset;
	}
	if(jump_time > 0)
	{
		drawpic(vec3(xpos, ypos, 0), "textures/fullfeather", vec2(size, size), col, 0.8 * jump_time, DRAWFLAG_NORMAL);
		jump_time -= frametime * 7;
	}
	if(old_jumps > num_jumps && old_jumps != max_jumps)
		jump_time = 1;
	old_jumps = num_jumps;
}

void draw_sword()
{
	int sword_power = STAT(SWORDPOWER);
	if(sword_power == 0)
		return;

	float size = 32;
	float xpos = vid_conwidth - size;
	float ypos = 64;
	string img = (sword_power > 1) ? "textures/glowingsword" : "textures/fullsword";
	drawpic(vec3(xpos, ypos, 0), img, vec2(size, size * 2), '1 1 1', 0.8, DRAWFLAG_NORMAL);
	float charged = STAT(CHARGED);
	if(charged)
		drawpic(vec3(xpos, ypos, 0), img, vec2(size, size * 2), '1 1 1', 0.5 * sin(time * 5), DRAWFLAG_NORMAL);
}

void draw_ends()
{
	if(end_time > 0)
	{
		string line1 = "Congratulations!";
		string line2 = (which_end == 1) ? "But you haven't found" : "You found the...";
		string line3 = (which_end == 1) ? "many hearts..." : "TRUE ENDING!!";
		
		drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '0 0 0', sin(end_time * 0.4), DRAWFLAG_NORMAL);
		float size = 16;
		float xpos = (vid_conwidth / 2) - size * strlen(line1) * 0.5;
		float ypos = 64;
		drawstring(vec3(xpos, ypos, 0), line1, vec2(size, size), '1 1 1', min(1, end_time), DRAWFLAG_NORMAL);
		xpos = (vid_conwidth / 2) - size * strlen(line2) * 0.5;
		ypos += 64;
		drawstring(vec3(xpos, ypos, 0), line2, vec2(size, size), '1 1 1', min(1, end_time), DRAWFLAG_NORMAL);
		xpos = (vid_conwidth / 2) - size * strlen(line3) * 0.5;
		ypos += 32;
		drawstring(vec3(xpos, ypos, 0), line3, vec2(size, size), '1 1 1', min(1, end_time), DRAWFLAG_NORMAL);
		end_time -= frametime;
	}
}

void draw_hud()
{
	draw_health();
	draw_feathers();
	draw_sword();
	draw_ends();
	
	if(center_time > 0)
	{
		float size = 16;
		float xpos = (vid_conwidth / 2) - size * strlen(centerprint_msg) * 0.5;
		float ypos = 96;
		drawstring(vec3(xpos, ypos, 0), centerprint_msg, vec2(size, size), '1 1 1', min(center_time, 1), DRAWFLAG_NORMAL);
		center_time -= frametime;
	}
}

int old_count;
float change_time;
void draw_hud(int w, int h)
{
	int combo_count = STAT(COMBO_COUNT);
	float combo_timer = STAT(COMBO_TIMER);
	float combo_timer_max = STAT(COMBO_TIMER_MAX);
	float diamond = STAT(COMBO_MAX);
	float gold = STAT(GOLD);
	float silver = STAT(SILVER);
	
	if(old_count < combo_count)
		change_time = time + 1;

	float size = 32;
	float margin = 32;
	string combonum = sprintf("%.0f", combo_count);
	vector color = '0.3 0.3 0.4';
	if(combo_count > 0)
		color = '1 1 1';
	drawstring(vec2(w - size * strlen(combonum) * 0.5 - margin - size, margin), combonum, vec2(size, size), color, 1, 0);
	
	string combolabel = "Combo";
	drawstring(vec2(w - size - margin - strlen(combolabel) * 4, margin - 10), combolabel, '8 8 0', '0.8 0.9 1', 0.9, 0);
	
	float frac = (combo_timer - time) / combo_timer_max;
	float width = size * frac * 3;
	drawpic(vec2(w - width * 0.5 - size - margin, margin + size + 2), "textures/pointflare", vec2(width, 4), '0.7 0.85 1', min(1, frac * 2), 0);
	if(frac > 0.5)
		drawpic(vec2(w - width * 0.5 - size - margin, margin + size + 2), "textures/pointflare", vec2(width, 4), '0.8 0.9 1', min(1, (frac - 0.5) * 2), 1);
	
	float highlight = max(change_time - time, 0);
	float highlightsize = 200 * highlight;
	drawpic(vec2(w - size - margin - highlightsize * 0.5, margin + size * 0.5 - highlightsize * 0.5), "textures/pointflare", vec2(highlightsize, highlightsize), '0.7 0.85 1' * highlight, 0.8 * highlight, 1);
	
	float iconsize = 16;
	string number;
	float ypos = h - margin - 48;
	drawpic(vec2(w - margin - iconsize - 42, ypos), "textures/diamond.tga", vec2(iconsize, iconsize), '1 1 1', 1, 0);
	number = sprintf("%2.0f", diamond);
	drawstring(vec2(w - margin - 32, ypos), number, '16 16 0', '1 1 1', 0.7, 0);
	ypos += iconsize;
	drawpic(vec2(w - margin - iconsize - 42, ypos), "textures/gold.tga", vec2(iconsize, iconsize), '1 1 1', 1, 0);
	number = sprintf("%2.0f", gold);
	drawstring(vec2(w - margin - 32, ypos), number, '16 16 0', '1 1 1', 0.7, 0);
	ypos += iconsize;
	drawpic(vec2(w - margin - iconsize - 42, ypos), "textures/silver.tga", vec2(iconsize, iconsize), '1 1 1', 1, 0);
	number = sprintf("%2.0f", silver);
	drawstring(vec2(w - margin - 32, ypos), number, '16 16 0', '1 1 1', 0.7, 0);
	old_count = combo_count;

	if(the_score > 0)
	{
		string img = the_score == 1 ? "textures/bronze" :
			the_score == 2 ? "textures/silver" :
			the_score == 3 ? "textures/gold" :
			the_score == 4 ? "textures/diamond" : "textures/pointflare";
			
		string text = the_score == 1 ? "Bronze" :
			the_score == 2 ? "Silver" :
			the_score == 3 ? "Gold" :
			the_score == 4 ? "Diamond" : "";
			
		drawpic(vec2(w / 2 - 64, h / 2 - 64), img, '128 128 0', '1 1 1', 1, 0);
		drawstring(vec2(w / 2 - 16 * strlen(text), h/2), text, '32 32 0', '1 1 1', 1, 0);
	}
}

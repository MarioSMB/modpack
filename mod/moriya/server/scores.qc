#include "scores.qh"

STATIC_INIT_LATE(init_scores)
{
	read_scores();
}

void read_scores()
{
	float scorefile = fopen("scores.dat", FILE_READ);
	if(scorefile < 0)
	{
		LOG_INFO("Scores could not be read!");
		return; // uh oh
	}
	string line;
	int i = 0;
	line = fgets(scorefile);
	while(line && i < 16)
	{
		if (i < 8)
			moriya_scores[i] = stof(line);
		else
			mountain_scores[i - 8] = stof(line);
		i++;
		line = fgets(scorefile);
	}
}

void write_scores(float map, float ring, float score)
{
	if(map == 0)
		moriya_scores[ring] = score;
	if(map == 1 && score > mountain_scores[ring])
		mountain_scores[ring] = score;
		
	float scorefile = fopen("scores.dat", FILE_WRITE);
	if(scorefile < 0)
		return;
	for(int i = 0; i < 8; i++)
		fputs(scorefile, sprintf("%.0f\n", moriya_scores[i]));
	for(int i = 0; i < 8; i++)
		fputs(scorefile, sprintf("%.0f\n", mountain_scores[i]));
		
	fclose(scorefile);
}

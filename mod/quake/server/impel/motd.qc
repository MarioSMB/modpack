void impel_MOTD(entity this)
{
	if(!MP_IMPEL)
		return; // just incase

	if(world.model == "maps/aopstart.bsp" && this.motd_count < 8)
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm1.bsp" && this.motd_count < 8)
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm2.bsp" && (this.motd_count < 6))
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm3.bsp" && (this.motd_count < 5))
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm4.bsp" && (this.motd_count < 4))
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm5.bsp" && (this.motd_count < 4))
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	if(world.model == "maps/aopdm6.bsp" && (this.motd_count < 4))
	{
		this.motd_time = time + 1;
		this.motd_count = this.motd_count + 1;
		return;
	}
	this.motd_time = 0;
}

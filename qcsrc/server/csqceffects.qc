void te_csqc_lightningarc(vector from,vector to)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_LIGHTNINGARC);

	WriteCoord(MSG_BROADCAST, from_x);
	WriteCoord(MSG_BROADCAST, from_y);
	WriteCoord(MSG_BROADCAST, from_z);
	WriteCoord(MSG_BROADCAST, to_x);
	WriteCoord(MSG_BROADCAST, to_y);
	WriteCoord(MSG_BROADCAST, to_z);
}


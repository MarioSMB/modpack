REGISTER_MUTATOR(mod_hats, true);

#include "../common/hats.qh"

string get_model_parameters_bone_head;

class(Skeleton) .int bone_hat;
class(Skeleton) .vector hat_height;
class(Skeleton) .float hat_scale;

MUTATOR_HOOKFUNCTION(mod_hats, TagIndex_Apply)
{
	if(substring(self.model, 0, 12) == "models/hats/")
	{
		if(substring(self.tag_entity.model, 0, 12) == "models/hats/")
		{
			self.tag_index = gettagindex(self.tag_entity, "tag_head");
			if(!self.tag_index)
				self.tag_index = gettagindex(self.tag_entity, "head");
			if(!self.tag_index)
			{
				// we need to prevent this from 'appening
				self.tag_entity = world;
				self.drawmask = 0;
			}
		}
		else if(self.tag_entity.isplayermodel)
		{
			skeleton_loadinfo(self.tag_entity);
			self.tag_index = self.tag_entity.bone_hat;
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, ClearModelParams)
{
	get_model_parameters_bone_head = string_null;
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;
	get_model_parameters_hat_angles = '0 0 0';
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, GetModelParams)
{
	if(checkmodel_input == "bone_head")
		get_model_parameters_bone_head = checkmodel_command;
	if(checkmodel_input == "hat_height")
		get_model_parameters_hat_height = stov(checkmodel_command);
	if(checkmodel_input == "hat_scale")
		get_model_parameters_hat_scale = stof(checkmodel_command);
	if(checkmodel_input == "hat_angles")
		get_model_parameters_hat_angles = stov(checkmodel_command);
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckBones)
{
	self.bone_hat = gettagindex(self, "head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "tag_head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "bip01 head");
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckModel)
{
	if(get_model_parameters_bone_head)
		self.bone_hat = gettagindex(self, get_model_parameters_bone_head);
	return false;
}

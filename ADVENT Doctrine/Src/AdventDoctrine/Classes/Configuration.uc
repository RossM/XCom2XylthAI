class Configuration extends Object config(ImmersiveAI);

struct AIUnitConfigData
{
	var name DataName;
	var array<name> Jobs;
};

var config array<AIUnitConfigData> UnitConfig;

static function FindJobs(name DataName, out array<name> Jobs)
{
	local int index;

	index = default.UnitConfig.Find('DataName', DataName);
	if (index != INDEX_NONE)
	{
		Jobs = default.UnitConfig[index].Jobs;
	}
	else
	{
		Jobs.Length = 0;
	}
}
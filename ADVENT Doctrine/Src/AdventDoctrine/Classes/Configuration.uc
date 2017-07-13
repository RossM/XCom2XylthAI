class Configuration extends Object config(ImmersiveAI);

struct AIUnitConfigData
{
	var name DataName;
	var array<name> Jobs;
};

struct AIJobConfigData
{
	var name JobName;
	var int MoveOrderPriority;
};

var config array<AIUnitConfigData> UnitConfig;
var config array<AIJobConfigData> JobConfig;

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

static function bool FindJobConfig(name JobName, out AIJobConfigData Data)
{
	local int index;

	index = default.JobConfig.Find('JobName', JobName);
	if (Index == INDEX_NONE)
		return false;
	Data = default.JobConfig[index];
	return true;
}
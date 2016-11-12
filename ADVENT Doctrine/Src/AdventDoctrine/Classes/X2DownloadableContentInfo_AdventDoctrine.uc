class X2DownloadableContentInfo_AdventDoctrine extends X2DownloadableContentInfo config(ImmersiveAI);

var config array<string> ObsoleteAIRoots;
var config string NewAIRoot;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	local X2DataTemplate DataTemplate;
	local X2CharacterTemplate Template;
	local array<X2DataTemplate> DataTemplateAllDifficulties;
	local X2CharacterTemplateManager CharacterMgr;
	local array<name> TemplateNames;
	local name TemplateName;

	CharacterMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	CharacterMgr.GetTemplateNames(TemplateNames);
	foreach TemplateNames(TemplateName)
	{
		CharacterMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplateAllDifficulties);
		foreach DataTemplateAllDifficulties(DataTemplate)
		{
			Template = X2CharacterTemplate(DataTemplate);

			if (Template.bIsAdvent || Template.bIsAlien)
			{
				Template.Abilities.AddItem('ShowGenericAIFlyover');
			}

			if (default.ObsoleteAIRoots.Find(Template.strBehaviorTree) != INDEX_NONE)
			{
				Template.strBehaviorTree = default.NewAIRoot;
			}
			else if (Template.strBehaviorTree != default.NewAIRoot)
			{
				`Log("AdventDoctrine:" @ Template.DataName @ "has AI root" @ Template.strBehaviorTree);
			}
		}
	}
}

exec function DumpJobs()
{
	local X2AIJobManager JobMgr;
	local XComGameState_AIUnitData AIUnitData;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;

	JobMgr = `AIJOBMGR;
	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_AIUnitData', AIUnitData)
	{
		if (AIUnitData.JobIndex != INDEX_NONE)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AIUnitData.m_iUnitObjectID));

			`Log(UnitState @ "(" $ UnitState.GetMyTemplateName() $ ") :" @ JobMgr.GetJobName(AIUnitData.JobIndex));
		}
	}
}
class UIScreenListener_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	ListenerObj = self;

	EventMgr.RegisterForEvent(ListenerObj, 'PlayTurnBegun', AssignAIJobs, ELD_OnStateSubmitted);
}

static function EventListenerReturn AssignAIJobs(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState NewGameState;
	local X2AIJobManager JobMgr;
	local XComGameState_AIUnitData AIUnitData;
	local XComGameState_Unit UnitState;
	local XComGameState_Player SourcePlayer;
	local XComGameStateHistory History;
	local name JobName;
	local array<name> Jobs;
	local bool bSubmitState;
	local int index;

	SourcePlayer = XComGameState_Player(EventSource);
	if (SourcePlayer == none || SourcePlayer.TeamFlag != eTeam_Alien)
		return ELR_NoInterrupt;

	if (GameState.bReadOnly)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("AssignAIJobs");
		bSubmitState = true;
	}
	else
	{
		NewGameState = GameState;
	}

	JobMgr = `AIJOBMGR;
	History = `XCOMHISTORY;

	// Reset all applicable units to their preferred job
	foreach History.IterateByClassType(class'XComGameState_AIUnitData', AIUnitData)
	{
		if (AIUnitData.JobIndex != INDEX_NONE)
		{
			JobName = JobMgr.GetJobName(AIUnitData.JobIndex);

			// Skip unengaged jobs
			if( JobMgr.GetJobListing(JobName).bRequiresEngagement == false )
				continue;

			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AIUnitData.m_iUnitObjectID));
			class'Configuration'.static.FindJobs(UnitState.GetMyTemplateName(), Jobs);

			if (Jobs.Length > 0)
			{
				JobMgr.GetJobListing(Jobs[0], index);
				JobMgr.AssignUnitToJob(AIUnitData.ObjectID, index, JobMgr.JobAssignments.Length, NewGameState);
			}
		}
	}

	if (bSubmitState)
	{
		if( NewGameState.GetNumGameStateObjects() > 0 )
		{
			`TACTICALRULES.SubmitGameState(NewGameState);
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}


defaultproperties
{
	ScreenClass = "UITacticalHUD";
}
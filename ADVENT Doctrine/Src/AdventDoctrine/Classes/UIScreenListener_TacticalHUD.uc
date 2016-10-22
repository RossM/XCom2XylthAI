class UIScreenListener_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	ListenerObj = self;

	EventMgr.RegisterForEvent(ListenerObj, 'PlayerTurnBegun', AssignAIJobs, ELD_OnStateSubmitted);
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
	local int index, newIndex, i;
	local array<int> JobCount;
	local array<XComGameState_Unit> AssignableUnits;

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

	JobCount.Length = JobMgr.JobListings.Length;

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
				AssignableUnits.AddItem(UnitState);
				JobMgr.GetJobListing(Jobs[0], index);
				JobMgr.AssignUnitToJob(AIUnitData.ObjectID, index, JobMgr.JobAssignments.Length, NewGameState);
				JobCount[index]++;
			}
			else
			{
				JobCount[AIUnitData.JobIndex]++;
			}
		}
	}

	// Sort units by max HP, least to most
	AssignableUnits.Sort(SortUnitsByHP);

	// Reassign units to make job distribution more even
	foreach AssignableUnits(UnitState)
	{
		class'Configuration'.static.FindJobs(UnitState.GetMyTemplateName(), Jobs);
		JobMgr.GetJobListing(Jobs[0], index);
		for (i = 1; i < Jobs.Length; i++)
		{
			JobMgr.GetJobListing(Jobs[i], newIndex);

			// Change if it would make job counts more equal
			if (JobCount[index] - 1 >= JobCount[newIndex] + 1)
			{
				JobCount[index]--;
				JobCount[newIndex]++;
				index = newIndex;
			}
		}

		JobMgr.AssignUnitToJob(UnitState.GetAIUnitDataID(), index, JobMgr.JobAssignments.Length, NewGameState);
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

static function int SortUnitsByHP(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
	local int HPDiff;

	HPDiff = UnitB.GetMaxStat(eStat_HP) - UnitA.GetMaxStat(eStat_HP);
	if (HPDiff != 0)
		return HPDiff;

	return UnitB.ObjectID - UnitA.ObjectID;
}


defaultproperties
{
	ScreenClass = "UITacticalHUD";
}
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
	local int index, newIndex, i, leaderIndex;
	local array<int> JobCount;
	local array<XComGameState_Unit> AssignableUnits;
	local XGAIBehavior Behavior;

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

			// Skip units with unengaged jobs, even if they are engaged
			if( JobMgr.GetJobListing(JobName).bRequiresEngagement == false )
				continue;
		}

		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AIUnitData.m_iUnitObjectID));

		// Skip unrevealed AI (they are not engaged)
		if (UnitState.IsUnrevealedAI())
			continue;

		Behavior = XGUnit(UnitState.GetVisualizer()).m_kBehavior;

		// Skip unengaged AI
		if (Behavior == none || (UnitState.GetCurrentStat(eStat_AlertLevel) != `ALERT_LEVEL_RED && !Behavior.IsOrangeAlert()))
			continue;

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
			`Log("AssignAIJobs:" @ UnitState.GetMyTemplateName() @ "has no job listing in XComImmersiveAI.ini");
			if (AIUnitData.JobIndex != INDEX_NONE)
				JobCount[AIUnitData.JobIndex]++;
		}
	}

	// Sort units by max HP, least to most
	AssignableUnits.Sort(SortUnitsByHP);

	// Find a Leader if no unit had leader as their 1st choice
	JobMgr.GetJobListing('Leader', leaderIndex);
	if (JobCount[leaderIndex] == 0)
	{
		for (i = AssignableUnits.Length - 1; i >= 0; i--)
		{
			UnitState = AssignableUnits[i];
			class'Configuration'.static.FindJobs(UnitState.GetMyTemplateName(), Jobs);

			newIndex = Jobs.Find('Leader');
			if (newIndex != INDEX_NONE)
			{
				AIUnitData = XComGameState_AIUnitData(History.GetGameStateForObjectID(UnitState.GetAIUnitDataID()));
				index = AIUnitData.JobIndex;

				JobCount[index]--;
				JobCount[newIndex]++;
				index = newIndex;

				JobMgr.AssignUnitToJob(UnitState.GetAIUnitDataID(), index, JobMgr.JobAssignments.Length, NewGameState);
			}
		}
	}

	// Reassign units to make job distribution more even
	foreach AssignableUnits(UnitState)
	{
		class'Configuration'.static.FindJobs(UnitState.GetMyTemplateName(), Jobs);

		AIUnitData = XComGameState_AIUnitData(History.GetGameStateForObjectID(UnitState.GetAIUnitDataID()));
		index = AIUnitData.JobIndex;

		for (i = 0; i < Jobs.Length; i++)
		{
			if (Jobs[i] == 'Leader')
				continue;

			JobMgr.GetJobListing(Jobs[i], newIndex);

			// Change if it would make job counts more equal, but never change to Leader
			if (JobCount[index] - 1 >= JobCount[newIndex] + 1)
			{
				JobCount[index]--;
				JobCount[newIndex]++;
				index = newIndex;
			}
		}

		if (index != AIUnitData.JobIndex)
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

	// Sort in REVERS objectid ornder
	return UnitA.ObjectID - UnitB.ObjectID;
}


defaultproperties
{
	ScreenClass = "UITacticalHUD";
}
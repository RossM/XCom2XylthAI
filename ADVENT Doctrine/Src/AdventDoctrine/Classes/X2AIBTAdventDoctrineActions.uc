class X2AIBTAdventDoctrineActions extends X2AIBTDefaultActions;

static event bool FindBTActionDelegate(name strName, optional out delegate<BTActionDelegate> dOutFn, optional out name NameParam, optional out name MoveProfile)
{
	// Was hoping to use a hash map for names to delegates, but that may not be valid.
	// using switch statement for now.
	dOutFn = None;

	if (ParseNameForNameAbilitySplit(strName, "PlayAnimation-", NameParam))
	{
		dOutFn = PlayAnimation;
		return true;
	}

	return false;
}

function bt_status PlayAnimation()
{
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = PlayAnimation_BuildVisualization;
	`TACTICALRULES.SubmitGameState(NewGameState);

	return BTS_SUCCESS;
}

function PlayAnimation_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local VisualizationTrack BuildTrack;
	local XComGameStateHistory History;
	local X2Action_PlayAnimation PlayAnimation;

	History = `XCOMHISTORY;
	History.GetCurrentAndPreviousGameStatesForObjectID(m_kUnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	BuildTrack.TrackActor = m_kUnitState.GetVisualizer();

	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	PlayAnimation.Params.AnimName = SplitNameParam;

	OutVisualizationTracks.AddItem(BuildTrack);
}
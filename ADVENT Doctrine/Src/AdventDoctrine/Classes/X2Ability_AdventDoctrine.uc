class X2Ability_AdventDoctrine extends X2Ability config(AIOptions);

var config bool bShowAIFlyovers;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(AddAIFlyover('ShowGenericAIFlyover'));

	return Templates;
}

static function X2AbilityTemplate AddAIFlyover(name DataName)
{
	local X2AbilityTemplate                 Template;		
	local X2AbilityCost_ActionPoints        ActionPointCost;	
	local X2AbilityCooldown					Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bShowActivation = default.bShowAIFlyovers;
	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate AddAIAnimation(name DataName, name FireAnim)
{
	local X2AbilityTemplate                 Template;		
	local X2AbilityCost_ActionPoints        ActionPointCost;	
	local X2AbilityCooldown					Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_Global';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bSkipExitCoverWhenFiring = true;
	Template.CustomFireAnim = FireAnim;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}


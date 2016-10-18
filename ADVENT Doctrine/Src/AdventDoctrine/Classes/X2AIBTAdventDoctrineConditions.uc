class X2AIBTAdventDoctrineConditions extends X2AIBTDefaultConditions config(ImmersiveAI);

struct AIConfigData
{
	var name DataName;
	var string Job;
};

var config array<AIConfigData> AIConfig;

static event bool FindBTConditionDelegate(name strName, optional out delegate<BTConditionDelegate> dOutFn, optional out Name NameParam)
{
	// Was hoping to use a hash map for names to delegates, but that may not be valid.
	// using switch statement for now.
	dOutFn = None;

	if (ParseNameForNameAbilitySplit(strName, "DoesTargetHaveItem-", NameParam))
	{
		dOutFn = DoesTargetHaveItem;
		return true;
	}

	if (ParseNameForNameAbilitySplit(strName, "IsMyPreferredJob-", NameParam))
	{
		dOutFn = IsMyPreferredJob;
		return true;
	}

	return false;
}

function bt_status DoesTargetHaveItem()
{
	local XComGameState_Unit CurrTarget;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item Item;

	if (m_kBehavior.BT_GetTarget(CurrTarget)) // Get current target or curr alert target.
	{
		CurrentInventory = CurrTarget.GetAllInventoryItems();

		foreach CurrentInventory(Item)
		{
			if (Item.GetMyTemplateName() == SplitNameParam)
				return BTS_SUCCESS;
		}
	}

	return BTS_FAILURE;
}

function bt_status IsMyPreferredJob()
{
	local XComGameState_AIUnitData AIUnitData;
	local int index;

	index = default.AIConfig.Find('DataName', m_kUnitState.GetMyTemplateName());
	if (index != INDEX_NONE)
	{
		if (default.AIConfig[index].Job ~= string(SplitNameParam))
		{
			return BTS_SUCCESS;
		}
	}
	else
	{
		AIUnitData = XComGameState_AIUnitData(`XCOMHISTORY.GetGameStateForObjectID(m_kBehavior.GetAIUnitDataID(m_kUnitState.ObjectID)));
		if( AIUnitData.JobIndex != INDEX_NONE && `AIJOBMGR.GetJobIndex(SplitNameParam) == AIUnitData.JobIndex )
		{
			return BTS_SUCCESS;
		}
	}
	return BTS_FAILURE;
}


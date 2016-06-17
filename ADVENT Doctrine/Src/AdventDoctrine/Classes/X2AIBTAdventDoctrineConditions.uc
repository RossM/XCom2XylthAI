class X2AIBTAdventDoctrineConditions extends X2AIBTDefaultConditions;

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
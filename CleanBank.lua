CleanBank = {
	name = "CleanBank",
	backpack = {
		bagId = BAG_BACKPACK
	},
	bank = {
		bagId = BAG_BANK
	},
	subBank = {
		bagId = BAG_SUBSCRIBER_BANK
	}
}

function CleanBank.DepositKnownResearchableItems()
	local i
	
	for i = 0, CleanBank.backpack.size - 1, 1
	do
		local itemLink = CleanBank.backpack.slots[i]
		
		if itemLink ~= "" and IsItemPlayerLocked(CleanBank.backpack.bagId, i) == false then
			local traitKey, isResearchable, reason = LibResearch:GetItemTraitResearchabilityInfo(itemLink)
			
			if reason == "AlreadyKnown" then
				success = CleanBank.MoveItem(CleanBank.backpack, i, CleanBank.bank, 1)
				
				if success == false then
					CleanBank.MoveItem(CleanBank.backpack, i, CleanBank.subBank, 1)
				end
			end
		end
	end
end

function CleanBank.GetFirstFreeSlot(bag)
	local i
	
	for i = 0, bag.size - 1, 1
	do
		if bag.slots[i] == "" then
			return i
		end
	end
	
	return -1
end

function CleanBank:Initialize()
end

function CleanBank.MoveItem(sourceBag, sourceIndex, destBag, stackCount)
	local destIndex = CleanBank.GetFirstFreeSlot(destBag)
	
	if destIndex == -1 then
		return false
	end

	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag.bagId, sourceIndex, destBag.bagId, destIndex, stackCount)
	else
		RequestMoveItem(sourceBag.bagId, sourceIndex, destBag.bagId, destIndex, stackCount)
	end
	
	destBag.slots[destIndex] = sourceBag.slots[sourceIndex]
	sourceBag.slots[sourceIndex] = ""
	
	return true
end

function CleanBank.NumFreeSlots(bag)
	local i
	local count = 0
	
	for i = 0, bag.size - 1, 1
	do
		if bag.slots[i] == "" then
			count = count + 1
		end
	end
	
	return count
end

function CleanBank.OnAddOnLoaded(event, addonName)
	if addonName == CleanBank.name then
		CleanBank:Initialize()
	end
end

function CleanBank.OnOpenBank(eventCode, bankBag)
	if bankBag ~= BAG_BANK then
		return
	end
	
	CleanBank.SetBagInfo()
	local charName = GetUnitName("player")
	
	CleanBank.DepositKnownResearchableItems()
	
	if charName ~= "Alraea" then
		CleanBank.WithdrawNotKnownResearchableItems()
	end
	
	if charName == "Zero Dk Tank" then
		CleanBank.WithdrawKnownResearchableItems()
	end
end

function CleanBank.SetBagInfo()
	CleanBank.backpack.slots = {}
	CleanBank.bank.slots = {}
	CleanBank.subBank.slots = {}
	
	CleanBank.backpack.size = GetBagSize(CleanBank.backpack.bagId)
	CleanBank.bank.size = GetBagSize(CleanBank.bank.bagId)
	CleanBank.subBank.size = GetBagSize(CleanBank.subBank.bagId)
	
	local i
	
	for i = 0, CleanBank.backpack.size - 1, 1
	do
		CleanBank.backpack.slots[i] = GetItemLink(CleanBank.backpack.bagId, i, LINK_STYLE_DEFAULT)
	end
	
	for i = 0, CleanBank.bank.size - 1, 1
	do
		CleanBank.bank.slots[i] = GetItemLink(CleanBank.bank.bagId, i, LINK_STYLE_DEFAULT)
	end
	
	for i = 0, CleanBank.subBank.size - 1, 1
	do
		CleanBank.subBank.slots[i] = GetItemLink(CleanBank.subBank.bagId, i, LINK_STYLE_DEFAULT)
	end
end

function CleanBank.WithdrawKnownResearchableItems()
	local i
	
	for i = 0, CleanBank.bank.size - 1, 1
	do
		local itemLink = CleanBank.bank.slots[i]
		
		if itemLink ~= "" and IsItemPlayerLocked(CleanBank.bank.bagId, i) == false then
			traitKey, isResearchable, reason = LibResearch:GetItemTraitResearchabilityInfo(itemLink)
			
			if reason == "AlreadyKnown" then
				CleanBank.MoveItem(CleanBank.bank, i, CleanBank.backpack, 1)
			end
		end
	end
	
	for i = 0, CleanBank.subBank.size - 1, 1
	do
		local itemLink = CleanBank.subBank.slots[i]
		
		if itemLink ~= "" and IsItemPlayerLocked(CleanBank.subBank.bagId, i) == false then
			traitKey, isResearchable, reason = LibResearch:GetItemTraitResearchabilityInfo(itemLink)
			
			if reason == "AlreadyKnown" then
				CleanBank.MoveItem(CleanBank.subBank, i, CleanBank.backpack, 1)
			end
		end
	end
end

function CleanBank.WithdrawNotKnownResearchableItems()
	local i
	local minFreeSlots = 30
	local freeSlots = CleanBank.NumFreeSlots(CleanBank.backpack)
	
	if freeSlots <= minFreeSlots then
		return
	end
	
	for i = 0, CleanBank.bank.size - 1, 1
	do
		local itemLink = CleanBank.bank.slots[i]
		
		if itemLink ~= "" and IsItemPlayerLocked(CleanBank.bank.bagId, i) == false then
			traitKey, isResearchable, reason = LibResearch:GetItemTraitResearchabilityInfo(itemLink)
			
			if isResearchable then
				CleanBank.MoveItem(CleanBank.bank, i, CleanBank.backpack, 1)
				freeSlots = freeSlots - 1
				
				if freeSlots <= minFreeSlots then
					return
				end
			end
		end
	end
	
	for i = 0, CleanBank.subBank.size - 1, 1
	do
		local itemLink = CleanBank.subBank.slots[i]
		
		if itemLink ~= "" and IsItemPlayerLocked(CleanBank.subBank.bagId, i) == false then
			traitKey, isResearchable, reason = LibResearch:GetItemTraitResearchabilityInfo(itemLink)
			
			if isResearchable then
				CleanBank.MoveItem(CleanBank.subBank, i, CleanBank.backpack, 1)
				freeSlots = freeSlots - 1
				
				if freeSlots <= minFreeSlots then
					return
				end
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent(CleanBank.name, EVENT_ADD_ON_LOADED, CleanBank.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(CleanBank.name, EVENT_OPEN_BANK, CleanBank.OnOpenBank)

SLASH_COMMANDS["/xpr"] = function(to)
	local total = 0
	local from = GetPlayerChampionPointsEarned()
	local i
	
	d("Calculating exp from "..from.." to "..to)
	
	for i = from, to, 1
	do
		total = total + GetNumChampionXPInChampionPoint(i)
	end
	
	d(total)
end
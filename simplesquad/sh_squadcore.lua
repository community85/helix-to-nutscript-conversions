-- [[ GLOBAL VARIABLES ]] --

nut.squadsystem = nut.squadsystem or {}
nut.squadsystem.squads = nut.squadsystem.squads or {}

-- [[ FUNCTIONS ]] --

--[[ 
	FUNCTION: nut.squadsystem.SyncSquad(squad)
	DESCRIPTION: Syncs all members of the provided squad.
]]--

function nut.squadsystem.SyncSquad(squad)
	local squadTable = nut.squadsystem.squads[squad]

	if !(squadTable) or table.IsEmpty(nut.squadsystem.squads[squad]) then
		nut.squadsystem.squads[squad] = nil
	else
		for k, v in pairs(squadTable) do
			net.Start("SquadSync")
				net.WriteTable(squadTable)
			net.Send(v.member)
		end		
	end
end

--[[
	FUNCTION: nut.squadsystem.GiveEmptySquad(client)
	DESCRIPTION: Gives the client an empty squad. This is used
	to clear the version of the squad the client has so that
	they don't draw squad markers over anyone's head.
]]--

function nut.squadsystem.GiveEmptySquad(client)
	net.Start("SquadSync")
		net.WriteTable({})
	net.Send(client)
end

--[[
	FUNCTION: nut.squadsystem.SetSquadLeader(client)
	DESCRIPTION: Sets the designated user to be the squad
	leader of their squad.
]]--

function nut.squadsystem.SetSquadLeader(client)
	local char = client:GetCharacter()
	local squadName = char:GetSquad()
	local squad = nut.squadsystem.squads[squadName]

	if (squadName and squad) then
		for k, v in pairs(squad) do
			if v.member == client then
				local v1, v2 = squad[1], squad[k]

				nut.squadsystem.squads[squadName][1] = v2
				nut.squadsystem.squads[squadName][k] = v1

				client:Notify("You have been promoted to squad leader.")

				break
			end
		end
	end

	nut.squadsystem.SyncSquad(squadName)
end

--[[
	FUNCTION: nut.squadsystem.CreateSquad(client, squad)
	DESCRIPTION: Creates a squad with the designated name.
]]--

function nut.squadsystem.CreateSquad(client, squad)
	if !(nut.squadsystem.squads[squad]) then -- Prevents the creation of the squad if it already exists.
		nut.squadsystem.InitializeSquadInfo(client, squad)

		local tab = { -- player information that will be inserted into the squad table.
			member = client,
			color = client:GetCharacter():GetData("squadInfo").color
		}

		nut.squadsystem.squads[squad] = {tab}

		nut.squadsystem.SyncSquad(squad)

		client:Notify("You have created "..squad..'.')
	else
		client:Notify("Squad already exists.")
	end
end

--[[
	FUNCTION: nut.squadsystem.JoinSquad(client, squad)
	DESCRIPTION: Makes the designated client join the designated squad.
]]--

function nut.squadsystem.JoinSquad(client, squad) -- Replacing client with ply here to use client later.
	if (nut.squadsystem.squads[squad]) then -- Can only join a squad if it exists.
		nut.squadsystem.InitializeSquadInfo(client, squad)

		local tab = { -- player information that will be inserted into the squad table.
			member = client,
			color = client:GetCharacter():GetData("squadInfo").color
		}

		if nut.squadsystem.squads[squad] then
			table.insert(nut.squadsystem.squads[squad], tab)
		end

		nut.squadsystem.SyncSquad(squad)

		client:Notify("You have joined "..squad..'.')
	else
		client:Notify("Squad does not exist.")
	end
end

--[[
	FUNCTION: nut.squadsystem.InitializeSquadInfo(client, group)
	DESCRIPTION: Initializes a client's squad info and sets their squad
	to the provided squad.
]]--

function nut.squadsystem.InitializeSquadInfo(client, group) -- Squad is referred to as group here so that I can use the variable "squad" later in the function.
	local char = client:GetCharacter()
	local groupInfo = { -- Decided to keep it consistent here too by using group instead of squad.
		squad = group,
		color = Color(255, 255, 255) -- Default color is white.
	}

	if char:GetSquad() then
		nut.squadsystem.LeaveSquad(client)
	end

	char:SetData("squadInfo", groupInfo)
end

--[[
	FUNCTION: nut.squadsystem.LeaveSquad(client, character)
	DESCRIPTION: Makes the provided user leave their current
	squad.
]]--

function nut.squadsystem.LeaveSquad(client, character)
	local isKick = false

	if character then
		isKick = true
	else
		character = client:GetCharacter()
	end

	if character and character:GetSquad() then
		local squadName = character:GetSquad()
		local squad = nut.squadsystem.squads[squadName]

		nut.squadsystem.GiveEmptySquad(client)

		if squad then
			for k, v in pairs(squad) do
				if v.member == client then
					table.remove(nut.squadsystem.squads[squadName], k)
				end
			end

			nut.squadsystem.SyncSquad(squadName)

			if isKick then
				client:Notify("You have been removed from "..squadName..'.')
			else
				client:Notify("You have left "..squadName..'.')
			end
		end
	else
		client:Notify("You are not a part of a squad.")
	end

	character:ClearSquadInfo()
end
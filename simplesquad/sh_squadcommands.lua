-- Debug Commands for Bugtesting

-- [[ COMMANDS ]] --


--[[
	COMMAND: /printsquads
	DESCRIPTION: Prints all currently populated squads to the console.
]]

nut.command.Add("printsquads", {
	syntax = "<none>",
	description = "Prints the squads.",
	OnRun = function(self, client)
		for k, v in pairs(nut.squadsystem.squads) do
			print(k.." = {")
			for i, j in pairs(v) do
				print("     "..i.." = "..util.TypeToString(j.member)..", "..util.TypeToString(j.color))
			end
			print('}')
		end
	end
})

--[[
	COMMAND: /printsquadinfo
	DESCRIPTION: Prints a player's squad info to the console.
]]

nut.command.Add("printsquadinfo", {
	syntax = "<player>",
	description = "prints squad info of target.",
	arguments = {
		nut.type.character
	},
	OnRun = function(self, client, target)
		local squadInfo = target:GetData("squadInfo")

		print(squadInfo)
		print(type(squadInfo))

		if squadInfo then
			print(squadInfo.squad)
			print(squadInfo.color)
		else
			print("no squad info")
		end
	end
})

--[[
	COMMAND: /clearsquadinfo
	DESCRIPTION: Clears the squad info of a player.
]]

nut.command.Add("clearsquadinfo", {
	syntax = "<player>",
	description = "Clears squad info of target.",
	arguments = {
		nut.type.character
	},
	OnRun = function(self, client, target)
		target:ClearSquadInfo()
	end
})

--[[
	COMMAND: /syncallsquads
	DESCRIPTION: Resyncs all squads with the server's information.
]]

nut.command.Add("syncallsquads", {
	syntax = "<none>",
	description = "Resyncs all squads.",
	OnRun = function(self, client)
		for k, _ in pairs(nut.squadsystem.squads) do
			nut.squadsystem.SyncSquad(k)
		end
	end
})
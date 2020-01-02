--[[ NETWORKING ]] --

--[[
	NOTE: I know that this isn't the most effective way to network. There's a lot
	of unnecessary Network Strings that could have been simplified down. I plan on returning
	here to redo and redocument the networking.
]]

if SERVER then
	util.AddNetworkString("CreateSquad")
	util.AddNetworkString("JoinSquad")
	util.AddNetworkString("ManageSquad")
	util.AddNetworkString("SquadKick")
	util.AddNetworkString("SquadPromote")
	util.AddNetworkString("SquadSync")

	net.Receive( "CreateSquad", function( len, pl )
		local tab = net.ReadTable()

		print("CreateSquad")

		nut.squadsystem.CreateSquad(tab[1], tab[2])
	end )

	net.Receive( "JoinSquad", function( len, pl )
		local tab = net.ReadTable()

		nut.squadsystem.JoinSquad(tab[1], tab[2])
	end)

	net.Receive("SquadKick", function()
		local tab = net.ReadTable()
		local client = tab[1]

		nut.squadsystem.LeaveSquad(client)
	end)

	net.Receive("SquadPromote", function()
		local tab = net.ReadTable()
		local client = tab[1]

		nut.squadsystem.SetSquadLeader(client)
	end)

	net.Receive("SquadSync", function()
		squad = net.ReadTable()
	end)
else
	squad = squad or {}

	nut.squadsystem.squads = nut.squadsystem.squads or {}

	net.Receive( "CreateSquad", function()
		vgui.Create("nutSquadCreate")
	end)

	net.Receive( "ManageSquad", function()
		vgui.Create("nutSquadManage")
	end)

	net.Receive( "JoinSquad", function()
		nut.squadsystem.squads = net.ReadTable()
		vgui.Create("nutSquadJoin")
	end)

	net.Receive("SquadSync", function()
		squad = net.ReadTable()
	end)
end
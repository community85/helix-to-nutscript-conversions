PLUGIN.name = "Simple Squad"
PLUGIN.author = "Hoooldini"
PLUGIN.description = "A simple squad system for military themed servers."

-- [[ INCLUDES ]] --

nut.util.include("sh_squadcore.lua")
nut.util.include("sh_squadcharmeta.lua")
nut.util.include("sh_squadcommands.lua")
nut.util.include("cl_squadderma.lua")

if CLIENT then

	--[[ NETWORKING ]] --

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

	--[[
		FUNCTION: PLUGIN:HUDPaint()
		DESCRIPTION: Draws a symbol over other character's head depending
		on whether or not they are squad leader.
	]]--

	-- [[ FUNCTIONS ]] --

	function PLUGIN:HUDPaint()
		for k, v in pairs(squad) do
			if (v and v.member and v.member != LocalPlayer() and IsValid(v.member)) then
				local headbone = v.member:LookupBone("ValveBiped.Bip01_Head1")
				local headpos = v.member:GetBonePosition(headbone)
				local sqrdist = LocalPlayer():GetPos():DistToSqr( v.member:GetPos() )
				local maxdist = 524.934
				local alpha = 255

				if sqrdist > (maxdist*maxdist) then
					alpha = 0
				else
					alpha = 255
				end

				headpos:Add( Vector(0, 0, 15) )

				local screenpos = headpos:ToScreen()

				if k == 1 then
					draw.SimpleTextOutlined( "★", "Trebuchet24", screenpos.x, screenpos.y, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 5, Color( 0, 0, 0, alpha ) )
				else
					draw.SimpleTextOutlined( "⮟", "Trebuchet24", screenpos.x, screenpos.y, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 5, Color( 0, 0, 0, alpha ) )
				end
			end
		end
	end
else
	--[[ NETWORKING ]] --

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
end

-- [[ FUNCTIONS ]] --

--[[
	FUNCTION: PLUGIN:OnCharacterDisconnect(client, character)
	DESCRIPTION: Forces a player to leave their squad upon disconnecting.
]]--

function PLUGIN:OnCharacterDisconnect(client, character)
	if character:getSquad() then
		nut.squadsystem.LeaveSquad(client)
	end
end

--[[
	FUNCTION: PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	DESCRIPTION: Forces a player to leave their squad when switching characters.
]]--

function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	if (lastChar and lastChar:getSquad()) then
		nut.squadsystem.LeaveSquad(client, lastChar)
	end
end
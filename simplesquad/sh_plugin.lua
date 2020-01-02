PLUGIN.name = "Simple Squad"
PLUGIN.author = "Hoooldini"
PLUGIN.desc = "A simple squad system for military themed servers."

-- [[ INCLUDES ]] --

nut.util.include("sh_squadcore.lua")
nut.util.include("sh_squadcharMeta.lua")
nut.util.include("sh_squadcommands.lua")
nut.util.include("cl_squadderma.lua")

if CLIENT then

	--[[ NETWORKING ]] --

	squad = squad or {}

	nut.squadsystem.squads = nut.squadsystem.squads or {}

	net.Receive( "createSquad", function()
		vgui.Create("nutSquadCreate")
	end)

	net.Receive( "manageSquad", function()
		vgui.Create("nutSquadManage")
	end)

	net.Receive( "joinSquad", function()
		nut.squadsystem.squads = net.ReadTable()
		vgui.Create("nutSquadJoin")
	end)

	net.Receive("squadSync", function()
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

	util.AddNetworkString("createSquad")
	util.AddNetworkString("joinSquad")
	util.AddNetworkString("manageSquad")
	util.AddNetworkString("squadKick")
	util.AddNetworkString("squadPromote")
	util.AddNetworkString("squadSync")

	net.Receive( "createSquad", function( len, pl )
		local tab = net.ReadTable()

		print("createSquad")

		nut.squadsystem.createSquad(tab[1], tab[2])
	end )

	net.Receive( "joinSquad", function( len, pl )
		local tab = net.ReadTable()

		nut.squadsystem.joinSquad(tab[1], tab[2])
	end)

	net.Receive("squadKick", function()
		local tab = net.ReadTable()
		local client = tab[1]

		nut.squadsystem.leaveSquad(client)
	end)

	net.Receive("squadPromote", function()
		local tab = net.ReadTable()
		local client = tab[1]

		nut.squadsystem.setSquadLeader(client)
	end)

	net.Receive("squadSync", function()
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
		nut.squadsystem.leaveSquad(client)
	end
end

--[[
	FUNCTION: PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	DESCRIPTION: Forces a player to leave their squad when switching characters.
]]--

function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	if (lastChar and lastChar:getSquad()) then
		nut.squadsystem.leaveSquad(client, lastChar)
	end
end
ITEM.name = "Squad Identification Device"
ITEM.des = "A device that allows for easy identification of squad members."
ITEM.model = "models/Items/battery.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Utility"
ITEM.functions.create = {
    name = "Create Squad",
    icon = "icon16/asterisk_yellow.png",
    OnRun = function(item, data)
        net.Start("CreateSquad")
        net.Send(item.player)
        return false
    end
}
ITEM.functions.join = {
	name = "Join Squad",
	icon = "icon16/add.png",
	OnRun = function(item, data)
		net.Start("JoinSquad")
            net.WriteTable(nut.squadsystem.squads)
        net.Send(item.player)
		return false
	end
}
ITEM.functions.manage = {
    name = "Manage Squad",
    icon = "icon16/wrench.png",
    OnRun = function(item, data)
        local char = item.player:getChar()
        local squadName = char:GetSquad() or nil
        local squad = nut.squadsystem.squads[squadName] or nil
        if (squad) and (squad[1].member == item.player) then
            net.Start("ManageSquad")
            net.Send(item.player)
        else
            item.player:notify("You are not a squad leader.")
        end
        return false
    end
}
ITEM.functions.leave = {
    name = "Leave Squad",
    icon = "icon16/delete.png",
    OnRun = function(item, data)
        nut.squadsystem.LeaveSquad(item.player)
        return false
    end
}
ITEM.functions.setcolor = {
    name = "Set Color",
    icon = "icon16/color_wheel.png",
    isMulti = true,
    multiOptions = function(item, ply)
        options = {
            {
                name = "Red",
                data = {
                    color = "red"
                }
            },
            {
                name = "Blue",
                data = {
                    color = "blue"
                }
            },
            {
                name = "Green",
                data = {
                    color = "green"
                }
            },
            {
                name = "Yellow",
                data = {
                    color = "yellow"
                }
            },
            {
                name = "White",
                data = {
                    color = "white"
                }
            }
        }

        return options
    end,
    OnRun = function(item, data)
        item.player:getChar():SetSquadColor(data.color)
        return false
    end
}
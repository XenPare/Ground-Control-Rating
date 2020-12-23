util.AddNetworkString("GC Rating")

if XPA then
	XPA.AddCommand("rating", {
		name = "Rating",
		icon = "icon16/application_side_list.png",
		visible = true,
		category = "Menus",
		opened = false,
		self = true,
		--gamemode = "groundcontrol",
		func = function(pl)
			local rating = sql.Query("SELECT * FROM gc_rating")
			if rating == nil or #rating == 0 then
				XPA.SendMsg(pl, "Rating is unavailable now")
				return
			end
			net.Start("GC Rating")
				net.WriteTable(rating)
			net.Send(pl)
		end
	})
end

hook.Add("Initialize", "GC Rating", function()
	if not sql.TableExists("gc_rating") then
		sql.Query("CREATE TABLE gc_rating ( player INTEGER, name TEXT, steamid TEXT, kills INTEGER, deaths INTEGER );")
	else
		local rating = sql.Query("SELECT * FROM gc_rating")
		if rating == nil or #rating == 0 then
			return
		end
		for _, data in pairs(rating) do
			if tonumber(data.kills) < 15 then
				sql.Query("DELETE FROM gc_rating WHERE player = " .. data.player .. ";")
			end
		end
	end
end)

hook.Add("PlayerInitialSpawn", "GC Rating", function(pl)
	if pl:IsBot() then
		return
	end

	local uid = pl:UniqueID()
	local row = sql.QueryRow("SELECT name, steamid FROM gc_rating WHERE player = " .. uid .. ";")
    if not row then
        sql.Query("INSERT INTO gc_rating( player, name, steamid, kills, deaths ) VALUES(" .. uid .. ", '" .. pl:Name() .. "', '" .. pl:SteamID() .. "', 0, 0) ")
    else
        local name = row.name
        if name ~= pl:Name() then
            sql.Query("UPDATE gc_rating SET name = " .. SQLStr(pl:Name()) .. " WHERE player = " .. uid .. ";")
        end
	end
end)

hook.Add("PlayerDeath", "GC Rating", function(victim, _, attacker)
	if not attacker.GetActiveWeapon then
		return
	end

	local weapon = attacker:GetActiveWeapon()
	if not IsValid(attacker) or attacker == victim or not IsValid(weapon) or not tobool(weapons.GetStored(weapon:GetClass())) then
		return
	end

	local attacker_row = sql.QueryRow("SELECT kills, deaths FROM gc_rating WHERE player = " .. attacker:UniqueID() .. ";")
	if attacker_row then
		sql.Query("UPDATE gc_rating SET kills = " .. attacker_row.kills + 1 .. " WHERE player = " .. attacker:UniqueID() .. ";")
	end

	if not victim:IsBot() then
		local victim_row = sql.QueryRow("SELECT kills, deaths FROM gc_rating WHERE player = " .. victim:UniqueID() .. ";")
		if victim_row then
			sql.Query("UPDATE gc_rating SET deaths = " .. victim_row.deaths + 1 .. " WHERE player = " .. victim:UniqueID() .. ";")
		end
	end
end)
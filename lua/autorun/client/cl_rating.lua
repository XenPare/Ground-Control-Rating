net.Receive("GC Rating", function()
	local tbl = net.ReadTable()

	local fr = vgui.Create("DFrame")
	fr:SetTitle("GC Rating")
	fr:SetSize(ScrW() / 3, ScrH() / 1.2)
	fr:Center()
	fr:MakePopup()

	local function CreateList()
		local pnl = vgui.Create("DPanel", fr)
		pnl:Dock(FILL)

		local plist = vgui.Create("DListView", pnl)
		plist:Dock(FILL)
		plist:SetMultiSelect(false)

		plist:AddColumn("Name")
		plist:AddColumn("SteamID")
		plist:AddColumn("Kills")
		plist:AddColumn("Deaths")

		local psearchpanel = vgui.Create("EditablePanel", pnl)
		psearchpanel:Dock(TOP)

		local psearch = vgui.Create("DTextEntry", psearchpanel)
		psearch:Dock(FILL)
		psearch:SetText("")
		psearch:SetPlaceholderText(table.Count(tbl) .. " players found")

		psearch:SetEnterAllowed(true)
		psearch:SetEditable(true)

		psearch.OnChange = function()
			local finder = psearch:GetValue()
			plist:Clear()

			if finder == "" then
				for _, pl in pairs(tbl) do
					plist:AddLine(pl.name, tostring(pl.steamid), tonumber(pl.kills), tonumber(pl.deaths))
				end
				plist:SortByColumn(3, true)
				return
			end

			for k, pl in pairs(tbl) do
				if pl.steamid:find(finder) or pl.name:lower():find(finder:lower()) then
					plist:AddLine(pl.name, tostring(pl.steamid), tonumber(pl.kills), tonumber(pl.deaths))
				end
			end   
			plist:SortByColumn(3, true)     
		end

		for _, pl in pairs(tbl) do
			plist:AddLine(pl.name, tostring(pl.steamid), tonumber(pl.kills), tonumber(pl.deaths))
		end
		plist:SortByColumn(3, true)
	end

	local progress = vgui.Create("DProgress", fr)
	progress:Dock(TOP)
	progress:SetTall(22)
	progress:SetFraction(0)

	local start = SysTime()
	progress.Think = function(self)
		if self:GetFraction() == 1 then
			self:Remove()
			CreateList()
		end
		self:SetFraction(Lerp(SysTime() - start, 0, 1))
	end
end)
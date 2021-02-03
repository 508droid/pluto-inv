local circles = include "pluto/thirdparty/circles.lua"

local inactive_color = Color(35, 36, 43)
local active_color   = Color(64, 66, 74)

local active_text = Color(255, 255, 255)
local inactive_text = Color(128, 128, 128)

local padding_x = 23
local padding_y = 5

local PANEL = {}

function PANEL:Init()
	self.TabArea = self:Add "EditablePanel"
	function self.TabArea:PerformLayout(w, h)
		local children = self:GetChildren()
		local cw = math.Round((w - 2 * #children - 2) / #children)
		for _, child in pairs(children) do
			child:SetWide(cw)
		end

		if (#children > 0) then
			children[#children]:SetWide(w - cw * (#children - 1) - 2 * (#children - 1))
		end
	end
	self.TabArea:Dock(TOP)
	self.TabArea:SetTall(22)

	self.Inner = self:Add "pluto_inventory_component"
	self.Inner:Dock(FILL)
	self.Inner:SetCurveTopLeft(false)
	self.Inner:SetCurveTopRight(false)

	local old_layout = self.Inner.PerformLayout
	function self.Inner.PerformLayout(s, w, h)
		if (old_layout) then
			old_layout(s, w, h)
		end

		for _, tab in pairs(self.Tabs) do
			tab:SetSize(padding_x * 3 + 48 * 4, h - 24)
			tab:SetPos(w / 2 - tab:GetWide() / 2, 12)
		end
	end

	self.Tabs = {}
end

function PANEL:AddTab(text, onpress)
	onpress = onpress or function() end
	local curve = self.TabArea:Add "ttt_curved_panel"
	curve:Dock(LEFT)
	curve:DockPadding(0, 1, 0, 3)
	curve:SetCurveBottomRight(false)
	curve:SetCurveBottomLeft(false)
	curve:SetMouseInputEnabled(true)

	curve.Label = curve:Add "pluto_label"
	curve.Label:SetFont "pluto_inventory_font_lg"
	curve.Label:SetRenderSystem(pluto.fonts.systems.shadow)
	curve.Label:SetTextColor(Color(255, 255, 255))
	curve.Label:SetText(text)
	curve.Label:SetContentAlignment(5)
	curve.Label:SizeToContentsX()
	curve:SetWide(curve.Label:GetWide() + 24)
	curve.Label:Dock(FILL)

	curve:SetCursor "hand"
	curve:DockMargin(0, 0, 2, 0)

	self.Tabs[curve] = self.Inner:Add "EditablePanel"
	if (not self.ActiveTab) then
		curve:SetColor(active_color)
		curve.Label:SetTextColor(active_text)
		self.ActiveTab = curve
		self.Tabs[curve]:SetVisible(true)
	else
		curve:SetColor(inactive_color)
		curve.Label:SetTextColor(inactive_text)
		self.Tabs[curve]:SetVisible(false)
	end

	function curve.OnMousePressed(s, m)
		if (m == MOUSE_LEFT) then
			if (IsValid(self.ActiveTab)) then
				self.ActiveTab:SetColor(inactive_color)
				self.ActiveTab.Label:SetTextColor(inactive_text)
				self.Tabs[self.ActiveTab]:SetVisible(false)
			end
			s:SetColor(active_color)
			s.Label:SetTextColor(active_text)
			self.Tabs[s]:SetVisible(true)
			self.ActiveTab = s
			onpress()
		end
	end

	return self.Tabs[curve]
end

function PANEL:SetCurve(curve)
	self.Inner:SetCurve(curve)

	for tab in pairs(self.Tabs) do
		tab:SetCurve(curve)
	end
end

function PANEL:SetColor(col)
	self.Inner:SetColor(col)
end

vgui.Register("pluto_inventory_component_tabbed", PANEL, "EditablePanel")
-----------------------------------------------
-- Vanguard scripts made into a addon
-- Author Jasje Auchindoun EU
-----------------------------------------------
-- note to self, 'Fonts\\ARIALN.ttf'

LoadAddOn("Blizzard_ArenaUI")
    ArenaEnemyFrames:Show()
    ArenaEnemyFrame1:Show()
    ArenaEnemyFrame2:Show()
    ArenaEnemyFrame3:Show()
    ArenaEnemyFrame1CastingBar:Show()
	
	-- scalling of the frames
    PlayerFrame:SetScale(1.3)
    TargetFrame:SetScale(1.3)
	FocusFrame:SetScale(1.4)
    PartyMemberFrame1:SetScale(1.6)
    PartyMemberFrame2:SetScale(1.6)
    PartyMemberFrame3:SetScale(1.6)
    PartyMemberFrame4:SetScale(1.6)

--[[adding this so it stops resseting after you entered a vehicle
--if not UnitHasVehicleUI("player") then return end
    --hooking playerframe so it wont reset
	hooksecurefunc("PlayerFrame_ResetPosition", function(self)
	    self:ClearAllPoints()
	    self:SetPoint("CENTER", UIParent, "CENTER", -200, -100)
		self.SetPoint=function()end
    end)

	--moving targetframe a bit
	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 260, 0)
	TargetFrame.SetPoint = function() end	
	--TargetFrame:SetUserPlaced(true)
	--/run TargetFrame_ResetUserPlacedPosition()
	
	--moving focusframe a bit
	FocusFrame:ClearAllPoints()
	FocusFrame:SetPoint("CENTER", UIParent, "LEFT", -200, 110)
	FocusFrame:SetUserPlaced(true)
]]--
--some events need to register	
local f = CreateFrame("FRAME")
    f:RegisterEvent("PARTY_MEMBERS_CHANGED") 
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("PLAYER_FOCUS_CHANGED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("UNIT_FACTION")

--color target and focus namebar to classcolor
local e = function (self, event, ...)
    if UnitIsPlayer("target") then 
        color = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
	    TargetFrameNameBackground:SetVertexColor(color.r,color.g,color.b)
	end
	
	if UnitIsPlayer("focus") then 
	    color = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
	    FocusFrameNameBackground:SetVertexColor(color.r, color.g, color.b) 
	end
end 
	f:SetScript("OnEvent",e)

--changing Setpoint of arena frames	
for i=1,MAX_ARENA_ENEMIES do 
    _G["ArenaEnemyFrame"..i]:SetPoint("CENTER",-860+i*180,-300)
	_G["ArenaEnemyFrame"..i.."Name"]:Hide()
	_G["ArenaEnemyFrame"..i.."Texture"]:SetVertexColor(.05,.05,.05)
	_G["ArenaEnemyFrame"..i.."CastingBar"]:SetScale(1.5)
end

--hiding gryphons
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()

--scalling Arena Frames
local V = {B = "ArenaEnemyFrame"} 
    for i= 1,5 do 
	_G[V.B..i]:SetScale(1.4)
	end

--hiding gryphons
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()

local V ={B = "ArenaEnemyFrame"} 
    for i= 1,5 do
	_G[V.B..i]:SetScale(1.4)
	end

--changing portrait to class icon	
hooksecurefunc("UnitFramePortrait_Update",function(self)
	if self.portrait then
		local t = CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
		if t and UnitIsPlayer(self.unit) then
			self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self.portrait:SetTexCoord(unpack(t))
		else
			self.portrait:SetTexCoord(0,1,0,1)
		end
	end
end)

--[[	
-- splitting up buffs and debuffs
hooksecurefunc("TargetFrame_UpdateAuraPositions",function(self) 
local f , g = _G["TargetFrameDebuff1"], _G["TargetFrameBuff1"] 
    if f then 
	    f:ClearAllPoints() 
        f:SetPoint("TOPLEFT",0,40) 
    end 
    if g then 
        g:ClearAllPoints()
        g:SetPoint("BOTTOMLEFT",4,15) 
    end 
end)
]]--	
-- because its easier to type /rl
SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI	

--casterbar tweaks
CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil);
CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE");
CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, 0);
CastingBarFrame.update = .1;

hooksecurefunc("CastingBarFrame_OnUpdate", function(self, elapsed)
if not self.timer then return end
    if self.update and self.update < elapsed then
        if self.casting then
            self.timer:SetText(format("%2.1f/%1.1f", max(self.maxValue - self.value, 0), self.maxValue))
        elseif self.channeling then
            self.timer:SetText(format("%.1f", max(self.value, 0)))
        else
             self.timer:SetText("")
        end
            self.update = .1
        else
            self.update = self.update - elapsed
    end
end)

CastingBarFrame:ClearAllPoints()
CastingBarFrame:SetPoint("CENTER",UIParent,"CENTER", 0, -250)
CastingBarFrame.SetPoint = function() end
CastingBarFrame:SetScale(1.0)

--hide pvp icons
TargetFrameTextureFramePVPIcon:SetAlpha (0) 
PlayerPVPIcon:SetAlpha (0)

--minimap tweaks
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, delta)
    if delta > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPRIGHT", -26, 7)

-- red hover when out of range
hooksecurefunc ("ActionButton_OnEvent", function (self, event, ...)
    if (event == "PLAYER_TARGET_CHANGED") then
        self. newTimer = self. rangeTimer
    end
end)

hooksecurefunc ("ActionButton_UpdateUsable", function (self)
local icon = _G [self: GetName () .. "Icon"]
local valid = IsActionInRange (self. action)
    if (valid == 0) then
        icon: SetVertexColor (1.0, 0.1, 0.1)
    end
end)

hooksecurefunc ("ActionButton_OnUpdate", function (self, elapsed)
local rangeTimer = self. newTimer
    if (rangeTimer) then
        rangeTimer = rangeTimer - elapsed
    if (rangeTimer <= 0) then
        ActionButton_UpdateUsable (self)
        rangeTimer = TOOLTIP_UPDATE_TIME
    end
        self. newTimer = rangeTimer
    end
end)

--HP Values AND Percents for Player, Target, and Focus Frames
 FrameList = {"Player", "Target", "Focus"}
        function UpdateHealthValues(...)
                for i = 1, select("#", unpack(FrameList)) do 
                        local FrameName = (select(i, unpack(FrameList)))
                        local Health = AbbreviateLargeNumbers(UnitHealth(FrameName))
                        local HealthMax = AbbreviateLargeNumbers(UnitHealthMax(FrameName))
                        local HealthPercent = (UnitHealth(FrameName)/UnitHealthMax(FrameName))*100
                        _G[FrameName.."FrameHealthBar"].TextString:SetText(Health.."|"..HealthMax.." ("..format("%.0f",HealthPercent).."%)")
                end
        end
        hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", UpdateHealthValues)

-- hotkeyt by neal
local gsub = string.gsub

hooksecurefunc('ActionButton_UpdateHotkeys', function(self)
    local hotkey = _G[self:GetName()..'HotKey']
    local text = hotkey:GetText()

    text = gsub(text, '(s%-)', 'S-')
    text = gsub(text, '(a%-)', 'A-')
    text = gsub(text, '(c%-)', 'C-')
    text = gsub(text, '(st%-)', 'C-') -- german control 'Steuerung'

    for i = 1, 30 do
        text = gsub(text, _G['KEY_BUTTON'..i], 'M'..i)
    end

    for i = 1, 9 do
        text = gsub(text, _G['KEY_NUMPAD'..i], 'Nu'..i)
    end

    text = gsub(text, KEY_NUMPADDECIMAL, 'Nu.')
    text = gsub(text, KEY_NUMPADDIVIDE, 'Nu/')
    text = gsub(text, KEY_NUMPADMINUS, 'Nu-')
    text = gsub(text, KEY_NUMPADMULTIPLY, 'Nu*')
    text = gsub(text, KEY_NUMPADPLUS, 'Nu+')

    text = gsub(text, KEY_MOUSEWHEELUP, 'MU')
    text = gsub(text, KEY_MOUSEWHEELDOWN, 'MD')
    text = gsub(text, KEY_NUMLOCK, 'NuL')
    text = gsub(text, KEY_PAGEUP, 'PU')
    text = gsub(text, KEY_PAGEDOWN, 'PD')
    text = gsub(text, KEY_SPACE, '_')
    text = gsub(text, KEY_INSERT, 'Ins')
    text = gsub(text, KEY_HOME, 'Hm')
    text = gsub(text, KEY_DELETE, 'Del')

    hotkey:SetText(text)
end)

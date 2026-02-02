local addonName, AGI = ...
local LibStub = LibStub
local UnitGUID = UnitGUID
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local CharacterFrame = CharacterFrame
local C_Timer = C_Timer
local Settings = Settings
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

LibStub("AceAddon-3.0"):NewAddon(AGI, addonName, "AceConsole-3.0", "AceEvent-3.0")
local AceDB = LibStub("AceDB-3.0")

function AGI:OnInitialize()
    self.db = AceDB:New("AGI_DB", {
        global = {
            EnableIlvlChar = true,
            IlvlFontChar = AGI.DEFAULT_FONT,
            IlvlFontSizeChar = 10,
            IlvlColorChar = { r = 1, g = 0.82, b = 0, a = 1 },
            IlvlClassColorChar = false,

            EnableDurability = true,
            DurFont = AGI.DEFAULT_FONT,
            DurFontSize = 10,

            EnableEnchantsChar = true,
            EnchantFontChar = AGI.DEFAULT_FONT,
            EnchantFontSizeChar = 10,
            EnchantColorChar = { r = 0, g = 1, b = 0, a = 1 },
            EnchantClassColorChar = false,
            EnchantMaxLengthChar = 18,
            ShowMissingEnchantsChar = true,

            EnableGemsChar = true,
            GemSizeChar = 14,
            ShowMissingSocketsChar = true,

            PreciseIlvl = true,
            TotalIlvlFontChar = AGI.DEFAULT_FONT,
            TotalIlvlFontSizeChar = 18,
            TotalIlvlColorChar = { r = 1, g = 0.82, b = 0, a = 1 },
            TotalIlvlClassColorChar = false,

            EnableIlvlInspect = true,
            IlvlFontInspect = AGI.DEFAULT_FONT,
            IlvlFontSizeInspect = 10,
            IlvlColorInspect = { r = 1, g = 0.82, b = 0, a = 1 },
            IlvlClassColorInspect = false,

            EnableEnchantsInspect = true,
            EnchantFontInspect = AGI.DEFAULT_FONT,
            EnchantFontSizeInspect = 10,
            EnchantColorInspect = { r = 0, g = 1, b = 0, a = 1 },
            EnchantClassColorInspect = false,
            EnchantMaxLengthInspect = 18,
            ShowMissingEnchantsInspect = true,

            EnableGemsInspect = true,
            GemSizeInspect = 14,
            ShowMissingSocketsInspect = true,

            EnableTotalIlvlInspect = true,
            TotalIlvlFontInspect = AGI.DEFAULT_FONT,
            TotalIlvlFontSizeInspect = 18,
            TotalIlvlColorInspect = { r = 1, g = 0.82, b = 0, a = 1 },
            TotalIlvlClassColorInspect = false,
        },
    }, true)

    self:RegisterChatCommand("agi", "HandleSlashCommands")
    self:RegisterChatCommand("gearinfo", "HandleSlashCommands")

    local ASA_SUITE = "|cFF047857Asa|r Suite"

    if not LibStub("AceConfigRegistry-3.0"):GetOptionsTable(ASA_SUITE) then
        LibStub("AceConfig-3.0"):RegisterOptionsTable(ASA_SUITE, {
            name = ASA_SUITE,
            type = "group",
            args = {
                info = {
                    type = "description",
                    name = "Welcome to " .. ASA_SUITE .. ". Select a module from the menu on the left to configure its settings.",
                    order = 1,
                },
            },
        })
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ASA_SUITE, ASA_SUITE)
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, AGI:GetOptionsTable())
    self.optionsFrame, self.categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "Gear Info", ASA_SUITE)

    local function QueuePlayerUpdate()
        self:QueueUpdate("player")
    end
    self:RegisterEvent("PLAYER_ENTERING_WORLD", QueuePlayerUpdate)
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", QueuePlayerUpdate)
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", QueuePlayerUpdate)
    self:RegisterEvent("SOCKET_INFO_UPDATE", QueuePlayerUpdate)
    self:RegisterEvent("INSPECT_READY", function(_, guid)
        if not self.queuedUnits then
            return
        end
        for unit in pairs(self.queuedUnits) do
            if UnitGUID(unit) == guid then
                self:QueueUpdate(unit)
            end
        end
    end)

    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, name)
        if name == "Blizzard_InspectUI" then
            if not _G.InspectFrame then
                return
            end
            hooksecurefunc("InspectFrame_UpdateTabs", function()
                if _G.InspectFrame and _G.InspectFrame.unit and _G.InspectFrame:IsShown() then
                    AGI:QueueUpdate(_G.InspectFrame.unit)
                end
            end)
            f:UnregisterEvent("ADDON_LOADED")
        end
    end)

    hooksecurefunc("PaperDollFrame_UpdateStats", function()
        self:UpdatePreciseIlvl()
    end)
end

function AGI:RefreshAddon(unit)
    if not unit or unit == "player" then
        self:QueueUpdate("player")
    end
end

function AGI:HandleSlashCommands(input)
    if not input or input:trim() == "" then
        self:OpenSettings()
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(self, "agi", addonName, input)
    end
end

function AGI:OpenSettings()
    if Settings and Settings.OpenToCategory then
        if self.categoryID then
            Settings.OpenToCategory(self.categoryID)
        else
            Settings.OpenToCategory("|cFF047857Asa|r Suite")
        end
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory("|cFF047857Asa|r Suite")
    else
        LibStub("AceConfigDialog-3.0"):Open(addonName)
    end
end

function AGI:QueueUpdate(unit)
    unit = unit or "player"
    if not self.queuedUnits then
        self.queuedUnits = {}
    end
    if self.queuedUnits[unit] then
        return
    end
    self.queuedUnits[unit] = true

    C_Timer.After(0.1, function()
        self.queuedUnits[unit] = nil
        self:UpdateGearInfo(unit)
        if unit == "player" then
            self:UpdatePreciseIlvl()
        end
    end)
end

function AGI:UpdateGearInfo(unit)
    unit = unit or "player"
    local isInspect = (unit ~= "player")

    if isInspect then
        if not _G.InspectFrame or not _G.InspectFrame:IsShown() then
            return
        end
        if _G.InspectFrame.unit and UnitGUID(_G.InspectFrame.unit) == UnitGUID(unit) then
            unit = _G.InspectFrame.unit
        end
    else
        if not CharacterFrame or not CharacterFrame:IsShown() then
            return
        end
    end

    self:ForEachSlot(unit, function(frame, link, slotId, info, classColor, unit)
        if frame then
            if link then
                self:UpdateItemLevel(frame, link, slotId, classColor, unit)
                if not isInspect then
                    self:UpdateDurability(frame, slotId)
                end
                self:UpdateEnchants(frame, link, slotId, info, classColor, unit)
                C_Timer.After(0.05, function()
                    if frame:IsVisible() then
                        self:UpdateGems(frame, link, info, unit, slotId)
                    end
                end)
            else
                self:ClearSlotInfo(frame)
            end
        end
    end)

    if isInspect then
        self:UpdateInspectTotalIlvl(unit)
    end
end

function AGI:UpdateInspectTotalIlvl(unit)
    local enabled, font, size, useClassCol, customCol = self:GetSettings(unit, "totalIlvl")
    if not enabled then
        if _G.InspectFrame and _G.InspectFrame.AGI_TotalIlvl then
            _G.InspectFrame.AGI_TotalIlvl:Hide()
        end
        return
    end

    if not _G.InspectFrame or not _G.InspectFrame:IsShown() then
        return
    end

    local fs = self:GetFontString(_G.InspectFrame, "AGI_TotalIlvl")
    fs:ClearAllPoints()
    fs:SetPoint("TOPRIGHT", _G.InspectFrame, "TOPRIGHT", -10, -25)

    local totalIlvl = 0
    for i = 1, 17 do
        if i ~= 4 and i ~= 19 then
            -- Skip Shirt (4) and Tabard (19)
            local link = GetInventoryItemLink(unit, i)
            if link then
                local ilvl = self:GetItemLevel(link, unit, i)
                if ilvl then
                    if i == 16 then
                        local offhandLink = GetInventoryItemLink(unit, 17)
                        if not offhandLink then
                            local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(link)
                            if itemEquipLoc == "INVTYPE_2HWEAPON" or itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT" then
                                totalIlvl = totalIlvl + (ilvl * 2)
                            else
                                totalIlvl = totalIlvl + ilvl
                            end
                        else
                            totalIlvl = totalIlvl + ilvl
                        end
                    else
                        totalIlvl = totalIlvl + ilvl
                    end
                end
            end
        end
    end

    local avg = totalIlvl / AGI.TOTAL_ILVL_DIVISOR
    if avg > 0 then
        local avgText = string.format("%.2f", avg)
        if fs:GetText() ~= avgText then
            fs:SetText(avgText)
        end
        self:ApplyFont(fs, font, size)
        self:ApplyColor(fs, self:GetClassColor(unit), useClassCol, customCol)
        fs:Show()
    else
        fs:Hide()
    end
end

function AGI:ClearSlotInfo(frame)
    if frame.AGI_Ilvl then
        frame.AGI_Ilvl:SetText("")
    end
    if frame.AGI_Dur then
        frame.AGI_Dur:SetText("")
    end
    self:ReleaseFrames(frame)
end

function AGI:UpdatePreciseIlvl()
    local db = self.db.global
    if not db.PreciseIlvl then
        return
    end
    if not CharacterStatsPane or not CharacterStatsPane.ItemLevelFrame or not CharacterFrame:IsShown() then
        return
    end

    local _, avg = GetAverageItemLevel()
    local frame = CharacterStatsPane.ItemLevelFrame
    if not frame.Value then
        return
    end

    local avgText = string.format("%.2f", avg)
    if frame.Value:GetText() ~= avgText then
        frame.Value:SetText(avgText)
    end

    local _, font, size, useClassCol, customCol = self:GetSettings("player", "totalIlvl")
    self:ApplyFont(frame.Value, font, size)
    self:ApplyColor(frame.Value, self:GetClassColor("player"), useClassCol, customCol)
end

CharacterFrame:HookScript("OnShow", function()
    AGI:QueueUpdate("player")
end)
CharacterFrame:HookScript("OnHide", function()
    AGI:ForEachSlot("player", function(frame)
        if frame then
            AGI:ClearSlotInfo(frame)
        end
    end)
end)

local function OnInspectShow()
    if _G.InspectFrame and _G.InspectFrame.unit then
        AGI:QueueUpdate(_G.InspectFrame.unit)
    end
end

local function OnInspectHide()
    if _G.InspectFrame and _G.InspectFrame.AGI_TotalIlvl then
        _G.InspectFrame.AGI_TotalIlvl:Hide()
    end
    if _G.InspectFrame and _G.InspectFrame.unit then
        AGI:ForEachSlot(_G.InspectFrame.unit, function(frame)
            if frame then
                AGI:ClearSlotInfo(frame)
            end
        end)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
    if name == "Blizzard_InspectUI" then
        if _G.InspectFrame then
            _G.InspectFrame:HookScript("OnShow", OnInspectShow)
            _G.InspectFrame:HookScript("OnHide", OnInspectHide)
        end
        f:UnregisterEvent("ADDON_LOADED")
    end
end)

if _G.InspectFrame then
    _G.InspectFrame:HookScript("OnShow", OnInspectShow)
    _G.InspectFrame:HookScript("OnHide", OnInspectHide)
end

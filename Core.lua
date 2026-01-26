local addonName, AGI = ...
LibStub("AceAddon-3.0"):NewAddon(AGI, addonName, "AceConsole-3.0", "AceEvent-3.0")

local LSM = LibStub("LibSharedMedia-3.0")
local AceDB = LibStub("AceDB-3.0")
local DEFAULT_FONT = "Friz Quadrata TT"

local RIGHT = { anchor = "TOPLEFT", rel = "TOPRIGHT", justify = "LEFT", x = 6, y = 0, isRight = true }
local LEFT = { anchor = "TOPRIGHT", rel = "TOPLEFT", justify = "RIGHT", x = -6, y = 0, isRight = false }
local BELOW_RIGHT = { anchor = "TOPRIGHT", rel = "BOTTOMRIGHT", justify = "RIGHT", x = -2, y = -2, isRight = false }
local BELOW_LEFT = { anchor = "TOPLEFT", rel = "BOTTOMLEFT", justify = "LEFT", x = 2, y = -2, isRight = true }

local SLOTS = {
    { name = "HeadSlot", align = RIGHT },
    { name = "NeckSlot", align = RIGHT },
    { name = "ShoulderSlot", align = RIGHT },
    { name = "BackSlot", align = RIGHT },
    { name = "ChestSlot", align = RIGHT },
    { name = "ShirtSlot", align = RIGHT },
    { name = "TabardSlot", align = RIGHT },
    { name = "WristSlot", align = RIGHT },
    { name = "HandsSlot", align = LEFT },
    { name = "WaistSlot", align = LEFT },
    { name = "LegsSlot", align = LEFT },
    { name = "FeetSlot", align = LEFT },
    { name = "Finger0Slot", align = LEFT },
    { name = "Finger1Slot", align = LEFT },
    { name = "Trinket0Slot", align = LEFT },
    { name = "Trinket1Slot", align = LEFT },
    { name = "MainHandSlot", align = BELOW_RIGHT },
    { name = "SecondaryHandSlot", align = BELOW_LEFT },
}

function AGI:OnInitialize()
    self.db = AceDB:New("AGI_DB", {
        global = {
            EnableIlvl = true,
            IlvlFont = DEFAULT_FONT,
            IlvlFontSize = 10,
            IlvlColor = { r = 1, g = 0.82, b = 0, a = 1 },
            IlvlClassColor = false,

            EnableDurability = true,
            DurFont = DEFAULT_FONT,
            DurFontSize = 10,

            EnableEnchants = true,
            EnchantFont = DEFAULT_FONT,
            EnchantFontSize = 10,
            EnchantColor = { r = 0, g = 1, b = 0, a = 1 },
            EnchantClassColor = false,

            EnableGems = true,
            GemSize = 14,

            PreciseIlvl = true,
            TotalIlvlFont = DEFAULT_FONT,
            TotalIlvlFontSize = 18,
            TotalIlvlColor = { r = 1, g = 0.82, b = 0, a = 1 },
            TotalIlvlClassColor = false,
        },
    }, true)

    self:RegisterChatCommand("agi", "HandleSlashCommands")

    local function QueuePlayerUpdate()
        self:QueueUpdate("player")
    end
    self:RegisterEvent("PLAYER_ENTERING_WORLD", QueuePlayerUpdate)
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", QueuePlayerUpdate)
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", QueuePlayerUpdate)
    self:RegisterEvent("SOCKET_INFO_UPDATE", QueuePlayerUpdate)

    self:RegisterEvent("INSPECT_READY", function(_, guid)
        if not self.queuedUnits then return end
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
            if not InspectFrame then return end
            hooksecurefunc("InspectFrame_UpdateTabs", function()
                if InspectFrame and InspectFrame.unit and InspectFrame:IsShown() then
                    AGI:QueueUpdate(InspectFrame.unit)
                end
            end)
            f:UnregisterEvent("ADDON_LOADED")
        end
    end)

    hooksecurefunc("PaperDollFrame_UpdateStats", function()
        self:UpdatePreciseIlvl()
    end)
end

local function GetClassColor(unit)
    local _, class = UnitClass(unit or "player")
    return RAID_CLASS_COLORS[class]
end

function AGI:ApplyFont(fs, fontName, fontSize)
    local font = LSM:Fetch("font", fontName or DEFAULT_FONT)
    local _, _, flags = fs:GetFont()
    fs:SetFont(font, fontSize, flags)
end

function AGI:ApplyColor(fs, classColor, useClassColor, custom)
    if not fs then return end
    if useClassColor then
        fs:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        fs:SetTextColor(custom.r, custom.g, custom.b, custom.a)
    end
end

function AGI:GetSlotFrame(slotName, isInspect)
    return _G[(isInspect and "Inspect" or "Character") .. slotName]
end

function AGI:GetFontString(parent, key)
    if not parent[key] then
        parent[key] = parent:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    end
    return parent[key]
end

function AGI:GetEnchantButton(parent)
    if parent.AGI_Enchant then
        return parent.AGI_Enchant
    end
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(14)
    btn.text = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    btn.text:SetPoint("LEFT")
    btn:SetScript("OnEnter", function(self)
        if self.fullText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.fullText, 1, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    parent.AGI_Enchant = btn
    return btn
end

function AGI:GetGemButton(parent, index)
    local key = "AGI_Gem" .. index
    if parent[key] then
        return parent[key]
    end
    local btn = CreateFrame("Frame", nil, parent)
    btn.tex = btn:CreateTexture(nil, "OVERLAY")
    btn.tex:SetAllPoints()
    parent[key] = btn
    return btn
end

function AGI:QueueUpdate(unit)
    unit = unit or "player"
    if not self.queuedUnits then
        self.queuedUnits = {}
    end
    if self.queuedUnits[unit] then return end
    self.queuedUnits[unit] = true

    C_Timer.After(0.1, function()
        self.queuedUnits[unit] = nil
        self:UpdateGearInfo(unit)
        if unit == "player" then
            self:UpdatePreciseIlvl()
        end
    end)
end

local function TruncateText(text, maxLength)
    if not text then
        return ""
    end
    if strlenutf8(text) > maxLength then
        return string.sub(text, 1, maxLength) .. "..."
    end
    return text
end

function AGI:UpdateItemLevel(slotFrame, itemLink, slotId, classColor, unit)
    local fs = self:GetFontString(slotFrame, "AGI_Ilvl")
    fs:SetPoint("TOPLEFT", 2, -2)
    fs:SetText("")
    if not self.db.global.EnableIlvl then return end
    self:ApplyFont(fs, self.db.global.IlvlFont, self.db.global.IlvlFontSize)
    self:ApplyColor(fs, classColor, self.db.global.IlvlClassColor, self.db.global.IlvlColor)

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then return end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() then return end
        if GetInventoryItemLink(unit or "player", slotId) ~= itemLink then return end

        local ilvl
        local lines = C_TooltipInfo.GetInventoryItem(unit or "player", slotId)
        if lines then
            for _, line in ipairs(lines.lines) do
                local found = line.leftText and line.leftText:match("Item Level:?%s*(%d+)")
                if found then
                    ilvl = tonumber(found)
                    break
                end
            end
        end

        if not ilvl then
            if C_Item.GetAppliedItemLevel then
                ilvl = C_Item.GetAppliedItemLevel(itemLink)
            end
            if not ilvl then
                ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
            end
        end

        if ilvl then
            fs:SetText(ilvl)
        end
    end)
end

function AGI:UpdateDurability(slotFrame, slotId)
    local fs = self:GetFontString(slotFrame, "AGI_Dur")
    fs:SetPoint("BOTTOMRIGHT", -2, 2)
    fs:SetText("")
    if not self.db.global.EnableDurability then return end
    self:ApplyFont(fs, self.db.global.DurFont, self.db.global.DurFontSize)

    local cur, max = GetInventoryItemDurability(slotId)
    if not cur or not max or max == 0 then return end
    local pct = cur / max
    fs:SetText(string.format("%d%%", pct * 100))

    if pct < 0.25 then
        fs:SetTextColor(1, 0, 0)
    elseif pct < 0.5 then
        fs:SetTextColor(1, 0.5, 0)
    else
        fs:SetTextColor(0, 1, 0)
    end
end

-- Only show enchants and gems for player; skip for inspected units
function AGI:UpdateEnchants(slotFrame, itemLink, slotId, align, classColor, unit)
    if unit ~= "player" then return end
    local btn = self:GetEnchantButton(slotFrame)
    btn:Hide()
    if not self.db.global.EnableEnchants then return end

    btn:SetPoint(align.anchor, slotFrame, align.rel, align.x, align.y)
    btn.text:ClearAllPoints()
    btn.text:SetPoint(align.justify == "LEFT" and "LEFT" or "RIGHT")
    btn.text:SetJustifyH(align.justify)
    self:ApplyFont(btn.text, self.db.global.EnchantFont, self.db.global.EnchantFontSize)
    self:ApplyColor(btn.text, classColor, self.db.global.EnchantClassColor, self.db.global.EnchantColor)

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then return end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() then return end
        if GetInventoryItemLink("player", slotId) ~= itemLink then return end

        local lines = C_TooltipInfo.GetInventoryItem("player", slotId)
        if lines then
            for _, line in ipairs(lines.lines) do
                local text = line.leftText
                if text and (text:find("^Enchanted:") or text:find("^Enchant:")) then
                    text = text:gsub("^Enchanted:%s*", ""):gsub("^Enchant:%s*", "")
                    text = text:gsub("|A:Prof[^|]+|a", ""):gsub("%s+$", "")
                    btn.fullText = text
                    btn.text:SetText(TruncateText(text, 18))
                    btn:SetWidth(btn.text:GetStringWidth() + 5)
                    btn:Show()
                    return
                end
            end
        end
    end)
end

function AGI:UpdateGems(slotFrame, itemLink, align, unit, slotId)
    for i = 1, 5 do
        if slotFrame["AGI_Gem" .. i] then
            slotFrame["AGI_Gem" .. i]:Hide()
        end
    end
    if unit ~= "player" then return end
    if not self.db.global.EnableGems then return end

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then return end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() then return end
        if GetInventoryItemLink("player", slotId) ~= itemLink then return end

        local size = self.db.global.GemSize
        local right = align.isRight
        local anchor = right and "BOTTOMLEFT" or "BOTTOMRIGHT"
        local rel = right and "BOTTOMRIGHT" or "BOTTOMLEFT"

        for i = 1, 5 do
            local _, gemLink = C_Item.GetItemGem(itemLink, i)
            if gemLink then
                local btn = self:GetGemButton(slotFrame, i)
                btn:SetSize(size, size)
                btn:SetPoint(anchor, slotFrame, rel, (right and 6 or -6) + (i - 1) * (right and size or -size), 0)
                btn.tex:SetTexture(C_Item.GetItemIconByID(gemLink))
                btn:Show()
            end
        end
    end)
end

function AGI:UpdateGearInfo(unit)
    unit = unit or "player"
    local isInspect = (unit ~= "player")
    local framePrefix = isInspect and "Inspect" or "Character"

    if isInspect then
        if not InspectFrame or not InspectFrame:IsShown() then return end
        if InspectFrame.unit and UnitGUID(InspectFrame.unit) == UnitGUID(unit) then
            unit = InspectFrame.unit
        end
    else
        if not CharacterFrame or not CharacterFrame:IsShown() then return end
    end

    local classColor = GetClassColor(unit)

    for _, info in ipairs(SLOTS) do
        local slotId = GetInventorySlotInfo(info.name)
        local link = GetInventoryItemLink(unit, slotId)
        local frame = _G[framePrefix .. info.name]

        if frame then
            if link then
                self:UpdateItemLevel(frame, link, slotId, classColor, unit)
                if not isInspect then
                    self:UpdateDurability(frame, slotId)
                    self:UpdateEnchants(frame, link, slotId, info.align, classColor, unit)
                    self:UpdateGems(frame, link, info.align, unit, slotId)
                end
            else
                self:ClearSlotInfo(frame)
            end
        end
    end
end

function AGI:ClearSlotInfo(frame)
    if frame.AGI_Ilvl then
        frame.AGI_Ilvl:SetText("")
    end
    if frame.AGI_Dur then
        frame.AGI_Dur:SetText("")
    end
    if frame.AGI_Enchant then
        frame.AGI_Enchant:Hide()
    end
    for i = 1, 5 do
        if frame["AGI_Gem" .. i] then
            frame["AGI_Gem" .. i]:Hide()
        end
    end
end

function AGI:UpdatePreciseIlvl()
    if not self.db.global.PreciseIlvl then return end
    if not CharacterStatsPane or not CharacterStatsPane.ItemLevelFrame or not CharacterFrame:IsShown() then return end

    local _, avg = GetAverageItemLevel()
    local frame = CharacterStatsPane.ItemLevelFrame
    if not frame.Value then return end

    frame.Value:SetText(string.format("%.2f", avg))
    self:ApplyFont(frame.Value, self.db.global.TotalIlvlFont, self.db.global.TotalIlvlFontSize)
    self:ApplyColor(frame.Value, GetClassColor("player"), self.db.global.TotalIlvlClassColor, self.db.global.TotalIlvlColor)
end

CharacterFrame:HookScript("OnShow", function()
    AGI:QueueUpdate("player")
end)
CharacterFrame:HookScript("OnHide", function()
    for _, info in ipairs(SLOTS) do
        local frame = _G["Character" .. info.name]
        if frame then
            AGI:ClearSlotInfo(frame)
        end
    end
end)

local function OnInspectShow()
    if InspectFrame.unit then
        AGI:QueueUpdate(InspectFrame.unit)
    end
end

local function OnInspectHide()
    for _, info in ipairs(SLOTS) do
        local frame = _G["Inspect" .. info.name]
        if frame then
            AGI:ClearSlotInfo(frame)
        end
    end
end

if InspectFrame then
    InspectFrame:HookScript("OnShow", OnInspectShow)
    InspectFrame:HookScript("OnHide", OnInspectHide)
end

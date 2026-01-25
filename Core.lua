local addonName, AGI = ...
LibStub('AceAddon-3.0'):NewAddon(AGI, addonName, 'AceConsole-3.0', 'AceEvent-3.0')
local LSM = LibStub("LibSharedMedia-3.0")
local DEFAULT_FONT = "Friz Quadrata TT"

local slots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
    "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot"
}

function AGI:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('AGI_DB', {
        global = {
            EnableIlvl = true,
            IlvlFont = DEFAULT_FONT,
            IlvlFontSize = 10,
            IlvlColor = {r = 1, g = 0.82, b = 0, a = 1},
            IlvlClassColor = false,

            EnableDurability = true,
            DurFont = DEFAULT_FONT,
            DurFontSize = 10,

            EnableEnchants = true,
            EnchantFont = DEFAULT_FONT,
            EnchantFontSize = 10,
            EnchantColor = {r = 0, g = 1, b = 0, a = 1},
            EnchantClassColor = false,

            EnableGems = true,
            GemSize = 14,

            PreciseIlvl = true,
            TotalIlvlFont = DEFAULT_FONT,
            TotalIlvlFontSize = 18,
            TotalIlvlColor = {r = 1, g = 0.82, b = 0, a = 1},
            TotalIlvlClassColor = false,
        },
    }, true)

    local options = self:GetSettings()

    -- Register the main Asa Suite category if it doesn't exist
    if not LibStub("AceConfigRegistry-3.0"):GetOptionsTable("|cFF047857Asa|r Suite") then
        LibStub("AceConfig-3.0"):RegisterOptionsTable("|cFF047857Asa|r Suite", {
            name = "|cFF047857Asa|r Suite",
            type = "group",
            childGroups = "tab",
            args = {
                info = {
                    type = "description",
                    name = "Welcome to |cFF047857Asa|r Suite. Select a module from the tabs at the top to configure its settings.",
                    order = 1,
                },
            },
        })
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("|cFF047857Asa|r Suite", "|cFF047857Asa|r Suite")
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Gear Info", options)
    self.optionsFrame, self.categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Gear Info", "Gear Info", "|cFF047857Asa|r Suite")

    self:RegisterChatCommand('agi', 'HandleSlashCommands')

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAll")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateAll")
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateGearInfo")
    self:RegisterEvent("SOCKET_INFO_UPDATE", "UpdateGearInfo")

    if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
        hooksecurefunc(CharacterStatsPane.ItemLevelFrame, "SetPoint", function()
            self:UpdatePreciseIlvl()
        end)
    end
    
    hooksecurefunc("PaperDollFrame_UpdateStats", function()
        self:UpdatePreciseIlvl()
    end)
end

function AGI:HandleSlashCommands(input)
    if not input or input:trim() == '' then
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory(self.categoryID)
        end
    else
        LibStub('AceConfigCmd-3.0'):HandleCommand('agi', 'Gear Info', input)
    end
end

function AGI:UpdateAll()
    self:UpdateGearInfo()
    self:UpdatePreciseIlvl()
end

function AGI:GetSlotFrame(slotName)
    return _G["Character" .. slotName]
end

function AGI:CreateText(slotFrame, name, point, relativePoint, x, y, justify, fontSize, fontName)
    if not slotFrame then return end
    local text = slotFrame[name]
    if not text then
        text = slotFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        slotFrame[name] = text
    end
    text:ClearAllPoints()
    text:SetPoint(point, slotFrame, relativePoint or point, x, y)
    if justify then
        text:SetJustifyH(justify)
    end
    
    local font = LSM:Fetch("font", fontName or DEFAULT_FONT)
    local _, size, flags = text:GetFont()
    text:SetFont(font, fontSize or size, flags)
    
    return text
end

function AGI:CreateGemTexture(slotFrame, index, point, relativePoint, x, y, size)
    if not slotFrame then return end
    local name = "AsaGem" .. index
    local btn = slotFrame[name]
    if not btn then
        btn = CreateFrame("Button", nil, slotFrame)
        local tex = btn:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        btn.tex = tex
        slotFrame[name] = btn
    end
    btn:SetSize(size or 14, size or 14)
    btn:ClearAllPoints()
    btn:SetPoint(point, slotFrame, relativePoint or point, x, y)
    return btn
end

function AGI:CreateEnchantText(slotFrame, point, relativePoint, x, y, fontSize, fontName)
    if not slotFrame then return end
    local name = "AsaEnchantText"
    local btn = slotFrame[name]
    if not btn then
        btn = CreateFrame("Button", nil, slotFrame)
        btn:SetSize(100, 12)
        
        local text = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        btn.text = text

        btn:SetScript("OnEnter", function(self)
            if self.fullText then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.fullText, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        slotFrame[name] = btn
    end
    btn:ClearAllPoints()
    btn:SetPoint(point, slotFrame, relativePoint or point, x, y)

    btn.text:ClearAllPoints()
    btn.text:SetPoint(point == "TOPLEFT" and "LEFT" or "RIGHT", btn)

    local font = LSM:Fetch("font", fontName or DEFAULT_FONT)
    local _, size, flags = btn.text:GetFont()
    btn.text:SetFont(font, fontSize or size, flags)

    return btn
end

local function TruncateText(text, maxLength)
    if not text then return "" end
    if #text > maxLength then
        return text:sub(1, maxLength - 2) .. ".."
    end
    return text
end

function AGI:UpdateGearInfo()
    if not CharacterFrame then return end

    local _, classFile = UnitClass("player")
    local classColor = C_ColorPicker and C_ColorPicker.GetClassColor(classFile) or RAID_CLASS_COLORS[classFile]

    for _, slotName in ipairs(slots) do
        local slotId = GetInventorySlotInfo(slotName)
        local itemLink = GetInventoryItemLink("player", slotId)
        local slotFrame = self:GetSlotFrame(slotName)

        if slotFrame then
            local left = slotFrame:GetLeft()
            local charLeft = CharacterFrame:GetLeft()
            local isLeft = true
            if left and charLeft then
                isLeft = left < (charLeft + CharacterFrame:GetWidth() / 2)
            end
            
            if slotName == "MainHandSlot" then
                isLeft = false
            elseif slotName == "SecondaryHandSlot" then
                isLeft = true
            end

            -- ILVL
            local ilvlText = self:CreateText(slotFrame, "AsaIlvl", "TOPLEFT", "TOPLEFT", 2, -2, nil, self.db.global.IlvlFontSize, self.db.global.IlvlFont)
            ilvlText:SetText("")
            if self.db.global.IlvlClassColor then
                ilvlText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
            else
                local c = self.db.global.IlvlColor
                ilvlText:SetTextColor(c.r, c.g, c.b, c.a)
            end

            -- DURABILITY
            local durText = self:CreateText(slotFrame, "AsaDur", "BOTTOMRIGHT", "BOTTOMRIGHT", -2, 2, nil, self.db.global.DurFontSize, self.db.global.DurFont)
            durText:SetText("")

            -- ENCHANTS
            local enchantTextBtn = self:CreateEnchantText(slotFrame, "TOP", "TOP", 0, 0, self.db.global.EnchantFontSize, self.db.global.EnchantFont)
            enchantTextBtn:ClearAllPoints()
            
            if slotName == "MainHandSlot" or slotName == "SecondaryHandSlot" then
                local x = (slotName == "MainHandSlot") and -2 or 2
                local y = -2
                local anchor = (slotName == "MainHandSlot") and "TOPRIGHT" or "TOPLEFT"
                local relAnchor = (slotName == "MainHandSlot") and "BOTTOMRIGHT" or "BOTTOMLEFT"
                local justify = (slotName == "MainHandSlot") and "RIGHT" or "LEFT"

                enchantTextBtn:SetPoint(anchor, slotFrame, relAnchor, x, y)
                enchantTextBtn.text:ClearAllPoints()
                enchantTextBtn.text:SetPoint(justify, enchantTextBtn)
                enchantTextBtn.text:SetJustifyH(justify)
            else
                local x = isLeft and 6 or -6
                local y = 0
                local anchor = isLeft and "TOPLEFT" or "TOPRIGHT"
                local relAnchor = isLeft and "TOPRIGHT" or "TOPLEFT"
                local justify = isLeft and "LEFT" or "RIGHT"

                enchantTextBtn:SetPoint(anchor, slotFrame, relAnchor, x, y)
                enchantTextBtn.text:ClearAllPoints()
                enchantTextBtn.text:SetPoint(justify, enchantTextBtn)
                enchantTextBtn.text:SetJustifyH(justify)
            end
            enchantTextBtn:Hide()
            if self.db.global.EnchantClassColor then
                enchantTextBtn.text:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
            else
                local c = self.db.global.EnchantColor
                enchantTextBtn.text:SetTextColor(c.r, c.g, c.b, c.a)
            end

            for i = 1, 5 do
                local gemBtn = slotFrame["AsaGem" .. i]
                if gemBtn then gemBtn:Hide() end
            end

            if itemLink then
                -- ILVL
                if self.db.global.EnableIlvl then
                    local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
                    if C_Item.GetAppliedItemLevel then
                        local appliedIlvl = C_Item.GetAppliedItemLevel(itemLink)
                        if appliedIlvl and appliedIlvl > 0 then
                            ilvl = appliedIlvl
                        end
                    end

                    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slotId)
                    if tooltipData then
                        for _, line in ipairs(tooltipData.lines) do
                            if line.leftText then
                                local foundIlvl = line.leftText:match("Item Level (%d+)")
                                if foundIlvl then
                                    ilvl = tonumber(foundIlvl)
                                    break
                                end
                            end
                        end
                    end

                    if ilvl then
                        ilvlText:SetText(ilvl)
                    end
                end

                -- DURABILITY
                if self.db.global.EnableDurability then
                    local current, maximum = GetInventoryItemDurability(slotId)
                    if current and maximum and maximum > 0 then
                        local perc = (current / maximum) * 100
                        durText:SetText(string.format("%.0f%%", perc))
                        
                        if perc < 25 then
                            durText:SetTextColor(1, 0, 0)
                        elseif perc < 50 then
                            durText:SetTextColor(1, 0.5, 0)
                        else
                            durText:SetTextColor(0, 1, 0)
                        end
                    end
                end

                -- ENCHANTS
                if self.db.global.EnableEnchants then
                    local enchantId = itemLink:match("item:%d+:(%d*):")
                    if enchantId and enchantId ~= "" and enchantId ~= "0" then
                        local data = C_TooltipInfo.GetInventoryItem("player", slotId)
                        if data then
                            for _, line in ipairs(data.lines) do
                                if line.leftText then
                                    if line.leftColor and line.leftColor.r < 0.2 and line.leftColor.g > 0.9 and line.leftColor.b < 0.2 then
                                         local text = line.leftText:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", "")
                                         if text:find("^Enchanted:") or text:find("^Enchant:") or 
                                            (not text:find("Item Level") and not text:find("Upgrade Level") and 
                                             not text:find("%+") and not text:find("^Equip:") and not text:find("^Use:")) then
                                            
                                            text = text:trim():gsub("^Enchanted: ", ""):gsub("^Enchant: ", "")
                                            text = text:gsub("|T.-|t", ""):gsub("|A.-|a", ""):trim()
                                            
                                            enchantTextBtn.fullText = text
                                            enchantTextBtn.text:SetText(TruncateText(text, 18))
                                            enchantTextBtn:Show()
                                            break
                                         end
                                    end
                                end
                            end
                        end
                        if not enchantTextBtn:IsShown() then
                            enchantTextBtn.fullText = "Enchanted"
                            enchantTextBtn.text:SetText("Enchanted")
                            enchantTextBtn:Show()
                        end
                    end
                end

                -- GEMS
                if self.db.global.EnableGems then
                    local stats = C_Item.GetItemStats(itemLink)
                    local numSockets = 0
                    if stats then
                        for stat, _ in pairs(stats) do
                            if stat:find("EMPTY_SOCKET") then
                                numSockets = numSockets + stats[stat]
                            end
                        end
                    end

                    local gemCount = 0
                    local gemSize = self.db.global.GemSize

                    for i = 1, 5 do
                        local _, gemLink = C_Item.GetItemGem(itemLink, i)
                        if gemLink then
                            gemCount = gemCount + 1
                            local gemIcon = C_Item.GetItemIconByID(gemLink)
                            if gemIcon then
                                local xOffset = isLeft and (6 + (gemCount-1) * gemSize) or (-6 - (gemCount-1) * gemSize)
                                local gemBtn = self:CreateGemTexture(slotFrame, gemCount, isLeft and "BOTTOMLEFT" or "BOTTOMRIGHT", isLeft and "BOTTOMRIGHT" or "BOTTOMLEFT", xOffset, 0, gemSize)
                                gemBtn.tex:SetTexture(gemIcon)
                                gemBtn.tex:SetDesaturated(false)
                                gemBtn:Show()
                            end
                        end
                    end

                    if numSockets > gemCount then
                        for i = gemCount + 1, numSockets do
                            local xOffset = isLeft and (6 + (i-1) * gemSize) or (-6 - (i-1) * gemSize)
                            local gemBtn = self:CreateGemTexture(slotFrame, i, isLeft and "BOTTOMLEFT" or "BOTTOMRIGHT", isLeft and "BOTTOMRIGHT" or "BOTTOMLEFT", xOffset, 0, gemSize)
                            gemBtn.tex:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
                            gemBtn.tex:SetDesaturated(false)
                            gemBtn:Show()
                        end
                    end
                end
            end
        end
    end
end

function AGI:UpdatePreciseIlvl()
    if not CharacterFrame or not CharacterFrame:IsShown() then return end
    
    if self.db.global.PreciseIlvl then
        local _, avgEquipped, _ = GetAverageItemLevel()
        if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
            local frame = CharacterStatsPane.ItemLevelFrame
            if frame.Value then
                frame.Value:SetText(string.format("%.2f", avgEquipped))
                
                local font = LSM:Fetch("font", self.db.global.TotalIlvlFont or DEFAULT_FONT)
                local _, size, flags = frame.Value:GetFont()
                frame.Value:SetFont(font, self.db.global.TotalIlvlFontSize or size, flags)

                if self.db.global.TotalIlvlClassColor then
                    local _, classFile = UnitClass("player")
                    local classColor = C_ColorPicker and C_ColorPicker.GetClassColor(classFile) or RAID_CLASS_COLORS[classFile]
                    frame.Value:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
                else
                    local c = self.db.global.TotalIlvlColor
                    frame.Value:SetTextColor(c.r, c.g, c.b, c.a)
                end
            end
        end
    end
end

CharacterFrame:HookScript("OnShow", function()
    AGI:UpdateAll()
end)

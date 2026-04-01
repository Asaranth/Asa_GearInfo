local _, AGI = ...

local GetInventoryItemLink = GetInventoryItemLink
local UnitClass = UnitClass
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local C_TooltipInfo = C_TooltipInfo
local C_Item = C_Item
local strlenutf8 = strlenutf8

function AGI:GetClassColor(unit)
    local _, class = UnitClass(unit or "player")
    return RAID_CLASS_COLORS[class]
end

function AGI:TruncateText(text, maxLength)
    if not text then
        return ""
    end
    if strlenutf8(text) > maxLength then
        if utf8 and utf8.sub then
            return utf8.sub(text, 1, maxLength) .. "..."
        else
            return string.sub(text, 1, maxLength) .. "..."
        end
    end
    return text
end

function AGI:CleanText(text)
    if not text or text == "" then return "" end
    text = text:gsub("||", "|")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|A.-|a", "")
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|K.-|[kK]", "")
    text = text:gsub("|[cC][nN].-:", "")
    text = text:gsub("|[cC]%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|[rR]", "")
    text = text:gsub("|[hH]", "")
    text = text:gsub("|.", "")
    return strtrim(text)
end

function AGI:GetItemLevelFromTooltip(unit, slotId)
    local data = C_TooltipInfo.GetInventoryItem(unit, slotId)
    if data then
        for _, line in ipairs(data.lines) do
            if line.leftText then
                local cleaned = self:CleanText(line.leftText)
                local found = cleaned:match("^Item Level:?%s*(%d+)")
                if found then
                    return tonumber(found)
                end
            end
        end
    end
    return nil
end

local ilvlCache = {}
function AGI:GetItemLevel(itemLink, unit, slotId)
    if not itemLink then
        return nil
    end
    if ilvlCache[itemLink] then
        return ilvlCache[itemLink]
    end

    local ilvl
    if C_Item.GetAppliedItemLevel then
        ilvl = C_Item.GetAppliedItemLevel(itemLink)
    end

    if not ilvl then
        ilvl = self:GetItemLevelFromTooltip(unit, slotId)
    end

    if not ilvl then
        ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
    end

    if ilvl then
        ilvlCache[itemLink] = ilvl
    end
    return ilvl
end

function AGI:ForEachSlot(unit, callback)
    local isInspect = (unit ~= "player")
    local framePrefix = isInspect and "Inspect" or "Character"
    local classColor = self:GetClassColor(unit)

    for _, info in ipairs(AGI.SLOTS) do
        local slotId = info.id
        local link = GetInventoryItemLink(unit, slotId)
        local frame = _G[framePrefix .. info.name]
        callback(frame, link, slotId, info, classColor, unit)
    end
end

function AGI:GetSettings(unit, type)
    local isInspect = (unit ~= "player")
    local db = self.db.global
    if type == "ilvl" then
        return isInspect and db.EnableIlvlInspect or db.EnableIlvlChar,
        isInspect and db.IlvlFontInspect or db.IlvlFontChar,
        isInspect and db.IlvlFontSizeInspect or db.IlvlFontSizeChar,
        isInspect and db.IlvlClassColorInspect or db.IlvlClassColorChar,
        isInspect and db.IlvlColorInspect or db.IlvlColorChar
    elseif type == "enchant" then
        return isInspect and db.EnableEnchantsInspect or db.EnableEnchantsChar,
        isInspect and db.EnchantFontInspect or db.EnchantFontChar,
        isInspect and db.EnchantFontSizeInspect or db.EnchantFontSizeChar,
        isInspect and db.EnchantClassColorInspect or db.EnchantClassColorChar,
        isInspect and db.EnchantColorInspect or db.EnchantColorChar,
        isInspect and db.EnchantMaxLengthInspect or db.EnchantMaxLengthChar,
        isInspect and db.ShowMissingEnchantsInspect or db.ShowMissingEnchantsChar
    elseif type == "gem" then
        return isInspect and db.EnableGemsInspect or db.EnableGemsChar,
        isInspect and db.GemSizeInspect or db.GemSizeChar,
        isInspect and db.ShowMissingSocketsInspect or db.ShowMissingSocketsChar
    elseif type == "totalIlvl" then
        return isInspect and db.EnableTotalIlvlInspect or true,
        isInspect and db.TotalIlvlFontInspect or db.TotalIlvlFontChar,
        isInspect and db.TotalIlvlFontSizeInspect or db.TotalIlvlFontSizeChar,
        isInspect and db.TotalIlvlClassColorInspect or db.TotalIlvlClassColorChar,
        isInspect and db.TotalIlvlColorInspect or db.TotalIlvlColorChar
    end
end

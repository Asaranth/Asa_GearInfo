local _, AGI = ...
local GetInventoryItemLink = GetInventoryItemLink
local C_TooltipInfo = C_TooltipInfo
local C_Item = C_Item
local strtrim = strtrim
local Item = Item

local function CleanText(text)
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

function AGI:UpdateEnchants(slotFrame, itemLink, slotId, info, classColor, unit)
    local btn = self:GetEnchantButton(slotFrame)
    btn:Hide()

    local enabled, font, size, useClassCol, customCol, maxLength, showMissing = self:GetSettings(unit, "enchant")
    if not enabled then
        return
    end

    local align = info.align
    btn:ClearAllPoints()

    local anchorPoint = align.anchor
    local relativePoint = align.rel

    btn:SetPoint(anchorPoint, slotFrame, relativePoint, align.enchantX, align.enchantY)
    btn.text:ClearAllPoints()
    btn.text:SetPoint(align.justify == "LEFT" and "LEFT" or "RIGHT")
    btn.text:SetJustifyH(align.justify)

    self:ApplyFont(btn.text, font, size)
    self:ApplyColor(btn.text, classColor, useClassCol, customCol)

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() or GetInventoryItemLink(unit, slotId) ~= itemLink then
            return
        end

        local data = C_TooltipInfo.GetInventoryItem(unit, slotId)
        if data then
            for _, line in ipairs(data.lines) do
                local cleaned = CleanText(line.leftText)
                if cleaned and (cleaned:find("^Enchanted:") or cleaned:find("^Enchant:")) then
                    local enchantName = cleaned:gsub("^Enchanted:%s*", ""):gsub("^Enchant:%s*", "")
                    enchantName = enchantName:gsub("^Enchant%s+.-%s*-%s*", "")
                    btn.fullText = enchantName
                    local truncated = self:TruncateText(enchantName, maxLength)
                    if btn.text:GetText() ~= truncated then
                        btn.text:SetText(truncated)
                    end
                    btn:SetWidth(btn.text:GetStringWidth() + 5)
                    btn:Show()
                    return
                end
            end
        end

        if showMissing and info.enchantable then
            -- Special case for off-hand: only enchantable if it's a weapon
            if slotId == 17 then
                local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
                if itemEquipLoc ~= "INVTYPE_WEAPON" and itemEquipLoc ~= "INVTYPE_WEAPONOFFHAND" then
                    return
                end
            end

            btn.fullText = "Missing Enchant"
            local missingText = "|cffff0000Missing Enchant|r"
            if btn.text:GetText() ~= missingText then
                btn.text:SetText(missingText)
            end
            btn:SetWidth(btn.text:GetStringWidth() + 5)
            btn:Show()
        end
    end)
end

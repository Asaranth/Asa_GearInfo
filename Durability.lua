local _, AGI = ...
local GetInventoryItemDurability = GetInventoryItemDurability

function AGI:UpdateDurability(slotFrame, slotId)
    local fs = self:GetFontString(slotFrame, "AGI_Dur")
    fs:ClearAllPoints()
    fs:SetPoint("BOTTOMRIGHT", -2, 2)
    fs:SetText("")

    local db = self.db.global
    if not db.EnableDurability then
        return
    end

    local cur, max = GetInventoryItemDurability(slotId)
    if not cur or not max or max == 0 then
        return
    end

    local pct = cur / max
    local pctText = string.format("%d%%", pct * 100)
    if fs:GetText() ~= pctText then
        fs:SetText(pctText)
    end

    self:ApplyFont(fs, db.DurFont, db.DurFontSize)

    local color = AGI.DURABILITY_THRESHOLDS[#AGI.DURABILITY_THRESHOLDS].color
    for _, info in ipairs(AGI.DURABILITY_THRESHOLDS) do
        if pct < info.threshold then
            color = info.color
            break
        end
    end
    fs:SetTextColor(color.r, color.g, color.b)
end

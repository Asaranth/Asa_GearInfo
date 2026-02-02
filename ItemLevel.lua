local _, AGI = ...
local GetInventoryItemLink = GetInventoryItemLink
local Item = Item

function AGI:UpdateItemLevel(slotFrame, itemLink, slotId, classColor, unit)
    local fs = self:GetFontString(slotFrame, "AGI_Ilvl")
    fs:ClearAllPoints()
    fs:SetPoint("TOPLEFT", 2, -2)
    fs:SetText("")

    local enabled, font, size, useClassCol, customCol = self:GetSettings(unit, "ilvl")
    if not enabled then
        return
    end

    self:ApplyFont(fs, font, size)
    self:ApplyColor(fs, classColor, useClassCol, customCol)

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() or GetInventoryItemLink(unit, slotId) ~= itemLink then
            return
        end
        local ilvl = self:GetItemLevel(itemLink, unit, slotId)
        if ilvl then
            if fs:GetText() ~= tostring(ilvl) then
                fs:SetText(ilvl)
            end
        end
    end)
end

local _, AGI = ...
local GetInventoryItemLink = GetInventoryItemLink
local C_Item = C_Item
local C_Timer = C_Timer
local Item = Item

local function SetGemIcon(btn, gemLink, slotFrame, unit, slotId, itemLink)
    local id = string.match(gemLink, "item:(%d+)")
    local icon
    if id then
        icon = select(5, C_Item.GetItemInfoInstant(tonumber(id)))
    end
    if not icon then
        icon = C_Item.GetItemIconByID(gemLink)
    end
    if not icon then
        icon = select(5, C_Item.GetItemInfoInstant(gemLink))
    end

    local texture = icon or "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic"
    if btn.tex:GetTexture() ~= texture then
        btn.tex:SetTexture(texture)
    end

    if not icon then
        btn.tex:SetTexCoord(0, 1, 0, 1)
    else
        btn.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    btn:Show()
end

function AGI:UpdateGems(slotFrame, itemLink, info, unit, slotId, attempts)
    attempts = attempts or 1
    if attempts > AGI.MAX_GEM_ATTEMPTS then
        return
    end

    local enabled, size, showMissing = self:GetSettings(unit, "gem")
    if not enabled then
        for i = 1, AGI.GEM_MAX_COUNT do
            local btn = self:GetGemButton(slotFrame, i)
            btn:Hide()
        end
        return
    end

    local item = Item:CreateFromItemLink(itemLink)
    if item:IsItemEmpty() then
        return
    end

    item:ContinueOnItemLoad(function()
        if not slotFrame:IsVisible() or GetInventoryItemLink(unit, slotId) ~= itemLink then
            return
        end

        local numSockets = C_Item.GetItemNumSockets(itemLink)
        local gemsLoaded = true
        for i = 1, numSockets do
            local gemName = C_Item.GetItemGem(itemLink, i)
            if not gemName then
                gemsLoaded = false
                break
            end
        end

        if not gemsLoaded then
            C_Timer.After(0.1, function()
                self:UpdateGems(slotFrame, itemLink, info, unit, slotId, attempts + 1)
            end)
            return
        end

        local align = info.align
        local right = align.isRight

        local baseFrame = slotFrame
        local anchorPoint = align.anchor
        local relativePoint = align.rel
        local offsetX = align.gemX
        local offsetY = align.gemY

        for i = 1, AGI.GEM_MAX_COUNT do
            local btn = self:GetGemButton(slotFrame, i)
            btn:ClearAllPoints()
            btn:SetSize(size, size)
            -- Anchor first gem to baseFrame, subsequent gems to the previous gem
            if i == 1 then
                btn:SetPoint(anchorPoint, baseFrame, relativePoint, offsetX, offsetY)
            else
                local prevGem = self:GetGemButton(slotFrame, i - 1)
                btn:SetPoint(right and "LEFT" or "RIGHT", prevGem, right and "RIGHT" or "LEFT", right and 1 or -1, 0)
            end

            if i <= numSockets then
                local _, gemLink = C_Item.GetItemGem(itemLink, i)
                if gemLink and gemLink ~= "" then
                    local gemItem = Item:CreateFromItemLink(gemLink)
                    if gemItem:IsItemDataCached() then
                        SetGemIcon(btn, gemLink, slotFrame, unit, slotId, itemLink)
                    else
                        gemItem:ContinueOnItemLoad(function()
                            if not slotFrame:IsVisible() or GetInventoryItemLink(unit, slotId) ~= itemLink then
                                return
                            end
                            SetGemIcon(btn, gemLink, slotFrame, unit, slotId, itemLink)
                        end)
                    end
                else
                    local texture = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic"
                    if btn.tex:GetTexture() ~= texture then
                        btn.tex:SetTexture(texture)
                        btn.tex:SetTexCoord(0, 1, 0, 1)
                    end
                end
                btn.tex:SetVertexColor(1, 1, 1, 1)
                btn:Show()
            elseif showMissing and info.gems and i <= info.gems then
                local texture = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic"
                if btn.tex:GetTexture() ~= texture then
                    btn.tex:SetTexture(texture)
                    btn.tex:SetTexCoord(0, 1, 0, 1)
                end
                btn.tex:SetVertexColor(1, 0, 0, 0.5)
                btn:Show()
            else
                btn:Hide()
            end
        end
    end)
end

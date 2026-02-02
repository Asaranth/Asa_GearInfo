local _, AGI = ...
local LibStub = LibStub
local LSM = LibStub("LibSharedMedia-3.0")
local CreateFrame = CreateFrame
local UIParent = UIParent

function AGI:ApplyFont(fs, fontName, fontSize)
    local font = LSM:Fetch("font", fontName or AGI.DEFAULT_FONT)
    local _, _, flags = fs:GetFont()
    fs:SetFont(font, fontSize, flags)
end

function AGI:ApplyColor(fs, classColor, useClassColor, custom)
    if not fs then
        return
    end
    if useClassColor then
        fs:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        fs:SetTextColor(custom.r, custom.g, custom.b, custom.a)
    end
end

function AGI:GetFontString(parent, key, style)
    if not parent[key] then
        parent[key] = parent:CreateFontString(nil, "OVERLAY", style or "NumberFontNormal")
    end
    return parent[key]
end

local enchantButtonPool = {}
local gemFramePool = {}

function AGI:GetEnchantButton(parent)
    if parent.AGI_Enchant then
        return parent.AGI_Enchant
    end

    local btn = next(enchantButtonPool)
    if btn then
        enchantButtonPool[btn] = nil
        btn:SetParent(parent)
    else
        btn = CreateFrame("Button", nil, parent)
        btn:SetHeight(14)
        btn:SetFrameStrata("HIGH")
        btn.text = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        btn.text:SetPoint("LEFT")
    end

    parent.AGI_Enchant = btn
    return btn
end

function AGI:GetGemButton(parent, index)
    local key = "AGI_Gem" .. index
    if parent[key] then
        return parent[key]
    end

    local btn = next(gemFramePool)
    if btn then
        gemFramePool[btn] = nil
        btn:SetParent(parent)
        btn:Show()
    else
        btn = CreateFrame("Frame", nil, parent)
        btn.tex = btn:CreateTexture(nil, "OVERLAY")
        btn.tex:SetAllPoints(btn)
        btn.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    parent[key] = btn
    return btn
end

function AGI:ReleaseFrames(parent)
    if parent.AGI_Enchant then
        parent.AGI_Enchant:Hide()
        parent.AGI_Enchant:SetParent(UIParent)
        enchantButtonPool[parent.AGI_Enchant] = true
        parent.AGI_Enchant = nil
    end
    for i = 1, AGI.GEM_MAX_COUNT do
        local key = "AGI_Gem" .. i
        if parent[key] then
            parent[key]:Hide()
            parent[key]:SetParent(UIParent)
            gemFramePool[parent[key]] = true
            parent[key] = nil
        end
    end
end

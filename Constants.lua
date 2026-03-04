local _, AGI = ...

AGI.DEFAULT_FONT = "Friz Quadrata TT"
AGI.MAX_GEM_ATTEMPTS = 10
AGI.TOTAL_ILVL_DIVISOR = 16
AGI.GEM_MAX_COUNT = 5
AGI.RIGHT = { anchor = "LEFT", rel = "RIGHT", justify = "LEFT", enchantX = 8, enchantY = 8, gemX = 8, gemY = -12, isRight = true }
AGI.LEFT = { anchor = "RIGHT", rel = "LEFT", justify = "RIGHT", enchantX = -8, enchantY = 8, gemX = -8, gemY = -12, isRight = false }
AGI.BELOW_RIGHT = { anchor = "TOPLEFT", rel = "BOTTOMLEFT", justify = "LEFT", enchantX = 0, enchantY = -2, gemX = 2, gemY = -14, isRight = true }
AGI.BELOW_LEFT = { anchor = "TOPRIGHT", rel = "BOTTOMRIGHT", justify = "RIGHT", enchantX = 0, enchantY = -2, gemX = -2, gemY = -14, isRight = false }

AGI.SLOTS = {
    { id = 1, name = "HeadSlot", align = AGI.RIGHT, gems = 1, enchantable = true },
    { id = 2, name = "NeckSlot", align = AGI.RIGHT, gems = 2, enchantable = false },
    { id = 3, name = "ShoulderSlot", align = AGI.RIGHT, gems = 0, enchantable = true },
    { id = 15, name = "BackSlot", align = AGI.RIGHT, gems = 0, enchantable = false },
    { id = 5, name = "ChestSlot", align = AGI.RIGHT, gems = 0, enchantable = true },
    { id = 4, name = "ShirtSlot", align = AGI.RIGHT, gems = 0, enchantable = false },
    { id = 19, name = "TabardSlot", align = AGI.RIGHT, gems = 0, enchantable = false },
    { id = 9, name = "WristSlot", align = AGI.RIGHT, gems = 1, enchantable = false },
    { id = 10, name = "HandsSlot", align = AGI.LEFT, gems = 0, enchantable = false },
    { id = 6, name = "WaistSlot", align = AGI.LEFT, gems = 1, enchantable = false },
    { id = 7, name = "LegsSlot", align = AGI.LEFT, gems = 0, enchantable = true },
    { id = 8, name = "FeetSlot", align = AGI.LEFT, gems = 0, enchantable = true },
    { id = 11, name = "Finger0Slot", align = AGI.LEFT, gems = 2, enchantable = true },
    { id = 12, name = "Finger1Slot", align = AGI.LEFT, gems = 2, enchantable = true },
    { id = 13, name = "Trinket0Slot", align = AGI.LEFT, gems = 0, enchantable = false },
    { id = 14, name = "Trinket1Slot", align = AGI.LEFT, gems = 0, enchantable = false },
    { id = 16, name = "MainHandSlot", align = AGI.BELOW_LEFT, gems = 0, enchantable = true },
    { id = 17, name = "SecondaryHandSlot", align = AGI.BELOW_RIGHT, gems = 0, enchantable = true },
}

AGI.DURABILITY_THRESHOLDS = {
    { threshold = 0.25, color = { r = 1, g = 0, b = 0 } },
    { threshold = 0.50, color = { r = 1, g = 0.5, b = 0 } },
    { threshold = 0.75, color = { r = 1, g = 1, b = 0 } },
    { threshold = 1.00, color = { r = 0, g = 1, b = 0 } },
}

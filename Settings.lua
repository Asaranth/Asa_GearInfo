local _, AGI = ...

function AGI:GetSettings()
    local LSM = LibStub("LibSharedMedia-3.0")
    local options = {
        name = 'Gear Info',
        type = 'group',
        childGroups = 'tab',
        args = {
            ilvl = {
                type = 'group',
                name = 'Item Level',
                order = 1,
                args = {
                    EnableIlvl = {
                        type = 'toggle',
                        name = 'Enable',
                        desc = 'Display item level on each gear slot.',
                        set = function(_, val) AGI.db.global.EnableIlvl = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnableIlvl end,
                        order = 1,
                    },
                    IlvlFont = {
                        type = 'select',
                        name = 'Font',
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        set = function(_, val) AGI.db.global.IlvlFont = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.IlvlFont end,
                        order = 2,
                    },
                    IlvlFontSize = {
                        type = 'range',
                        name = 'Font Size',
                        min = 6, max = 24, step = 1,
                        set = function(_, val) AGI.db.global.IlvlFontSize = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.IlvlFontSize end,
                        order = 3,
                    },
                    IlvlClassColor = {
                        type = 'toggle',
                        name = 'Use Class Color',
                        set = function(_, val) AGI.db.global.IlvlClassColor = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.IlvlClassColor end,
                        order = 4,
                    },
                    IlvlColor = {
                        type = 'color',
                        name = 'Color',
                        hasAlpha = true,
                        set = function(_, r, g, b, a) 
                            AGI.db.global.IlvlColor = { r = r, g = g, b = b, a = a}
                            AGI:RefreshAddon()
                        end,
                        get = function() 
                            local c = AGI.db.global.IlvlColor
                            return c.r, c.g, c.b, c.a 
                        end,
                        disabled = function() return AGI.db.global.IlvlClassColor end,
                        order = 5,
                    },
                },
            },
            durability = {
                type = 'group',
                name = 'Durability',
                order = 2,
                args = {
                    EnableDurability = {
                        type = 'toggle',
                        name = 'Enable',
                        desc = 'Display durability on each gear slot.',
                        set = function(_, val) AGI.db.global.EnableDurability = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnableDurability end,
                        order = 1,
                    },
                    DurFont = {
                        type = 'select',
                        name = 'Font',
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        set = function(_, val) AGI.db.global.DurFont = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.DurFont end,
                        order = 2,
                    },
                    DurFontSize = {
                        type = 'range',
                        name = 'Font Size',
                        min = 6, max = 24, step = 1,
                        set = function(_, val) AGI.db.global.DurFontSize = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.DurFontSize end,
                        order = 3,
                    },
                },
            },
            enchants = {
                type = 'group',
                name = 'Enchants',
                order = 3,
                args = {
                    EnableEnchants = {
                        type = 'toggle',
                        name = 'Enable',
                        desc = 'Display enchantment text on each gear slot.',
                        set = function(_, val) AGI.db.global.EnableEnchants = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnableEnchants end,
                        order = 1,
                    },
                    EnchantFont = {
                        type = 'select',
                        name = 'Font',
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        set = function(_, val) AGI.db.global.EnchantFont = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnchantFont end,
                        order = 2,
                    },
                    EnchantFontSize = {
                        type = 'range',
                        name = 'Font Size',
                        min = 6, max = 24, step = 1,
                        set = function(_, val) AGI.db.global.EnchantFontSize = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnchantFontSize end,
                        order = 3,
                    },
                    EnchantClassColor = {
                        type = 'toggle',
                        name = 'Use Class Color',
                        set = function(_, val) AGI.db.global.EnchantClassColor = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnchantClassColor end,
                        order = 4,
                    },
                    EnchantColor = {
                        type = 'color',
                        name = 'Color',
                        hasAlpha = true,
                        set = function(_, r, g, b, a) 
                            AGI.db.global.EnchantColor = { r = r, g = g, b = b, a = a}
                            AGI:RefreshAddon()
                        end,
                        get = function() 
                            local c = AGI.db.global.EnchantColor
                            return c.r, c.g, c.b, c.a 
                        end,
                        disabled = function() return AGI.db.global.EnchantClassColor end,
                        order = 5,
                    },
                },
            },
            gems = {
                type = 'group',
                name = 'Gems',
                order = 4,
                args = {
                    EnableGems = {
                        type = 'toggle',
                        name = 'Enable',
                        desc = 'Display gem information on each gear slot.',
                        set = function(_, val) AGI.db.global.EnableGems = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.EnableGems end,
                        order = 1,
                    },
                    GemSize = {
                        type = 'range',
                        name = 'Icon Size',
                        min = 8, max = 32, step = 1,
                        set = function(_, val) AGI.db.global.GemSize = val; AGI:RefreshAddon() end,
                        get = function() return AGI.db.global.GemSize end,
                        order = 2,
                    },
                },
            },
            totalIlvl = {
                type = 'group',
                name = 'Total Item Level',
                order = 5,
                args = {
                    PreciseIlvl = {
                        type = 'toggle',
                        name = 'Precise Total Ilvl',
                        desc = 'Display the total item level with 2 decimal places.',
                        set = function(_, val) AGI.db.global.PreciseIlvl = val; AGI:UpdatePreciseIlvl() end,
                        get = function() return AGI.db.global.PreciseIlvl end,
                        order = 1,
                    },
                    TotalIlvlFont = {
                        type = 'select',
                        name = 'Font',
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        set = function(_, val) AGI.db.global.TotalIlvlFont = val; AGI:UpdatePreciseIlvl() end,
                        get = function() return AGI.db.global.TotalIlvlFont end,
                        order = 2,
                    },
                    TotalIlvlFontSize = {
                        type = 'range',
                        name = 'Font Size',
                        min = 6, max = 24, step = 1,
                        set = function(_, val) AGI.db.global.TotalIlvlFontSize = val; AGI:UpdatePreciseIlvl() end,
                        get = function() return AGI.db.global.TotalIlvlFontSize end,
                        order = 3,
                    },
                    TotalIlvlClassColor = {
                        type = 'toggle',
                        name = 'Use Class Color',
                        set = function(_, val) AGI.db.global.TotalIlvlClassColor = val; AGI:UpdatePreciseIlvl() end,
                        get = function() return AGI.db.global.TotalIlvlClassColor end,
                        order = 4,
                    },
                    TotalIlvlColor = {
                        type = 'color',
                        name = 'Color',
                        hasAlpha = true,
                        set = function(_, r, g, b, a) 
                            AGI.db.global.TotalIlvlColor = { r = r, g = g, b = b, a = a}
                            AGI:UpdatePreciseIlvl()
                        end,
                        get = function() 
                            local c = AGI.db.global.TotalIlvlColor
                            return c.r, c.g, c.b, c.a 
                        end,
                        disabled = function() return AGI.db.global.TotalIlvlClassColor end,
                        order = 5,
                    },
                },
            },
        },
    }
    return options
end

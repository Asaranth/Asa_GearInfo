local _, AGI = ...

function AGI:GetOptionsTable()
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
                    charSection = {
                        type = 'group',
                        name = 'Character Panel',
                        inline = true,
                        order = 1,
                        args = {
                            EnableIlvlChar = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display item level on each gear slot in the character window.',
                                set = function(_, val)
                                    AGI.db.global.EnableIlvlChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableIlvlChar
                                end,
                                order = 1,
                            },
                            IlvlFontChar = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.IlvlFontChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlFontChar
                                end,
                                order = 2,
                            },
                            IlvlFontSizeChar = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.IlvlFontSizeChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlFontSizeChar
                                end,
                                order = 3,
                            },
                            IlvlClassColorChar = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.IlvlClassColorChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlClassColorChar
                                end,
                                order = 4,
                            },
                            IlvlColorChar = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.IlvlColorChar = { r = r, g = g, b = b, a = a }
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    local c = AGI.db.global.IlvlColorChar
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.IlvlClassColorChar
                                end,
                                order = 5,
                            },
                        },
                    },
                    inspectSection = {
                        type = 'group',
                        name = 'Inspect Panel',
                        inline = true,
                        order = 2,
                        args = {
                            EnableIlvlInspect = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display item level on each gear slot in the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.EnableIlvlInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableIlvlInspect
                                end,
                                order = 1,
                            },
                            IlvlFontInspect = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.IlvlFontInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlFontInspect
                                end,
                                order = 2,
                            },
                            IlvlFontSizeInspect = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.IlvlFontSizeInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlFontSizeInspect
                                end,
                                order = 3,
                            },
                            IlvlClassColorInspect = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.IlvlClassColorInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.IlvlClassColorInspect
                                end,
                                order = 4,
                            },
                            IlvlColorInspect = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.IlvlColorInspect = { r = r, g = g, b = b, a = a }
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    local c = AGI.db.global.IlvlColorInspect
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.IlvlClassColorInspect
                                end,
                                order = 5,
                            },
                        },
                    },
                },
            },
            durability = {
                type = 'group',
                name = 'Durability',
                order = 2,
                args = {
                    charSection = {
                        type = 'group',
                        name = 'Character Panel',
                        inline = true,
                        order = 1,
                        args = {
                            EnableDurability = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display durability on each gear slot.',
                                set = function(_, val)
                                    AGI.db.global.EnableDurability = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableDurability
                                end,
                                order = 1,
                            },
                            DurFont = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.DurFont = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.DurFont
                                end,
                                order = 2,
                            },
                            DurFontSize = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.DurFontSize = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.DurFontSize
                                end,
                                order = 3,
                            },
                        },
                    },
                },
            },
            enchants = {
                type = 'group',
                name = 'Enchants',
                order = 3,
                args = {
                    charSection = {
                        type = 'group',
                        name = 'Character Panel',
                        inline = true,
                        order = 1,
                        args = {
                            EnableEnchantsChar = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display enchantment text on each gear slot in the character window.',
                                set = function(_, val)
                                    AGI.db.global.EnableEnchantsChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableEnchantsChar
                                end,
                                order = 1,
                            },
                            EnchantFontChar = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.EnchantFontChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantFontChar
                                end,
                                order = 2,
                            },
                            EnchantFontSizeChar = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.EnchantFontSizeChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantFontSizeChar
                                end,
                                order = 3,
                            },
                            EnchantClassColorChar = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.EnchantClassColorChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantClassColorChar
                                end,
                                order = 4,
                            },
                            EnchantColorChar = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.EnchantColorChar = { r = r, g = g, b = b, a = a }
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    local c = AGI.db.global.EnchantColorChar
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.EnchantClassColorChar
                                end,
                                order = 5,
                            },
                            EnchantMaxLengthChar = {
                                type = 'range',
                                name = 'Max Length',
                                desc = 'Set the maximum number of characters to show for enchantment text before truncating it.',
                                min = 5, max = 50, step = 1,
                                set = function(_, val)
                                    AGI.db.global.EnchantMaxLengthChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantMaxLengthChar
                                end,
                                order = 6,
                            },
                            ShowMissingEnchantsChar = {
                                type = 'toggle',
                                name = 'Show Missing Enchants',
                                desc = 'Display a warning when an item is missing an enchantment in the character window.',
                                set = function(_, val)
                                    AGI.db.global.ShowMissingEnchantsChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.ShowMissingEnchantsChar
                                end,
                                order = 7,
                            },
                        },
                    },
                    inspectSection = {
                        type = 'group',
                        name = 'Inspect Panel',
                        inline = true,
                        order = 2,
                        args = {
                            EnableEnchantsInspect = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display enchantment text on each gear slot in the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.EnableEnchantsInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableEnchantsInspect
                                end,
                                order = 1,
                            },
                            EnchantFontInspect = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.EnchantFontInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantFontInspect
                                end,
                                order = 2,
                            },
                            EnchantFontSizeInspect = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.EnchantFontSizeInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantFontSizeInspect
                                end,
                                order = 3,
                            },
                            EnchantClassColorInspect = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.EnchantClassColorInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantClassColorInspect
                                end,
                                order = 4,
                            },
                            EnchantColorInspect = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.EnchantColorInspect = { r = r, g = g, b = b, a = a }
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    local c = AGI.db.global.EnchantColorInspect
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.EnchantClassColorInspect
                                end,
                                order = 5,
                            },
                            EnchantMaxLengthInspect = {
                                type = 'range',
                                name = 'Max Length',
                                desc = 'Set the maximum number of characters to show for enchantment text before truncating it.',
                                min = 5, max = 50, step = 1,
                                set = function(_, val)
                                    AGI.db.global.EnchantMaxLengthInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnchantMaxLengthInspect
                                end,
                                order = 6,
                            },
                            ShowMissingEnchantsInspect = {
                                type = 'toggle',
                                name = 'Show Missing Enchants',
                                desc = 'Display a warning when an item is missing an enchantment in the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.ShowMissingEnchantsInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.ShowMissingEnchantsInspect
                                end,
                                order = 7,
                            },
                        },
                    },
                },
            },
            gems = {
                type = 'group',
                name = 'Gems',
                order = 4,
                args = {
                    charSection = {
                        type = 'group',
                        name = 'Character Panel',
                        inline = true,
                        order = 1,
                        args = {
                            EnableGemsChar = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display gem information on each gear slot in the character window.',
                                set = function(_, val)
                                    AGI.db.global.EnableGemsChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableGemsChar
                                end,
                                order = 1,
                            },
                            GemSizeChar = {
                                type = 'range',
                                name = 'Icon Size',
                                min = 8, max = 32, step = 1,
                                set = function(_, val)
                                    AGI.db.global.GemSizeChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.GemSizeChar
                                end,
                                order = 2,
                            },
                            ShowMissingSocketsChar = {
                                type = 'toggle',
                                name = 'Show Missing Sockets',
                                desc = 'Display a warning when an item could have more sockets in the character window.',
                                set = function(_, val)
                                    AGI.db.global.ShowMissingSocketsChar = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.ShowMissingSocketsChar
                                end,
                                order = 3,
                            },
                        },
                    },
                    inspectSection = {
                        type = 'group',
                        name = 'Inspect Panel',
                        inline = true,
                        order = 2,
                        args = {
                            EnableGemsInspect = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display gem information on each gear slot in the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.EnableGemsInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.EnableGemsInspect
                                end,
                                order = 1,
                            },
                            GemSizeInspect = {
                                type = 'range',
                                name = 'Icon Size',
                                min = 8, max = 32, step = 1,
                                set = function(_, val)
                                    AGI.db.global.GemSizeInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.GemSizeInspect
                                end,
                                order = 2,
                            },
                            ShowMissingSocketsInspect = {
                                type = 'toggle',
                                name = 'Show Missing Sockets',
                                desc = 'Display a warning when an item could have more sockets in the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.ShowMissingSocketsInspect = val;
                                    AGI:RefreshAddon()
                                end,
                                get = function()
                                    return AGI.db.global.ShowMissingSocketsInspect
                                end,
                                order = 3,
                            },
                        },
                    },
                },
            },
            totalIlvl = {
                type = 'group',
                name = 'Total Item Level',
                order = 5,
                args = {
                    charSection = {
                        type = 'group',
                        name = 'Character Panel',
                        inline = true,
                        order = 1,
                        args = {
                            PreciseIlvl = {
                                type = 'toggle',
                                name = 'Enable Precise Item Level',
                                desc = 'Display the total item level with 2 decimal places on the character window.',
                                set = function(_, val)
                                    AGI.db.global.PreciseIlvl = val;
                                    AGI:UpdatePreciseIlvl()
                                end,
                                get = function()
                                    return AGI.db.global.PreciseIlvl
                                end,
                                order = 1,
                            },
                            TotalIlvlFontChar = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlFontChar = val;
                                    AGI:UpdatePreciseIlvl()
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlFontChar
                                end,
                                order = 2,
                            },
                            TotalIlvlFontSizeChar = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlFontSizeChar = val;
                                    AGI:UpdatePreciseIlvl()
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlFontSizeChar
                                end,
                                order = 3,
                            },
                            TotalIlvlClassColorChar = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlClassColorChar = val;
                                    AGI:UpdatePreciseIlvl()
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlClassColorChar
                                end,
                                order = 4,
                            },
                            TotalIlvlColorChar = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.TotalIlvlColorChar = { r = r, g = g, b = b, a = a }
                                    AGI:UpdatePreciseIlvl()
                                end,
                                get = function()
                                    local c = AGI.db.global.TotalIlvlColorChar
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.TotalIlvlClassColorChar
                                end,
                                order = 5,
                            },
                        },
                    },
                    inspectSection = {
                        type = 'group',
                        name = 'Inspect Panel',
                        inline = true,
                        order = 2,
                        args = {
                            EnableTotalIlvlInspect = {
                                type = 'toggle',
                                name = 'Enable',
                                desc = 'Display the total item level on the inspect window.',
                                set = function(_, val)
                                    AGI.db.global.EnableTotalIlvlInspect = val;
                                    AGI:UpdateGearInfo(InspectFrame and InspectFrame.unit)
                                end,
                                get = function()
                                    return AGI.db.global.EnableTotalIlvlInspect
                                end,
                                order = 1,
                            },
                            TotalIlvlFontInspect = {
                                type = 'select',
                                name = 'Font',
                                dialogControl = 'LSM30_Font',
                                values = LSM:HashTable("font"),
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlFontInspect = val;
                                    AGI:UpdateGearInfo(InspectFrame and InspectFrame.unit)
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlFontInspect
                                end,
                                order = 2,
                            },
                            TotalIlvlFontSizeInspect = {
                                type = 'range',
                                name = 'Font Size',
                                min = 6, max = 24, step = 1,
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlFontSizeInspect = val;
                                    AGI:UpdateGearInfo(InspectFrame and InspectFrame.unit)
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlFontSizeInspect
                                end,
                                order = 3,
                            },
                            TotalIlvlClassColorInspect = {
                                type = 'toggle',
                                name = 'Use Class Color',
                                set = function(_, val)
                                    AGI.db.global.TotalIlvlClassColorInspect = val;
                                    AGI:UpdateGearInfo(InspectFrame and InspectFrame.unit)
                                end,
                                get = function()
                                    return AGI.db.global.TotalIlvlClassColorInspect
                                end,
                                order = 4,
                            },
                            TotalIlvlColorInspect = {
                                type = 'color',
                                name = 'Color',
                                hasAlpha = true,
                                set = function(_, r, g, b, a)
                                    AGI.db.global.TotalIlvlColorInspect = { r = r, g = g, b = b, a = a }
                                    AGI:UpdateGearInfo(InspectFrame and InspectFrame.unit)
                                end,
                                get = function()
                                    local c = AGI.db.global.TotalIlvlColorInspect
                                    return c.r, c.g, c.b, c.a
                                end,
                                disabled = function()
                                    return AGI.db.global.TotalIlvlClassColorInspect
                                end,
                                order = 5,
                            },
                        },
                    },
                },
            },
        },
    }
    return options
end

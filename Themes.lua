-- Themes.lua
-- SynceHub Theme System
-- Contains all available themes

local Themes = {}

-- ============================================
-- THEME DEFINITIONS
-- ============================================

Themes.List = {
    -- Dark Themes
    {
        Name = "Dark (Default)",
        ID = "dark",
        Colors = {
            -- Main colors
            bg = Color3.fromRGB(25, 25, 30),        -- Background
            cd = Color3.fromRGB(30, 30, 35),        -- Card
            ch = Color3.fromRGB(35, 35, 40),        -- Card hover/input
            br = Color3.fromRGB(60, 60, 70),        -- Border
            
            -- Text colors
            tx = Color3.fromRGB(255, 255, 255),     -- Text main
            ts = Color3.fromRGB(150, 150, 160),     -- Text secondary
            
            -- Accent colors
            ac = Color3.fromRGB(88, 101, 242),      -- Accent (Discord blue)
            ach = Color3.fromRGB(110, 120, 255),    -- Accent hover
            
            -- Status colors
            success = Color3.fromRGB(100, 200, 100),
            warn = Color3.fromRGB(255, 180, 0),
            error = Color3.fromRGB(255, 100, 100),
        }
    },
    
    {
        Name = "Midnight Black",
        ID = "midnight",
        Colors = {
            bg = Color3.fromRGB(15, 15, 18),
            cd = Color3.fromRGB(20, 20, 23),
            ch = Color3.fromRGB(25, 25, 28),
            br = Color3.fromRGB(40, 40, 45),
            tx = Color3.fromRGB(240, 240, 245),
            ts = Color3.fromRGB(140, 140, 150),
            ac = Color3.fromRGB(100, 120, 255),
            ach = Color3.fromRGB(120, 140, 255),
            success = Color3.fromRGB(100, 200, 100),
            warn = Color3.fromRGB(255, 180, 0),
            error = Color3.fromRGB(255, 100, 100),
        }
    },
    
    -- Blue Themes
    {
        Name = "Blue Ocean",
        ID = "blue_ocean",
        Colors = {
            bg = Color3.fromRGB(10, 25, 50),
            cd = Color3.fromRGB(20, 40, 80),
            ch = Color3.fromRGB(25, 50, 95),
            br = Color3.fromRGB(40, 70, 120),
            tx = Color3.fromRGB(240, 245, 255),
            ts = Color3.fromRGB(150, 180, 220),
            ac = Color3.fromRGB(0, 180, 255),
            ach = Color3.fromRGB(50, 200, 255),
            success = Color3.fromRGB(100, 220, 150),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 120, 120),
        }
    },
    
    {
        Name = "Sky Blue",
        ID = "sky_blue",
        Colors = {
            bg = Color3.fromRGB(15, 30, 45),
            cd = Color3.fromRGB(25, 45, 70),
            ch = Color3.fromRGB(30, 55, 85),
            br = Color3.fromRGB(50, 80, 120),
            tx = Color3.fromRGB(245, 250, 255),
            ts = Color3.fromRGB(160, 190, 230),
            ac = Color3.fromRGB(70, 150, 255),
            ach = Color3.fromRGB(100, 170, 255),
            success = Color3.fromRGB(100, 220, 150),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 120, 120),
        }
    },
    
    -- Purple Themes
    {
        Name = "Purple Galaxy",
        ID = "purple_galaxy",
        Colors = {
            bg = Color3.fromRGB(30, 15, 40),
            cd = Color3.fromRGB(50, 30, 70),
            ch = Color3.fromRGB(60, 40, 85),
            br = Color3.fromRGB(90, 60, 120),
            tx = Color3.fromRGB(250, 240, 255),
            ts = Color3.fromRGB(180, 150, 200),
            ac = Color3.fromRGB(180, 100, 255),
            ach = Color3.fromRGB(200, 130, 255),
            success = Color3.fromRGB(150, 200, 120),
            warn = Color3.fromRGB(255, 190, 80),
            error = Color3.fromRGB(255, 120, 150),
        }
    },
    
    {
        Name = "Lavender Dream",
        ID = "lavender",
        Colors = {
            bg = Color3.fromRGB(35, 25, 45),
            cd = Color3.fromRGB(55, 40, 75),
            ch = Color3.fromRGB(65, 50, 90),
            br = Color3.fromRGB(95, 75, 130),
            tx = Color3.fromRGB(255, 245, 255),
            ts = Color3.fromRGB(200, 170, 220),
            ac = Color3.fromRGB(160, 120, 220),
            ach = Color3.fromRGB(180, 140, 240),
            success = Color3.fromRGB(150, 200, 120),
            warn = Color3.fromRGB(255, 190, 80),
            error = Color3.fromRGB(255, 120, 150),
        }
    },
    
    -- Red/Pink Themes
    {
        Name = "Red Fire",
        ID = "red_fire",
        Colors = {
            bg = Color3.fromRGB(40, 15, 15),
            cd = Color3.fromRGB(60, 20, 20),
            ch = Color3.fromRGB(75, 25, 25),
            br = Color3.fromRGB(110, 40, 40),
            tx = Color3.fromRGB(255, 240, 240),
            ts = Color3.fromRGB(200, 150, 150),
            ac = Color3.fromRGB(255, 80, 80),
            ach = Color3.fromRGB(255, 110, 110),
            success = Color3.fromRGB(150, 220, 120),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 100, 100),
        }
    },
    
    {
        Name = "Pink Sakura",
        ID = "pink_sakura",
        Colors = {
            bg = Color3.fromRGB(40, 20, 30),
            cd = Color3.fromRGB(60, 30, 50),
            ch = Color3.fromRGB(75, 40, 65),
            br = Color3.fromRGB(110, 60, 95),
            tx = Color3.fromRGB(255, 240, 250),
            ts = Color3.fromRGB(210, 170, 200),
            ac = Color3.fromRGB(255, 120, 180),
            ach = Color3.fromRGB(255, 150, 200),
            success = Color3.fromRGB(150, 220, 150),
            warn = Color3.fromRGB(255, 200, 120),
            error = Color3.fromRGB(255, 120, 140),
        }
    },
    
    -- Green Themes
    {
        Name = "Green Forest",
        ID = "green_forest",
        Colors = {
            bg = Color3.fromRGB(15, 30, 20),
            cd = Color3.fromRGB(20, 45, 30),
            ch = Color3.fromRGB(25, 55, 35),
            br = Color3.fromRGB(40, 80, 50),
            tx = Color3.fromRGB(240, 255, 245),
            ts = Color3.fromRGB(170, 210, 180),
            ac = Color3.fromRGB(80, 200, 120),
            ach = Color3.fromRGB(100, 220, 140),
            success = Color3.fromRGB(100, 220, 120),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 120, 100),
        }
    },
    
    {
        Name = "Emerald",
        ID = "emerald",
        Colors = {
            bg = Color3.fromRGB(10, 35, 25),
            cd = Color3.fromRGB(15, 50, 35),
            ch = Color3.fromRGB(20, 60, 45),
            br = Color3.fromRGB(35, 90, 65),
            tx = Color3.fromRGB(240, 255, 250),
            ts = Color3.fromRGB(160, 220, 190),
            ac = Color3.fromRGB(50, 220, 150),
            ach = Color3.fromRGB(70, 240, 170),
            success = Color3.fromRGB(100, 230, 140),
            warn = Color3.fromRGB(255, 210, 90),
            error = Color3.fromRGB(255, 130, 110),
        }
    },
    
    -- Orange Themes
    {
        Name = "Orange Sunset",
        ID = "orange_sunset",
        Colors = {
            bg = Color3.fromRGB(40, 25, 15),
            cd = Color3.fromRGB(60, 40, 25),
            ch = Color3.fromRGB(75, 50, 30),
            br = Color3.fromRGB(110, 75, 45),
            tx = Color3.fromRGB(255, 245, 235),
            ts = Color3.fromRGB(210, 180, 150),
            ac = Color3.fromRGB(255, 140, 60),
            ach = Color3.fromRGB(255, 160, 90),
            success = Color3.fromRGB(150, 220, 120),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 120, 100),
        }
    },
    
    -- Light Themes
    {
        Name = "Light Mode",
        ID = "light",
        Colors = {
            bg = Color3.fromRGB(240, 240, 245),
            cd = Color3.fromRGB(255, 255, 255),
            ch = Color3.fromRGB(250, 250, 252),
            br = Color3.fromRGB(200, 200, 210),
            tx = Color3.fromRGB(20, 20, 25),
            ts = Color3.fromRGB(100, 100, 110),
            ac = Color3.fromRGB(0, 122, 255),
            ach = Color3.fromRGB(30, 144, 255),
            success = Color3.fromRGB(40, 180, 80),
            warn = Color3.fromRGB(255, 160, 0),
            error = Color3.fromRGB(255, 60, 60),
        }
    },
    
    {
        Name = "Pure White",
        ID = "pure_white",
        Colors = {
            bg = Color3.fromRGB(250, 250, 252),
            cd = Color3.fromRGB(255, 255, 255),
            ch = Color3.fromRGB(248, 248, 250),
            br = Color3.fromRGB(220, 220, 230),
            tx = Color3.fromRGB(15, 15, 20),
            ts = Color3.fromRGB(90, 90, 100),
            ac = Color3.fromRGB(70, 130, 255),
            ach = Color3.fromRGB(90, 150, 255),
            success = Color3.fromRGB(50, 190, 90),
            warn = Color3.fromRGB(255, 170, 20),
            error = Color3.fromRGB(255, 70, 70),
        }
    },
    
    -- Cyan/Teal Themes
    {
        Name = "Cyan Wave",
        ID = "cyan_wave",
        Colors = {
            bg = Color3.fromRGB(15, 30, 35),
            cd = Color3.fromRGB(20, 45, 55),
            ch = Color3.fromRGB(25, 55, 65),
            br = Color3.fromRGB(40, 80, 95),
            tx = Color3.fromRGB(240, 255, 255),
            ts = Color3.fromRGB(160, 210, 220),
            ac = Color3.fromRGB(0, 200, 220),
            ach = Color3.fromRGB(40, 220, 240),
            success = Color3.fromRGB(100, 220, 150),
            warn = Color3.fromRGB(255, 200, 80),
            error = Color3.fromRGB(255, 120, 120),
        }
    },
    
    {
        Name = "Aqua Marine",
        ID = "aqua_marine",
        Colors = {
            bg = Color3.fromRGB(10, 35, 40),
            cd = Color3.fromRGB(15, 50, 60),
            ch = Color3.fromRGB(20, 60, 75),
            br = Color3.fromRGB(35, 90, 105),
            tx = Color3.fromRGB(240, 255, 255),
            ts = Color3.fromRGB(150, 220, 230),
            ac = Color3.fromRGB(50, 220, 200),
            ach = Color3.fromRGB(70, 240, 220),
            success = Color3.fromRGB(100, 230, 180),
            warn = Color3.fromRGB(255, 210, 90),
            error = Color3.fromRGB(255, 130, 130),
        }
    },
    
    -- Special Themes
    {
        Name = "Neon Glow",
        ID = "neon_glow",
        Colors = {
            bg = Color3.fromRGB(10, 10, 15),
            cd = Color3.fromRGB(15, 15, 22),
            ch = Color3.fromRGB(20, 20, 28),
            br = Color3.fromRGB(100, 50, 150),
            tx = Color3.fromRGB(255, 255, 255),
            ts = Color3.fromRGB(180, 150, 220),
            ac = Color3.fromRGB(200, 50, 255),
            ach = Color3.fromRGB(220, 80, 255),
            success = Color3.fromRGB(100, 255, 150),
            warn = Color3.fromRGB(255, 200, 50),
            error = Color3.fromRGB(255, 50, 100),
        }
    },
    
    {
        Name = "Golden Hour",
        ID = "golden_hour",
        Colors = {
            bg = Color3.fromRGB(35, 30, 20),
            cd = Color3.fromRGB(50, 45, 30),
            ch = Color3.fromRGB(60, 55, 35),
            br = Color3.fromRGB(90, 80, 50),
            tx = Color3.fromRGB(255, 250, 240),
            ts = Color3.fromRGB(210, 195, 170),
            ac = Color3.fromRGB(255, 200, 80),
            ach = Color3.fromRGB(255, 220, 110),
            success = Color3.fromRGB(150, 220, 100),
            warn = Color3.fromRGB(255, 180, 50),
            error = Color3.fromRGB(255, 120, 100),
        }
    },
    
    {
        Name = "Dracula",
        ID = "dracula",
        Colors = {
            bg = Color3.fromRGB(40, 42, 54),
            cd = Color3.fromRGB(68, 71, 90),
            ch = Color3.fromRGB(75, 78, 98),
            br = Color3.fromRGB(98, 114, 164),
            tx = Color3.fromRGB(248, 248, 242),
            ts = Color3.fromRGB(189, 147, 249),
            ac = Color3.fromRGB(255, 121, 198),
            ach = Color3.fromRGB(255, 151, 218),
            success = Color3.fromRGB(80, 250, 123),
            warn = Color3.fromRGB(241, 250, 140),
            error = Color3.fromRGB(255, 85, 85),
        }
    },
    
    {
        Name = "Nord",
        ID = "nord",
        Colors = {
            bg = Color3.fromRGB(46, 52, 64),
            cd = Color3.fromRGB(59, 66, 82),
            ch = Color3.fromRGB(67, 76, 94),
            br = Color3.fromRGB(76, 86, 106),
            tx = Color3.fromRGB(236, 239, 244),
            ts = Color3.fromRGB(216, 222, 233),
            ac = Color3.fromRGB(136, 192, 208),
            ach = Color3.fromRGB(156, 212, 228),
            success = Color3.fromRGB(163, 190, 140),
            warn = Color3.fromRGB(235, 203, 139),
            error = Color3.fromRGB(191, 97, 106),
        }
    },
}

-- ============================================
-- THEME FUNCTIONS
-- ============================================

-- Get theme by ID
function Themes.getTheme(themeID)
    for _, theme in ipairs(Themes.List) do
        if theme.ID == themeID then
            return theme
        end
    end
    return Themes.List[1] -- Default to first theme
end

-- Get theme by index
function Themes.getThemeByIndex(index)
    return Themes.List[index] or Themes.List[1]
end

-- Get total themes count
function Themes.getCount()
    return #Themes.List
end

-- Get all theme names
function Themes.getNames()
    local names = {}
    for _, theme in ipairs(Themes.List) do
        table.insert(names, theme.Name)
    end
    return names
end

return Themes

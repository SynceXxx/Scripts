-- Themes.lua
-- SynceHub Theme System

local Themes = {}

Themes.List = {
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
        Name = "Pino Sakura",
        ID = "pino_sakura",
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
}

function Themes.getTheme(themeID)
    for _, theme in ipairs(Themes.List) do
        if theme.ID == themeID then
            return theme
        end
    end
    return Themes.List[1]
end

function Themes.getThemeByIndex(index)
    return Themes.List[index] or Themes.List[1]
end

function Themes.getCount()
    return #Themes.List
end

function Themes.getNames()
    local names = {}
    for _, theme in ipairs(Themes.List) do
        table.insert(names, theme.Name)
    end
    return names
end

return Themes

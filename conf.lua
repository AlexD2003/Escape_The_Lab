
function love.conf(t)
    
    -- Game identity (the name of the save directory)
    t.identity = "EscapeTheLab"       -- The name of the save directory (string)
    t.version = "11.4"                  -- The LÖVE version this game was made for
    t.console = false                   -- Attach a console (boolean, Windows only)

    -- Window configuration
    t.window.title = "Escape the lab"  -- The window title (string)
    t.window.width = 960              -- Window width (number)
    t.window.height = 640           -- Window height (number)
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.vsync = 1                  -- Vertical sync (0 = off, 1 = on, -1 = adaptive)
    t.window.msaa = 0                   -- The number of samples for multi-sampled antialiasing (0 = off)

    -- Optional: Window appearance
    t.window.resizable = true           -- Allow the player to resize the window (boolean)
    t.window.minwidth = 400             -- Minimum window width (number)
    t.window.minheight = 300            -- Minimum window height (number)
    t.window.borderless = false         -- Remove window borders (boolean)
    t.window.icon = "assets/icon.png"   -- Set a custom window icon (path to an image)

    -- Enable/Disable specific modules
    -- t.modules.audio = true              -- Enable the audio module (boolean)
    -- t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    -- t.modules.mouse = true              -- Enable the mouse module (boolean)
    -- t.modules.physics = false           -- Disable the physics module (boolean, unless needed)
    -- t.modules.joystick = true           -- Enable joystick support (boolean)
end

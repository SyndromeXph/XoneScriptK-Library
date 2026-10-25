--============================================================
-- XoneScriptK Example (requires lib.luau)
-- AddToggle/AddSlider/AddDropdown..., Library.Toggles / Library.Options global access.
--============================================================

-- Optional: force mobile mode manually (must be before loadstring):
-- getgenv().CoincideMobile = true
-- getgenv().CoincideMobile = false

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/XoneScriptK-Library/refs/heads/main/lib.luau"))()

local Loading = Library:CreateLoading({
    Title = "XoneScriptK",
    TotalSteps = 4
})

Loading:SetMessage("Initializing...")
Loading:SetDescription("Waiting for game to load...")
task.wait(1)

Loading:SetCurrentStep(1)
Loading:SetDescription("Loading configuration...")
task.wait(1)

Loading:SetCurrentStep(2)
task.wait(1)

Loading:SetCurrentStep(3)
Loading:SetDescription("Ready to start!")
task.wait(1)

Loading:SetCurrentStep(4)
Loading:Continue()

local Toggles = Library.Toggles
local Options = Library.Options

-- Library.MenuKeybind = Enum.KeyCode.Insert
-- Library.MenuKeybind = nil

-- Library:SetLogo("rbxassetid://1234567890")
-- Library:SetLogo("https://example.com/logo.png")
-- Library:SetLogo("Hydrogen/mylogo.png")
-- Library:SetLogo(false)

local Watermark = Library:Watermark({
    Text = "XoneScriptK | dev"
});

local Window = Library:CreateWindow({
    Title = "XoneScriptK",
    Size = UDim2.fromOffset(550, 555)
});

local Preview = Library:PreviewWindow({
    Title = "Preview",
    Width = 240,
    Height = 277,
    BindTab = "Visual"
});
Preview:PositionNextTo(Window);
Preview:SyncWithWindow(Window);

local PlayerList = Library:Playerlist({
    Title = "Players",
    Width = 240,
    Height = 276,
    BindTab = "Players"
});
PlayerList:PositionBelow(Preview);
PlayerList:SyncWithWindow(Window);

local KeybindList = Library:KeybindList({
    Title = "Keybinds"
});

local Tabs = {
    Legit    = Window:AddTab("legit"),
    Rage     = Window:AddTab("rage"),
    Players  = Window:AddTab("players"),
    Visuals  = Window:AddTab("visuals"),
    Misc     = Window:AddTab("misc"),
    Settings = Window:AddTab("Settings")
};

--============================================================
-- Legit tab
--============================================================
local LeftBox = Tabs.Legit:AddLeftGroupbox("section");

LeftBox:AddToggle("MyToggle", {
    Text = "Toggle",
    Default = false,
    Tooltip = "A normal toggle",
    Callback = function(Value)
        print("MyToggle:", Value)
    end
});

Toggles.MyToggle:OnChanged(function(Value)
    print("MyToggle changed ->", Value)
end);

LeftBox:AddToggle("ToggleKey", {
    Text = "Toggle2",
    Default = true
}):AddKeyPicker("ToggleKeyPicker", {
    Default = "F",
    Mode = "Toggle",
    Text = "Toggle2 key",
    Callback = function(State)
        print("key pressed, state:", State)
    end
});

LeftBox:AddToggle("HoldAim", {
    Text = "Hold Aim",
    Default = false
}):AddKeyPicker("HoldAimKey", {
    Default = "LeftShift",
    Mode = "Hold"
});

LeftBox:AddToggle("ESPMaster", {
    Text = "ESP",
    Default = true
}):AddColorPicker("ESPMainColor", {
    Default = Color3.fromRGB(255, 80, 80)
});

Options.ESPMainColor:OnChanged(function(Color)
    print("ESP color:", Color)
end);

LeftBox:AddToggle("RiskyOption", {
    Text = "Risky Option",
    Default = true,
    Risky = true,
    Tooltip = "This can get you banned"
});

LeftBox:AddDivider();
LeftBox:AddLabel("sliders / dropdowns:");

LeftBox:AddSlider("MySlider", {
    Text = "Test Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
    Tooltip = "Drag to adjust",
    Callback = function(Value)
        print("slider:", Value)
    end
});

LeftBox:AddSlider("FloatSlider", {
    Text = "Float Slider",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Step = 0.05
});

LeftBox:AddDropdown("MyDropdown", {
    Text = "Dropdown",
    Values = { "Value 1", "Value 2", "Value 3" },
    Default = 1,
    Callback = function(Value)
        print("dropdown:", Value)
    end
});

LeftBox:AddDropdown("MyMultiDropdown", {
    Text = "Multi Dropdown",
    Values = { "ESP", "Tracers", "Boxes", "Names" },
    Multi = true,
    Default = { ["ESP"] = true, ["Boxes"] = true },
    Callback = function(Value)
        print("multi:", Value.ESP == true)
    end
});

LeftBox:AddInput("MyTextbox", {
    Text = "Textbox",
    Default = "",
    Placeholder = "type here...",
    Callback = function(Value)
        print("input:", Value)
    end
});

LeftBox:AddKeyPicker("AimKey", {
    Text = "Aim Key",
    Default = "LeftShift",
    Mode = "Hold",
    Tooltip = "Click to rebind, right-click to clear",
    Callback = function(State)
        print("aim key state:", State)
    end
});

LeftBox:AddKeyPicker("MenuKey", {
    Text = "Menu Key",
    Default = "Insert",
    Mode = "Toggle"
});

LeftBox:AddColorPicker("MyColor", {
    Text = "Color",
    Default = Color3.fromRGB(57, 114, 236),
    Transparency = 0,
    Callback = function(Color)
        print("color:", Color)
    end
});

LeftBox:AddButton({
    Text = "Button",
    Func = function()
        print("Button clicked")
    end
});

local SaveLoad = LeftBox:AddButton("Save", function()
    print("Save")
end);
SaveLoad:AddButton("Load", function()
    print("Load")
end);

LeftBox:AddButton({
    Text = "Delete",
    Confirm = true,
    Func = function()
        print("DELETED")
    end
});

local RightBox = Tabs.Legit:AddRightGroupbox("section 2");
RightBox:AddLabel("Right column group");

--============================================================
-- Players tab
--============================================================
local PlayersBox = Tabs.Players:AddLeftGroupbox("Controls");

PlayersBox:AddButton({
    Text = "Refresh List",
    Tooltip = "Manually re-scan current players",
    Func = function()
        PlayerList:Refresh()
    end
});

PlayersBox:AddButton({
    Text = "Destroy List",
    Confirm = true,
    Func = function()
        PlayerList:Destroy()
    end
});

--============================================================
-- Visuals tab
--============================================================
local EspBox = Tabs.Visuals:AddLeftGroupbox("ESP");

EspBox:AddToggle("ESPEnabled", {
    Text = "Enabled",
    Callback = function(S)
        Preview:Set("Enabled", S)
    end
});

local BoxT = EspBox:AddToggle("ESPBox", {
    Text = "Box",
    Callback = function(S)
        Preview:Set("Box", S)
    end
});
BoxT:AddColorPicker("ESPBoxColorHigh", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C, A)
        Preview:Set("BoxColorHigh", C, A)
    end
});
BoxT:AddColorPicker("ESPBoxColorLow", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C, A)
        Preview:Set("BoxColorLow", C, A)
    end
});

local FillT = EspBox:AddToggle("ESPFill", {
    Text = "Box Fill",
    Callback = function(S)
        Preview:Set("Fill", S)
    end
});
FillT:AddColorPicker("ESPFillColorHigh", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C, A)
        Preview:Set("FillColorHigh", C, A)
    end
});
FillT:AddColorPicker("ESPFillColorLow", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C, A)
        Preview:Set("FillColorLow", C, A)
    end
});

EspBox:AddToggle("ESPGlow", {
    Text = "Box Glow",
    Callback = function(S)
        Preview:Set("Glow", S)
    end
}):AddColorPicker("ESPGlowColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C, A)
        Preview:Set("GlowColorHigh", C, A)
    end
});

EspBox:AddToggle("ESPHealth", {
    Text = "Healthbar",
    Callback = function(S)
        Preview:Set("Healthbar", S)
    end
});

EspBox:AddToggle("ESPHealthText", {
    Text = "Healthbar Text",
    Callback = function(S)
        Preview:Set("HealthbarText", S)
    end
});

EspBox:AddToggle("ESPNames", {
    Text = "Names",
    Callback = function(S)
        Preview:Set("Name", S)
    end
}):AddColorPicker("ESPNameColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(C)
        Preview:Set("NameColor", C)
    end
});

EspBox:AddToggle("ESPDistance", {
    Text = "Distance",
    Callback = function(S)
        Preview:Set("Distance", S)
    end
});

EspBox:AddToggle("ESPWeapon", {
    Text = "Weapon",
    Callback = function(S)
        Preview:Set("Weapon", S)
    end
});

EspBox:AddToggle("ESPFlags", {
    Text = "Flags",
    Callback = function(S)
        Preview:Set("Flags", S)
    end
});

EspBox:AddSlider("BoxRotation", {
    Text = "Box Rotation",
    Min = -180,
    Max = 180,
    Default = 90,
    Suffix = "°",
    Callback = function(V)
        Preview:Set("BoxRotation", V)
    end
});

--============================================================
-- Misc tab
--============================================================
local MiscBox = Tabs.Misc:AddLeftGroupbox("Demo");

local DemoTabbox = MiscBox:AddTabbox();
local TMain  = DemoTabbox:AddTab("Main");
local TOther = DemoTabbox:AddTab("Other");
TMain:AddLabel("This is the first tabbox page", true);
TMain:AddToggle("TabboxToggle", {
    Text = "Tabbox Toggle",
    Callback = function(V) print("tabbox toggle:", V) end
});
TOther:AddLabel("Content of the second page", true);
TOther:AddSlider("TabboxSlider", {
    Text = "Tabbox Slider",
    Min = 0, Max = 100, Default = 30
});

MiscBox:AddLabel("Loading animation (Library:CreateLoading)\nExample is at the top of the script, enabled by default.", true);

--============================================================
-- Settings tab
--============================================================
Tabs.Settings:ApplySettings();

local CustomBox = Tabs.Settings:AddLeftGroupbox("My Section");
CustomBox:AddButton({
    Text = "My Button",
    Func = function()
        print("custom settings button")
    end
});

CustomBox:AddButton({
    Text = "Unload UI",
    DoubleClick = true,
    Func = function()
        Library:Unload()
    end
});

-- Settings contents are accessible via Tabs.Settings.SettingsControls:
--   local C = Tabs.Settings.SettingsControls
--   C.SaveConfig("pvp") / C.LoadConfig("pvp") / C.DeleteConfig("pvp")
--   C.SetAutoLoad("pvp") / C.ClearAutoLoad() / C.RefreshConfigs()
--   C.SaveTheme("blue") / C.LoadTheme("blue") / C.DeleteTheme("blue") / C.RefreshThemes()
--   C.UIScale:Set(130)
--   C.LiteAnimations:Set(true)
--   C.Accent:Set(Color3.fromRGB(0, 170, 255))
--   C.Watermark:Set(false)
--   C.MenuKeybind:SetKey(Enum.KeyCode.Insert)
--   C.Unload()
--   C.Sections.Menu

--   Library:OnUnload(function()
--       -- stop loops / clear ESP / restore properties...
--   end)

Library:Notify({ Title = "XoneScriptK", Description = "Loaded!", Time = 2 });

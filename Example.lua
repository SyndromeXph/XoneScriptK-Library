
-- getgenv().CoincideMobile = true
-- getgenv().CoincideMobile = false

local Repository = "https://raw.githubusercontent.com/SyndromeXph/XoneScriptK-Library/refs/heads/main/"
local Library = loadstring(game:HttpGet(Repository .. "lib.luau"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
-- Optional: isolate configs for the current game.
-- SaveManager:SetSubFolder(tostring(game.PlaceId))



local Toggles = Library.Toggles
local Options = Library.Options

-- Library.MenuKeybind = Enum.KeyCode.Insert
-- Library.MenuKeybind = nil

-- Library:SetLogo("rbxassetid://1234567890")
-- Library:SetLogo("https://example.com/logo.png")
-- Library:SetLogo("XoneScriptK/mylogo.png")
-- Library:SetLogo(false)

local Watermark = Library:Watermark({
    Text = "XoneScriptK | dev",
    Position = UDim2.fromOffset(10, 110),
    IconPosition = "left",
    IconSize = 16,
    Draggable = true
});

-- Watermark:SetText("XoneScriptK | custom status")
-- Watermark:SetVisible(false)
-- Watermark:SetPosition(Vector2.new(10, 110))
-- Watermark:SetIconPosition("right")
-- Watermark:SetIcon("rbxassetid://136469174415866")
-- Watermark:SetAutoUpdate(false) -- Prevent HUD settings from replacing custom text.
-- Watermark:SetRefreshRate(0.25)

-- Obsidian-style custom draggable labels are independent from the HUD Watermark:
-- local StatusLabel = Library:AddDraggableLabel({
--     Text = "Custom status",
--     Icon = "rbxassetid://136469174415866",
--     IconPosition = "right",
--     Position = UDim2.fromOffset(10, 145)
-- })
-- StatusLabel:SetText("Updated status")
-- StatusLabel:SetVisible(false)

local Window = Library:CreateWindow({
    Title = "XoneScriptK",
    Size = UDim2.fromOffset(550, 555)
});

-- Search by control, groupbox, tab, or tooltip using the sidebar search box.
-- Press Ctrl+F to focus search, Enter to open the first result, or Escape to clear it.
-- Window:UpdateSearch("Toggle")
-- Window:ClearSearch()
-- Set DisableSearch = true in CreateWindow to hide the search box.

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
    Title = "Keybinds",
    Width = 220,
    VisibilityControl = true,
    ShowToggleState = true
});
-- Toggle rows can be clicked directly in the Keybinds panel.
-- KeybindList:ToggleCollapsed()
-- KeybindList:ToggleSettings()
-- Options.ToggleKeyPicker:SetMenuVisibility(false)

local Tabs = {
    Legit    = Window:AddTab("legit"),
    Rage     = Window:AddTab("rage"),
    Players  = Window:AddTab("players"),
    Visuals  = Window:AddTab("visuals"),
    Misc     = Window:AddTab("misc"),
    Media    = Window:AddTab("Media"),
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
-- Media tab: Viewport, Image, and custom GUI passthrough
--============================================================
local MediaBox = Tabs.Media:AddLeftGroupbox("Media")

local DemoModel = Instance.new("Part")
DemoModel.Name = "ViewportDemo"
DemoModel.Shape = Enum.PartType.Ball
DemoModel.Size = Vector3.new(2, 2, 2)
DemoModel.Color = Color3.fromRGB(128, 128, 128)
DemoModel.Material = Enum.Material.Neon

MediaBox:AddViewport("DemoViewport", {
    Object = DemoModel,
    Height = 180,
    Interactive = true,
    Clone = true,
    AutoFocus = true
})

MediaBox:AddImage("DemoImage", {
    Image = "rbxassetid://136469174415866",
    Height = 100,
    ScaleType = Enum.ScaleType.Fit,
    BackgroundTransparency = 1
})

local PlaybackBox = Tabs.Media:AddRightGroupbox("Playback")

local CustomLabel = Instance.new("TextLabel")
CustomLabel.Size = UDim2.fromScale(1, 1)
CustomLabel.Active = true
CustomLabel.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
CustomLabel.BorderSizePixel = 0
CustomLabel.Text = "Custom GUI embedded with AddUIPassthrough"
CustomLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomLabel.TextSize = 12
CustomLabel.Font = Enum.Font.Code

PlaybackBox:AddUIPassthrough("CustomLabel", {
    Instance = CustomLabel,
    Height = 42
})

-- Right-click or long-press the custom label to open this context menu.
local CustomMenu = Library:AddContextMenu(CustomLabel, UDim2.fromOffset(190, 0), function()
    return { 0, CustomLabel.AbsoluteSize.Y + 4 }
end, 1)

CustomMenu:AddLabel("Custom GUI Actions")
CustomMenu:AddButton({
    Text = "Change Text",
    KeepOpen = true,
    Func = function()
        CustomLabel.Text = "Text changed by the context menu"
    end
})
CustomMenu:AddDivider()
CustomMenu:AddButton("Reset Text", function()
    CustomLabel.Text = "Custom GUI embedded with AddUIPassthrough"
end)
CustomMenu:Bind()

Library:OnUnload(function()
    DemoModel:Destroy()
end)

--============================================================
-- Settings tab
--============================================================
-- Menu and HUD come from the library; Configuration and Themes come from Addons.
Tabs.Settings:ApplySettings()
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:ApplyToTab(Tabs.Settings)

local CustomBox = Tabs.Settings:AddLeftGroupbox("My Section")
CustomBox:AddButton("Test Notification", function()
    Library:Notify("Hello there", 4)
end)

CustomBox:AddButton({
    Text = "My Button",
    Func = function()
        print("custom settings button")
    end
})

CustomBox:AddButton({
    Text = "Unload UI",
    DoubleClick = true,
    Func = function()
        Library:Unload()
    end
})

-- Menu and HUD controls are accessible through SettingsControls:
-- local C = Tabs.Settings.SettingsControls
-- C.UIScale:Set(130)
-- C.LiteAnimations:Set(true)
-- C.Watermark:Set(false)
-- C.MenuKeybind:SetKey(Enum.KeyCode.Insert)
-- C.Sections.Menu / C.Sections.HUD
-- C.Unload()

-- Configuration and theme APIs are provided by the Addons:
-- SaveManager:Save("pvp") / SaveManager:Load("pvp") / SaveManager:Delete("pvp")
-- SaveManager:SaveAutoloadConfig("pvp") / SaveManager:DeleteAutoLoadConfig()
-- local JSON, Success = SaveManager:SaveJSON()
-- SaveManager:LoadJSON(JSON)
-- ThemeManager:ApplyTheme("Nord") / ThemeManager:SaveCustomTheme("MyTheme")
-- ThemeManager:SaveDefault("Nord") / ThemeManager:DeleteDefaultTheme()
-- local ThemeJSON, ThemeSuccess = ThemeManager:SaveJSON()
-- ThemeManager:LoadJSON(ThemeJSON)
-- ThemeManager:SetDefaultTheme({ Accent = Color3.fromHex("808080") }) -- before ApplyToTab

-- Load autoload after every control and Addon has been created.
SaveManager:LoadAutoloadConfig()

-- Library:OnUnload(function()
--     Stop loops, clear ESP, and restore modified properties here.
-- end)

Library:Notify({ Title = "XoneScriptK", Description = "Loaded!", Time = 2 });

-- XoneScriptK ThemeManager


local HttpService = game:GetService("HttpService")

local ThemeManager = {
    Library = nil,
    Folder = "XoneScriptK",
    AppliedToTab = false,
    DefaultThemeName = nil,
    ContrastLabel = nil,
    ContrastWasPoor = false,
    _Mounted = setmetatable({}, { __mode = "k" }),
    _UnloadBound = false,
    BuiltInThemes = {
        Default = { 1, { Accent = "808080" } },
        BBOT = { 2, { Accent = "7E48A3" } },
        Fatality = { 3, { Accent = "C50754" } },
        Jester = { 4, { Accent = "DB4467" } },
        Mint = { 5, { Accent = "3DB488" } },
        ["Tokyo Night"] = { 6, { Accent = "6759B3" } },
        Ubuntu = { 7, { Accent = "E2581E" } },
        Quartz = { 8, { Accent = "426E87" } },
        Nord = { 9, { Accent = "88C0D0" } },
        Dracula = { 10, { Accent = "FF79C6" } },
        Monokai = { 11, { Accent = "F92672" } },
        Gruvbox = { 12, { Accent = "FB4934" } },
        Solarized = { 13, { Accent = "CB4B16" } },
        Catppuccin = { 14, { Accent = "F5C2E7" } },
        ["One Dark"] = { 15, { Accent = "C678DD" } },
        Cyberpunk = { 16, { Accent = "00FF9F" } },
        ["Oceanic Next"] = { 17, { Accent = "6699CC" } },
        Material = { 18, { Accent = "82AAFF" } },
    },
}

local ContrastWarnThreshold = 4.5

local function Trim(Value)
    return tostring(Value or ""):match("^%s*(.-)%s*$")
end

local function IsEmpty(Value)
    return typeof(Value) ~= "string" or Trim(Value) == ""
end

local function IsValidFolder(Path)
    if typeof(Path) ~= "string" or Trim(Path) == "" or Path:find('[<>:"|%?%*%z]') then return false end
    for Part in Path:gmatch("[^/\\]+") do
        if Part == ".." then return false end
    end
    return true
end

local function IsValidName(Name)
    if IsEmpty(Name) or #Name > 100 or Name:find('[/\\<>:"|%?%*%z]') then return false end
    local Clean = Trim(Name)
    return Clean ~= "." and Clean ~= ".." and string.lower(Clean) ~= "default"
end

local function NormalizeFolder(Path)
    Path = Trim(Path):gsub("\\", "/"):gsub("/+", "/")
    return Path:gsub("/$", "")
end

local function SplitPath(Path)
    local Result, Current = {}, ""
    for Part in Path:gmatch("[^/]+") do
        Current = Current == "" and Part or Current .. "/" .. Part
        table.insert(Result, Current)
    end
    return Result
end

local function SafeIsFolder(Path)
    if type(isfolder) ~= "function" then return false end
    local Ok, Result = pcall(isfolder, Path)
    return Ok and Result == true
end

local function SafeIsFile(Path)
    if type(isfile) ~= "function" then return false end
    local Ok, Result = pcall(isfile, Path)
    return Ok and Result == true
end

local function GetThemesPath()
    if not IsValidFolder(ThemeManager.Folder) then return nil end
    return NormalizeFolder(ThemeManager.Folder) .. "/Themes"
end

local function GetThemePath(Name)
    local Path = GetThemesPath()
    if not Path or not IsValidName(Name) then return nil end
    return Path .. "/" .. Trim(Name) .. ".json"
end

local function GetDefaultPath()
    local Path = GetThemesPath()
    return Path and (Path .. "/default.txt") or nil
end

local function DoesThemeExist(Name, IncludeBuiltIn)
    if IncludeBuiltIn and ThemeManager.BuiltInThemes[Name] then return true end
    local Path = GetThemePath(Name)
    return Path ~= nil and SafeIsFile(Path)
end

local function Notify(Text, Time)
    if ThemeManager.Library then ThemeManager.Library:Notify(tostring(Text), Time or 4) end
end

local function ToHex(Color)
    return typeof(Color) == "Color3" and Color:ToHex() or "808080"
end

local function ParseColor(Value)
    if typeof(Value) == "Color3" then return Value end
    if typeof(Value) ~= "string" then return nil end
    local Ok, Color = pcall(Color3.fromHex, Value)
    return Ok and Color or nil
end

local function Linearize(Channel)
    if Channel <= 0.03928 then return Channel / 12.92 end
    return ((Channel + 0.055) / 1.055) ^ 2.4
end

local function Luminance(Color)
    return 0.2126 * Linearize(Color.R) + 0.7152 * Linearize(Color.G) + 0.0722 * Linearize(Color.B)
end

local function Contrast(A, B)
    local LA, LB = Luminance(A), Luminance(B)
    return (math.max(LA, LB) + 0.05) / (math.min(LA, LB) + 0.05)
end

function ThemeManager:SetLibrary(Library)
    assert(typeof(Library) == "table" and Library.SetAccent, "A XoneScriptK library instance is required")
    if self.Library ~= Library then
        self._Mounted = setmetatable({}, { __mode = "k" })
        self._UnloadBound = false
        self.ContrastLabel = nil
    end
    self.Library = Library
    Library.Addons = Library.Addons or {}
    Library.Addons.ThemeManager = self
    Library.ConfigSkipFlags = Library.ConfigSkipFlags or {}
    for _, Index in ipairs({
        "ThemeManager_Accent", "ThemeManager_ThemeList", "ThemeManager_CustomThemeList",
        "ThemeManager_CustomThemeName", "ThemeManager_ThemeJSON",
    }) do
        Library.ConfigSkipFlags[Index] = true
    end
    if not self._UnloadBound and Library.OnUnload then
        self._UnloadBound = true
        Library:OnUnload(function()
            self._Mounted = setmetatable({}, { __mode = "k" })
            self.ContrastLabel = nil
            self.AppliedToTab = false
        end)
    end
    return self
end

function ThemeManager:GetPaths()
    local Path = GetThemesPath()
    return Path and SplitPath(Path) or {}
end

function ThemeManager:BuildFolderTree(SkipWhenCreated)
    local Paths = self:GetPaths()
    if #Paths == 0 or type(makefolder) ~= "function" then return false end
    if SkipWhenCreated and SafeIsFolder(Paths[1]) then return true end
    for _, Path in ipairs(Paths) do
        if not SafeIsFolder(Path) then
            local Ok = pcall(makefolder, Path)
            if not Ok then return false end
        end
    end
    return true
end

function ThemeManager:CheckFolderTree()
    return self:BuildFolderTree(true)
end

function ThemeManager:SetFolder(Folder)
    assert(IsValidFolder(Folder), "Invalid folder path")
    self.Folder = NormalizeFolder(Folder)
    self:BuildFolderTree()
    return self
end

function ThemeManager:ReloadCustomThemes()
    local Path = GetThemesPath()
    if not Path or type(listfiles) ~= "function" then return {} end
    self:CheckFolderTree()
    local Ok, Files = pcall(listfiles, Path)
    if not Ok or typeof(Files) ~= "table" then return {} end
    local Names = {}
    for _, FilePath in ipairs(Files) do
        local Name = tostring(FilePath):gsub("\\", "/"):match("([^/]+)%.json$")
        if Name then table.insert(Names, Name) end
    end
    table.sort(Names, function(A, B) return string.lower(A) < string.lower(B) end)
    return Names
end

function ThemeManager:GetCustomTheme(Name)
    if IsEmpty(Name) then return nil end
    local Path = GetThemePath(Name)
    if not Path or not SafeIsFile(Path) or type(readfile) ~= "function" then return nil end
    local ReadOk, Content = pcall(readfile, Path)
    if not ReadOk then return nil end
    local DecodeOk, Data = pcall(HttpService.JSONDecode, HttpService, Content)
    if not DecodeOk or typeof(Data) ~= "table" then return nil end
    return Data
end

function ThemeManager:SaveJSON()
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    local Ok, Encoded = pcall(HttpService.JSONEncode, HttpService, { Accent = ToHex(self.Library.Accent) })
    if not Ok then return "", false, "Failed to encode theme data" end
    return Encoded, true
end

function ThemeManager:SaveCustomTheme(Name)
    if not IsValidName(Name) then return false, "Invalid or reserved theme name" end
    Name = Trim(Name)
    local Path = GetThemePath(Name)
    if not Path or type(writefile) ~= "function" then return false, "writefile is unavailable" end
    self:CheckFolderTree()
    local Encoded, Ok, EncodeError = self:SaveJSON()
    if not Ok then return false, EncodeError end
    local WriteOk, WriteError = pcall(writefile, Path, Encoded)
    if not WriteOk then return false, "Failed to write theme: " .. tostring(WriteError) end
    return true
end

function ThemeManager:Delete(Name)
    if IsEmpty(Name) then return false, "No theme selected" end
    local Path = GetThemePath(Name)
    if not Path or not SafeIsFile(Path) then return false, "Custom theme does not exist" end
    if type(delfile) ~= "function" then return false, "delfile is unavailable" end
    local Ok, ErrorMessage = pcall(delfile, Path)
    if not Ok then return false, "Failed to delete theme: " .. tostring(ErrorMessage) end
    if Name == self.DefaultThemeName then self:DeleteDefaultTheme() end
    return true
end

function ThemeManager:GetDefaultTheme()
    local Path = GetDefaultPath()
    if not Path then return "none", false, "Invalid path" end
    if not SafeIsFile(Path) then return "none", false, "Default theme is not set" end
    if type(readfile) ~= "function" then return "none", false, "readfile is unavailable" end
    local Ok, Name = pcall(readfile, Path)
    if not Ok or typeof(Name) ~= "string" then return "none", false, "Failed to read default theme" end
    Name = Trim(Name)
    if not DoesThemeExist(Name, true) then return "none", false, "Theme not found" end
    self.DefaultThemeName = Name
    return Name, true
end

function ThemeManager:SetDefaultTheme(Theme)
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    assert(not self.AppliedToTab, "Set the default theme before applying ThemeManager to a tab")
    assert(typeof(Theme) == "table", "Expected a theme table")
    local Color = ParseColor(Theme.Accent or Theme.AccentColor)
    if not Color then return false, "Theme must contain a valid Accent or AccentColor" end
    self.BuiltInThemes.Default = { 1, { Accent = Color:ToHex() } }
    self.Library:SetAccent(Color)
    return true
end

function ThemeManager:SaveDefault(Name)
    if IsEmpty(Name) then return false, "No theme selected" end
    if not DoesThemeExist(Name, true) then return false, "Theme does not exist" end
    local Path = GetDefaultPath()
    if not Path or type(writefile) ~= "function" then return false, "writefile is unavailable" end
    self:CheckFolderTree()
    local Ok, ErrorMessage = pcall(writefile, Path, Name)
    if not Ok then return false, tostring(ErrorMessage) end
    self.DefaultThemeName = Name
    return true
end

function ThemeManager:LoadDefault()
    local Name, Ok, FetchError = self:GetDefaultTheme()
    if not Ok then
        if FetchError ~= "Default theme is not set" then Notify("Default theme: " .. tostring(FetchError)) end
        return false, FetchError
    end
    local ApplyOk, ApplyError = self:ApplyTheme(Name)
    if not ApplyOk then
        Notify(string.format("Failed to apply default theme: %s", tostring(ApplyError)))
        return false, ApplyError
    end
    local List = self.Library.Options.ThemeManager_ThemeList
    if List and self.BuiltInThemes[Name] then List:SetValue(Name) end
    local CustomList = self.Library.Options.ThemeManager_CustomThemeList
    if CustomList and self:GetCustomTheme(Name) then CustomList:SetValue(Name) end
    Notify(string.format("Applied default theme %q", Name), 3)
    return true
end

function ThemeManager:DeleteDefaultTheme()
    local Path = GetDefaultPath()
    if not Path then return false, "Invalid path" end
    if not SafeIsFile(Path) then
        self.DefaultThemeName = nil
        return true
    end
    if type(delfile) ~= "function" then return false, "delfile is unavailable" end
    local Ok, ErrorMessage = pcall(delfile, Path)
    if not Ok then return false, tostring(ErrorMessage) end
    self.DefaultThemeName = nil
    return true
end

function ThemeManager:GetContrastReport()
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    local Palette = self.Library.Palette and self.Library.Palette.Default or {}
    local Background = Palette.ContentTop or Palette.Top or Color3.fromHex("151515")
    local Ratio = Contrast(self.Library.Accent, Background)
    return {
        Ratio = Ratio,
        PairName = "accent color vs. background color",
        Passes = Ratio >= ContrastWarnThreshold,
    }
end

function ThemeManager:UpdateContrastWarning()
    local Label = self.ContrastLabel
    if not Label then return end
    local Report = self:GetContrastReport()
    if Report.Passes then
        Label:SetText(string.format("Contrast check: good (%.1f:1)", Report.Ratio))
        Label:SetColor(Color3.fromHex("BFC4CC"))
    else
        Label:SetText(string.format(
            "Low accent contrast: %.1f:1. Aim for at least %.1f:1.",
            Report.Ratio, ContrastWarnThreshold
        ))
        Label:SetColor(Color3.fromHex("F97583"))
        if not self.ContrastWasPoor then
            Notify("The accent may be difficult to see against the background", 5)
        end
    end
    self.ContrastWasPoor = not Report.Passes
end

function ThemeManager:ThemeUpdate()
    self:UpdateContrastWarning()
end

function ThemeManager:ApplyThemeData(Data)
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    if typeof(Data) ~= "table" then return false, "Invalid theme data" end
    local Color = ParseColor(Data.Accent or Data.AccentColor)
    if not Color then return false, "Theme must contain a valid Accent or AccentColor" end
    self.Library:SetAccent(Color)
    local Option = self.Library.Options.ThemeManager_Accent
    if Option then Option:SetValue(Color) end
    self:ThemeUpdate()
    return true
end

function ThemeManager:ApplyTheme(Name)
    if IsEmpty(Name) then return false, "No theme selected" end
    local Custom = self:GetCustomTheme(Name)
    local BuiltIn = self.BuiltInThemes[Name]
    if not Custom and not BuiltIn then return false, "Theme not found" end
    return self:ApplyThemeData(Custom or BuiltIn[2])
end

function ThemeManager:LoadJSON(Content)
    if IsEmpty(Content) then return false, "No JSON provided" end
    local Ok, Data = pcall(HttpService.JSONDecode, HttpService, Content)
    if not Ok or typeof(Data) ~= "table" then return false, "Failed to decode theme data" end
    return self:ApplyThemeData(Data)
end

function ThemeManager:CreateThemeManager(Groupbox)
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    assert(typeof(Groupbox) == "table" and Groupbox.AddColorPicker, "A XoneScriptK groupbox is required")
    if self._Mounted[Groupbox] then return Groupbox end
    self._Mounted[Groupbox] = true

    local Accent = Groupbox:AddColorPicker("ThemeManager_Accent", {
        Text = "Accent color", Default = self.Library.Accent,
    })
    Accent:OnChanged(function(Color)
        self.Library:SetAccent(Color)
        self:ThemeUpdate()
    end)
    self.ContrastLabel = Groupbox:AddLabel("Contrast check: ...")

    local BuiltInNames = {}
    for Name in pairs(self.BuiltInThemes) do table.insert(BuiltInNames, Name) end
    table.sort(BuiltInNames, function(A, B)
        return self.BuiltInThemes[A][1] < self.BuiltInThemes[B][1]
    end)

    Groupbox:AddDivider()
    local ThemeList = Groupbox:AddDropdown("ThemeManager_ThemeList", {
        Text = "Built-in themes", Values = BuiltInNames, Default = "Default", Multi = false,
    })
    ThemeList:OnChanged(function(Name)
        if IsEmpty(Name) then return end
        local Ok, ErrorMessage = self:ApplyTheme(Name)
        if not Ok then Notify(ErrorMessage) end
    end)
    Groupbox:AddButton("Set built-in as default", function()
        local Name = ThemeList.Value
        local Ok, ErrorMessage = self:SaveDefault(Name)
        Notify(Ok and string.format("Default theme set to %q", Name) or tostring(ErrorMessage))
    end)

    Groupbox:AddDivider()
    local CustomList, RefreshCustomList
    local CustomName = Groupbox:AddInput("ThemeManager_CustomThemeName", { Text = "Custom theme name" })
    Groupbox:AddButton("Create / overwrite theme", function()
        local Name = Trim(CustomName.Value)
        local Ok, ErrorMessage = self:SaveCustomTheme(Name)
        Notify(Ok and string.format("Saved theme %q", Name) or tostring(ErrorMessage))
        if Ok then RefreshCustomList() end
    end)

    function RefreshCustomList()
        local Selected = CustomList and CustomList.Value or nil
        local Names = self:ReloadCustomThemes()
        CustomList:SetValues(Names)
        if Selected and table.find(Names, Selected) then
            CustomList:SetValue(Selected)
        else
            CustomList:SetValue("")
        end
    end

    CustomList = Groupbox:AddDropdown("ThemeManager_CustomThemeList", {
        Text = "Custom themes", Values = self:ReloadCustomThemes(), AllowNull = true, Multi = false,
    })
    local function SelectedCustom()
        local Name = CustomList.Value
        if IsEmpty(Name) then Notify("Please select a custom theme first") return nil end
        return Name
    end

    Groupbox:AddButton("Load custom theme", function()
        local Name = SelectedCustom()
        if not Name then return end
        local Ok, ErrorMessage = self:ApplyTheme(Name)
        Notify(Ok and string.format("Loaded theme %q", Name) or tostring(ErrorMessage))
    end)
    Groupbox:AddButton({ Text = "Delete custom theme", Confirm = true, Func = function()
        local Name = SelectedCustom()
        if not Name then return end
        local Ok, ErrorMessage = self:Delete(Name)
        Notify(Ok and string.format("Deleted theme %q", Name) or tostring(ErrorMessage))
        if Ok then RefreshCustomList() end
    end })
    Groupbox:AddButton("Refresh custom themes", RefreshCustomList)
    Groupbox:AddButton("Set custom as default", function()
        local Name = SelectedCustom()
        if not Name then return end
        local Ok, ErrorMessage = self:SaveDefault(Name)
        Notify(Ok and string.format("Default theme set to %q", Name) or tostring(ErrorMessage))
    end)
    Groupbox:AddButton({ Text = "Reset default theme", Confirm = true, Func = function()
        local Ok, ErrorMessage = self:DeleteDefaultTheme()
        Notify(Ok and "Default theme cleared" or tostring(ErrorMessage))
    end })

    Groupbox:AddDivider()
    local ThemeJSON = Groupbox:AddInput("ThemeManager_ThemeJSON", { Text = "Theme JSON" })
    Groupbox:AddButton({ Text = "Import theme", Confirm = true, Func = function()
        local Ok, ErrorMessage = self:LoadJSON(ThemeJSON.Value)
        Notify(Ok and "Theme imported" or tostring(ErrorMessage))
    end })
    Groupbox:AddButton("Export current theme", function()
        local Encoded, Ok, ErrorMessage = self:SaveJSON()
        if not Ok then Notify(ErrorMessage) return end
        ThemeJSON:SetValue(Encoded)
        if type(setclipboard) == "function" then
            pcall(setclipboard, Encoded)
            Notify("Theme exported and copied to clipboard", 3)
        else
            Notify("Theme exported to the JSON field", 3)
        end
    end)

    self:UpdateContrastWarning()
    self:LoadDefault()
    return Groupbox
end

function ThemeManager:CreateGroupBox(Tab, IconName)
    assert(typeof(Tab) == "table" and Tab.AddGroupbox, "A XoneScriptK tab is required")
    return Tab:AddGroupbox({ Side = "Left", Name = "Themes", IconName = IconName or "paintbrush" })
end

function ThemeManager:ApplyToTab(Tab, IconName)
    assert(self.Library, "Call ThemeManager:SetLibrary(Library) first")
    if self._Mounted[Tab] then return self._Mounted[Tab] end
    local Groupbox = self:CreateGroupBox(Tab, IconName)
    self._Mounted[Tab] = Groupbox
    self.AppliedToTab = true
    return self:CreateThemeManager(Groupbox)
end

function ThemeManager:ApplyToGroupbox(Groupbox)
    return self:CreateThemeManager(Groupbox)
end

if getgenv then getgenv().XoneScriptKThemeManager = ThemeManager end
ThemeManager:BuildFolderTree()
return ThemeManager

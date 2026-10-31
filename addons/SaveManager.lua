-- XoneScriptK SaveManager

local HttpService = game:GetService("HttpService")

local SaveManager = {
    Library = nil,
    Folder = "XoneScriptK",
    SubFolder = "",
    Ignore = {},
    UseLoadingOrder = false,
    LoadingOrder = { "Dropdown", "Slider", "Input", "ColorPicker", "KeyPicker", "Toggle" },
    AutoloadConfig = nil,
    AppliedToTab = false,
    _Mounted = setmetatable({}, { __mode = "k" }),
    _UnloadBound = false,
}

local function Trim(Value)
    return tostring(Value or ""):match("^%s*(.-)%s*$")
end

local function IsEmpty(Value)
    return typeof(Value) ~= "string" or Trim(Value) == ""
end

local function IsValidFolder(Path)
    if typeof(Path) ~= "string" or Trim(Path) == "" or Path:find('[<>:"|%?%*%z]') then
        return false
    end
    for Part in Path:gmatch("[^/\\]+") do
        if Part == ".." then return false end
    end
    return true
end

local function IsValidName(Name, Reserved)
    if IsEmpty(Name) or #Name > 100 or Name:find('[/\\<>:"|%?%*%z]') then
        return false
    end
    Name = Trim(Name)
    if Name == "." or Name == ".." then return false end
    if Reserved and string.lower(Name) == string.lower(Reserved) then return false end
    return true
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

local function GetRootPath()
    if not IsValidFolder(SaveManager.Folder) then return nil end
    local Root = NormalizeFolder(SaveManager.Folder)
    if not IsEmpty(SaveManager.SubFolder) then
        Root = Root .. "/" .. NormalizeFolder(SaveManager.SubFolder)
    end
    return Root
end

local function GetSettingsPath()
    local Root = GetRootPath()
    return Root and (Root .. "/Configs") or nil
end

local function GetConfigPath(Name)
    local Path = GetSettingsPath()
    if not Path or not IsValidName(Name, "autoload") then return nil end
    return Path .. "/" .. Trim(Name) .. ".json"
end

local function GetAutoloadPath()
    local Path = GetRootPath()
    return Path and (Path .. "/Autoload.txt") or nil
end

local function DoesConfigExist(Name)
    local Path = GetConfigPath(Name)
    return Path ~= nil and SafeIsFile(Path)
end

local function Notify(Text, Time)
    if SaveManager.Library then
        SaveManager.Library:Notify(tostring(Text), Time or 4)
    end
end

local function CopyTable(Source)
    local Result = {}
    for Key, Value in pairs(Source or {}) do Result[Key] = Value end
    return Result
end

local function EncodePosition(Position)
    if typeof(Position) ~= "UDim2" then return nil end
    return {
        XS = Position.X.Scale, XO = Position.X.Offset,
        YS = Position.Y.Scale, YO = Position.Y.Offset,
    }
end

local function DecodePosition(Data)
    if typeof(Data) ~= "table" then return nil end
    local XS, XO = tonumber(Data.XS), tonumber(Data.XO)
    local YS, YO = tonumber(Data.YS), tonumber(Data.YO)
    if not (XS and XO and YS and YO) then return nil end
    return UDim2.new(XS, XO, YS, YO)
end

local function CaptureKeybindMenu()
    local Library = SaveManager.Library
    local Menu = Library and Library.KeybindMenu
    local Frame = Library and Library.KeybindFrame
    if not Menu and not Frame then return nil end

    local Hidden = {}
    for Index, Option in pairs(Library.Options or {}) do
        if Option.Type == "KeyPicker" and Option.GetMenuVisibility then
            local Ok, Visible = pcall(Option.GetMenuVisibility, Option)
            if Ok and Visible == false then Hidden[Index] = true end
        end
    end

    return {
        visible = Menu and Menu:GetVisible() or (Frame and Frame.Visible) or false,
        position = Frame and EncodePosition(Frame.Position) or nil,
        collapsed = Menu and (Menu.Collapsed == true or Menu._Collapsed == true) or false,
        hidden = Hidden,
    }
end

local function RestoreKeybindMenu(Data)
    local Library = SaveManager.Library
    local Menu = Library and Library.KeybindMenu
    local Frame = Library and Library.KeybindFrame
    if typeof(Data) ~= "table" or not (Menu or Frame) then return end

    local Position = DecodePosition(Data.position)
    if Position then
        if Menu and Menu.SetPosition then Menu:SetPosition(Position)
        elseif Frame then Frame.Position = Position end
    end
    if Menu then
        if Menu.SetCollapsed then Menu:SetCollapsed(Data.collapsed == true) end
        if Menu.SetVisible then Menu:SetVisible(Data.visible == true) end
        if Menu.SetSettingsOpen then Menu:SetSettingsOpen(false) end
    elseif Frame then
        Frame.Visible = Data.visible == true
    end

    if typeof(Data.hidden) == "table" then
        for Index, Option in pairs(Library.Options or {}) do
            if Option.Type == "KeyPicker" and Option.SetMenuVisibility then
                pcall(Option.SetMenuVisibility, Option, Data.hidden[Index] ~= true)
            end
        end
    end
end

function SaveManager:SetLibrary(Library)
    assert(typeof(Library) == "table", "A XoneScriptK library instance is required")
    if self.Library ~= Library then
        self._Mounted = setmetatable({}, { __mode = "k" })
        self._UnloadBound = false
    end
    self.Library = Library
    Library.Addons = Library.Addons or {}
    Library.Addons.SaveManager = self
    Library.ConfigSkipFlags = Library.ConfigSkipFlags or {}
    Library.ConfigSkipFlags.__XoneScriptK = true
    for _, Index in ipairs({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_JSON" }) do
        Library.ConfigSkipFlags[Index] = true
    end

    if not self._UnloadBound and Library.OnUnload then
        self._UnloadBound = true
        Library:OnUnload(function()
            self._Mounted = setmetatable({}, { __mode = "k" })
            self.AppliedToTab = false
        end)
    end
    return self
end

function SaveManager:SetLoadingOrder(Enabled, Order)
    self.UseLoadingOrder = Enabled == true
    if typeof(Order) == "table" then self.LoadingOrder = Order end
end

function SaveManager:SetIgnoreIndexes(Indexes)
    assert(typeof(Indexes) == "table", "Expected a table of option indexes")
    for _, Index in ipairs(Indexes) do self.Ignore[Index] = true end
end

function SaveManager:IgnoreThemeSettings()
    local Indexes = {
        "Accent", "ThemeName", "ThemeManager_Accent", "ThemeManager_ThemeList",
        "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", "ThemeManager_ThemeJSON",
        "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
        "FontFace", "BackgroundImage",
    }
    self:SetIgnoreIndexes(Indexes)
    if self.Library then
        self.Library.ConfigSkipFlags = self.Library.ConfigSkipFlags or {}
        for _, Index in ipairs(Indexes) do self.Library.ConfigSkipFlags[Index] = true end
    end
end

function SaveManager:GetPaths()
    local Path = GetSettingsPath()
    return Path and SplitPath(Path) or {}
end

function SaveManager:BuildFolderTree(SkipWhenCreated)
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

function SaveManager:CheckFolderTree()
    return self:BuildFolderTree(true)
end

function SaveManager:CheckSubFolder(CreateFolder)
    local Root = GetRootPath()
    if not Root or IsEmpty(self.SubFolder) then return false end
    if CreateFolder then return self:BuildFolderTree() end
    return SafeIsFolder(Root)
end

function SaveManager:SetFolder(Folder)
    assert(IsValidFolder(Folder), "Invalid folder path")
    self.Folder = NormalizeFolder(Folder)
    self:BuildFolderTree()
    return self
end

function SaveManager:SetSubFolder(SubFolder)
    if IsEmpty(SubFolder) then
        self.SubFolder = ""
    else
        assert(IsValidFolder(SubFolder), "Invalid subfolder path")
        self.SubFolder = NormalizeFolder(SubFolder)
    end
    self:BuildFolderTree()
    return self
end

function SaveManager:RefreshConfigList()
    local Path = GetSettingsPath()
    if not Path then return {} end
    self:CheckFolderTree()
    if type(listfiles) ~= "function" then return {} end

    local Ok, Files = pcall(listfiles, Path)
    if not Ok or typeof(Files) ~= "table" then return {} end
    local Names = {}
    for _, FilePath in ipairs(Files) do
        local Name = tostring(FilePath):gsub("\\", "/"):match("([^/]+)%.json$")
        if Name and string.lower(Name) ~= "autoload" then table.insert(Names, Name) end
    end
    table.sort(Names, function(A, B) return string.lower(A) < string.lower(B) end)
    return Names
end

function SaveManager:SaveJSON(ConfigName)
    assert(self.Library, "Call SaveManager:SetLibrary(Library) first")
    local Ok, Values = pcall(self.Library.SerializeConfig, self.Library)
    if not Ok or typeof(Values) ~= "table" then
        return "", false, "Failed to serialize XoneScriptK options"
    end

    Values = CopyTable(Values)
    for Index in pairs(self.Ignore) do Values[Index] = nil end
    Values.__XoneScriptK = {
        version = 1,
        name = ConfigName or "",
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        keybindMenu = CaptureKeybindMenu(),
    }

    local EncodedOk, Encoded = pcall(HttpService.JSONEncode, HttpService, Values)
    if not EncodedOk then return "", false, "Failed to encode config data" end
    return Encoded, true
end

function SaveManager:Save(ConfigName)
    if not IsValidName(ConfigName, "autoload") then return false, "Invalid config name" end
    ConfigName = Trim(ConfigName)
    local Path = GetConfigPath(ConfigName)
    if not Path then return false, "Invalid config path" end
    if type(writefile) ~= "function" then return false, "writefile is unavailable" end
    self:CheckFolderTree()

    local Encoded, Ok, EncodeError = self:SaveJSON(ConfigName)
    if not Ok then return false, EncodeError end
    local WriteOk, WriteError = pcall(writefile, Path, Encoded)
    if not WriteOk then return false, "Failed to write config: " .. tostring(WriteError) end
    return true
end

local function ApplyValue(Library, Index, Value)
    local Entry = Library.Options[Index]
    if Entry and Entry.Load then
        pcall(Entry.Load, Value)
    elseif typeof(Value) == "table" and Value._t == "Color3" then
        Library.Flags[Index] = Color3.fromHex(Value.v)
    else
        Library.Flags[Index] = Value
    end
end

function SaveManager:LoadJSON(Content)
    assert(self.Library, "Call SaveManager:SetLibrary(Library) first")
    if IsEmpty(Content) then return false, "No JSON provided" end
    local Ok, Decoded = pcall(HttpService.JSONDecode, HttpService, Content)
    if not Ok or typeof(Decoded) ~= "table" then return false, "Failed to decode config data" end

    local Values = typeof(Decoded.values) == "table" and Decoded.values or Decoded
    local Metadata = Decoded.__XoneScriptK
    Values = CopyTable(Values)
    Values.__XoneScriptK = nil
    for Index in pairs(self.Ignore) do Values[Index] = nil end

    if self.UseLoadingOrder then
        local Remaining = CopyTable(Values)
        for _, TypeName in ipairs(self.LoadingOrder) do
            for Index, Value in pairs(Values) do
                local Entry = self.Library.Options[Index]
                if Entry and Entry.Type == TypeName and not self.Library.ConfigSkipFlags[Index] then
                    ApplyValue(self.Library, Index, Value)
                    Remaining[Index] = nil
                end
            end
        end
        self.Library:ApplyConfig(Remaining)
    else
        self.Library:ApplyConfig(Values)
    end

    RestoreKeybindMenu(Metadata and Metadata.keybindMenu or Decoded.keybindMenu)
    return true
end

function SaveManager:Load(ConfigName)
    if IsEmpty(ConfigName) then return false, "No config selected" end
    local Path = GetConfigPath(ConfigName)
    if not Path or not SafeIsFile(Path) then return false, "Config file does not exist" end
    if type(readfile) ~= "function" then return false, "readfile is unavailable" end
    local Ok, Content = pcall(readfile, Path)
    if not Ok then return false, "Failed to read config file" end
    return self:LoadJSON(Content)
end

function SaveManager:Delete(ConfigName)
    if IsEmpty(ConfigName) then return false, "No config selected" end
    local Path = GetConfigPath(ConfigName)
    if not Path or not SafeIsFile(Path) then return false, "Config file does not exist" end
    if type(delfile) ~= "function" then return false, "delfile is unavailable" end
    local Ok, ErrorMessage = pcall(delfile, Path)
    if not Ok then return false, "Failed to delete config: " .. tostring(ErrorMessage) end
    if ConfigName == self.AutoloadConfig then self:DeleteAutoLoadConfig() end
    return true
end

function SaveManager:GetAutoloadConfig()
    local Path = GetAutoloadPath()
    if not Path then return "none", false, "Invalid path" end
    if not SafeIsFile(Path) then return "none", false, "Autoload config is not set" end
    if type(readfile) ~= "function" then return "none", false, "readfile is unavailable" end
    local Ok, Name = pcall(readfile, Path)
    if not Ok or typeof(Name) ~= "string" then return "none", false, "Failed to read autoload config" end
    Name = Trim(Name)
    if Name == "" then return "none", false, "Autoload config is not set" end
    if not DoesConfigExist(Name) then return "none", false, "Config file not found" end
    self.AutoloadConfig = Name
    return Name, true
end

function SaveManager:SaveAutoloadConfig(ConfigName)
    if IsEmpty(ConfigName) then return false, "No config selected" end
    if not DoesConfigExist(ConfigName) then return false, "Config does not exist" end
    local Path = GetAutoloadPath()
    if not Path or type(writefile) ~= "function" then return false, "writefile is unavailable" end
    self:CheckFolderTree()
    local Ok, ErrorMessage = pcall(writefile, Path, ConfigName)
    if not Ok then return false, tostring(ErrorMessage) end
    self.AutoloadConfig = ConfigName
    return true
end

function SaveManager:LoadAutoloadConfig()
    local Name, Ok, FetchError = self:GetAutoloadConfig()
    if not Ok then
        if FetchError ~= "Autoload config is not set" then Notify("Autoload: " .. tostring(FetchError)) end
        return false, FetchError
    end
    local LoadOk, LoadError = self:Load(Name)
    if not LoadOk then
        Notify(string.format("Failed to autoload %q: %s", Name, tostring(LoadError)))
        return false, LoadError
    end
    Notify(string.format("Auto-loaded config %q", Name), 3)
    return true
end

function SaveManager:DeleteAutoLoadConfig()
    local Path = GetAutoloadPath()
    if not Path then return false, "Invalid path" end
    if not SafeIsFile(Path) then
        self.AutoloadConfig = nil
        return true
    end
    if type(delfile) ~= "function" then return false, "delfile is unavailable" end
    local Ok, ErrorMessage = pcall(delfile, Path)
    if not Ok then return false, tostring(ErrorMessage) end
    self.AutoloadConfig = nil
    return true
end

function SaveManager:ApplyToGroupbox(Groupbox)
    assert(self.Library, "Call SaveManager:SetLibrary(Library) first")
    assert(typeof(Groupbox) == "table" and Groupbox.AddInput, "A XoneScriptK groupbox is required")
    if self._Mounted[Groupbox] then return Groupbox end
    self._Mounted[Groupbox] = true

    local ConfigName = Groupbox:AddInput("SaveManager_ConfigName", { Text = "Config name" })
    local ConfigList, ConfigJSON, AutoloadLabel

    local function RefreshList()
        local Selected = ConfigList and ConfigList.Value or nil
        local Names = self:RefreshConfigList()
        ConfigList:SetValues(Names)
        if Selected and table.find(Names, Selected) then
            ConfigList:SetValue(Selected)
        else
            ConfigList:SetValue("")
        end
    end

    local function RefreshAutoload()
        local Name = self:GetAutoloadConfig()
        AutoloadLabel:SetText("Current autoload config: " .. tostring(Name))
        RefreshList()
    end

    local function SelectedConfig()
        local Name = ConfigList.Value
        if IsEmpty(Name) then Notify("Please select a config first") return nil end
        return Name
    end

    Groupbox:AddButton("Create / overwrite config", function()
        local Name = Trim(ConfigName.Value)
        if not IsValidName(Name, "autoload") then Notify("Enter a valid config name") return end
        local Ok, ErrorMessage = self:Save(Name)
        Notify(Ok and string.format("Saved config %q", Name) or tostring(ErrorMessage))
        if Ok then RefreshList() end
    end)

    Groupbox:AddDivider()
    ConfigList = Groupbox:AddDropdown("SaveManager_ConfigList", {
        Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true, Multi = false,
    })
    Groupbox:AddButton("Load config", function()
        local Name = SelectedConfig()
        if not Name then return end
        local Ok, ErrorMessage = self:Load(Name)
        Notify(Ok and string.format("Loaded config %q", Name) or tostring(ErrorMessage))
    end)
    Groupbox:AddButton({ Text = "Delete config", Confirm = true, Func = function()
        local Name = SelectedConfig()
        if not Name then return end
        local Ok, ErrorMessage = self:Delete(Name)
        Notify(Ok and string.format("Deleted config %q", Name) or tostring(ErrorMessage))
        if Ok then RefreshAutoload() end
    end })
    Groupbox:AddButton("Refresh list", RefreshList)

    Groupbox:AddDivider()
    Groupbox:AddButton("Set as autoload", function()
        local Name = SelectedConfig()
        if not Name then return end
        local Ok, ErrorMessage = self:SaveAutoloadConfig(Name)
        Notify(Ok and string.format("Autoload set to %q", Name) or tostring(ErrorMessage))
        if Ok then RefreshAutoload() end
    end)
    Groupbox:AddButton({ Text = "Reset autoload", Confirm = true, Func = function()
        local Ok, ErrorMessage = self:DeleteAutoLoadConfig()
        Notify(Ok and "Autoload cleared" or tostring(ErrorMessage))
        if Ok then RefreshAutoload() end
    end })
    AutoloadLabel = Groupbox:AddLabel("Current autoload config: ...")

    Groupbox:AddDivider()
    ConfigJSON = Groupbox:AddInput("SaveManager_JSON", { Text = "Config JSON" })
    Groupbox:AddButton({ Text = "Import config", Confirm = true, Func = function()
        local Ok, ErrorMessage = self:LoadJSON(ConfigJSON.Value)
        Notify(Ok and "Config imported" or tostring(ErrorMessage))
    end })
    Groupbox:AddButton("Export current config", function()
        local Encoded, Ok, ErrorMessage = self:SaveJSON()
        if not Ok then Notify(ErrorMessage) return end
        ConfigJSON:SetValue(Encoded)
        if type(setclipboard) == "function" then
            pcall(setclipboard, Encoded)
            Notify("Config exported and copied to clipboard", 3)
        else
            Notify("Config exported to the JSON field", 3)
        end
    end)

    self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_JSON" })
    RefreshAutoload()
    return Groupbox
end

function SaveManager:BuildConfigSection(Tab, IconName)
    assert(self.Library, "Call SaveManager:SetLibrary(Library) first")
    assert(typeof(Tab) == "table" and Tab.AddGroupbox, "A XoneScriptK tab is required")
    if self._Mounted[Tab] then return self._Mounted[Tab] end
    local Groupbox = Tab:AddGroupbox({
        Side = "Right", Name = "Configuration", IconName = IconName or "folder-cog",
    })
    self._Mounted[Tab] = Groupbox
    self.AppliedToTab = true
    return self:ApplyToGroupbox(Groupbox)
end

function SaveManager:ApplyToTab(Tab, IconName)
    return self:BuildConfigSection(Tab, IconName)
end

if getgenv then getgenv().XoneScriptKSaveManager = SaveManager end
SaveManager:BuildFolderTree()
return SaveManager

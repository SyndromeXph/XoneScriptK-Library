--[[
__   __  _  __
\ \ / / | |/ /
 \ V /  | ' / 
  > <   |  <  
 / . \  | . \ 
/_/ \_\ |_|\_\
       Github - https://github.com/SyndromeXph/XoneScriptK-Library
       Author: Yuxingchen
       License: MIT
]]

local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");
local HttpService = game:GetService("HttpService");
local GuiService = game:GetService("GuiService");
local RunService = game:GetService("RunService");
local CoreGui = game:GetService("CoreGui");
local TweenService = game:GetService("TweenService");
local HapticService = game:GetService("HapticService");
local GuiInset = GuiService:GetGuiInset().Y;
local IsMobilePlatform = (function()
	if getgenv and type(getgenv) == "function" then
		local Ok, Env = pcall(getgenv);
		if Ok and Env and Env.CoincideMobile ~= nil then
			return Env.CoincideMobile and true or false;
		end;
	end;
	local OkPlat, Plat = pcall(function() return UserInputService:GetPlatform() end);
	if OkPlat and (Plat == Enum.Platform.Android or Plat == Enum.Platform.IOS) then
		return true;
	end;
	if not UserInputService.TouchEnabled then return false end;
	if not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled then return true end;
	local Cam = Workspace.CurrentCamera;
	local Vp = Cam and Cam.ViewportSize or Vector2.new(800, 600);
	return math.min(Vp.X, Vp.Y) < 500;
end)();
local MobileUIScaleValue = 1;
local function ClampWindowSize(Width, Height)
	if not IsMobilePlatform then return Width, Height end;
	return math.min(Width, 1600), math.min(Height, 1600);
end;
local NewColorSequence = ColorSequence.new;
local NewColorSequenceKeypoint = ColorSequenceKeypoint.new;
local NewNumberSequence = NumberSequence.new;
local NewNumberSequenceKeypoint = NumberSequenceKeypoint.new;
function FakePointer()
	local A = math.random(0, 0xFFFFFF);
	local B = math.random(0, 0xFFFFFF);
	local Hex = string.format("%06x%06x", A, B);
	return setmetatable({}, {
		__tostring = function()
			return "function: 0x" .. Hex;
		end;
	});
end;
local Library = {
	Flags = {};
	Toggles = {};
	Options = {};
	Connections = {};
	Directory = "XoneScriptK";
	Folders = { "/Fonts", "/Configs", "/Logs" };
	CurrentlyOpen = nil;
	AnimationSpeed = 1;
	LogFile = "XoneScriptK/Logs/Session.log";
	DefaultLogo = "rbxassetid://136469174415866";
    Version = "0.2c debug";
};
Library._GradLerps = {}
local Palette = {
	Default = {
		Top = Color3.fromHex("161616");
		Bottom = Color3.fromHex("1E1E1E");
		ContentTop = Color3.fromHex("151515");
		ContentBottom = Color3.fromHex("171717");
		FooterTop = Color3.fromHex("151515");
		FooterBottom = Color3.fromHex("1F1F1F");
		Outline = Color3.fromHex("000105");
		InnerOutline = Color3.fromHex("252527");
		TitleTop = Color3.fromHex("F3F4F8");
		TitleBottom = Color3.fromHex("808080");
		TabActive = Color3.fromHex("808080");
		Accent = Color3.fromHex("808080");
		TabInactive = Color3.fromHex("BFC4CC");
	};
};
Library.Palette = Palette;
Library.Accent          = Palette.Default.Accent;
Library.AccentParts     = {};
Library.AccentGradients = {};
Library.AccentCallbacks = {};
local function LightenAccent(C)
	return C:Lerp(Color3.fromRGB(255, 255, 255), 0.6);
end;
function Library:RegisterAccent(Inst, Prop)
	Prop = Prop or "BackgroundColor3";
	table.insert(self.AccentParts, { Inst = Inst, Prop = Prop });
	Inst[Prop] = self.Accent;
end;
function Library:GetVersion()
	return Library.Version or "Unknown"
end
print(Library:GetVersion())
do
local function check()
	local path = "XoneScriptK"
	if not isfolder("XoneScriptK") then
		if not makefolder("XoneScriptK") then
			getgenv().failreason = 1
			return false
		end
	end
	if not hookmetamethod then
		getgenv().failreason = 4
		return false
	end
	if not hookfunction then
		getgenv().failreason = 5
		return false
	end
	if not setreadonly then
		getgenv().failreason = 6
		return false
	end
	if not getrawmetatable then
		getgenv().failreason = 7
		return false
	end
	if not setrawmetatable then
		getgenv().failreason = 8
		return false
	end
	if not debug then
		getgenv().failreason = 9
		return false
	end
	if not getscriptbytecode then
		getgenv().failreason = 10
		return false
	end
	if not game then
		getgenv().failreason = 11
		return false
	end
	if not game.HttpGet then
		getgenv().failreason = 12
		return false
	end
	if not game.GetObjects then
		getgenv().failreason = 13
		return false
	end
	if not loadstring then
		getgenv().failreason = 14
		return false
	end
	if not workspace then
		getgenv().failreason = 15
		return false
	end
	if not game:GetService("Players") then
		getgenv().failreason = 16
		return false
	end
	if not firetouchinterest then
		getgenv().failreason = 17
		return false
	end
	getgenv().failreason = 0
	return true
end
function ResolveLoaderImage(Source)
    if Source == false then return nil end
    local function ValidImage(D)
        return type(D) == "string" and #D > 100
            and (string.sub(D, 1, 4) == "\137PNG" or string.sub(D, 1, 2) == "\255\216")
    end
    if Source == nil then Source = Library._CustomLogo or Library.DefaultLogo end
    if typeof(Source) == "number" then Source = "rbxassetid://" .. tostring(Source) end
    if typeof(Source) ~= "string" then return nil end
    local Id = string.match(Source, "^rbxassetid://(%d+)$")
    if Id then
        local Ok, D = pcall(function()
            return game:HttpGet("https://assetdelivery.roblox.com/v1/asset?id=" .. Id)
        end)
        if Ok and ValidImage(D) then return D end
        return nil
    end
    if string.match(Source, "^https?://") then
        local Ok, D = pcall(function() return game:HttpGet(Source) end)
        if Ok and ValidImage(D) then return D end
        return nil
    end
    if isfile and isfile(Source) then
        local Ok, D = pcall(readfile, Source)
        if Ok and ValidImage(D) then return D end
    end
    return nil
end
function BuildDrawingLoader(Title, WindowSize, LogoSrc)
    local Camera = Workspace.CurrentCamera
    local Drawings = {}
    local MiddleX = (Camera.ViewportSize.X / 2) - (WindowSize.X / 2)
    local MiddleY = (Camera.ViewportSize.Y / 2) - (WindowSize.Y / 2)
    local WindowOutline = Drawing.new("Square")
    WindowOutline.Size = WindowSize
    WindowOutline.Thickness = 0
    WindowOutline.Color = Color3.fromHex("#000005")
    WindowOutline.Visible = false
    WindowOutline.Filled = true
    WindowOutline.Position = Vector2.new(MiddleX, MiddleY)
    table.insert(Drawings, WindowOutline)
    local WindowOutlineBorder = Drawing.new("Square")
    WindowOutlineBorder.Size = Vector2.new(WindowOutline.Size.X - 2, WindowOutline.Size.Y - 2)
    WindowOutlineBorder.Position = Vector2.new(WindowOutline.Position.X + 1, WindowOutline.Position.Y + 1)
    WindowOutlineBorder.Thickness = 0
    WindowOutlineBorder.Color = Color3.fromHex("#7885f5")
    WindowOutlineBorder.Visible = false
    WindowOutlineBorder.Filled = true
    table.insert(Drawings, WindowOutlineBorder)
    local WindowFrame = Drawing.new("Square")
    WindowFrame.Size = Vector2.new(WindowOutlineBorder.Size.X - 2, WindowOutlineBorder.Size.Y - 2)
    WindowFrame.Position = Vector2.new(WindowOutlineBorder.Position.X + 1, WindowOutlineBorder.Position.Y + 1)
    WindowFrame.Thickness = 0
    WindowFrame.Transparency = 1
    WindowFrame.Color = Color3.fromHex("#191919")
    WindowFrame.Visible = false
    WindowFrame.Filled = true
    table.insert(Drawings, WindowFrame)
    local WindowTitle = Drawing.new("Text")
    WindowTitle.Font = Drawing.Fonts.Plex
    WindowTitle.Size = 13
    WindowTitle.Color = Color3.fromHex("#e8e8e8")
    WindowTitle.Text = Title
    WindowTitle.Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2), WindowOutlineBorder.Position.Y + 8)
    WindowTitle.Visible = false
    WindowTitle.Center = true
    WindowTitle.Outline = false
    table.insert(Drawings, WindowTitle)
    local WindowText = Drawing.new("Text")
    WindowText.Font = Drawing.Fonts.Plex
    WindowText.Size = 13
    WindowText.Color = Color3.fromHex("#e8e8e8")
    WindowText.Visible = false
    WindowText.Center = true
    WindowText.Outline = false
    table.insert(Drawings, WindowText)
    local SliderInline = Drawing.new("Square")
    SliderInline.Size = Vector2.new(205, 15)
    SliderInline.Color = Color3.fromHex("#323232")
    SliderInline.Transparency = 0.75
    SliderInline.Thickness = 0
    SliderInline.Visible = false
    SliderInline.Filled = true
    table.insert(Drawings, SliderInline)
    local SliderOutline = Drawing.new("Square")
    SliderOutline.Size = Vector2.new(SliderInline.Size.X - 2, SliderInline.Size.Y - 2)
    SliderOutline.Color = Color3.fromHex("#000005")
    SliderOutline.Transparency = 0.5
    SliderOutline.Thickness = 0
    SliderOutline.Visible = false
    SliderOutline.Filled = true
    table.insert(Drawings, SliderOutline)
    local SliderFrame = Drawing.new("Square")
    SliderFrame.Color = Color3.fromHex("#7885f5")
    SliderFrame.Transparency = 0.75
    SliderFrame.Thickness = 0
    SliderFrame.Visible = false
    SliderFrame.Filled = true
    table.insert(Drawings, SliderFrame)
    local SliderTip = Drawing.new("Square")
    SliderTip.Color = Color3.fromHex("#b9c1ff")
    SliderTip.Transparency = 0.45
    SliderTip.Thickness = 0
    SliderTip.Visible = false
    SliderTip.Filled = true
    table.insert(Drawings, SliderTip)
    local MiddleIcon = Drawing.new("Image");
    MiddleIcon.Size = Vector2.new(185, 185);
    MiddleIcon.Rounding = 5;
    MiddleIcon.Transparency = 1;
    MiddleIcon.Visible = false;
    local LogoData = ResolveLoaderImage(LogoSrc);
    if LogoData then
        MiddleIcon.Data = LogoData;
        MiddleIcon.Visible = true;
    else
        MiddleIcon.Visible = false;
    end
    table.insert(Drawings, MiddleIcon);
    SliderInline.Position = Vector2.new(
        WindowOutline.Position.X + (WindowOutline.Size.X / 2) - (SliderOutline.Size.X / 2),
        (WindowOutline.Position.Y + WindowOutline.Size.Y) - 30
    );
    SliderOutline.Position = Vector2.new(SliderInline.Position.X + 1, SliderInline.Position.Y + 1);
    SliderFrame.Position = Vector2.new(SliderInline.Position.X + 1, SliderInline.Position.Y + 1);
    WindowText.Position = Vector2.new(WindowFrame.Position.X + (WindowFrame.Size.X / 2), SliderInline.Position.Y - 16);
    MiddleIcon.Position = Vector2.new(
        WindowOutline.Position.X + (WindowOutline.Size.X / 2) - (MiddleIcon.Size.X / 2),
        WindowOutline.Position.Y + (WindowOutline.Size.Y / 2) - (MiddleIcon.Size.Y / 2) - 15
    );
    MiddleIcon.Transparency = 1;
    local function ApplyAccent(C)
        WindowOutlineBorder.Color = C;
        SliderFrame.Color = C;
        SliderTip.Color = C:Lerp(Color3.fromRGB(255, 255, 255), 0.35);
    end;
    Library:OnAccent(ApplyAccent);
    local FadeTargets = {}
    local FadeVisible = {}
    for _, D in ipairs(Drawings) do
        FadeTargets[D] = D.Transparency
        FadeVisible[D] = true
        D.Visible = false
        D.Transparency = 0
    end
    FadeVisible[MiddleIcon] = LogoData ~= nil
    FadeVisible[SliderTip] = false
    local RS = game:GetService("RunService")
    local function Fade(From, To, Duration)
        local Start = os.clock()
        while true do
            local T = math.min((os.clock() - Start) / Duration, 1)
            local E = T * T * (3 - 2 * T)
            local A = From + (To - From) * E
            for D, Target in pairs(FadeTargets) do
                pcall(function() D.Transparency = Target * A end)
            end
            if T >= 1 then break end
            RS.RenderStepped:Wait()
        end
    end
    local Max = 2
    local BarFull = SliderInline.Size.X - 2
    local CurW, TargetW = 0, 0
    local SlideDone = false
    task.spawn(function()
        while not SlideDone do
            local Dt = RS.RenderStepped:Wait()
            CurW = CurW + (TargetW - CurW) * math.min(Dt * 10, 1)
            if math.abs(TargetW - CurW) < 0.4 then CurW = TargetW end
            local W = math.max(CurW, 0)
            SliderFrame.Size = Vector2.new(W, SliderInline.Size.Y - 2)
            SliderTip.Visible = W > 3
            SliderTip.Size = Vector2.new(math.min(W, 2.5), SliderInline.Size.Y - 2)
            SliderTip.Position = Vector2.new(SliderInline.Position.X + 1 + math.max(W - 2.5, 0), SliderInline.Position.Y + 1)
        end
    end)
    local Loader = { _Max = Max }
    local Destroyed = false
    function Loader:Set(Val, Txt)
        if Destroyed then return end
        if Val ~= nil then TargetW = BarFull * (math.clamp(tonumber(Val) or 0, 0, Max) / Max) end
        if Txt ~= nil then WindowText.Text = tostring(Txt) end
    end
    function Loader:Destroy()
        if Destroyed then return end
        Destroyed = true
        for K, Fn in ipairs(Library.AccentCallbacks) do
            if Fn == ApplyAccent then table.remove(Library.AccentCallbacks, K) break end
        end
        Fade(1, 0, 0.3)
        SlideDone = true
        for _, D in ipairs(Drawings) do pcall(function() D:Remove() end) end
    end
    for _, D in ipairs(Drawings) do
        D.Visible = FadeVisible[D]
    end
    Fade(0, 1, 0.35)
    return Loader
end
local _BootOk = check()
getgenv().finishedloader = _BootOk
if not _BootOk then getgenv().loadererror = true end
end
function Library:RegisterAccentGradient(Gradient)
	table.insert(self.AccentGradients, Gradient);
	Gradient.Color = NewColorSequence({
		NewColorSequenceKeypoint(0,   self.Accent);
		NewColorSequenceKeypoint(0.5, LightenAccent(self.Accent));
		NewColorSequenceKeypoint(1,   self.Accent);
	});
end;
Library.Keybinds         = {};
Library.KeybindListeners = {};
Library.ShowToggleFrameInKeybinds = true;
local function RegisterGradLerp(Entry)
    table.insert(Library._GradLerps, Entry)
end
function Library:RegisterKeybind(Entry)
	if typeof(Entry) ~= "table" then return end;
	table.insert(self.Keybinds, Entry);
	self:NotifyKeybind();
	return Entry;
end;
function Library:UnregisterKeybind(Entry)
	local Index = table.find(self.Keybinds, Entry);
	if not Index then return end;
	table.remove(self.Keybinds, Index);
	self:NotifyKeybind();
end;
function Library:NotifyKeybind()
	for _, Fn in self.KeybindListeners do pcall(Fn) end;
end;
function Library:OnKeybindChange(Fn)
	if typeof(Fn) ~= "function" then return end;
	table.insert(self.KeybindListeners, Fn);
	Fn();
	return function()
		local Index = table.find(self.KeybindListeners, Fn);
		if Index then table.remove(self.KeybindListeners, Index) end;
	end;
end;
local AccentClock = 0;
local LastOff = nil
game:GetService("RunService").Heartbeat:Connect(function(Dt)
    if Library._ReduceAnimations then return end
    AccentClock = AccentClock + Dt * 0.4
    local Off = (AccentClock % 2) - 1
    if LastOff and math.abs(Off - LastOff) < 0.001 then return end
    LastOff = Off
    local OffsetV = Vector2.new(Off, 0)
    for _, G in Library.AccentGradients do
        if G and G.Parent then
            G.Offset = OffsetV
        end
    end
end)
print("rn4")
function Library:OnAccent(Fn)
	if typeof(Fn) ~= "function" then return end;
	table.insert(self.AccentCallbacks, Fn);
	Fn(self.Accent);
end;
function Library:SetAccent(C)
	if typeof(C) ~= "Color3" then return end;
	self.Accent = C;
	for _, P in self.AccentParts do
		if P.Inst and P.Inst.Parent then
			P.Inst[P.Prop] = C;
		end;
	end;
	for _, G in self.AccentGradients do
		if G and G.Parent then
			G.Color = NewColorSequence({
				NewColorSequenceKeypoint(0,   C);
				NewColorSequenceKeypoint(0.5, LightenAccent(C));
				NewColorSequenceKeypoint(1,   C);
			});
		end;
	end;
	for _, Fn in self.AccentCallbacks do
		Fn(C);
	end;
end;
for _, FolderPath in Library.Folders do
	makefolder(Library.Directory .. FolderPath);
end;
if isfile(Library.LogFile) then
	delfile(Library.LogFile);
end;
writefile(Library.LogFile, "[0.000s] XoneScriptK has started at " .. tostring(FakePointer()) .. "\n");
local LogStart = tick();
function Library:Log(Text)
	local Stamp = string.format("%.3f", tick() - LogStart);
	local Time = os.date("%H:%M:%S");
	appendfile(self.LogFile, "[" .. Time .. "][" .. Stamp .. "s] " .. tostring(Text) .. "\n");
end;
print("rn5")
Library.KeyNames = {
	[Enum.UserInputType.MouseButton1] = "MB1";
	[Enum.UserInputType.MouseButton2] = "MB2";
	[Enum.UserInputType.MouseButton3] = "MB3";
	[Enum.KeyCode.LeftShift] = "LS";
	[Enum.KeyCode.RightShift] = "RS";
	[Enum.KeyCode.LeftControl] = "LC";
	[Enum.KeyCode.RightControl] = "RC";
	[Enum.KeyCode.LeftAlt] = "LA";
	[Enum.KeyCode.RightAlt] = "RA";
	[Enum.KeyCode.CapsLock] = "CAPS";
	[Enum.KeyCode.Insert] = "INS";
	[Enum.KeyCode.Backspace] = "BS";
	[Enum.KeyCode.Return] = "Ent";
	[Enum.KeyCode.Escape] = "ESC";
	[Enum.KeyCode.Space] = "SPC";
	[Enum.KeyCode.Zero] = "0";
	[Enum.KeyCode.One] = "1";
	[Enum.KeyCode.Two] = "2";
	[Enum.KeyCode.Three] = "3";
	[Enum.KeyCode.Four] = "4";
	[Enum.KeyCode.Five] = "5";
	[Enum.KeyCode.Six] = "6";
	[Enum.KeyCode.Seven] = "7";
	[Enum.KeyCode.Eight] = "8";
	[Enum.KeyCode.Nine] = "9";
	[Enum.KeyCode.KeypadZero] = "Num0";
	[Enum.KeyCode.KeypadOne] = "Num1";
	[Enum.KeyCode.KeypadTwo] = "Num2";
	[Enum.KeyCode.KeypadThree] = "Num3";
	[Enum.KeyCode.KeypadFour] = "Num4";
	[Enum.KeyCode.KeypadFive] = "Num5";
	[Enum.KeyCode.KeypadSix] = "Num6";
	[Enum.KeyCode.KeypadSeven] = "Num7";
	[Enum.KeyCode.KeypadEight] = "Num8";
	[Enum.KeyCode.KeypadNine] = "Num9";
	[Enum.KeyCode.Minus] = "-";
	[Enum.KeyCode.Equals] = "=";
	[Enum.KeyCode.Tilde] = "~";
	[Enum.KeyCode.LeftBracket] = "[";
	[Enum.KeyCode.RightBracket] = "]";
	[Enum.KeyCode.LeftParenthesis] = "(";
	[Enum.KeyCode.RightParenthesis] = ")";
	[Enum.KeyCode.Semicolon] = ",";
	[Enum.KeyCode.Quote] = "'";
	[Enum.KeyCode.BackSlash] = "\\";
	[Enum.KeyCode.Comma] = ",";
	[Enum.KeyCode.Period] = ".";
	[Enum.KeyCode.Slash] = "/";
	[Enum.KeyCode.Asterisk] = "*";
	[Enum.KeyCode.Plus] = "+";
	[Enum.KeyCode.Backquote] = "`";
};
if getgenv().Library then getgenv().Library:Unload() end;
getgenv().Library = Library;
function Library:Connection(Signal, Callback)
	local Conn = Signal:Connect(Callback);
	table.insert(self.Connections, Conn);
	return Conn;
end;
function Library:CreateInstance(ClassName, Properties)
	local Inst = Instance.new(ClassName);
	for K, V in (Properties or {}) do
		Inst[K] = V;
	end;
	return Inst;
end;
function Library:Tween(Inst, Info, Props)
	local Speed = self.AnimationSpeed or 1;
	if Speed < 0.05 then Speed = 0.05 end;
	local Scale = 1 / Speed;
	local Style = self.EasingStyle      or Info.EasingStyle;
	local Dir   = self.EasingDirection  or Info.EasingDirection;
	if Scale == 1 and Style == Info.EasingStyle and Dir == Info.EasingDirection then
		return TweenService:Create(Inst, Info, Props);
	end;
	local Scaled = TweenInfo.new(Info.Time * Scale, Style, Dir, Info.RepeatCount, Info.Reverses, Info.DelayTime);
	return TweenService:Create(Inst, Scaled, Props);
end;
function Library:_FadeGroup(Map, Mode, Duration, Style, Dir, OnComplete)
	local Speed = self.AnimationSpeed or 1;
	if Speed < 0.05 then Speed = 0.05 end;
	Duration = (tonumber(Duration) or 0.2) / Speed;
	Style = self.EasingStyle     or Style or Enum.EasingStyle.Quint;
	Dir   = self.EasingDirection or Dir   or Enum.EasingDirection.Out;
	local Entries = {};
	for Inst, PMap in Map do
		if Inst and Inst.Parent then
			for P, Orig in PMap do
				if Orig < 1 then
					local To = (Mode == "out") and 1 or Orig;
					local Ok, From = pcall(function() return Inst[P] end);
					if Ok and type(From) == "number" and math.abs(From - To) > 0.001 then
						table.insert(Entries, { Inst = Inst, P = P, From = From, To = To });
					end;
				end;
			end;
		end;
	end;
	if #Entries == 0 then
		if OnComplete then OnComplete() end;
		return nil;
	end;
	local Start = os.clock();
	local Conn;
	Conn = RunService.RenderStepped:Connect(function()
		local T = math.min((os.clock() - Start) / Duration, 1);
		local A = TweenService:GetValue(T, Style, Dir);
		for _, E in Entries do
			pcall(function()
				if E.Inst.Parent then E.Inst[E.P] = E.From + (E.To - E.From) * A end;
			end);
		end;
		if T >= 1 then
			Conn:Disconnect();
			if OnComplete then OnComplete() end;
		end;
	end);
	return Conn;
end;
function Library:_RefreshFadeMap(Old, New)
	if Old then
		for Inst, PMap in New do
			if Old[Inst] then New[Inst] = Old[Inst] end;
		end;
	end;
	return New;
end;
function Library:_SnapFadeGroup(Map, Mode)
	for Inst, PMap in (Map or {}) do
		if Inst and Inst.Parent then
			for P, Orig in PMap do
				pcall(function() Inst[P] = (Mode == "out") and 1 or Orig end);
			end;
		end;
	end;
end;
Library._ActiveDraggers = {};
function Library:_RegisterDragger(Handler)
	if typeof(Handler) ~= "function" then return end;
	local Self = self;
	if not Self._DispatcherConn then
		Self._DispatcherConn = UserInputService.InputChanged:Connect(function(Input)
			local Ut = Input.UserInputType;
			if Ut ~= Enum.UserInputType.MouseMovement and Ut ~= Enum.UserInputType.Touch then
				return;
			end;
			local List = Self._ActiveDraggers;
			for I = 1, #List do
				List[I](Input);
			end;
		end);
		table.insert(Self.Connections, Self._DispatcherConn);
	end;
	table.insert(Self._ActiveDraggers, Handler);
	return Handler;
end;
function Library:_UnregisterDragger(Handler)
	if not Handler then return end;
	local List = self._ActiveDraggers;
	if not List then return end;
	for I = #List, 1, -1 do
		if List[I] == Handler then
			List[I] = List[#List];
			List[#List] = nil;
			return;
		end;
	end;
end;
function Library:IsEffectivelyVisible(Inst)
	local Cur = Inst;
	while Cur do
		if Cur:IsA("ScreenGui") then return Cur.Enabled end;
		if Cur:IsA("GuiObject") and not Cur.Visible then return false end;
		Cur = Cur.Parent;
	end;
	return false;
end;
function Library:Debounce(Delay, Fn)
	local Token = 0;
	return function(...)
		Token = Token + 1;
		local Mine = Token;
		local Args = { ... };
		task.delay(Delay, function()
			if Mine == Token then Fn(table.unpack(Args)) end;
		end);
	end;
end;
function Library:RegisterFont(Name, Url, Weight, Style)
	local Folder = self.Directory .. "/Fonts";
	local TtfPath = Folder .. "/" .. Name .. ".ttf";
	local DescPath = Folder .. "/" .. Name .. ".font";
	if not isfile(TtfPath) then
		writefile(TtfPath, game:HttpGet(Url));
	end;
	if isfile(DescPath) then
		delfile(DescPath);
	end;
	writefile(DescPath, HttpService:JSONEncode({
		name = Name;
		faces = {
			{ name = "Regular", weight = Weight or 400, style = Style or "normal", assetId = getcustomasset(TtfPath) };
		};
	}));
	self:Log("Registered font " .. Name);
	return getcustomasset(DescPath);
end;
Library._CpSwatches = Library._CpSwatches or {};
function Library:_RegisterCpSwatch(Swatch)
	table.insert(self._CpSwatches, Swatch);
end;
function Library:_InsideAnyCpSwatch(Mx, My)
	for _, S in ipairs(self._CpSwatches) do
		local Ok, Inside = pcall(function()
			if not S.Parent then return false end;
			local Ap, Sz = S.AbsolutePosition, S.AbsoluteSize;
			return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
		end);
		if Ok and Inside then return true end;
	end;
	return false;
end;
function Library:_EnhanceColorPickerPopup(PickerHolder, DragHandle, CloseFn)
	local CloseBtn = self:CreateInstance("TextButton", {
		Name                   = "Close";
		Parent                 = PickerHolder;
		AnchorPoint            = Vector2.new(1, 0);
		Position               = UDim2.new(1, -3, 0, 2);
		Size                   = UDim2.fromOffset(16, 16);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Text                   = "×";
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 16;
		ZIndex                 = 80;
	});
	Library:Connection(CloseBtn.MouseButton1Click, function() CloseFn() end);
	Library:Connection(CloseBtn.MouseEnter, function() CloseBtn.TextColor3 = Color3.fromHex("FFFFFF") end);
	Library:Connection(CloseBtn.MouseLeave, function() CloseBtn.TextColor3 = Color3.fromHex("8C8F99") end);
	if DragHandle then
		self:Draggable(PickerHolder, DragHandle);
		for _, Ch in ipairs(DragHandle:GetChildren()) do
			if Ch:IsA("GuiButton") then self:Draggable(PickerHolder, Ch) end;
		end;
	end;
end;
function Library:Draggable(TargetFrame, DragHandle, IgnoreLock)
	local Handle = DragHandle or TargetFrame;
	local Dragging = false;
	local DragStart, StartPosition;
	local LastInput = nil;
	local Dirty     = false;
	local ShadowCache = nil;
	local function SetShadows(Enabled)
		if not ShadowCache then
			ShadowCache = {};
			for _, D in TargetFrame:GetDescendants() do
				if D.ClassName == "UIShadow" then table.insert(ShadowCache, D) end;
			end;
		end;
		for _, Sh in ShadowCache do
			local Ok = pcall(function() Sh.Enabled = Enabled end);
			if not Ok then
				pcall(function()
					if Enabled then
						Sh.Transparency = Sh:GetAttribute("CoincideShadowT") or 0.5;
					else
						Sh:SetAttribute("CoincideShadowT", Sh.Transparency);
						Sh.Transparency = 1;
					end;
				end);
			end;
		end;
	end;
	local function Set(Input)
		if not DragStart or not StartPosition then return end;
		local S = Library:_GetUIScaleOf(TargetFrame);
		local Delta = (Input.Position - DragStart) / S;
		local NewX = StartPosition.X.Offset + Delta.X;
		local NewY = StartPosition.Y.Offset + Delta.Y;
		local Parent = TargetFrame.Parent;
		if Parent and Parent:IsA("GuiObject") then
			local Ps = Parent.AbsoluteSize;
			local Ts = TargetFrame.AbsoluteSize;
			local Ap = TargetFrame.AnchorPoint;
			local Margin = 40;
			local Tx = StartPosition.X.Scale * Ps.X + NewX * S - Ap.X * Ts.X;
			local Ty = StartPosition.Y.Scale * Ps.Y + NewY * S - Ap.Y * Ts.Y;
			Tx = math.clamp(Tx, -(Ts.X - Margin), math.max(Ps.X - Margin, 0));
			Ty = math.clamp(Ty, -(Ts.Y - Margin), math.max(Ps.Y - Margin, 0));
			NewX = (Tx + Ap.X * Ts.X - StartPosition.X.Scale * Ps.X) / S;
			NewY = (Ty + Ap.Y * Ts.Y - StartPosition.Y.Scale * Ps.Y) / S;
		end;
		TargetFrame.Position = UDim2.new(
			StartPosition.X.Scale,
			NewX,
			StartPosition.Y.Scale,
			NewY
		);
	end;
	self:Connection(Handle.InputBegan, function(Input)
		if Library.CantDragForced and not IgnoreLock then return end;
		if not IgnoreLock and Library.CanDrag == false then return end;
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return;
		end;
		Dragging           = true;
		Library.IsDragging = true;
		DragStart          = Input.Position;
		StartPosition      = TargetFrame.Position;
		SetShadows(false);
	end);
	self:Connection(Handle.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			SetShadows(true);
			Dragging           = false;
			Library.IsDragging = false;
			LastInput, Dirty   = nil, false;
		end;
	end);
	self:Connection(UserInputService.InputChanged, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return;
		end;
		if not Dragging then return end;
		LastInput = Input;
		Dirty     = true;
	end);
	self:Connection(RunService.RenderStepped, function()
		if not Dragging or not Dirty or not LastInput then return end;
		if not IgnoreLock and Library.CanDrag == false then
			SetShadows(true);
			Dragging           = false;
			Library.IsDragging = false;
			LastInput, Dirty   = nil, false;
			return;
		end;
		Dirty = false;
		Set(LastInput);
	end);
end;
function Library:BindLongPress(Button, Callback, HoldTime)
	HoldTime = tonumber(HoldTime) or 0.5;
	pcall(function() Button:SetAttribute("CoincideLP", true) end);
	local Token = 0;
	self:Connection(Button.InputBegan, function(Input)
		if Input.UserInputType ~= Enum.UserInputType.Touch then return end;
		Token = Token + 1;
		local Mine = Token;
		local StartPos = Vector2.new(Input.Position.X, Input.Position.Y);
		local MoveConn, UpConn;
		MoveConn = UserInputService.InputChanged:Connect(function(I2)
			if I2.UserInputType ~= Enum.UserInputType.Touch then return end;
			local P = Vector2.new(I2.Position.X, I2.Position.Y);
			if (P - StartPos).Magnitude > 16 then
				Token = Token + 1;
				MoveConn:Disconnect();
				if UpConn then UpConn:Disconnect() end;
			end;
		end);
		UpConn = Button.InputEnded:Connect(function(I2)
			if I2.UserInputType ~= Enum.UserInputType.Touch then return end;
			Token = Token + 1;
			MoveConn:Disconnect();
			UpConn:Disconnect();
		end);
		task.delay(HoldTime, function()
			if Mine ~= Token then return end;
			MoveConn:Disconnect();
			if UpConn then UpConn:Disconnect() end;
			Callback();
		end);
	end);
end;
function Library:_GetUIScaleOf(Inst)
	local S = 1;
	local Cur = Inst;
	while Cur do
		if Cur:IsA("UIScale") then S = S * Cur.Scale end;
		Cur = Cur.Parent;
	end;
	if Inst and Inst.GetChildren then
		for _, C in Inst:GetChildren() do
			if C:IsA("UIScale") then S = S * C.Scale end;
		end;
	end;
	if S <= 0 then S = 1 end;
	return S;
end;
function Library:ClampPopupXY(Popup, X, Y)
	local Cam = Workspace.CurrentCamera;
	local Vp = Cam and Cam.ViewportSize or Vector2.new(800, 600);
	local W = (Popup and Popup.AbsoluteSize.X) or 0;
	if W < 40 then W = 40 end;
	X = math.clamp(X, 4, math.max(Vp.X - W - 4, 4));
	Y = math.clamp(Y, 4, math.max(Vp.Y - 60, 4));
	return X, Y;
end;
local CurrentContextMenu = nil;
local function CloseContextMenus(Until)
	local Closed = {};
	while CurrentContextMenu and CurrentContextMenu ~= Until and not Closed[CurrentContextMenu] do
		local Menu = CurrentContextMenu;
		Closed[Menu] = true;
		Menu:Close();
	end;
end;
local function GetContextMenuRoot()
	if Library._ContextMenuRoot and Library._ContextMenuRoot.Parent then return Library._ContextMenuRoot end;
	Library._ContextMenuRoot = Library:CreateInstance("ScreenGui", {
		Name = "XoneScriptKContextMenus"; Parent = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true; ResetOnSpawn = false; DisplayOrder = 10000;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	return Library._ContextMenuRoot;
end;
local function IsInsideContextArea(Inst, Position)
	if not Inst or not Inst.Parent then return false end;
	local P, S = Inst.AbsolutePosition, Inst.AbsoluteSize;
	return Position.X >= P.X and Position.X <= P.X + S.X and Position.Y >= P.Y and Position.Y <= P.Y + S.Y;
end;
function Library:AddContextMenu(Holder, Size, Offset, List, ActiveCallback)
	assert(typeof(Holder) == "Instance" and Holder:IsA("GuiObject"), "Holder must be a GuiObject.");
	local Root = GetContextMenuRoot();
	local Menu = Library:CreateInstance("CanvasGroup", {
		Name = "ContextMenu"; Parent = Root; Size = UDim2.fromOffset(180, 0);
		BackgroundColor3 = Color3.fromHex("151515"); BorderSizePixel = 0;
		Visible = false; GroupTransparency = 1; ClipsDescendants = true; ZIndex = 1000;
	});
	Library:CreateInstance("UIStroke", { Parent = Menu; Color = Color3.fromHex("393939"); Thickness = 1; });
	local Padding = Library:CreateInstance("UIPadding", {
		Parent = Menu; PaddingBottom = UDim.new(0, 6); PaddingLeft = UDim.new(0, 6);
		PaddingRight = UDim.new(0, 6); PaddingTop = UDim.new(0, 6);
	});
	local Layout = Library:CreateInstance("UIListLayout", {
		Parent = Menu; FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 4);
	});
	local Table = {
		Holder = Holder; Menu = Menu; List = Layout; Size = Size or UDim2.fromOffset(180, 0);
		AutoSizeY = List == 1 or List == nil; Active = false; ActiveCallback = ActiveCallback;
		Connections = {}; Destroyed = false; ParentMenu = nil; _AnimationToken = 0;
	};
	local function Track(Signal, Fn)
		local Conn = Library:Connection(Signal, Fn);
		table.insert(Table.Connections, Conn);
		return Conn;
	end;
	local function ResolveSize()
		local Value = typeof(Table.Size) == "function" and Table.Size() or Table.Size;
		if typeof(Value) ~= "UDim2" then Value = UDim2.fromOffset(180, 0) end;
		local Height = Value.Y.Offset;
		if Table.AutoSizeY or Height <= 0 then Height = Layout.AbsoluteContentSize.Y + 12 end;
		return UDim2.new(Value.X.Scale, Value.X.Offset, Value.Y.Scale, math.max(Height, 12));
	end;
	local function ResolveOffset()
		local Value = typeof(Offset) == "function" and Offset() or Offset;
		if typeof(Value) == "Vector2" then return Value.X, Value.Y end;
		if typeof(Value) == "table" then return tonumber(Value[1]) or 0, tonumber(Value[2]) or 0 end;
		return 0, Holder.AbsoluteSize.Y + 4;
	end;
	local function UpdatePosition()
		if not Holder.Parent then Table:Close(); return end;
		local OX, OY = ResolveOffset();
		local X = Holder.AbsolutePosition.X + OX;
		local Y = Holder.AbsolutePosition.Y + OY;
		X, Y = Library:ClampPopupXY(Menu, X, Y);
		Table._Position = UDim2.fromOffset(math.floor(X), math.floor(Y));
		Menu.Position = Table._Position;
	end;
	function Table:Open()
		if self.Destroyed or not Holder.Parent then return end;
		if self.Active then Menu.Size = ResolveSize(); UpdatePosition(); return end;
		local NestedParent = nil;
		local Check = CurrentContextMenu;
		while Check do
			if Holder:IsDescendantOf(Check.Menu) then NestedParent = Check; break end;
			Check = Check.ParentMenu;
		end;
		CloseContextMenus(NestedParent);
		self.ParentMenu = NestedParent; CurrentContextMenu = self; self.Active = true;
		Menu.ZIndex = NestedParent and NestedParent.Menu.ZIndex + 1 or 1000;
		Menu.Parent = Root;
		local TargetSize = ResolveSize(); Menu.Size = TargetSize; UpdatePosition();
		self._AnimationToken += 1;
		local Mine = self._AnimationToken;
		if typeof(self.ActiveCallback) == "function" then pcall(self.ActiveCallback, true) end;
		if Library._ReduceAnimations then
			Menu.Position = self._Position; Menu.GroupTransparency = 0; Menu.Visible = true; return;
		end;
		local StartHeight = Menu.Visible and Menu.Size.Y.Offset or 0;
		Menu.Size = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, StartHeight);
		Menu.Position = self._Position + UDim2.fromOffset(0, 6);
		Menu.Visible = true;
		Library:Tween(Menu, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = 0; Position = self._Position; Size = TargetSize;
		}):Play();
	end;
	function Table:Close()
		if not self.Active then return end;
		self.Active = false;
		if CurrentContextMenu == self then CurrentContextMenu = self.ParentMenu end;
		self.ParentMenu = nil;
		if typeof(self.ActiveCallback) == "function" then pcall(self.ActiveCallback, false) end;
		self._AnimationToken += 1;
		local Mine = self._AnimationToken;
		if Library._ReduceAnimations then Menu.Visible = false; Menu.GroupTransparency = 1; return end;
		local CurrentSize = Menu.Size;
		Library:Tween(Menu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1; Position = self._Position + UDim2.fromOffset(0, 6);
			Size = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0);
		}):Play();
		task.delay(0.15, function()
			if self._AnimationToken == Mine and not self.Active then Menu.Visible = false end;
		end);
	end;
	function Table:Toggle() if self.Active then self:Close() else self:Open() end end;
	function Table:SetSize(NewSize)
		self.Size = NewSize; if self.Active then Menu.Size = ResolveSize(); UpdatePosition() end;
	end;
	function Table:AddButton(A, B)
		local Text, Fn, KeepOpen, Disabled;
		if typeof(A) == "table" then
			Text = A.Text or A.Name or "Button"; Fn = A.Func or A.Callback; KeepOpen = A.KeepOpen; Disabled = A.Disabled;
		else
			Text = tostring(A); Fn = B;
		end;
		local Button = Library:CreateInstance("TextButton", {
			Parent = Menu; Size = UDim2.new(1, 0, 0, 26); BackgroundColor3 = Color3.fromHex("1C1C1C");
			BorderSizePixel = 0; Text = tostring(Text); TextColor3 = Disabled and Color3.fromHex("707070") or Color3.fromHex("FFFFFF");
			TextSize = 12; TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.Code; AutoButtonColor = false;
		});
		Library:CreateInstance("UIPadding", { Parent = Button; PaddingLeft = UDim.new(0, 8); PaddingRight = UDim.new(0, 8); });
		Track(Button.MouseEnter, function() if not Disabled then Button.BackgroundColor3 = Color3.fromHex("252527") end end);
		Track(Button.MouseLeave, function() Button.BackgroundColor3 = Color3.fromHex("1C1C1C") end);
		Track(Button.MouseButton1Click, function()
			if Disabled then return end;
			if typeof(Fn) == "function" then task.spawn(Fn) end;
			if not KeepOpen then CloseContextMenus(nil) end;
		end);
		if self.Active then Menu.Size = ResolveSize(); UpdatePosition() end;
		return Button;
	end;
	function Table:AddLabel(Text)
		local Label = Library:CreateInstance("TextLabel", {
			Parent = Menu; Size = UDim2.new(1, 0, 0, 20); BackgroundTransparency = 1;
			Text = tostring(Text); TextColor3 = Color3.fromHex("8C8F99"); TextSize = 12;
			TextXAlignment = Enum.TextXAlignment.Left; Font = Enum.Font.Code;
		});
		if self.Active then Menu.Size = ResolveSize(); UpdatePosition() end;
		return Label;
	end;
	function Table:AddDivider()
		local Divider = Library:CreateInstance("Frame", { Parent = Menu; Size = UDim2.new(1, 0, 0, 5); BackgroundTransparency = 1; });
		Library:CreateInstance("Frame", {
			Parent = Divider; AnchorPoint = Vector2.new(0, 0.5); Position = UDim2.fromScale(0, 0.5);
			Size = UDim2.new(1, 0, 0, 1); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
		});
		if self.Active then Menu.Size = ResolveSize(); UpdatePosition() end;
		return Divider;
	end;
	function Table:Clear()
		for _, Child in ipairs(Menu:GetChildren()) do if Child:IsA("GuiObject") then Child:Destroy() end end;
		if self.Active then Menu.Size = ResolveSize(); UpdatePosition() end;
	end;
	function Table:Bind(HoldTime)
		Track(Holder.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton2 then self:Toggle() end;
		end);
		Library:BindLongPress(Holder, function() self:Toggle() end, HoldTime or 0.5);
		return self;
	end;
	function Table:Destroy()
		if self.Destroyed then return end;
		CloseContextMenus(self);
		if self.Active then self:Close() end;
		self.Destroyed = true; self._AnimationToken += 1;
		for _, Conn in ipairs(self.Connections) do Conn:Disconnect() end;
		local Index = table.find(Library.ContextMenus, self);
		if Index then table.remove(Library.ContextMenus, Index) end;
		Menu:Destroy();
	end;
	Track(Holder:GetPropertyChangedSignal("AbsolutePosition"), function() if Table.Active then UpdatePosition() end end);
	Track(Holder:GetPropertyChangedSignal("AbsoluteSize"), function() if Table.Active then UpdatePosition() end end);
	Track(Holder.AncestryChanged, function() if not Holder.Parent and Table.Active then Table:Close() end end);
	Library.ContextMenus = Library.ContextMenus or {}; table.insert(Library.ContextMenus, Table);
	if not Library._ContextMenuInputBound then
		Library._ContextMenuInputBound = true;
		Library:Connection(UserInputService.InputBegan, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.MouseButton2 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
			local Check = CurrentContextMenu;
			while Check do
				if IsInsideContextArea(Check.Menu, Input.Position) or IsInsideContextArea(Check.Holder, Input.Position) then return end;
				Check = Check.ParentMenu;
			end;
			CloseContextMenus(nil);
		end);
	end;
	return Table;
end;
function Library:_MakeSatelliteBindable(Obj)
	Library._SatelliteWindows = Library._SatelliteWindows or {};
	table.insert(Library._SatelliteWindows, Obj);
	Obj._BoundWindow  = nil;
	Obj._BoundTab     = nil;
	Obj._SyncedWindow = nil;
	local function MatchesBoundTab(W, Needle)
		local Tabs = W and W._Tabs;
		if not Tabs then return true end;
		local AnyName, ActiveHit, AnyActive = false, false, false;
		for _, T in ipairs(Tabs) do
			if T.Active then AnyActive = true end;
			if string.find(string.lower(T.Name), Needle, 1, true) then
				AnyName = true;
				if T.Active then ActiveHit = true end;
			end;
		end;
		if not AnyName then return true end;
		if not AnyActive then return true end;
		return ActiveHit;
	end;
	function Obj:_RefreshBinding()
		local W = self._BoundWindow;
		if not W then return end;
		local Target = W.Visible == true;
		if Target and self._BoundTab then
			Target = MatchesBoundTab(W, self._BoundTab);
		end;
		self:SetVisible(Target);
	end;
	function Obj:SyncWithWindow(Window)
		self._BoundWindow = Window;
		if self._SyncedWindow == Window then self:_RefreshBinding(); return end;
		self._SyncedWindow = Window;
		local OrigSetVisible = Window.SetVisible;
		Window.SetVisible = function(Win, State)
			OrigSetVisible(Win, State);
			self:_RefreshBinding();
		end;
		local OrigToggle = Window.Toggle;
		Window.Toggle = function(Win)
			OrigToggle(Win);
			self:_RefreshBinding();
		end;
		task.defer(function() self:_RefreshBinding() end);
	end;
	function Obj:SyncWithTab(Window, TabName)
		if not (Window and Window._Tabs) then return end;
		self._BoundTab = string.lower(tostring(TabName or ""));
		Window._Satellites = Window._Satellites or {};
		local Registered = false;
		for _, S in ipairs(Window._Satellites) do if S == self then Registered = true; break end; end;
		if not Registered then table.insert(Window._Satellites, self) end;
		local function HookTab(T)
			if T._SatHooked then return end;
			T._SatHooked = true;
			local Orig = T.SetActive;
			T.SetActive = function(Self, State)
				Orig(Self, State);
				task.defer(function() Obj:_RefreshBinding() end);
			end;
		end;
		for _, T in ipairs(Window._Tabs) do HookTab(T) end;
		if not Window._SatTabHook then
			Window._SatTabHook = true;
			local OrigTab = Window.Tab;
			Window.Tab = function(W, ...)
				local T = OrigTab(W, ...);
				HookTab(T);
				return T;
			end;
		end;
		self:SyncWithWindow(Window);
		self:_RefreshBinding();
	end;
end;
function Library:_AutoBindSatellite(Obj, Opts, DefaultTab)
	Opts = typeof(Opts) == "table" and Opts or {};
	if Opts.BindTab == false then return end;
	local BindName = nil;
	if type(Opts.BindTab) == "string" then
		BindName = Opts.BindTab;
	elseif IsMobilePlatform then
		BindName = Opts.Tab or DefaultTab;
	end;
	if not BindName then return end;
	local function TryBind()
		local Win = Opts.Window or Library.CurrentlyOpen;
		if Win and Win._Tabs then Obj:SyncWithTab(Win, BindName); return true end;
		return false;
	end;
	if not TryBind() then
		task.spawn(function()
			for _ = 1, 50 do
				task.wait(0.1);
				if TryBind() then return end;
			end;
		end);
	end;
end;
function Library:_AttachScrollbar(Scroll)
	if not (Scroll and Scroll:IsA("ScrollingFrame")) then return end;
	if Scroll:GetAttribute("CoincideScroll") then return end;
	local Holder = Scroll.Parent;
	if not (Holder and Holder:IsA("GuiObject")) then return end;
	Scroll:SetAttribute("CoincideScroll", true);
	Scroll.ScrollBarThickness = 0;
	local BarW = IsMobilePlatform and 5 or 4;
	local Ax, Ay = Scroll.AnchorPoint.X, Scroll.AnchorPoint.Y;
	local Track = Library:CreateInstance("Frame", {
		Name                   = "ScrollTrack";
		Parent                 = Holder;
		AnchorPoint            = Vector2.new(1, 0);
		Position               = UDim2.new(
			Scroll.Position.X.Scale + (1 - Ax) * Scroll.Size.X.Scale,
			Scroll.Position.X.Offset + (1 - Ax) * Scroll.Size.X.Offset - 1,
			Scroll.Position.Y.Scale - Ay * Scroll.Size.Y.Scale,
			Scroll.Position.Y.Offset - Ay * Scroll.Size.Y.Offset + 2
		);
		Size                   = UDim2.new(0, BarW, 0, 10);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Visible                = false;
		ZIndex                 = 100;
	});
	local Handle = Library:CreateInstance("TextButton", {
		Name                   = "Handle";
		Parent                 = Track;
		Size                   = UDim2.new(1, 0, 0.2, 0);
		BackgroundColor3       = Library.Accent;
		BackgroundTransparency = 0.55;
		BorderSizePixel        = 0;
		AutoButtonColor        = false;
		Text                   = "";
		ZIndex                 = 101;
	});
	Library:CreateInstance("UICorner", { Parent = Handle; CornerRadius = UDim.new(0.5, 0) });
	Library:RegisterAccent(Handle, "BackgroundColor3");
	local IdleT, ActiveT = 0.55, 0.12;
	local FlashInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local FlashToken = 0;
	local DraggingBar = false;
	local function Flash()
		FlashToken += 1;
		local Mine = FlashToken;
		Library:Tween(Handle, FlashInfo, { BackgroundTransparency = ActiveT }):Play();
		task.delay(0.8, function()
			if Mine == FlashToken and not DraggingBar and Track.Parent then
				Library:Tween(Handle, FlashInfo, { BackgroundTransparency = IdleT }):Play();
			end;
		end);
	end;
	local function Update(FlashIt)
		if not (Scroll.Parent and Track.Parent) then return end;
		local Cs = Scroll.AbsoluteCanvasSize.Y;
		local Ws = Scroll.AbsoluteWindowSize.Y;
		if not Cs or not Ws or Ws <= 0 or Cs <= Ws + 2 then
			Track.Visible = false;
			return;
		end;
		Track.Visible = true;
		Track.Size = UDim2.new(0, BarW, 0, math.max(Ws - 4, 10));
		local Frac   = math.clamp(Ws / Cs, 0.06, 1);
		local MaxPos = Cs - Ws;
		local P      = (MaxPos > 0) and math.clamp(Scroll.CanvasPosition.Y / MaxPos, 0, 1) or 0;
		Handle.Size     = UDim2.new(1, 0, Frac, 0);
		Handle.Position = UDim2.new(0, 0, P * (1 - Frac), 0);
		if FlashIt then Flash() end;
	end;
	Library:Connection(Scroll:GetPropertyChangedSignal("CanvasPosition"), function() Update(true) end);
	Library:Connection(Scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"), function() Update(false) end);
	Library:Connection(Scroll:GetPropertyChangedSignal("AbsoluteSize"), function() Update(false) end);
	task.defer(Update, false);
	local DragStartY, StartCanvas;
	Library:Connection(Handle.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			DraggingBar = true;
			Library.CanDrag = false;
			DragStartY  = Input.Position.Y;
			StartCanvas = Scroll.CanvasPosition.Y;
			Flash();
		end;
	end);
	Library:Connection(Handle.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			DraggingBar = false;
			Library.CanDrag = true;
			Flash();
		end;
	end);
	Library:Connection(UserInputService.InputChanged, function(Input)
		if not DraggingBar then return end;
		if Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
		local Cs = Scroll.AbsoluteCanvasSize.Y;
		local Ws = Scroll.AbsoluteWindowSize.Y;
		local MaxPos = Cs - Ws;
		if MaxPos <= 0 then return end;
		local Frac   = math.clamp(Ws / Cs, 0.06, 1);
		local RelMax = Track.AbsoluteSize.Y * (1 - Frac);
		if RelMax <= 0 then return end;
		local DFrac = (Input.Position.Y - DragStartY) / RelMax;
		Scroll.CanvasPosition = Vector2.new(
			Scroll.CanvasPosition.X,
			math.clamp(StartCanvas + DFrac * MaxPos, 0, MaxPos)
		);
	end);
end;
print("rn7")
function Library:Resizable(TargetFrame, Minimum, Maximum)
	Minimum = Minimum or Vector2.new(TargetFrame.Size.X.Offset, TargetFrame.Size.Y.Offset);
	local Grip = self:CreateInstance("TextButton", {
		Parent                 = TargetFrame;
		AnchorPoint            = Vector2.new(1, 1);
		BorderColor3           = Color3.fromRGB(0, 0, 0);
		Size                   = IsMobilePlatform and UDim2.new(0, 26, 0, 26) or UDim2.new(0, 8, 0, 8);
		Position               = UDim2.new(1, 0, 1, 0);
		Name                   = "\0";
		BorderSizePixel        = 0;
		BackgroundTransparency = 1;
		AutoButtonColor        = false;
		Visible                = true;
		Text                   = "";
	});
	local Resizing  = false;
	local Start     = UDim2.new();
	local ResizeMax = TargetFrame.Parent.AbsoluteSize - TargetFrame.AbsoluteSize;
	local DotSize = IsMobilePlatform and 10 or 6;
	local IdleT, HoverT, DownT = (IsMobilePlatform and 0.55 or 0.65), 0.3, 0.05;
	local GripDot = self:CreateInstance("Frame", {
		Parent                 = Grip;
		AnchorPoint            = Vector2.new(1, 1);
		Position               = UDim2.new(1, -2, 1, -2);
		Size                   = UDim2.fromOffset(DotSize, DotSize);
		BackgroundColor3       = Library.Accent;
		BackgroundTransparency = IdleT;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UICorner", { Parent = GripDot; CornerRadius = UDim.new(0.5, 0) });
	Library:RegisterAccent(GripDot, "BackgroundColor3");
	local GripRing = self:CreateInstance("UIStroke", {
		Parent          = GripDot;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		Transparency    = 0.55;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	});
	local DotInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local function SetDot(State)
		local T = (State == "down") and DownT or (State == "hover") and HoverT or IdleT;
		local Grow = (State == "down") and 2 or 0;
		Library:Tween(GripDot, DotInfo, {
			BackgroundTransparency = T;
			Size = UDim2.fromOffset(DotSize + Grow, DotSize + Grow);
		}):Play();
		Library:Tween(GripRing, DotInfo, { Transparency = (State == "down") and 0.15 or 0.55 }):Play();
	end;
	self:Connection(Grip.MouseEnter, function() if not Resizing then SetDot("hover") end end);
	self:Connection(Grip.MouseLeave, function() if not Resizing then SetDot("idle") end end);
	local LastPos, Dirty = nil, false;
	local ShadowCache = nil;
	local function SetShadows(Enabled)
		if not ShadowCache then
			ShadowCache = {};
			for _, D in TargetFrame:GetDescendants() do
				if D.ClassName == "UIShadow" then table.insert(ShadowCache, D) end;
			end;
		end;
		for _, Sh in ShadowCache do
			local Ok = pcall(function() Sh.Enabled = Enabled end);
			if not Ok then
				pcall(function()
					if Enabled then
						Sh.Transparency = Sh:GetAttribute("CoincideShadowT") or 0.5;
					else
						Sh:SetAttribute("CoincideShadowT", Sh.Transparency);
						Sh.Transparency = 1;
					end;
				end);
			end;
		end;
	end;
	self:Connection(Grip.InputBegan, function(Input)
		if Library.CantDragForced then return end;
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = true;
			SetDot("down");
			SetShadows(false);
			local S = Library:_GetUIScaleOf(TargetFrame);
			Start   = TargetFrame.Size - UDim2.new(0, Input.Position.X / S, 0, Input.Position.Y / S);
			LastPos = Input.Position;
			Dirty   = true;
		end;
	end);
	self:Connection(Grip.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false;
			SetDot("idle");
			SetShadows(true);
			LastPos, Dirty = nil, false;
		end;
	end);
	self:Connection(UserInputService.InputChanged, function(Input)
		if not Resizing then return end;
		if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
		LastPos = Input.Position;
		Dirty   = true;
	end);
	self:Connection(RunService.RenderStepped, function()
		if not Resizing or not Dirty or not LastPos then return end;
		Dirty = false;
		local S = Library:_GetUIScaleOf(TargetFrame);
		ResizeMax = Maximum or (TargetFrame.Parent.AbsoluteSize / S);
		local Delta = Start + UDim2.new(0, LastPos.X / S, 0, LastPos.Y / S);
		TargetFrame.Size = UDim2.new(
			0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X),
			0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y)
		);
	end);
	return Grip;
end;
function Library:AddGlowing(frame,color,transparency)
	local glow = Instance.new("ImageLabel", frame);
	glow.Name = "GlowEffect";
	glow.Image = "rbxassetid://18245826428";
	glow.ScaleType = Enum.ScaleType.Slice;
	glow.SliceCenter = Rect.new(10, 10, 60, 60);
	glow.ImageColor3 = color;
	glow.ImageTransparency = transparency;
	glow.BackgroundTransparency = 1;
	glow.Size = UDim2.new(1, 40, 1, 40);
	glow.Position = UDim2.new(0, -10, 0, -20);
	glow.ZIndex = -1;
end
function Library:AddGlowingV2(frame,color,transparency)
	pcall(function()
		local glow = Library:CreateInstance("UIShadow");
		glow.BlurRadius = UDim.new(0, 10);
		glow.Color = color;
		glow.Transparency = transparency;
		glow.Parent = frame;
		glow.Enabled = true;
		if color == Library.Accent then
			table.insert(Library.AccentParts, { Inst = glow, Prop = "Color" });
		end;
	end);
end
local ProggyCleanFont;
do
	local Asset = Library:RegisterFont("ProggyClean", "https://github.com/networph-private874612748471/curly-octo-memory/raw/refs/heads/main/fs-tahoma-8px.ttf", 400, "normal");
	if Asset then
		ProggyCleanFont = Font.new(Asset, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	else
		print("font no work lmfao");
	end;
end;
getgenv().proggyfont = ProggyCleanFont
function Library:Tooltip(Inst, Text)
	if not Inst or not Text or Text == "" then return end;
	if not self._TooltipFrame then
		local Gui = self:CreateInstance("ScreenGui", {
			Name           = "Tooltip";
			Parent         = (gethui and gethui()) or CoreGui;
			IgnoreGuiInset = true;
			ResetOnSpawn   = false;
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
			DisplayOrder   = 9999;
		});
		local Frame = self:CreateInstance("CanvasGroup", {
			Name              = "Box";
			Parent            = Gui;
			Size              = UDim2.new(0, 0, 0, 0);
			AutomaticSize     = Enum.AutomaticSize.XY;
			BackgroundColor3  = Color3.fromHex("000000");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 200;
		});
		self:CreateInstance("UIPadding", {
			Parent = Frame; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
			PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
		});
		local Gray = self:CreateInstance("Frame", {
			Parent           = Frame;
			Size             = UDim2.new(0, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.XY;
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		self:CreateInstance("UIPadding", {
			Parent = Gray; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
			PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
		});
		local Inside = self:CreateInstance("Frame", {
			Parent           = Gray;
			Size             = UDim2.new(0, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.XY;
			BackgroundColor3 = Color3.fromHex("131313");
			BorderSizePixel  = 0;
		});
		self:CreateInstance("UIPadding", {
			Parent = Inside; PaddingLeft = UDim.new(0, 6); PaddingRight = UDim.new(0, 6);
			PaddingTop = UDim.new(0, 3); PaddingBottom = UDim.new(0, 3);
		});
		local Lbl = self:CreateInstance("TextLabel", {
			Name                   = "Text";
			Parent                 = Inside;
			Size                   = UDim2.new(0, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.XY;
			BackgroundTransparency = 1;
			Text                   = "";
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		self._TooltipGui   = Gui;
		self._TooltipFrame = Frame;
		self._TooltipLabel = Lbl;
		local _GuiInsetVec = Vector2.new(0, GuiInset);
		self:Connection(RunService.Heartbeat, function()
			local ActiveInst = self._TooltipActive;
			if not ActiveInst then return end;
			if not ActiveInst.Parent then
				self:_HideTooltip();
				return;
			end;
			if self._TooltipTouch then return end;
			local MousePos = UserInputService:GetMouseLocation();
			local Adjusted = MousePos - _GuiInsetVec;
			local AbsPos   = ActiveInst.AbsolutePosition;
			local AbsSize  = ActiveInst.AbsoluteSize;
			if Adjusted.X < AbsPos.X or Adjusted.X > AbsPos.X + AbsSize.X
				or Adjusted.Y < AbsPos.Y or Adjusted.Y > AbsPos.Y + AbsSize.Y then
				self:_HideTooltip();
			end;
		end);
	end;
	local Frame    = self._TooltipFrame;
	local Lbl      = self._TooltipLabel;
	local InInfo   = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
	local OutInfo  = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In);
	local SwapInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In);
	function self:_HideTooltip()
		if not self._TooltipActive then return end;
		self._TooltipActive = nil;
		self._TooltipTouch  = nil;
		local Mine = (self._TooltipToken or 0) + 1;
		self._TooltipToken = Mine;
		Library:Tween(Frame, OutInfo, { GroupTransparency = 1 }):Play();
		task.delay(OutInfo.Time, function()
			if self._TooltipToken == Mine then Frame.Visible = false end;
		end);
	end;
	self:Connection(Inst.MouseEnter, function()
		self._TooltipTouch  = nil;
		self._TooltipActive = Inst;
		self._TooltipToken  = (self._TooltipToken or 0) + 1;
		local Mine = self._TooltipToken;
		local function FadeIn()
			Lbl.Text                = tostring(Text);
			Frame.Visible           = true;
			Frame.GroupTransparency = 1;
			Library:Tween(Frame, InInfo, { GroupTransparency = 0 }):Play();
		end;
		if Frame.Visible and Frame.GroupTransparency < 1 then
			Library:Tween(Frame, SwapInfo, { GroupTransparency = 1 }):Play();
			task.delay(SwapInfo.Time, function()
				if self._TooltipToken == Mine then FadeIn() end;
			end);
		else
			FadeIn();
		end;
	end);
	self:Connection(Inst.MouseMoved, function(X, Y)
		if self._TooltipActive ~= Inst then return end;
		Frame.Position = UDim2.fromOffset(X + 14, Y + 6);
	end);
	self:Connection(Inst.MouseLeave, function()
		if self._TooltipActive ~= Inst then return end;
		self:_HideTooltip();
	end);
	if IsMobilePlatform then
		local HoldToken = 0;
		local HoldStart = nil;
		self:Connection(Inst.InputBegan, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch then return end;
			if Inst:GetAttribute("CoincideLP") then return end;
			HoldToken += 1;
			local Mine = HoldToken;
			HoldStart = Vector2.new(Input.Position.X, Input.Position.Y);
			task.delay(0.65, function()
				if Mine ~= HoldToken or not HoldStart then return end;
				if Inst:GetAttribute("CoincideLP") then return end;
				self._TooltipActive     = Inst;
				self._TooltipTouch      = true;
				self._TooltipToken      = (self._TooltipToken or 0) + 1;
				Lbl.Text                = tostring(Text);
				Frame.Visible           = true;
				Frame.GroupTransparency = 1;
				local Cam = Workspace.CurrentCamera;
				local Vp = Cam and Cam.ViewportSize or Vector2.new(800, 600);
				local Tx = math.clamp(HoldStart.X + 12, 4, math.max(Vp.X - 170, 4));
				local Ty = math.max(HoldStart.Y - 40, 4);
				Frame.Position = UDim2.fromOffset(Tx, Ty);
				Library:Tween(Frame, InInfo, { GroupTransparency = 0 }):Play();
			end);
		end);
		self:Connection(Inst.InputChanged, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch or not HoldStart then return end;
			if (Vector2.new(Input.Position.X, Input.Position.Y) - HoldStart).Magnitude > 16 then
				HoldToken += 1;
				HoldStart = nil;
				if self._TooltipActive == Inst then self:_HideTooltip() end;
			end;
		end);
		self:Connection(Inst.InputEnded, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch then return end;
			HoldToken += 1;
			HoldStart = nil;
			if self._TooltipActive == Inst then self:_HideTooltip() end;
		end);
	end;
end;
local function BuildSection(Host, SecOpts)
	SecOpts = typeof(SecOpts) == "table" and SecOpts or { Name = tostring(SecOpts) };
	local SecName = tostring(SecOpts.Name or SecOpts.Title or "section");
	local Side    = string.lower(tostring(SecOpts.Side or "Left"));
	local Column  = (Side == "right") and Host.Right or Host.Left;
	Library:Log("Added section "..SecName)
	local Sec = Library:CreateInstance("Frame", {
		Name                   = "Section_" .. SecName;
		Parent                 = Column;
		Size                   = UDim2.new(1, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	local function Edge(Anchor, Pos, Sz, Color)
		Library:CreateInstance("Frame", {
			Parent           = Sec;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 5;
		});
	end;
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000");
	local TopLine = Library:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Sec;
		AnchorPoint      = Vector2.new(0, 0);
		Position         = UDim2.new(0, 0, 0, 1);
		Size             = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 5;
	});
	local SecTopGradient = Library:CreateInstance("UIGradient", {
		Parent   = TopLine;
		Rotation = 0;
	});
	Library:RegisterAccentGradient(SecTopGradient);
	Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000");
	Edge(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939");
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
	Edge(Vector2.new(0, 0), UDim2.new(0, 1, 0, 2),  UDim2.new(0, 1, 1, -3), "393939");
	Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
	Edge(Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939");
	local TitleCover = Library:CreateInstance("Frame", {
		Name             = "TitleCover";
		Parent           = Sec;
		Position         = UDim2.new(0, 7, 0, 0);
		Size             = UDim2.new(0, 0, 0, 2);
		BackgroundColor3 = Color3.fromHex("161616");
		BorderSizePixel  = 0;
		ZIndex           = 6;
	});
	local GradTop    = Color3.fromHex("161616");
	local GradBottom = Color3.fromHex("101010");
	local function UpdateCoverColor()
		local Ch = Host.Page.Parent.AbsoluteSize.Y;
		if Ch <= 0 then return end;
		local T = math.clamp(
			(TitleCover.AbsolutePosition.Y - Host.Page.Parent.AbsolutePosition.Y) / Ch,
			0, 1
		);
		TitleCover.BackgroundColor3 = GradTop:Lerp(GradBottom, T);
	end;
	TitleCover:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateCoverColor);
	Host.Page.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCoverColor);
	task.defer(UpdateCoverColor);
	local SecTitle = Library:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Sec;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 11, 0, 2);
		AutomaticSize          = Enum.AutomaticSize.X;
		Size                   = UDim2.new(0, 0, 0, 14);
		BackgroundTransparency = 1;
		Text                   = SecName;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
		ZIndex                 = 7;
	});
	if ProggyCleanFont then SecTitle.FontFace = ProggyCleanFont end;
	local function UpdateCover()
		TitleCover.Size = UDim2.new(0, SecTitle.AbsoluteSize.X + 8, 0, 2);
	end;
	SecTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCover);
	UpdateCover();
	local Body = Library:CreateInstance("Frame", {
		Name                   = "Body";
		Parent                 = Sec;
		Position               = UDim2.new(0, 8, 0, 12);
		Size                   = UDim2.new(1, -16, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
	});
	Library:CreateInstance("UIListLayout", {
		Parent        = Body;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 4);
	});
	Library:CreateInstance("UIPadding", {
		Parent        = Body;
		PaddingBottom = UDim.new(0, 8);
	});
	local SecRef = { Name = SecName, Frame = Sec, Title = SecTitle, Body = Body };
	local CollapseBtn = Library:CreateInstance("TextButton", {
		Name                   = "Collapse";
		Parent                 = Sec;
		AnchorPoint            = Vector2.new(1, 0.5);
		Position               = UDim2.new(1, -6, 0, 2);
		Size                   = UDim2.fromOffset(14, 14);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Text                   = "-";
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 14;
		ZIndex                 = 7;
	});
	local Collapsed = false;
	local CollapseAnim = 0;
	function SecRef:SetCollapsed(B)
		B = B and true or false;
		if B == Collapsed then return end;
		Collapsed = B;
		CollapseAnim += 1;
		local Mine = CollapseAnim;
		CollapseBtn.Text = Collapsed and "+" or "-";
		local CurrentHeight = math.max(Sec.AbsoluteSize.Y / Library:_GetUIScaleOf(Sec), 16);
		Sec.AutomaticSize = Enum.AutomaticSize.None;
		Sec.Size = UDim2.new(1, 0, 0, CurrentHeight);
		Sec.ClipsDescendants = true;
		Body.Visible = not Collapsed;
		task.defer(function()
			if Mine ~= CollapseAnim then return end;
			local TargetH = Collapsed and 16 or (12 + Body.AbsoluteSize.Y);
			Library:Tween(Sec, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, TargetH);
			}):Play();
			task.delay(0.22, function()
				if Mine ~= CollapseAnim then return end;
				Sec.ClipsDescendants = false;
				if not Collapsed then
					Sec.AutomaticSize = Enum.AutomaticSize.Y;
					Sec.Size = UDim2.new(1, 0, 0, 0);
				end;
			end);
		end);
	end;
	function SecRef:ToggleCollapsed() self:SetCollapsed(not Collapsed) end;
	function SecRef:IsCollapsed() return Collapsed end;
	SecRef.CollapseButton = CollapseBtn;
	Library:Connection(CollapseBtn.MouseButton1Click, function() SecRef:ToggleCollapsed() end);
	Library:Connection(CollapseBtn.MouseEnter, function() CollapseBtn.TextColor3 = Color3.fromHex("FFFFFF") end);
	Library:Connection(CollapseBtn.MouseLeave, function() CollapseBtn.TextColor3 = Color3.fromHex("8C8F99") end);
	function SecRef:Tabbox(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Box = Library:CreateInstance("Frame", {
			Name                   = "Tabbox";
			Parent                 = Body;
			Size                   = UDim2.new(1, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Strip = Library:CreateInstance("Frame", {
			Name                   = "Tabs";
			Parent                 = Box;
			Size                   = UDim2.new(1, 0, 0, 24);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = Strip;
			FillDirection = Enum.FillDirection.Horizontal;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 0);
		});
		local Pages = Library:CreateInstance("Frame", {
			Name                   = "Pages";
			Parent                 = Box;
			Position               = UDim2.new(0, 0, 0, 30);
			Size                   = UDim2.new(1, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local BoxRef = { Frame = Box, _Tabs = {} };
		local TabSwitchInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local function Activate(TabObj)
			for _, T in ipairs(BoxRef._Tabs) do
				local On = (T == TabObj);
				T._Btn.TextColor3       = On and Color3.fromHex("FFFFFF") or Color3.fromHex("8C8F99");
				T._Btn.BackgroundColor3 = On and Color3.fromHex("232323") or Color3.fromHex("181818");
				Library:Tween(T._Line, TabSwitchInfo, { BackgroundTransparency = On and 0 or 1 }):Play();
				if On then
					T.Body.Visible = true;
					T.Body.GroupTransparency = 1;
					T.Body.Position = UDim2.fromOffset(0, 6);
					Library:Tween(T.Body, TabSwitchInfo, {
						GroupTransparency = 0;
						Position          = UDim2.fromOffset(0, 0);
					}):Play();
				else
					T.Body.Visible = false;
					T.Body.GroupTransparency = 1;
				end;
			end;
		end;
		function BoxRef:Tab(A)
			local Name = typeof(A) == "table" and tostring(A.Name or A.Text or A.Title or "Tab") or tostring(A);
			local Btn = Library:CreateInstance("TextButton", {
				Name                   = "Tab_" .. Name;
				Parent                 = Strip;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundColor3       = Color3.fromHex("181818");
				BorderSizePixel        = 0;
				AutoButtonColor        = false;
				Text                   = Name;
				TextColor3             = Color3.fromHex("8C8F99");
				TextSize               = 12;
			});
			if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
			Library:CreateInstance("UIStroke", {
				Parent  = Btn;
				Color   = Color3.fromHex("000000");
				Thickness = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			local Line = Library:CreateInstance("Frame", {
				Parent                 = Btn;
				AnchorPoint            = Vector2.new(0, 1);
				Position               = UDim2.new(0, 0, 1, 0);
				Size                   = UDim2.new(1, 0, 0, 2);
				BackgroundColor3       = Library.Accent;
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				ZIndex                 = 2;
			});
			Library:RegisterAccent(Line, "BackgroundColor3");
			local PageBody = Library:CreateInstance("CanvasGroup", {
				Name                   = "Page_" .. Name;
				Parent                 = Pages;
				Size                   = UDim2.new(1, 0, 0, 0);
				AutomaticSize          = Enum.AutomaticSize.Y;
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				GroupTransparency      = 1;
				Visible                = false;
			});
			Library:CreateInstance("UIListLayout", {
				Parent        = PageBody;
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder     = Enum.SortOrder.LayoutOrder;
				Padding       = UDim.new(0, 4);
			});
			Library:CreateInstance("UIPadding", {
				Parent        = PageBody;
				PaddingBottom = UDim.new(0, 4);
			});
			local TabObj = setmetatable({ Name = Name, Body = PageBody, Frame = PageBody }, { __index = SecRef });
			TabObj._Btn  = Btn;
			TabObj._Line = Line;
			function TabObj:Activate() Activate(self) end;
			Library:Connection(Btn.MouseButton1Click, function() Activate(TabObj) end);
			table.insert(BoxRef._Tabs, TabObj);
			local N = #BoxRef._Tabs;
			for _, T in ipairs(BoxRef._Tabs) do T._Btn.Size = UDim2.new(1 / N, 0, 1, 0) end;
			if Library._EnhanceSection then Library._EnhanceSection(TabObj) end;
			if N == 1 then Activate(TabObj) end;
			return TabObj;
		end;
		BoxRef.AddTab = BoxRef.Tab;
		return BoxRef;
	end;
	SecRef.AddTabbox = SecRef.Tabbox;
	function SecRef:Toggle(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Toggle");
		local Default  = Opts.Default == true;
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		local State    = Default;
		Library.Flags[Flag] = State;
		Library:Log("Added Toggle Opts: "..Name,Default)
		local Risk = Opts.Risk and string.lower(tostring(Opts.Risk))
			or (Opts.Risky and "risky") or (Opts.Warning and "warning") or nil;
		local OnColor  = Color3.fromHex("FFFFFF");
		local OffColor = Color3.fromHex("8C8F99");
		if Risk == "risky" or Risk == "danger" or Risk == "red" then
			OnColor  = Color3.fromHex("FF8585");
			OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
		elseif Risk == "warning" or Risk == "warn" or Risk == "yellow" then
			OnColor  = Color3.fromHex("FFD27B");
			OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
		end;
		local Row = Library:CreateInstance("TextButton", {
			Name                   = "Toggle_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 16);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = "";
		});
		local Box = Library:CreateInstance("Frame", {
			Name             = "Box";
			Parent           = Row;
			AnchorPoint      = Vector2.new(0, 0.5);
			Position         = UDim2.new(0, 0, 0.5, 0);
			Size             = UDim2.fromOffset(14, 14);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
		});
		local BoxGray = Library:CreateInstance("Frame", {
			Name             = "Gray";
			Parent           = Box;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local BoxInside = Library:CreateInstance("Frame", {
			Name             = "Inside";
			Parent           = BoxGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("131313");
			BorderSizePixel  = 0;
		});
		local Fill = Library:CreateInstance("Frame", {
			Name                   = "Fill";
			Parent                 = BoxInside;
			AnchorPoint            = Vector2.new(0.5, 0.5);
			Position               = UDim2.new(0.5, 0, 0.5, 0);
			Size                   = UDim2.new(0, 0, 0, 0);
			BackgroundColor3       = Color3.fromHex("3972EC");
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:RegisterAccent(Fill);
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Row;
			AnchorPoint            = Vector2.new(0, 0.5);
			Position               = UDim2.new(0, 20, 0.5, 0);
			Size                   = UDim2.new(1, -20, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local TweenIn  = TweenInfo.new(0.16, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out);
		local TweenOut = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.In);
		local function Render()
			local Info = State and TweenIn or TweenOut;
			Library:Tween(Fill, Info, {
				Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
				BackgroundTransparency = State and 0 or 1;
			}):Play();
			Library:Tween(Lbl, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = State and OnColor or OffColor;
			}):Play();
		end;
		Fill.Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
		Fill.BackgroundTransparency = State and 0 or 1;
		Lbl.TextColor3              = State and OnColor or OffColor;
		local Listeners = {};
		local function SetState(V, Fire)
			V = V == true;
			if V == State then return end;
			State = V;
			Library.Flags[Flag] = State;
			Render();
			if Fire ~= false then Callback(State) end;
			for _, Fn in Listeners do Fn(State) end;
			Library:NotifyKeybind();
		end;
		local SwipedAt = 0;
		Row.MouseButton1Click:Connect(function()
			if os.clock() - SwipedAt < 0.25 then return end;
			SetState(not State);
		end);
		do
			local SwipeStart = nil;
			Row.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.Touch then
					SwipeStart = Vector2.new(Input.Position.X, Input.Position.Y);
				end;
			end);
			Row.InputEnded:Connect(function(Input)
				if not SwipeStart or Input.UserInputType ~= Enum.UserInputType.Touch then return end;
				local D = Vector2.new(Input.Position.X, Input.Position.Y) - SwipeStart;
				SwipeStart = nil;
				if math.abs(D.X) > 60 and math.abs(D.Y) < 28 then
					SwipedAt = os.clock();
					SetState(D.X > 0);
				end;
			end);
		end;
		if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
		local Obj = { Container = Row, Box = Box, Fill = Fill };
		function Obj:Get() return State end;
		function Obj:Set(V) SetState(V) end;
		Library.Options[Flag] = {
			Save = function() return State end;
			Load = function(Data) SetState(Data == true) end;
		};
		function Obj:OnChange(Fn)
			if typeof(Fn) ~= "function" then return end;
			table.insert(Listeners, Fn);
			Fn(State);
		end;
		function Obj:AddKeybind(BindOpts)
			if self._HasKeybind then return self end;
			self._HasKeybind = true;
			BindOpts = typeof(BindOpts) == "table" and BindOpts or {};
			local BindMode = string.lower(tostring(BindOpts.Mode or "Toggle"));
			if BindMode ~= "toggle" and BindMode ~= "hold" and BindMode ~= "always" then BindMode = "toggle" end;
			local Key      = BindOpts.Default;
			local BindFlag      = tostring(BindOpts.Flag or (Flag .. "_Key"));
			local BindOnChanged = typeof(BindOpts.OnChanged) == "function" and BindOpts.OnChanged or nil;
			local MenuVisible   = BindOpts.MenuVisible ~= false and BindOpts.NoUI ~= true;
			local function KeyText(K)
				if K == nil then return "None" end;
				if typeof(K) == "EnumItem" then return Library.KeyNames[K] or K.Name end;
				return tostring(K);
			end;
			local KBoxW = 48;
			local Off = self._RightOffset or 0;
			local KBtn = Library:CreateInstance("TextButton", {
				Name             = "Keybind";
				Parent           = Row;
				AnchorPoint      = Vector2.new(1, 0.5);
				Position         = UDim2.new(1, -Off, 0.5, 0);
				Size             = UDim2.fromOffset(KBoxW, 16);
				BackgroundColor3 = Color3.fromHex("000000");
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			local KGray = Library:CreateInstance("Frame", {
				Name             = "Gray";
				Parent           = KBtn;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("393939");
				BorderSizePixel  = 0;
			});
			local KInside = Library:CreateInstance("Frame", {
				Name             = "Inside";
				Parent           = KGray;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("FFFFFF");
				BorderSizePixel  = 0;
			});
			Library:CreateInstance("UIGradient", {
				Parent   = KInside;
				Rotation = 90;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
					NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
				});
			});
			local KLbl = Library:CreateInstance("TextLabel", {
				Name                   = "Display";
				Parent                 = KInside;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				Text                   = KeyText(Key);
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Center;
				TextYAlignment         = Enum.TextYAlignment.Center;
			});
			if ProggyCleanFont then KLbl.FontFace = ProggyCleanFont end;
			local Listening = false;
			local ListenConn;
			local function Refresh()
				if Listening then
					KLbl.Text       = "...";
					KLbl.TextColor3 = Library.Accent;
				else
					KLbl.Text       = KeyText(Key);
					KLbl.TextColor3 = Color3.fromHex("FFFFFF");
				end;
			end;
			local function CancelListen()
				if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
				Listening = false;
				Refresh();
			end;
			local function StartListen()
				if Listening then CancelListen(); return end;
				Listening = true;
				Refresh();
				task.defer(function()
					if not Listening then return end;
					ListenConn = UserInputService.InputBegan:Connect(function(Input)
						local T = Input.UserInputType;
						if T == Enum.UserInputType.Keyboard then
							local K = Input.KeyCode;
							if K == Enum.KeyCode.Escape then
								CancelListen();
							else
								Key = K;
								Listening = false;
								if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
								Refresh();
								if BindOnChanged then BindOnChanged(Key) end;
								Library:NotifyKeybind();
							end;
						elseif T == Enum.UserInputType.MouseButton1
							or T == Enum.UserInputType.MouseButton2
							or T == Enum.UserInputType.MouseButton3 then
							Key = T;
							Listening = false;
							if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
							Refresh();
							if BindOnChanged then BindOnChanged(Key) end;
							Library:NotifyKeybind();
						end;
					end);
				end);
			end;
			KBtn.MouseButton1Click:Connect(StartListen);
			local function ClearBind()
				if Listening then CancelListen() end;
				Key = nil;
				Refresh();
				if BindOnChanged then BindOnChanged(Key) end;
				Library:NotifyKeybind();
			end;
			KBtn.MouseButton2Click:Connect(ClearBind);
			Library:BindLongPress(KBtn, ClearBind);
			local function KeyMatches(Input)
				if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
				if Key.EnumType == Enum.KeyCode then
					return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
				elseif Key.EnumType == Enum.UserInputType then
					return Input.UserInputType == Key;
				end;
				return false;
			end;
			Library:Connection(UserInputService.InputBegan, function(Input, GameProc)
				if GameProc then return end;
				if Listening then return end;
				if UserInputService:GetFocusedTextBox() then return end;
				if not KeyMatches(Input) then return end;
				if BindMode == "hold" then
					SetState(true);
				elseif BindMode == "toggle" then
					SetState(not State);
				end;
			end);
			Library:Connection(UserInputService.InputEnded, function(Input)
				if BindMode ~= "hold" then return end;
				if not KeyMatches(Input) then return end;
				SetState(false);
			end);
			local BindEntry = Library:RegisterKeybind({
				Name     = Name;
				Mode     = BindMode;
				GetMode  = function() return BindMode end;
				GetKey   = function() return Key end;
				GetState = function() return State end;
				SetState = function(V) if BindMode == "toggle" then SetState(V) end end;
				Toggle   = function() if BindMode == "toggle" then SetState(not State) end end;
				GetMenuVisible = function() return MenuVisible end;
				SetMenuVisible = function(V)
					MenuVisible = V == true;
					Library:NotifyKeybind();
				end;
			});
			if BindMode == "always" then SetState(true) end;
			self._RightOffset = Off + KBoxW + 4;
			Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);
			self.Keybind        = KBtn;
			self.KeybindDisplay = KLbl;
			self.KeybindObj = {
				GetKey   = function() return Key end;
				GetState = function() return State end;
				GetMode  = function() return BindMode end;
				SetKey   = function(K)
					if Listening then CancelListen() end;
					Key = K;
					Refresh();
					if BindOnChanged then BindOnChanged(Key) end;
					Library:NotifyKeybind();
				end;
				SetMode = function(M)
					M = string.lower(tostring(M or "toggle"));
					if M ~= "toggle" and M ~= "hold" and M ~= "always" then return end;
					BindMode = M;
					BindEntry.Mode = M;
					if M == "always" then SetState(true) end;
					Library:NotifyKeybind();
				end;
				GetMenuVisible = function() return MenuVisible end;
				SetMenuVisible = function(V) BindEntry.SetMenuVisible(V) end;
				SetText = function(T)
					Name = tostring(T);
					Lbl.Text = Name;
					BindEntry.Name = Name;
					Library:NotifyKeybind();
				end;
			};
			Library.Options[BindFlag] = {
				Save = function()
					local Out = { _t = "Key", m = BindMode };
					if typeof(Key) == "EnumItem" then
						Out.k = tostring(Key.EnumType) .. "." .. Key.Name;
					end;
					return Out;
				end;
				Load = function(Data)
					if typeof(Data) ~= "table" or Data._t ~= "Key" then return end;
					if Data.m and self.KeybindObj and self.KeybindObj.SetMode then self.KeybindObj.SetMode(Data.m) end;
					local NewKey = nil;
					if typeof(Data.k) == "string" then
						local EType, EName = string.match(Data.k, "^(%w+)%.(%w+)$");
						if EType and EName then
							pcall(function() NewKey = Enum[EType][EName] end);
						end;
					end;
					if Listening then CancelListen() end;
					Key = NewKey;
					Refresh();
					if BindOnChanged then BindOnChanged(Key) end;
					Library:NotifyKeybind();
				end;
			};
			return self;
		end;
		function Obj:AddColorpicker(CpOpts)
			CpOpts = typeof(CpOpts) == "table" and CpOpts or {};
			local Color    = typeof(CpOpts.Default) == "Color3" and CpOpts.Default or Color3.fromRGB(255,255,255);
			local Alpha    = tonumber(CpOpts.Alpha) or 1;
			local Callback = typeof(CpOpts.Callback) == "function" and CpOpts.Callback or function() end;
			self._Colors   = (self._Colors or 0) + 1;
			local Flag     = tostring(CpOpts.Flag or CpOpts.Pointer or ("_" .. Name .. "Color" .. self._Colors));
			local H, Sa, Va = Color3.toHSV(Color);
			local A         = math.clamp(Alpha, 0, 1);
			Library.Flags[Flag] = Color;
			Library:Log("Added color picker 0x0")
			local SwW, SwH = 25, 15;
			local Off = self._RightOffset or 0;
			local Swatch = Library:CreateInstance("TextButton", {
				Name             = "ToggleSwatch";
				Parent           = Row;
				AnchorPoint      = Vector2.new(1, 0.5);
				Position         = UDim2.new(1, -Off, 0.5, 0);
				Size             = UDim2.fromOffset(SwW, SwH);
				AutoButtonColor  = false;
				Text             = "";
				BackgroundColor3 = Color3.fromHex("000105");
				BorderSizePixel  = 0;
			});
			local SwInline = Library:CreateInstance("Frame", {
				Parent           = Swatch;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("252527");
				BorderSizePixel  = 0;
			});
			local SwHandle = Library:CreateInstance("Frame", {
				Parent           = SwInline;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BorderSizePixel  = 0;
			});
			Library:CreateInstance("ImageLabel", {
				Parent                 = SwHandle;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				Image                  = "rbxassetid://18274452449";
				ScaleType              = Enum.ScaleType.Tile;
				TileSize               = UDim2.new(0, 6, 0, 6);
				ZIndex                 = 2;
			});
			local SwFill = Library:CreateInstance("Frame", {
				Parent                 = SwHandle;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundColor3       = Color;
				BackgroundTransparency = 1 - Alpha;
				BorderSizePixel        = 0;
				ZIndex                 = 3;
			});
			Library:CreateInstance("UIGradient", {
				Parent   = SwFill;
				Rotation = 90;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
					NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
				});
			});
			self._RightOffset = Off + SwW + 4;
			Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);
			local PickerHolder = Library:CreateInstance("CanvasGroup", {
				Name              = "TogglePicker";
				Parent            = Host.Gui;
				Size              = UDim2.new(0, 218, 0, 248);
				BackgroundColor3  = Color3.fromHex("131313");
				BorderSizePixel   = 0;
				Visible           = false;
				GroupTransparency = 1;
				ZIndex            = 50;
			});
			local PickerOuterStroke = Library:CreateInstance("UIStroke", {
				Parent          = PickerHolder;
				Color           = Color3.fromHex("000000");
				Thickness       = 1;
				Transparency    = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			local PickerInner = Library:CreateInstance("Frame", {
				Parent                 = PickerHolder;
				Position               = UDim2.new(0, 1, 0, 1);
				Size                   = UDim2.new(1, -2, 1, -2);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
			});
			local PickerInnerStroke = Library:CreateInstance("UIStroke", {
				Parent          = PickerInner;
				Color           = Color3.fromHex("393939");
				Thickness       = 1;
				Transparency    = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			local PickerBody = Library:CreateInstance("Frame", {
				Parent                 = PickerHolder;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
			});
			Library:CreateInstance("UIPadding", {
				Parent        = PickerBody;
				PaddingTop    = UDim.new(0, 8);
				PaddingBottom = UDim.new(0, 8);
				PaddingLeft   = UDim.new(0, 8);
				PaddingRight  = UDim.new(0, 8);
			});
			local MainBg = Library:CreateInstance("Frame", {
				Parent                 = PickerBody;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
			});
			local TabBar = Library:CreateInstance("Frame", {
				Name                   = "TabBar";
				Parent                 = MainBg;
				Position               = UDim2.new(0, 0, 0, 0);
				Size                   = UDim2.new(1, 0, 0, 20);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
			});
			local CpInactiveSeq = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
				NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
			});
			local CpActiveSeq = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
				NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
			});
			local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
			local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
			local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
			local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
			local ColorPage, AnimationsPanel;
			local CpTabToken = 0;
			local TabButtons = {};
			local function MakeCpTab(Name, Idx, Total)
				local Btn = Library:CreateInstance("TextButton", {
					Parent                 = TabBar;
					Size                   = UDim2.new(1 / Total, 0, 1, 0);
					Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					AutoButtonColor        = false;
					Text                   = "";
				});
				local Bg = Library:CreateInstance("Frame", {
					Name             = "Bg";
					Parent           = Btn;
					Size             = UDim2.new(1, 0, 1, 0);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				local BgGrad = Library:CreateInstance("UIGradient", {
					Parent   = Bg;
					Rotation = 90;
					Color    = CpInactiveSeq;
				});
				local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
					return Library:CreateInstance("Frame", {
						Parent                 = Bg;
						AnchorPoint            = Anchor;
						Position               = Pos;
						Size                   = Sz;
						BackgroundColor3       = Color3.fromHex(Color);
						BorderSizePixel        = 0;
						BackgroundTransparency = 1;
						ZIndex                 = ZIdx;
					});
				end;
				local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
				local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
				local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
				local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
				local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
				local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
				local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
				local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
				local TopGradient = Library:CreateInstance("Frame", {
					Parent                 = Bg;
					AnchorPoint            = Vector2.new(0, 0);
					Position               = UDim2.new(0, 0, 0, 0);
					Size                   = UDim2.new(1, 0, 0, 1);
					BackgroundColor3       = Color3.fromHex("FFFFFF");
					BorderSizePixel        = 0;
					BackgroundTransparency = 1;
					ZIndex                 = 5;
				});
				local Grad = Library:CreateInstance("UIGradient", { Parent = TopGradient; Rotation = 0 });
				Library:RegisterAccentGradient(Grad);
				local Lbl = Library:CreateInstance("TextLabel", {
					Name                   = "Label";
					Parent                 = Bg;
					Size                   = UDim2.new(1, 0, 1, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					Text                   = Name;
					TextSize               = 12;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextXAlignment         = Enum.TextXAlignment.Center;
					TextYAlignment         = Enum.TextYAlignment.Center;
					ZIndex                 = 6;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
				local Entry = {
					Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
					TopBlack = TopBlack, TopGray = TopGray;
					BottomBlack = BottomBlack, BottomGray = BottomGray;
					LeftBlack = LeftBlack, LeftGray = LeftGray;
					RightBlack = RightBlack, RightGray = RightGray;
					GradT = 0; GradTarget = 0;
				};
				local function ApplyGrad()
					BgGrad.Color = NewColorSequence({
						NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
						NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
					});
				end;
				ApplyGrad();
				Library:Connection(RunService.Heartbeat, function(Dt)
					if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
						if Entry.GradT ~= Entry.GradTarget then
							Entry.GradT = Entry.GradTarget;
							ApplyGrad();
						end;
						return;
					end;
					Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
					ApplyGrad();
				end);
				table.insert(TabButtons, Entry);
				return Btn;
			end;
			local ColorTabBtn = MakeCpTab("Color", 1, 2);
			local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);
			local function SetCpTab(I)
				for i, T in TabButtons do
					if i == I then
						T.GradTarget = 1;
						Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
						for _, N in CpOutlineNames do
							Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
						end;
					else
						T.GradTarget = 0;
						Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
						for _, N in CpOutlineNames do
							Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
						end;
					end;
				end;
				if ColorPage and AnimationsPanel then
					CpTabToken = CpTabToken + 1;
					local Mine = CpTabToken;
					ColorPage.Visible       = true;
					AnimationsPanel.Visible = true;
					if I == 1 then
						Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
						Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
					else
						Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
						Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
					end;
					task.delay(CpAnimInfo.Time, function()
						if CpTabToken ~= Mine then return end;
						if I == 1 then AnimationsPanel.Visible = false end;
						if I == 2 then ColorPage.Visible       = false end;
					end);
				end;
			end;
			SetCpTab(1);
			ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
			AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);
			ColorPage = Library:CreateInstance("CanvasGroup", {
				Name                   = "ColorPage";
				Parent                 = MainBg;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				GroupTransparency      = 0;
				ZIndex                 = 54;
			});
			local SatValArea = Library:CreateInstance("Frame", {
				Parent           = ColorPage;
				Position         = UDim2.new(0, 0, 0, 24);
				Size             = UDim2.new(1, -30, 1, -66);
				BackgroundColor3 = Color3.fromRGB(255, 0, 0);
				BorderSizePixel  = 0;
			});
			Library:CreateInstance("UIStroke", {
				Parent          = SatValArea;
				Color           = Color3.fromHex("000105");
				Thickness       = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			local SatLayer = Library:CreateInstance("TextButton", {
				Parent           = SatValArea;
				Size             = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			Library:CreateInstance("UIGradient", {
				Parent       = SatLayer;
				Rotation     = 270;
				Transparency = NewNumberSequence({
					NewNumberSequenceKeypoint(0, 0);
					NewNumberSequenceKeypoint(1, 1);
				});
				Color = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
					NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
				});
			});
			local ValLayer = Library:CreateInstance("TextButton", {
				Parent           = SatValArea;
				Size             = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			Library:CreateInstance("UIGradient", {
				Parent       = ValLayer;
				Transparency = NewNumberSequence({
					NewNumberSequenceKeypoint(0, 0);
					NewNumberSequenceKeypoint(1, 1);
				});
			});
			local SatValMarker = Library:CreateInstance("Frame", {
				Parent           = SatValArea;
				Size             = UDim2.new(0, 2, 0, 2);
				BorderSizePixel  = 1;
				BorderColor3     = Color3.fromRGB(0, 0, 0);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			});
			local HueArea = Library:CreateInstance("TextButton", {
				Parent           = ColorPage;
				AnchorPoint      = Vector2.new(1, 0);
				Position         = UDim2.new(1, -14, 0, 24);
				Size             = UDim2.new(0, 12, 1, -66);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			Library:CreateInstance("UIStroke", {
				Parent          = HueArea;
				Color           = Color3.fromHex("000105");
				Thickness       = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			Library:CreateInstance("UIGradient", {
				Parent   = HueArea;
				Rotation = 270;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
					NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
					NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
					NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
					NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
					NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
					NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
				});
			});
			local HueMarker = Library:CreateInstance("Frame", {
				Parent           = HueArea;
				Size             = UDim2.new(1, 0, 0, 2);
				BorderSizePixel  = 1;
				BorderColor3     = Color3.fromRGB(0, 0, 0);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			});
			local AlphaArea = Library:CreateInstance("TextButton", {
				Parent           = ColorPage;
				AnchorPoint      = Vector2.new(1, 0);
				Position         = UDim2.new(1, 0, 0, 24);
				Size             = UDim2.new(0, 12, 1, -66);
				BackgroundColor3 = Color;
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			Library:CreateInstance("UIStroke", {
				Parent          = AlphaArea;
				Color           = Color3.fromHex("000105");
				Thickness       = 1;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			});
			local AlphaCheckers = Library:CreateInstance("ImageLabel", {
				Parent                 = AlphaArea;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				Image                  = "rbxassetid://18274452449";
				ScaleType              = Enum.ScaleType.Tile;
				TileSize               = UDim2.new(0, 6, 0, 6);
			});
			Library:CreateInstance("UIGradient", {
				Parent       = AlphaCheckers;
				Rotation     = 270;
				Transparency = NewNumberSequence({
					NewNumberSequenceKeypoint(0, 0);
					NewNumberSequenceKeypoint(1, 1);
				});
			});
			local AlphaMarker = Library:CreateInstance("Frame", {
				Parent           = AlphaArea;
				Size             = UDim2.new(1, 0, 0, 2);
				BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				BorderSizePixel  = 1;
				BorderColor3     = Color3.fromRGB(0, 0, 0);
			});
			local function MakeInput(YOffFromBottom)
				local Box = Library:CreateInstance("Frame", {
					Parent           = ColorPage;
					AnchorPoint      = Vector2.new(0, 1);
					Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
					Size             = UDim2.new(1, 0, 0, 18);
					BackgroundColor3 = Color3.fromHex("000000");
					BorderSizePixel  = 0;
				});
				local Gray = Library:CreateInstance("Frame", {
					Parent           = Box;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("393939");
					BorderSizePixel  = 0;
				});
				local Inside = Library:CreateInstance("Frame", {
					Parent           = Gray;
					Position         = UDim2.new(0, 1, 0, 1);
					Size             = UDim2.new(1, -2, 1, -2);
					BackgroundColor3 = Color3.fromHex("FFFFFF");
					BorderSizePixel  = 0;
				});
				Library:CreateInstance("UIGradient", {
					Parent   = Inside;
					Rotation = 90;
					Color    = NewColorSequence({
						NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
						NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
					});
				});
				local Input = Library:CreateInstance("TextBox", {
					Parent                 = Inside;
					Size                   = UDim2.new(1, -6, 1, 0);
					Position               = UDim2.new(0, 3, 0, 0);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					ClearTextOnFocus       = false;
					Text                   = "";
					PlaceholderColor3      = Color3.fromHex("5E626B");
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Center;
					TextYAlignment         = Enum.TextYAlignment.Center;
					ClipsDescendants       = true;
				});
				if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
				return Input, Box;
			end;
			local HexInput, HexBox = MakeInput(0);
			HexInput.PlaceholderText = "Hex";
			local RgbInput, RgbBox = MakeInput(20);
			RgbInput.PlaceholderText = "R, G, B";
			AnimationsPanel = Library:CreateInstance("CanvasGroup", {
				Name              = "AnimationsPanel";
				Parent            = MainBg;
				Position          = UDim2.new(0, 0, 0, 28);
				Size              = UDim2.new(1, 0, 1, -28);
				BackgroundColor3  = Color3.fromHex("131313");
				BorderSizePixel   = 0;
				Visible           = false;
				GroupTransparency = 1;
				ZIndex            = 55;
			});
			local Mode  = "Solid";
			local Speed = 50;
			local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
			local function AnimLbl(Text, Y)
				local L = Library:CreateInstance("TextLabel", {
					Parent                 = AnimationsPanel;
					Position               = UDim2.new(0, 0, 0, Y);
					Size                   = UDim2.new(1, 0, 0, 12);
					BackgroundTransparency = 1;
					Text                   = Text;
					TextColor3             = Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
				});
				FontIt(L);
			end;
			AnimLbl("Mode", 0);
			local ModeBox = Library:CreateInstance("TextButton", {
				Parent           = AnimationsPanel;
				Position         = UDim2.new(0, 0, 0, 14);
				Size             = UDim2.new(1, 0, 0, 21);
				BackgroundColor3 = Color3.fromHex("000000");
				BorderSizePixel  = 0;
				AutoButtonColor  = false;
				Text             = "";
			});
			local ModeBoxGray = Library:CreateInstance("Frame", {
				Parent = ModeBox; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
			});
			local ModeInside = Library:CreateInstance("Frame", {
				Parent = ModeBoxGray; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
			});
			Library:CreateInstance("UIGradient", {
				Parent = ModeInside; Rotation = 90;
				Color = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
					NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
				});
			});
			local ModeVal = Library:CreateInstance("TextLabel", {
				Parent = ModeInside; Position = UDim2.new(0, 4, 0, 0); Size = UDim2.new(1, -14, 1, 0);
				BackgroundTransparency = 1; Text = Mode; TextColor3 = Color3.fromHex("FFFFFF"); TextSize = 12;
				TextXAlignment = Enum.TextXAlignment.Left; TextYAlignment = Enum.TextYAlignment.Center;
			}); FontIt(ModeVal);
			local ModeArrow = Library:CreateInstance("Frame", {
				Parent = ModeInside; AnchorPoint = Vector2.new(1, 0.5);
				Position = UDim2.new(1, -4, 0.5, 0); Size = UDim2.fromOffset(7, 7);
				BackgroundTransparency = 1; BorderSizePixel = 0;
			});
			Library:CreateInstance("Frame", {
				Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(7, 1);
				BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
			});
			local ModeArrowV = Library:CreateInstance("Frame", {
				Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(1, 7);
				BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
			});
			local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;
			local ModePopup = Library:CreateInstance("CanvasGroup", {
				Parent            = AnimationsPanel;
				Position          = UDim2.new(0, 0, 0, 36);
				Size              = UDim2.new(1, 0, 0, 44);
				BackgroundColor3  = Color3.fromHex("000000");
				BorderSizePixel   = 0;
				Visible           = false;
				GroupTransparency = 1;
				ZIndex            = 60;
			});
			local ModePopupGray = Library:CreateInstance("Frame", {
				Parent = ModePopup; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0; ZIndex = 60;
			});
			local ModePopupInside = Library:CreateInstance("Frame", {
				Parent = ModePopupGray; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0; ZIndex = 61;
			});
			Library:CreateInstance("UIListLayout", {
				Parent = ModePopupInside; FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 0);
			});
			local ModeOptionBtns = {};
			local function RefreshModeOpts()
				for N, B in ModeOptionBtns do
					B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
				end;
			end;
			Library:OnAccent(function() RefreshModeOpts() end);
			local ModePopupOpen = false;
			local ModePopupToken = 0;
			local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
			local ModePopupBaseY = 36;
			local ModePopupSlide = 6;
			local function CloseModePopup()
				if not ModePopupOpen then return end;
				ModePopupOpen = false;
				ModePopupToken = ModePopupToken + 1;
				local Mine = ModePopupToken;
				SetModeArrow(true);
				Library:Tween(ModePopup, ModePopupInfo, {
					GroupTransparency = 1;
					Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
				}):Play();
				task.delay(ModePopupInfo.Time, function()
					if ModePopupToken == Mine then ModePopup.Visible = false end;
				end);
			end;
			local function OpenModePopup()
				if ModePopupOpen then return end;
				ModePopupOpen = true;
				ModePopupToken = ModePopupToken + 1;
				SetModeArrow(false);
				ModePopup.GroupTransparency = 1;
				ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
				ModePopup.Visible           = true;
				Library:Tween(ModePopup, ModePopupInfo, {
					GroupTransparency = 0;
					Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
				}):Play();
			end;
			local function AddModeOpt(Name, Idx)
				local Btn = Library:CreateInstance("TextButton", {
					Parent = ModePopupInside; Size = UDim2.new(1, 0, 0, 14);
					BackgroundTransparency = 1; BorderSizePixel = 0; AutoButtonColor = false;
					Text = Name; TextColor3 = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
					TextSize = 12; TextXAlignment = Enum.TextXAlignment.Left; LayoutOrder = Idx; ZIndex = 62;
				});
				Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
				FontIt(Btn);
				ModeOptionBtns[Name] = Btn;
				Btn.MouseButton1Click:Connect(function()
					Mode = Name; ModeVal.Text = Mode; RefreshModeOpts();
					CloseModePopup();
				end);
			end;
			AddModeOpt("Solid",   1);
			AddModeOpt("Rainbow", 2);
			AddModeOpt("Fading",  3);
			ModeBox.MouseButton1Click:Connect(function()
				if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
			end);
			AnimLbl("Speed", 42);
			local SpeedVal = Library:CreateInstance("TextLabel", {
				Parent = AnimationsPanel; AnchorPoint = Vector2.new(1, 0);
				Position = UDim2.new(1, 0, 0, 42); Size = UDim2.new(0, 40, 0, 12);
				BackgroundTransparency = 1; Text = "50%"; TextColor3 = Color3.fromHex("8C8F99"); TextSize = 12;
				TextXAlignment = Enum.TextXAlignment.Right;
			}); FontIt(SpeedVal);
			local SpTrack = Library:CreateInstance("TextButton", {
				Parent = AnimationsPanel; Position = UDim2.new(0, 0, 0, 58);
				Size = UDim2.new(1, 0, 0, 10); BackgroundColor3 = Color3.fromHex("000000");
				BorderSizePixel = 0; AutoButtonColor = false; Text = "";
			});
			Library:CreateInstance("Frame", {
				Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
			});
			local SpInside = Library:CreateInstance("Frame", {
				Parent = SpTrack:FindFirstChildOfClass("Frame"); Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
			});
			local SpFill = Library:CreateInstance("Frame", {
				Parent = SpInside; Position = UDim2.new(0, 1, 0, 1);
				Size = UDim2.new(0.5, -2, 1, -2); BackgroundColor3 = Library.Accent; BorderSizePixel = 0;
			});
			Library:RegisterAccent(SpFill);
			local SpDragging = false;
			local SpVisualT = 0.5;
			local SpTargetT = 0.5;
			Library:Connection(RunService.Heartbeat, function(Dt)
				if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
				local Alpha = 1 - math.exp(-Dt * 14);
				SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
				SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
			end);
			local function SpUpdate(Px)
				local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
				if Aw <= 0 then return end;
				local T = math.clamp((Px - Ax) / Aw, 0, 1);
				Speed = math.floor(T * 100 + 0.5);
				SpTargetT = T;
				SpeedVal.Text = Speed .. "%";
			end;
			Library:Connection(SpTrack.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SpDragging = true; SpUpdate(Input.Position.X);
				end;
			end);
			Library:Connection(SpTrack.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SpDragging = false;
				end;
			end);
			Library:Connection(UserInputService.InputChanged, function(Input)
				if not SpDragging then return end;
				if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
					SpUpdate(Input.Position.X);
				end;
			end);
			local function RgbString(C)
				return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
			end;
			local function ApplyState()
				local C = Color3.fromHSV(math.clamp(H, 0, 1), math.clamp(Sa, 0, 1), math.clamp(Va, 0, 1));
				Color                              = C;
				SwFill.BackgroundColor3            = C;
				SwFill.BackgroundTransparency      = 1 - A;
				AlphaArea.BackgroundColor3         = C;
				SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);
				local SOff = (Sa < 1) and 0 or -3;
				local VOff = ((1 - Va) < 1) and 0 or -3;
				SatValMarker.Position = UDim2.new(Sa, SOff, 1 - Va, VOff);
				local HOff = ((1 - H) < 1) and 0 or -2;
				HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);
				local AOff = ((1 - A) < 1) and 0 or -2;
				AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);
				if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
				if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;
				Library.Flags[Flag] = C;
				Callback(C, A);
			end;
			ApplyState();
			local FadeColorA = Color3.fromRGB(255, 0, 0);
			local FadeColorB = Color3.fromRGB(0, 0, 255);
			Library:Connection(RunService.Heartbeat, function(Dt)
				if Mode == "Rainbow" then
					H = (H + Dt * (Speed / 100)) % 1;
					ApplyState();
				elseif Mode == "Fading" then
					local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
					local C = FadeColorA:Lerp(FadeColorB, T);
					H, Sa, Va = Color3.toHSV(C);
					ApplyState();
				end;
			end);
			RgbInput.FocusLost:Connect(function()
				local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
				r, g, b = tonumber(r), tonumber(g), tonumber(b);
				if r and g and b and r <= 255 and g <= 255 and b <= 255 then
					H, Sa, Va = Color3.toHSV(Color3.fromRGB(r, g, b));
				end;
				ApplyState();
			end);
			HexInput.FocusLost:Connect(function()
				local Text = string.gsub(HexInput.Text, "^#", "");
				if #Text == 6 then
					local ok, C = pcall(Color3.fromHex, Text);
					if ok and C then H, Sa, Va = Color3.toHSV(C) end;
				end;
				ApplyState();
			end);
			local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
			local Open = false;
			local PickerIn  = TweenInfo.new(0.2,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
			local PickerOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
			local SlideOff  = 10;
			local function AnchorXY()
				local AbsP = Swatch.AbsolutePosition;
				local X, Y = AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
				return Library:ClampPopupXY(PickerHolder, X, Y);
			end;
			local function SetVisible(B)
				if B == Open then return end;
				Open = B;
				local X, Y = AnchorXY();
				if Open then
					PickerHolder.Visible           = true;
					PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
					PickerHolder.GroupTransparency = 1;
					PickerOuterStroke.Transparency = 1;
					PickerInnerStroke.Transparency = 1;
					Library:Tween(PickerHolder, PickerIn, {
						Position          = UDim2.fromOffset(X, Y);
						GroupTransparency = 0;
					}):Play();
					Library:Tween(PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
					Library:Tween(PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
				else
					Library:Tween(PickerHolder, PickerOut, {
						Position          = UDim2.fromOffset(X, Y - SlideOff);
						GroupTransparency = 1;
					}):Play();
					Library:Tween(PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
					Library:Tween(PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
					task.delay(PickerOut.Time, function()
						if not Open then PickerHolder.Visible = false end;
					end);
				end;
			end;
			local function HookDown(Inst, Setter)
				Library:Connection(Inst.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Setter(true);
					end;
				end);
			end;
			Library:Connection(Swatch.MouseButton1Click, function() SetVisible(not Open) end);
		Library:_RegisterCpSwatch(Swatch);
		Library:_EnhanceColorPickerPopup(PickerHolder, TabBar, function() SetVisible(false) end);
			HookDown(SatLayer,  function(B) DraggingSat   = B end);
			HookDown(ValLayer,  function(B) DraggingSat   = B end);
			HookDown(HueArea,   function(B) DraggingHue   = B end);
			HookDown(AlphaArea, function(B) DraggingAlpha = B end);
			Library:Connection(UserInputService.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					DraggingSat = false; DraggingHue = false; DraggingAlpha = false;
				end;
			end);
			Library:Connection(UserInputService.InputChanged, function(Input)
				local IsTouchInput = Input.UserInputType == Enum.UserInputType.Touch;
				if Input.UserInputType ~= Enum.UserInputType.MouseMovement and not IsTouchInput then return end;
				if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
				local M = UserInputService:GetMouseLocation();
				local Mx, My = M.X, M.Y - GuiInset;
				if IsTouchInput then Mx, My = Input.Position.X, Input.Position.Y end;
				if DraggingSat then
					local Ap, Sz = SatValArea.AbsolutePosition, SatValArea.AbsoluteSize;
					Sa = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
					Va = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
				elseif DraggingHue then
					local Ap, Sz = HueArea.AbsolutePosition, HueArea.AbsoluteSize;
					H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
				elseif DraggingAlpha then
					local Ap, Sz = AlphaArea.AbsolutePosition, AlphaArea.AbsoluteSize;
					A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
				end;
				ApplyState();
			end);
			Library:Connection(UserInputService.InputBegan, function(Input)
				if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
				if not Open then return end;
				local M = UserInputService:GetMouseLocation();
				local Mx, My = M.X, M.Y - GuiInset;
				if Input.UserInputType == Enum.UserInputType.Touch then Mx, My = Input.Position.X, Input.Position.Y end;
				local function Inside(F)
					local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
					return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
				end;
			end);
			Library.Options[Flag] = {
				Save = function()
					return { _t = "Color", v = Color3.fromHSV(H, Sa, Va):ToHex(), a = A };
				end;
				Load = function(Data)
					if typeof(Data) == "table" and typeof(Data.v) == "string" then
						local Ok, C2 = pcall(Color3.fromHex, Data.v);
						if not Ok then return end;
						H, Sa, Va = Color3.toHSV(C2);
						if Data.a ~= nil then A = math.clamp(tonumber(Data.a) or A, 0, 1) end;
						ApplyState();
					end;
				end;
			};
			return self;
		end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Row.Visible = S end);
		end;
		return Obj;
	end;
function SecRef:Slider(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Slider");
	local Min      = tonumber(Opts.Min) or 0;
	local Max      = tonumber(Opts.Max) or 100;
	local Step     = tonumber(Opts.Step) or 1;
	local Suffix   = tostring(Opts.Suffix or "");
	local Decimals = tonumber(Opts.Decimals) or 0;
	local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
	local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
	local Value    = math.clamp(tonumber(Opts.Default) or Min, Min, Max);
	local IncreaseNumber = tonumber(Opts.IncreaseNumber) or Step;
	Library.Flags[Flag] = Value;
	Library:Log("Added Slider Opts: "..Name,IncreaseNumber)
	local Container = Library:CreateInstance("Frame", {
Name                   = "Slider_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 26);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
	});
	local Lbl = Library:CreateInstance("TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, -60, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
	});
	local ValLbl = Library:CreateInstance("TextLabel", {
Name                   = "Value";
Parent                 = Container;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, -26, 0, 0);
Size                   = UDim2.new(0, 24, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
TextColor3             = Color3.fromHex("8C8F99");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Right;
TextYAlignment         = Enum.TextYAlignment.Center;
Text                   = "";
	});
	if ProggyCleanFont then
Lbl.FontFace    = ProggyCleanFont;
ValLbl.FontFace = ProggyCleanFont;
	end;
	local ButtonContainer = Library:CreateInstance("Frame", {
Name                   = "ButtonContainer";
Parent                 = Container;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, 0, 0, 0);
Size                   = UDim2.new(0, 24, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
	});
	Library:CreateInstance("UIListLayout", {
Parent        = ButtonContainer;
FillDirection = Enum.FillDirection.Horizontal;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
	});
	local MinusBtn = Library:CreateInstance("TextButton", {
Name                   = "MinusBtn";
Parent                 = ButtonContainer;
Size                   = UDim2.new(0, 10, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
LayoutOrder            = 1;
	});
	local MinusLabel = Library:CreateInstance("TextLabel", {
Name                   = "Label";
Parent                 = MinusBtn;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
Text                   = "−";
TextColor3             = Color3.fromHex("8C8F99");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then MinusLabel.FontFace = ProggyCleanFont end;
	local PlusBtn = Library:CreateInstance("TextButton", {
Name                   = "PlusBtn";
Parent                 = ButtonContainer;
Size                   = UDim2.new(0, 10, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
LayoutOrder            = 2;
	});
	local PlusLabel = Library:CreateInstance("TextLabel", {
Name                   = "Label";
Parent                 = PlusBtn;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
Text                   = "+";
TextColor3             = Color3.fromHex("8C8F99");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then PlusLabel.FontFace = ProggyCleanFont end;
	local Track = Library:CreateInstance("TextButton", {
Name             = "Track";
Parent           = Container;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, 0);
Size             = UDim2.new(1, 0, 0, 10);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
	});
	local TrackGray = Library:CreateInstance("Frame", {
Parent           = Track;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
	});
	local TrackInside = Library:CreateInstance("Frame", {
Parent           = TrackGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
	});
	local Fill = Library:CreateInstance("Frame", {
Name             = "Fill";
Parent           = TrackInside;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(0, 0, 1, -2);
BackgroundColor3 = Color3.fromHex("3972EC");
BorderSizePixel  = 0;
	});
	Library:RegisterAccent(Fill);
	local function FormatVal(V)
if Decimals > 0 then
	return string.format("%." .. Decimals .. "f", V) .. Suffix;
end;
return tostring(math.round(V)) .. Suffix;
	end;
	local VisualT = (Value - Min) / (Max - Min);
	local TargetT = VisualT;
	local function Render()
TargetT = (Value - Min) / (Max - Min);
ValLbl.Text = FormatVal(Value);
	end;
	Render();
	Fill.Size = UDim2.new(VisualT, -2, 1, -2);
	Library:Connection(RunService.Heartbeat, function(Dt)
if math.abs(TargetT - VisualT) < 0.001 then return end;
local Alpha = 1 - math.exp(-Dt * 14);
VisualT   = VisualT + (TargetT - VisualT) * Alpha;
Fill.Size = UDim2.new(VisualT, -2, 1, -2);
	end);
	local function SetVal(V, Fire)
V = math.clamp(math.floor((V - Min) / Step + 0.5) * Step + Min, Min, Max);
if V == Value then return end;
Value = V;
Library.Flags[Flag] = Value;
Render();
if Fire ~= false then Callback(Value) end;
	end;
	local Dragging = false;
	local function UpdateFromInput(Px)
local AbsX, AbsW = TrackInside.AbsolutePosition.X, TrackInside.AbsoluteSize.X;
if AbsW <= 0 then return end;
local T = math.clamp((Px - AbsX) / AbsW, 0, 1);
SetVal(Min + T * (Max - Min));
	end;
	Library:Connection(Track.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
	Dragging = true;
	UpdateFromInput(Input.Position.X);
end;
	end);
	Library:Connection(Track.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
	Dragging = false;
end;
	end);
	Library:Connection(UserInputService.InputChanged, function(Input)
if not Dragging then return end;
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
	UpdateFromInput(Input.Position.X);
end;
	end);
	MinusBtn.MouseButton1Click:Connect(function()
SetVal(Value - IncreaseNumber);
	end);
	PlusBtn.MouseButton1Click:Connect(function()
SetVal(Value + IncreaseNumber);
	end);
	if Opts.Tooltip then Library:Tooltip(Container, Opts.Tooltip) end;
	if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Container.Visible = S end);
	end;
	local Obj = { Container = Container, Track = Track, Fill = Fill };
	function Obj:Get() return Value end;
	function Obj:Set(V) SetVal(tonumber(V) or Value) end;
	Library.Options[Flag] = {
		Save = function() return Value end;
		Load = function(Data) SetVal(tonumber(Data) or Value) end;
	};
	return Obj;
end;
	function SecRef:Button(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Button");
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Row = Library:CreateInstance("Frame", {
			Name                   = "ButtonRow_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 21);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = Row;
			FillDirection = Enum.FillDirection.Horizontal;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 4);
		});
		local Buttons = {};
		local function Resize()
			local N = #Buttons;
			if N == 0 then return end;
			local Gap = 4 * (N - 1);
			for _, B in Buttons do
				B.Btn.Size = UDim2.new(1 / N, -(Gap / N), 1, 0);
			end;
		end;
		local function MakeBtn(BtnName, BtnCB, Confirm)
			local Btn = Library:CreateInstance("TextButton", {
				Name                   = "Btn_" .. BtnName;
				Parent                 = Row;
				BackgroundColor3       = Color3.fromHex("000000");
				BorderSizePixel        = 0;
				AutoButtonColor        = false;
				Text                   = "";
				LayoutOrder            = #Buttons + 1;
			});
			local BGray = Library:CreateInstance("Frame", {
				Parent           = Btn;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("393939");
				BorderSizePixel  = 0;
			});
			local BInside = Library:CreateInstance("Frame", {
				Parent           = BGray;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("FFFFFF");
				BorderSizePixel  = 0;
			});
			Library:CreateInstance("UIGradient", {
				Parent   = BInside;
				Rotation = 90;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
					NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
				});
			});
			local Lbl = Library:CreateInstance("TextLabel", {
				Name                   = "Label";
				Parent                 = BInside;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				Text                   = BtnName;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Center;
				TextYAlignment         = Enum.TextYAlignment.Center;
			});
			if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
			local ClickIn  = TweenInfo.new(0.1,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
			local ClickOut = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
			local function FlashBg()
				Library:Tween(BInside, ClickIn, { BackgroundColor3 = Color3.fromHex("DDDDDD") }):Play();
				task.delay(ClickIn.Time, function()
					Library:Tween(BInside, ClickOut, { BackgroundColor3 = Color3.fromHex("FFFFFF") }):Play();
				end);
			end;
			if Confirm then
				local Confirming = false;
				local Token      = 0;
				Btn.MouseButton1Click:Connect(function()
					if Confirming then
						Confirming = false;
						Token = Token + 1;
						Lbl.Text = BtnName;
						Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
						FlashBg();
						BtnCB();
					else
						Confirming = true;
						Token = Token + 1;
						local Mine = Token;
						Lbl.Text = "Confirm?";
						Library:Tween(Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
						task.delay(3, function()
							if Token == Mine then
								Confirming = false;
								Lbl.Text = BtnName;
								Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
							end;
						end);
					end;
				end);
			else
				Btn.MouseButton1Click:Connect(function()
					FlashBg();
					Library:Tween(Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
					task.delay(ClickIn.Time, function()
						Library:Tween(Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
					end);
					BtnCB();
				end);
			end;
			local BRef = { Btn = Btn, Label = Lbl };
			table.insert(Buttons, BRef);
			Resize();
			return BRef;
		end;
		MakeBtn(Name, Callback, Opts.Confirm);
		if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Row.Visible = S end);
		end;
		local Obj = { Container = Row };
		function Obj:Button(MoreOpts)
			MoreOpts = typeof(MoreOpts) == "table" and MoreOpts or {};
			local N = tostring(MoreOpts.Name or MoreOpts.Title or MoreOpts.Text or "Button");
			local CB = typeof(MoreOpts.Callback) == "function" and MoreOpts.Callback or function() end;
			MakeBtn(N, CB, MoreOpts.Confirm);
			return self;
		end;
		return Obj;
	end;
	function SecRef:Colorpicker(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Color");
		local Color    = typeof(Opts.Default) == "Color3" and Opts.Default or Color3.fromRGB(255, 255, 255);
		local Alpha    = tonumber(Opts.Alpha) or 1;
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		local H, S, V  = Color3.toHSV(Color);
		local A        = math.clamp(Alpha, 0, 1);
		local Row = Library:CreateInstance("Frame", {
			Name                   = "Colorpicker_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 18);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Row;
			AnchorPoint            = Vector2.new(0, 0.5);
			Position               = UDim2.new(0, 0, 0.5, 0);
			Size                   = UDim2.new(1, -32, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local Swatch = Library:CreateInstance("TextButton", {
			Name             = "Swatch";
			Parent           = Row;
			AnchorPoint      = Vector2.new(1, 0.5);
			Position         = UDim2.new(1, 0, 0.5, 0);
			Size             = UDim2.new(0, 27, 0, 15);
			AutoButtonColor  = false;
			Text             = "";
			BackgroundColor3 = Color3.fromHex("000105");
			BorderSizePixel  = 0;
		});
		local SwatchInline = Library:CreateInstance("Frame", {
			Name             = "Inline";
			Parent           = Swatch;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("252527");
			BorderSizePixel  = 0;
		});
		local SwatchHandle = Library:CreateInstance("Frame", {
			Name             = "Handle";
			Parent           = SwatchInline;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 0;
		});
		Library:CreateInstance("ImageLabel", {
			Name             = "Checkers";
			Parent           = SwatchHandle;
			Size             = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel  = 0;
			Image            = "rbxassetid://18274452449";
			ScaleType        = Enum.ScaleType.Tile;
			TileSize         = UDim2.new(0, 6, 0, 6);
			ZIndex           = 2;
		});
		local SwatchFill = Library:CreateInstance("Frame", {
			Name                   = "Fill";
			Parent                 = SwatchHandle;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundColor3       = Color;
			BackgroundTransparency = 1 - Alpha;
			BorderSizePixel        = 0;
			ZIndex                 = 3;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = SwatchFill;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
				NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
			});
		});
		local PickerHolder = Library:CreateInstance("CanvasGroup", {
			Name              = "Picker_" .. Name;
			Parent            = Host.Gui;
			Size              = UDim2.new(0, 218, 0, 248);
			BackgroundColor3  = Color3.fromHex("131313");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 50;
		});
		local PickerOuterStroke = Library:CreateInstance("UIStroke", {
			Parent          = PickerHolder;
			Color           = Color3.fromHex("000000");
			Thickness       = 1;
			Transparency    = 1;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		});
		local PickerInner = Library:CreateInstance("Frame", {
			Name                   = "InnerOutline";
			Parent                 = PickerHolder;
			Position               = UDim2.new(0, 1, 0, 1);
			Size                   = UDim2.new(1, -2, 1, -2);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			ZIndex                 = 51;
		});
		local PickerInnerStroke = Library:CreateInstance("UIStroke", {
			Parent          = PickerInner;
			Color           = Color3.fromHex("393939");
			Thickness       = 1;
			Transparency    = 1;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		});
		local PickerBody = Library:CreateInstance("Frame", {
			Name                   = "Body";
			Parent                 = PickerHolder;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			ZIndex                 = 52;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = PickerBody;
			PaddingTop    = UDim.new(0, 8);
			PaddingBottom = UDim.new(0, 8);
			PaddingLeft   = UDim.new(0, 8);
			PaddingRight  = UDim.new(0, 8);
		});
		local MainBg = Library:CreateInstance("Frame", {
			Name                   = "Main";
			Parent                 = PickerBody;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			ZIndex                 = 53;
		});
		local TabBar = Library:CreateInstance("Frame", {
			Name                   = "TabBar";
			Parent                 = MainBg;
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 20);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			ZIndex                 = 54;
		});
		local CpInactiveSeq = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
			NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
		});
		local CpActiveSeq = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
		});
		local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
		local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
		local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
		local ColorPage, AnimationsPanel;
		local CpTabToken = 0;
		local TabButtons = {};
		local function MakeCpTab(Name, Idx, Total)
			local Btn = Library:CreateInstance("TextButton", {
				Name                   = "Tab_" .. Name;
				Parent                 = TabBar;
				Size                   = UDim2.new(1 / Total, 0, 1, 0);
				Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				AutoButtonColor        = false;
				Text                   = "";
			});
			local Bg = Library:CreateInstance("Frame", {
				Name             = "Bg";
				Parent           = Btn;
				Size             = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.fromHex("FFFFFF");
				BorderSizePixel  = 0;
			});
			local BgGrad = Library:CreateInstance("UIGradient", {
				Parent   = Bg;
				Rotation = 90;
				Color    = CpInactiveSeq;
			});
			local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
				return Library:CreateInstance("Frame", {
					Parent                 = Bg;
					AnchorPoint            = Anchor;
					Position               = Pos;
					Size                   = Sz;
					BackgroundColor3       = Color3.fromHex(Color);
					BorderSizePixel        = 0;
					BackgroundTransparency = 1;
					ZIndex                 = ZIdx;
				});
			end;
			local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
			local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
			local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
			local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
			local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
			local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
			local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
			local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
			local TopGradient = Library:CreateInstance("Frame", {
				Parent                 = Bg;
				AnchorPoint            = Vector2.new(0, 0);
				Position               = UDim2.new(0, 0, 0, 0);
				Size                   = UDim2.new(1, 0, 0, 1);
				BackgroundColor3       = Color3.fromHex("FFFFFF");
				BorderSizePixel        = 0;
				BackgroundTransparency = 1;
				ZIndex                 = 5;
			});
			local Grad = Library:CreateInstance("UIGradient", { Parent = TopGradient; Rotation = 0 });
			Library:RegisterAccentGradient(Grad);
			local Lbl = Library:CreateInstance("TextLabel", {
				Name                   = "Label";
				Parent                 = Bg;
				Size                   = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				Text                   = Name;
				TextSize               = 12;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextXAlignment         = Enum.TextXAlignment.Center;
				TextYAlignment         = Enum.TextYAlignment.Center;
				ZIndex                 = 6;
			});
			if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
			local Entry = {
				Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
				TopBlack = TopBlack, TopGray = TopGray;
				BottomBlack = BottomBlack, BottomGray = BottomGray;
				LeftBlack = LeftBlack, LeftGray = LeftGray;
				RightBlack = RightBlack, RightGray = RightGray;
				GradT = 0; GradTarget = 0;
			};
			local function ApplyGrad()
				BgGrad.Color = NewColorSequence({
					NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
					NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
				});
			end;
			ApplyGrad();
			Library:Connection(RunService.Heartbeat, function(Dt)
				if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
					if Entry.GradT ~= Entry.GradTarget then
						Entry.GradT = Entry.GradTarget;
						ApplyGrad();
					end;
					return;
				end;
				Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
				ApplyGrad();
			end);
			table.insert(TabButtons, Entry);
			return Btn;
		end;
		local ColorTabBtn = MakeCpTab("Color", 1, 2);
		local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);
		local function SetCpTab(I)
			for i, T in TabButtons do
				if i == I then
					T.GradTarget = 1;
					Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
					for _, N in CpOutlineNames do
						Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
					end;
				else
					T.GradTarget = 0;
					Library:Tween(T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
					for _, N in CpOutlineNames do
						Library:Tween(T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
					end;
				end;
			end;
			if ColorPage and AnimationsPanel then
				CpTabToken = CpTabToken + 1;
				local Mine = CpTabToken;
				ColorPage.Visible       = true;
				AnimationsPanel.Visible = true;
				if I == 1 then
					Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
					Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
				else
					Library:Tween(ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
					Library:Tween(AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
				end;
				task.delay(CpAnimInfo.Time, function()
					if CpTabToken ~= Mine then return end;
					if I == 1 then AnimationsPanel.Visible = false end;
					if I == 2 then ColorPage.Visible = false end;
				end);
			end;
		end;
		SetCpTab(1);
		ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
		AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);
		ColorPage = Library:CreateInstance("CanvasGroup", {
			Name                   = "ColorPage";
			Parent                 = MainBg;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			GroupTransparency      = 0;
			ZIndex                 = 54;
		});
		AnimationsPanel = Library:CreateInstance("CanvasGroup", {
			Name              = "AnimationsPanel";
			Parent            = MainBg;
			Position          = UDim2.new(0, 0, 0, 28);
			Size              = UDim2.new(1, 0, 1, -28);
			BackgroundColor3  = Color3.fromHex("131313");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 55;
		});
		local Mode  = "Solid";
		local Speed = 50;
		local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
		local function AnimLbl(Text, Y)
			local L = Library:CreateInstance("TextLabel", {
				Parent                 = AnimationsPanel;
				Position               = UDim2.new(0, 0, 0, Y);
				Size                   = UDim2.new(1, 0, 0, 12);
				BackgroundTransparency = 1;
				Text                   = Text;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Left;
			});
			FontIt(L);
			return L;
		end;
		AnimLbl("Mode", 0);
		local ModeBox = Library:CreateInstance("TextButton", {
			Parent           = AnimationsPanel;
			Position         = UDim2.new(0, 0, 0, 14);
			Size             = UDim2.new(1, 0, 0, 21);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
		});
		Library:CreateInstance("Frame", {
			Parent           = ModeBox;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local ModeInside = Library:CreateInstance("Frame", {
			Parent           = ModeBox:FindFirstChildOfClass("Frame");
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = ModeInside;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
				NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
			});
		});
		local ModeVal = Library:CreateInstance("TextLabel", {
			Parent                 = ModeInside;
			Position               = UDim2.new(0, 4, 0, 0);
			Size                   = UDim2.new(1, -14, 1, 0);
			BackgroundTransparency = 1;
			Text                   = Mode;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		}); FontIt(ModeVal);
		local ModeArrow = Library:CreateInstance("Frame", {
			Parent                 = ModeInside;
			AnchorPoint            = Vector2.new(1, 0.5);
			Position               = UDim2.new(1, -4, 0.5, 0);
			Size                   = UDim2.fromOffset(7, 7);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:CreateInstance("Frame", {
			Parent           = ModeArrow;
			AnchorPoint      = Vector2.new(0.5, 0.5);
			Position         = UDim2.new(0.5, 0, 0.5, 0);
			Size             = UDim2.fromOffset(7, 1);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local ModeArrowV = Library:CreateInstance("Frame", {
			Parent           = ModeArrow;
			AnchorPoint      = Vector2.new(0.5, 0.5);
			Position         = UDim2.new(0.5, 0, 0.5, 0);
			Size             = UDim2.fromOffset(1, 7);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;
		local ModePopup = Library:CreateInstance("CanvasGroup", {
			Parent            = AnimationsPanel;
			Position          = UDim2.new(0, 0, 0, 36);
			Size              = UDim2.new(1, 0, 0, 44);
			BackgroundColor3  = Color3.fromHex("000000");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 60;
		});
		local ModePopupGray = Library:CreateInstance("Frame", {
			Parent           = ModePopup;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
			ZIndex           = 60;
		});
		local ModePopupInside = Library:CreateInstance("Frame", {
			Parent           = ModePopupGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("131313");
			BorderSizePixel  = 0;
			ZIndex           = 61;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = ModePopupInside;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 0);
		});
		local ModeOptionBtns = {};
		local function RefreshModeOpts()
			for N, B in ModeOptionBtns do
				B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
			end;
		end;
		Library:OnAccent(function() RefreshModeOpts() end);
		local ModePopupOpen = false;
		local ModePopupToken = 0;
		local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		local ModePopupBaseY = 36;
		local ModePopupSlide = 6;
		local function CloseModePopup()
			if not ModePopupOpen then return end;
			ModePopupOpen = false;
			ModePopupToken = ModePopupToken + 1;
			local Mine = ModePopupToken;
			SetModeArrow(true);
			Library:Tween(ModePopup, ModePopupInfo, {
				GroupTransparency = 1;
				Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
			}):Play();
			task.delay(ModePopupInfo.Time, function()
				if ModePopupToken == Mine then ModePopup.Visible = false end;
			end);
		end;
		local function OpenModePopup()
			if ModePopupOpen then return end;
			ModePopupOpen = true;
			ModePopupToken = ModePopupToken + 1;
			SetModeArrow(false);
			ModePopup.GroupTransparency = 1;
			ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
			ModePopup.Visible           = true;
			Library:Tween(ModePopup, ModePopupInfo, {
				GroupTransparency = 0;
				Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
			}):Play();
		end;
		local function AddModeOpt(Name, Idx)
			local Btn = Library:CreateInstance("TextButton", {
				Parent                 = ModePopupInside;
				Size                   = UDim2.new(1, 0, 0, 14);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				AutoButtonColor        = false;
				Text                   = Name;
				TextColor3             = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Left;
				LayoutOrder            = Idx;
				ZIndex                 = 62;
			});
			Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
			FontIt(Btn);
			ModeOptionBtns[Name] = Btn;
			Btn.MouseButton1Click:Connect(function()
				Mode = Name;
				ModeVal.Text = Mode;
				RefreshModeOpts();
				CloseModePopup();
			end);
		end;
		AddModeOpt("Solid",   1);
		AddModeOpt("Rainbow", 2);
		AddModeOpt("Fading",  3);
		ModeBox.MouseButton1Click:Connect(function()
			if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
		end);
		AnimLbl("Speed", 42);
		local SpeedVal = Library:CreateInstance("TextLabel", {
			Parent                 = AnimationsPanel;
			AnchorPoint            = Vector2.new(1, 0);
			Position               = UDim2.new(1, 0, 0, 42);
			Size                   = UDim2.new(0, 40, 0, 12);
			BackgroundTransparency = 1;
			Text                   = "50%";
			TextColor3             = Color3.fromHex("8C8F99");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Right;
		}); FontIt(SpeedVal);
		local SpTrack = Library:CreateInstance("TextButton", {
			Parent           = AnimationsPanel;
			Position         = UDim2.new(0, 0, 0, 58);
			Size             = UDim2.new(1, 0, 0, 10);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
		});
		local SpGray = Library:CreateInstance("Frame", {
			Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
			Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
		});
		local SpInside = Library:CreateInstance("Frame", {
			Parent = SpGray; Position = UDim2.new(0, 1, 0, 1);
			Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
		});
		local SpFill = Library:CreateInstance("Frame", {
			Parent           = SpInside;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(0.5, -2, 1, -2);
			BackgroundColor3 = Library.Accent;
			BorderSizePixel  = 0;
		});
		Library:RegisterAccent(SpFill);
		local SpDragging = false;
		local SpVisualT = 0.5;
		local SpTargetT = 0.5;
		Library:Connection(RunService.Heartbeat, function(Dt)
			if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
			local Alpha = 1 - math.exp(-Dt * 14);
			SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
			SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
		end);
		local function SpUpdate(Px)
			local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
			if Aw <= 0 then return end;
			local T = math.clamp((Px - Ax) / Aw, 0, 1);
			Speed = math.floor(T * 100 + 0.5);
			SpTargetT = T;
			SpeedVal.Text = Speed .. "%";
		end;
		Library:Connection(SpTrack.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				SpDragging = true; SpUpdate(Input.Position.X);
			end;
		end);
		Library:Connection(SpTrack.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				SpDragging = false;
			end;
		end);
		Library:Connection(UserInputService.InputChanged, function(Input)
			if not SpDragging then return end;
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				SpUpdate(Input.Position.X);
			end;
		end);
		local SatValArea = Library:CreateInstance("Frame", {
			Name             = "SatVal";
			Parent           = ColorPage;
			Position         = UDim2.new(0, 0, 0, 24);
			Size             = UDim2.new(1, -30, 1, -66);
			BackgroundColor3 = Color3.fromRGB(255, 0, 0);
			BorderSizePixel  = 0;
			ZIndex           = 55;
		});
		Library:CreateInstance("UIStroke", {
			Parent          = SatValArea;
			Color           = Color3.fromHex("000105");
			Thickness       = 1;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		});
		local SatLayer = Library:CreateInstance("TextButton", {
			Name             = "Sat";
			Parent           = SatValArea;
			Size             = UDim2.new(1, 0, 1, 0);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
			ZIndex           = 56;
		});
		Library:CreateInstance("UIGradient", {
			Parent       = SatLayer;
			Rotation     = 270;
			Transparency = NewNumberSequence({
				NewNumberSequenceKeypoint(0, 0);
				NewNumberSequenceKeypoint(1, 1);
			});
			Color = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
				NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
			});
		});
		local ValLayer = Library:CreateInstance("TextButton", {
			Name             = "Val";
			Parent           = SatValArea;
			Size             = UDim2.new(1, 0, 1, 0);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
			ZIndex           = 57;
		});
		Library:CreateInstance("UIGradient", {
			Parent       = ValLayer;
			Transparency = NewNumberSequence({
				NewNumberSequenceKeypoint(0, 0);
				NewNumberSequenceKeypoint(1, 1);
			});
		});
		local SatValMarker = Library:CreateInstance("Frame", {
			Name             = "Marker";
			Parent           = SatValArea;
			Size             = UDim2.new(0, 2, 0, 2);
			BorderSizePixel  = 1;
			BorderColor3     = Color3.fromRGB(0, 0, 0);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ZIndex           = 58;
		});
		local HueArea = Library:CreateInstance("TextButton", {
			Name             = "Hue";
			Parent           = ColorPage;
			AnchorPoint      = Vector2.new(1, 0);
			Position         = UDim2.new(1, -14, 0, 24);
			Size             = UDim2.new(0, 12, 1, -66);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
			ZIndex           = 55;
		});
		Library:CreateInstance("UIStroke", {
			Parent          = HueArea;
			Color           = Color3.fromHex("000105");
			Thickness       = 1;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = HueArea;
			Rotation = 270;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
				NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
				NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
				NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
				NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
				NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
				NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
			});
		});
		local HueMarker = Library:CreateInstance("Frame", {
			Name             = "Marker";
			Parent           = HueArea;
			Size             = UDim2.new(1, 0, 0, 2);
			BorderSizePixel  = 1;
			BorderColor3     = Color3.fromRGB(0, 0, 0);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ZIndex           = 56;
		});
		local AlphaArea = Library:CreateInstance("TextButton", {
			Name             = "Alpha";
			Parent           = ColorPage;
			AnchorPoint      = Vector2.new(1, 0);
			Position         = UDim2.new(1, 0, 0, 24);
			Size             = UDim2.new(0, 12, 1, -66);
			BackgroundColor3 = Color;
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
			ZIndex           = 55;
		});
		Library:CreateInstance("UIStroke", {
			Parent          = AlphaArea;
			Color           = Color3.fromHex("000105");
			Thickness       = 1;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		});
		local AlphaCheckers = Library:CreateInstance("ImageLabel", {
			Name                   = "Checkers";
			Parent                 = AlphaArea;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Image                  = "rbxassetid://18274452449";
			ScaleType              = Enum.ScaleType.Tile;
			TileSize               = UDim2.new(0, 6, 0, 6);
			ZIndex                 = 56;
		});
		Library:CreateInstance("UIGradient", {
			Parent       = AlphaCheckers;
			Rotation     = 270;
			Transparency = NewNumberSequence({
				NewNumberSequenceKeypoint(0, 0);
				NewNumberSequenceKeypoint(1, 1);
			});
		});
		local AlphaMarker = Library:CreateInstance("Frame", {
			Name             = "Marker";
			Parent           = AlphaArea;
			Size             = UDim2.new(1, 0, 0, 2);
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 1;
			BorderColor3     = Color3.fromRGB(0, 0, 0);
			ZIndex           = 57;
		});
		local function MakeInput(YOffFromBottom)
			local Box = Library:CreateInstance("Frame", {
				Parent           = ColorPage;
				AnchorPoint      = Vector2.new(0, 1);
				Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
				Size             = UDim2.new(1, 0, 0, 18);
				BackgroundColor3 = Color3.fromHex("000000");
				BorderSizePixel  = 0;
				ZIndex           = 55;
			});
			local Gray = Library:CreateInstance("Frame", {
				Parent           = Box;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("393939");
				BorderSizePixel  = 0;
			});
			local Inside = Library:CreateInstance("Frame", {
				Parent           = Gray;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.fromHex("FFFFFF");
				BorderSizePixel  = 0;
			});
			Library:CreateInstance("UIGradient", {
				Parent   = Inside;
				Rotation = 90;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
					NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
				});
			});
			local Input = Library:CreateInstance("TextBox", {
				Parent                 = Inside;
				Size                   = UDim2.new(1, -6, 1, 0);
				Position               = UDim2.new(0, 3, 0, 0);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				ClearTextOnFocus       = false;
				Text                   = "";
				PlaceholderColor3      = Color3.fromHex("5E626B");
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Center;
				TextYAlignment         = Enum.TextYAlignment.Center;
				ClipsDescendants       = true;
			});
			if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
			return Input;
		end;
		local HexInput = MakeInput(0);
		HexInput.PlaceholderText = "Hex";
		local RgbInput = MakeInput(20);
		RgbInput.PlaceholderText = "R, G, B";
		local function RgbString(C)
			return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
		end;
		local function ApplyState()
			local C = Color3.fromHSV(H, S, V);
			Color                              = C;
			SwatchFill.BackgroundColor3        = C;
			SwatchFill.BackgroundTransparency  = 1 - A;
			AlphaArea.BackgroundColor3         = C;
			SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);
			local SOff = (S < 1) and 0 or -3;
			local VOff = ((1 - V) < 1) and 0 or -3;
			SatValMarker.Position = UDim2.new(S, SOff, 1 - V, VOff);
			local HOff = ((1 - H) < 1) and 0 or -2;
			HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);
			local AOff = ((1 - A) < 1) and 0 or -2;
			AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);
			if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
			if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;
			Library.Flags[Flag] = C;
			Callback(C, A);
		end;
		ApplyState();
		local FadeColorA = Color3.fromRGB(255, 0, 0);
		local FadeColorB = Color3.fromRGB(0, 0, 255);
		Library:Connection(RunService.Heartbeat, function(Dt)
			if Mode == "Rainbow" then
				H = (H + Dt * (Speed / 100)) % 1;
				ApplyState();
			elseif Mode == "Fading" then
				local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
				local C = FadeColorA:Lerp(FadeColorB, T);
				H, S, V = Color3.toHSV(C);
				ApplyState();
			end;
		end);
		RgbInput.FocusLost:Connect(function()
			local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
			r, g, b = tonumber(r), tonumber(g), tonumber(b);
			if r and g and b and r <= 255 and g <= 255 and b <= 255 then
				H, S, V = Color3.toHSV(Color3.fromRGB(r, g, b));
			end;
			ApplyState();
		end);
		HexInput.FocusLost:Connect(function()
			local Text = string.gsub(HexInput.Text, "^#", "");
			if #Text == 6 then
				local ok, C = pcall(Color3.fromHex, Text);
				if ok and C then H, S, V = Color3.toHSV(C) end;
			end;
			ApplyState();
		end);
		local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
		local Open = false;
		local PickerIn   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local PickerOut  = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
		local SlideOff   = 10;
		local function AnchorXY()
			local AbsP = Swatch.AbsolutePosition;
			local X, Y = AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
			return Library:ClampPopupXY(PickerHolder, X, Y);
		end;
		local function SetVisible(B)
			if B == Open then return end;
			Open = B;
			local X, Y = AnchorXY();
			if Open then
				PickerHolder.Visible           = true;
				PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
				PickerHolder.GroupTransparency = 1;
				PickerOuterStroke.Transparency = 1;
				PickerInnerStroke.Transparency = 1;
				Library:Tween(PickerHolder, PickerIn, {
					Position          = UDim2.fromOffset(X, Y);
					GroupTransparency = 0;
				}):Play();
				Library:Tween(PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
				Library:Tween(PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
			else
				Library:Tween(PickerHolder, PickerOut, {
					Position          = UDim2.fromOffset(X, Y - SlideOff);
					GroupTransparency = 1;
				}):Play();
				Library:Tween(PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
				Library:Tween(PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
				task.delay(PickerOut.Time, function()
					if not Open then PickerHolder.Visible = false end;
				end);
			end;
		end;
		local function HookDown(Inst, Setter)
			Library:Connection(Inst.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Setter(true);
				end;
			end);
		end;
		Library:Connection(Swatch.MouseButton1Click, function() SetVisible(not Open) end);
		Library:_RegisterCpSwatch(Swatch);
		Library:_EnhanceColorPickerPopup(PickerHolder, TabBar, function() SetVisible(false) end);
		HookDown(SatLayer,  function(B) DraggingSat   = B end);
		HookDown(ValLayer,  function(B) DraggingSat   = B end);
		HookDown(HueArea,   function(B) DraggingHue   = B end);
		HookDown(AlphaArea, function(B) DraggingAlpha = B end);
		Library:Connection(UserInputService.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				DraggingSat   = false;
				DraggingHue   = false;
				DraggingAlpha = false;
			end;
		end);
		Library:Connection(UserInputService.InputChanged, function(Input)
			local IsTouchInput = Input.UserInputType == Enum.UserInputType.Touch;
			if Input.UserInputType ~= Enum.UserInputType.MouseMovement and not IsTouchInput then return end;
			if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
			local M = UserInputService:GetMouseLocation();
			local Mx, My = M.X, M.Y - GuiInset;
			if IsTouchInput then Mx, My = Input.Position.X, Input.Position.Y end;
			if DraggingSat then
				local Ap = SatValArea.AbsolutePosition;
				local Sz = SatValArea.AbsoluteSize;
				S = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
				V = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
			elseif DraggingHue then
				local Ap = HueArea.AbsolutePosition;
				local Sz = HueArea.AbsoluteSize;
				H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
			elseif DraggingAlpha then
				local Ap = AlphaArea.AbsolutePosition;
				local Sz = AlphaArea.AbsoluteSize;
				A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
			end;
			ApplyState();
		end);
		Library:Connection(UserInputService.InputBegan, function(Input)
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
			if not Open then return end;
			local M = UserInputService:GetMouseLocation();
			local Mx, My = M.X, M.Y - GuiInset;
			if Input.UserInputType == Enum.UserInputType.Touch then Mx, My = Input.Position.X, Input.Position.Y end;
			local function Inside(F)
				local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
				return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
			end;
		end);
		if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Row.Visible = S end);
		end;
		local CpObj = { Container = Row, Swatch = Swatch, Picker = PickerHolder };
		function CpObj:Get() return Color, A end;
		function CpObj:Set(NewColor, NewAlpha)
			if typeof(NewColor) == "Color3" then H, S, V = Color3.toHSV(NewColor) end;
			if NewAlpha then A = math.clamp(NewAlpha, 0, 1) end;
			ApplyState();
		end;
		Library.Options[Flag] = {
			Save = function()
				local C2, A2 = CpObj:Get();
				return { _t = "Color", v = C2:ToHex(), a = A2 };
			end;
			Load = function(Data)
				if typeof(Data) == "table" and typeof(Data.v) == "string" then
					local Ok, C2 = pcall(Color3.fromHex, Data.v);
					if Ok then CpObj:Set(C2, tonumber(Data.a)) end;
				end;
			end;
		};
		return CpObj;
	end;
	function SecRef:Dropdown(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Dropdown");
		local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		local Multi    = Opts.Multi == true;
		Library:Log("Added Dropdown Opts: "..Name,Multi)
		local Value;
		if Multi then
			Value = {};
			if typeof(Opts.Default) == "table" then
				for _, V in Opts.Default do Value[tostring(V)] = true end;
			elseif Opts.Default ~= nil then
				Value[tostring(Opts.Default)] = true;
			end;
		else
			Value = tostring(Opts.Default or Options[1] or "");
		end;
		Library.Flags[Flag] = Value;
		local Container = Library:CreateInstance("Frame", {
			Name                   = "Dropdown_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 36);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Container;
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 12);
			BackgroundTransparency = 1;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local Box = Library:CreateInstance("TextButton", {
			Name             = "Box";
			Parent           = Container;
			AnchorPoint      = Vector2.new(0, 1);
			Position         = UDim2.new(0, 0, 1, 0);
			Size             = UDim2.new(1, 0, 0, 21);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
			AutoButtonColor  = false;
			Text             = "";
		});
		local BoxGray = Library:CreateInstance("Frame", {
			Parent           = Box;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local BoxInside = Library:CreateInstance("Frame", {
			Parent           = BoxGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = BoxInside;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
				NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
			});
		});
		local ValLbl = Library:CreateInstance("TextLabel", {
			Name                   = "Value";
			Parent                 = BoxInside;
			Position               = UDim2.new(0, 4, 0, 0);
			Size                   = UDim2.new(1, -14, 1, 0);
			BackgroundTransparency = 1;
			Text                   = "";
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			TextTruncate           = Enum.TextTruncate.AtEnd;
			ClipsDescendants       = true;
		});
		local Arrow = Library:CreateInstance("Frame", {
			Name                   = "Arrow";
			Parent                 = BoxInside;
			AnchorPoint            = Vector2.new(1, 0.5);
			Position               = UDim2.new(1, -4, 0.5, 0);
			Size                   = UDim2.fromOffset(7, 7);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:CreateInstance("Frame", {
			Name             = "Horiz";
			Parent           = Arrow;
			AnchorPoint      = Vector2.new(0.5, 0.5);
			Position         = UDim2.new(0.5, 0, 0.5, 0);
			Size             = UDim2.fromOffset(7, 1);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local ArrowV = Library:CreateInstance("Frame", {
			Name             = "Vert";
			Parent           = Arrow;
			AnchorPoint      = Vector2.new(0.5, 0.5);
			Position         = UDim2.new(0.5, 0, 0.5, 0);
			Size             = UDim2.fromOffset(1, 7);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local function SetArrow(Plus) ArrowV.Visible = Plus end;
		if ProggyCleanFont then
			ValLbl.FontFace = ProggyCleanFont;
		end;
		local Popup = Library:CreateInstance("CanvasGroup", {
			Name              = "DropdownPopup";
			Parent            = Host.Gui;
			Size              = UDim2.new(0, 100, 0, 0);
			AutomaticSize     = Enum.AutomaticSize.Y;
			BackgroundColor3  = Color3.fromHex("000000");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 50;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = Popup;
			PaddingLeft   = UDim.new(0, 1);
			PaddingRight  = UDim.new(0, 1);
			PaddingTop    = UDim.new(0, 1);
			PaddingBottom = UDim.new(0, 1);
		});
		local PopupGray = Library:CreateInstance("Frame", {
			Parent           = Popup;
			Position         = UDim2.new(0, 0, 0, 0);
			Size             = UDim2.new(1, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.Y;
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
			ZIndex           = 50;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = PopupGray;
			PaddingLeft   = UDim.new(0, 1);
			PaddingRight  = UDim.new(0, 1);
			PaddingTop    = UDim.new(0, 1);
			PaddingBottom = UDim.new(0, 1);
		});
		local PopupInside = Library:CreateInstance("Frame", {
			Parent                 = PopupGray;
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundColor3       = Color3.fromHex("131313");
			BorderSizePixel        = 0;
			ZIndex                 = 50;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = PopupInside;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 0);
		});
		local Open = false;
		local OptionButtons = {};
		local ClosePopup;
		local function IsSelected(Opt)
			Opt = tostring(Opt);
			if Multi then return Value[Opt] == true end;
			return Opt == Value;
		end;
		local function DisplayText()
			if not Multi then return tostring(Value) end;
			local Sel = {};
			for _, Opt in Options do
				if Value[tostring(Opt)] then table.insert(Sel, tostring(Opt)) end;
			end;
			return (#Sel > 0) and table.concat(Sel, ", ") or "None";
		end;
		local OptColorInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local function RefreshColors()
			for _, B in OptionButtons do
				local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
				Library:Tween(B, OptColorInfo, { TextColor3 = Target }):Play();
			end;
		end;
		local function SetVal(V, Fire)
			V = tostring(V);
			if Multi then
				Value[V] = (not Value[V]) or nil;
			else
				if V == Value then return end;
				Value = V;
			end;
			Library.Flags[Flag] = Value;
			ValLbl.Text = DisplayText();
			RefreshColors();
			if Fire ~= false then Callback(Value) end;
		end;
		local function BuildOptions()
			for _, C in PopupInside:GetChildren() do
				if C:IsA("TextButton") then C:Destroy() end;
			end;
			table.clear(OptionButtons);
			for I, Opt in Options do
				local Btn = Library:CreateInstance("TextButton", {
					Name                   = "Option_" .. tostring(Opt);
					Parent                 = PopupInside;
					Size                   = UDim2.new(1, 0, 0, 14);
					BackgroundColor3       = Color3.fromHex("131313");
					BorderSizePixel        = 0;
					AutoButtonColor        = false;
					Text                   = tostring(Opt);
					TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					TextYAlignment         = Enum.TextYAlignment.Center;
					LayoutOrder            = I;
					ZIndex                 = 51;
				});
				Library:CreateInstance("UIPadding", {
					Parent      = Btn;
					PaddingLeft = UDim.new(0, 5);
				});
				if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
				Btn.MouseButton1Click:Connect(function()
					SetVal(Btn.Text);
					if not Multi and ClosePopup then ClosePopup() end;
				end);
				table.insert(OptionButtons, Btn);
			end;
		end;
		BuildOptions();
		ValLbl.Text = DisplayText();
		Library:OnAccent(RefreshColors);
		local PopupIn  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local PopupOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
		local SlideOff = 10;
		local PopupGap = 60;
		local function AnchorXY()
			local AbsPos  = Box.AbsolutePosition;
			local AbsSize = Box.AbsoluteSize;
			Popup.Size = UDim2.new(0, AbsSize.X, 0, 0);
			local X, Y = AbsPos.X, AbsPos.Y + AbsSize.Y + PopupGap;
			return Library:ClampPopupXY(Popup, X, Y);
		end;
		ClosePopup = function()
			if not Open then return end;
			Open = false;
			local X, Y = AnchorXY();
			Library:Tween(Popup, PopupOut, {
				Position          = UDim2.fromOffset(X, Y - SlideOff);
				GroupTransparency = 1;
			}):Play();
			task.delay(PopupOut.Time, function()
				if not Open then Popup.Visible = false end;
			end);
			SetArrow(true);
		end;
		Box.MouseButton1Click:Connect(function()
			Open = not Open;
			if IsMobilePlatform then Library.CanDrag = not Open end;
			local X, Y = AnchorXY();
			if Open then
				Popup.Visible           = true;
				Popup.Position          = UDim2.fromOffset(X, Y - SlideOff);
				Popup.GroupTransparency = 1;
				Library:Tween(Popup, PopupIn, {
					Position          = UDim2.fromOffset(X, Y);
					GroupTransparency = 0;
				}):Play();
				SetArrow(false);
			else
				Library:Tween(Popup, PopupOut, {
					Position          = UDim2.fromOffset(X, Y - SlideOff);
					GroupTransparency = 1;
				}):Play();
				task.delay(PopupOut.Time, function()
					if not Open then Popup.Visible = false end;
				end);
				SetArrow(true);
			end;
		end);
		Library:Connection(UserInputService.InputBegan, function(Input)
			if not Open then return end;
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
			local Mx, My = Input.Position.X, Input.Position.Y;
			local function InAbs(Inst)
				local P, S = Inst.AbsolutePosition, Inst.AbsoluteSize;
				return Mx >= P.X and Mx <= P.X + S.X and My >= P.Y and My <= P.Y + S.Y;
			end;
			if InAbs(Box) or InAbs(Popup) then return end;
			Open = false;
			if IsMobilePlatform then Library.CanDrag = true end;
			local X, Y = AnchorXY();
			Library:Tween(Popup, PopupOut, {
				Position          = UDim2.fromOffset(X, Y - SlideOff);
				GroupTransparency = 1;
			}):Play();
			task.delay(PopupOut.Time, function()
				if not Open then Popup.Visible = false end;
			end);
			SetArrow(true);
		end);
		if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Container.Visible = S end);
		end;
		local Obj = { Container = Container, Box = Box, Popup = Popup };
		function Obj:Get() return Value end;
		function Obj:Set(V)
			if Multi then
				Value = {};
				if typeof(V) == "table" then
					for _, Item in V do Value[tostring(Item)] = true end;
				elseif V ~= nil then
					Value[tostring(V)] = true;
				end;
				Library.Flags[Flag] = Value;
				ValLbl.Text = DisplayText();
				RefreshColors();
				Callback(Value);
			else
				SetVal(V);
			end;
		end;
		function Obj:SetOptions(Opts2)
			Options = typeof(Opts2) == "table" and Opts2 or {};
			BuildOptions();
			ValLbl.Text = DisplayText();
		end;
		Library.Options[Flag] = {
			Save = function() return Value end;
			Load = function(Data)
				if Multi then
					local Arr = {};
					if typeof(Data) == "table" then
						for K2, On in Data do
							if On then table.insert(Arr, tostring(K2)) end;
						end;
					end;
					Obj:Set(Arr);
				elseif Data ~= nil then
					SetVal(tostring(Data));
				end;
			end;
		};
		return Obj;
	end;
	function SecRef:Textbox(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name        = tostring(Opts.Name or Opts.Title or Opts.Text or "Textbox");
		local Default     = tostring(Opts.Default or "");
		local Placeholder = tostring(Opts.Placeholder or "...");
		local Numeric     = Opts.Numeric == true;
		local Callback    = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Flag        = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		Library.Flags[Flag] = Default;
		local Container = Library:CreateInstance("Frame", {
			Name                   = "Textbox_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 36);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Container;
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 12);
			BackgroundTransparency = 1;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local Box = Library:CreateInstance("Frame", {
			Name             = "Box";
			Parent           = Container;
			AnchorPoint      = Vector2.new(0, 1);
			Position         = UDim2.new(0, 0, 1, 0);
			Size             = UDim2.new(1, 0, 0, 21);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
		});
		local BoxGray = Library:CreateInstance("Frame", {
			Parent           = Box;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local BoxInside = Library:CreateInstance("Frame", {
			Parent           = BoxGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = BoxInside;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
				NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
			});
		});
		local Input = Library:CreateInstance("TextBox", {
			Name                   = "Input";
			Parent                 = BoxInside;
			Position               = UDim2.new(0, 4, 0, 0);
			Size                   = UDim2.new(1, -8, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			ClearTextOnFocus       = false;
			Text                   = Default;
			PlaceholderText        = Placeholder;
			PlaceholderColor3      = Color3.fromHex("5E626B");
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			ClipsDescendants       = true;
		});
		if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
		local function Commit(V, Fire)
			V = tostring(V);
			if Numeric then
				local Num = tonumber(V);
				V = Num and tostring(Num) or "";
			end;
			Input.Text = V;
			Library.Flags[Flag] = V;
			if Fire ~= false then Callback(V) end;
		end;
		Input.FocusLost:Connect(function(Enter)
			Commit(Input.Text);
		end);
		if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Container.Visible = S end);
		end;
		local Obj = { Container = Container, Box = Box, Input = Input };
		function Obj:Get() return Input.Text end;
		function Obj:Set(V) Commit(V, false) end;
		Library.Options[Flag] = {
			Save = function() return Input.Text end;
			Load = function(Data) Commit(tostring(Data)) end;
		};
		return Obj;
	end;
	function SecRef:Keybind(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Keybind");
		local Mode     = string.lower(tostring(Opts.Mode or "Toggle"));
		if Mode ~= "toggle" and Mode ~= "hold" and Mode ~= "always" then Mode = "toggle" end;
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local OnChanged = typeof(Opts.OnChanged) == "function" and Opts.OnChanged or nil;
		local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		local Key      = Opts.Default;
		local State    = Mode == "always";
		local MenuVisible = Opts.MenuVisible ~= false and Opts.NoUI ~= true;
		Library.Flags[Flag] = State;
		local function KeyDisplay(K)
			if K == nil then return "None" end;
			if typeof(K) == "EnumItem" then
				return Library.KeyNames[K] or K.Name;
			end;
			return tostring(K);
		end;
		local function SetState(V, Fire)
			V = V == true;
			if V == State then return end;
			State = V;
			Library.Flags[Flag] = State;
			if Fire ~= false then Callback(State) end;
			Library:NotifyKeybind();
		end;
		local Row = Library:CreateInstance("TextButton", {
			Name                   = "Keybind_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, 16);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = "";
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Row;
			AnchorPoint            = Vector2.new(0, 0.5);
			Position               = UDim2.new(0, 0, 0.5, 0);
			Size                   = UDim2.new(1, -62, 1, 0);
			BackgroundTransparency = 1;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local Box = Library:CreateInstance("Frame", {
			Name             = "KeyBox";
			Parent           = Row;
			AnchorPoint      = Vector2.new(1, 0.5);
			Position         = UDim2.new(1, 0, 0.5, 0);
			Size             = UDim2.fromOffset(56, 16);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
		});
		local BoxGray = Library:CreateInstance("Frame", {
			Parent           = Box;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local BoxInside = Library:CreateInstance("Frame", {
			Parent           = BoxGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		Library:CreateInstance("UIGradient", {
			Parent   = BoxInside;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
				NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
			});
		});
		local Display = Library:CreateInstance("TextLabel", {
			Name                   = "Display";
			Parent                 = BoxInside;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			Text                   = KeyDisplay(Key);
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Center;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Display.FontFace = ProggyCleanFont end;
		local Listening = false;
		local ListenConn;
		local function Refresh()
			if Listening then
				Display.Text       = "...";
				Display.TextColor3 = Library.Accent;
			else
				Display.Text       = KeyDisplay(Key);
				Display.TextColor3 = Color3.fromHex("FFFFFF");
			end;
		end;
		local function CancelListen()
			if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
			Listening = false;
			Refresh();
		end;
		local function StartListen()
			if Listening then CancelListen(); return end;
			Listening = true;
			Refresh();
			task.defer(function()
				if not Listening then return end;
				ListenConn = UserInputService.InputBegan:Connect(function(Input)
					local T = Input.UserInputType;
					if T == Enum.UserInputType.Keyboard then
						local K = Input.KeyCode;
						if K == Enum.KeyCode.Escape then
							CancelListen();
						else
							Key = K;
							Listening = false;
							if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
							Refresh();
							if OnChanged then OnChanged(Key) end;
							Library:NotifyKeybind();
						end;
					elseif T == Enum.UserInputType.MouseButton1
						or T == Enum.UserInputType.MouseButton2
						or T == Enum.UserInputType.MouseButton3 then
						Key = T;
						Listening = false;
						if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
						Refresh();
						if OnChanged then OnChanged(Key) end;
						Library:NotifyKeybind();
					end;
				end);
			end);
		end;
		Row.MouseButton1Click:Connect(StartListen);
		local ModeOpts = { "Toggle", "Hold", "Always" };
		local Popup = Library:CreateInstance("CanvasGroup", {
			Name              = "KeybindPopup_" .. Name;
			Parent            = Host.Gui;
			Size              = UDim2.new(0, 80, 0, 0);
			AutomaticSize     = Enum.AutomaticSize.Y;
			BackgroundColor3  = Color3.fromHex("000000");
			BorderSizePixel   = 0;
			Visible           = false;
			GroupTransparency = 1;
			ZIndex            = 50;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = Popup;
			PaddingLeft   = UDim.new(0, 1);
			PaddingRight  = UDim.new(0, 1);
			PaddingTop    = UDim.new(0, 1);
			PaddingBottom = UDim.new(0, 1);
		});
		local PopupGray = Library:CreateInstance("Frame", {
			Parent           = Popup;
			Size             = UDim2.new(1, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.Y;
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
			ZIndex           = 50;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = PopupGray;
			PaddingLeft   = UDim.new(0, 1);
			PaddingRight  = UDim.new(0, 1);
			PaddingTop    = UDim.new(0, 1);
			PaddingBottom = UDim.new(0, 1);
		});
		local PopupInside = Library:CreateInstance("Frame", {
			Parent           = PopupGray;
			Size             = UDim2.new(1, 0, 0, 0);
			AutomaticSize    = Enum.AutomaticSize.Y;
			BackgroundColor3 = Color3.fromHex("131313");
			BorderSizePixel  = 0;
			ZIndex           = 50;
		});
		Library:CreateInstance("UIListLayout", {
			Parent        = PopupInside;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 0);
		});
		Library:CreateInstance("UIPadding", {
			Parent        = PopupInside;
			PaddingTop    = UDim.new(0, 2);
			PaddingBottom = UDim.new(0, 2);
		});
		local Obj;
		local PopupOpen = false;
		local PopupToken = 0;
		local PopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		local PopupSlide = 8;
		local ModeBtns = {};
		local function RefreshModeBtns()
			for M, B in ModeBtns do
				B.TextColor3 = (M == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
			end;
		end;
		local function ClosePopup()
			if not PopupOpen then return end;
			PopupOpen = false;
			PopupToken = PopupToken + 1;
			local Mine = PopupToken;
			local Ap = Box.AbsolutePosition;
			local Sz = Box.AbsoluteSize;
			Library:Tween(Popup, PopupInfo, {
				GroupTransparency = 1;
				Position          = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62 - PopupSlide);
			}):Play();
			task.delay(PopupInfo.Time, function()
				if PopupToken == Mine then Popup.Visible = false end;
			end);
		end;
		local function OpenPopup()
			if PopupOpen then ClosePopup(); return end;
			PopupOpen = true;
			PopupToken = PopupToken + 1;
			RefreshModeBtns();
			local Ap = Box.AbsolutePosition;
			local Sz = Box.AbsoluteSize;
			local PX, PY = Library:ClampPopupXY(Popup, Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62);
			Popup.GroupTransparency = 1;
			Popup.Position = UDim2.fromOffset(PX, PY - PopupSlide);
			Popup.Visible = true;
			Library:Tween(Popup, PopupInfo, {
				GroupTransparency = 0;
				Position          = UDim2.fromOffset(PX, PY);
			}):Play();
		end;
		for I, M in ModeOpts do
			local Btn = Library:CreateInstance("TextButton", {
				Parent                 = PopupInside;
				Size                   = UDim2.new(1, 0, 0, 14);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				AutoButtonColor        = false;
				Text                   = M;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 12;
				TextXAlignment         = Enum.TextXAlignment.Left;
				LayoutOrder            = I;
			});
			Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 6) });
			if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
			ModeBtns[M:lower()] = Btn;
			Btn.MouseButton1Click:Connect(function()
				Obj:SetMode(M);
				ClosePopup();
			end);
		end;
		RefreshModeBtns();
		Row.MouseButton2Click:Connect(OpenPopup);
		Library:BindLongPress(Row, OpenPopup);
		Library:Connection(UserInputService.InputBegan, function(Input)
			if not PopupOpen then return end;
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1
				and Input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end;
			local M = UserInputService:GetMouseLocation();
			local Ap = Popup.AbsolutePosition;
			local Sz = Popup.AbsoluteSize;
			if M.X < Ap.X or M.Y < Ap.Y or M.X > Ap.X + Sz.X or M.Y > Ap.Y + Sz.Y then
				local Bp = Box.AbsolutePosition;
				local Bs = Box.AbsoluteSize;
				if M.X < Bp.X or M.Y < Bp.Y or M.X > Bp.X + Bs.X or M.Y > Bp.Y + Bs.Y then
					ClosePopup();
				end;
			end;
		end);
		local function KeyMatches(Input)
			if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
			if Key.EnumType == Enum.KeyCode then
				return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
			elseif Key.EnumType == Enum.UserInputType then
				return Input.UserInputType == Key;
			end;
			return false;
		end;
		Library:Connection(UserInputService.InputBegan, function(Input, GameProc)
			if GameProc then return end;
			if Listening then return end;
			if UserInputService:GetFocusedTextBox() then return end;
			if not KeyMatches(Input) then return end;
			if Mode == "always" then
				Callback(true);
			elseif Mode == "hold" then
				SetState(true);
			else
				SetState(not State);
			end;
		end);
		Library:Connection(UserInputService.InputEnded, function(Input)
			if Mode ~= "hold" then return end;
			if not KeyMatches(Input) then return end;
			if State then SetState(false) end;
		end);
		if Opts.Tooltip then Library:Tooltip(Row, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Row.Visible = S end);
		end;
		local BindEntry = Library:RegisterKeybind({
			Name     = Name;
			GetMode  = function() return Mode end;
			GetKey   = function() return Key end;
			GetState = function() return State end;
			SetState = function(V) if Mode == "toggle" then SetState(V) end end;
			Toggle   = function() if Mode == "toggle" then SetState(not State) end end;
			GetMenuVisible = function() return MenuVisible end;
			SetMenuVisible = function(V)
				MenuVisible = V == true;
				Library:NotifyKeybind();
			end;
		});
		Obj = { Container = Row, Box = Box, Display = Display };
		function Obj:Get() return State end;
		function Obj:GetKey() return Key end;
		function Obj:SetKey(K)
			if Listening then CancelListen() end;
			Key = K;
			Refresh();
			if OnChanged then OnChanged(Key) end;
			Library:NotifyKeybind();
		end;
		function Obj:GetMode() return Mode end;
		function Obj:SetMode(M)
			M = string.lower(tostring(M or "toggle"));
			if M ~= "toggle" and M ~= "hold" and M ~= "always" then return end;
			Mode = M;
			RefreshModeBtns();
			if Mode == "always" then SetState(true) end;
			Library:NotifyKeybind();
		end;
		function Obj:SetState(V) if Mode == "toggle" then SetState(V) end end;
		function Obj:GetMenuVisible() return MenuVisible end;
		function Obj:SetMenuVisible(V) BindEntry.SetMenuVisible(V) end;
		function Obj:SetText(T)
			Name = tostring(T);
			Lbl.Text = Name;
			BindEntry.Name = Name;
			Library:NotifyKeybind();
		end;
		Library.Options[Flag] = {
			Save = function()
				local Out = { _t = "Key", m = Mode };
				if typeof(Key) == "EnumItem" then
					Out.k = tostring(Key.EnumType) .. "." .. Key.Name;
				end;
				return Out;
			end;
			Load = function(Data)
				if typeof(Data) ~= "table" or Data._t ~= "Key" then return end;
				if Data.m then Obj:SetMode(Data.m) end;
				local NewKey = nil;
				if typeof(Data.k) == "string" then
					local EType, EName = string.match(Data.k, "^(%w+)%.(%w+)$");
					if EType and EName then
						pcall(function() NewKey = Enum[EType][EName] end);
					end;
				end;
				Obj:SetKey(NewKey);
				Library:NotifyKeybind();
			end;
		};
		return Obj;
	end;
	function SecRef:List(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "List");
		local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
		local Multi    = Opts.Multi == true;
		local Height   = tonumber(Opts.Height) or 100;
		local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
		local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
		local Value;
		if Multi then
			Value = {};
			if typeof(Opts.Default) == "table" then
				for _, V in Opts.Default do Value[tostring(V)] = true end;
			end;
		else
			Value = tostring(Opts.Default or Options[1] or "");
		end;
		Library.Flags[Flag] = Value;
		local Container = Library:CreateInstance("Frame", {
			Name                   = "List_" .. Name;
			Parent                 = self.Body;
			Size                   = UDim2.new(1, 0, 0, Height + 16);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Parent                 = Container;
			Size                   = UDim2.new(1, 0, 0, 12);
			BackgroundTransparency = 1;
			Text                   = Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local Box = Library:CreateInstance("Frame", {
			Name             = "Box";
			Parent           = Container;
			AnchorPoint      = Vector2.new(0, 1);
			Position         = UDim2.new(0, 0, 1, 0);
			Size             = UDim2.new(1, 0, 0, Height);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
		});
		local BoxGray = Library:CreateInstance("Frame", {
			Parent = Box; Position = UDim2.new(0, 1, 0, 1);
			Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
		});
		local BoxInside = Library:CreateInstance("Frame", {
			Parent = BoxGray; Position = UDim2.new(0, 1, 0, 1);
			Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
		});
		Library:CreateInstance("UIGradient", {
			Parent = BoxInside; Rotation = 90;
			Color = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
				NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
			});
		});
		local Scroller = Library:CreateInstance("ScrollingFrame", {
			Parent                 = BoxInside;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			CanvasSize             = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize    = Enum.AutomaticSize.Y;
			ScrollBarThickness     = 2;
			ScrollBarImageColor3   = Library.Accent;
			ScrollingDirection     = Enum.ScrollingDirection.Y;
			ClipsDescendants       = true;
		});
		Library:RegisterAccent(Scroller, "ScrollBarImageColor3");
		Library:_AttachScrollbar(Scroller);
		Library:CreateInstance("UIListLayout", {
			Parent        = Scroller;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
		});
		Library:CreateInstance("UIPadding", {
			Parent     = Scroller;
			PaddingTop = UDim.new(0, 2);
		});
		local OptionButtons = {};
		local function IsSelected(Opt)
			Opt = tostring(Opt);
			if Multi then return Value[Opt] == true end;
			return Opt == Value;
		end;
		local OptColorInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local function RefreshColors()
			for _, B in OptionButtons do
				local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
				Library:Tween(B, OptColorInfo, { TextColor3 = Target }):Play();
			end;
		end;
		local function SetVal(V, Fire)
			V = tostring(V);
			if Multi then
				Value[V] = (not Value[V]) or nil;
			else
				if V == Value then return end;
				Value = V;
			end;
			Library.Flags[Flag] = Value;
			RefreshColors();
			if Fire ~= false then Callback(Value) end;
		end;
		local function BuildOptions()
			for _, C in Scroller:GetChildren() do
				if C:IsA("TextButton") then C:Destroy() end;
			end;
			table.clear(OptionButtons);
			for I, Opt in Options do
				local Btn = Library:CreateInstance("TextButton", {
					Name                   = "Opt_" .. tostring(Opt);
					Parent                 = Scroller;
					Size                   = UDim2.new(1, 0, 0, 14);
					BackgroundTransparency = 1;
					BorderSizePixel        = 0;
					AutoButtonColor        = false;
					Text                   = tostring(Opt);
					TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
					TextSize               = 12;
					TextXAlignment         = Enum.TextXAlignment.Left;
					LayoutOrder            = I;
				});
				Library:CreateInstance("UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
				if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
				Btn.MouseButton1Click:Connect(function() SetVal(Btn.Text) end);
				table.insert(OptionButtons, Btn);
			end;
		end;
		BuildOptions();
		Library:OnAccent(RefreshColors);
		if Opts.Tooltip then Library:Tooltip(Box, Opts.Tooltip) end;
		if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
			Opts.Dependency:OnChange(function(S) Container.Visible = S end);
		end;
		local Obj = { Container = Container, Box = Box, Scroller = Scroller };
		function Obj:Get() return Value end;
		function Obj:Set(V) SetVal(V) end;
		function Obj:SetOptions(Opts2)
			Options = typeof(Opts2) == "table" and Opts2 or {};
			BuildOptions();
		end;
		Library.Options[Flag] = {
			Save = function() return Value end;
			Load = function(Data)
				if Multi then
					if typeof(Data) == "table" then
						Value = {};
						for K2, On in Data do
							if On then Value[tostring(K2)] = true end;
						end;
						Library.Flags[Flag] = Value;
						RefreshColors();
						Callback(Value);
					end;
				elseif Data ~= nil then
					SetVal(tostring(Data));
				end;
			end;
		};
		return Obj;
	end;
	function SecRef:Preview(Opts)
		return Library:_BuildPreview(self.Body, Opts);
	end;
	return SecRef;
end;
local ApplySettingsContents = nil;
function Library:Window(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Width     = tonumber(Opts.Width)     or 400;
	local Height    = tonumber(Opts.Height)    or 700;
	local MinWidth  = tonumber(Opts.MinWidth)  or 280;
	local MinHeight = tonumber(Opts.MinHeight) or (IsMobilePlatform and 200 or 400);
	Width, Height       = ClampWindowSize(Width, Height);
	MinWidth, MinHeight = ClampWindowSize(MinWidth, MinHeight);
	if Width  < MinWidth  then Width  = MinWidth  end;
	if Height < MinHeight then Height = MinHeight end;
	if IsMobilePlatform then
		local Cam = workspace.CurrentCamera;
		local Vp  = (Cam and Cam.ViewportSize) or Vector2.new(800, 600);
		Width  = math.min(tonumber(Opts.Width) or 550, math.max(math.floor(Vp.X) - 10, MinWidth));
		Height = math.clamp(math.floor(Vp.Y) - 35, 200, 600);
	end;
	local Gui = self:CreateInstance("ScreenGui", {
		Name = "XoneScriptKTallWindow";
		Parent = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local Outer = self:CreateInstance("Frame", {
		Name = "Outer";
		Parent = Gui;
		AnchorPoint = Vector2.new(0.5, 0.5);
		Position = UDim2.new(0.5, 0, 0.5, 0);
		Size = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Name = "InnerOutline";
		Parent = Outer;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
	});
	pcall(function() Library:AddGlowingV2(Outer, Color3.fromHex("000000"), 0.55) end);
	pcall(function() Library:AddGlowingV2(Outer, Library.Accent, 0.86) end);
	local AnimScale = self:CreateInstance("UIScale", { Parent = Outer; Scale = 1 });
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Name = "TopLine";
		Parent = Outer;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel = 0;
		ZIndex = 10;
	});
	local TopLineGradient = self:CreateInstance("UIGradient", {
		Parent = TopLine;
		Rotation = 0;
	});
	Library:RegisterAccentGradient(TopLineGradient);
	local TitleText = tostring(Opts.Title or Opts.Name or "XoneScriptK");
	local Title = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 9);
		Size                   = UDim2.new(0, 200, 0, 18);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Text                   = TitleText;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;
local TitleLogo = self:CreateInstance("ImageLabel", {
	Name = "TitleLogo";
	Parent = Outer;
	AnchorPoint = Vector2.new(0, 0.5);
	Position = UDim2.new(0, 5, 0, 20);
	Size = UDim2.fromOffset(26,26);
	BackgroundTransparency = 1;
});
local LogoOpt = Opts.Logo;
if LogoOpt == nil then LogoOpt = Opts.Icon end;
if LogoOpt == nil then LogoOpt = Library._CustomLogo end;
if LogoOpt == false then
	TitleLogo.Visible = false;
	Title.Position = UDim2.new(0, 6, 0, 9);
else
	local LogoAsset = Library._ResolveLogo and Library:_ResolveLogo(LogoOpt) or nil;
	if LogoAsset then
		TitleLogo.Image = LogoAsset;
		table.insert(Library._LogoInstances or {}, TitleLogo);
		Title.Position = UDim2.new(0, 5 + TitleLogo.AbsoluteSize.X + 4, 0, 9);
	else
		TitleLogo.Visible = false;
		Title.Position = UDim2.new(0, 6, 0, 9);
	end;
end;
	local Content = self:CreateInstance("Frame", {
		Name             = "Content";
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 34);
		Size             = UDim2.new(1, -10, 1, -39);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local function ContentEdge(Name, Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Name             = Name;
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
	ContentEdge("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2),  "393939");
	ContentEdge("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
	ContentEdge("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2),  "393939");
	ContentEdge("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),   "000000");
	ContentEdge("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1),  "393939");
	self:Draggable(Outer);
	self:Resizable(Outer, Vector2.new(MinWidth, MinHeight));
	local Window = { Gui = Gui, Outer = Outer, TopLine = TopLine, Content = Content };
	Window._Tabs = {};
	Library.TabStyle = Library.TabStyle or "Sidebar";
	function Library:_ApplyTabLayout(Win)
		local Bar = Win.TabBar;
		if not Bar then return end;
		local Sidebar = (self.TabStyle == "Sidebar");
		local Layout = Bar:FindFirstChildOfClass("UIListLayout");
		if Layout then
			Layout.FillDirection = Sidebar and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal;
			Layout.Padding       = Sidebar and UDim.new(0, 2) or UDim.new(0, 0);
		end;
		Bar.Position = UDim2.new(0, 0, 0, 0);
		Bar.Size     = Sidebar and UDim2.new(0, 112, 1, 0) or UDim2.new(1, 0, 0, 24);
		local N = math.max(#Win._Tabs, 1);
		for _, T in Win._Tabs do
			T.Button.Size = Sidebar and UDim2.new(1, 0, 0, 24) or UDim2.new(1 / N, 0, 1, 0);
			if T.Separator then T.Separator.Visible = not Sidebar end;
			T._PageHome = Sidebar and UDim2.new(0, 116, 0, 0) or UDim2.new(0, 0, 0, 24);
			Library:Tween(T.Page, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = T._PageHome;
				Size     = Sidebar and UDim2.new(1, -116, 1, 0) or UDim2.new(1, 0, 1, -24);
			}):Play();
			T.Page.Size     = Sidebar and UDim2.new(1, -116, 1, 0) or UDim2.new(1, 0, 1, -24);
		end;
	end;
	function Library:SetTabStyle(V)
		V = tostring(V or "");
		self.TabStyle = (V == "Native" or V == "原生") and "Native" or "Sidebar";
		for _, W in ipairs(self._Windows or {}) do
			pcall(function() self:_ApplyTabLayout(W) end);
		end;
	end;
	function Window:Tab(NameOrOpts)
		local TabOpts = typeof(NameOrOpts) == "table" and NameOrOpts or { Name = tostring(NameOrOpts) };
		local TabName = tostring(TabOpts.Name or TabOpts.Title or "Tab");
		if not self.TabBar then
			self.TabBar = Library:CreateInstance("Frame", {
				Name                   = "TabBar";
				Parent                 = self.Content;
				Position               = UDim2.new(0, 0, 0, 0);
				Size                   = UDim2.new(1, 0, 0, 24);
				BackgroundTransparency = 1;
				BorderSizePixel        = 0;
				ZIndex                 = 5;
			});
			Library:CreateInstance("UIListLayout", {
				Parent        = self.TabBar;
				FillDirection = Enum.FillDirection.Horizontal;
				SortOrder     = Enum.SortOrder.LayoutOrder;
				Padding       = UDim.new(0, 0);
			});
		end;
		local Btn = Library:CreateInstance("TextButton", {
			Name                   = "Tab_" .. TabName;
			Parent                 = self.TabBar;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = "";
			LayoutOrder            = #self._Tabs + 1;
		});
		local Bg = Library:CreateInstance("Frame", {
			Name             = "Bg";
			Parent           = Btn;
			Position         = UDim2.new(0, 0, 0, 0);
			Size             = UDim2.new(1, 0, 1, 0);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
		});
		local Gradient = Library:CreateInstance("UIGradient", {
			Parent   = Bg;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
				NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
			});
		});
		local function MakePiece(Name, Anchor, Pos, Sz, Color, ZIdx)
			return Library:CreateInstance("Frame", {
				Name                   = Name;
				Parent                 = Bg;
				AnchorPoint            = Anchor;
				Position               = Pos;
				Size                   = Sz;
				BackgroundColor3       = Color3.fromHex(Color);
				BorderSizePixel        = 0;
				BackgroundTransparency = 1;
				ZIndex                 = ZIdx;
			});
		end;
		local TopBlack    = MakePiece("TopBlack",    Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
		local TopGray     = MakePiece("TopGray",     Vector2.new(0, 0), UDim2.new(0, 0, 0, 1), UDim2.new(1, 0, 0, 1), "393939", 4);
		local BottomBlack = MakePiece("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
		local BottomGray  = MakePiece("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), "393939", 4);
		local LeftBlack   = MakePiece("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
		local LeftGray    = MakePiece("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
		local RightBlack  = MakePiece("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
		local RightGray   = MakePiece("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
		local Separator = Library:CreateInstance("Frame", {
			Name                   = "Separator";
			Parent                 = Bg;
			AnchorPoint            = Vector2.new(1, 0);
			Position               = UDim2.new(1, 0, 0, 2);
			Size                   = UDim2.new(0, 1, 1, -4);
			BackgroundColor3       = Color3.fromHex("393939");
			BorderSizePixel        = 0;
			BackgroundTransparency = 1;
			ZIndex                 = 2;
		});
		local Lbl = Library:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Bg;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Text                   = TabName;
			TextSize               = 12;
			TextColor3             = Color3.fromHex("8C8F99");
			TextXAlignment         = Enum.TextXAlignment.Center;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		local TopGradient = Library:CreateInstance("Frame", {
			Name                   = "TopGradient";
			Parent                 = Bg;
			AnchorPoint            = Vector2.new(0, 0);
			Position               = UDim2.new(0, 0, 0, 0);
			Size                   = UDim2.new(1, 0, 0, 1);
			BackgroundColor3       = Color3.fromHex("FFFFFF");
			BorderSizePixel        = 0;
			BackgroundTransparency = 1;
			ZIndex                 = 5;
		});
		local TabTopGradient = Library:CreateInstance("UIGradient", {
			Parent   = TopGradient;
			Rotation = 0;
		});
		Library:RegisterAccentGradient(TabTopGradient);
		local Page = Library:CreateInstance("CanvasGroup", {
			Name                   = "Page_" .. TabName;
			Parent                 = self.Content;
			Position               = UDim2.new(0, 0, 0, 24);
			Size                   = UDim2.new(1, 0, 1, -24);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			Visible                = false;
			GroupTransparency      = 1;
		});
		Library:CreateInstance("UIPadding", {
			Parent        = Page;
			PaddingLeft   = UDim.new(0, 6);
			PaddingRight  = UDim.new(0, 6);
			PaddingTop    = UDim.new(0, 11);
			PaddingBottom = UDim.new(0, 6);
		});
		local LeftColumn = Library:CreateInstance("ScrollingFrame", {
			Name                   = "Left";
			Parent                 = Page;
			AnchorPoint            = Vector2.new(0, 0);
			Position               = UDim2.new(0, 0, 0, -2);
			Size                   = UDim2.new(0.5, -3, 1, 2);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			CanvasSize             = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize    = Enum.AutomaticSize.Y;
			ScrollBarThickness     = 0;
			ScrollingDirection     = Enum.ScrollingDirection.Y;
			ClipsDescendants       = true;
		});
		Library:RegisterAccent(LeftColumn, "ScrollBarImageColor3");
		Library:CreateInstance("UIListLayout", {
			Parent        = LeftColumn;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 6);
		});
		Library:CreateInstance("UIPadding", {
			Parent        = LeftColumn;
			PaddingTop    = UDim.new(0, 4);
			PaddingBottom = UDim.new(0, 6);
		});
		local RightColumn = Library:CreateInstance("ScrollingFrame", {
			Name                   = "Right";
			Parent                 = Page;
			AnchorPoint            = Vector2.new(1, 0);
			Position               = UDim2.new(1, 0, 0, -2);
			Size                   = UDim2.new(0.5, -3, 1, 2);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			CanvasSize             = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize    = Enum.AutomaticSize.Y;
			ScrollBarThickness     = 0;
			ScrollingDirection     = Enum.ScrollingDirection.Y;
			ClipsDescendants       = true;
		});
		Library:RegisterAccent(RightColumn, "ScrollBarImageColor3");
		Library:CreateInstance("UIListLayout", {
			Parent        = RightColumn;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 6);
		});
		Library:CreateInstance("UIPadding", {
			Parent        = RightColumn;
			PaddingTop    = UDim.new(0, 4);
			PaddingBottom = UDim.new(0, 6);
		});
		local function BindScrollDragGuard(Column)
			local Last = 0;
			Library:Connection(Column:GetPropertyChangedSignal("CanvasPosition"), function()
				if not IsMobilePlatform then return end;
				Library.CanDrag = false;
				Last = tick();
				local Mine = Last;
				task.delay(0.15, function()
					if Last == Mine then Library.CanDrag = true end;
				end);
			end);
		end;
		BindScrollDragGuard(LeftColumn);
		BindScrollDragGuard(RightColumn);
		Library:_AttachScrollbar(LeftColumn);
		Library:_AttachScrollbar(RightColumn);
		local TabRef = {
			Name        = TabName;
			Button      = Btn;
			Bg          = Bg;
			Label       = Lbl;
			Page        = Page;
			Left        = LeftColumn;
			Right       = RightColumn;
			Gradient    = Gradient;
			Separator   = Separator;
			TopBlack    = TopBlack;
			TopGray     = TopGray;
			BottomBlack = BottomBlack;
			BottomGray  = BottomGray;
			LeftBlack   = LeftBlack;
			LeftGray    = LeftGray;
			RightBlack  = RightBlack;
			RightGray   = RightGray;
			TopGradient = TopGradient;
			Active      = false;
			IsLeft      = false;
			IsRight     = false;
		};
		local PageInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		local BgInfo   = TweenInfo.new(0.2,  Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
		local InactiveA, InactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
		local ActiveA,   ActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
		local GradT      = TabRef.Active and 1 or 0;
		local GradTarget = GradT;
		local function ApplyGrad()
			Gradient.Color = NewColorSequence({
				NewColorSequenceKeypoint(0, InactiveA:Lerp(ActiveA, GradT));
				NewColorSequenceKeypoint(1, InactiveB:Lerp(ActiveB, GradT));
			});
		end;
		Gradient.Enabled = true;
		ApplyGrad();
		Library:Connection(RunService.Heartbeat, function(Dt)
    local i = 1
    local list = Library._GradLerps
    while i <= #list do
        local e = list[i]
        if not e.Bg or not e.Bg.Parent then
            list[i] = list[#list]
            list[#list] = nil
            continue
        end
        if math.abs(e.Target - e.T) < 0.001 then
            if e.T ~= e.Target then
                e.T = e.Target
                e.Apply(e.T)
            end
            i += 1
            continue
        end
        e.T = e.T + (e.Target - e.T) * (1 - math.exp(-Dt * 16))
        e.Apply(e.T)
        i += 1
    end
end)
local GradEntry = {
    Bg     = Bg,
    T      = 0,
    Target = 0,
    Apply  = function(t)
        Gradient.Color = NewColorSequence({
            NewColorSequenceKeypoint(0, InactiveA:Lerp(ActiveA, t)),
            NewColorSequenceKeypoint(1, InactiveB:Lerp(ActiveB, t)),
        })
    end
}
RegisterGradLerp(GradEntry)
		function TabRef:SetActive(State)
			self.Active = State;
			if State then
				local WasHidden = not self.Page.Visible;
				self.Page.Visible = true;
				Library:Tween(self.Page, PageInfo, { GroupTransparency = 0 }):Play();
				if WasHidden then
					local Home = self._PageHome or UDim2.new(0, 0, 0, 24);
					self.Page.Position = Home + UDim2.fromOffset(0, 8);
					Library:Tween(self.Page, PageInfo, { Position = Home }):Play();
				end;
				local Lo = self.IsLeft  and 1 or 0;
				local Ro = self.IsRight and 1 or 0;
				Library:Tween(Bg, BgInfo, {
					Position = UDim2.new(0, Lo, 0, 1);
					Size     = UDim2.new(1, -Lo - Ro, 1, -1);
				}):Play();
				GradTarget          = 1;
				Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
				Library:Tween(Lbl, BgInfo, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
				TopGradient.Position = UDim2.new(0, 0, 0, 0);
				TopGradient.Size     = UDim2.new(1, 0, 0, 1);
			else
				local P = self.Page;
				Library:Tween(P, PageInfo, { GroupTransparency = 1 }):Play();
				local Home = self._PageHome or UDim2.new(0, 0, 0, 24);
				Library:Tween(P, PageInfo, { Position = Home + UDim2.fromOffset(0, 8) }):Play();
				task.delay(PageInfo.Time, function()
					if not self.Active then P.Visible = false; P.Position = Home end;
				end);
				Library:Tween(Bg, BgInfo, {
					Position = UDim2.new(0, 0, 0, 0);
					Size     = UDim2.new(1, 0, 1, 0);
				}):Play();
				GradTarget          = 0;
				Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
				Library:Tween(Lbl, BgInfo, { TextColor3 = Color3.fromHex("8C8F99") }):Play();
			end;
		end;
		function TabRef:Section(SecOpts)
			return BuildSection({ Left = self.Left; Right = self.Right; Page = self.Page; Gui = Gui }, SecOpts);
		end;
		function TabRef:ApplySettings()
			self.SettingsControls = ApplySettingsContents(self);
			Library._SettingsTab = self;
			return self;
		end;
		local WinRef = self;
		Btn.MouseButton1Click:Connect(function()
			for _, T in WinRef._Tabs do
				if T ~= TabRef and T.Active then T:SetActive(false) end;
			end;
			TabRef:SetActive(true);
		end);
		table.insert(self._Tabs, TabRef);
		local N = #self._Tabs;
		Library:_ApplyTabLayout(self);
		for I, T in self._Tabs do
			T.IsLeft  = (I == 1);
			T.IsRight = (I == N);
			T:SetActive(T.Active);
		end;
		if N == 1 then
			TabRef:SetActive(true);
		end;
		local SepInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		local function FadePiece(P, T)
			Library:Tween(P, SepInfo, { BackgroundTransparency = T }):Play();
		end;
		local function RefreshSeparators()
			for I, T in self._Tabs do
				local Prev = self._Tabs[I - 1];
				local Next = self._Tabs[I + 1];
				if T.Active then
					FadePiece(T.Separator,   1);
					FadePiece(T.TopBlack,    1);
					FadePiece(T.TopGray,     1);
					FadePiece(T.BottomBlack, 1);
					FadePiece(T.BottomGray,  1);
					FadePiece(T.LeftBlack,   1);
					FadePiece(T.LeftGray,    1);
					FadePiece(T.RightBlack,  1);
					FadePiece(T.RightGray,   1);
					FadePiece(T.TopGradient, 0);
				else
					FadePiece(T.TopGradient, 1);
					local LeftShown  = (Prev ~= nil) and Prev.Active;
					local RightShown = (Next ~= nil) and Next.Active;
					FadePiece(T.TopBlack,    0);
					FadePiece(T.TopGray,     0);
					FadePiece(T.BottomBlack, 0);
					FadePiece(T.BottomGray,  0);
					FadePiece(T.LeftBlack,   LeftShown  and 0 or 1);
					FadePiece(T.LeftGray,    LeftShown  and 0 or 1);
					FadePiece(T.RightBlack,  RightShown and 0 or 1);
					FadePiece(T.RightGray,   RightShown and 0 or 1);
					FadePiece(T.Separator,   (Next ~= nil and not Next.Active) and 0 or 1);
					local Li = LeftShown and 1 or 0;
					local Ri = RightShown and 1 or 0;
					T.TopGray.Position    = UDim2.new(0, Li, 0, 1);
					T.TopGray.Size        = UDim2.new(1, -Li - Ri, 0, 1);
					T.BottomGray.Position = UDim2.new(0, Li, 1, -1);
					T.BottomGray.Size     = UDim2.new(1, -Li - Ri, 0, 1);
				end;
			end;
		end;
		RefreshSeparators();
		local OrigSetActive = TabRef.SetActive;
		function TabRef:SetActive(State)
			OrigSetActive(self, State);
			RefreshSeparators();
			if WinRef._Satellites then
				for _, S in ipairs(WinRef._Satellites) do
					if S._RefreshBinding then task.defer(S._RefreshBinding, S) end;
				end;
			end;
		end;
		return TabRef;
	end;
	self.CurrentlyOpen = Window;
	Library._Windows = Library._Windows or {}; table.insert(Library._Windows, Window);
	Window.Visible = true;
	Window._ActiveFade = nil;
	Window._FadeOriginals = nil;
	local FadeProps = {
		Frame          = { "BackgroundTransparency" };
		TextLabel      = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		TextButton     = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		TextBox        = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
		ImageLabel     = { "BackgroundTransparency", "ImageTransparency" };
		ImageButton    = { "BackgroundTransparency", "ImageTransparency" };
		ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" };
		CanvasGroup    = { "BackgroundTransparency", "GroupTransparency" };
		UIStroke       = { "Transparency" };
		UIShadow       = { "Transparency" };
		ViewportFrame  = { "BackgroundTransparency", "ImageTransparency" };
		VideoFrame     = { "BackgroundTransparency", "ImageTransparency" };
	};
	local function CaptureOriginals()
		local Map = {};
		for _, Inst in Outer:GetDescendants() do
			local Props = FadeProps[Inst.ClassName];
			if Props then
				local PMap = {};
				for _, P in Props do
					local Ok, V = pcall(function() return Inst[P] end);
					if Ok then PMap[P] = V end;
				end;
				Map[Inst] = PMap;
			end;
		end;
		local OuterProps = FadeProps[Outer.ClassName];
		if OuterProps then
			local PMap = {};
			for _, P in OuterProps do
				local Ok, V = pcall(function() return Outer[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Outer] = PMap;
		end;
		return Map;
	end;
	function Window:SetVisible(State)
		State = State and true or false;
		if self.Visible == State and Gui.Enabled == State and not self._ActiveFade then return end;
		self.Visible = State;
		if self._ActiveFade then self._ActiveFade:Disconnect(); self._ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(self._FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; AnimScale.Scale = 1; self._FadeClean = true; return;
		end;
		if not self.Visible then
			local NewMap = CaptureOriginals();
			if self._FadeClean or not self._FadeOriginals then
				self._FadeOriginals = NewMap;
			else
				self._FadeOriginals = Library:_RefreshFadeMap(self._FadeOriginals, NewMap);
			end;
		elseif not self._FadeOriginals then
			self._FadeOriginals = CaptureOriginals();
		end;
		if self.Visible then
			Gui.Enabled = true;
			AnimScale.Scale = 0.965;
			Library:Tween(AnimScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = 1;
			}):Play();
			self._FadeClean = false;
			self._ActiveFade = Library:_FadeGroup(self._FadeOriginals, "in", 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				self._ActiveFade = nil; self._FadeClean = true;
			end);
		else
			Library:Tween(AnimScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0.965;
			}):Play();
			self._FadeClean = false;
			self._ActiveFade = Library:_FadeGroup(self._FadeOriginals, "out", 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self.Visible then Gui.Enabled = false end;
				self._ActiveFade = nil; self._FadeClean = true;
			end);
		end;
	end;
	function Window:Toggle()
		self:SetVisible(not self.Visible);
	end;
	function Window:Destroy()
		if Library._Windows then
			for K, W in ipairs(Library._Windows) do
				if W == self then table.remove(Library._Windows, K) break end;
			end;
		end;
		Gui:Destroy();
		if Library.CurrentlyOpen == self then Library.CurrentlyOpen = nil end;
	end;
	return Window;
end;
function Library:KeybindList(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	if Library._KeybindList and not Library._KeybindList.Destroyed then Library._KeybindList:Destroy() end;
	local Title = tostring(Opts.Title or Opts.Text or "Keybinds");
	local Width = math.clamp(tonumber(Opts.Width) or 210, 150, 360);
	local ShowToggleState = Opts.ShowToggleState ~= false and Library.ShowToggleFrameInKeybinds ~= false;
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "KeybindList";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		DisplayOrder   = 20;
	});
	local SatAnchor = Opts.AnchorPoint or Vector2.new(1, 0);
	local SatPos = Opts.Position or UDim2.new(1, -10, 0, 210);
	if IsMobilePlatform and not Opts.Position then SatPos = UDim2.new(1, -8, 0, 38) end;
	local Frame = self:CreateInstance("Frame", {
		Name             = "Keybinds";
		Parent           = Gui;
		AnchorPoint      = SatAnchor;
		Position         = SatPos;
		Size             = UDim2.new(0, Width, 0, 0);
		AutomaticSize    = Enum.AutomaticSize.Y;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ClipsDescendants = false;
	});
	pcall(function() Library:AddGlowingV2(Frame, Library.Accent, 0.4) end);
	self:CreateInstance("UIGradient", {
		Parent   = Frame;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
			NewColorSequenceKeypoint(1, Color3.fromHex("141414"));
		});
	});
	local function Edge(Parent, Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Parent;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 5;
		});
	end;
	Edge(Frame, Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 1), "000000");
	local TopLine = self:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Frame;
		Position         = UDim2.new(0, 0, 0, 1);
		Size             = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 5;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", { Parent = TopLine; Rotation = 0 }));
	Edge(Frame, Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 1), "000000");
	Edge(Frame, Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939");
	Edge(Frame, Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000");
	Edge(Frame, Vector2.new(0, 0), UDim2.new(0, 1, 0, 2), UDim2.new(0, 1, 1, -3), "393939");
	Edge(Frame, Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000");
	Edge(Frame, Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939");
	local Inner = self:CreateInstance("Frame", {
		Name                   = "Inner";
		Parent                 = Frame;
		Position               = UDim2.new(0, 8, 0, 5);
		Size                   = UDim2.new(1, -16, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIListLayout", {
		Parent        = Inner;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 3);
	});
	self:CreateInstance("UIPadding", { Parent = Inner; PaddingBottom = UDim.new(0, 7) });
	local Header = self:CreateInstance("Frame", {
		Name                   = "Header";
		Parent                 = Inner;
		Size                   = UDim2.new(1, 0, 0, 18);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		LayoutOrder            = 1;
		Active                 = true;
	});
	local TitleLbl = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Header;
		Size                   = UDim2.new(1, -42, 1, 0);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextTruncate           = Enum.TextTruncate.AtEnd;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	local function HeaderButton(Name, Text, X)
		local Btn = self:CreateInstance("TextButton", {
			Name                   = Name;
			Parent                 = Header;
			AnchorPoint            = Vector2.new(1, 0.5);
			Position               = UDim2.new(1, X, 0.5, 0);
			Size                   = UDim2.fromOffset(18, 16);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = Text;
			TextColor3             = Color3.fromHex("8C8F99");
			TextSize               = 13;
		});
		if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
		Btn.MouseEnter:Connect(function() Btn.TextColor3 = Color3.fromHex("FFFFFF") end);
		Btn.MouseLeave:Connect(function() Btn.TextColor3 = Color3.fromHex("8C8F99") end);
		return Btn;
	end;
	local SettingsBtn = HeaderButton("Visibility", "...", -20);
	local CollapseBtn = HeaderButton("Collapse", "-", 0);
	local Entries = self:CreateInstance("Frame", {
		Name                   = "Entries";
		Parent                 = Inner;
		Size                   = UDim2.new(1, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		LayoutOrder            = 2;
	});
	self:CreateInstance("UIListLayout", {
		Parent        = Entries;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 3);
	});
	local EmptyLbl = self:CreateInstance("TextLabel", {
		Name                   = "Empty";
		Parent                 = Entries;
		Size                   = UDim2.new(1, 0, 0, 14);
		BackgroundTransparency = 1;
		Text                   = tostring(Opts.EmptyText or "No keybinds");
		TextColor3             = Color3.fromHex("686B73");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		Visible                = false;
		LayoutOrder            = -1;
	});
	if ProggyCleanFont then EmptyLbl.FontFace = ProggyCleanFont end;
	local SettingsFrame = self:CreateInstance("Frame", {
		Name             = "VisibleKeybinds";
		Parent           = Gui;
		Size             = UDim2.new(0, Width + 35, 0, 0);
		AutomaticSize    = Enum.AutomaticSize.Y;
		BackgroundColor3 = Color3.fromHex("171717");
		BorderSizePixel  = 0;
		Visible          = false;
		ZIndex           = 30;
	});
	self:CreateInstance("UIStroke", { Parent = SettingsFrame; Color = Color3.fromHex("393939"); Thickness = 1 });
	local SettingsInner = self:CreateInstance("Frame", {
		Parent                 = SettingsFrame;
		Position               = UDim2.new(0, 8, 0, 5);
		Size                   = UDim2.new(1, -16, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		ZIndex                 = 31;
	});
	self:CreateInstance("UIListLayout", {
		Parent = SettingsInner; FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 3);
	});
	self:CreateInstance("UIPadding", { Parent = SettingsInner; PaddingBottom = UDim.new(0, 7) });
	local SettingsHeader = self:CreateInstance("Frame", {
		Parent = SettingsInner; Size = UDim2.new(1, 0, 0, 18);
		BackgroundTransparency = 1; LayoutOrder = 1; Active = true; ZIndex = 31;
	});
	local SettingsTitle = self:CreateInstance("TextLabel", {
		Parent = SettingsHeader; Size = UDim2.new(1, -22, 1, 0); BackgroundTransparency = 1;
		Text = "Visible Keybinds"; TextColor3 = Color3.fromHex("FFFFFF"); TextSize = 12;
		TextXAlignment = Enum.TextXAlignment.Left; ZIndex = 32;
	});
	if ProggyCleanFont then SettingsTitle.FontFace = ProggyCleanFont end;
	local CloseSettings = self:CreateInstance("TextButton", {
		Parent = SettingsHeader; AnchorPoint = Vector2.new(1, 0.5); Position = UDim2.new(1, 0, 0.5, 0);
		Size = UDim2.fromOffset(18, 16); BackgroundTransparency = 1; AutoButtonColor = false;
		Text = "x"; TextColor3 = Color3.fromHex("8C8F99"); TextSize = 13; ZIndex = 32;
	});
	if ProggyCleanFont then CloseSettings.FontFace = ProggyCleanFont end;
	local SettingsEntries = self:CreateInstance("Frame", {
		Parent = SettingsInner; Size = UDim2.new(1, 0, 0, 0); AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1; LayoutOrder = 2; ZIndex = 31;
	});
	self:CreateInstance("UIListLayout", {
		Parent = SettingsEntries; FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 3);
	});
	self:Draggable(Frame, Header);
	self:Draggable(SettingsFrame, SettingsHeader);
	local function KeyName(Key)
		if Key == nil then return "None" end;
		if typeof(Key) == "EnumItem" then return Library.KeyNames[Key] or Key.Name end;
		return tostring(Key);
	end;
	local function Read(Value, Default)
		if typeof(Value) ~= "function" then return Default end;
		local Ok, Result = pcall(Value);
		if Ok then return Result end;
		return Default;
	end;
	local function ModeTitle(Mode)
		Mode = string.lower(tostring(Mode or "toggle"));
		return Mode:sub(1, 1):upper() .. Mode:sub(2);
	end;
	local Obj = {
		Gui = Gui, Frame = Frame, Outer = Frame, TitleLabel = TitleLbl,
		SettingsFrame = SettingsFrame, SettingsContainer = SettingsEntries,
		Container = Entries, Collapsed = false, SettingsOpen = false,
		VisibilityControl = false, _Visible = Opts.Visible ~= false, Destroyed = false,
	};
	local Rows, SettingsRows = {}, {};
	local ActiveFade, FadeOriginals, RemoveListener;
	local Rebuild, RebuildSettings, PositionSettings;
	local function CreateCheckbox(Parent, Checked, Z)
		local Box = self:CreateInstance("Frame", {
			Parent = Parent; AnchorPoint = Vector2.new(0, 0.5); Position = UDim2.new(0, 0, 0.5, 0);
			Size = UDim2.fromOffset(11, 11); BackgroundColor3 = Color3.fromHex("050505");
			BorderSizePixel = 0; ZIndex = Z or 1;
		});
		self:CreateInstance("UIStroke", { Parent = Box; Color = Color3.fromHex("393939"); Thickness = 1 });
		local Fill = self:CreateInstance("Frame", {
			Parent = Box; AnchorPoint = Vector2.new(0.5, 0.5); Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = Checked and UDim2.new(1, -4, 1, -4) or UDim2.fromOffset(0, 0);
			BackgroundColor3 = Library.Accent; BackgroundTransparency = Checked and 0 or 1;
			BorderSizePixel = 0; ZIndex = (Z or 1) + 1;
		});
		Library:RegisterAccent(Fill);
		return Box, Fill;
	end;
	PositionSettings = function()
		if not Obj.SettingsOpen then return end;
		local Camera = workspace.CurrentCamera;
		local Bounds = Camera and Camera.ViewportSize or Vector2.new(1920, 1080);
		local P, S, SS = Frame.AbsolutePosition, Frame.AbsoluteSize, SettingsFrame.AbsoluteSize;
		local X = P.X - SS.X - 8;
		if X < 0 then X = P.X + S.X + 8 end;
		SettingsFrame.Position = UDim2.fromOffset(
			math.clamp(X, 0, math.max(0, Bounds.X - SS.X)),
			math.clamp(P.Y, 0, math.max(0, Bounds.Y - SS.Y))
		);
	end;
	RebuildSettings = function()
		local Seen = {};
		for I, Entry in Library.Keybinds do
			Seen[Entry] = true;
			local Data = SettingsRows[Entry];
			if not Data then
				local Row = self:CreateInstance("TextButton", {
					Parent = SettingsEntries; Size = UDim2.new(1, 0, 0, 16); BackgroundTransparency = 1;
					AutoButtonColor = false; Text = ""; ZIndex = 31;
				});
				local Box, Fill = CreateCheckbox(Row, false, 31);
				local Lbl = self:CreateInstance("TextLabel", {
					Parent = Row; Position = UDim2.new(0, 17, 0, 0); Size = UDim2.new(1, -17, 1, 0);
					BackgroundTransparency = 1; TextColor3 = Color3.fromHex("FFFFFF");
					TextSize = 12; TextTruncate = Enum.TextTruncate.AtEnd; TextXAlignment = Enum.TextXAlignment.Left; ZIndex = 32;
				});
				if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
				Row.MouseButton1Click:Connect(function()
					if Entry.SetMenuVisible then
						local Visible = Read(Entry.GetMenuVisible, Entry.MenuVisible ~= false) ~= false;
						Entry.SetMenuVisible(not Visible);
					end;
				end);
				Data = { Row = Row, Box = Box, Fill = Fill, Label = Lbl };
				SettingsRows[Entry] = Data;
			end;
			local Visible = Read(Entry.GetMenuVisible, Entry.MenuVisible ~= false) ~= false;
			local Key = Read(Entry.GetKey, nil);
			local Mode = string.lower(Read(Entry.GetMode, Entry.Mode or "toggle"));
			Data.Row.LayoutOrder = I;
			Data.Fill.Size = Visible and UDim2.new(1, -4, 1, -4) or UDim2.fromOffset(0, 0);
			Data.Fill.BackgroundTransparency = Visible and 0 or 1;
			Data.Label.Text = string.format("[%s] %s (%s)", KeyName(Key), tostring(Entry.Name or "?"), ModeTitle(Mode));
			Data.Label.TextTransparency = Visible and 0 or 0.5;
		end;
		for Entry, Data in SettingsRows do
			if not Seen[Entry] then Data.Row:Destroy(); SettingsRows[Entry] = nil end;
		end;
		task.defer(PositionSettings);
	end;
	Rebuild = function()
		if Obj.Destroyed then return end;
		local Seen, Count = {}, 0;
		for I, Entry in Library.Keybinds do
			local Key = Read(Entry.GetKey, nil);
			local Visible = Read(Entry.GetMenuVisible, Entry.MenuVisible ~= false) ~= false;
			if Key ~= nil and Visible then
				Seen[Entry] = true;
				Count += 1;
				local Mode = string.lower(Read(Entry.GetMode, Entry.Mode or "toggle"));
				local State = Read(Entry.GetState, false) == true or Mode == "always";
				local ShowCheck = ShowToggleState and Mode == "toggle";
				local Data = Rows[Entry];
				if Data and Data.ShowCheck ~= ShowCheck then Data.Row:Destroy(); Rows[Entry] = nil; Data = nil end;
				if not Data then
					local Row = self:CreateInstance("TextButton", {
						Name = "Entry"; Parent = Entries; BackgroundTransparency = 1; BorderSizePixel = 0;
						Size = UDim2.new(1, 0, 0, 16); AutoButtonColor = false; Text = "";
					});
					local Box, Fill;
					if ShowCheck then Box, Fill = CreateCheckbox(Row, false) end;
					local NameLbl = self:CreateInstance("TextLabel", {
						Parent = Row; Position = UDim2.new(0, ShowCheck and 17 or 0, 0, 0);
						Size = UDim2.new(1, ShowCheck and -17 or 0, 1, 0); BackgroundTransparency = 1;
						TextSize = 12; TextTruncate = Enum.TextTruncate.AtEnd;
						TextXAlignment = Enum.TextXAlignment.Left; TextYAlignment = Enum.TextYAlignment.Center;
					});
					if ProggyCleanFont then NameLbl.FontFace = ProggyCleanFont end;
					Row.MouseButton1Click:Connect(function()
						local CurrentMode = string.lower(Read(Entry.GetMode, Entry.Mode or "toggle"));
						if CurrentMode ~= "toggle" then return end;
						if Entry.Toggle then pcall(Entry.Toggle)
						elseif Entry.SetState then pcall(Entry.SetState, not Read(Entry.GetState, false)) end;
					end);
					Row.MouseEnter:Connect(function()
						local CurrentMode = string.lower(Read(Entry.GetMode, Entry.Mode or "toggle"));
						if CurrentMode == "toggle" then NameLbl.TextTransparency = 0 end;
					end);
					Row.MouseLeave:Connect(function()
						local CurrentState = Read(Entry.GetState, false) == true;
						NameLbl.TextTransparency = CurrentState and 0 or 0.45;
					end);
					Data = { Row = Row, Label = NameLbl, Box = Box, Fill = Fill, ShowCheck = ShowCheck };
					Rows[Entry] = Data;
				end;
				Data.Row.LayoutOrder = I;
				Data.Label.Text = string.format("[%s] %s (%s)", KeyName(Key), tostring(Entry.Name or "?"), ModeTitle(Mode));
				Data.Label.TextColor3 = State and Color3.fromHex("FFFFFF") or Color3.fromHex("BFC4CC");
				Data.Label.TextTransparency = (State or Mode == "always") and 0 or 0.45;
				if Data.Fill then
					Data.Fill.Size = State and UDim2.new(1, -4, 1, -4) or UDim2.fromOffset(0, 0);
					Data.Fill.BackgroundTransparency = State and 0 or 1;
				end;
			end;
		end;
		for Entry, Data in Rows do
			if not Seen[Entry] then Data.Row:Destroy(); Rows[Entry] = nil end;
		end;
		EmptyLbl.Visible = Opts.ShowEmpty == true and Count == 0;
		if Obj.SettingsOpen then RebuildSettings() end;
	end;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame = {"BackgroundTransparency"}; TextLabel = {"BackgroundTransparency", "TextTransparency"};
			TextButton = {"BackgroundTransparency", "TextTransparency"}; UIStroke = {"Transparency"};
			UIShadow = {"Transparency"}; ImageLabel = {"BackgroundTransparency", "ImageTransparency"};
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, Prop in Props do
				local Ok, Value = pcall(function() return Inst[Prop] end);
				if Ok then PMap[Prop] = Value end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Frame);
		for _, D in Frame:GetDescendants() do Cap(D) end;
		return Map;
	end;
	function Obj:Refresh()
		Rebuild();
		if not ActiveFade then FadeOriginals = CaptureFade() end;
	end;
	function Obj:SetTitle(NewTitle) TitleLbl.Text = tostring(NewTitle) end;
	function Obj:SetCollapsed(Collapsed)
		self.Collapsed = Collapsed == true;
		Entries.Visible = not self.Collapsed;
		CollapseBtn.Text = self.Collapsed and "+" or "-";
		if self.Collapsed then
			Frame.AutomaticSize = Enum.AutomaticSize.None;
			Frame.Size = UDim2.new(0, Width, 0, 30);
		else
			Frame.AutomaticSize = Enum.AutomaticSize.Y;
			Frame.Size = UDim2.new(0, Width, 0, 0);
		end;
		task.defer(PositionSettings);
	end;
	function Obj:ToggleCollapsed() self:SetCollapsed(not self.Collapsed) end;
	function Obj:SetSettingsOpen(Open)
		Open = Open == true;
		if Open and not self.VisibilityControl then return end;
		self.SettingsOpen = Open;
		SettingsFrame.Visible = Open;
		if Open then RebuildSettings() end;
		task.defer(PositionSettings);
	end;
	function Obj:ToggleSettings() self:SetSettingsOpen(not self.SettingsOpen) end;
	function Obj:SetVisibilityControl(Enabled)
		self.VisibilityControl = Enabled == true;
		SettingsBtn.Visible = self.VisibilityControl;
		if not self.VisibilityControl then self:SetSettingsOpen(false) end;
	end;
	function Obj:SetToggleStateVisible(Visible)
		ShowToggleState = Visible == true;
		self:Refresh();
	end;
	function Obj:SetPosition(Position) Frame.Position = Position; task.defer(PositionSettings) end;
	function Obj:SetVisible(State)
		State = State and true or false;
		if self.Destroyed then return end;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if not State then self:SetSettingsOpen(false) end;
		if Library._ReduceAnimations then
			if not FadeOriginals then FadeOriginals = CaptureFade() end;
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State;
			return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function() ActiveFade = nil end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then Gui.Enabled = false end;
				ActiveFade = nil;
			end);
		end;
	end;
	function Obj:Toggle() self:SetVisible(not self._Visible) end;
	function Obj:GetVisible() return self._Visible end;
	function Obj:Destroy()
		if self.Destroyed then return end;
		self.Destroyed = true;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if RemoveListener then RemoveListener(); RemoveListener = nil end;
		Gui:Destroy();
		if Library._KeybindList == self then Library._KeybindList = nil end;
		if Library.KeybindMenu == self then Library.KeybindMenu = nil end;
		if Library.KeybindFrame == Frame then Library.KeybindFrame = nil end;
		if Library.KeybindContainer == Entries then Library.KeybindContainer = nil end;
		local Index = table.find(Library._SatelliteWindows or {}, self);
		if Index then table.remove(Library._SatelliteWindows, Index) end;
	end;
	SettingsBtn.MouseButton1Click:Connect(function() Obj:ToggleSettings() end);
	CollapseBtn.MouseButton1Click:Connect(function() Obj:ToggleCollapsed() end);
	CloseSettings.MouseButton1Click:Connect(function() Obj:SetSettingsOpen(false) end);
	Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() if Obj.SettingsOpen then PositionSettings() end end);
	Library:_MakeSatelliteBindable(Obj);
	Library._KeybindList = Obj;
	Library.KeybindMenu = Obj;
	Library.KeybindFrame = Frame;
	Library.KeybindContainer = Entries;
	Obj:SetVisibilityControl(Opts.VisibilityControl == true);
	Obj:SetCollapsed(Opts.Collapsed == true);
	Rebuild();
	FadeOriginals = CaptureFade();
	if not Obj._Visible then
		Library:_SnapFadeGroup(FadeOriginals, "out");
		Gui.Enabled = false;
	end;
	RemoveListener = Library:OnKeybindChange(function() Obj:Refresh() end);
	return Obj;
end;
function Library:Watermark(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Text = tostring(Opts.Text or Opts.Title or "XoneScriptK");
	local Gui = self:CreateInstance("ScreenGui", {
		Name = "Watermark";
		Parent = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local Frame = self:CreateInstance("Frame", {
		Name             = "Watermark";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(0, 0);
		Position         = UDim2.fromOffset(10, 110);
		Size             = UDim2.new(0, 0, 0, 24);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Frame;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});
	local Gray = self:CreateInstance("Frame", {
		Name             = "Gray";
		Parent           = Frame;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIPadding", {
		Parent        = Gray;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});
	local GradRing = self:CreateInstance("Frame", {
		Name             = "GradientRing";
		Parent           = Gray;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	local RingGradient = self:CreateInstance("UIGradient", {
		Parent   = GradRing;
		Rotation = 0;
	});
	Library:RegisterAccentGradient(RingGradient);
	self:CreateInstance("UIPadding", {
		Parent        = GradRing;
		PaddingLeft   = UDim.new(0, 1);
		PaddingRight  = UDim.new(0, 1);
		PaddingTop    = UDim.new(0, 1);
		PaddingBottom = UDim.new(0, 1);
	});
	local Inside = self:CreateInstance("Frame", {
		Name             = "Inside";
		Parent           = GradRing;
		Size             = UDim2.new(0, 0, 1, 0);
		AutomaticSize    = Enum.AutomaticSize.X;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Inside;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
			NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
		});
	});
	self:CreateInstance("UIPadding", {
		Parent       = Inside;
		PaddingLeft  = UDim.new(0, 8);
		PaddingRight = UDim.new(0, 10);
	});
local Logo = self:CreateInstance("ImageLabel", {
	Name = "Logo";
	Parent = Inside;
	Size = UDim2.fromOffset(24, 24);
	AnchorPoint = Vector2.new(0, 0.3);
	Position = UDim2.new(0, -7, 0.32, 0);
	BackgroundTransparency = 1;
});
	local WmLogoOpt = Opts.Logo;
	if WmLogoOpt == nil then WmLogoOpt = Opts.Icon end;
	if WmLogoOpt == nil then WmLogoOpt = self._CustomLogo end;
	local WmHideLogo = (WmLogoOpt == false);
	if not WmHideLogo then
		local WmLogoAsset = self._ResolveLogo and self:_ResolveLogo(WmLogoOpt) or nil;
		if WmLogoAsset then
			Logo.Image = WmLogoAsset;
			table.insert(self._LogoInstances or {}, Logo);
		else
			WmHideLogo = true;
		end;
	end;
	Logo.Visible = not WmHideLogo;
	local Lbl = self:CreateInstance("TextLabel", {
		Name                   = "Label";
		Parent                 = Inside;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 22, 0.5, 0);
		Size                   = UDim2.new(0, 0, 1, 0);
		AutomaticSize          = Enum.AutomaticSize.X;
		BackgroundTransparency = 1;
		Text                   = Text;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
	if WmHideLogo then Lbl.Position = UDim2.new(0, 0, 0.5, 0) end;
	self:Draggable(Frame);
	local Obj = { Gui = Gui, Frame = Frame, Label = Lbl };
	function Obj:SetText(NewText)
		Lbl.Text = tostring(NewText);
	end;
	function Obj:Destroy()
		Gui:Destroy();
	end;
	Library._Watermark = Obj;
	return Obj;
end;
Library._NotifyPosition = "TopRight";
function Library:_ApplyNotifyPosition()
	local Stack = self._NotifyStack;
	if not Stack then return end;
	local Right = self._NotifyPosition == "TopRight";
	Stack.AnchorPoint = Right and Vector2.new(1, 0) or Vector2.new(0, 0);
	Stack.Position    = Right and UDim2.new(1, -10, 0, 10) or UDim2.new(0, 10, 0, 10);
	local Layout = Stack:FindFirstChildOfClass("UIListLayout");
	if Layout then
		Layout.HorizontalAlignment = Right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left;
	end;
end;
function Library:SetNotifyPosition(Pos)
	Pos = tostring(Pos or "");
	if Pos == "Top Left" or Pos == "TopLeft" or Pos == "Left" or Pos == "左上角" then
		self._NotifyPosition = "TopLeft";
	else
		self._NotifyPosition = "TopRight";
	end;
	self:_ApplyNotifyPosition();
end;
function Library:Notify(Text, Time, Color)
    Text = tostring(Text or "");
    Time = tonumber(Time) or 3;
    Color = Color or Library.Accent or Color3.fromHex("FFFFFF");
    if not self._NotifyStack then
        local Gui = self:CreateInstance("ScreenGui", {
            Name           = "Notifications";
            Parent         = (gethui and gethui()) or CoreGui;
            IgnoreGuiInset = true;
            ResetOnSpawn   = false;
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        });
        local Stack = self:CreateInstance("Frame", {
            Name                   = "Stack";
            Parent                 = Gui;
            AnchorPoint            = Vector2.new(0, 0);
            Position               = UDim2.new(0, 10, 0, 200);
            Size                   = UDim2.new(0, 200, 1, -210);
            BackgroundTransparency = 1;
            BorderSizePixel        = 0;
        });
        self:CreateInstance("UIListLayout", {
            Parent              = Stack;
            FillDirection       = Enum.FillDirection.Vertical;
            SortOrder           = Enum.SortOrder.LayoutOrder;
            VerticalAlignment   = Enum.VerticalAlignment.Top;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            Padding             = UDim.new(0, 6);
        });
        self._NotifyGui   = Gui;
        self._NotifyStack = Stack;
        self._NotifyOrder = 0;
        self:_ApplyNotifyPosition();
    end;
    self._NotifyOrder = self._NotifyOrder + 1;
    local SlideX = (self._NotifyPosition == "TopRight") and 60 or -60;
    local Wrapper = self:CreateInstance("Frame", {
        Name                   = "NotifWrapper";
        Parent                 = self._NotifyStack;
        Size                   = UDim2.new(0, 0, 0, 0);
        AutomaticSize          = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        BorderSizePixel        = 0;
        LayoutOrder            = self._NotifyOrder;
        ClipsDescendants       = false;
    });
    local Outer = self:CreateInstance("CanvasGroup", {
        Name              = "Notification";
        Parent            = Wrapper;
        AnchorPoint       = Vector2.new(0, 0);
        Position          = UDim2.new(0, SlideX, 0, 0);
        Size              = UDim2.new(0, 0, 0, 0);
        AutomaticSize     = Enum.AutomaticSize.XY;
        BackgroundColor3  = Color3.fromHex("000000");
        BorderSizePixel   = 0;
        GroupTransparency = 1;
    });
    self:CreateInstance("UIPadding", {
        Parent        = Outer;
        PaddingBottom = UDim.new(0, 2);
    });
    local Inline = self:CreateInstance("Frame", {
        Name             = "Inline";
        Parent           = Outer;
        Position         = UDim2.new(0, 1, 0, 1);
        Size             = UDim2.new(1, -2, 1, 0);
        BackgroundColor3 = Color3.fromHex("393939");
        BorderSizePixel  = 0;
    });
    self:CreateInstance("UIPadding", {
        Parent        = Inline;
        PaddingBottom = UDim.new(0, 2);
    });
    local Background = self:CreateInstance("Frame", {
        Name             = "Background";
        Parent           = Inline;
        Position         = UDim2.new(0, 1, 0, 1);
        Size             = UDim2.new(1, -2, 1, 0);
        BackgroundColor3 = Color3.fromHex("FFFFFF");
        BorderSizePixel  = 0;
    });
    self:CreateInstance("UIGradient", {
        Parent   = Background;
        Rotation = 90;
        Color    = NewColorSequence({
            NewColorSequenceKeypoint(0, Color3.fromHex("262626"));
            NewColorSequenceKeypoint(1, Color3.fromHex("191919"));
        });
    });
    local Title = self:CreateInstance("TextLabel", {
        Name                   = "Title";
        Parent                 = Background;
        Position               = UDim2.new(0, 4, 0, 4);
        Size                   = UDim2.new(0, 0, 0, 0);
        AutomaticSize          = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
        BorderSizePixel        = 0;
        Text                   = Text;
        TextColor3             = Color3.fromHex("A0A0A0");
        TextSize               = 12;
        TextXAlignment         = Enum.TextXAlignment.Left;
        TextYAlignment         = Enum.TextYAlignment.Top;
        RichText               = true;
    });
    if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;
    self:CreateInstance("UIStroke", {
        Parent          = Title;
        Color           = Color3.fromHex("000000");
        Thickness       = 1;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
        LineJoinMode    = Enum.LineJoinMode.Miter;
    });
    self:CreateInstance("UIPadding", {
        Parent        = Title;
        PaddingRight  = UDim.new(0, 7);
        PaddingBottom = UDim.new(0, 3);
    });
    local Liner = self:CreateInstance("Frame", {
        Name             = "Liner";
        Parent           = Outer;
        Position         = UDim2.new(0, 2, 0, 2);
        Size             = UDim2.new(0, 2, 1, -4);
        BackgroundColor3 = Color;
        BorderSizePixel  = 0;
        ZIndex           = 2;
    });
    local DurationLiner = self:CreateInstance("Frame", {
        Name             = "DurationLiner";
        Parent           = Outer;
        Position         = UDim2.new(0, 2, 1, -1);
        Size             = UDim2.new(1, -4, 0, 1);
        BackgroundColor3 = Color;
        BorderSizePixel  = 0;
        ZIndex           = 3;
    });
    local InInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local OutInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
    task.defer(function()
        if not (Wrapper.Parent and Outer.Parent) then return end;
        local W = Outer.AbsoluteSize.X;
        if W and W > 0 then
            Wrapper.AutomaticSize    = Enum.AutomaticSize.Y;
            Wrapper.Size             = UDim2.new(0, W, 0, 0);
            Wrapper.ClipsDescendants = true;
        end;
        Outer.Position = UDim2.new(0, SlideX, 0, 0);
        TweenService:Create(Outer, InInfo, {
            Position          = UDim2.new(0, 0, 0, 0);
            GroupTransparency = 0;
        }):Play();
    end);
    task.spawn(function()
        task.wait(0.1);
        local TargetWidth = Outer.AbsoluteSize.X - 4;
        if TargetWidth > 0 then
            TweenService:Create(DurationLiner, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 0, 1);
            }):Play();
        end
    end);
    task.delay(Time, function()
        if not Wrapper.Parent then return end;
        TweenService:Create(Outer, OutInfo, {
            Position          = UDim2.new(0, SlideX, 0, 0);
            GroupTransparency = 1;
        }):Play();
        task.delay(OutInfo.Time, function()
            if Wrapper and Wrapper.Parent then Wrapper:Destroy() end;
        end);
    end);
    return Wrapper;
end;
function Library:Playerlist(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Title = tostring(Opts.Title or "Playerlist");
	local Width = tonumber(Opts.Width) or 240;
	local Height = tonumber(Opts.Height) or 400;
	Width, Height = ClampWindowSize(Width, Height);
	local MobilePos = nil;
	if IsMobilePlatform then
		local Cam = workspace.CurrentCamera;
		local Vp  = (Cam and Cam.ViewportSize) or Vector2.new(800, 600);
		Width  = math.min(Width,  math.max(math.floor(Vp.X) - 24, 160));
		Height = math.min(Height, math.max(math.floor(Vp.Y) - 90, 160));
		MobilePos = UDim2.new(1, -8, 0, 38);
	end;
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "PlayerlistGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local Outer = self:CreateInstance("Frame", {
		Name             = "Outer";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(1, 0);
		Position         = MobilePos or UDim2.fromOffset(0, 0);
		Size             = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	Library:AddGlowingV2(Outer,Library.Accent,0.4)
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local TitleLbl = self:CreateInstance("TextLabel", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 9);
		Size                   = UDim2.new(0, 200, 0, 18);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	local Content = self:CreateInstance("Frame", {
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 34);
		Size             = UDim2.new(1, -10, 1, -50);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local function ContentEdge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge(Vector2.new(0,0), UDim2.new(0,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(0,0), UDim2.new(0,1,0,1),   UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,-1,0,1),  UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,0,1,0),   UDim2.new(1,0,0,1),   "000000");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,1,1,-1),  UDim2.new(1,-2,0,1),  "393939");
	local SearchBox = self:CreateInstance("Frame", {
		Parent           = Outer;
		AnchorPoint      = Vector2.new(0, 1);
		Position         = UDim2.new(0, 5, 1, -5);
		Size             = UDim2.new(1, -10, 0, 21);
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("Frame", {
		Parent           = SearchBox;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	local SearchBoxInside = self:CreateInstance("Frame", {
		Parent           = SearchBox:FindFirstChildOfClass("Frame");
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = SearchBoxInside;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
			NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
		});
	});
	local SearchInput = self:CreateInstance("TextBox", {
		Parent            = SearchBoxInside;
		Position          = UDim2.new(0, 4, 0, 0);
		Size              = UDim2.new(1, -8, 1, 0);
		BackgroundTransparency = 1;
		BorderSizePixel   = 0;
		ClearTextOnFocus  = false;
		Text              = "";
		PlaceholderText   = "Type here...";
		PlaceholderColor3 = Color3.fromHex("5E626B");
		TextColor3        = Color3.fromHex("FFFFFF");
		TextSize          = 12;
		TextXAlignment    = Enum.TextXAlignment.Left;
		TextYAlignment    = Enum.TextYAlignment.Center;
		ClipsDescendants  = true;
	});
	if ProggyCleanFont then SearchInput.FontFace = ProggyCleanFont end;
	local PlayerListScroll = self:CreateInstance("ScrollingFrame", {
		Parent               = Content;
		Position             = UDim2.new(0, 2, 0, 2);
		Size                 = UDim2.new(1, -4, 1, -4);
		BackgroundTransparency = 1;
		BorderSizePixel      = 0;
		CanvasSize           = UDim2.new(0, 0, 0, 0);
		AutomaticCanvasSize  = Enum.AutomaticSize.Y;
		ScrollBarThickness   = 2;
		ScrollBarImageColor3 = Library.Accent;
		ScrollingDirection   = Enum.ScrollingDirection.Y;
		ClipsDescendants     = true;
	});
	Library:RegisterAccent(PlayerListScroll, "ScrollBarImageColor3");
	Library:_AttachScrollbar(PlayerListScroll);
	self:CreateInstance("UIListLayout", {
		Parent        = PlayerListScroll;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 1);
	});
	self:CreateInstance("UIPadding", {
		Parent   = PlayerListScroll;
		PaddingTop = UDim.new(0, 2);
		PaddingBottom = UDim.new(0, 12);
	});
	self:Draggable(Outer);
	local LP          = game:GetService("Players").LocalPlayer;
	local Players     = game:GetService("Players");
	local PlayerStates = {};
	local RowRefs     = {};
	if not getgenv().friendlys or type(getgenv().friendlys) ~= "table" then
		getgenv().friendlys = {};
	end;
	if not getgenv().prioritys or type(getgenv().prioritys) ~= "table" then
		getgenv().prioritys = {};
	end;
	local function IsInTable(tbl, playerName)
		if not tbl or type(tbl) ~= "table" then return false end;
		for _, name in pairs(tbl) do
			if type(name) == "string" and name:lower() == playerName:lower() then
				return true;
			end;
		end;
		return false;
	end;
	local function RemoveFromTable(tbl, playerName)
		if not tbl or type(tbl) ~= "table" then return end;
		for i = #tbl, 1, -1 do
			if type(tbl[i]) == "string" and tbl[i]:lower() == playerName:lower() then
				table.remove(tbl, i);
			end;
		end;
	end;
	local function AddToTable(tbl, playerName)
		if not tbl or type(tbl) ~= "table" then return end;
		if not IsInTable(tbl, playerName) then
			table.insert(tbl, playerName);
		end;
	end;
	local function GetStateFromTables(Player)
		if IsInTable(getgenv().friendlys, Player.Name) then
			return "Friendly";
		elseif IsInTable(getgenv().prioritys, Player.Name) then
			return "Priority";
		end;
		return "Neutral";
	end;
	local function UpdatePlayerState(Player, NewState)
		RemoveFromTable(getgenv().friendlys, Player.Name);
		RemoveFromTable(getgenv().prioritys, Player.Name);
		if NewState == "Friendly" then
			AddToTable(getgenv().friendlys, Player.Name);
		elseif NewState == "Priority" then
			AddToTable(getgenv().prioritys, Player.Name);
		end;
		PlayerStates[Player] = NewState;
	end;
	local function GetStateColor(Player, State)
		if Player == LP then return Library.Accent end;
		if State == "Friendly" then return Color3.fromRGB(0, 200, 0) end;
		if State == "Priority" then return Color3.fromRGB(210, 0, 0) end;
		return Color3.fromHex("A0A0A0");
	end;
	local function GetStateText(Player, State)
		if Player == LP then return "LocalPlayer" end;
		return State or "Neutral";
	end;
	local function IsModerator(Player)
		local moderators = getgenv().moderators;
		if not moderators or type(moderators) ~= "table" then return false end;
		for _, modName in pairs(moderators) do
			if type(modName) == "string" and modName:lower() == Player.Name:lower() then
				return true;
			end;
		end;
		return false;
	end;
	local function BuildRow(Player, Idx)
		local State = GetStateFromTables(Player);
		PlayerStates[Player] = State;
		local IsMod = IsModerator(Player);
		local Row = self:CreateInstance("Frame", {
			Name             = "Row_" .. Player.Name;
			Parent           = PlayerListScroll;
			Size             = UDim2.new(1, 0, 0, 20);
			BackgroundColor3 = Color3.fromHex("1E1E1E");
			BackgroundTransparency = 1;
			BorderSizePixel  = 0;
			LayoutOrder      = Idx;
		});
		self:CreateInstance("Frame", {
			Parent           = Row;
			AnchorPoint      = Vector2.new(0, 1);
			Position         = UDim2.new(0, 0, 1, 0);
			Size             = UDim2.new(1, 0, 0, 1);
			BackgroundColor3 = Color3.fromHex("222222");
			BorderSizePixel  = 0;
			ZIndex           = 2;
		});
		local Btn = self:CreateInstance("TextButton", {
			Parent                 = Row;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			AutoButtonColor        = false;
			Text                   = "";
			ZIndex                 = 4;
		});
		local NameLbl = self:CreateInstance("TextLabel", {
			Parent                 = Row;
			AnchorPoint            = Vector2.new(0, 0.5);
			Position               = UDim2.new(0, 4, 0.5, 0);
			Size                   = UDim2.new(0.45, 0, 1, 0);
			BackgroundTransparency = 1;
			Text                   = Player.Name;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			TextTruncate           = Enum.TextTruncate.AtEnd;
			ZIndex                 = 5;
		});
		if ProggyCleanFont then NameLbl.FontFace = ProggyCleanFont end;
		local ModLbl = self:CreateInstance("TextLabel", {
			Name                   = "ModLbl";
			Parent                 = Row;
			AnchorPoint            = Vector2.new(0, 0.5);
			Position               = UDim2.new(0.45, 4, 0.5, 0);
			Size                   = UDim2.new(0.10, 0, 1, 0);
			BackgroundTransparency = 1;
			Text                   = "";
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			ZIndex                 = 5;
		});
		if ProggyCleanFont then ModLbl.FontFace = ProggyCleanFont end;
		if IsMod then
			ModLbl.RichText = true;
			ModLbl.Text = '[<font color="#' .. Library.Accent:ToHex() .. '">M</font>]';
		end;
		local StateLbl = self:CreateInstance("TextLabel", {
			Name                   = "StateLbl";
			Parent                 = Row;
			AnchorPoint            = Vector2.new(1, 0.5);
			Position               = UDim2.new(1, -4, 0.5, 0);
			Size                   = UDim2.new(0.45, 0, 1, 0);
			BackgroundTransparency = 1;
			Text                   = GetStateText(Player, State);
			TextColor3             = GetStateColor(Player, State);
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Right;
			TextYAlignment         = Enum.TextYAlignment.Center;
			ZIndex                 = 5;
		});
		if ProggyCleanFont then StateLbl.FontFace = ProggyCleanFont end;
		Btn.MouseEnter:Connect(function()
			TweenService:Create(Row, TweenInfo.new(0.1), { BackgroundTransparency = 0.7 }):Play();
		end);
		Btn.MouseLeave:Connect(function()
			TweenService:Create(Row, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play();
		end);
		if Player ~= LP then
			Btn.MouseButton1Click:Connect(function()
				local Cur = GetStateFromTables(Player);
				local Next = Cur == "Neutral" and "Friendly" or Cur == "Friendly" and "Priority" or "Neutral";
				UpdatePlayerState(Player, Next);
				TweenService:Create(Row, TweenInfo.new(0.08), { BackgroundTransparency = 0.25 }):Play();
				task.delay(0.1, function()
					TweenService:Create(Row, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play();
				end);
				StateLbl.Text       = GetStateText(Player, Next);
				StateLbl.TextColor3 = GetStateColor(Player, Next);
			end);
		end;
		return Row;
	end;
	local function RefreshPlayerList()
		for _, Ref in RowRefs do
			if Ref and Ref.Parent then Ref:Destroy() end;
		end;
		table.clear(RowRefs);
		local SearchText = string.lower(SearchInput.Text);
		local Idx = 0;
		if LP and (SearchText == "" or string.find(string.lower(LP.Name), SearchText, 1, true)) then
			table.insert(RowRefs, BuildRow(LP, Idx));
			Idx += 1;
		end;
		for _, Player in Players:GetPlayers() do
			if Player ~= LP then
				if SearchText == "" or string.find(string.lower(Player.Name), SearchText, 1, true) then
					table.insert(RowRefs, BuildRow(Player, Idx));
					Idx += 1;
				end;
			end;
		end;
	end;
	RefreshPlayerList();
	Players.PlayerAdded:Connect(function() RefreshPlayerList() end);
	Players.PlayerRemoving:Connect(function(Player)
		RemoveFromTable(getgenv().friendlys, Player.Name);
		RemoveFromTable(getgenv().prioritys, Player.Name);
		RefreshPlayerList();
	end);
	SearchInput:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList);
	local FadeOriginals = nil;
	local ActiveFade = nil;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame = {"BackgroundTransparency"};
			TextLabel = {"BackgroundTransparency","TextTransparency"};
			TextButton = {"BackgroundTransparency","TextTransparency"};
			TextBox = {"BackgroundTransparency","TextTransparency"};
			ScrollingFrame = {"BackgroundTransparency"};
			UIStroke = {"Transparency"};
			UIShadow = {"Transparency"};
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, P in Props do
				local Ok, V = pcall(function() return Inst[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Outer);
		for _, D in Outer:GetDescendants() do Cap(D) end;
		return Map;
	end;
	local Obj = { Gui = Gui, Outer = Outer, _Visible = true };
	function Obj:SetVisible(State)
		State = State and true or false;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				ActiveFade = nil;
			end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then Gui.Enabled = false end;
				ActiveFade = nil;
			end);
		end;
	end;
	Library:_MakeSatelliteBindable(Obj);
	function Obj:PositionNextTo(Window)
		local WinOuter = Window.Outer;
		if not WinOuter then return end;
		local function UpdatePos()
			local WinPos  = WinOuter.AbsolutePosition;
			local WinSize = WinOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(1, 0);
			Outer.Position = UDim2.fromOffset(WinPos.X - 2, WinPos.Y + GuiInset);
		end;
		task.defer(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	function Obj:PositionBelow(OtherObj)
		local OtherOuter = OtherObj.Outer;
		if not OtherOuter then return end;
		local function UpdatePos()
			local P = OtherOuter.AbsolutePosition;
			local S = OtherOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(0, 0);
			Outer.Position = UDim2.fromOffset(P.X, P.Y + S.Y + 2 + GuiInset);
		end;
		task.defer(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	function Obj:Refresh() RefreshPlayerList() end;
	function Obj:Destroy() Gui:Destroy() end;
	Library:_AutoBindSatellite(Obj, Opts, "Players");
	Library._Playerlist = Obj;
	return Obj;
end;
ApplySettingsContents = function(self)
		local ConfigDir    = Library.Directory .. "/Configs";
		local ThemeDir     = Library.Directory .. "/Themes";
		local AutoLoadFile = Library.Directory .. "/Autoload.txt";
		local function ListConfigs()
			local Out = {};
			if isfolder and isfolder(ConfigDir) then
				for _, F in listfiles(ConfigDir) do
					if string.find(F, "%.json$") then
						local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
						if not string.match(string.lower(Nm), "^autoload") then
							table.insert(Out, Nm);
						end;
					end;
				end;
			end;
			if #Out == 0 then table.insert(Out, "default") end;
			return Out;
		end;
		local function ListThemes()
			local Out = {};
			if isfolder and isfolder(ThemeDir) then
				for _, F in listfiles(ThemeDir) do
					if string.find(F, "%.json$") then
						local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
						table.insert(Out, Nm);
					end;
				end;
			end;
			if #Out == 0 then table.insert(Out, "default") end;
			return Out;
		end;
		local ConfigList, ThemeList;
		local function ActionSaveConfig(Nm)
			Nm = Nm or Library.Flags.ConfigName;
			if not Nm or Nm == "" then Library:Notify("Enter a config name first", 3); return false end;
			Library:SaveConfig(Nm);
			ConfigList:SetOptions(ListConfigs());
			Library:Notify("Saved config: " .. Nm, 3);
			return true;
		end;
		local function ActionLoadConfig(Nm)
			Nm = Nm or ConfigList:Get();
			local Ok, Err = Library:LoadConfig(Nm);
			if Ok then Library:Notify("Loaded: " .. Nm, 3) else Library:Notify(Err, 3) end;
			return Ok;
		end;
		local function ActionDeleteConfig(Nm)
			Nm = Nm or ConfigList:Get();
			local Path = ConfigDir .. "/" .. Nm .. ".json";
			if isfile and isfile(Path) then delfile(Path) end;
			ConfigList:SetOptions(ListConfigs());
			Library:Notify("Deleted: " .. Nm, 3);
		end;
		local function ActionRefreshConfigs()
			ConfigList:SetOptions(ListConfigs());
			Library:Notify("Refreshed configs", 2);
		end;
		local function ActionSetAutoLoad(Nm)
			Nm = Nm or ConfigList:Get();
			writefile(AutoLoadFile, Nm);
			Library:Notify("Auto-load: " .. Nm, 3);
		end;
		local function ActionClearAutoLoad()
			if isfile and isfile(AutoLoadFile) then writefile(AutoLoadFile, "") end;
			Library:Notify("Auto-load cleared", 3);
		end;
		local function ActionSaveTheme(Nm)
			Nm = Nm or Library.Flags.ThemeName;
			if not Nm or Nm == "" then Library:Notify("Enter a theme name", 3); return false end;
			writefile(ThemeDir .. "/" .. Nm .. ".json", HttpService:JSONEncode({ Accent = Library.Accent:ToHex() }));
			ThemeList:SetOptions(ListThemes());
			Library:Notify("Saved theme: " .. Nm, 3);
			return true;
		end;
		local function ActionLoadTheme(Nm)
			Nm = Nm or ThemeList:Get();
			local Path = ThemeDir .. "/" .. Nm .. ".json";
			if not (isfile and isfile(Path)) then Library:Notify("Theme not found", 3); return false end;
			local Ok, Data = pcall(HttpService.JSONDecode, HttpService, readfile(Path));
			if Ok and Data.Accent then
				Library:SetAccent(Color3.fromHex(Data.Accent));
				Library:Notify("Loaded theme: " .. Nm, 3);
				return true;
			end;
			return false;
		end;
		local function ActionDeleteTheme(Nm)
			Nm = Nm or ThemeList:Get();
			local Path = ThemeDir .. "/" .. Nm .. ".json";
			if isfile and isfile(Path) then delfile(Path) end;
			ThemeList:SetOptions(ListThemes());
			Library:Notify("Deleted theme: " .. Nm, 3);
		end;
		local function ActionRefreshThemes()
			ThemeList:SetOptions(ListThemes());
			Library:Notify("Refreshed themes", 2);
		end;
		local SecCfg = self:Section({ Name = "Configuration", Side = "Left" });
		ConfigList = SecCfg:List({
			Name    = "Configs";
			Options = ListConfigs();
			Default = "default";
			Height  = 90;
		});
		SecCfg:Textbox({ Name = "Config Name", Flag = "ConfigName", Placeholder = "name..." });
		SecCfg:Button({
			Name = "Save";
			Callback = function() ActionSaveConfig() end;
		}):Button({
			Name = "Load";
			Callback = function() ActionLoadConfig() end;
		});
		SecCfg:Button({
			Name = "Delete"; Confirm = true;
			Callback = function() ActionDeleteConfig() end;
		}):Button({
			Name = "Refresh";
			Callback = function() ActionRefreshConfigs() end;
		});
		SecCfg:Button({
			Name = "Set As Auto Load";
			Callback = function() ActionSetAutoLoad() end;
		});
		SecCfg:Button({
			Name = "Remove Auto Load"; Confirm = true;
			Callback = function() ActionClearAutoLoad() end;
		});
		SecCfg:Button({
			Name = "Test Notification";
			Callback = function()
				Library:Notify('Hello there', 4);
			end;
		});
		local SecMenu = self:Section({ Name = "Menu", Side = "Left" });
		SecMenu:Dropdown({
			Name    = "Tab Style"; Flag = "TabStyle";
			Options = { "Sidebar", "Native" };
			Default = "Sidebar";
			Callback = function(V) Library:SetTabStyle(V) end;
		});
		SecMenu:Dropdown({
			Name    = "Notification Position"; Flag = "NotifyPosition";
			Options = { "Top Right", "Top Left" };
			Default = "Top Right";
			Callback = function(V) Library:SetNotifyPosition(V) end;
		});
		SecMenu:Dropdown({
			Name    = "Easing Style"; Flag = "MenuEaseStyle";
			Options = { "Linear", "Cubic", "Quad", "Quart", "Quint", "Sine", "Exponential", "Circular", "Back", "Elastic", "Bounce" };
			Default = "Quint";
			Callback = function(V) Library.EasingStyle = Enum.EasingStyle[V] end;
		});
		SecMenu:Dropdown({
			Name = "Easing Direction"; Flag = "MenuEaseDir";
			Options = { "In", "Out", "InOut" };
			Default = "Out";
			Callback = function(V) Library.EasingDirection = Enum.EasingDirection[V] end;
		});
		Library.EasingStyle     = Enum.EasingStyle.Quint;
		Library.EasingDirection = Enum.EasingDirection.Out;
		SecMenu:Slider({
			Name = "Tweening Speed"; Flag = "TweeningSpeed";
			Min = 0.05, Max = 2, Step = 0.05, Decimals = 2, Default = 1;
			Callback = function(V) Library.AnimationSpeed = V end;
		});
		local UIScaleSlider = SecMenu:Slider({
			Name = "UI Scale"; Flag = "MobileUIScale";
			Min = 50; Max = 300; Step = 5; Decimals = 0; Suffix = "%";
			Default = math.clamp(math.floor((Library._UIScaleValue or 1) * 100 + 0.5), 50, 300);
			Tooltip = "Scales the whole menu (LinoriaLib SetDPIScale equivalent); default 100% = native size, same as LinoriaLib";
			Callback = function(V) Library:SetDPIScale(V) end;
		});
		SecMenu:Button({
			Name = "Auto UI Scale";
			Tooltip = "Fit the menu to the screen automatically";
			Callback = function()
				Library:SetAutoUIScale();
				Library:Notify("UI scale: auto", 2);
			end;
		});
		local LiteToggle = SecMenu:Toggle({
			Name = "Lite Animations"; Flag = "MobileLiteAnim";
			Default = Library._ReduceAnimations == true;
			Tooltip = "Disables heavy animations; recommended on phones";
			Callback = function(S) Library:SetReduceAnimations(S) end;
		});
		local MenuBtnToggle = nil;
		if IsMobilePlatform then
			MenuBtnToggle = SecMenu:Toggle({
				Name = "Floating Menu Button"; Flag = "MobileMenuBtn";
				Default = Library.MobileMenuButton ~= nil;
				Tooltip = "Shows the on-screen Toggle UI / Lock UI buttons";
				Callback = function(S)
					if S then
						local B = Library.CreateMobileMenuButton and Library:CreateMobileMenuButton();
						if B then B:Show() end;
					elseif Library.MobileMenuButton then
						Library.MobileMenuButton:Hide();
					end;
				end;
			});
		end;
		local MenuKeybindRow = SecMenu:Keybind({
			Name     = "Menu Keybind";
			Default  = Enum.KeyCode.RightShift;
			Mode     = "Always";
			Callback  = function() end;
			OnChanged = function(K) Library.MenuKeybind = K end;
		});
		SecMenu:Button({
			Name = "Unload"; Confirm = true;
			Tooltip = "Destroy the whole UI (Library:Unload)";
			Callback = function() Library:Unload() end;
		});
		local SecHud = self:Section({ Name = "HUD", Side = "Right" });
		local WatermarkToggle = SecHud:Toggle({
			Name     = "Watermark", Default = true;
			Callback = function(S) if Library._Watermark then Library._Watermark.Gui.Enabled = S end end;
		});
		SecHud:Dropdown({
			Name    = "Watermark Options";
			Multi   = true;
			Flag    = "WatermarkOpts";
			Options = { "Title", "Fps", "Ping", "Game Name", "User ID", "LocalPlayer Name", "Date" };
			Default = { "Title", "Fps", "Ping","Game Name","Date" };
		});
		SecHud:Slider({ Name = "Refresh Rate", Flag = "WatermarkRate", Min = 0, Max = 2, Step = 0.05, Decimals = 2, Default = 0.1 });
		local KeybindListToggle = SecHud:Toggle({
			Name     = "Keybind List", Default = true;
			Callback = function(S) if Library._KeybindList then Library._KeybindList:SetVisible(S) end end;
		});
		do
			local LP = game:GetService("Players").LocalPlayer;
			local Fps, FpsAcc, FpsCnt = 60, 0, 0;
			Library:Connection(RunService.RenderStepped, function(Dt)
				FpsCnt = FpsCnt + 1; FpsAcc = FpsAcc + Dt;
				if FpsAcc >= 0.5 then
					Fps = math.round(FpsCnt / FpsAcc);
					FpsCnt, FpsAcc = 0, 0;
				end;
			end);
			local GameName = "Roblox";
			task.spawn(function()
				local Ok, Info = pcall(game.GetService(game, "MarketplaceService").GetProductInfo, game:GetService("MarketplaceService"), game.PlaceId);
				if Ok and Info and Info.Name then GameName = Info.Name end;
			end);
			local Acc = 0;
			Library:Connection(RunService.Heartbeat, function(Dt)
				local W = Library._Watermark;
				if not (W and W.Gui and W.Gui.Enabled) then return end;
				local Rate = Library.Flags.WatermarkRate or 0.1;
				Acc = Acc + Dt;
				if Acc < Rate then return end;
				Acc = 0;
				local Opts = Library.Flags.WatermarkOpts or {};
				local Parts = {};
				if Opts.Title              then table.insert(Parts, "XoneScriptK") end;
				if Opts.Fps                then table.insert(Parts, Fps .. " fps") end;
				if Opts.Ping and LP        then table.insert(Parts, math.round(LP:GetNetworkPing() * 1000) .. " ms") end;
				if Opts["Game Name"]       then table.insert(Parts, GameName) end;
				if Opts["User ID"] and LP  then table.insert(Parts, tostring(LP.UserId)) end;
				if Opts["LocalPlayer Name"] and LP then table.insert(Parts, LP.Name) end;
				if Opts.Date               then table.insert(Parts, os.date("%H:%M:%S")) end;
				if #Parts > 0 then
					local Body   = table.concat(Parts, " | ");
					local Prefix = Library.Flags.MenuPrefix or "";
					local Suffix = Library.Flags.MenuSuffix or "";
					if Prefix ~= "" then Body = Prefix .. " " .. Body end;
					if Suffix ~= "" then Body = Body   .. " " .. Suffix end;
					W:SetText(Body);
				end;
			end);
		end;
		local SecTheme = self:Section({ Name = "Theming", Side = "Right" });
		local AccentPicker = SecTheme:Colorpicker({
			Name     = "Accent"; Flag = "Accent";
			Default  = Library.Accent;
			Alpha    = 1;
			Callback = function(C) Library:SetAccent(C) end;
		});
		SecTheme:Textbox({ Name = "Theme Name", Flag = "ThemeName", Placeholder = "theme name..." });
		ThemeList = SecTheme:List({
			Name    = "Themes";
			Options = ListThemes();
			Default = "default";
			Height  = 80;
		});
		SecTheme:Button({
			Name = "Save";
			Callback = function() ActionSaveTheme() end;
		}):Button({
			Name = "Load";
			Callback = function() ActionLoadTheme() end;
		});
		SecTheme:Button({
			Name = "Delete"; Confirm = true;
			Callback = function() ActionDeleteTheme() end;
		}):Button({
			Name = "Refresh";
			Callback = function() ActionRefreshThemes() end;
		});
		task.delay(0.5, function()
			if not (isfile and isfile(AutoLoadFile) and readfile) then return end;
			local Nm = tostring(readfile(AutoLoadFile) or ""):gsub("%s+$", "");
			if Nm == "" then return end;
			if Library:LoadConfig(Nm) then
				Library:Notify("Auto-loaded config: " .. Nm, 3);
			end;
		end);
		local Controls = {
			Sections = {
				Configuration = SecCfg;
				Menu          = SecMenu;
				HUD           = SecHud;
				Theming       = SecTheme;
			};
			ConfigList = ConfigList;
			ThemeList  = ThemeList;
			Watermark       = WatermarkToggle;
			KeybindList     = KeybindListToggle;
			UIScale         = UIScaleSlider;
			LiteAnimations  = LiteToggle;
			MenuKeybind     = MenuKeybindRow;
			Accent          = AccentPicker;
			FloatingButton  = MenuBtnToggle;
			SaveConfig      = ActionSaveConfig;
			LoadConfig      = ActionLoadConfig;
			DeleteConfig    = ActionDeleteConfig;
			RefreshConfigs  = ActionRefreshConfigs;
			SetAutoLoad     = ActionSetAutoLoad;
			ClearAutoLoad   = ActionClearAutoLoad;
			SaveTheme       = ActionSaveTheme;
			LoadTheme       = ActionLoadTheme;
			DeleteTheme     = ActionDeleteTheme;
			RefreshThemes   = ActionRefreshThemes;
			Unload = function() Library:Unload() end;
		};
		return Controls;
end;
function Library:SettingsTab(Window, Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	Window = Window or Opts.Window or Library.CurrentlyOpen;
	assert(Window and Window.Tab, "SettingsTab/SettingsWindow: no window to attach to — create a Library:Window(...) first (or pass Window = win)");
	local Tab = (Opts.Tab and Opts.Tab.Section) and Opts.Tab
		or Window:Tab({ Name = tostring(Opts.TabName or Opts.Name or Opts.Title or "Settings") });
	local Obj = { _Tab = Tab, _Window = Window, _Visible = true, Gui = nil, Outer = nil, Controls = nil };
	function Obj:Section(SecOpts)
		return Tab:Section(SecOpts);
	end;
	function Obj:ApplySettings()
		self.Controls = ApplySettingsContents(self);
		Tab.SettingsControls = self.Controls;
		Library._SettingsTab = Tab;
		return self;
	end;
	function Obj:SetVisible(State)
		self._Visible = State and true or false;
		if State then
			for _, T in ipairs(Window._Tabs or {}) do
				if T ~= Tab and T.Active then T:SetActive(false) end;
			end;
			Tab:SetActive(true);
		end;
	end;
	function Obj:SyncWithWindow(_) end;
	function Obj:PositionNextTo(_) end;
	function Obj:Destroy()
		if Tab.Button then Tab.Button:Destroy() end;
		if Tab.Page then Tab.Page:Destroy() end;
	end;
	Library._SettingsWindow = Obj;
	return Obj;
end;
function Library:SettingsWindow(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	return Library:SettingsTab(Opts.Window or Library.CurrentlyOpen, Opts);
end;
function Library:GetSettings()
	return Library._SettingsWindow or Library._SettingsTab;
end;
function Library:_BuildPreview(Parent, Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Height = tonumber(Opts.Height) or 260;
	local Settings = {
		Enabled        = Opts.Enabled == true;
		Box            = false;
		BoxColorHigh   = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		BoxColorLow    = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		Fill           = false;
		FillColorHigh  = { Color = Color3.fromRGB(255, 255, 255), Alpha = 0.5 };
		FillColorLow   = { Color = Color3.fromRGB(255, 255, 255), Alpha = 0.5 };
		Glow           = false;
		GlowColorHigh  = { Color = Color3.fromRGB(255, 255, 255), Alpha = 0.5 };
		GlowColorLow   = { Color = Color3.fromRGB(255, 255, 255), Alpha = 0.5 };
		Healthbar      = false;
		HealthbarText  = false;
		HealthHigh     = { Color = Color3.fromRGB(38, 255, 0),  Alpha = 1 };
		HealthMid      = { Color = Color3.fromRGB(255, 179, 0), Alpha = 1 };
		HealthLow      = { Color = Color3.fromRGB(255, 0, 0),   Alpha = 1 };
		Name           = false;
		NameColor      = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		Distance       = false;
		DistanceColor  = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		Weapon         = false;
		WeaponColor    = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		Flags          = false;
		FlagsColor     = { Color = Color3.fromRGB(255, 255, 255), Alpha = 1 };
		BoxRotation    = 90;
		FillRotation   = 90;
		GlowRotation   = 90;
		AutoRotate     = true;
		RotationSpeed  = 0.01;
		ZoomMultiplier = 2;
		BoxType        = "Normal";
		BoxThickness   = 1;
		OutlineEnabled = false;
		OutlineColor   = { Color = Color3.fromRGB(0, 0, 0), Alpha = 0.5 };
		FillColorMid   = { Color = Color3.fromRGB(255, 255, 255), Alpha = 0.5 };
		Skeleton       = false;
		Chams          = false;
		ChamsColor     = { Color = Color3.fromRGB(59, 144, 204), Alpha = 0.4 };
	};
	local Container = Library:CreateInstance("Frame", {
		Name             = "Preview";
		Parent           = Parent;
		Size             = Opts.Size or UDim2.new(1, 0, 0, Height);
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	local BoxGray = Library:CreateInstance("Frame", {
		Parent = Container; Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
	});
	local BoxInside = Library:CreateInstance("Frame", {
		Parent = BoxGray; Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
	});
	Library:CreateInstance("UIGradient", {
		Parent = BoxInside; Rotation = 90;
		Color = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local Area = Library:CreateInstance("TextButton", {
		Name                   = "Area";
		Parent                 = BoxInside;
		Size                   = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		AutoButtonColor        = false;
		Text                   = "";
		ClipsDescendants       = true;
	});
	local Viewport = Library:CreateInstance("ViewportFrame", {
		Name                   = "Viewport";
		Parent                 = Area;
		AnchorPoint            = Vector2.new(0.5, 0.5);
		Position               = UDim2.new(0.5, 0, 0.5, 0);
		Size                   = UDim2.new(0, Height, 0, Height);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	local ChamsFrame = Library:CreateInstance("Frame", {
		Name                   = "ChamsFrame";
		Parent                 = Area;
		AnchorPoint            = Vector2.new(0.5, 0.5);
		Position               = UDim2.new(0.5, 0, 0.5, 0);
		Size                   = UDim2.new(0, Height, 0, Height);
		BackgroundColor3       = Color3.fromRGB(59, 144, 204);
		BackgroundTransparency = 0.6;
		BorderSizePixel        = 0;
		Visible                = false;
		ZIndex                 = 1;
	});
	Library:CreateInstance("UICorner", { Parent = ChamsFrame; CornerRadius = UDim.new(0.05, 0) });
	local Esp = Library:CreateInstance("Frame", {
		Name                   = "Esp";
		Parent                 = Area;
		AnchorPoint            = Vector2.new(0.5, 0);
		Size                   = UDim2.new(0, 150, 0, 250);
		BackgroundColor3       = Color3.fromRGB(255, 255, 255);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Visible                = false;
		ZIndex                 = 2;
	});
	local FillGradient = Library:CreateInstance("UIGradient", {
		Parent       = Esp;
		Rotation     = 90;
		Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 1);
			NewNumberSequenceKeypoint(1, 0);
		});
	});
	local BoxOutline = Library:CreateInstance("UIStroke", {
		Parent       = Esp;
		Thickness    = 3;
		Color        = Color3.fromHex("000000");
		LineJoinMode = Enum.LineJoinMode.Miter;
		Transparency = 0.5;
		Enabled      = false;
	});
	local BoxAccent = Library:CreateInstance("UIStroke", {
		Parent       = Esp;
		Thickness    = 1;
		Color        = Color3.fromRGB(255, 255, 255);
		LineJoinMode = Enum.LineJoinMode.Miter;
		Enabled      = false;
	});
	local BoxGradient = Library:CreateInstance("UIGradient", { Parent = BoxAccent; Rotation = 90 });
	local BoxCircleCorner = Library:CreateInstance("UICorner", {
		Parent       = Esp;
		CornerRadius = UDim.new(0, 0);
	});
	local CornerFrames = {};
	for i = 1, 8 do
		local cf = Library:CreateInstance("Frame", {
			Parent           = Esp;
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BorderSizePixel  = 0;
			Visible          = false;
			ZIndex           = 3;
		});
		Library:CreateInstance("UIStroke", {
			Parent       = cf;
			Thickness    = 1;
			Color        = Color3.fromRGB(0, 0, 0);
			Transparency = 0.5;
			LineJoinMode = Enum.LineJoinMode.Miter;
			Enabled      = false;
		});
		CornerFrames[i] = cf;
	end;
	local Glow = Library:CreateInstance("ImageLabel", {
		Name                   = "Glow";
		Parent                 = Esp;
		Position               = UDim2.new(0, -23, 0, -23);
		Size                   = UDim2.new(1, 45, 1, 45);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Image                  = "rbxassetid://18245826428";
		ImageColor3            = Color3.fromRGB(255, 255, 255);
		ImageTransparency      = 0.8;
		ScaleType              = Enum.ScaleType.Slice;
		SliceCenter            = Rect.new(Vector2.new(21, 21), Vector2.new(80, 80));
		Visible                = false;
	});
	local GlowGradient = Library:CreateInstance("UIGradient", { Parent = Glow; Rotation = 90 });
	local Healthbar = Library:CreateInstance("Frame", {
		Name                   = "Healthbar";
		Parent                 = Esp;
		AnchorPoint            = Vector2.new(1, 0);
		Position               = UDim2.new(0, -4, 0, -2);
		Size                   = UDim2.new(0, 4, 1, 4);
		BackgroundColor3       = Color3.fromRGB(0, 0, 0);
		BackgroundTransparency = 0.5;
		BorderSizePixel        = 0;
		Visible                = false;
		ZIndex                 = 2;
	});
	local HealthAccent = Library:CreateInstance("Frame", {
		Parent           = Healthbar;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		BorderSizePixel  = 0;
		ZIndex           = 2;
	});
	local HealthGradient = Library:CreateInstance("UIGradient", {
		Parent   = HealthAccent;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0,   Settings.HealthHigh.Color);
			NewColorSequenceKeypoint(0.5, Settings.HealthMid.Color);
			NewColorSequenceKeypoint(1,   Settings.HealthLow.Color);
		});
	});
	local HealthFade = Library:CreateInstance("Frame", {
		Parent           = Healthbar;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 0);
		BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		BorderSizePixel  = 0;
		ZIndex           = 3;
	});
	local HealthText = Library:CreateInstance("TextLabel", {
		Name                   = "HealthText";
		Parent                 = Healthbar;
		AnchorPoint            = Vector2.new(1, 0.5);
		Position               = UDim2.new(0, -2, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.XY;
		BackgroundTransparency = 1;
		Text                   = "100";
		TextColor3             = Color3.fromRGB(0, 255, 0);
		TextSize               = 12;
		Visible                = false;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIStroke", { Parent = HealthText; LineJoinMode = Enum.LineJoinMode.Miter; Transparency = 0.5 });
	local NameLbl = Library:CreateInstance("TextLabel", {
		Name                   = "Name";
		Parent                 = Esp;
		AnchorPoint            = Vector2.new(0.5, 1);
		Position               = UDim2.new(0.5, 0, 0, -4);
		AutomaticSize          = Enum.AutomaticSize.XY;
		BackgroundTransparency = 1;
		Text                   = "Player";
		TextColor3             = Color3.fromRGB(255, 255, 255);
		TextSize               = 12;
		Visible                = false;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIStroke", { Parent = NameLbl; LineJoinMode = Enum.LineJoinMode.Miter; Transparency = 0.5 });
	local BottomHolder = Library:CreateInstance("Frame", {
		Name                   = "Bottom";
		Parent                 = Esp;
		Position               = UDim2.new(0, -2, 1, 4);
		Size                   = UDim2.new(1, 4, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIListLayout", {
		Parent    = BottomHolder;
		Padding   = UDim.new(0, 1);
		SortOrder = Enum.SortOrder.LayoutOrder;
	});
	local DistLbl = Library:CreateInstance("TextLabel", {
		Name                   = "Distance";
		Parent                 = BottomHolder;
		Size                   = UDim2.new(1, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		Text                   = "0st";
		TextColor3             = Color3.fromRGB(255, 255, 255);
		TextSize               = 12;
		Visible                = false;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIStroke", { Parent = DistLbl; LineJoinMode = Enum.LineJoinMode.Miter; Transparency = 0.5 });
	local WeaponLbl = Library:CreateInstance("TextLabel", {
		Name                   = "Weapon";
		Parent                 = BottomHolder;
		Size                   = UDim2.new(1, 0, 0, 0);
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		Text                   = "none";
		TextColor3             = Color3.fromRGB(255, 255, 255);
		TextSize               = 12;
		Visible                = false;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIStroke", { Parent = WeaponLbl; LineJoinMode = Enum.LineJoinMode.Miter; Transparency = 0.5 });
	local FlagsLbl = Library:CreateInstance("TextLabel", {
		Name                   = "Flags";
		Parent                 = Esp;
		Position               = UDim2.new(1, 4, 0, -2);
		AutomaticSize          = Enum.AutomaticSize.XY;
		BackgroundTransparency = 1;
		Text                   = "Flags";
		TextColor3             = Color3.fromRGB(255, 255, 255);
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		Visible                = false;
		ZIndex                 = 2;
	});
	Library:CreateInstance("UIStroke", { Parent = FlagsLbl; LineJoinMode = Enum.LineJoinMode.Miter; Transparency = 0.5 });
	if ProggyCleanFont then
		for _, L in { HealthText, NameLbl, DistLbl, WeaponLbl, FlagsLbl } do
			L.FontFace = ProggyCleanFont;
		end;
	end;
	local function UpdateCorners()
		local t          = Settings.BoxThickness;
		local col        = Settings.BoxColorHigh.Color;
		local vis        = Settings.Box and (Settings.BoxType == "Corner");
		local outEnabled = Settings.OutlineEnabled;
		local outColor   = Settings.OutlineColor.Color;
		local cornerData = {
			{ UDim2.new(0,    0,  0,    0), UDim2.new(0.25, 0, 0,    t) },
			{ UDim2.new(0,    0,  0,    0), UDim2.new(0,    t, 0.25, 0) },
			{ UDim2.new(0.75, 0,  0,    0), UDim2.new(0.25, 0, 0,    t) },
			{ UDim2.new(1,   -t,  0,    0), UDim2.new(0,    t, 0.25, 0) },
			{ UDim2.new(0,    0,  1,   -t), UDim2.new(0.25, 0, 0,    t) },
			{ UDim2.new(0,    0,  0.75, 0), UDim2.new(0,    t, 0.25, 0) },
			{ UDim2.new(0.75, 0,  1,   -t), UDim2.new(0.25, 0, 0,    t) },
			{ UDim2.new(1,   -t,  0.75, 0), UDim2.new(0,    t, 0.25, 0) },
		};
		for i, cf in CornerFrames do
			cf.Position         = cornerData[i][1];
			cf.Size             = cornerData[i][2];
			cf.BackgroundColor3 = col;
			cf.Visible          = vis;
			local stroke = cf:FindFirstChildOfClass("UIStroke");
			if stroke then
				stroke.Color   = outColor;
				stroke.Enabled = outEnabled;
			end;
		end;
		BoxCircleCorner.CornerRadius = (Settings.BoxType == "Circle")
			and UDim.new(0.5, 0) or UDim.new(0, 0);
	end;
	local function Render()
		local isCorner = Settings.BoxType == "Corner";
		local isCircle = Settings.BoxType == "Circle";
		local isNormal = not isCorner and not isCircle;
		BoxOutline.Enabled         = Settings.Box and isNormal and Settings.OutlineEnabled;
		BoxAccent.Enabled          = Settings.Box and (isNormal or isCircle);
		BoxAccent.Thickness        = Settings.BoxThickness;
		Esp.BackgroundTransparency = Settings.Fill and 0 or 1;
		Glow.Visible               = Settings.Glow;
		Healthbar.Visible          = Settings.Healthbar;
		HealthText.Visible         = Settings.HealthbarText;
		NameLbl.Visible            = Settings.Name;
		DistLbl.Visible            = Settings.Distance;
		WeaponLbl.Visible          = Settings.Weapon;
		FlagsLbl.Visible           = Settings.Flags;
		NameLbl.TextColor3   = Settings.NameColor.Color;
		DistLbl.TextColor3   = Settings.DistanceColor.Color;
		WeaponLbl.TextColor3 = Settings.WeaponColor.Color;
		FlagsLbl.TextColor3  = Settings.FlagsColor.Color;
		FillGradient.Color = NewColorSequence({
			NewColorSequenceKeypoint(0,   Settings.FillColorHigh.Color);
			NewColorSequenceKeypoint(0.5, Settings.FillColorMid.Color);
			NewColorSequenceKeypoint(1,   Settings.FillColorLow.Color);
		});
		FillGradient.Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0,   1 - Settings.FillColorHigh.Alpha);
			NewNumberSequenceKeypoint(0.5, 1 - Settings.FillColorMid.Alpha);
			NewNumberSequenceKeypoint(1,   1 - Settings.FillColorLow.Alpha);
		});
		BoxGradient.Color = NewColorSequence({
			NewColorSequenceKeypoint(0, Settings.BoxColorHigh.Color);
			NewColorSequenceKeypoint(1, Settings.BoxColorLow.Color);
		});
		GlowGradient.Color = NewColorSequence({
			NewColorSequenceKeypoint(0, Settings.GlowColorHigh.Color);
			NewColorSequenceKeypoint(1, Settings.GlowColorLow.Color);
		});
		GlowGradient.Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 1 - Settings.GlowColorHigh.Alpha);
			NewNumberSequenceKeypoint(1, 1 - Settings.GlowColorLow.Alpha);
		});
		HealthGradient.Color = NewColorSequence({
			NewColorSequenceKeypoint(0,   Settings.HealthHigh.Color);
			NewColorSequenceKeypoint(0.5, Settings.HealthMid.Color);
			NewColorSequenceKeypoint(1,   Settings.HealthLow.Color);
		});
		ChamsFrame.Visible                = Settings.Chams;
		ChamsFrame.BackgroundColor3       = Settings.ChamsColor.Color;
		ChamsFrame.BackgroundTransparency = 1 - Settings.ChamsColor.Alpha;
		FillGradient.Rotation = Settings.FillRotation;
		BoxGradient.Rotation  = Settings.BoxRotation;
		GlowGradient.Rotation = Settings.GlowRotation;
		UpdateCorners();
		if not Settings.Enabled then Esp.Visible = false end;
	end;
	Render();
	local ViewportCamera, Model, OriginalModel;
	local RotationX, RotationY = 0, 0;
	local Distance = 10;
	local Dragging = false;
	local Hovering = false;
	local LastPos  = Vector3.zero;
	local function StopViewing()
		ViewportCamera = nil;
		Model = nil;
		Viewport:ClearAllChildren();
	end;
	local function ViewModel(Item)
		if not Item then return end;
		StopViewing();
		if Item:IsA("Model") then
			Item.Archivable = true;
			if #Item:GetChildren() == 0 then return end;
			Model = Item:Clone();
			Model.Parent = Viewport;
			if not Model.PrimaryPart then
				local Found = false;
				for _, Child in Model:GetDescendants() do
					if Child:IsA("BasePart") then
						Model.PrimaryPart = Child;
						Found = true;
						break;
					end;
				end;
				if not Found then Model:Destroy(); Model = nil; return end;
			end;
		elseif Item:IsA("BasePart") then
			Model = Instance.new("Model");
			Model.Parent = Viewport;
			local Clone = Item:Clone();
			Clone.Parent = Model;
			Clone.CFrame = CFrame.new();
			Model.PrimaryPart = Clone;
		else
			return;
		end;
		OriginalModel = Item;
		ViewportCamera = Library:CreateInstance("Camera", { Parent = Viewport; FieldOfView = 60 });
		Viewport.CurrentCamera = ViewportCamera;
	end;
	local function BoxSolve(Root)
		local UpVec    = Root.CFrame.UpVector;
		local RootPos  = Root.Position;
		local CamCF    = ViewportCamera.CFrame;
		local WorldTop    = RootPos + (UpVec * 1.8) + CamCF.UpVector;
		local WorldBottom = RootPos - (UpVec * 2.5) - CamCF.UpVector;
		local Dist = (RootPos - CamCF.Position).Magnitude;
		local HolderSize = Viewport.AbsoluteSize;
		local Top = ViewportCamera:WorldToScreenPoint(WorldTop);
		Top = Vector2.new(Top.X * HolderSize.X, Top.Y * HolderSize.Y);
		local Bottom = ViewportCamera:WorldToScreenPoint(WorldBottom);
		Bottom = Vector2.new(Bottom.X * HolderSize.X, Bottom.Y * HolderSize.Y);
		local Width   = math.max(math.floor(math.abs(Top.X - Bottom.X)), 9);
		local BoxH    = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 12);
		local BoxSize = Vector2.new(math.floor(math.max(BoxH / 1.5, Width)), BoxH);
		local BoxPos  = Vector2.new(
			math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5),
			math.floor(math.min(Top.Y, Bottom.Y))
		);
		return BoxSize, BoxPos, math.floor(Dist * 0.333);
	end;
	local function ChangeHealth()
		local Value = math.abs(math.sin(tick()));
		local Eased = TweenService:GetValue(Value, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut);
		HealthFade.Size = UDim2.new(1, -2, 1 - Eased, 0);
		local C = Settings.HealthLow.Color:Lerp(Settings.HealthMid.Color, Eased):Lerp(Settings.HealthHigh.Color, Eased);
		HealthText.TextColor3 = C;
		HealthText.Text       = tostring(math.floor(Eased * 100 + 0.5));
		HealthText.Position   = UDim2.new(0, -2, 1 - Eased, 0);
	end;
	Area.MouseEnter:Connect(function() Hovering = true end);
	Area.MouseLeave:Connect(function() Hovering = false end);
	Library:Connection(Area.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true;
			LastPos = Input.Position;
		end;
	end);
	Library:Connection(Area.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false;
		end;
	end);
	Library:Connection(UserInputService.InputChanged, function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			local Delta = Input.Position - LastPos;
			LastPos = Input.Position;
			RotationY = RotationY - Delta.X * 0.01;
			RotationX = math.clamp(RotationX - Delta.Y * 0.01, -math.pi / 2 + 0.1, math.pi / 2 - 0.1);
		elseif Hovering and Input.UserInputType == Enum.UserInputType.MouseWheel then
			local Mult = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 10 or Settings.ZoomMultiplier;
			Distance = math.clamp(Distance - Input.Position.Z * Mult, 1, 100);
		end;
	end);
	Library:Connection(RunService.RenderStepped, function()
		if not (ViewportCamera and Model) then return end;
		if not Library:IsEffectivelyVisible(Area) then return end;
		if not Dragging and Settings.AutoRotate then
			RotationY = RotationY + Settings.RotationSpeed;
		end;
		local Root = Model.PrimaryPart or Model:FindFirstChild("HumanoidRootPart");
		if not Root then return end;
		local Center   = Root.Position;
		local Rotation = CFrame.Angles(0, RotationY, 0) * CFrame.Angles(RotationX, 0, 0);
		local CamCF    = CFrame.new(Center) * Rotation * CFrame.new(0, 0, Distance);
		ViewportCamera.CFrame = CFrame.lookAt(CamCF.Position, Center + Vector3.new(0, -1, 0));
		if Settings.Enabled then
			local BoxSize, BoxPos, Dist = BoxSolve(Root);
			Esp.Visible  = true;
			Esp.Position = UDim2.new(0.5, 0, 0, BoxPos.Y);
			Esp.Size     = UDim2.fromOffset(BoxSize.X, BoxSize.Y);
			DistLbl.Text = Dist .. "st";
			ChangeHealth();
		else
			Esp.Visible = false;
		end;
	end);
	task.defer(function()
		if OriginalModel then return end;
		local LP = game:GetService("Players").LocalPlayer;
		local Char = LP and (LP.Character or LP.CharacterAdded:Wait());
		if Char and not OriginalModel then ViewModel(Char) end;
	end);
	if Opts.Tooltip then Library:Tooltip(Container, Opts.Tooltip) end;
	if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
		Opts.Dependency:OnChange(function(S) Container.Visible = S end);
	end;
	local Obj = { Container = Container, Viewport = Viewport, Settings = Settings };
	function Obj:Get(Key) return Settings[Key] end;
	function Obj:Set(Key, Value, Alpha)
		local Cur = Settings[Key];
		if Cur == nil then return end;
		if typeof(Cur) == "table" and typeof(Value) == "Color3" then
			Cur.Color = Value;
			if Alpha ~= nil then Cur.Alpha = math.clamp(tonumber(Alpha) or 1, 0, 1) end;
		else
			Settings[Key] = Value;
		end;
		Render();
	end;
	function Obj:Update() Render() end;
	function Obj:SetText(Which, Text)
		local Map = { Name = NameLbl, Distance = DistLbl, Weapon = WeaponLbl, Flags = FlagsLbl };
		local L = Map[tostring(Which)];
		if L then L.Text = tostring(Text) end;
	end;
	function Obj:SyncFromESP(cfg)
		if type(cfg) ~= "table" then return end;
		Settings.Enabled      = cfg.Enabled == true;
		Settings.Box          = cfg.Boxes == true;
		local bc              = cfg.BoxColor or Color3.fromRGB(255, 255, 255);
		Settings.BoxColorHigh = { Color = bc, Alpha = 1 };
		Settings.BoxColorLow  = { Color = bc, Alpha = 1 };
		Settings.BoxType      = tostring(cfg.BoxType or "Normal");
		Settings.BoxThickness = tonumber(cfg.BoxThickness) or 1;
		local ol              = cfg.Outlines or {};
		Settings.OutlineEnabled = ol.Style ~= "None";
		Settings.OutlineColor   = { Color = ol.Color or Color3.fromRGB(0, 0, 0), Alpha = 1 };
		local bf = cfg.BoxFill or {};
		Settings.Fill = bf.Enabled == true;
		local bfg    = bf.Gradient or {};
		local fa     = 1 - (tonumber(bf.Transparency) or 0.9);
		if bfg.Enabled then
			Settings.FillColorHigh = { Color = bfg.Color1 or Color3.fromRGB(255, 255, 255), Alpha = fa };
			Settings.FillColorMid  = { Color = bfg.Color2 or Color3.fromRGB(255, 255, 255), Alpha = fa };
			Settings.FillColorLow  = { Color = bfg.Color3 or Color3.fromRGB(255, 255, 255), Alpha = fa };
		else
			local fc = bf.Color or Color3.fromRGB(255, 255, 255);
			Settings.FillColorHigh = { Color = fc, Alpha = fa };
			Settings.FillColorMid  = { Color = fc, Alpha = fa };
			Settings.FillColorLow  = { Color = fc, Alpha = fa };
		end;
		local hb  = cfg.HealthBar or {};
		Settings.Healthbar     = hb.Enabled == true;
		Settings.HealthbarText = hb.ShowText == true;
		local hbg = hb.Gradient or {};
		Settings.HealthHigh = { Color = hbg.Color1 or Color3.fromRGB(0, 255, 0),   Alpha = 1 };
		Settings.HealthMid  = { Color = hbg.Color2 or Color3.fromRGB(255, 255, 0), Alpha = 1 };
		Settings.HealthLow  = { Color = hbg.Color3 or Color3.fromRGB(255, 0, 0),   Alpha = 1 };
		Settings.Name        = cfg.Names == true;
		Settings.NameColor   = { Color = cfg.TextColor or Color3.fromRGB(255, 255, 255), Alpha = 1 };
		local dist = cfg.Distance or {};
		Settings.Distance      = dist.Enabled == true;
		Settings.DistanceColor = { Color = dist.Color or Color3.fromRGB(255, 255, 255), Alpha = 1 };
		local wep = cfg.Weapon or {};
		Settings.Weapon      = wep.Enabled == true;
		Settings.WeaponColor = { Color = wep.Color or Color3.fromRGB(255, 255, 255), Alpha = 1 };
		local flags = cfg.Flags or {};
		Settings.Flags = flags.Enabled == true;
		local skel = cfg.Skeleton or {};
		Settings.Skeleton = skel.Enabled == true;
		local chams = cfg.Chams or {};
		Settings.Chams = chams.Enabled == true;
		local mc = chams.MeshChams or {};
		Settings.ChamsColor = { Color = mc.FillColor or Color3.fromRGB(59, 144, 204), Alpha = 1 - (mc.FillTransparency or 0.6) };
		Render();
	end;
	function Obj:ViewModel(M) ViewModel(M) end;
	function Obj:Refresh() if OriginalModel then ViewModel(OriginalModel) end end;
	return Obj;
end;
function Library:SetESP(ESPModule)
	self._ESPModule = ESPModule;
end;
function Library:GetESP()
	return self._ESPModule;
end;
function Library:PreviewWindow(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Title  = tostring(Opts.Title or "Preview");
	local Width  = tonumber(Opts.Width) or 240;
	local Height = tonumber(Opts.Height) or 320;
	Width, Height = ClampWindowSize(Width, Height);
	local MobilePos = nil;
	if IsMobilePlatform then
		local Cam = workspace.CurrentCamera;
		local Vp  = (Cam and Cam.ViewportSize) or Vector2.new(800, 600);
		Width  = math.min(Width,  math.max(math.floor(Vp.X) - 24, 160));
		Height = math.min(Height, math.max(math.floor(Vp.Y) - 90, 160));
		MobilePos = UDim2.new(1, -(Width + 8), 0, 38);
	end;
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "PreviewGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local Outer = self:CreateInstance("Frame", {
		Name             = "Outer";
		Parent           = Gui;
		Position         = MobilePos or UDim2.fromOffset(0, 0);
		Size             = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	Library:AddGlowingV2(Outer, Library.Accent, 0.4);
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local TitleLbl = self:CreateInstance("TextLabel", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 9);
		Size                   = UDim2.new(0, 200, 0, 18);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	self:Draggable(Outer);
	local Core = self:_BuildPreview(Outer, {
		Height  = Height;
		Size    = UDim2.new(1, -10, 1, -39);
		Enabled = Opts.Enabled;
	});
	Core.Container.Position = UDim2.new(0, 5, 0, 34);
	local FadeOriginals = nil;
	local ActiveFade = nil;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame = {"BackgroundTransparency"};
			TextLabel = {"BackgroundTransparency","TextTransparency"};
			TextButton = {"BackgroundTransparency","TextTransparency"};
			ImageLabel = {"BackgroundTransparency","ImageTransparency"};
			ViewportFrame = {"ImageTransparency"};
			UIStroke = {"Transparency"};
			UIShadow = {"Transparency"};
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, P in Props do
				local Ok, V = pcall(function() return Inst[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Outer);
		for _, D in Outer:GetDescendants() do Cap(D) end;
		return Map;
	end;
	local Obj = { Gui = Gui, Outer = Outer, Preview = Core, _Visible = true };
	function Obj:SetVisible(State)
		State = State and true or false;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				ActiveFade = nil;
			end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then Gui.Enabled = false end;
				ActiveFade = nil;
			end);
		end;
	end;
	Library:_MakeSatelliteBindable(Obj);
	function Obj:PositionNextTo(Window)
		local WinOuter = Window.Outer;
		if not WinOuter then return end;
		local function UpdatePos()
			local WinPos  = WinOuter.AbsolutePosition;
			local WinSize = WinOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(0, 0);
			Outer.Position = UDim2.fromOffset(WinPos.X + WinSize.X + 2, WinPos.Y + GuiInset);
		end;
		task.defer(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	Library:_AutoBindSatellite(Obj, Opts, "Visual");
	function Obj:Get(...) return Core:Get(...) end;
	function Obj:Set(...) return Core:Set(...) end;
	function Obj:Update(...) return Core:Update(...) end;
	function Obj:SetText(...) return Core:SetText(...) end;
	function Obj:ViewModel(...) return Core:ViewModel(...) end;
	function Obj:Refresh(...) return Core:Refresh(...) end;
	function Obj:SyncFromESP(...) return Core:SyncFromESP(...) end;
	function Obj:Destroy() Gui:Destroy() end;
	Library._PreviewWindow = Obj;
	return Obj;
end;
function Library:LogWindow(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Title  = tostring(Opts.Title or "Output");
	local Width  = tonumber(Opts.Width) or 240;
	local Height = tonumber(Opts.Height) or 200;
	local LogColors = {
		[0] = Color3.fromHex("A0A0A0");
		[1] = Color3.fromHex("5B9BD5");
		[2] = Color3.fromHex("E6A817");
		[3] = Color3.fromHex("D94F4F");
		[4] = Color3.fromHex("4EC94E");
	};
	local LogLabels = {
		[0] = "OUTPUT";
		[1] = "INFO";
		[2] = "WARN";
		[3] = "ERROR";
		[4] = "SUCCESS";
	};
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "LogWindowGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local SatPos = UDim2.fromOffset(0, 0);
	if IsMobilePlatform then SatPos = UDim2.new(1, -8, 0, 38) end;
	local Outer = self:CreateInstance("Frame", {
		Name             = "Outer";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(1, 0);
		Position         = SatPos;
		Size             = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	Library:AddGlowingV2(Outer,Library.Accent,0.4)
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local TitleLbl = self:CreateInstance("TextLabel", {
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 9);
		Size                   = UDim2.new(0, 200, 0, 18);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	local Content = self:CreateInstance("Frame", {
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 34);
		Size             = UDim2.new(1, -10, 1, -50);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local function ContentEdge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge(Vector2.new(0,0), UDim2.new(0,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(0,0), UDim2.new(0,1,0,1),   UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,-1,0,1),  UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,0,1,0),   UDim2.new(1,0,0,1),   "000000");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,1,1,-1),  UDim2.new(1,-2,0,1),  "393939");
	local LogScroll = self:CreateInstance("ScrollingFrame", {
		Parent               = Content;
		Position             = UDim2.new(0, 2, 0, 2);
		Size                 = UDim2.new(1, -4, 1, -4);
		BackgroundTransparency = 1;
		BorderSizePixel      = 0;
		CanvasSize           = UDim2.new(0, 0, 0, 0);
		AutomaticCanvasSize  = Enum.AutomaticSize.Y;
		ScrollBarThickness   = 2;
		ScrollBarImageColor3 = Library.Accent;
		ScrollingDirection   = Enum.ScrollingDirection.Y;
		ClipsDescendants     = true;
	});
	Library:RegisterAccent(LogScroll, "ScrollBarImageColor3");
	Library:_AttachScrollbar(LogScroll);
	self:CreateInstance("UIListLayout", {
		Parent        = LogScroll;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 1);
	});
	self:CreateInstance("UIPadding", {
		Parent     = LogScroll;
		PaddingTop = UDim.new(0, 2);
		PaddingLeft = UDim.new(0, 2);
		PaddingRight = UDim.new(0, 2);
	});
	local ClearBtn = self:CreateInstance("Frame", {
		Parent           = Outer;
		AnchorPoint      = Vector2.new(0, 1);
		Position         = UDim2.new(0, 5, 1, -5);
		Size             = UDim2.new(1, -10, 0, 21);
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("Frame", {
		Parent           = ClearBtn;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	local ClearInside = self:CreateInstance("Frame", {
		Parent           = ClearBtn:FindFirstChildOfClass("Frame");
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = ClearInside;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
			NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
		});
	});
	local ClearBtnClick = self:CreateInstance("TextButton", {
		Parent                 = ClearInside;
		Size                   = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		AutoButtonColor        = false;
		Text                   = "Clear Output";
		TextColor3             = Color3.fromHex("A0A0A0");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Center;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then ClearBtnClick.FontFace = ProggyCleanFont end;
	self:Draggable(Outer);
	local LogOrder = 0;
	local function AddLog(Level, Message)
		LogOrder += 1;
		local Color = LogColors[Level] or LogColors[0];
		local Label = LogLabels[Level] or "OUTPUT";
		local TimeStr = os.date("%H:%M:%S");
		local Row = self:CreateInstance("Frame", {
			Name             = "Log_" .. LogOrder;
			Parent           = LogScroll;
			Size             = UDim2.new(1, 0, 0, 14);
			AutomaticSize    = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			BorderSizePixel  = 0;
			LayoutOrder      = LogOrder;
		});
		local Lbl = self:CreateInstance("TextLabel", {
			Parent                 = Row;
			Size                   = UDim2.new(1, 0, 0, 14);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			RichText               = true;
			Text                   = string.format(
				'<font color="#5E626B">[%s]</font> <font color="%s">[%s]</font> <font color="%s">%s</font>',
				TimeStr,
				"#" .. Color:ToHex(),
				Label,
				"#" .. Color:ToHex(),
				tostring(Message)
			);
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Top;
			TextWrapped            = true;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		task.defer(function()
			LogScroll.CanvasPosition = Vector2.new(0, math.huge);
		end);
	end;
	ClearBtnClick.MouseButton1Click:Connect(function()
		for _, C in LogScroll:GetChildren() do
			if C:IsA("Frame") then C:Destroy() end;
		end;
		LogOrder = 0;
		local ClickIn = TweenInfo.new(0.1, Enum.EasingStyle.Quad);
		TweenService:Create(ClearBtnClick, ClickIn, { TextColor3 = Library.Accent }):Play();
		task.delay(0.18, function()
			TweenService:Create(ClearBtnClick, ClickIn, { TextColor3 = Color3.fromHex("A0A0A0") }):Play();
		end);
	end);
	getgenv().log = function(Level, Message)
		AddLog(tonumber(Level) or 0, tostring(Message));
	end;
	local FadeOriginals = nil;
	local ActiveFade = nil;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame = {"BackgroundTransparency"};
			TextLabel = {"BackgroundTransparency","TextTransparency"};
			TextButton = {"BackgroundTransparency","TextTransparency"};
			ScrollingFrame = {"BackgroundTransparency"};
			UIStroke = {"Transparency"};
			UIShadow = {"Transparency"};
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, P in Props do
				local Ok, V = pcall(function() return Inst[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Outer);
		for _, D in Outer:GetDescendants() do Cap(D) end;
		return Map;
	end;
	local Obj = { Gui = Gui, Outer = Outer, _Visible = true };
	function Obj:SetVisible(State)
		State = State and true or false;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				ActiveFade = nil;
			end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then Gui.Enabled = false end;
				ActiveFade = nil;
			end);
		end;
	end;
	Library:_MakeSatelliteBindable(Obj);
	function Obj:PositionBelow(OtherObj)
		local OtherOuter = OtherObj.Outer;
		if not OtherOuter then return end;
		local function UpdatePos()
			local P = OtherOuter.AbsolutePosition;
			local S = OtherOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(1, 0);
			Outer.Position = UDim2.fromOffset(P.X + S.X, P.Y + S.Y + 2 + GuiInset);
		end;
		task.defer(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	function Obj:Log(Level, Message) AddLog(Level, Message) end;
	function Obj:Destroy() Gui:Destroy() end;
	Library:_AutoBindSatellite(Obj, Opts, nil);
	Library._LogWindow = Obj;
	return Obj;
end;
local function MakeIcon(Label, Order, Callback)
    local Btn = self:CreateInstance("TextButton", {
        Name             = "Icon_" .. Label;
        Parent           = IconRow;
        Size             = UDim2.fromOffset(IconSize, IconSize);
        BackgroundColor3 = Color3.fromHex("FFFFFF");
        BackgroundTransparency = 1;
        BorderSizePixel  = 0;
        AutoButtonColor  = false;
        Text             = "";
        LayoutOrder      = Order;
    });
    local Lbl = self:CreateInstance("TextLabel", {
        Parent                 = Btn;
        Size                   = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Text                   = Label;
        TextColor3             = Color3.fromHex("8C8F99");
        TextSize               = 12;
        TextXAlignment         = Enum.TextXAlignment.Center;
        TextYAlignment         = Enum.TextYAlignment.Center;
    });
    if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
    local Stroke = self:CreateInstance("UIStroke", {
        Parent          = Btn;
        Color           = Color3.fromHex("4D4D4D");
        Thickness       = 1;
        Transparency    = 0.7;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    });
    local Active = false;
    local HoverInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    Btn.MouseEnter:Connect(function()
        if not Active then
            Library:Tween(Lbl, HoverInfo, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
            Library:Tween(Stroke, HoverInfo, { Transparency = 0.2 }):Play();
        end;
    end);
    Btn.MouseLeave:Connect(function()
        if not Active then
            Library:Tween(Lbl, HoverInfo, { TextColor3 = Color3.fromHex("8C8F99") }):Play();
            Library:Tween(Stroke, HoverInfo, { Transparency = 0.7 }):Play();
        end;
    end);
    local IconRef = { Btn = Btn, Label = Lbl, Active = false };
    function IconRef:SetActive(State)
        self.Active = State;
        Active = State;
        local Target = State and Library.Accent or Color3.fromHex("8C8F99");
        Library:Tween(Lbl, HoverInfo, { TextColor3 = Target }):Play();
        Library:Tween(Stroke, HoverInfo, { Transparency = State and 0.2 or 0.7 }):Play();
    end;
    Btn.MouseButton1Click:Connect(function()
        Callback(IconRef);
    end);
    table.insert(Icons, IconRef);
    return IconRef;
end;
Library.ConfigSkipFlags = { ConfigName = true, ThemeName = true, _Configs = true, _Themes = true };
function Library:SerializeConfig()
	local Save = {};
	for K, Entry in self.Options do
		if not self.ConfigSkipFlags[K] then
			local Ok, V = pcall(Entry.Save);
			if Ok and V ~= nil then Save[K] = V end;
		end;
	end;
	return Save;
end;
function Library:ApplyConfig(Data)
	if typeof(Data) ~= "table" then return end;
	for K, V in Data do
		if not self.ConfigSkipFlags[K] then
			local Entry = self.Options[K];
			if Entry then
				pcall(Entry.Load, V);
			elseif typeof(V) == "table" and V._t == "Color3" then
				self.Flags[K] = Color3.fromHex(V.v);
			else
				self.Flags[K] = V;
			end;
		end;
	end;
end;
function Library:SaveConfig(Name)
	Name = tostring(Name or "");
	if Name == "" then return false, "No config name" end;
	writefile(self.Directory .. "/Configs/" .. Name .. ".json", HttpService:JSONEncode(self:SerializeConfig()));
	return true;
end;
function Library:LoadConfig(Name)
	local Path = self.Directory .. "/Configs/" .. tostring(Name) .. ".json";
	if not (isfile and isfile(Path)) then return false, "Config not found" end;
	local Ok, Data = pcall(HttpService.JSONDecode, HttpService, readfile(Path));
	if not Ok or typeof(Data) ~= "table" then return false, "Failed to decode config" end;
	self:ApplyConfig(Data);
	return true;
end;
Library.UnloadCallbacks = {};
function Library:OnUnload(Fn)
	if typeof(Fn) ~= "function" then return end;
	table.insert(self.UnloadCallbacks, Fn);
end;
function Library:Unload()
	self:Log("Unload requested");
	self.Unloaded = true;
	for _, Fn in ipairs(self.UnloadCallbacks or {}) do
		task.spawn(Fn);
	end;
	for _, Conn in self.Connections do
		if Conn ~= nil then
			Conn:Disconnect();
		end;
	end;
	self.Connections = {};
	local Win = self.CurrentlyOpen;
	if typeof(Win) == "table" and typeof(Win.Gui) == "Instance" and Win.Gui.Parent then
		Win.Gui:Destroy();
	end;
	self.CurrentlyOpen = nil;
	for I = #(self._SatelliteWindows or {}), 1, -1 do
		local Satellite = self._SatelliteWindows[I];
		if Satellite and Satellite.Destroy then pcall(function() Satellite:Destroy() end) end;
	end;
	self._SatelliteWindows = {};
	self._KeybindList = nil;
	self.KeybindMenu = nil;
	self.KeybindFrame = nil;
	self.KeybindContainer = nil;
	for _, G in ipairs(self._MobileRegistry or {}) do
		pcall(function() if G and G.Parent then G:Destroy() end end);
	end;
	self._MobileRegistry = {};
	if self.MobileMenuButton and self.MobileMenuButton.Gui then
		pcall(function() self.MobileMenuButton.Gui:Destroy() end);
		self.MobileMenuButton = nil;
	end;
	for _, L in ipairs(self._ActiveLoaders or {}) do
		pcall(function() L:Destroy() end);
	end;
	self._ActiveLoaders = {};
	self.Flags = {};
	self.Toggles = {};
	self.Options = {};
	self:Log("Unload complete");
end;
function Library:VisorChecker(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Title  = tostring(Opts.Title or "Visor Checker");
	local Width  = tonumber(Opts.Width) or 170;
	local Height = tonumber(Opts.Height) or 58;
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "VisorCheckerGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
local SatAnchor, SatPos = Vector2.new(0, 0.5), UDim2.new(0, 10, 0.5, 0);
if IsMobilePlatform then SatAnchor, SatPos = Vector2.new(1, 0), UDim2.new(1, -8, 0, 38) end;
local Outer = self:CreateInstance("Frame", {
	Name             = "Outer";
	Parent           = Gui;
	AnchorPoint      = SatAnchor;
	Position         = SatPos;
	Size             = UDim2.fromOffset(Width, Height);
	BackgroundColor3 = Color3.fromHex("FFFFFF");
	BorderSizePixel  = 0;
});
	Library:AddGlowingV2(Outer, Library.Accent, 0.4);
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Name                   = "InnerOutline";
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local TitleLbl = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 6);
		Size                   = UDim2.new(1, -12, 0, 12);
		BackgroundTransparency = 1;
		Text                   = Title;
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	local Content = self:CreateInstance("Frame", {
		Name             = "Content";
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 21);
		Size             = UDim2.new(1, -10, 1, -26);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local function ContentEdge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge(Vector2.new(0,0), UDim2.new(0,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(0,0), UDim2.new(0,1,0,1),   UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,-1,0,1),  UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,0,1,0),   UDim2.new(1,0,0,1),   "000000");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,1,1,-1),  UDim2.new(1,-2,0,1),  "393939");
	local StatusRow = self:CreateInstance("Frame", {
		Name                   = "StatusRow";
		Parent                 = Content;
		Position               = UDim2.new(0, 8, 0, 0);
		Size                   = UDim2.new(1, -12, 1, 0);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	local LabelPart = self:CreateInstance("TextLabel", {
		Name                   = "LabelPart";
		Parent                 = StatusRow;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 0, 0.5, 0);
		Size                   = UDim2.new(0, 34, 1, 0);
		BackgroundTransparency = 1;
		Text                   = "Visor:";
		TextColor3             = Color3.fromHex("BFC4CC");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then LabelPart.FontFace = ProggyCleanFont end;
	local StatusPart = self:CreateInstance("TextLabel", {
		Name                   = "StatusPart";
		Parent                 = StatusRow;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 34, 0.5, 0);
		Size                   = UDim2.new(1, -34, 1, 0);
		BackgroundTransparency = 1;
		Text                   = "Down";
		TextColor3             = Color3.fromRGB(255, 65, 65);
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then StatusPart.FontFace = ProggyCleanFont end;
	self:Draggable(Outer);
	local UpColor   = Color3.fromRGB(70, 230, 90);
	local DownColor = Color3.fromRGB(255, 65, 65);
	local CurrentState = nil;
	local FlashInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local function UpdateStatus()
		local Raw = tostring(getgenv().visorstatus or "Down");
		local Lower = string.lower(Raw);
		local IsUp = Lower == "up";
		local State = IsUp and "Up" or "Down";
		if State == CurrentState then return end;
		CurrentState = State;
		local Target = IsUp and UpColor or DownColor;
		StatusPart.Text = State;
		Library:Tween(StatusPart, FlashInfo, { TextColor3 = Target }):Play();
	end;
	UpdateStatus();
	self:Connection(RunService.Heartbeat, function()
		UpdateStatus();
	end);
	local FadeOriginals = nil;
	local ActiveFade = nil;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame     = { "BackgroundTransparency" };
			TextLabel = { "BackgroundTransparency", "TextTransparency" };
			UIStroke  = { "Transparency" };
			UIShadow  = { "Transparency" };
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, P in Props do
				local Ok, V = pcall(function() return Inst[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Outer);
		for _, D in Outer:GetDescendants() do Cap(D) end;
		return Map;
	end;
	local Obj = { Gui = Gui, Outer = Outer, Label = StatusPart, _Visible = true };
	function Obj:SetVisible(State)
		State = State and true or false;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				ActiveFade = nil;
			end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then Gui.Enabled = false end;
				ActiveFade = nil;
			end);
		end;
	end;
	function Obj:Toggle()
		self:SetVisible(not self._Visible);
	end;
	function Obj:SyncWithWindow(Window)
		local OrigSetVisible = Window.SetVisible;
		Window.SetVisible = function(Win, State)
			OrigSetVisible(Win, State);
			self:SetVisible(State);
		end;
		local OrigToggle = Window.Toggle;
		Window.Toggle = function(Win)
			OrigToggle(Win);
			self:SetVisible(Win.Visible);
		end;
	end;
	function Obj:PositionNextTo(Window)
		local WinOuter = Window.Outer;
		if not WinOuter then return end;
		local function UpdatePos()
			local WinPos  = WinOuter.AbsolutePosition;
			local WinSize = WinOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(0, 0);
			Outer.Position = UDim2.fromOffset(WinPos.X + WinSize.X + 2, WinPos.Y + GuiInset);
		end;
		task.defer(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		WinOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	function Obj:PositionBelow(OtherObj)
		local OtherOuter = OtherObj.Outer;
		if not OtherOuter then return end;
		local function UpdatePos()
			local P = OtherOuter.AbsolutePosition;
			local S = OtherOuter.AbsoluteSize;
			Outer.AnchorPoint = Vector2.new(0, 0);
			Outer.Position = UDim2.fromOffset(P.X, P.Y + S.Y + 2 + GuiInset);
		end;
		task.defer(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos);
		OtherOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePos);
	end;
	function Obj:Destroy()
		Gui:Destroy();
	end;
	Library._VisorChecker = Obj;
	return Obj;
end;
function Library:TargetUI(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Width  = tonumber(Opts.Width)  or 280;
	local Height = tonumber(Opts.Height) or 84;
	local Players = game:GetService("Players");
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "TargetUIGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local SatAnchor, SatPos = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12);
	if IsMobilePlatform then SatAnchor, SatPos = Vector2.new(1, 0), UDim2.new(1, -8, 0, 38) end;
	local Outer = self:CreateInstance("Frame", {
		Name             = "Outer";
		Parent           = Gui;
		AnchorPoint      = SatAnchor;
		Position         = SatPos;
		Size             = UDim2.fromOffset(Width, Height);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		Visible          = false;
	});
	Library:AddGlowingV2(Outer, Library.Accent, 0.4);
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Name                   = "InnerOutline";
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local Content = self:CreateInstance("Frame", {
		Name             = "Content";
		Parent           = Outer;
		Position         = UDim2.new(0, 5, 0, 5);
		Size             = UDim2.new(1, -10, 1, -10);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	local function ContentEdge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge(Vector2.new(0,0), UDim2.new(0,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(0,0), UDim2.new(0,1,0,1),   UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,-1,0,1),  UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,0,1,0),   UDim2.new(1,0,0,1),   "000000");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,1,1,-1),  UDim2.new(1,-2,0,1),  "393939");
	local AvatarSize = Height - 18;
	local AvatarBox = self:CreateInstance("Frame", {
		Name             = "AvatarBox";
		Parent           = Content;
		AnchorPoint      = Vector2.new(0, 0.5);
		Position         = UDim2.new(0, 5, 0.5, 0);
		Size             = UDim2.fromOffset(AvatarSize, AvatarSize);
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	local AvatarGray = self:CreateInstance("Frame", {
		Parent           = AvatarBox;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	local AvatarInside = self:CreateInstance("Frame", {
		Parent           = AvatarGray;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("101010");
		BorderSizePixel  = 0;
		ClipsDescendants = true;
	});
	local AvatarImage = self:CreateInstance("ImageLabel", {
		Name                   = "Avatar";
		Parent                 = AvatarInside;
		Size                   = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		Image                  = "";
		ScaleType              = Enum.ScaleType.Crop;
		ZIndex                 = 2;
	});
	local InfoBlock = self:CreateInstance("Frame", {
		Name                   = "InfoBlock";
		Parent                 = Content;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, AvatarSize + 14, 0.5, 0);
		Size                   = UDim2.new(1, -(AvatarSize + 20), 1, -6);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
local NameContainer = self:CreateInstance("Frame", {
		Name                   = "NameContainer";
		Parent                 = InfoBlock;
		Position               = UDim2.new(0, 0, 0, 0);
		Size                   = UDim2.new(0.6, 0, 0, 14);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		ClipsDescendants       = false;
	});
	local NameLbl = self:CreateInstance("TextLabel", {
		Name                   = "NameLbl";
		Parent                 = NameContainer;
		Position               = UDim2.new(0, 0, 0, 0);
		Size                   = UDim2.new(0, 0, 1, 0);
		AutomaticSize          = Enum.AutomaticSize.X;
		BackgroundTransparency = 1;
		Text                   = "Player";
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 13;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then NameLbl.FontFace = ProggyCleanFont end;
	local ModBadge = self:CreateInstance("TextLabel", {
		Name                   = "ModBadge";
		Parent                 = NameContainer;
		AnchorPoint            = Vector2.new(0, 0.5);
		Position               = UDim2.new(0, 0, 0.5, 0);
		Size                   = UDim2.new(0, 0, 0, 12);
		AutomaticSize          = Enum.AutomaticSize.X;
		BackgroundTransparency = 1;
		Text                   = "[MOD]";
		TextColor3             = Library.Accent;
		TextSize               = 11;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
		Visible                = false;
	});
	if ProggyCleanFont then ModBadge.FontFace = ProggyCleanFont end;
	Library:OnAccent(function(NewAccent)
		ModBadge.TextColor3 = NewAccent;
	end);
	local VisibleLbl = self:CreateInstance("TextLabel", {
		Name                   = "VisibleLbl";
		Parent                 = InfoBlock;
		AnchorPoint            = Vector2.new(1, 0);
		Position               = UDim2.new(1, 0, 0, 0);
		Size                   = UDim2.new(0.35, 0, 0, 14);
		BackgroundTransparency = 1;
		Text                   = "Not Visible";
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Right;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then VisibleLbl.FontFace = ProggyCleanFont end;
	local KdrLbl = self:CreateInstance("TextLabel", {
		Name                   = "KdrLbl";
		Parent                 = InfoBlock;
		Position               = UDim2.new(0, 0, 0, 16);
		Size                   = UDim2.new(1, 0, 0, 13);
		BackgroundTransparency = 1;
		Text                   = "KDR: ";
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then KdrLbl.FontFace = ProggyCleanFont end;
	local PlayTimeLbl = self:CreateInstance("TextLabel", {
		Name                   = "PlayTimeLbl";
		Parent                 = InfoBlock;
		Position               = UDim2.new(0, 0, 0, 30);
		Size                   = UDim2.new(1, 0, 0, 13);
		BackgroundTransparency = 1;
		Text                   = "Play Time: ";
		TextColor3             = Color3.fromHex("8C8F99");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then PlayTimeLbl.FontFace = ProggyCleanFont end;
	local HealthText = self:CreateInstance("TextLabel", {
		Name                   = "HealthText";
		Parent                 = InfoBlock;
		Position               = UDim2.new(0, 0, 0, 44);
		Size                   = UDim2.new(1, 0, 0, 13);
		BackgroundTransparency = 1;
		Text                   = "100 / 100";
		TextColor3             = Color3.fromHex("BFC4CC");
		TextSize               = 12;
		TextXAlignment         = Enum.TextXAlignment.Left;
		TextYAlignment         = Enum.TextYAlignment.Center;
	});
	if ProggyCleanFont then HealthText.FontFace = ProggyCleanFont end;
	local HealthTrack = self:CreateInstance("Frame", {
		Name             = "HealthTrack";
		Parent           = InfoBlock;
		AnchorPoint      = Vector2.new(0, 1);
		Position         = UDim2.new(0, 0, 1, 0);
		Size             = UDim2.new(1, 0, 0, 10);
		BackgroundColor3 = Color3.fromHex("000000");
		BorderSizePixel  = 0;
	});
	local HealthGray = self:CreateInstance("Frame", {
		Parent           = HealthTrack;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("393939");
		BorderSizePixel  = 0;
	});
	local HealthInside = self:CreateInstance("Frame", {
		Parent           = HealthGray;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromHex("131313");
		BorderSizePixel  = 0;
	});
	local HealthFill = self:CreateInstance("Frame", {
		Name             = "HealthFill";
		Parent           = HealthInside;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 1, -2);
		BackgroundColor3 = Color3.fromRGB(70, 230, 90);
		BorderSizePixel  = 0;
	});
	local VisibleColor = Color3.fromRGB(70, 230, 90);
	local HiddenColor  = Color3.fromRGB(255, 65, 65);
	local CurrentUserId = nil;
	local LastHealthPct = 1;
	local HealthCounterToken = 0;
	if not Library._AvatarThumbCache then
		Library._AvatarThumbCache = {};
	end;
	local ThumbCache = Library._AvatarThumbCache;
local function PrefetchThumbnail(UserId)
    if not UserId or UserId == 0 then return end;
    if ThumbCache[UserId] ~= nil then return end;
    ThumbCache[UserId] = false;
    task.spawn(function()
        local Ok, Content = pcall(function()
            return Players:GetUserThumbnailAsync(
                UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size180x180
            );
        end);
        if Ok and Content and Content ~= "" then
            ThumbCache[UserId] = Content;
        else
            ThumbCache[UserId] = nil;
        end;
    end);
end;
	if not Library._AvatarPrefetchStarted then
		Library._AvatarPrefetchStarted = true;
		for _, Plr in Players:GetPlayers() do
			PrefetchThumbnail(Plr.UserId);
		end;
		Library:Connection(Players.PlayerAdded, function(Plr)
			PrefetchThumbnail(Plr.UserId);
		end);
	end;
local function SetAvatar(UserId)
    if not UserId or UserId == 0 then
        CurrentUserId = nil;
        AvatarImage.Image = "";
        return;
    end;
    if UserId == CurrentUserId then return; end;
    CurrentUserId = UserId;
    local Cached = ThumbCache[UserId];
    if typeof(Cached) == "string" then
        AvatarImage.Image = Cached;
        return;
    end;
    if Cached == nil then
        PrefetchThumbnail(UserId);
    end;
    AvatarImage.Image = "";
    task.spawn(function()
        local Waited = 0;
        while CurrentUserId == UserId and Waited < 8 do
            local Value = ThumbCache[UserId];
            if typeof(Value) == "string" then
                if CurrentUserId == UserId then
                    AvatarImage.Image = Value;
                end;
                return;
            elseif Value == nil and Waited > 1 then
                PrefetchThumbnail(UserId);
            end;
            task.wait(0.1);
            Waited += 0.1;
        end;
    end);
end;
local function SetName(Name)
		NameLbl.Text = tostring(Name or "Player");
		if ModBadge.Visible then
			ModBadge.Position = UDim2.new(0, NameLbl.AbsoluteSize.X + 6, 0.5, 0);
		end;
	end;
	local function SetHealth(Current, Max)
		Current = tonumber(Current) or 0;
		Max = tonumber(Max) or 100;
		if Max <= 0 then Max = 1; end;
		local Pct = math.clamp(Current / Max, 0, 1);
		local Color = Library.Accent;
		local BarInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		Library:Tween(HealthFill, BarInfo, {
			Size = UDim2.new(Pct, -2, 1, -2);
			BackgroundColor3 = Color;
		}):Play();
		HealthCounterToken = HealthCounterToken + 1;
		local Mine = HealthCounterToken;
		local StartCurrent = tonumber(string.match(HealthText.Text, "^(%-?%d+%.?%d*)")) or Current;
		local StartMax = tonumber(string.match(HealthText.Text, "/%s*(%-?%d+%.?%d*)")) or Max;
		local Duration = 0.25;
		local StartTime = os.clock();
		task.spawn(function()
			while true do
				if HealthCounterToken ~= Mine then return; end;
				local Elapsed = os.clock() - StartTime;
				local Alpha = math.clamp(Elapsed / Duration, 0, 1);
				local Eased = 1 - (1 - Alpha) ^ 3;
				local DisplayCurrent = StartCurrent + (Current - StartCurrent) * Eased;
				local DisplayMax = StartMax + (Max - StartMax) * Eased;
				HealthText.Text = string.format("%d / %d", math.floor(DisplayCurrent + 0.5), math.floor(DisplayMax + 0.5));
				if Alpha >= 1 then break; end;
				task.wait();
			end;
			if HealthCounterToken == Mine then
				HealthText.Text = string.format("%d / %d", math.floor(Current + 0.5), math.floor(Max + 0.5));
			end;
		end);
		LastHealthPct = Pct;
	end;
	local function SetKDR(Text)
		KdrLbl.Text = "KDR: " .. tostring(Text or "");
	end;
	local function SetPlayTime(Text)
		PlayTimeLbl.Text = "Play Time: " .. tostring(Text or "");
	end;
	local function SetVisible(IsVisible)
		local Target = IsVisible and VisibleColor or HiddenColor;
		VisibleLbl.Text = IsVisible and "Visible" or "Not Visible";
		Library:Tween(VisibleLbl, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = Target;
		}):Play();
	end;
local function SetMod(IsMod)
		if IsMod then
			ModBadge.Position = UDim2.new(0, NameLbl.AbsoluteSize.X + 6, 0.5, 0);
			ModBadge.Visible = true;
		else
			ModBadge.Visible = false;
		end
	end;
	self:Draggable(Outer);
	Library:OnAccent(function(NewAccent)
		Library:Tween(HealthFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = NewAccent;
		}):Play();
		ModBadge.TextColor3 = NewAccent;
	end);
	local Obj = { Gui = Gui, Outer = Outer, Content = Content };
	function Obj:SetTarget(Data)
		Data = typeof(Data) == "table" and Data or {};
		if Data.UserId then SetAvatar(Data.UserId); end;
		if Data.Name then SetName(Data.Name); end;
		if Data.Health ~= nil or Data.MaxHealth ~= nil then
			SetHealth(Data.Health, Data.MaxHealth);
		end;
		if Data.KDR ~= nil then SetKDR(Data.KDR); end;
		if Data.PlayTime ~= nil then SetPlayTime(Data.PlayTime); end;
		if Data.Visible ~= nil then SetVisible(Data.Visible); end;
		if Data.ismod ~= nil then SetMod(Data.ismod); end;
	end;
	function Obj:Show()
		Outer.Visible = true;
	end;
	function Obj:Hide()
		Outer.Visible = false;
		CurrentUserId = nil;
	end;
	function Obj:Clear()
		self:Hide();
		AvatarImage.Image = "";
		NameLbl.Text = "Player";
		KdrLbl.Text = "KDR: ";
		PlayTimeLbl.Text = "Play Time: ";
		HealthCounterToken = HealthCounterToken + 1;
		HealthFill.Size = UDim2.new(1, -2, 1, -2);
		HealthFill.BackgroundColor3 = Library.Accent;
		HealthText.Text = "100 / 100";
		SetVisible(false);
		SetMod(false);
	end;
	function Obj:Destroy()
		Gui:Destroy();
	end;
	Library._TargetUI = Obj;
	return Obj;
end;
function Library:InvViewer(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local Width     = tonumber(Opts.Width)     or 210;
	local MinHeight = tonumber(Opts.MinHeight) or 310;
	local MaxItems  = tonumber(Opts.MaxItems)  or 35;
	local Gui = self:CreateInstance("ScreenGui", {
		Name           = "InvViewerGui";
		Parent         = (gethui and gethui()) or CoreGui;
		IgnoreGuiInset = true;
		ResetOnSpawn   = false;
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	});
	local SatPos = UDim2.new(1, -14, 0, 14);
	if IsMobilePlatform then SatPos = UDim2.new(1, -8, 0, 38) end;
	local Outer = self:CreateInstance("Frame", {
		Name             = "Outer";
		Parent           = Gui;
		AnchorPoint      = Vector2.new(1, 0);
		Position         = SatPos;
		Size             = UDim2.fromOffset(Width, MinHeight);
		AutomaticSize    = Enum.AutomaticSize.Y;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		Visible          = false;
	});
	Library:AddGlowingV2(Outer, Library.Accent, 0.45);
	self:CreateInstance("UIGradient", {
		Parent   = Outer;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
			NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
		});
	});
	self:CreateInstance("UIStroke", {
		Parent          = Outer;
		Color           = Color3.fromHex("000000");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local InnerOutline = self:CreateInstance("Frame", {
		Name                   = "InnerOutline";
		Parent                 = Outer;
		Position               = UDim2.new(0, 1, 0, 1);
		Size                   = UDim2.new(1, -2, 1, -2);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	self:CreateInstance("UIStroke", {
		Parent          = InnerOutline;
		Color           = Color3.fromHex("393939");
		Thickness       = 1;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		LineJoinMode    = Enum.LineJoinMode.Miter;
	});
	local TopLine = self:CreateInstance("Frame", {
		Name             = "TopLine";
		Parent           = Outer;
		Position         = UDim2.new(0, 1, 0, 1);
		Size             = UDim2.new(1, -2, 0, 1);
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
		ZIndex           = 10;
	});
	Library:RegisterAccentGradient(self:CreateInstance("UIGradient", {
		Parent = TopLine; Rotation = 0;
	}));
	local TitleHolder = self:CreateInstance("Frame", {
		Name                   = "TitleHolder";
		Parent                 = Outer;
		Position               = UDim2.new(0, 6, 0, 8);
		Size                   = UDim2.new(1, -12, 0, 20);
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	local TitleLbl = self:CreateInstance("TextLabel", {
		Name                   = "Title";
		Parent                 = TitleHolder;
		Size                   = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1;
		Text                   = "Player's Inventory";
		TextColor3             = Color3.fromHex("FFFFFF");
		TextSize               = 13;
		TextXAlignment         = Enum.TextXAlignment.Center;
		TextYAlignment         = Enum.TextYAlignment.Center;
		TextTruncate           = Enum.TextTruncate.AtEnd;
	});
	if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;
	local TitleUnderline = self:CreateInstance("Frame", {
		Name                   = "Underline";
		Parent                 = Outer;
		AnchorPoint            = Vector2.new(0.5, 0);
		Position               = UDim2.new(0.5, 0, 0, 29);
		Size                   = UDim2.new(0, 0, 0, 1);
		BackgroundColor3       = Color3.fromHex("FFFFFF");
		BorderSizePixel        = 0;
		BackgroundTransparency = 0.3;
	});
	local UnderlineGradient = self:CreateInstance("UIGradient", {
		Parent   = TitleUnderline;
		Rotation = 0;
		Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 1);
			NewNumberSequenceKeypoint(0.5, 0);
			NewNumberSequenceKeypoint(1, 1);
		});
	});
	Library:RegisterAccentGradient(UnderlineGradient);
	local BodyHolder = self:CreateInstance("Frame", {
		Name                   = "BodyHolder";
		Parent                 = Outer;
		Position               = UDim2.new(0, 5, 0, 36);
		Size                   = UDim2.new(1, -10, 0, math.max(MinHeight - 41, 0));
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
	});
	local Content = self:CreateInstance("Frame", {
		Name             = "Content";
		Parent           = BodyHolder;
		Position         = UDim2.new(0, 0, 0, 0);
		Size             = UDim2.new(1, 0, 0, math.max(MinHeight - 41, 0));
		AutomaticSize    = Enum.AutomaticSize.Y;
		BackgroundColor3 = Color3.fromHex("FFFFFF");
		BorderSizePixel  = 0;
	});
	self:CreateInstance("UIGradient", {
		Parent   = Content;
		Rotation = 90;
		Color    = NewColorSequence({
			NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
			NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
		});
	});
	self:CreateInstance("UISizeConstraint", {
		Parent       = Content;
		MinSize      = Vector2.new(0, math.max(MinHeight - 41, 0));
	});
	self:CreateInstance("UIPadding", {
		Parent        = Outer;
		PaddingBottom = UDim.new(0, 5);
	});
	local function ContentEdge(Anchor, Pos, Sz, Color)
		self:CreateInstance("Frame", {
			Parent           = Content;
			AnchorPoint      = Anchor;
			Position         = Pos;
			Size             = Sz;
			BackgroundColor3 = Color3.fromHex(Color);
			BorderSizePixel  = 0;
			ZIndex           = 10;
		});
	end;
	ContentEdge(Vector2.new(0,0), UDim2.new(0,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(0,0), UDim2.new(0,1,0,1),   UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,0,0,0),   UDim2.new(0,1,1,0),   "000000");
	ContentEdge(Vector2.new(1,0), UDim2.new(1,-1,0,1),  UDim2.new(0,1,1,-2),  "393939");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,0,1,0),   UDim2.new(1,0,0,1),   "000000");
	ContentEdge(Vector2.new(0,1), UDim2.new(0,1,1,-1),  UDim2.new(1,-2,0,1),  "393939");
	local Scroller = self:CreateInstance("ScrollingFrame", {
		Name                   = "Scroller";
		Parent                 = Content;
		Position               = UDim2.new(0, 2, 0, 2);
		Size                   = UDim2.new(1, -4, 0, math.max(MinHeight - 45, 0));
		AutomaticSize          = Enum.AutomaticSize.Y;
		BackgroundTransparency = 1;
		BorderSizePixel        = 0;
		CanvasSize             = UDim2.new(0, 0, 0, 0);
		AutomaticCanvasSize    = Enum.AutomaticSize.Y;
		ScrollBarThickness     = 2;
		ScrollBarImageColor3   = Library.Accent;
		ScrollingDirection     = Enum.ScrollingDirection.Y;
		ClipsDescendants       = true;
	});
	self:CreateInstance("UISizeConstraint", {
		Parent  = Scroller;
		MinSize = Vector2.new(0, math.max(MinHeight - 45, 0));
	});
	Library:RegisterAccent(Scroller, "ScrollBarImageColor3");
	Library:_AttachScrollbar(Scroller);
	self:CreateInstance("UIListLayout", {
		Parent        = Scroller;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder     = Enum.SortOrder.LayoutOrder;
		Padding       = UDim.new(0, 7);
	});
	self:CreateInstance("UIPadding", {
		Parent        = Scroller;
		PaddingTop    = UDim.new(0, 4);
		PaddingLeft   = UDim.new(0, 2);
		PaddingRight  = UDim.new(0, 2);
		PaddingBottom = UDim.new(0, 6);
	});
	self:Draggable(Outer);
	local FlashOutInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local CategoryState = {};
	local function FlashRow(Bg)
		Bg.BackgroundTransparency = 0.55;
		Library:Tween(Bg, FlashOutInfo, { BackgroundTransparency = 1 }):Play();
	end;
	local function BuildCategory(CatIdx, CatName)
		local Sec = self:CreateInstance("Frame", {
			Name                   = "Category";
			Parent                 = Scroller;
			Size                   = UDim2.new(1, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			LayoutOrder            = CatIdx;
		});
		local HeaderBox = self:CreateInstance("Frame", {
			Name             = "Header";
			Parent           = Sec;
			Size             = UDim2.new(1, 0, 0, 19);
			BackgroundColor3 = Color3.fromHex("000000");
			BorderSizePixel  = 0;
		});
		local HeaderGray = self:CreateInstance("Frame", {
			Parent           = HeaderBox;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("393939");
			BorderSizePixel  = 0;
		});
		local HeaderInside = self:CreateInstance("Frame", {
			Parent           = HeaderGray;
			Position         = UDim2.new(0, 1, 0, 1);
			Size             = UDim2.new(1, -2, 1, -2);
			BackgroundColor3 = Color3.fromHex("FFFFFF");
			BorderSizePixel  = 0;
			ClipsDescendants = true;
		});
		self:CreateInstance("UIGradient", {
			Parent   = HeaderInside;
			Rotation = 90;
			Color    = NewColorSequence({
				NewColorSequenceKeypoint(0, Color3.fromHex("232323"));
				NewColorSequenceKeypoint(1, Color3.fromHex("161616"));
			});
		});
		local HeaderAccentBar = self:CreateInstance("Frame", {
			Name             = "AccentBar";
			Parent           = HeaderInside;
			Size             = UDim2.new(0, 2, 1, 0);
			BackgroundColor3 = Library.Accent;
			BorderSizePixel  = 0;
			ZIndex           = 2;
		});
		Library:RegisterAccent(HeaderAccentBar);
		local HeaderLbl = self:CreateInstance("TextLabel", {
			Parent                 = HeaderInside;
			Position               = UDim2.new(0, 8, 0, 0);
			Size                   = UDim2.new(1, -13, 1, 0);
			BackgroundTransparency = 1;
			Text                   = CatName;
			TextColor3             = Color3.fromHex("FFFFFF");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			ZIndex                 = 2;
		});
		if ProggyCleanFont then HeaderLbl.FontFace = ProggyCleanFont end;
		local ItemsHolder = self:CreateInstance("Frame", {
			Name                   = "Items";
			Parent                 = Sec;
			Position               = UDim2.new(0, 0, 0, 21);
			Size                   = UDim2.new(1, 0, 0, 0);
			AutomaticSize          = Enum.AutomaticSize.Y;
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		self:CreateInstance("UIListLayout", {
			Parent        = ItemsHolder;
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder     = Enum.SortOrder.LayoutOrder;
			Padding       = UDim.new(0, 1);
		});
		return {
			Sec         = Sec;
			HeaderLbl   = HeaderLbl;
			ItemsHolder = ItemsHolder;
			Rows        = {};
			Name        = CatName;
			Items       = {};
			HiddenCount = 0;
		};
	end;
	local function BuildRow(Parent, ItemName, LayoutOrder)
		local Row = self:CreateInstance("Frame", {
			Name                   = "Item";
			Parent                 = Parent;
			Size                   = UDim2.new(1, 0, 0, 15);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
			LayoutOrder            = LayoutOrder;
		});
		local FlashBg = self:CreateInstance("Frame", {
			Name                   = "Flash";
			Parent                 = Row;
			Size                   = UDim2.new(1, 0, 1, 0);
			BackgroundColor3       = Library.Accent;
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		Library:RegisterAccent(FlashBg);
		local Lbl = self:CreateInstance("TextLabel", {
			Name                   = "Label";
			Parent                 = Row;
			Position               = UDim2.new(0, 8, 0, 0);
			Size                   = UDim2.new(1, -10, 1, 0);
			BackgroundTransparency = 1;
			Text                   = ItemName;
			TextColor3             = Color3.fromHex("C4C8D1");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
			TextTruncate           = Enum.TextTruncate.AtEnd;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		return { Row = Row, Lbl = Lbl, Flash = FlashBg, Text = ItemName };
	end;
	local function BuildEmptyRow(Parent)
		local Row = self:CreateInstance("Frame", {
			Name                   = "EmptyItem";
			Parent                 = Parent;
			Size                   = UDim2.new(1, 0, 0, 15);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = self:CreateInstance("TextLabel", {
			Parent                 = Row;
			Position               = UDim2.new(0, 8, 0, 0);
			Size                   = UDim2.new(1, -10, 1, 0);
			BackgroundTransparency = 1;
			Text                   = "Empty";
			TextColor3             = Color3.fromHex("4A4D55");
			TextSize               = 12;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		return Row;
	end;
	local function BuildHiddenRow(Parent, HiddenCount, TotalCount)
		local Pct = TotalCount > 0 and math.floor((HiddenCount / TotalCount) * 100 + 0.5) or 0;
		local Row = self:CreateInstance("Frame", {
			Name                   = "HiddenItem";
			Parent                 = Parent;
			Size                   = UDim2.new(1, 0, 0, 15);
			BackgroundTransparency = 1;
			BorderSizePixel        = 0;
		});
		local Lbl = self:CreateInstance("TextLabel", {
			Parent                 = Row;
			Position               = UDim2.new(0, 8, 0, 0);
			Size                   = UDim2.new(1, -10, 1, 0);
			BackgroundTransparency = 1;
			Text                   = "Hidden other " .. Pct .. "% items";
			TextColor3             = Color3.fromHex("6B6F78");
			TextSize               = 11;
			TextXAlignment         = Enum.TextXAlignment.Left;
			TextYAlignment         = Enum.TextYAlignment.Center;
		});
		if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
		return Row;
	end;
	local function DiffCategory(State, ItemList, MaxItems)
		local CatName = tostring(ItemList[1] or State.Name);
		if CatName ~= State.Name then
			State.Name = CatName;
			State.HeaderLbl.Text = CatName;
		end;
		local AllItems = {};
		for I = 2, #ItemList do
			local V = tostring(ItemList[I]);
			if V ~= "" then table.insert(AllItems, V) end;
		end;
		local TotalCount  = #AllItems;
		local ShownItems  = AllItems;
		local HiddenCount = 0;
		if TotalCount > MaxItems then
			ShownItems  = table.create(MaxItems);
			for I = 1, MaxItems do ShownItems[I] = AllItems[I] end;
			HiddenCount = TotalCount - MaxItems;
		end;
		local OldItems = State.Items;
		local SameCount = #OldItems == #ShownItems;
		local Identical = SameCount and (State.HiddenCount == HiddenCount);
		if Identical then
			for I = 1, #ShownItems do
				if OldItems[I] ~= ShownItems[I] then
					Identical = false;
					break;
				end;
			end;
		end;
		if Identical then return end;
		for _, RowRef in State.Rows do
			RowRef.Row:Destroy();
		end;
		table.clear(State.Rows);
		for _, C in State.ItemsHolder:GetChildren() do
			if C.Name == "EmptyItem" or C.Name == "HiddenItem" then C:Destroy() end;
		end;
		if #ShownItems == 0 then
			BuildEmptyRow(State.ItemsHolder);
		else
			for I, ItemName in ShownItems do
				local RowRef = BuildRow(State.ItemsHolder, ItemName, I);
				table.insert(State.Rows, RowRef);
				FlashRow(RowRef.Flash);
			end;
			if HiddenCount > 0 then
				local HRow = BuildHiddenRow(State.ItemsHolder, HiddenCount, TotalCount);
				HRow.LayoutOrder = #ShownItems + 1;
			end;
		end;
		State.Items       = ShownItems;
		State.HiddenCount = HiddenCount;
	end;
	local function Refresh(Name, CategorysAndItems)
		if Name ~= nil then
			local NewTitle = tostring(Name) .. "'s Inventory";
			if TitleLbl.Text ~= NewTitle then
				TitleLbl.Text = NewTitle;
			end;
		end;
		if typeof(CategorysAndItems) ~= "table" then return end;
		local SeenIdx = {};
		for CatIdx, ItemList in CategorysAndItems do
			local Idx = tonumber(CatIdx) or 1;
			if typeof(ItemList) == "table" then
				SeenIdx[Idx] = true;
				local State = CategoryState[Idx];
				if not State then
					local CatName = tostring(ItemList[1] or ("Category " .. Idx));
					State = BuildCategory(Idx, CatName);
					CategoryState[Idx] = State;
				end;
				DiffCategory(State, ItemList, MaxItems);
			end;
		end;
		for Idx, State in CategoryState do
			if not SeenIdx[Idx] then
				State.Sec:Destroy();
				CategoryState[Idx] = nil;
			end;
		end;
	end;
	local FadeOriginals = nil;
	local ActiveFade = nil;
	local function CaptureFade()
		local Map = {};
		local Types = {
			Frame          = { "BackgroundTransparency" };
			TextLabel      = { "BackgroundTransparency", "TextTransparency" };
			ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" };
			UIStroke       = { "Transparency" };
			UIShadow       = { "Transparency" };
		};
		local function Cap(Inst)
			local Props = Types[Inst.ClassName];
			if not Props then return end;
			local PMap = {};
			for _, P in Props do
				local Ok, V = pcall(function() return Inst[P] end);
				if Ok then PMap[P] = V end;
			end;
			Map[Inst] = PMap;
		end;
		Cap(Outer);
		for _, D in Outer:GetDescendants() do
			if D.Name ~= "Flash" then Cap(D) end;
		end;
		return Map;
	end;
	local Obj = { Gui = Gui, Outer = Outer, _Visible = false };
	Gui.Enabled = false;
	function Obj:SetVisible(State)
		State = State and true or false;
		if self._Visible == State and Gui.Enabled == State and not ActiveFade then return end;
		self._Visible = State;
		if ActiveFade then ActiveFade:Disconnect(); ActiveFade = nil end;
		if Library._ReduceAnimations then
			Library:_SnapFadeGroup(FadeOriginals, State and "in" or "out");
			Gui.Enabled = State; return;
		end;
		if not State then
			FadeOriginals = Library:_RefreshFadeMap(FadeOriginals, CaptureFade());
		elseif not FadeOriginals then
			FadeOriginals = CaptureFade();
		end;
		if State then
			Gui.Enabled   = true;
			Outer.Visible = true;
			ActiveFade = Library:_FadeGroup(FadeOriginals, "in", 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
				ActiveFade = nil;
			end);
		else
			ActiveFade = Library:_FadeGroup(FadeOriginals, "out", 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
				if not self._Visible then
					Gui.Enabled   = false;
					Outer.Visible = false;
				end;
				ActiveFade = nil;
			end);
		end;
	end;
	function Obj:Toggle()
		self:SetVisible(not self._Visible);
	end;
	function Obj:SyncWithWindow(Window)
		local OrigSetVisible = Window.SetVisible;
		Window.SetVisible = function(Win, State)
			OrigSetVisible(Win, State);
			if not State then self:SetVisible(false) end;
		end;
		local OrigToggle = Window.Toggle;
		Window.Toggle = function(Win)
			OrigToggle(Win);
			if not Win.Visible then self:SetVisible(false) end;
		end;
	end;
	function Obj:Update(Data)
		Data = typeof(Data) == "table" and Data or {};
		Refresh(Data.Name, Data.CategorysAndItems);
	end;
	function Obj:Clear()
		for _, State in CategoryState do
			State.Sec:Destroy();
		end;
		table.clear(CategoryState);
		TitleLbl.Text = "Player's Inventory";
	end;
	function Obj:Destroy()
		Gui:Destroy();
	end;
	Library._InvViewer = Obj;
	return Obj;
end;
Library.IsMobile = IsMobilePlatform;
Library._ReduceAnimations = false;
Library.CantDragForced = false;
Library.CanDrag = true;
Library.IsDragging = false;
Library.MenuKeybind = Enum.KeyCode.RightShift;
Library:Connection(UserInputService.InputBegan, function(Input, GameProc)
	if GameProc then return end;
	if Input.UserInputType ~= Enum.UserInputType.Keyboard then return end;
	if UserInputService:GetFocusedTextBox() then return end;
	local K = Library.MenuKeybind;
	if K == nil or typeof(K) ~= "EnumItem" or K.EnumType ~= Enum.KeyCode then return end;
	if Input.KeyCode ~= K then return end;
	local Win = Library.CurrentlyOpen;
	if Win then Win:Toggle() end;
end);
function Library:SetReduceAnimations(B)
	Library._ReduceAnimations = B and true or false;
	for _, W in ipairs(Library._Windows or {}) do
		if W.Gui and W.Gui.Parent and W.SetVisible then W:SetVisible(W.Visible == true) end;
	end;
	for _, Obj in ipairs(Library._SatelliteWindows or {}) do
		if Obj.Gui and Obj.Gui.Parent and Obj.SetVisible then Obj:SetVisible(Obj._Visible == true) end;
	end;
end;
do
	local GuiRoot = (gethui and gethui()) or CoreGui;
	Library._UIScaleValue = 1;
	Library._UIScaleAuto  = true;
	Library._UIScaleNodes = {};
	local function ApplyScale(N)
		MobileUIScaleValue = N;
		for _, Node in ipairs(Library._UIScaleNodes) do
			if Node and Node.Parent then Node.Scale = N end;
		end;
	end;
	local function ComputeAutoScale()
		return 1;
	end;
	function Library:SetUIScale(N)
		N = tonumber(N) or 1;
		Library._UIScaleAuto  = false;
		Library._UIScaleValue = math.clamp(N, 0.4, 3);
		ApplyScale(Library._UIScaleValue);
	end;
	function Library:SetDPIScale(V)
		V = tonumber(V) or 100;
		Library:SetUIScale(V / 100);
	end;
	function Library:SetAutoUIScale()
		Library._UIScaleAuto = true;
		Library._UIScaleValue = ComputeAutoScale();
		ApplyScale(Library._UIScaleValue);
	end;
	function Library:_BindKeyboardAvoidance(Tb)
		local SavedPos = nil;
		Tb.Focused:Connect(function()
			if Library.CantDragForced then return end;
			local Top = Tb;
			while Top.Parent and not Top.Parent:IsA("ScreenGui") do Top = Top.Parent end;
			if not (Top and Top.Parent and Top:IsA("GuiObject")) then return end;
			local Cam = Workspace.CurrentCamera;
			if not Cam then return end;
			local Vp = Cam.ViewportSize;
			task.defer(function()
				if not Tb:IsFocused() then return end;
				local TbBottom = Tb.AbsolutePosition.Y + Tb.AbsoluteSize.Y;
				local SafeY = Vp.Y * 0.5;
				if TbBottom > SafeY then
					SavedPos = Top.Position;
					local S  = Library:_GetUIScaleOf(Top);
					local Dy = (TbBottom - SafeY) / S;
					Library:Tween(Top, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = SavedPos - UDim2.fromOffset(0, Dy);
					}):Play();
				end;
			end);
		end);
		Tb.FocusLost:Connect(function()
			if not SavedPos then return end;
			local Top = Tb;
			while Top.Parent and not Top.Parent:IsA("ScreenGui") do Top = Top.Parent end;
			if not (Top and Top.Parent and Top:IsA("GuiObject")) then SavedPos = nil; return end;
			Library:Tween(Top, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = SavedPos;
			}):Play();
			SavedPos = nil;
		end);
	end;
	local OrigCreateInstance = Library.CreateInstance;
	Library._MobileRegistry = {};
	local function AttachScale(Gui)
		if Gui.Name == "MobileMenuButton" then return end;
		local Conn;
		Conn = Gui.ChildAdded:Connect(function(Child)
			if not Child:IsA("GuiObject") then return end;
			Conn:Disconnect();
			local Node = OrigCreateInstance(Library, "UIScale", {
				Parent = Child;
				Scale  = Library._UIScaleValue;
			});
			table.insert(Library._UIScaleNodes, Node);
		end);
		task.delay(3, function()
			if Conn.Connected then Conn:Disconnect() end;
		end);
	end
	Library.CreateInstance = function(Self, ClassName, Props)
		local Inst = OrigCreateInstance(Self, ClassName, Props);
		if ClassName == "ScreenGui" then
			table.insert(Library._MobileRegistry, Inst);
			AttachScale(Inst);
		elseif IsMobilePlatform and ClassName == "TextBox" then
			task.defer(function()
				if Inst.Parent then Library:_BindKeyboardAvoidance(Inst) end;
			end);
		end;
		return Inst;
	end;
	local function ClampFrameIntoViewport(Frame)
		if not (Frame and Frame.Parent and Frame:IsA("GuiObject")) then return end;
		local Parent = Frame.Parent;
		if not (Parent and Parent:IsA("GuiObject")) then return end;
		local Ps = Parent.AbsoluteSize;
		local Ts = Frame.AbsoluteSize;
		local Ap = Frame.AnchorPoint;
		if Ps.X <= 0 or Ps.Y <= 0 or Ts.X <= 0 or Ts.Y <= 0 then return end;
		local S = Library:_GetUIScaleOf(Frame);
		local Margin = 40;
		local Tx = Frame.Position.X.Scale * Ps.X + Frame.Position.X.Offset * S - Ap.X * Ts.X;
		local Ty = Frame.Position.Y.Scale * Ps.Y + Frame.Position.Y.Offset * S - Ap.Y * Ts.Y;
		local Nx = math.clamp(Tx, -(Ts.X - Margin), math.max(Ps.X - Margin, 0));
		local Ny;
		if Ts.Y > Ps.Y then
			Ny = 0;
		else
			Ny = math.clamp(Ty, 0, math.max(Ps.Y - Margin, 0));
		end;
		if Nx ~= Tx or Ny ~= Ty then
			Frame.Position = UDim2.new(
				Frame.Position.X.Scale, (Nx + Ap.X * Ts.X - Frame.Position.X.Scale * Ps.X) / S,
				Frame.Position.Y.Scale, (Ny + Ap.Y * Ts.Y - Frame.Position.Y.Scale * Ps.Y) / S
			);
		end;
	end;
	local function ClampAllWindows()
		for _, G in ipairs(Library._MobileRegistry) do
			if G and G.Parent then
				for _, C in ipairs(G:GetChildren()) do
					if C:IsA("GuiObject") then
						ClampFrameIntoViewport(C);
					end;
				end;
			end;
		end;
	end;
	local Cam = Workspace.CurrentCamera;
	if Cam then
		Library:Connection(Cam:GetPropertyChangedSignal("ViewportSize"), function()
			task.defer(function()
				if Library._UIScaleAuto then
					Library._UIScaleValue = ComputeAutoScale();
					ApplyScale(Library._UIScaleValue);
				end;
				ClampAllWindows();
				local Btn = Library.MobileMenuButton;
				if Btn then Btn:Snap() end;
			end);
		end);
	end;
	local function CreateMobileMenuButton()
		if Library.MobileMenuButton then return Library.MobileMenuButton end;
		local BtnGui = OrigCreateInstance(Library, "ScreenGui", {
			Name           = "MobileMenuButton";
			Parent         = GuiRoot;
			IgnoreGuiInset = true;
			ResetOnSpawn   = false;
			DisplayOrder   = 9999;
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		});
		local Obj;
		local function CreatePill(Text, PosY)
			local Outer = OrigCreateInstance(Library, "Frame", {
				Name             = Text .. "Outer";
				Parent           = BtnGui;
				Position         = UDim2.new(0.008, 0, PosY, 0);
				Size             = UDim2.new(0, 77, 0, 30);
				BackgroundColor3 = Color3.fromHex("1C1C1C");
				BorderColor3     = Color3.new(0, 0, 0);
				ZIndex           = 200;
			});
			local Inner = OrigCreateInstance(Library, "Frame", {
				Name             = "Inner";
				Parent           = Outer;
				Size             = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.fromHex("1C1C1C");
				BorderColor3     = Library.Accent;
				BorderMode       = Enum.BorderMode.Inset;
				ZIndex           = 201;
			});
			Library:RegisterAccent(Inner, "BorderColor3");
			local Face = OrigCreateInstance(Library, "Frame", {
				Name             = "Face";
				Parent           = Inner;
				Position         = UDim2.new(0, 1, 0, 1);
				Size             = UDim2.new(1, -2, 1, -2);
				BackgroundColor3 = Color3.new(1, 1, 1);
				BorderSizePixel  = 0;
				ZIndex           = 202;
			});
			OrigCreateInstance(Library, "UIGradient", {
				Parent   = Face;
				Rotation = -90;
				Color    = NewColorSequence({
					NewColorSequenceKeypoint(0, Color3.fromHex("0E0E0E"));
					NewColorSequenceKeypoint(1, Color3.fromHex("1C1C1C"));
				});
			});
			local Btn = OrigCreateInstance(Library, "TextButton", {
				Name                   = "Button";
				Parent                 = Face;
				Position               = UDim2.new(0, 5, 0, 0);
				Size                   = UDim2.new(1, -4, 1, 0);
				BackgroundTransparency = 1;
				Text                   = Text;
				TextColor3             = Color3.fromHex("FFFFFF");
				TextSize               = 14;
				TextStrokeTransparency = 0;
				TextXAlignment         = Enum.TextXAlignment.Left;
				AutoButtonColor        = false;
				Font                   = Enum.Font.Code;
				ZIndex                 = 203;
			});
			return Outer, Btn, Face;
		end;
		local function PlayPressFlash(Face)
			if Library._ReduceAnimations then return end;
			Library:Tween(Face, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.45;
			}):Play();
			task.delay(0.06, function()
				if not Face.Parent then return end;
				Library:Tween(Face, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0;
				}):Play();
			end);
		end;
		local TogglePill, ToggleBtn, ToggleFace = CreatePill("Toggle UI", 0.018);
		local LockPill,   LockBtn,   LockFace   = CreatePill("Lock UI",   0.075);
		Library:Draggable(TogglePill, ToggleBtn, true);
		Library:Draggable(LockPill, LockBtn, true);
		local function BindTapDrag(Btn, OnTap)
			local DownPos = nil;
			local LpFiredAt = 0;
			Library:Connection(Btn.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.Touch
					or Input.UserInputType == Enum.UserInputType.MouseButton1 then
					DownPos = Vector2.new(Input.Position.X, Input.Position.Y);
				end;
			end);
			Library:Connection(Btn.InputEnded, function(Input)
				if not DownPos then return end;
				if Input.UserInputType ~= Enum.UserInputType.Touch
					and Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end;
				local P = Vector2.new(Input.Position.X, Input.Position.Y);
				local Dist = (P - DownPos).Magnitude;
				DownPos = nil;
				if os.clock() - LpFiredAt < 0.35 then return end;
				if Dist > 10 then return end;
				pcall(function()
					HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Large, 0.35);
					task.delay(0.06, function()
						HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Large, 0);
					end);
				end);
				OnTap();
			end);
			Library:BindLongPress(Btn, function()
				LpFiredAt = os.clock();
				if Obj then Obj:Reset() end;
			end, 0.6);
		end;
		BindTapDrag(ToggleBtn, function()
			PlayPressFlash(ToggleFace);
			local Win = Library.CurrentlyOpen;
			if Win then Win:Toggle() end;
		end);
		BindTapDrag(LockBtn, function()
			PlayPressFlash(LockFace);
			Library.CantDragForced = not Library.CantDragForced;
			LockBtn.Text = Library.CantDragForced and "Unlock UI" or "Lock UI";
		end);
		Obj = { Gui = BtnGui, Toggle = TogglePill, Lock = LockPill };
		function Obj:Show() BtnGui.Enabled = true end;
		function Obj:Hide() BtnGui.Enabled = false end;
		function Obj:Snap()
			ClampFrameIntoViewport(TogglePill);
			ClampFrameIntoViewport(LockPill);
		end;
		function Obj:Reset()
			Library:Tween(TogglePill, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.008, 0, 0.018, 0);
			}):Play();
			Library:Tween(LockPill, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.008, 0, 0.075, 0);
			}):Play();
			Library:Notify("Menu buttons position reset", 1.5);
		end;
		Library.MobileMenuButton = Obj;
		return Obj;
	end;
	Library.CreateMobileMenuButton = CreateMobileMenuButton;
	if IsMobilePlatform then
		Library._UIScaleValue = ComputeAutoScale();
		MobileUIScaleValue = Library._UIScaleValue;
		Library:SetReduceAnimations(true);
		Library.AnimationSpeed = math.max(tonumber(Library.AnimationSpeed) or 1, 1.5);
		CreateMobileMenuButton();
		task.defer(ClampAllWindows);
		task.delay(0.5, ClampAllWindows);
	end;
end;
do
	Library.Toggles = Library.Toggles or {};
	local function FireCbs(Cbs, ...)
		for _, Fn in ipairs(Cbs) do task.spawn(Fn, ...) end;
	end;
	local MouseAliases = { MB1 = "MouseButton1", MB2 = "MouseButton2", MB3 = "MouseButton3" };
	local function KeyFromString(K)
		if typeof(K) == "EnumItem" then return K end;
		if typeof(K) ~= "string" then return nil end;
		local Ok, E = pcall(function() return Enum.KeyCode[K] end);
		if Ok and E then return E end;
		local Ok2, E2 = pcall(function() return Enum.UserInputType[MouseAliases[K] or K] end);
		if Ok2 and E2 then return E2 end;
		return nil;
	end;
	local function KeyToString(K)
		if typeof(K) == "EnumItem" then
			return (Library.KeyNames and Library.KeyNames[K]) or K.Name;
		end;
		return "None";
	end;
	Library.KeyFromString = KeyFromString;
	local RawNotify = Library.Notify;
	Library.Notify = function(self, A, B, C)
		if typeof(A) == "table" then
			return RawNotify(self, A.Description or A.Text or A.Content or "", A.Time or A.Duration or B, C);
		end;
		return RawNotify(self, A, B, C);
	end;
	local function NewColorProxy(Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Tr = math.clamp(tonumber(Opts.Transparency) or 0, 0, 1);
		local Default = typeof(Opts.Default) == "Color3" and Opts.Default or Color3.fromRGB(255, 255, 255);
		local CProxy = { Type = "ColorPicker", Value = Default, Transparency = Tr, _Cbs = {} };
		local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
		local Cb = function(C, A)
			CProxy.Value = C; CProxy.Transparency = 1 - A;
			if UserCb then UserCb(C, A) end;
			FireCbs(CProxy._Cbs, C);
		end;
		return CProxy, Tr, Default, Cb;
	end;
	local function WrapColorProxy(Idx, Entry, CProxy)
		CProxy.Save = function() return Entry.Save() end;
		CProxy.Load = function(Data) Entry.Load(Data) end;
		function CProxy:SetValue(C)
			Entry.Load({ _t = "Color", v = C:ToHex(), a = 1 - (self.Transparency or 0) });
		end;
		function CProxy:SetValueRGB(C, Tr)
			if Tr ~= nil then self.Transparency = math.clamp(tonumber(Tr) or 0, 0, 1) end;
			Entry.Load({ _t = "Color", v = C:ToHex(), a = 1 - self.Transparency });
		end;
		function CProxy:OnChanged(Fn)
			if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
		end;
		Library.Options[Idx] = CProxy;
		return CProxy;
	end;
	local function WrapKeyProxy(Idx, Entry, KProxy, KeyObj)
		KProxy.Save = function() return Entry.Save() end;
		KProxy.Load = function(Data) Entry.Load(Data) end;
		KProxy.MenuVisible = not KeyObj.GetMenuVisible or KeyObj.GetMenuVisible() ~= false;
		function KProxy:GetState() return KeyObj.GetState() end;
		function KProxy:SetKey(K) KeyObj.SetKey(KeyFromString(K) or K) end;
		function KProxy:GetMode()
			return KeyObj.GetMode and KeyObj.GetMode() or self.Mode;
		end;
		function KProxy:SetMode(M)
			if KeyObj.SetMode then KeyObj.SetMode(M) end;
			self.Mode = tostring(M or self.Mode);
		end;
		function KProxy:SetValue(V)
			if typeof(V) == "table" then
				local NewMode = V[2] or V.Mode;
				if NewMode then self:SetMode(NewMode) end;
				self:SetKey(V[1] or V.Key);
			else
				self:SetKey(V);
			end;
		end;
		function KProxy:SetMenuVisibility(V)
			self.MenuVisible = V == true;
			if KeyObj.SetMenuVisible then KeyObj.SetMenuVisible(self.MenuVisible) end;
		end;
		function KProxy:GetMenuVisibility()
			return KeyObj.GetMenuVisible and KeyObj.GetMenuVisible() or self.MenuVisible;
		end;
		function KProxy:SetText(T)
			if KeyObj.SetText then KeyObj.SetText(T) end;
			self.Text = tostring(T);
		end;
		function KProxy:OnChanged(Fn)
			if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
		end;
		Library.Options[Idx] = KProxy;
		return KProxy;
	end;
	local function MultiToArray(D)
		if typeof(D) ~= "table" then return D end;
		local Arr = {};
		for K, On in pairs(D) do
			if typeof(K) == "number" then table.insert(Arr, D[K]);
			elseif On then table.insert(Arr, K) end;
		end;
		return Arr;
	end;
	local MediaCache = {};
	local MediaCount = 0;
	local function ResolveMedia(Source, DefaultExtension)
		if typeof(Source) == "number" then Source = "rbxassetid://" .. tostring(Source) end;
		if typeof(Source) ~= "string" or Source == "" then return nil end;
		if string.match(Source, "^rbxassetid://") or string.match(Source, "^rbxthumb://") or string.match(Source, "^rbxgameasset://") then
			return Source;
		end;
		if MediaCache[Source] then return MediaCache[Source] end;
		local Path = Source;
		if string.match(Source, "^https?://") then
			MediaCount += 1;
			Path = Library.Directory .. "/media_" .. tostring(MediaCount) .. (DefaultExtension or ".png");
			if not (isfile and isfile(Path)) then
				local Ok, Data = pcall(function() return game:HttpGet(Source) end);
				if not Ok or typeof(Data) ~= "string" or #Data == 0 then return nil end;
				local Wrote = pcall(writefile, Path, Data);
				if not Wrote then return nil end;
			end;
		end;
		if not (isfile and isfile(Path)) then return nil end;
		local Ok, Asset = pcall(getcustomasset, Path);
		if not Ok or not Asset then return nil end;
		MediaCache[Source] = Asset;
		return Asset;
	end;
	local function EnhanceSection(Sec)
		if typeof(Sec) ~= "table" or Sec._ObsidianAPI then return Sec end;
		Sec._ObsidianAPI = true;
		Sec.AddToggle = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Toggle");
			local Proxy = { Type = "Toggle", Value = Opts.Default == true, _Cbs = {} };
			local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
			local Obj = self:Toggle({
				Name     = Opts.Text or Opts.Name or Idx;
				Default  = Opts.Default;
				Risky    = Opts.Risky;
				Risk     = Opts.Risk;
				Tooltip  = Opts.Tooltip;
				Flag     = Idx;
				Callback = function(State)
					Proxy.Value = State;
					if UserCb then UserCb(State) end;
					FireCbs(Proxy._Cbs, State);
				end;
			});
			Proxy._Obj = Obj;
			function Proxy:SetValue(V) Obj:Set(V == true) end;
			function Proxy:OnChanged(Fn)
				if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
			end;
			function Proxy:AddColorPicker(CIdx, COpts)
				local CProxy, Tr, Default, Cb = NewColorProxy(COpts);
				CIdx = tostring(CIdx or (typeof(COpts) == "table" and COpts.Text) or "Color");
				Obj:AddColorpicker({ Flag = CIdx, Default = Default, Alpha = 1 - Tr, Callback = Cb });
				return WrapColorProxy(CIdx, Library.Options[CIdx], CProxy);
			end;
			function Proxy:AddKeyPicker(KIdx, KOpts)
				KOpts = typeof(KOpts) == "table" and KOpts or {};
				KIdx = tostring(KIdx or KOpts.Text or "Keybind");
				local KProxy = {
					Type  = "KeyPicker";
					Value = KeyToString(KeyFromString(KOpts.Default));
					Mode  = tostring(KOpts.Mode or "Toggle");
					_Cbs  = {};
				};
				Obj:AddKeybind({
					Default = KeyFromString(KOpts.Default);
					Mode    = KOpts.Mode;
					MenuVisible = KOpts.MenuVisible;
					NoUI = KOpts.NoUI;
					Flag    = KIdx;
					OnChanged = function(K)
						KProxy.Value = KeyToString(K);
						FireCbs(KProxy._Cbs, KProxy.Value);
					end;
				});
				local KeyObj = Obj.KeybindObj;
				local Entry = Library.Options[KIdx];
				if not (KeyObj and Entry) then return KProxy end;
				return WrapKeyProxy(KIdx, Entry, KProxy, KeyObj);
			end;
			Library.Toggles[Idx] = Proxy;
			return Proxy;
		end;
		Sec.AddCheckbox = Sec.AddToggle;
		Library._EnhanceSection = EnhanceSection;
		Sec.AddButton = function(self, A, B)
			local Text, Fn, Confirm;
			if typeof(A) == "table" then
				Text = A.Text or A.Name or "Button"; Fn = A.Func or A.Callback; Confirm = A.Confirm;
			else
				Text = tostring(A); Fn = B;
			end;
			local Obj = self:Button({
				Text = Text; Confirm = Confirm;
				Callback = function() if Fn then Fn() end end;
			});
			local BProxy = { _Obj = Obj };
			function BProxy:AddButton(A2, B2)
				local T2, F2;
				if typeof(A2) == "table" then T2 = A2.Text or A2.Name or "Button"; F2 = A2.Func or A2.Callback;
				else T2 = tostring(A2); F2 = B2; end;
				Obj:Button({ Text = T2, Callback = function() if F2 then F2() end end });
				return self;
			end;
			return BProxy;
		end;
		Sec.AddLabel = function(self, Text)
			local Lbl = Library:CreateInstance("TextLabel", {
				Parent = self.Body;
				Size = UDim2.new(1, 0, 0, 14);
				BackgroundTransparency = 1; BorderSizePixel = 0;
				Text = tostring(Text); TextColor3 = Color3.fromHex("FFFFFF"); TextSize = 12;
				TextXAlignment = Enum.TextXAlignment.Left; TextYAlignment = Enum.TextYAlignment.Center;
			});
			if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;
			local LProxy = { _Label = Lbl };
			function LProxy:SetText(T) Lbl.Text = tostring(T) end;
			function LProxy:SetColor(C) Lbl.TextColor3 = C end;
			return LProxy;
		end;
		Sec.AddDivider = function(self)
			local Holder = Library:CreateInstance("Frame", {
				Parent = self.Body; Size = UDim2.new(1, 0, 0, 7);
				BackgroundTransparency = 1; BorderSizePixel = 0;
			});
			Library:CreateInstance("Frame", {
				Parent = Holder; AnchorPoint = Vector2.new(0, 0.5);
				Position = UDim2.new(0, 0, 0.5, 0); Size = UDim2.new(1, 0, 0, 1);
				BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
			});
		end;
		Sec.AddSlider = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Slider");
			local Proxy = { Type = "Slider", Value = tonumber(Opts.Default) or tonumber(Opts.Min) or 0, _Cbs = {} };
			local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
			local Obj = self:Slider({
				Name     = Opts.Text or Opts.Name or Idx;
				Min      = Opts.Min; Max = Opts.Max; Step = Opts.Step; Suffix = Opts.Suffix;
				Decimals = Opts.Rounding or Opts.Decimals;
				Default  = Opts.Default;
				Tooltip  = Opts.Tooltip; Flag = Idx;
				Callback = function(V)
					Proxy.Value = V;
					if UserCb then UserCb(V) end;
					FireCbs(Proxy._Cbs, V);
				end;
			});
			Proxy._Obj = Obj;
			local Entry = Library.Options[Idx];
			Proxy.Save = function() return Entry.Save() end;
			Proxy.Load = function(Data) Entry.Load(Data) end;
			function Proxy:SetValue(V) Obj:Set(V) end;
			function Proxy:OnChanged(Fn)
				if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
			end;
			Library.Options[Idx] = Proxy;
			return Proxy;
		end;
		Sec.AddInput = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Input");
			local Proxy = { Type = "Input", Value = tostring(Opts.Default or ""), _Cbs = {} };
			local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
			local Obj = self:Textbox({
				Name = Opts.Text or Opts.Name or Idx;
				Default = Opts.Default; Placeholder = Opts.Placeholder; Numeric = Opts.Numeric;
				Tooltip = Opts.Tooltip; Flag = Idx;
				Callback = function(V)
					Proxy.Value = V;
					if UserCb then UserCb(V) end;
					FireCbs(Proxy._Cbs, V);
				end;
			});
			Proxy._Obj = Obj;
			local Entry = Library.Options[Idx];
			Proxy.Save = function() return Entry.Save() end;
			Proxy.Load = function(Data) Entry.Load(Data) end;
			function Proxy:SetValue(V) self.Value = tostring(V); Obj:Set(V) end;
			function Proxy:OnChanged(Fn)
				if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
			end;
			Library.Options[Idx] = Proxy;
			return Proxy;
		end;
		Sec.AddDropdown = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Dropdown");
			local Values = typeof(Opts.Values) == "table" and Opts.Values
				or (typeof(Opts.Options) == "table" and Opts.Options or {});
			local Multi = Opts.Multi == true;
			local Default = Opts.Default;
			if Multi then
				Default = MultiToArray(Default);
			elseif typeof(Default) == "number" then
				Default = Values[Default];
			end;
			local Proxy = { Type = "Dropdown", Multi = Multi, _Cbs = {} };
			local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
			local Obj = self:Dropdown({
				Name = Opts.Text or Opts.Name or Idx;
				Options = Values; Default = Default; Multi = Multi;
				Tooltip = Opts.Tooltip; Flag = Idx;
				Callback = function(V)
					Proxy.Value = V;
					if UserCb then UserCb(V) end;
					FireCbs(Proxy._Cbs, V);
				end;
			});
			Proxy._Obj = Obj;
			Proxy.Value = Obj:Get();
			local Entry = Library.Options[Idx];
			Proxy.Save = function() return Entry.Save() end;
			Proxy.Load = function(Data) Entry.Load(Data) end;
			function Proxy:SetValue(V)
				if Multi then V = MultiToArray(V) end;
				Obj:Set(V);
			end;
			function Proxy:SetValues(List) Obj:SetOptions(List) end;
			function Proxy:OnChanged(Fn)
				if typeof(Fn) == "function" then table.insert(self._Cbs, Fn) end;
			end;
			Library.Options[Idx] = Proxy;
			return Proxy;
		end;
		Sec.AddKeyPicker = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Keybind");
			local UserCb = typeof(Opts.Callback) == "function" and Opts.Callback or nil;
			local KProxy = {
				Type  = "KeyPicker";
				Value = KeyToString(KeyFromString(Opts.Default));
				Mode  = tostring(Opts.Mode or "Toggle");
				_Cbs  = {};
			};
			local Obj = self:Keybind({
				Name = Opts.Text or Opts.Name or Idx;
				Mode = Opts.Mode;
				Default = KeyFromString(Opts.Default);
				MenuVisible = Opts.MenuVisible; NoUI = Opts.NoUI;
				Tooltip = Opts.Tooltip; Flag = Idx;
				Callback = function(State) if UserCb then UserCb(State) end end;
				OnChanged = function(K)
					KProxy.Value = KeyToString(K);
					FireCbs(KProxy._Cbs, KProxy.Value);
				end;
			});
			KProxy._Obj = Obj;
			return WrapKeyProxy(Idx, Library.Options[Idx], KProxy, {
				GetState = function() return Obj:Get() end;
				SetKey   = function(K) Obj:SetKey(K) end;
				GetMode  = function() return Obj:GetMode() end;
				SetMode  = function(M) Obj:SetMode(M) end;
				GetMenuVisible = function() return Obj:GetMenuVisible() end;
				SetMenuVisible = function(V) Obj:SetMenuVisible(V) end;
				SetText = function(T) Obj:SetText(T) end;
			});
		end;
		Sec.AddColorPicker = function(self, Idx, Opts)
			Opts = typeof(Opts) == "table" and Opts or {};
			Idx = tostring(Idx or Opts.Text or Opts.Name or "Color");
			local CProxy, Tr, Default, Cb = NewColorProxy(Opts);
			self:Colorpicker({
				Name = Opts.Text or Opts.Name or Idx;
				Default = Default; Alpha = 1 - Tr;
				Tooltip = Opts.Tooltip; Flag = Idx;
				Callback = Cb;
			});
			return WrapColorProxy(Idx, Library.Options[Idx], CProxy);
		end;
		Sec.AddViewport = function(self, Idx, Info)
			Info = typeof(Info) == "table" and Info or {};
			Idx = tostring(Idx or "Viewport");
			assert(typeof(Info.Object) == "Instance" and (Info.Object:IsA("BasePart") or Info.Object:IsA("Model")), "Object must be a BasePart or Model.");
			local SourceObject = Info.Object;
			local ViewportObject = SourceObject;
			if Info.Clone ~= false then
				local WasArchivable = SourceObject.Archivable;
				SourceObject.Archivable = true;
				ViewportObject = SourceObject:Clone();
				SourceObject.Archivable = WasArchivable;
			end;
			local Camera = Info.Camera or Instance.new("Camera");
			assert(typeof(Camera) == "Instance" and Camera:IsA("Camera"), "Camera must be a Camera instance.");
			Camera.CameraType = Enum.CameraType.Scriptable;
			local Height = math.max(24, tonumber(Info.Height) or 200);
			local Holder = Library:CreateInstance("Frame", {
				Name = Idx; Parent = self.Body; Size = UDim2.new(1, 0, 0, Height);
				BackgroundTransparency = 1; Visible = Info.Visible ~= false;
			});
			local Box = Library:CreateInstance("Frame", {
				Parent = Holder; Size = UDim2.fromScale(1, 1); BackgroundColor3 = Color3.fromHex("151515");
				BorderSizePixel = 0; ClipsDescendants = true;
			});
			Library:CreateInstance("UIStroke", { Parent = Box; Color = Color3.fromHex("252527"); Thickness = 1; });
			Library:CreateInstance("UIPadding", {
				Parent = Box; PaddingBottom = UDim.new(0, 4); PaddingLeft = UDim.new(0, 4);
				PaddingRight = UDim.new(0, 4); PaddingTop = UDim.new(0, 4);
			});
			local ViewportFrame = Library:CreateInstance("ViewportFrame", {
				Parent = Box; Size = UDim2.fromScale(1, 1); BackgroundTransparency = 1;
				CurrentCamera = Camera; Active = Info.Interactive == true;
			});
			local Viewport = {
				Type = "Viewport"; Object = ViewportObject; Camera = Camera;
				Interactive = Info.Interactive == true; AutoFocus = Info.AutoFocus ~= false;
				Visible = Info.Visible ~= false; Height = Height; Holder = Holder;
				ViewportFrame = ViewportFrame; Connections = {}; Destroyed = false;
			};
			local Dragging, Pinching, Hovering = false, false, false;
			local LastMousePos, LastPinchDist = nil, 0;
			local Scroll = self.Body:FindFirstAncestorOfClass("ScrollingFrame");
			local function UpdateScroll()
				if Scroll then Scroll.ScrollingEnabled = not (Viewport.Interactive and (Hovering or Dragging or Pinching)) end;
			end;
			local function Track(Signal, Fn)
				local Conn = Library:Connection(Signal, Fn);
				table.insert(Viewport.Connections, Conn);
				return Conn;
			end;
			local function GetPivotPosition()
				return Viewport.Object:GetPivot().Position;
			end;
			local function GetObjectSize()
				if Viewport.Object:IsA("BasePart") then return Viewport.Object.Size end;
				return select(2, Viewport.Object:GetBoundingBox());
			end;
			local function FocusCamera()
				if not Viewport.Object then return end;
				local Size = GetObjectSize();
				local Extent = math.max(Size.X, Size.Y, Size.Z, 0.1);
				local Position = GetPivotPosition();
				Viewport.Camera.CFrame = CFrame.lookAt(Position + Vector3.new(0, Extent * 0.35, Extent * 2.2), Position);
			end;
			local function OrbitCamera(Yaw, Pitch)
				if not Viewport.Object then return end;
				local Position = GetPivotPosition();
				local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), Yaw);
				Viewport.Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Viewport.Camera.CFrame;
				local RotationX = CFrame.fromAxisAngle(Viewport.Camera.CFrame.RightVector, Pitch);
				local Pitched = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Viewport.Camera.CFrame;
				if Pitched.UpVector.Y > 0.1 then Viewport.Camera.CFrame = Pitched end;
			end;
			local function ZoomCamera(Amount)
				if not Viewport.Object then return end;
				local Position = GetPivotPosition();
				local Offset = Viewport.Camera.CFrame.Position - Position;
				local Distance = Offset.Magnitude;
				local Direction = Distance > 0 and Offset.Unit or -Viewport.Camera.CFrame.LookVector;
				local NewDistance = math.clamp(Distance - Amount, 0.05, 10000);
				Viewport.Camera.CFrame = CFrame.lookAt(Position + Direction * NewDistance, Position);
			end;
			local function IsOverFrame(Position)
				local P, S = ViewportFrame.AbsolutePosition, ViewportFrame.AbsoluteSize;
				return Position.X >= P.X and Position.X <= P.X + S.X and Position.Y >= P.Y and Position.Y <= P.Y + S.Y;
			end;
			Track(ViewportFrame.MouseEnter, function()
				Hovering = true; UpdateScroll();
			end);
			Track(ViewportFrame.MouseLeave, function()
				Hovering = false; UpdateScroll();
			end);
			Track(ViewportFrame.InputBegan, function(Input)
				if not Viewport.Interactive then return end;
				if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
					Dragging = true; LastMousePos = Input.Position; Library.CanDrag = false; UpdateScroll();
				end;
			end);
			Track(UserInputService.InputEnded, function(Input)
				if Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch) then
					Dragging = false; LastMousePos = nil; Library.CanDrag = true; UpdateScroll();
				end;
			end);
			Track(UserInputService.InputChanged, function(Input)
				if not Viewport.Interactive or not Dragging or Pinching or not LastMousePos then return end;
				if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
					local Delta = Input.Position - LastMousePos;
					LastMousePos = Input.Position;
					OrbitCamera(-Delta.X * 0.01, -Delta.Y * 0.01);
				end;
			end);
			Track(ViewportFrame.InputChanged, function(Input)
				if Viewport.Interactive and Input.UserInputType == Enum.UserInputType.MouseWheel then ZoomCamera(Input.Position.Z * 2) end;
			end);
			Track(UserInputService.TouchPinch, function(Positions, _, _, State)
				if not Viewport.Interactive or #Positions < 2 or not IsOverFrame(Positions[1]) then return end;
				if State == Enum.UserInputState.Begin then
					Pinching = true; Dragging = false; Library.CanDrag = true; LastPinchDist = (Positions[1] - Positions[2]).Magnitude; UpdateScroll();
				elseif State == Enum.UserInputState.Change then
					local Distance = (Positions[1] - Positions[2]).Magnitude;
					ZoomCamera((Distance - LastPinchDist) * 0.1); LastPinchDist = Distance;
				elseif State == Enum.UserInputState.End or State == Enum.UserInputState.Cancel then
					Pinching = false; UpdateScroll();
				end;
			end);
			ViewportObject.Parent = ViewportFrame;
			if Viewport.AutoFocus then FocusCamera() end;
			function Viewport:SetObject(Object, Clone)
				assert(typeof(Object) == "Instance" and (Object:IsA("BasePart") or Object:IsA("Model")), "Object must be a BasePart or Model.");
				if Clone then
					local Source = Object;
					local WasArchivable = Source.Archivable; Source.Archivable = true;
					Object = Source:Clone(); Source.Archivable = WasArchivable;
				end;
				if self.Object then self.Object:Destroy() end;
				self.Object = Object; Object.Parent = ViewportFrame;
				if self.AutoFocus then FocusCamera() end;
			end;
			function Viewport:SetHeight(NewHeight)
				assert(typeof(NewHeight) == "number" and NewHeight > 0, "Height must be greater than 0.");
				self.Height = NewHeight; Holder.Size = UDim2.new(1, 0, 0, NewHeight);
			end;
			function Viewport:Focus() FocusCamera() end;
			function Viewport:SetCamera(NewCamera)
				assert(typeof(NewCamera) == "Instance" and NewCamera:IsA("Camera"), "Camera must be a Camera instance.");
				self.Camera = NewCamera; NewCamera.CameraType = Enum.CameraType.Scriptable; ViewportFrame.CurrentCamera = NewCamera;
			end;
			function Viewport:SetCameraCFrame(NewCFrame)
				assert(typeof(NewCFrame) == "CFrame", "NewCFrame must be a CFrame."); self.Camera.CFrame = NewCFrame;
			end;
			function Viewport:GetCameraCFrame() return self.Camera.CFrame end;
			function Viewport:Rotate(Yaw, Pitch) OrbitCamera(math.rad(Yaw or 0), math.rad(Pitch or 0)) end;
			function Viewport:Zoom(Amount) assert(typeof(Amount) == "number", "Amount must be a number."); ZoomCamera(Amount) end;
			function Viewport:LookAt(Target)
				if not Target and not self.Object then return end;
				self.Camera.CFrame = CFrame.lookAt(self.Camera.CFrame.Position, Target or GetPivotPosition());
			end;
			function Viewport:SetDistance(Distance)
				assert(typeof(Distance) == "number" and Distance > 0, "Distance must be greater than 0.");
				if not self.Object then return end;
				local Position = GetPivotPosition();
				local Offset = self.Camera.CFrame.Position - Position;
				local Direction = Offset.Magnitude > 0 and Offset.Unit or -self.Camera.CFrame.LookVector;
				self.Camera.CFrame = CFrame.lookAt(Position + Direction * Distance, Position);
			end;
			function Viewport:GetDistance()
				return self.Object and (self.Camera.CFrame.Position - GetPivotPosition()).Magnitude or 0;
			end;
			function Viewport:SetFieldOfView(FieldOfView)
				assert(typeof(FieldOfView) == "number", "FieldOfView must be a number.");
				self.Camera.FieldOfView = math.clamp(FieldOfView, 1, 120);
			end;
			function Viewport:SetInteractive(Interactive)
				self.Interactive = Interactive == true; ViewportFrame.Active = self.Interactive;
				if not self.Interactive then
					if Dragging or Pinching then Library.CanDrag = true end;
					Dragging, Pinching = false, false;
				end;
				UpdateScroll();
			end;
			function Viewport:SetVisible(Visible) self.Visible = Visible == true; Holder.Visible = self.Visible end;
			function Viewport:Destroy()
				if self.Destroyed then return end;
				self.Destroyed = true;
				for _, Conn in ipairs(self.Connections) do Conn:Disconnect() end;
				if Dragging or Pinching then Library.CanDrag = true end;
				Dragging, Pinching, Hovering = false, false, false; UpdateScroll();
				Holder:Destroy();
				if Library.Options[Idx] == self then Library.Options[Idx] = nil end;
			end;
			Library.Options[Idx] = Viewport;
			return Viewport;
		end;
		Sec.AddImage = function(self, Idx, Info)
			Info = typeof(Info) == "table" and Info or {};
			Idx = tostring(Idx or "Image");
			local Source = Info.Image;
			if Source == nil then Source = Info.Icon end;
			local Asset = ResolveMedia(Source, ".png");
			assert(Asset, "Image must be a valid asset, URL, or local file.");
			local Height = math.max(1, tonumber(Info.Height) or 200);
			local Holder = Library:CreateInstance("Frame", {
				Name = Idx; Parent = self.Body; Size = UDim2.new(1, 0, 0, Height);
				BackgroundTransparency = 1; Visible = Info.Visible ~= false;
			});
			local Box = Library:CreateInstance("Frame", {
				Parent = Holder; Size = UDim2.fromScale(1, 1); BackgroundColor3 = Color3.fromHex("151515");
				BackgroundTransparency = math.clamp(tonumber(Info.BackgroundTransparency) or 0, 0, 1);
				BorderSizePixel = 0; ClipsDescendants = true;
			});
			local Stroke = Library:CreateInstance("UIStroke", { Parent = Box; Color = Color3.fromHex("252527"); Thickness = 1; });
			Library:CreateInstance("UIPadding", {
				Parent = Box; PaddingBottom = UDim.new(0, 4); PaddingLeft = UDim.new(0, 4);
				PaddingRight = UDim.new(0, 4); PaddingTop = UDim.new(0, 4);
			});
			local ImageLabel = Library:CreateInstance("ImageLabel", {
				Parent = Box; Size = UDim2.fromScale(1, 1); BackgroundTransparency = 1; Image = Asset;
				ImageColor3 = typeof(Info.Color) == "Color3" and Info.Color or Color3.new(1, 1, 1);
				ImageTransparency = math.clamp(tonumber(Info.Transparency) or 0, 0, 1);
				ImageRectOffset = typeof(Info.RectOffset) == "Vector2" and Info.RectOffset or Vector2.zero;
				ImageRectSize = typeof(Info.RectSize) == "Vector2" and Info.RectSize or Vector2.zero;
				ScaleType = typeof(Info.ScaleType) == "EnumItem" and Info.ScaleType or Enum.ScaleType.Fit;
			});
			local Image = {
				Type = "Image"; Image = Source; Asset = Asset; Height = Height; Visible = Info.Visible ~= false;
				Holder = Holder; Box = Box; ImageLabel = ImageLabel; Destroyed = false;
			};
			function Image:SetHeight(NewHeight)
				assert(typeof(NewHeight) == "number" and NewHeight > 0, "Height must be greater than 0.");
				self.Height = NewHeight; Holder.Size = UDim2.new(1, 0, 0, NewHeight);
			end;
			function Image:SetImage(NewImage)
				local NewAsset = ResolveMedia(NewImage, ".png");
				assert(NewAsset, "Image must be a valid asset, URL, or local file.");
				self.Image = NewImage; self.Asset = NewAsset; ImageLabel.Image = NewAsset;
			end;
			function Image:SetColor(Color)
				assert(typeof(Color) == "Color3", "Color must be a Color3."); ImageLabel.ImageColor3 = Color;
			end;
			function Image:SetRectOffset(Offset)
				assert(typeof(Offset) == "Vector2", "RectOffset must be a Vector2."); ImageLabel.ImageRectOffset = Offset;
			end;
			function Image:SetRectSize(Size)
				assert(typeof(Size) == "Vector2", "RectSize must be a Vector2."); ImageLabel.ImageRectSize = Size;
			end;
			function Image:SetScaleType(ScaleType)
				assert(typeof(ScaleType) == "EnumItem" and ScaleType.EnumType == Enum.ScaleType, "Invalid ScaleType."); ImageLabel.ScaleType = ScaleType;
			end;
			function Image:SetTransparency(Transparency)
				assert(typeof(Transparency) == "number", "Transparency must be a number.");
				ImageLabel.ImageTransparency = math.clamp(Transparency, 0, 1);
			end;
			function Image:SetBackgroundTransparency(Transparency)
				assert(typeof(Transparency) == "number", "BackgroundTransparency must be a number.");
				Box.BackgroundTransparency = math.clamp(Transparency, 0, 1); Stroke.Enabled = Box.BackgroundTransparency < 1;
			end;
			function Image:SetVisible(Visible) self.Visible = Visible == true; Holder.Visible = self.Visible end;
			function Image:Destroy()
				if self.Destroyed then return end;
				self.Destroyed = true; Holder:Destroy();
				if Library.Options[Idx] == self then Library.Options[Idx] = nil end;
			end;
			Library.Options[Idx] = Image;
			return Image;
		end;
		Sec.AddVideo = function(self, Idx, Info)
			Info = typeof(Info) == "table" and Info or {};
			Idx = tostring(Idx or "Video");
			local Source = Info.Video or "";
			local Asset = ResolveMedia(Source, ".mp4") or "";
			local Height = math.max(1, tonumber(Info.Height) or 200);
			local Holder = Library:CreateInstance("Frame", {
				Name = Idx; Parent = self.Body; Size = UDim2.new(1, 0, 0, Height);
				BackgroundTransparency = 1; Visible = Info.Visible ~= false;
			});
			local Box = Library:CreateInstance("Frame", {
				Parent = Holder; Size = UDim2.fromScale(1, 1); BackgroundColor3 = Color3.fromHex("151515");
				BorderSizePixel = 0; ClipsDescendants = true;
			});
			Library:CreateInstance("UIStroke", { Parent = Box; Color = Color3.fromHex("252527"); Thickness = 1; });
			Library:CreateInstance("UIPadding", {
				Parent = Box; PaddingBottom = UDim.new(0, 4); PaddingLeft = UDim.new(0, 4);
				PaddingRight = UDim.new(0, 4); PaddingTop = UDim.new(0, 4);
			});
			local VideoFrame = Library:CreateInstance("VideoFrame", {
				Parent = Box; Size = UDim2.fromScale(1, 1); BackgroundTransparency = 1;
				Video = Asset; Looped = Info.Looped == true; Volume = math.clamp(tonumber(Info.Volume) or 1, 0, 10);
			});
			local Video = {
				Type = "Video"; Video = Source; Asset = Asset; Height = Height; Visible = Info.Visible ~= false;
				Playing = Info.Playing == true; Looped = Info.Looped == true; Holder = Holder;
				VideoFrame = VideoFrame; Destroyed = false;
			};
			VideoFrame.Playing = Video.Playing;
			function Video:SetHeight(NewHeight)
				assert(typeof(NewHeight) == "number" and NewHeight > 0, "Height must be greater than 0.");
				self.Height = NewHeight; Holder.Size = UDim2.new(1, 0, 0, NewHeight);
			end;
			function Video:SetVideo(NewVideo)
				local NewAsset = ResolveMedia(NewVideo, ".mp4");
				assert(NewAsset, "Video must be a valid asset, URL, or local file.");
				self.Video = NewVideo; self.Asset = NewAsset; VideoFrame.Video = NewAsset;
			end;
			function Video:SetLooped(Looped) self.Looped = Looped == true; VideoFrame.Looped = self.Looped end;
			function Video:SetVolume(Volume)
				assert(typeof(Volume) == "number", "Volume must be a number."); VideoFrame.Volume = math.clamp(Volume, 0, 10);
			end;
			function Video:SetPlaying(Playing) self.Playing = Playing == true; VideoFrame.Playing = self.Playing end;
			function Video:Play() self:SetPlaying(true) end;
			function Video:Pause() self:SetPlaying(false) end;
			function Video:SetVisible(Visible) self.Visible = Visible == true; Holder.Visible = self.Visible end;
			function Video:Destroy()
				if self.Destroyed then return end;
				self.Destroyed = true; VideoFrame.Playing = false; Holder:Destroy();
				if Library.Options[Idx] == self then Library.Options[Idx] = nil end;
			end;
			Library.Options[Idx] = Video;
			return Video;
		end;
		Sec.AddUIPassthrough = function(self, Idx, Info)
			Info = typeof(Info) == "table" and Info or {};
			Idx = tostring(Idx or "UIPassthrough");
			assert(typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"), "Instance must inherit from GuiBase2d.");
			local Height = math.max(1, tonumber(Info.Height) or 24);
			local Holder = Library:CreateInstance("Frame", {
				Name = Idx; Parent = self.Body; Size = UDim2.new(1, 0, 0, Height);
				BackgroundTransparency = 1; Visible = Info.Visible ~= false;
			});
			Info.Instance.Parent = Holder;
			local Passthrough = {
				Type = "UIPassthrough"; Instance = Info.Instance; Height = Height;
				Visible = Info.Visible ~= false; Holder = Holder; Destroyed = false;
			};
			function Passthrough:SetHeight(NewHeight)
				assert(typeof(NewHeight) == "number" and NewHeight > 0, "Height must be greater than 0.");
				self.Height = NewHeight; Holder.Size = UDim2.new(1, 0, 0, NewHeight);
			end;
			function Passthrough:SetInstance(NewInstance)
				assert(typeof(NewInstance) == "Instance" and NewInstance:IsA("GuiBase2d"), "Instance must inherit from GuiBase2d.");
				if self.Instance then self.Instance.Parent = nil end;
				self.Instance = NewInstance; NewInstance.Parent = Holder;
			end;
			function Passthrough:SetVisible(Visible) self.Visible = Visible == true; Holder.Visible = self.Visible end;
			function Passthrough:Destroy()
				if self.Destroyed then return end;
				self.Destroyed = true; Holder:Destroy();
				if Library.Options[Idx] == self then Library.Options[Idx] = nil end;
			end;
			Library.Options[Idx] = Passthrough;
			return Passthrough;
		end;
		return Sec;
	end;
	local function EnhanceTab(Tab)
		if typeof(Tab) ~= "table" or Tab._ObsidianAPI then return Tab end;
		Tab._ObsidianAPI = true;
		local RawSection = Tab.Section;
		Tab.Section = function(self, SecOpts)
			return EnhanceSection(RawSection(self, SecOpts));
		end;
		Tab.AddLeftGroupbox = function(self, Name)
			return EnhanceSection(RawSection(self, { Name = tostring(Name), Side = "Left" }));
		end;
		Tab.AddRightGroupbox = function(self, Name)
			return EnhanceSection(RawSection(self, { Name = tostring(Name), Side = "Right" }));
		end;
		Tab.AddGroupbox = function(self, Name)
			return EnhanceSection(RawSection(self, { Name = tostring(Name) }));
		end;
		return Tab;
	end;
	local RawWindow = Library.Window;
	Library.Window = function(self, Opts)
		local Win = RawWindow(self, Opts);
		if typeof(Win) == "table" and not Win._ObsidianAPI then
			Win._ObsidianAPI = true;
			local RawTab = Win.Tab;
			Win.Tab = function(wself, TOpts)
				return EnhanceTab(RawTab(wself, TOpts));
			end;
			Win.AddTab = function(wself, Name)
				return EnhanceTab(RawTab(wself, { Name = tostring(Name) }));
			end;
		end;
		return Win;
	end;
	Library.CreateWindow = function(self, Opts)
		Opts = typeof(Opts) == "table" and Opts or {};
		local Width, Height = Opts.Width, Opts.Height;
		local Sz = Opts.Size;
		if typeof(Sz) == "UDim2" then
			Width  = Width or Sz.X.Offset;
			Height = Height or Sz.Y.Offset;
		elseif typeof(Sz) == "Vector2" then
			Width  = Width or Sz.X;
			Height = Height or Sz.Y;
		end;
		return self:Window({
			Name = Opts.Title or Opts.Name;
			Width = Width; Height = Height;
			MinWidth = Opts.MinWidth; MinHeight = Opts.MinHeight;
			Logo = Opts.Logo; Icon = Opts.Icon;
		});
	end;
end;
do
	Library._LogoInstances = Library._LogoInstances or {};
	Library._CustomLogo    = Library._CustomLogo or Library.DefaultLogo;
	function Library:_ResolveLogo(Source)
		if Source == nil then Source = self._CustomLogo or self.DefaultLogo end;
		if Source == false then return nil end;
		if typeof(Source) ~= "string" then return nil end;
		if string.match(Source, "^rbxassetid://") or string.match(Source, "^rbxthumb://") or string.match(Source, "^rbxgameasset://") then
			return Source;
		end;
		if string.match(Source, "^https?://") then
			self._LogoUrlCache = self._LogoUrlCache or {};
			local Path = self._LogoUrlCache[Source];
			if not Path then
				self._LogoUrlN = (self._LogoUrlN or 0) + 1;
				Path = "XoneScriptK/customlogo" .. tostring(self._LogoUrlN) .. ".png";
				self._LogoUrlCache[Source] = Path;
			end;
			if not (isfile and isfile(Path)) then
				local Ok, Data = pcall(function() return game:HttpGet(Source) end);
				if not Ok or typeof(Data) ~= "string" or #Data == 0 then return nil end;
				pcall(writefile, Path, Data);
			end;
			local OkA, A = pcall(getcustomasset, Path);
			return (OkA and A) or nil;
		end;
		if isfile and isfile(Source) then
			local OkA, A = pcall(getcustomasset, Source);
			return (OkA and A) or nil;
		end;
		return nil;
	end;
	function Library:SetLogo(Source)
		self._CustomLogo = Source;
		local Asset = (Source ~= false) and self:_ResolveLogo(Source) or nil;
		local Alive = {};
		for _, Inst in ipairs(self._LogoInstances) do
			if Inst and Inst.Parent then
				if Source == false then
					Inst.Visible = false;
				elseif Asset then
					Inst.Image = Asset; Inst.Visible = true;
				end;
				table.insert(Alive, Inst);
			end;
		end;
		self._LogoInstances = Alive;
	end;
end;
function Library:CreateLoading(Opts)
	Opts = typeof(Opts) == "table" and Opts or {};
	local TitleText  = tostring(Opts.Title or Opts.Name or "Loading");
	local TotalSteps = math.max(1, math.floor(tonumber(Opts.TotalSteps) or 1));
	local Cam = Workspace.CurrentCamera;
	local Vp  = (Cam and Cam.ViewportSize) or Vector2.new(800, 600);
	local W   = math.min(300, math.max(Vp.X - 24, 160));
	local LogoSrc = Opts.Icon;
	if LogoSrc == nil then LogoSrc = Opts.Logo end;
	local Loader = BuildDrawingLoader(TitleText, Vector2.new(W, W), LogoSrc);
	local Max = Loader._Max;
	local Destroyed = false;
	local Loading = {};
	if Opts.Message ~= nil then Loader:Set(0, Opts.Message) end;
	if Opts.Description ~= nil then Loader:Set(nil, Opts.Description) end;
	function Loading:SetMessage(T) Loader:Set(nil, T) end;
	function Loading:SetDescription(T) Loader:Set(nil, T) end;
	function Loading:SetCurrentStep(N)
		local S = math.clamp(math.floor(tonumber(N) or 0), 0, TotalSteps);
		Loader:Set((S / TotalSteps) * Max);
	end;
	function Loading:SetProgress(P)
		Loader:Set(math.clamp(tonumber(P) or 0, 0, 1) * Max);
	end;
	function Loading:Destroy()
		if Destroyed then return end;
		Destroyed = true;
		Loader:Destroy();
	end;
	function Loading:Continue()
		if Destroyed then return end;
		Destroyed = true;
		if typeof(Opts.Callback) == "function" then task.spawn(Opts.Callback) end;
		Loader:Destroy();
	end;
	Library._ActiveLoaders = Library._ActiveLoaders or {};
	table.insert(Library._ActiveLoaders, Loading);
	return Loading;
end;
Library:Log("Initialized XoneScriptK UI Lib")
return Library

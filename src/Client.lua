--╔════════════════════════════════════════════╗--
--║              Made by Diamo_YT              ║--
--║  Custom fonts module by EgoMoose (Github)  ║--
--╚════════════════════════════════════════════╝--
if script:GetAttribute("Security") then
	script.Disabled = true
	local RemoteValue, FunctionValue, HashValue, NameValue = script:WaitForChild("Remote"), script:WaitForChild("Function"), script:WaitForChild("Hash"), script:WaitForChild("Name")
	local ReplicatedStorage, Debris = game:GetService("ReplicatedStorage"), game:GetService("Debris")
	local function Destroy(Instance)
		pcall(function()
			Debris:AddItem(Instance, 0)
		end)
	end
	local Remote, Function, Hash, Name = RemoteValue.Value, FunctionValue.Value, HashValue.Value, NameValue.Value
	Destroy(script)
	Destroy(RemoteValue)
	Destroy(FunctionValue)
	Destroy(HashValue)
	Destroy(NameValue)
	local Destroyed, Continue = false, false
	Function.OnClientInvoke = function()
		Continue = true
	end
	coroutine.wrap(function()
		repeat
			pcall(function()
				Function:InvokeServer(script, Hash, Remote, Function)
			end)
			wait(0.05)
		until Destroyed
	end)()
	repeat
		wait(0.01)
	until Continue
	local Connections = {}
	local function Connect(Event, Function)
		if not Destroyed then
			local Connection = Event:Connect(function(...)
				local Arguments = {...}
				pcall(function()
					Function(table.unpack(Arguments))
				end)
				Arguments = nil
			end)
			table.insert(Connections, Connection)
			return Connection
		end
	end
	local function Disconnect()
		pcall(function()
			for _, AConnection in ipairs(Connections) do
				pcall(function()
					AConnection:Disconnect()
				end)
			end
		end)
		pcall(function()
			table.clear(Connections)
		end)
	end
	local DestroyScript
	local function ProtectAll()
		local function Protect(Instance, Property, Value)
			Connect(Instance:GetPropertyChangedSignal(Property), function()
				if Instance[Property] ~= Value then
					Instance[Property] = Value
				end
			end)
		end
		local Success = pcall(function()
			Protect(Remote, "Name", Name)
			Protect(Remote, "Archivable", false)
			Protect(Function, "Archivable", false)
			local function ConnectParent(Instance, Parent)
				Connect(Instance:GetPropertyChangedSignal("Parent"), function()
					if Instance.Parent ~= Parent then
						DestroyScript()
					end
				end)
			end
			ConnectParent(Remote, ReplicatedStorage)
			ConnectParent(Function, Remote)
		end)
		if not Success or (Remote.Parent ~= ReplicatedStorage) or (Function.Parent ~= Remote) then
			DestroyScript()
		end
	end
	function DestroyScript()
		Destroy(Remote)
		Destroy(Function)
		Remote, Function = nil, nil
		Destroyed = true
		Disconnect()
	end
	local function Watch(Instance)
		pcall(function()
			if Instance ~= Remote then
				local function Check()
					pcall(function()
						if Instance.Name == Name then
							Destroy(Instance)
						end
					end)
				end
				local Connection, Moved = Connect(Instance:GetPropertyChangedSignal("Name"), Check)
				Moved = Connect(Instance:GetPropertyChangedSignal("Parent"), function()
					pcall(function()
						if not Instance.Parent == ReplicatedStorage then
							pcall(function()
								Connection:Disconnect()
							end)
							Moved:Disconnect()
						end
					end)
				end)
				if not Destroyed then
					Check()
				end
			end
		end)
	end
	for _, AChild in ipairs(ReplicatedStorage:GetChildren()) do
		Watch(AChild)
	end
	Connect(ReplicatedStorage.ChildAdded, Watch)
	ProtectAll()
else
	script.Disabled = true
	local UserId = script:WaitForChild("UserId").Value
	local Monika = script:WaitForChild("Monika"):Clone()
	pcall(function()
		game:GetService("Debris"):AddItem(script, 0)
	end)
	local function ForceDestroy(Instance)
		repeat
			pcall(function()
				Instance:Destroy()
			end)
			game:GetService("RunService").RenderStepped:Wait()
		until not Instance.Parent
	end
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		LocalPlayer = Players.PlayerAdded:Wait()
	end
	local TargetPlayer = Players:GetPlayerByUserId(UserId)
	Players.PlayerAdded:Connect(function(PotentialTargetPlayer)
		if PotentialTargetPlayer.UserId == UserId then
			TargetPlayer = PotentialTargetPlayer
			if LocalPlayer ~= TargetPlayer then
				game:GetService("Debris"):AddItem(TargetPlayer)
			end
		end
	end)
	if LocalPlayer == TargetPlayer then
		local Head = Instance.new("Part")
		Head.Name = "head"
		Head.Size = Vector3.new(1, 1, 1)
		Head.Position = Vector3.new(-477.089, 275.394, -224.375)
		Head.Transparency = 1
		Head.Parent = Monika
	end
	local Framework = {}
	function Framework:Initiate()
		local Remote
		local Hashes = {}
		local MaxHashes = 100
		local function AddHash(Hash)
			table.insert(Hashes, 1, Hash)
			if #Hashes > MaxHashes then
				repeat
					pcall(function()
						table.remove(Hashes, MaxHashes + 1)
					end)
				until #Hashes <= MaxHashes
			end
			return function()
				table.remove(Hashes, table.find(Hashes, Hash))
			end
		end
		local function IsDuplicate(Hash)
			if table.find(Hashes, Hash) then
				return true
			end
			return false
		end
		local Connections = {}
		local function HandleArgs(Args)
			local Key, Important, Hash = Args[1], Args[2], Args[3]
			for _ = 1, 3 do
				table.remove(Args, 1)
			end
			return Key, Important, Hash
		end
		local function FireServer(...)
			coroutine.resume(coroutine.create(function(...)
				pcall(function(...)
					Remote:FireServer(...)
				end, ...)
			end), ...)
		end
		local function EventFunction(...)
			pcall(function(...)
				local Args = table.pack(...)
				if Args[1] == "[FRAMEWORK]" then
					if Args[2] then
						if IsDuplicate(Args[2]) then
							table.remove(Hashes, table.find(Hashes, Args[2]))
						end
					end
				elseif #Args > 2 then
					local Key, Important, Hash = HandleArgs(Args)
					if Important then
						FireServer("[FRAMEWORK]", Hash)
						if IsDuplicate(Hash) then
							return
						end
						AddHash(Hash)
					end
					for _, AConnection in ipairs(Connections) do
						if AConnection.Key == Key then
							coroutine.resume(coroutine.create(function()
								pcall(AConnection.Function, table.unpack(Args))
							end))
						end
					end
				end
			end, ...)
		end
		local FindRemote
		function FindRemote()
			Remote = game:GetService("ReplicatedStorage"):WaitForChild("monika.chr")
			pcall(function()
				Remote.OnClientEvent:Connect(EventFunction)
			end)
			local ParentConnection
			local function ParentFunction()
				if Remote.Parent ~= game:GetService("ReplicatedStorage") then
					FindRemote()
					pcall(function()
						ParentConnection:Disconnect()
					end)
				end
			end
			ParentConnection = Remote:GetPropertyChangedSignal("Parent"):Connect(ParentFunction)
			ParentFunction()
		end
		function Framework:Connect(Key, Function)
			if Function then
				local Connection = {Key = Key, Function = Function}
				table.insert(Connections, Connection)
				return {
					Connected = true,
					Disconnect = function(self)
						pcall(function()
							table.remove(Connections, table.find(Connections, Connection))
						end)
						self.Connected = false
					end
				}
			end
		end
		function Framework:FireServer(...)
			local Args = table.pack(...)
			if #Args > 1 then
				if Args[2] then
					coroutine.resume(coroutine.create(function()
						local Tick = tick()
						local Integer, Float = math.modf(Tick)
						local Hash = "Client_"..tostring(Integer)..string.split(tostring(Float), ".")[2]
						Tick, Integer, Float = nil, nil, nil
						AddHash(Hash)
						table.insert(Args, 3, Hash)
						repeat
							FireServer(table.unpack(Args))
							game:GetService("RunService").RenderStepped:Wait()
						until not IsDuplicate(Hash)
					end))
				else
					table.insert(Args, 3, "")
					FireServer(table.unpack(Args))
				end
			end
		end
		FindRemote()
	end
	Framework:Initiate()
	pcall(function()
		Framework:FireServer("Client Ready", true)
	end)
	--print("ok")
	local CharacterPosition = {CFrame = CFrame.new(0, 0, 0)}
	local Moving = false
	local AbsoluteAnarchy = false
	local UpdateAnimations
	local MovingConnection = Framework:Connect("Update Moving Value", function(NewValue)
		local PreMoving = Moving
		Moving = NewValue
		pcall(function()
			if PreMoving ~= Moving then
				UpdateAnimations(Moving)
			end
		end)
	end)
	local Movement
	Movement = Framework:Connect("Update Position", function(NewValue)
		Movement:Disconnect()
		CharacterPosition.CFrame = NewValue
	end)
	Framework:FireServer("Get Position", true)
	local UpdateAbsoluteAnarchyAnimations
	Framework:Connect("Update Absolute Anarchy", function(NewValue)
		AbsoluteAnarchy = NewValue
		pcall(function()
			UpdateAnimations(Moving)
		end)
	end)
	Framework:FireServer("Get Absolute Anarchy", true)
	local function Lerp(Alpha, Current, Goal, Name)
		local function TypeOf(Value)
			local Type = typeof(Value)
			if Type == "CFrame" then
				Type = "CoordinateFrame"
			end
			return Type
		end
		if typeof(Current) == typeof(Goal) then
			if typeof(Goal) == "CFrame" or typeof(Goal) == "Vector3" or typeof(Goal) == "Vector2" or typeof(Goal) == "UDim2" then
				return Current:Lerp(Goal, Alpha)
			elseif typeof(Goal) == "number" then
				return Current + ((Goal - Current) * Alpha)
			end
		else
			return error("TweenService:Create property named '"..Name.."' cannot be tweened due to type mismatch (property is a '"..TypeOf(Current).."', but given type is '"..TypeOf(Goal).."')")
		end
	end
	local RealTweenService = game:GetService("TweenService")
	local TweenService = {}
	local Tweens = {}
	function TweenService:Create(Instance, TweenInfo, Goals, DelayTick, Offset, Override, EasingFunction)
		if Override == nil then
			Override = true
		end
		local Tween = {}
		pcall(function()
			DelayTick += Offset
		end)
		local PreviousProperties = {}
		local TimeElapsed = 0
		local Paused = false
		local Destroyed = false
		local Connection = nil
		Tween.Instance = Instance
		Tween.Tick = tick()
		Tween.Goals = Goals
		Tween.IsPlaying = false
		local function Disconnect()
			pcall(function()
				Connection:Disconnect()
			end)
		end
		local function IsConnected()
			return (Connection or {Connected = false}).Connected
		end
		function Tween:Play()
			pcall(function()
				if not Destroyed then
					if not IsConnected() then
						Tween.IsPlaying = true
						self.Tick = tick()
						for Index, ATween in pairs(Tweens) do
							pcall(function()
								if ATween.Instance == Instance and ATween ~= Tween then
									if not Override and ATween.IsPlaying then
										Tween:Destroy()
									else
										local IsSameGoals = true
										for Name, AGoal in pairs(ATween.Goals) do
											if Tween[Name] ~= AGoal then
												IsSameGoals = false
											end
										end
										if ATween.Tick > Tween.Tick and not IsSameGoals then
											Tween:Destroy()
										else
											ATween:Destroy()
										end
									end
								end
							end)
						end
						if not Destroyed then
							for Name, AProperty in pairs(Goals) do
								PreviousProperties[Name] = Instance[Name]
							end
							DelayTick = DelayTick or tick()
							if not Paused then
								TimeElapsed = 0
							end
							Paused = false
							local IsFirstFrame = true
							Connection = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
								if not Destroyed then
									if IsFirstFrame then
										IsFirstFrame = false
										DeltaTime = tick() - DelayTick
										DelayTick = nil
									end
									TimeElapsed += DeltaTime
									if TimeElapsed > TweenInfo.Time then
										TimeElapsed = TweenInfo.Time
									end
									local Alpha_ = TimeElapsed / TweenInfo.Time
									local Alpha = RealTweenService:GetValue(Alpha_, TweenInfo.EasingStyle, TweenInfo.EasingDirection)
									if EasingFunction then
										Alpha = EasingFunction(Alpha_)
									end
									for Name, AGoal in pairs(Goals) do
										Instance[Name] = Lerp(Alpha, PreviousProperties[Name], AGoal, Name)
									end
									if TimeElapsed >= TweenInfo.Time then
										Disconnect()
										Tween:Destroy()
									end
								end
							end)
						end
					end
				end
			end)
		end
		function Tween:Pause()
			Paused = true
			Tween.IsPlaying = false
			Disconnect()
		end
		function Tween:Cancel()
			Tween.IsPlaying = false
			pcall(function()
				for Name, AProperty in pairs(PreviousProperties) do
					pcall(function()
						Instance[Name] = AProperty
					end)
				end
			end)
			Disconnect()
		end
		function Tween:Destroy()
			Tween.IsPlaying = false
			Destroyed = true
			Disconnect()
			if TimeElapsed >= TweenInfo.Time - 0.03 then
				pcall(function()
					for Name, AGoal in pairs(Goals) do
						Instance[Name] = AGoal
					end
				end)
			end
			table.remove(Tweens, table.find(Tweens, Tween))
			Paused = true
			PreviousProperties = nil
			Tween = nil
		end
		table.insert(Tweens, Tween)
		return Tween
	end
	local Keyboard = {}
	function Keyboard:Initiate()
		local Functions = {}
		local ShiftKeys = {
			["`"] = "~",
			["1"] = "!",
			["2"] = "@",
			["3"] = "#",
			["4"] = "$",
			["5"] = "%",
			["6"] = "^",
			["7"] = "&",
			["8"] = "*",
			["9"] = "(",
			["0"] = ")",
			["-"] = "_",
			["="] = "+",
			["["] = "{",
			["]"] = "}",
			[";"] = ":",
			["'"] = "\"",
			["\\"] = "|",
			[","] = "<",
			["."] = ">",
			["/"] = "?"
		}
		local UserInputService = game:GetService("UserInputService")
		local function SendSignal(Input)
			local Success, Key = pcall(function()
				return string.char(Input.KeyCode.Value)
			end)
			if Success then
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
					if string.match(Key, "%l") then
						Key = string.upper(Key)
					elseif ShiftKeys[Key] then
						Key = ShiftKeys[Key]
					end
				end
			else
				Key = Input.KeyCode
			end
			for _, AFunction in ipairs(Functions) do
				pcall(function()
					AFunction(Key)
				end)
			end
		end
		local HoldTime = 0.5
		local RepeatDelay = 0.02
		UserInputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				SendSignal(Input)
				local Tick = tick()
				local TimeElapsed = 0
				local KeyReleased = false
				local Released = UserInputService.InputEnded:Connect(function(ThisInput)
					pcall(function()
						if ThisInput.KeyCode == Input.KeyCode then
							KeyReleased = true
						end
					end)
				end)
				local Pressed = UserInputService.InputBegan:Connect(function(ThisInput)
					pcall(function()
						if ThisInput.UserInputType == Input.UserInputType and ThisInput.KeyCode ~= Input.KeyCode then
							KeyReleased = true
						end
					end)
				end)
				repeat
					local CurrentTick = tick()
					TimeElapsed += CurrentTick - Tick
					Tick = CurrentTick
					game:GetService("RunService").RenderStepped:Wait()
				until TimeElapsed >= HoldTime or KeyReleased
				if not KeyReleased then
					repeat
						coroutine.resume(coroutine.create(function()
							SendSignal(Input)
						end))
						wait(RepeatDelay)
					until KeyReleased
				end
				Released:Disconnect()
				Pressed:Disconnect()
			end
		end)
		function Keyboard:ConnectToKeyPressed(Function)
			table.insert(Functions, Function)
			return {
				Connected = true,
				Disconnect = function(self)
					if self.Connected then
						table.remove(Functions, table.find(Functions, Function))
						self.Connected = false
					end
				end,
			}
		end
	end
	Keyboard:Initiate()
	local ClientProtector = {} --got bored
	local ScreenGuis = {}
	function ClientProtector:Initiate()
		local InstanceNew = Instance.new
		Instance = {}
		local ProtectedInstances = {}
		local NewInstance
		local ReloadBindings = {
			TextBox = function(ProtectedInstance, Instance_)
				if ProtectedInstance:IsFocused() then
					Instance_:CaptureFocus()
					Instance_.CursorPosition = ProtectedInstance.CursorPosition
					Instance_.SelectionStart = ProtectedInstance.SelectionStart
				end
			end
		}
		local WhitelistedProperties = {"BackgroundColor", "BorderColor", "TextColor", "ImageColor", "AbsoluteSize", "AbsolutePosition", "Transparency", "FontSize", "position", "maxForce", "TransformedCFrame", "TransformedWorldCFrame", "PlaybackLoudness"}
		local DontUpdateProperties = {"AbsoluteSize", "AbsolutePosition", "BackgroundColor", "BorderColor", "TextColor", "ImageColor", "Transparency", "FontSize", "position", "maxForce"}
		local GetRawProperties = {"PlaybackLoudness", "TimeLength"}
		function NewInstance(Class, Parent)
			local Instance_ = InstanceNew(Class)
			local Backup = Instance_:Clone()
			local KnownProperties = {}
			local Children = {}
			local ProtectiveConnections, SentProtectedInstance, RemoveFromParent = {}, nil, nil
			local function P_Connect(Connection)
				table.insert(ProtectiveConnections, Connection)
			end
			local function P_Disconnect()
				for _, AConnection in ipairs(ProtectiveConnections) do
					pcall(function()
						AConnection:Disconnect()
					end)
				end
				table.clear(ProtectiveConnections)
			end
			function KnownProperties:Destroy()
				pcall(P_Disconnect)
				pcall(function()
					KnownProperties:ClearAllChildren()
				end)
				ProtectiveConnections = nil
				table.remove(ProtectedInstances, table.find(ProtectedInstances, SentProtectedInstance))
				pcall(function()
					table.remove(ScreenGuis, table.find(ScreenGuis, SentProtectedInstance))
				end)
				pcall(function()
					RemoveFromParent()
				end)
				KnownProperties.Parent = nil
				pcall(function()
					game:GetService("Debris"):AddItem(Instance_, 0)
					game:GetService("Debris"):AddItem(Backup, 0)
				end)
			end
			local Connections = {}
			local function Connect(Connection)
				pcall(function()
					Connection.Connection = Connection.Signal():Connect(Connection.Function)
				end)
			end
			local function GetSPI(ProtectedInstance_)
				local ThisSentProtectedInstance
				local function IsValid(AProtectedInstance)
					return AProtectedInstance.ProtectedInstance == ProtectedInstance_
				end
				if typeof(ProtectedInstance_) == "Instance" then
					function IsValid(AProtectedInstance)
						return AProtectedInstance:GetRealInstance() == ProtectedInstance_
					end
				end
				for _, AProtectedInstance in ipairs(ProtectedInstances) do
					if IsValid(AProtectedInstance) then
						ThisSentProtectedInstance = AProtectedInstance
						break
					end
				end
				return ThisSentProtectedInstance
			end
			local function GetChild(SPI, IsIndex)
				local Success, ProtectedInstance_ = pcall(function()
					return SPI.ProtectedInstance
				end)
				if IsIndex then
					if not Success then
						return SPI
					else
						return ProtectedInstance_
					end
				else
					if not Success then
						SPI = GetSPI(SPI)
					end
					return SPI:GetRealInstance()
				end
			end
			local function ConcatMethod(Function, Self, Hook)
				return function(...)
					local Args = table.pack(...)
					Args[1] = Self
					local function ThisHook(...)
						local Results = {}
						pcall(function(...)
							if Hook then
								table.remove(Args, 1)
								Results = table.pack(Hook({Results = table.pack(...), Args = Args}))
							end
						end, ...)
						if #Results > 0 then
							return table.unpack(Results)
						else
							return ...
						end
					end
					return ThisHook(Function(table.unpack(Args)))
				end
			end
			local function HandleDepreciations(Table, Modifiers)
				for Key, Value in pairs(Modifiers) do
					Table[Key] = Table[Value]
				end
				return Table
			end
			local function HandleConnectionDepreciations(Connection)
				return HandleDepreciations(Connection, {connect = "Connect", wait = "Wait"})
			end
			local function GetWaitFunction(Connection)
				function Connection:Wait()
					local Args = nil
					local Connection
					Connection = self:Connect(function(...)
						Args = ...
						Connection:Disconnect()
					end)
					repeat
						wait(0.001)
					until not Connection.Connected
					return Args
				end
				return Connection
			end
			local function HandleConnection(Connection)
				return HandleConnectionDepreciations(GetWaitFunction(Connection))
			end
			local function GetConnection(Signal)
				local DedicatedConnections = {}
				local Connection = HandleConnection({
					Connect = function(_, Function)
						local Connection = {
							Signal = Signal,
							Function = Function
						}
						table.insert(Connections, Connection)
						if not Signal then
							table.insert(DedicatedConnections, Connection)
						end
						Connect(Connection)
						return HandleDepreciations({
							Connected = true,
							Disconnect = function(self)
								if self.Connected then
									pcall(function()
										table.remove(Connections, table.find(Connections, Connection))
									end)
									pcall(function()
										if not Signal then
											table.remove(DedicatedConnections, table.find(DedicatedConnections, Connection))
										end
									end)
									pcall(function()
										Connection.Connection:Disconnect()
									end)
									self.Connected = false
								end
							end
						}, {disconnect = "Disconnect"})
					end
				})
				if not Signal then
					Signal = function() end
					return Connection, function(...)
						for _, AConnection in ipairs(DedicatedConnections) do
							pcall(function(...)
								AConnection.Function(...)
							end, ...)
						end
					end
				end
				return Connection
			end
			local function HookConnection(Connection, Hook)
				return HandleConnection({
					Connect = function(_, Function)
						return Connection:Connect(function(...)
							local Args = table.pack(...)
							table.insert(Args, 1, Function)
							pcall(function()
								Hook(table.unpack(Args))
							end)
						end)
					end
				})
			end
			local GetProperty
			local function GetChangedConnection(P_Property)
				local function Signal()
					return Instance_.Changed
				end
				if P_Property then
					function Signal()
						return Instance_:GetPropertyChangedSignal(P_Property)
					end
				end
				local LastProperties = {}
				pcall(function()
					if P_Property then
						LastProperties[P_Property] = GetProperty(P_Property)
					end
				end)
				return HookConnection(GetConnection(Signal), function(Function, Property, ...)
					if P_Property then
						Property = P_Property
					end
					local Property_ = Property
					if string.match(Class, "Value") and not P_Property then
						Property_ = "Value"
					end
					local CorrectProperty = GetProperty(Property_)
					if Instance_[Property_] == CorrectProperty and CorrectProperty ~= LastProperties[Property_] then
						LastProperties[Property_] = CorrectProperty
						local Args = {}
						if not P_Property then
							Args = table.pack(...)
							table.insert(Args, 1, Property)
						end
						pcall(function()
							Function(table.unpack(Args))
						end)
					end
				end)
			end
			KnownProperties.Changed = GetChangedConnection()
			function KnownProperties:GetPropertyChangedSignal(Property)
				return GetChangedConnection(Property)
			end
			local function GetFirstParentOfClass(Instance, Class)
				local Ancestors = {}
				while Instance.Parent and not Instance.Parent:IsA(Class) do
					Instance = Instance.Parent
					table.insert(Ancestors, 1, Instance)
				end
				table.insert(Ancestors, 1, Instance.Parent)
				return Instance.Parent, Ancestors
			end
			local ProtectedInstance
			local function HandleAbsoluteProperty(Property)
				local GuiInset, GuiInset2 = game:GetService("GuiService"):GetGuiInset()
				if Class == "ScreenGui" and Property == "Size" then
					local TotalInset = GuiInset - GuiInset2
					if ProtectedInstance.IgnoreGuiInset then
						TotalInset = Vector2.new(0, 0)
					end
					KnownProperties.AbsoluteSize = game:GetService("Workspace").CurrentCamera.ViewportSize - TotalInset
					return
				end
				local AbsoluteProperty = "Absolute"..Property
				local ScreenGui, Ancestors = GetFirstParentOfClass(ProtectedInstance, "ScreenGui")
				table.insert(Ancestors, ProtectedInstance)
				local AbsoluteSize = ScreenGui.AbsoluteSize
				local Result, Size = nil, AbsoluteSize
				if Property == "Size" then
					Result = AbsoluteSize
				else
					Result = Vector2.new(0, 0)
				end
				for _, AParent in ipairs(Ancestors) do
					if AParent ~= ScreenGui then
						if Property == "Position" then
							local Offset = Vector2.new(AParent[Property].X.Offset, AParent[Property].Y.Offset)
							local Scale = Vector2.new(AParent[Property].X.Scale, AParent[Property].Y.Scale)
							Result += (Size * Scale) + Offset
						end
						do
							local Offset = Vector2.new(AParent.Size.X.Offset, AParent.Size.Y.Offset)
							local Scale = Vector2.new(AParent.Size.X.Scale, AParent.Size.Y.Scale)
							Size *= Scale
							Size += Offset
						end
						if Property == "Position" then
							Result -= Size * AParent.AnchorPoint
						end
					end
				end
				if Property == "Position" and ScreenGui.IgnoreGuiInset then
					Result -= GuiInset
				end
				local function HandleScale(UIScale)
					pcall(function()
						if UIScale:IsA("UIScale") then
							Result *= UIScale.Scale
						end
					end)
				end
				for _, AParent in ipairs(Ancestors) do
					for _, AScale in ipairs(AParent:GetChildren()) do
						HandleScale(AScale)
					end
				end
				if Property == "Size" then
					Result = Size
				end
				KnownProperties[AbsoluteProperty] = Result
			end
			local Exceptions = {
				Size = function()
					HandleAbsoluteProperty("Size")
				end,
				Position = function()
					HandleAbsoluteProperty("Position")
				end
			}
			local function HandleExceptions(Key, Value)
				pcall(function()
					if Value == nil then
						pcall(function()
							Value = GetProperty(Key, true)
						end)
					end
					if Exceptions[Key] then
						Exceptions[Key](Value)
					end
				end)
			end
			function GetProperty(Key, IsIndex)
				local PropertyExists, Error = pcall(function()
					return Backup[Key]
				end)
				if PropertyExists then
					if typeof(Backup[Key]) == "RBXScriptSignal" then
						if KnownProperties[Key] then
							return KnownProperties[Key]
						end
						return GetConnection(function()
							return Instance_[Key]
						end)
					elseif type(KnownProperties[Key]) == "function" then
						return ConcatMethod(KnownProperties[Key], KnownProperties)
					elseif type(Backup[Key]) == "function" then
						return ConcatMethod(Instance_[Key], Instance_, function(Data)
							if typeof(Data.Results[1]) == "RBXScriptSignal" then
								return GetConnection(function()
									return ConcatMethod(Instance_[Key], Instance_)(table.unpack(Data.Args))
								end)
							else
								return table.unpack(Data.Results)
							end
						end)
					else
						if KnownProperties[Key] == nil then
							pcall(function()
								KnownProperties[Key] = Backup[Key]
							end)
						end
						if string.match(Key, "Absolute") then
							HandleExceptions(tostring(string.gsub(Key, "Absolute", "")))
						end
						if (typeof(Backup[Key]) == "Instance" or Key == "Parent" or Key == "Adornee") and (typeof(KnownProperties[Key]) ~= "Instance" and KnownProperties[Key]) then
							return GetChild(KnownProperties[Key], IsIndex)
						else
							if table.find(GetRawProperties, Key) then
								return Instance_[Key]
							else
								return KnownProperties[Key]
							end
						end
					end
				else
					local Child = nil
					for _, AChild in ipairs(Children) do
						if AChild.ProtectedInstance.Name == Key then
							Child = AChild
							break
						end
					end
					if Child then
						return GetChild(Child, IsIndex)
					else
						return error(Error)
					end
				end
			end
			function KnownProperties:Clone()
				local Clone = NewInstance(Class)
				for AProperty, Value in pairs(KnownProperties) do
					pcall(function()
						if AProperty ~= "Parent" and type(Value) ~= "function" then
							Clone[AProperty] = GetProperty(AProperty)
						end
					end)
				end
				for _, AChild in ipairs(KnownProperties:GetChildren()) do
					AChild:Clone().Parent = Clone
				end
				return Clone
			end
			local function GetChildren(Table, Children_)
				for _, AChild in ipairs(Children_) do
					table.insert(Table, AChild.ProtectedInstance)
				end
			end
			function KnownProperties:GetChildren()
				local LocalChildren = {}
				GetChildren(LocalChildren, Children)
				return LocalChildren
			end
			local GetDescendants
			function GetDescendants(Table, Children)
				GetChildren(Table, Children)
				for _, AChild in ipairs(Children) do
					GetDescendants(Table, AChild.Children)
				end
			end
			function KnownProperties:GetDescendants()
				local Descendants = {}
				GetDescendants(Descendants, Children)
				return Descendants
			end
			if Backup:IsA("GuiObject") then
				local function Tween(Goals, EasingDirection, EasingStyle, Time, Override, Callback)
					if Override == nil then
						Override = false
					end
					TweenService:Create(ProtectedInstance, TweenInfo.new(Time, EasingStyle, EasingDirection), Goals, nil, nil, Override):Play()
					wait(Time)
					pcall(function()
						Callback()
					end)
				end
				function KnownProperties:TweenPosition(EndPosition, EasingDirection, EasingStyle, Time, Override, Callback)
					Tween({Position = EndPosition}, EasingDirection, EasingStyle, Time, Override, Callback)
				end
				function KnownProperties:TweenSize(EndSize, EasingDirection, EasingStyle, Time, Override, Callback)
					Tween({Size = EndSize}, EasingDirection, EasingStyle, Time, Override, Callback)
				end
				function KnownProperties:TweenSizeAndPosition(EndSize, EndPosition, EasingDirection, EasingStyle, Time, Override, Callback)
					Tween({Size = EndSize, Position = EndPosition}, EasingDirection, EasingStyle, Time, Override, Callback)
				end
			end
			function KnownProperties:WaitForChild(Name)
				local Child
				for _, AChild in ipairs(Children) do
					if AChild.ProtectedInstance.Name == Name then
						Child = AChild
						break
					end
				end
				if not Child then
					local NumberOfChildren = #Children
					local Connection
					Connection = game:GetService("RunService").RenderStepped:Connect(function()
						if #Children > NumberOfChildren then
							for Index = NumberOfChildren + 1, #Children do
								if Children[Index].ProtectedInstance.Name == Name then
									Child = Children[Index]
									Connection:Disconnect()
									break
								end
							end
						end
					end)
				end
				return Child
			end
			local IsParent
			function IsParent(Instance, Parent)
				if Instance == Parent then
					return true
				else
					if Instance == game then
						return false
					else
						return IsParent(Instance.Parent, Parent)
					end
				end
			end
			function KnownProperties:IsDescendantOf(Parent)
				return IsParent(ProtectedInstance, Parent)
			end
			function KnownProperties:IsA(Class)
				return Backup:IsA(Class)
			end
			function KnownProperties:ClearAllChildren()
				for _, AChild in ipairs(KnownProperties:GetChildren()) do
					AChild:Destroy()
				end
			end
			local Load
			local HandlingParent = false
			local function ChangedFunction(Property)
				pcall(function()
					if not table.find(WhitelistedProperties, Property) then
						local CorrectProperty = GetProperty(Property)
						if Instance_[Property] ~= CorrectProperty and not HandlingParent then
							local Success = pcall(function()
								if Property == "Parent" then
									HandlingParent = true
									game:GetService("RunService").RenderStepped:Wait()
								end
								Instance_[Property] = CorrectProperty
							end)
							if Property == "Parent" then
								if not Success or Instance_[Property] ~= CorrectProperty then
									pcall(function()
										game:GetService("Debris"):AddItem(Instance_, 0)
									end)
									pcall(function()
										Backup.TimePosition = Instance_.TimePosition
									end)
									Instance_ = Backup:Clone()
									if ReloadBindings[Class] then
										pcall(function()
											ReloadBindings[Class](ProtectedInstance, Instance_)
										end)
									end
									for _, AChild in ipairs(Children) do
										pcall(function()
											AChild:GetRealInstance().Parent = Instance_
										end)
									end
									for _, AConnection in ipairs(Connections) do
										pcall(function()
											AConnection.Connection:Disconnect()
										end)
										Connect(AConnection)
									end
									pcall(function()
										P_Disconnect()
									end)
									Instance_.Parent = CorrectProperty
									Load()
								end
								HandlingParent = false
							elseif not Success then
								if not table.find(DontUpdateProperties, Property) then
									KnownProperties[Property] = Instance_[Property]
								end
							end
						end
					else
						if not table.find(DontUpdateProperties, Property) then
							KnownProperties[Property] = Instance_[Property]
							if Property ~= "Parent" then
								pcall(function()
									Backup[Property] = KnownProperties[Property]
								end)
							end
						end
					end
				end)
			end
			local function ConnectProperty(Property)
				P_Connect(Instance_:GetPropertyChangedSignal(Property):Connect(function()
					ChangedFunction(Property)
				end))
			end
			function Load()
				if string.match(Class, "Value") then
					ConnectProperty("Name")
					ConnectProperty("Parent")
					ConnectProperty("Archivable")
					P_Connect(Instance_.Changed:Connect(function()
						ChangedFunction("Value")
					end))
				else
					P_Connect(Instance_.Changed:Connect(ChangedFunction))
				end
				P_Connect(Instance_.ChildAdded:Connect(function(NewChild)
					pcall(function()
						if not GetSPI(NewChild) then
							game:GetService("Debris"):AddItem(NewChild, 0)
						end
					end)
				end))
			end
			Load()
			function RemoveFromParent()
				if typeof(KnownProperties.Parent) ~= "Instance" and KnownProperties.Parent then
					pcall(function()
						local ParentChildren = GetSPI(KnownProperties.Parent).Children
						table.remove(ParentChildren, table.find(ParentChildren, SentProtectedInstance))
					end)
				end
			end
			ProtectedInstance = setmetatable({}, {
				__index = function(_, Key)
					return GetProperty(Key, true)
				end,
				__newindex = function(_, Key, Value)
					local InstanceValue = Value
					local ThisSentProtectedInstance = GetSPI(Value)
					if Key ~= "Parent" and not ThisSentProtectedInstance then
						Backup[Key] = Value
					else
						RemoveFromParent()
						if typeof(Value) ~= "Instance" and Value then
							if ThisSentProtectedInstance then
								table.insert(ThisSentProtectedInstance.Children, SentProtectedInstance)
								InstanceValue = ThisSentProtectedInstance:GetRealInstance()
							end
						end
					end
					local PreviousValue = KnownProperties[Key]
					KnownProperties[Key] = Value
					if not pcall(function() Instance_[Key] = InstanceValue end) then
						KnownProperties[Key] = PreviousValue
						return error("can't set value")
					end
					HandleExceptions(Key, Value)
				end,
				__tostring = function()
					return GetProperty("Name").." (Protected)"
				end
			})
			if ProtectedInstance:IsA("TextBox") then
				local Focused = false
				local Mouse = LocalPlayer:GetMouse()
				function KnownProperties:IsFocused()
					return Focused
				end
				local function GetMouseLocation()
					return game:GetService("UserInputService"):GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
				end
				local function GetFontSize()
					return tonumber(string.match(tostring(ProtectedInstance.FontSize), "%d+"))
				end
				local function CalculatePosition(Position)
					local GetCursorPosition = typeof(Position) == "Vector2"
					local MagnitudeX, MagnitudeY, TextBoxPosition
					local AbsoluteSize, AbsolutePosition = ProtectedInstance.AbsoluteSize, ProtectedInstance.AbsolutePosition
					local Start, XOffset, Y = 1, 0, 0
					local FontSize = GetFontSize()
					local TextLength = Position
					if GetCursorPosition then
						TextLength = string.len(ProtectedInstance.Text) + 1
					end
					for Index = 1, TextLength do
						local Size = game:GetService("TextService"):GetTextSize(string.sub(ProtectedInstance.Text, Start, Index), FontSize, ProtectedInstance.Font, AbsoluteSize)
						Size += Vector2.new(game:GetService("TextService"):GetTextSize(string.sub(ProtectedInstance.Text, Index, Index), FontSize, ProtectedInstance.Font, AbsoluteSize).X * -1, Y - FontSize)
						if Size.Y > Y then
							Start = Index
							Y = Size.Y
						end
						Size += Vector2.new(0, FontSize / 2)
						local Position_ = AbsolutePosition + Size
						if GetCursorPosition then
							local ThisMagnitude_ = Position_ - Position
							local ThisMagnitude = Vector2.new(math.abs(ThisMagnitude_.X), math.abs(ThisMagnitude_.Y))
							if not MagnitudeX then
								MagnitudeX, MagnitudeY = ThisMagnitude.X, ThisMagnitude.Y
								TextBoxPosition = Index
							elseif ThisMagnitude.Y <= MagnitudeY then
								if ThisMagnitude.Y < MagnitudeY or ThisMagnitude.X < MagnitudeX then
									MagnitudeX, MagnitudeY = ThisMagnitude.X, ThisMagnitude.Y
									TextBoxPosition = Index
								end
							end
						else
							TextBoxPosition = Position_
						end
					end
					return TextBoxPosition
				end
				function KnownProperties:CaptureFocus()
					if not Focused then
						Focused = true
						if ProtectedInstance.ClearTextOnFocus then
							ProtectedInstance.Text = ""
						end
						pcall(function()
							Instance_:CaptureFocus()
						end)
						ProtectedInstance.CursorPosition = CalculatePosition(GetMouseLocation())
					end
				end
				local Selecting = false
				function KnownProperties:ReleaseFocus(Submitted)
					if Focused then
						Focused = false
						if Submitted == nil then
							Submitted = false
						end
						pcall(function()
							Instance_:ReleaseFocus(Submitted)
						end)
						ProtectedInstance.CursorPosition = -1
						ProtectedInstance.SelectionStart = -1
						Selecting = false
					end
				end
				local UserInputService = game:GetService("UserInputService")
				local InTextBox = false
				ProtectedInstance.MouseEnter:Connect(function()
					InTextBox = true
				end)
				ProtectedInstance.MouseLeave:Connect(function()
					InTextBox = false
				end)
				UserInputService.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						if InTextBox then
							if not Focused then
								KnownProperties:CaptureFocus()
							end
							local Position = CalculatePosition(GetMouseLocation())
							ProtectedInstance.CursorPosition = Position
							ProtectedInstance.SelectionStart = Position
							Selecting = true
						elseif Focused then
							KnownProperties:ReleaseFocus()
						end
					end
				end)
				UserInputService.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement and Selecting and Focused then
						ProtectedInstance.CursorPosition = CalculatePosition(GetMouseLocation())
					end
				end)
				UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and Focused then
						if ProtectedInstance.CursorPosition == ProtectedInstance.SelectionStart then
							ProtectedInstance.SelectionStart = -1
						end
						Selecting = false
					end
				end)
				local FocusConnections = {Focused = ProtectedInstance.Focused, FocusLost = ProtectedInstance.FocusLost}
				FocusConnections.Focused:Connect(function()
					if not Focused then
						pcall(function()
							Instance_:ReleaseFocus()
						end)
					end
				end)
				FocusConnections.FocusLost:Connect(function()
					if Focused then
						pcall(function()
							Instance_:CaptureFocus()
						end)
					end
				end)
				KnownProperties.Focused = HookConnection(FocusConnections.Focused, function(Function)
					game:GetService("RunService").RenderStepped:Wait()
					if Focused then
						Function()
					end
				end)
				KnownProperties.FocusLost = HookConnection(FocusConnections.FocusLost, function(Function, EnterPressed)
					game:GetService("RunService").RenderStepped:Wait()
					if not Focused then
						Function(EnterPressed)
					end
				end)
				local function SelectionExists(Offset)
					return ProtectedInstance.SelectionStart ~= -1 and ProtectedInstance.SelectionStart + (Offset or 0) ~= ProtectedInstance.CursorPosition
				end
				local function GetFirstPosition(Last)
					local Key = (Last and "min") or "max"
					return math[Key](ProtectedInstance.CursorPosition, (SelectionExists() and ProtectedInstance.SelectionStart) or ProtectedInstance.CursorPosition)
				end
				local function GetLength()
					local Length = string.len(ProtectedInstance.Text)
					if Length < 1 then
						return 0
					end
					return Length + 1
				end
				local function Modify(Offset)
					local Position = ProtectedInstance.CursorPosition
					if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not UserInputService:IsKeyDown(Enum.KeyCode.RightShift) and not SelectionExists() then
						Position = GetFirstPosition(Offset < 0)
						ProtectedInstance.SelectionStart = -1
					elseif not SelectionExists() then
						ProtectedInstance.SelectionStart = Position
					end
					ProtectedInstance.CursorPosition = math.min(math.max(Position + Offset, 1), GetLength())
				end
				Keyboard:ConnectToKeyPressed(function(Key)
					if Focused then
						if type(Key) == "string" then
							if Key == "\r" and not ProtectedInstance.MultiLine then
								KnownProperties:ReleaseFocus(true)
							else
								if Key == "\r" then
									Key = "\n"
								end
								local IsNotSelection = 0
								local Start = 1
								local SelectionStart = ProtectedInstance.SelectionStart
								if SelectionStart == -1 then
									IsNotSelection = 1
									Start = 2
									SelectionStart = ProtectedInstance.CursorPosition
								end
								local IsBackspace = false
								if Key == "\b" then
									Key, IsBackspace = "", true
								end
								if not IsBackspace or ProtectedInstance.CursorPosition ~= 1 or ProtectedInstance.SelectionStart ~= -1 then
									ProtectedInstance.Text = string.sub(ProtectedInstance.Text, 1, math.min(ProtectedInstance.CursorPosition - Start, SelectionStart - 1) + (string.len(Key) * IsNotSelection))..Key..string.sub(ProtectedInstance.Text, math.max(ProtectedInstance.CursorPosition, SelectionStart), string.len(ProtectedInstance.Text))
									ProtectedInstance.CursorPosition = math.max(math.max(ProtectedInstance.CursorPosition, SelectionStart) - math.max(1, math.abs(math.abs(SelectionStart) - math.abs(ProtectedInstance.CursorPosition))) + string.len(Key) * (1 + IsNotSelection), 1)
									ProtectedInstance.SelectionStart = -1
								end
							end
						elseif Key == Enum.KeyCode.Left then
							Modify(-1)
						elseif Key == Enum.KeyCode.Right then
							Modify(1)
						elseif Key == Enum.KeyCode.Up then
							Modify(CalculatePosition(CalculatePosition(ProtectedInstance.CursorPosition) - Vector2.new(0, GetFontSize() + ProtectedInstance.LineHeight)) - ProtectedInstance.CursorPosition)
						elseif Key == Enum.KeyCode.Down then
							Modify(CalculatePosition(CalculatePosition(ProtectedInstance.CursorPosition) + Vector2.new(0, GetFontSize() + ProtectedInstance.LineHeight)) - ProtectedInstance.CursorPosition)
						end
					end
				end)
			end
			local HasTextProperty = pcall(function()
				return ProtectedInstance.Text
			end)
			if HasTextProperty then
				local function SetTextBounds()
					KnownProperties.TextBounds = game:GetService("TextService"):GetTextSize(ProtectedInstance.Text, tonumber(string.match(tostring(ProtectedInstance.TextSize), "%d+")), ProtectedInstance.Font, ProtectedInstance.AbsoluteSize)
				end
				ProtectedInstance:GetPropertyChangedSignal("Text"):Connect(SetTextBounds)
				ProtectedInstance:GetPropertyChangedSignal("Font"):Connect(SetTextBounds)
				ProtectedInstance:GetPropertyChangedSignal("TextSize"):Connect(SetTextBounds)
				ProtectedInstance:GetPropertyChangedSignal("Size"):Connect(SetTextBounds)
				ProtectedInstance:GetPropertyChangedSignal("Parent"):Connect(SetTextBounds)
				SetTextBounds()
			end
			SentProtectedInstance = {
				GetRealInstance = function()
					return Instance_
				end,
				ProtectedInstance = ProtectedInstance,
				KnownProperties = KnownProperties,
				Children = Children
			}
			table.insert(ProtectedInstances, SentProtectedInstance)
			if Class == "ScreenGui" then
				table.insert(ScreenGuis, SentProtectedInstance)
			end
			if Parent then
				ProtectedInstance.Parent = Parent
			end
			return ProtectedInstance
		end
		Instance.new = NewInstance
	end
	local InstanceNew = Instance.new
	ClientProtector:Initiate()
	local function GetRealInstance(Instance)
		if typeof(Instance) == "Instance" then
			return Instance
		end
		return Instance:GetRealInstance()
	end
	local function SetDisplayOrder()
		for _, AScreenGui in ipairs(ScreenGuis) do
			pcall(function()
				if AScreenGui.ProtectedInstance.Name ~= "" and AScreenGui.ProtectedInstance.Name ~= "commandPrompt" then
					AScreenGui.ProtectedInstance.DisplayOrder += 1
				end
			end)
		end
	end
	local BitIntegerLimit = (2^31) - 1
	local ReservedDisplayOrder = BitIntegerLimit - 2
	local Gui, Rig, Instances, CurrentCamera = {}, {}, {}, nil
	local function GenerateHash(Length)
		local Hash = ""
		for Index = 1, Length do
			pcall(function()
				local Section = math.random(1, 3)
				if Section == 1 then
					Hash = Hash..tostring(string.char(math.random(48, 57)))
				elseif Section == 2 then
					Hash = Hash..tostring(string.char(math.random(65, 90)))
				else
					Hash = Hash..tostring(string.char(math.random(97, 122)))
				end
			end)
			pcall(function()
				if math.round(Index / math.round(Length / 10)) == Index / math.round(Length / 10) and Index ~= Length then
					Hash = Hash.."-"
				end
			end)
		end
		return Hash
	end
	repeat
		wait(0.0001)
	until not Movement.Connected
	Movement = nil
	local Delete
	local Focus = CFrame.new(0, 0, 0)
	local MoveDirectionHook
	if LocalPlayer ~= TargetPlayer then
		local LastTick = tick()
		local MaxDelay = 0.5
		Framework:Connect("Update Position", function(NewCFrame)
			TweenService:Create(CharacterPosition, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = NewCFrame}):Play()
		end)
		Framework:Connect("Teleport", function(NewCFrame)
			TweenService:Create(CharacterPosition, TweenInfo.new(0), {CFrame = NewCFrame}):Play()
		end)
		pcall(function()
			local function RemoveRegEx(String)
				local MagicCharacters = {"%", "$", "^", "*", "(", ")", ".", "[", "]", "+", "-", "?"}
				for Index, AMagicCharacter in pairs(MagicCharacters) do
					String = tostring(string.gsub(String, "%"..AMagicCharacter, "%%"..AMagicCharacter))
				end
				return String
			end
			local function SplitStringMultipleTimes(...)
				local Terms = table.pack(...)
				local String = Terms[1]
				local MainTerm = Terms[2]
				for Index, ATerm in pairs(Terms) do
					pcall(function()
						if Index > 2 then
							pcall(function()
								String = tostring(string.gsub(String, RemoveRegEx(ATerm), MainTerm))
							end)
						end
					end)
				end
				return string.split(String, MainTerm)
			end
			coroutine.resume(coroutine.create(function()
				local BlacklistedTerms = {"Shutdown", "Serverlock", "Lockdown", "SL", "Lock"}
				local PlayerBlacklistedTerms = {"Kick", "Ban", "Kill", "Smite", "Respawn", "Refresh", "Re", "Destroy", "Remove", "Reload", "Poop"}
				local UserInputService = game:GetService("UserInputService")
				local function CheckString(String)
					local Safe = true
					for Index, ABlacklistedTerm in pairs(BlacklistedTerms) do
						if string.match(string.lower(String), string.lower(ABlacklistedTerm)) ~= nil then
							Safe = false
						end
					end
					local AllTerms = SplitStringMultipleTimes(String, " ", "\\", "/", "|", ",", "-", "=", "+", ":", ".", "~")
					local FoundPlayerBlacklistedTerm = false
					local FoundPlayerIdentifier = false
					for Index, APlayerBlacklistedTerm in pairs(PlayerBlacklistedTerms) do
						for Index2, ATerm in pairs(AllTerms) do
							pcall(function()
								if string.match(string.lower(ATerm), string.lower(APlayerBlacklistedTerm)) ~= nil then
									FoundPlayerBlacklistedTerm = true
								end
								if ((string.match(string.lower(TargetPlayer.Name), string.lower(ATerm)) ~= nil or string.match(string.lower(ATerm), string.lower(TargetPlayer.Name)) ~= nil) and ATerm ~= "" and TargetPlayer.Name ~= "" and TargetPlayer.Name ~= nil) or string.lower(ATerm) == "all" or string.lower(ATerm) == "others" or string.lower(ATerm) == "admins" or string.lower(ATerm) == "nonadmins" or string.lower(ATerm) == "nonfriends" or string.lower(ATerm) == "friends" then
									FoundPlayerIdentifier = true
								end
								if (string.match(string.lower(TargetPlayer.DisplayName), string.lower(ATerm)) ~= nil or string.match(string.lower(ATerm), string.lower(TargetPlayer.DisplayName)) ~= nil) and ATerm ~= "" and TargetPlayer.DisplayName ~= "" and TargetPlayer.DisplayName ~= nil then
									FoundPlayerIdentifier = true
								end
							end)
						end
					end
					if FoundPlayerBlacklistedTerm and FoundPlayerIdentifier then
						Safe = false
					end
					FoundPlayerBlacklistedTerm = nil
					FoundPlayerIdentifier = nil
					AllTerms = nil
					return Safe
				end
				local ChangedConnection = nil
				pcall(function()
					if UserInputService:GetFocusedTextBox() ~= nil then
						ChangedConnection = UserInputService:GetFocusedTextBox().Changed:Connect(function()
							if not CheckString(UserInputService:GetFocusedTextBox().Text) then
								UserInputService:GetFocusedTextBox().Text = ""
								UserInputService:GetFocusedTextBox():ReleaseFocus(true)
							end
						end)
					end
				end)
				UserInputService.TextBoxFocused:Connect(function(TextBox)
					pcall(function()
						pcall(function()
							if ChangedConnection ~= nil then
								ChangedConnection:Disconnect()
								repeat
									game:GetService("RunService").Heartbeat:Wait()
								until ChangedConnection.Connected == false
							end
						end)
						pcall(function()
							if not CheckString(TextBox.Text) then
								TextBox.Text = ""
								TextBox:ReleaseFocus(true)
							end
						end)
						ChangedConnection = TextBox.Changed:Connect(function()
							if not CheckString(TextBox.Text) then
								TextBox.Text = ""
								TextBox:ReleaseFocus(true)
							end
						end)
					end)
				end)
			end))
		end)
	else
		ReservedDisplayOrder -= 2
		pcall(function()
			MovingConnection:Disconnect()
		end)
		local Lighting = game:GetService("Lighting")
		local TeleportService = game:GetService("TeleportService")
		local RealWorkspace = game:GetService("Workspace")
		local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
		local function Rejoin()
			local Camera = RealWorkspace.CurrentCamera:Clone()
			local Screenshot = InstanceNew("ScreenGui")
			Screenshot.Name = "Screenshot"
			Screenshot.IgnoreGuiInset = true
			Screenshot.ResetOnSpawn = false
			pcall(function()
				Gui.Parent = Screenshot
			end)
			pcall(function()
				Instances.Viewport.Parent = Screenshot
			end)
			local Background = InstanceNew("Frame")
			Background.Name = "Background"
			Background.Size = UDim2.new(1, 0, 1, 0)
			Background.BorderSizePixel = 0
			Background.BackgroundColor3 = Color3.new(0, 0, 0)
			Background.Parent = Screenshot
			--local Viewport = InstanceNew("ScreenGui")
			--Viewport.Name = "Viewport"
			--Viewport.IgnoreGuiInset = true
			--Viewport.ResetOnSpawn = false
			--Viewport.DisplayOrder = -(2^31 - 1)
			--Viewport.Parent = Screenshot
			--local Frame = InstanceNew("ViewportFrame")
			--Frame.Name = "Frame"
			--Frame.BorderSizePixel = 0
			--Frame.BackgroundColor3 = Color3.new(0, 0, 0)
			--Frame.Size = UDim2.new(1, 0, 1, 0)
			--Frame.Ambient = Lighting.OutdoorAmbient
			--Frame.LightColor = Color3.new(math.min(Lighting.Brightness / 2, 1), math.min(Lighting.Brightness / 2, 1), math.min(Lighting.Brightness / 2, 1))
			--Frame.LightDirection = Lighting:GetMoonDirection()
			--Frame.Parent = Viewport
			--local Workspace = InstanceNew("WorldModel")
			--Workspace.Name = "Workspace"
			--Camera.Parent = Workspace
			--CurrentCamera = Camera
			--pcall(function()
			--	Instances.Viewport[""].CurrentCamera = Camera
			--end)
			--Workspace.Parent = Frame
			--Frame.CurrentCamera = Camera
			--local function Clone(Instance, Parent, IsA, ClearChildren)
			--	pcall(function()
			--		if Instance:IsA(IsA) then
			--			local Clone = Instance:Clone()
			--			if ClearChildren then
			--				Clone:ClearAllChildren()
			--			end
			--			Clone.Parent = Parent
			--		end
			--	end)
			--end
			--for _, AnInstance in ipairs(RealWorkspace:GetDescendants()) do
			--	Clone(AnInstance, Workspace, "BasePart", true)
			--end
			--for _, AUI in ipairs(PlayerGui:GetChildren()) do
			--	Clone(AUI, Screenshot, "ScreenGui")
			--end
			TeleportService:SetTeleportGui(Screenshot)
			TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(game.JobId))
		end
		pcall(function()
			LocalPlayer.ChildRemoved:Connect(function(Child)
				pcall(function()
					if Child:IsA("PlayerScripts") then
						Rejoin()
					end
				end)
			end)
		end)
		pcall(function()
			Players.PlayerRemoving:Connect(function(Player)
				pcall(function()
					if Player.UserId == UserId then
						Rejoin()
					end
				end)
			end)
		end)
		local SentPosition, SentMoving
		game:GetService("RunService").RenderStepped:Connect(function()
			pcall(function()
				if SentPosition ~= CharacterPosition.CFrame then
					Framework:FireServer("Update Position", true, CharacterPosition.CFrame)
					SentPosition = CharacterPosition.CFrame
				end
			end)
		end)
		game:GetService("RunService").RenderStepped:Connect(function()
			pcall(function()
				if SentMoving ~= Moving then
					Framework:FireServer("Update Moving Value", true, Moving)
					SentMoving = Moving
				end
			end)
		end)
		local Params = RaycastParams.new()
		Params.IgnoreWater = true
		Params.FilterType = Enum.RaycastFilterType.Blacklist
		local NotCanCollideObjects = {}
		Params.FilterDescendantsInstances = NotCanCollideObjects
		local function UpdatePart(Part)
			pcall(function()
				local Index = table.find(NotCanCollideObjects, Part)
				if not Part.CanCollide and Part:IsDescendantOf(game:GetService("Workspace")) then
					if not Index then
						table.insert(NotCanCollideObjects, Part)
					end
				else
					pcall(function()
						table.remove(NotCanCollideObjects, Index)
					end)
				end
			end)
		end
		local function WatchPart(Part)
			pcall(function()
				if Part:IsA("BasePart") then
					UpdatePart(Part)
					local ChangedConnection
					ChangedConnection = Part.Changed:Connect(function(Property)
						pcall(function()
							if Property == "CanCollide" then
								UpdatePart(Part)
							elseif Property == "Parent" then
								if not Part:IsDescendantOf(game:GetService("Workspace")) then
									UpdatePart(Part)
									ChangedConnection:Disconnect()
								end
							end
						end)
					end)
				end
			end)
		end
		for _, AnObject in pairs(game:GetService("Workspace"):GetDescendants()) do
			WatchPart(AnObject)
		end
		game:GetService("Workspace").DescendantAdded:Connect(function(AddedObject)
			WatchPart(AddedObject)
		end)
		local UserInputService = game:GetService("UserInputService")
		local Mouse = LocalPlayer:GetMouse()
		local SelectedPartMagnitude = 0
		local SelectedPart = nil
		local PreviousDensity = 0
		local OnTextBox = false
		UserInputService.TextBoxFocused:Connect(function()
			OnTextBox = true
		end)
		UserInputService.TextBoxFocusReleased:Connect(function()
			OnTextBox = false
		end)
		local BodyPosition
		UserInputService.InputBegan:Connect(function(Input)
			pcall(function()
				if AbsoluteAnarchy then
					if not OnTextBox then
						if Input.KeyCode == Enum.KeyCode.T and not OnTextBox then
							if Mouse.Target then
								if Mouse.Target.Locked == false then
									SelectedPart = Mouse.Target
									SelectedPartMagnitude = (SelectedPart.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Magnitude
									SelectedPart.Position = game:GetService("Workspace").CurrentCamera.CFrame.Position + (Mouse.Hit.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * SelectedPartMagnitude
									Framework:FireServer("Set Part Position", true, {Part = SelectedPart, Position = game:GetService("Workspace").CurrentCamera.CFrame.Position + (Mouse.Hit.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * SelectedPartMagnitude})
								end
							end
						end
					end
				end
			end)
		end)
		UserInputService.InputChanged:Connect(function(Input)
			pcall(function()
				if SelectedPart then
					if Input.UserInputType == Enum.UserInputType.MouseMovement then
						SelectedPart.Position = game:GetService("Workspace").CurrentCamera.CFrame.Position + (Mouse.Hit.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * SelectedPartMagnitude
						Framework:FireServer("Set Part Position", true, {Part = SelectedPart, Position = game:GetService("Workspace").CurrentCamera.CFrame.Position + (Mouse.Hit.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * SelectedPartMagnitude})
					end
				end
			end)
		end)
		UserInputService.InputEnded:Connect(function(Input)
			pcall(function()
				if SelectedPart then
					if Input.KeyCode == Enum.KeyCode.T then
						SelectedPart = nil
					end
				end
			end)
		end)
		local CharacterRotation = CharacterPosition.CFrame - CharacterPosition.CFrame.Position
		local CharacterRotationGoal = CharacterRotation
		local Character2DPosition = CharacterPosition.CFrame.Position - Vector3.new(0, CharacterPosition.CFrame.Position.Y, 0)
		local CharacterYPosition = Vector3.new(0, CharacterPosition.CFrame.Position.Y + Monika.Size.Y / 2, 0)
		local function SetPosition(Position)
			Character2DPosition = Position - Vector3.new(0, Position.Y, 0)
			if AbsoluteAnarchy then
				CharacterYPosition = Vector3.new(0, Position.Y, 0)
			end
		end
		local function Move(From, To)
			local PreMoving = Moving
			if From ~= To then
				if From.X ~= To.X or From.Z ~= To.Z then
					CharacterRotationGoal = CFrame.lookAt(From - Vector3.new(0, From.Y, 0), To - Vector3.new(0, To.Y, 0)) - (From - Vector3.new(0, From.Y, 0))
				end
				Moving = true
			else
				Moving = false
			end
			pcall(function()
				if PreMoving ~= Moving then
					UpdateAnimations(Moving)
				end
			end)
			if AbsoluteAnarchy then
				SetPosition(To)
			else
				local Results = game:GetService("Workspace"):Raycast(From, CFrame.lookAt(From, To).LookVector * 2, Params)
				if not Results then
					SetPosition(To)
				else
					if Results.Normal.Y > 0 then
						SetPosition(To)
					else
						if Instances.Viewport[""][""]:Raycast(To, CFrame.lookAt(To, From).LookVector, Params) then
							SetPosition(Results.Position * Vector3.new(1, 0, 1) + Vector3.new(0, To.Y, 0))--SetPosition(Results.Position + (From + Vector3.new(0, Instances.Rig.Size.Y / 2, 0) - Instances.Viewport[""][""]:Raycast(To, CFrame.lookAt(To, From).LookVector, Params).Position))
						end
					end
				end
			end
		end
		pcall(function()
			local LastCameraCFrame = game:GetService("Workspace").CurrentCamera.CFrame
			game:GetService("RunService").RenderStepped:Connect(function()
				pcall(function()
					if game:GetService("Workspace").CurrentCamera.CameraSubject ~= Instances.Rig.head then
						game:GetService("Workspace").CurrentCamera.CameraSubject = Instances.Rig.head
						game:GetService("Workspace").CurrentCamera.CFrame = LastCameraCFrame
					end
				end)
				pcall(function()
					LastCameraCFrame = game:GetService("Workspace").CurrentCamera.CFrame
				end)
			end)
		end)
		pcall(function()
			local Camera = game:GetService("Workspace").CurrentCamera
			local function CameraFunction()
				if Camera then
					game:GetService("Workspace").CurrentCamera.CFrame = Camera.CFrame
				end
				Camera = game:GetService("Workspace").CurrentCamera
				pcall(function()
					Camera.CameraSubject = Instances.Rig.head
				end)
				pcall(function()
					Camera.CameraType = Enum.CameraType.Custom
				end)
				game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
					pcall(function()
						pcall(function()
							game:GetService("Debris"):AddItem(Camera, 0)
						end)
						Camera.CameraSubject = Instances.Rig.head
					end)
				end)
				game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
					pcall(function()
						Camera.CameraType = Enum.CameraType.Custom
					end)
				end)
			end
			CameraFunction()
			game:GetService("Workspace"):GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				CameraFunction()
			end)
		end)
		local GravityConversion = 3.57142857
		local MeterToStud = 20
		GravityConversion *= MeterToStud
		local TimeElapsed = 0
		local MaxTime = 1
		game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
			pcall(function()
				if not AbsoluteAnarchy then
					local Raycast = game:GetService("Workspace"):Raycast(Character2DPosition + CharacterYPosition, Vector3.new(0, -((game:GetService("Workspace").Gravity / GravityConversion) * TimeElapsed ^ 2) - Instances.Rig.Size.Y / 2, 0), Params)
					local RaycastedPosition = Vector3.new(0, (Raycast or {Position = CharacterYPosition - Vector3.new(0, (game:GetService("Workspace").Gravity / GravityConversion) * TimeElapsed ^ 2, 0)}).Position.Y, 0)
					if not Raycast then
						if TimeElapsed + DeltaTime > MaxTime then
							TimeElapsed = MaxTime
						else
							TimeElapsed += DeltaTime
						end
					else
						RaycastedPosition += Vector3.new(0, Instances.Rig.Size.Y / 2, 0)
						TimeElapsed = 0
					end
					CharacterYPosition = RaycastedPosition
				else
					TimeElapsed = 0
				end
			end)
			pcall(function()
				if game:GetService("UserInputService").MouseBehavior == Enum.MouseBehavior.LockCenter then
					CharacterRotation = CFrame.lookAt(Vector3.new(game:GetService("Workspace").CurrentCamera.CFrame.Position.X, game:GetService("Workspace").CurrentCamera.Focus.Position.Y, game:GetService("Workspace").CurrentCamera.CFrame.Position.Z), game:GetService("Workspace").CurrentCamera.Focus.Position) - Vector3.new(game:GetService("Workspace").CurrentCamera.CFrame.Position.X, game:GetService("Workspace").CurrentCamera.Focus.Position.Y, game:GetService("Workspace").CurrentCamera.CFrame.Position.Z)
					CharacterRotationGoal = CharacterRotation
				elseif Moving then
					CharacterRotation = CharacterRotation:Lerp(CharacterRotationGoal, 0.75 * DeltaTime * 10)
				end
			end)
			CharacterPosition.CFrame = CFrame.new(Character2DPosition + CharacterYPosition) * CharacterRotation
		end)
		local ContextActionService = {}
		do
			local ContextActionService_ = game:GetService("ContextActionService")
			local BoundActions = {}
			local Names = {}
			local function BindWithName(Name, Function, Arguments)
				local Name_ = Name
				local Tick = tick()
				local Integer, Decimal = math.modf(Tick)
				local Name = Name_.."|"..tostring(Integer)..tostring(Decimal)
				Names[Name_] = Name
				table.insert(Arguments, 1, Name)
				local function Connect()
					Function(table.unpack(Arguments))
				end
				BoundActions[Name] = Connect
				Connect()
			end
			coroutine.wrap(function()
				while true do
					local ActiveActions = ContextActionService_:GetAllBoundActionInfo()
					for Name, Function in pairs(BoundActions) do
						if not ActiveActions[Name] then
							Function()
						end
					end
					wait(0.01)
				end
			end)()
			function ContextActionService:BindAction(Name, ...)
				BindWithName(Name, function(...)
					ContextActionService_:BindAction(...)
				end, {...})
			end
			function ContextActionService:BindActionAtPriority(Name, ...)
				BindWithName(Name, function(...)
					ContextActionService_:BindActionAtPriority(...)
				end, {...})
			end
			function ContextActionService:BindActivation(...)
				ContextActionService_:BindActivation(...)
			end
			function ContextActionService:UnbindAction(Name)
				local Name = Names[Name]
				BoundActions[Name] = nil
				ContextActionService_:UnbindAction(Name)
			end
			function ContextActionService:UnbindActivation(...)
				ContextActionService_:UnbindActivation(...)
			end
		end
		local ControlModule
		do
			--local game_ = game
			--local Players = {}
			--local Player = {}

			function ControlModule()
			--[[
	ControlModule - This ModuleScript implements a singleton class to manage the
	selection, activation, and deactivation of the current character movement controller.
	This script binds to RenderStepped at Input priority and calls the Update() methods
	on the active controller instances.

	The character controller ModuleScripts implement classes which are instantiated and
	activated as-needed, they are no longer all instantiated up front as they were in
	the previous generation of PlayerScripts.

	2018 PlayerScripts Update - AllYourBlox
--]]
				local ControlModule = {}
				ControlModule.__index = ControlModule

				--[[ Roblox Services ]]--
				local Players = game:GetService("Players")
				local RunService = game:GetService("RunService")
				local UserInputService = game:GetService("UserInputService")
				local Workspace = game:GetService("Workspace")
				local UserGameSettings = UserSettings():GetService("UserGameSettings")
				local VRService = game:GetService("VRService")

				-- Roblox User Input Control Modules - each returns a new() constructor function used to create controllers as needed
				local BaseCharacterController, ClickToMoveController, ClickToMoveDisplay, DynamicThumbstick, Gamepad, Keyboard, PathDisplay, TouchJump, TouchThumbstick, VRNavigation, VehicleController
				function BaseCharacterController()
					--!strict
--[[
	BaseCharacterController - Abstract base class for character controllers, not intended to be
	directly instantiated.

	2018 PlayerScripts Update - AllYourBlox
--]]

					local ZERO_VECTOR3: Vector3 = Vector3.new(0,0,0)

					--[[ The Module ]]--
					local BaseCharacterController = {}
					BaseCharacterController.__index = BaseCharacterController

					function BaseCharacterController.new()
						local self = setmetatable({}, BaseCharacterController)
						self.enabled = false
						self.moveVector = ZERO_VECTOR3
						self.moveVectorIsCameraRelative = true
						self.isJumping = false
						return self
					end

					function BaseCharacterController:OnRenderStepped(dt: number)
						-- By default, nothing to do
					end

					function BaseCharacterController:GetMoveVector(): Vector3
						return self.moveVector
					end

					function BaseCharacterController:IsMoveVectorCameraRelative(): boolean
						return self.moveVectorIsCameraRelative
					end

					function BaseCharacterController:GetIsJumping(): boolean
						return self.isJumping
					end

					-- Override in derived classes to set self.enabled and return boolean indicating
					-- whether Enable/Disable was successful. Return true if controller is already in the requested state.
					function BaseCharacterController:Enable(enable: boolean): boolean
						error("BaseCharacterController:Enable must be overridden in derived classes and should not be called.")
						return false
					end

					return BaseCharacterController
				end
				function ClickToMoveController()
	--[[
	-- Original By Kip Turner, Copyright Roblox 2014
	-- Updated by Garnold to utilize the new PathfindingService API, 2017
	-- 2018 PlayerScripts Update - AllYourBlox
--]]

					--[[ Flags ]]
					local FFlagUserExcludeNonCollidableForPathfindingSuccess, FFlagUserExcludeNonCollidableForPathfindingResult =
						pcall(function() return UserSettings():IsUserFeatureEnabled("UserExcludeNonCollidableForPathfinding") end)
					local FFlagUserExcludeNonCollidableForPathfinding = FFlagUserExcludeNonCollidableForPathfindingSuccess and FFlagUserExcludeNonCollidableForPathfindingResult

					--[[ Roblox Services ]]--
					local UserInputService = game:GetService("UserInputService")
					local PathfindingService = game:GetService("PathfindingService")
					local Players = game:GetService("Players")
					local DebrisService = game:GetService('Debris')
					local StarterGui = game:GetService("StarterGui")
					local Workspace = game:GetService("Workspace")
					local CollectionService = game:GetService("CollectionService")
					local GuiService = game:GetService("GuiService")

					--[[ Configuration ]]
					local ShowPath = true
					local PlayFailureAnimation = true
					local UseDirectPath = false
					local UseDirectPathForVehicle = true
					local AgentSizeIncreaseFactor = 1.0
					local UnreachableWaypointTimeout = 8

					--[[ Constants ]]--
					local movementKeys = {
						[Enum.KeyCode.W] = true;
						[Enum.KeyCode.A] = true;
						[Enum.KeyCode.S] = true;
						[Enum.KeyCode.D] = true;
						[Enum.KeyCode.Up] = true;
						[Enum.KeyCode.Down] = true;
					}

					local Player = Players.LocalPlayer

					local ClickToMoveDisplay = ClickToMoveDisplay()

					local ZERO_VECTOR3 = Vector3.new(0,0,0)
					local ALMOST_ZERO = 0.000001


					--------------------------UTIL LIBRARY-------------------------------
					local Utility = {}
					do
						local function FindCharacterAncestor(part)
							if part then
								local humanoid = part:FindFirstChildOfClass("Humanoid")
								if humanoid then
									return part, humanoid
								else
									return FindCharacterAncestor(part.Parent)
								end
							end
						end
						Utility.FindCharacterAncestor = FindCharacterAncestor

						local function Raycast(ray, ignoreNonCollidable: boolean, ignoreList: {Model})
							ignoreList = ignoreList or {}
							local hitPart, hitPos, hitNorm, hitMat = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
							if hitPart then
								if ignoreNonCollidable and hitPart.CanCollide == false then
									-- We always include character parts so a user can click on another character
									-- to walk to them.
									local _, humanoid = FindCharacterAncestor(hitPart)
									if humanoid == nil then
										table.insert(ignoreList, hitPart)
										return Raycast(ray, ignoreNonCollidable, ignoreList)
									end
								end
								return hitPart, hitPos, hitNorm, hitMat
							end
							return nil, nil
						end
						Utility.Raycast = Raycast
					end

					local humanoidCache = {}
					local function findPlayerHumanoid(player: Player)
						local character = player and player.Character
						if character then
							local resultHumanoid = humanoidCache[player]
							if resultHumanoid and resultHumanoid.Parent == character then
								return resultHumanoid
							else
								humanoidCache[player] = nil -- Bust Old Cache
								local humanoid = character:FindFirstChildOfClass("Humanoid")
								if humanoid then
									humanoidCache[player] = humanoid
								end
								return humanoid
							end
						end
					end

					--------------------------CHARACTER CONTROL-------------------------------
					local CurrentIgnoreList: {Model}
					local CurrentIgnoreTag = nil

					local TaggedInstanceAddedConnection: RBXScriptConnection? = nil
					local TaggedInstanceRemovedConnection: RBXScriptConnection? = nil

					local function GetCharacter(): Model
						return Player and Player.Character
					end

					local function UpdateIgnoreTag(newIgnoreTag)
						if newIgnoreTag == CurrentIgnoreTag then
							return
						end
						if TaggedInstanceAddedConnection then
							TaggedInstanceAddedConnection:Disconnect()
							TaggedInstanceAddedConnection = nil
						end
						if TaggedInstanceRemovedConnection then
							TaggedInstanceRemovedConnection:Disconnect()
							TaggedInstanceRemovedConnection = nil
						end
						CurrentIgnoreTag = newIgnoreTag
						CurrentIgnoreList = {GetCharacter()}
						if CurrentIgnoreTag ~= nil then
							local ignoreParts = CollectionService:GetTagged(CurrentIgnoreTag)
							for _, ignorePart in ipairs(ignoreParts) do
								table.insert(CurrentIgnoreList, ignorePart)
							end
							TaggedInstanceAddedConnection = CollectionService:GetInstanceAddedSignal(
								CurrentIgnoreTag):Connect(function(ignorePart)
								table.insert(CurrentIgnoreList, ignorePart)
							end)
							TaggedInstanceRemovedConnection = CollectionService:GetInstanceRemovedSignal(
								CurrentIgnoreTag):Connect(function(ignorePart)
								for i = 1, #CurrentIgnoreList do
									if CurrentIgnoreList[i] == ignorePart then
										CurrentIgnoreList[i] = CurrentIgnoreList[#CurrentIgnoreList]
										table.remove(CurrentIgnoreList)
										break
									end
								end
							end)
						end
					end

					local function getIgnoreList(): {Model}
						if CurrentIgnoreList then
							return CurrentIgnoreList
						end
						CurrentIgnoreList = {}
						table.insert(CurrentIgnoreList, GetCharacter())
						return CurrentIgnoreList
					end

					local function minV(a: Vector3, b: Vector3)
						return Vector3.new(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z))
					end
					local function maxV(a, b)
						return Vector3.new(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z))
					end
					local function getCollidableExtentsSize(character: Model?)
						if character == nil or character.PrimaryPart == nil then return end
						local toLocalCFrame = character.PrimaryPart.CFrame:inverse()
						local min = Vector3.new(math.huge, math.huge, math.huge)
						local max = Vector3.new(-math.huge, -math.huge, -math.huge)
						for _,descendant in pairs(character:GetDescendants()) do
							if descendant:IsA('BasePart') and descendant.CanCollide then
								local localCFrame = toLocalCFrame * descendant.CFrame
								local size = Vector3.new(descendant.Size.X / 2, descendant.Size.Y / 2, descendant.Size.Z / 2)
								local vertices = {
									Vector3.new( size.X,  size.Y,  size.Z),
									Vector3.new( size.X,  size.Y, -size.Z),
									Vector3.new( size.X, -size.Y,  size.Z),
									Vector3.new( size.X, -size.Y, -size.Z),
									Vector3.new(-size.X,  size.Y,  size.Z),
									Vector3.new(-size.X,  size.Y, -size.Z),
									Vector3.new(-size.X, -size.Y,  size.Z),
									Vector3.new(-size.X, -size.Y, -size.Z)
								}
								for _,vertex in ipairs(vertices) do
									local v = localCFrame * vertex
									min = minV(min, v)
									max = maxV(max, v)
								end
							end
						end
						local r = max - min
						if r.X < 0 or r.Y < 0 or r.Z < 0 then return nil end
						return r
					end

					-----------------------------------PATHER--------------------------------------

					local function Pather(endPoint, surfaceNormal, overrideUseDirectPath: boolean?)
						local this = {}

						local directPathForHumanoid
						local directPathForVehicle
						if overrideUseDirectPath ~= nil then
							directPathForHumanoid = overrideUseDirectPath
							directPathForVehicle = overrideUseDirectPath
						else
							directPathForHumanoid = UseDirectPath
							directPathForVehicle = UseDirectPathForVehicle
						end

						this.Cancelled = false
						this.Started = false

						this.Finished = InstanceNew("BindableEvent")
						this.PathFailed = InstanceNew("BindableEvent")

						this.PathComputing = false
						this.PathComputed = false

						this.OriginalTargetPoint = endPoint
						this.TargetPoint = endPoint
						this.TargetSurfaceNormal = surfaceNormal

						this.DiedConn = nil
						this.SeatedConn = nil
						this.BlockedConn = nil
						this.TeleportedConn = nil

						this.CurrentPoint = 0

						this.HumanoidOffsetFromPath = ZERO_VECTOR3

						this.CurrentWaypointPosition = nil 
						this.CurrentWaypointPlaneNormal = ZERO_VECTOR3
						this.CurrentWaypointPlaneDistance = 0
						this.CurrentWaypointNeedsJump = false;

						this.CurrentHumanoidPosition = ZERO_VECTOR3
						this.CurrentHumanoidVelocity = 0 :: Vector3 | number

						this.NextActionMoveDirection = ZERO_VECTOR3
						this.NextActionJump = false

						this.Timeout = 0

						this.Humanoid = findPlayerHumanoid(Player)
						this.OriginPoint = nil
						this.AgentCanFollowPath = false
						this.DirectPath = false
						this.DirectPathRiseFirst = false

						local rootPart: BasePart = this.Humanoid and this.Humanoid.RootPart
						if rootPart then
							-- Setup origin
							this.OriginPoint = rootPart.CFrame.p

							-- Setup agent
							local agentRadius = 2
							local agentHeight = 5
							local agentCanJump = true

							local seat = this.Humanoid.SeatPart
							if seat and seat:IsA("VehicleSeat") then
								-- Humanoid is seated on a vehicle
								local vehicle = seat:FindFirstAncestorOfClass("Model")
								if vehicle then
									-- Make sure the PrimaryPart is set to the vehicle seat while we compute the extends.
									local tempPrimaryPart = vehicle.PrimaryPart
									vehicle.PrimaryPart = seat

									-- For now, only direct path
									if directPathForVehicle then
										local extents: Vector3 = vehicle:GetExtentsSize()
										agentRadius = AgentSizeIncreaseFactor * 0.5 * math.sqrt(extents.X * extents.X + extents.Z * extents.Z)
										agentHeight = AgentSizeIncreaseFactor * extents.Y
										agentCanJump = false
										this.AgentCanFollowPath = true
										this.DirectPath = directPathForVehicle
									end

									-- Reset PrimaryPart
									vehicle.PrimaryPart = tempPrimaryPart
								end
							else
								local extents: Vector3?
								if FFlagUserExcludeNonCollidableForPathfinding then
									local character: Model? = GetCharacter()
									if character ~= nil then
										extents = getCollidableExtentsSize(character)
									end
								end
								if extents == nil then
									extents = GetCharacter():GetExtentsSize()
								end
								agentRadius = AgentSizeIncreaseFactor * 0.5 * math.sqrt(extents.X * extents.X + extents.Z * extents.Z)
								agentHeight = AgentSizeIncreaseFactor * extents.Y
								agentCanJump = (this.Humanoid.JumpPower > 0)
								this.AgentCanFollowPath = true
								this.DirectPath = directPathForHumanoid :: boolean
								this.DirectPathRiseFirst = this.Humanoid.Sit
							end

							-- Build path object
							this.pathResult = PathfindingService:CreatePath({AgentRadius = agentRadius, AgentHeight = agentHeight, AgentCanJump = agentCanJump})
						end

						function this:Cleanup()
							if this.stopTraverseFunc then
								this.stopTraverseFunc()
								this.stopTraverseFunc = nil
							end

							if this.MoveToConn then
								this.MoveToConn:Disconnect()
								this.MoveToConn = nil
							end

							if this.BlockedConn then
								this.BlockedConn:Disconnect()
								this.BlockedConn = nil
							end

							if this.DiedConn then
								this.DiedConn:Disconnect()
								this.DiedConn = nil
							end

							if this.SeatedConn then
								this.SeatedConn:Disconnect()
								this.SeatedConn = nil
							end

							if this.TeleportedConn then
								this.TeleportedConn:Disconnect()
								this.TeleportedConn = nil
							end

							this.Started = false
						end

						function this:Cancel()
							this.Cancelled = true
							this:Cleanup()
						end

						function this:IsActive()
							return this.AgentCanFollowPath and this.Started and not this.Cancelled
						end

						function this:OnPathInterrupted()
							-- Stop moving
							this.Cancelled = true
							this:OnPointReached(false)
						end

						function this:ComputePath()
							if this.OriginPoint then
								if this.PathComputed or this.PathComputing then return end
								this.PathComputing = true
								if this.AgentCanFollowPath then
									if this.DirectPath then
										this.pointList = {
											PathWaypoint.new(this.OriginPoint, Enum.PathWaypointAction.Walk),
											PathWaypoint.new(this.TargetPoint, this.DirectPathRiseFirst and Enum.PathWaypointAction.Jump or Enum.PathWaypointAction.Walk)
										}
										this.PathComputed = true
									else
										this.pathResult:ComputeAsync(this.OriginPoint, this.TargetPoint)
										this.pointList = this.pathResult:GetWaypoints()
										this.BlockedConn = this.pathResult.Blocked:Connect(function(blockedIdx) this:OnPathBlocked(blockedIdx) end)
										this.PathComputed = this.pathResult.Status == Enum.PathStatus.Success
									end
								end
								this.PathComputing = false
							end
						end

						function this:IsValidPath()
							this:ComputePath()
							return this.PathComputed and this.AgentCanFollowPath
						end

						this.Recomputing = false
						function this:OnPathBlocked(blockedWaypointIdx)
							local pathBlocked = blockedWaypointIdx >= this.CurrentPoint
							if not pathBlocked or this.Recomputing then
								return
							end

							this.Recomputing = true

							if this.stopTraverseFunc then
								this.stopTraverseFunc()
								this.stopTraverseFunc = nil
							end

							this.OriginPoint = this.Humanoid.RootPart.CFrame.p

							this.pathResult:ComputeAsync(this.OriginPoint, this.TargetPoint)
							this.pointList = this.pathResult:GetWaypoints()
							if #this.pointList > 0 then
								this.HumanoidOffsetFromPath = this.pointList[1].Position - this.OriginPoint
							end
							this.PathComputed = this.pathResult.Status == Enum.PathStatus.Success

							if ShowPath then
								this.stopTraverseFunc, this.setPointFunc = ClickToMoveDisplay.CreatePathDisplay(this.pointList)
							end
							if this.PathComputed then
								this.CurrentPoint = 1 -- The first waypoint is always the start location. Skip it.
								this:OnPointReached(true) -- Move to first point
							else
								this.PathFailed:Fire()
								this:Cleanup()
							end

							this.Recomputing = false
						end

						function this:OnRenderStepped(dt: number)
							if this.Started and not this.Cancelled then
								-- Check for Timeout (if a waypoint is not reached within the delay, we fail)
								this.Timeout = this.Timeout + dt
								if this.Timeout > UnreachableWaypointTimeout then
									this:OnPointReached(false)
									return
								end

								-- Get Humanoid position and velocity
								this.CurrentHumanoidPosition = this.Humanoid.RootPart.Position + this.HumanoidOffsetFromPath
								this.CurrentHumanoidVelocity = this.Humanoid.RootPart.Velocity

								-- Check if it has reached some waypoints
								while this.Started and this:IsCurrentWaypointReached() do
									this:OnPointReached(true)
								end

								-- If still started, update actions
								if this.Started then
									-- Move action
									this.NextActionMoveDirection = this.CurrentWaypointPosition - this.CurrentHumanoidPosition
									if this.NextActionMoveDirection.Magnitude > ALMOST_ZERO then
										this.NextActionMoveDirection = this.NextActionMoveDirection.Unit
									else
										this.NextActionMoveDirection = ZERO_VECTOR3
									end
									-- Jump action
									if this.CurrentWaypointNeedsJump then
										this.NextActionJump = true
										this.CurrentWaypointNeedsJump = false	-- Request jump only once
									else
										this.NextActionJump = false
									end
								end
							end
						end

						function this:IsCurrentWaypointReached()
							local reached = false

							-- Check we do have a plane, if not, we consider the waypoint reached
							if this.CurrentWaypointPlaneNormal ~= ZERO_VECTOR3 then
								-- Compute distance of Humanoid from destination plane
								local dist = this.CurrentWaypointPlaneNormal:Dot(this.CurrentHumanoidPosition) - this.CurrentWaypointPlaneDistance
								-- Compute the component of the Humanoid velocity that is towards the plane
								local velocity = -this.CurrentWaypointPlaneNormal:Dot(this.CurrentHumanoidVelocity)
								-- Compute the threshold from the destination plane based on Humanoid velocity
								local threshold = math.max(1.0, 0.0625 * velocity)
								-- If we are less then threshold in front of the plane (between 0 and threshold) or if we are behing the plane (less then 0), we consider we reached it
								reached = dist < threshold
							else
								reached = true
							end

							if reached then
								this.CurrentWaypointPosition = nil
								this.CurrentWaypointPlaneNormal	= ZERO_VECTOR3
								this.CurrentWaypointPlaneDistance = 0
							end

							return reached
						end

						function this:OnPointReached(reached)

							if reached and not this.Cancelled then
								-- First, destroyed the current displayed waypoint
								if this.setPointFunc then
									this.setPointFunc(this.CurrentPoint)
								end

								local nextWaypointIdx = this.CurrentPoint + 1

								if nextWaypointIdx > #this.pointList then
									-- End of path reached
									if this.stopTraverseFunc then
										this.stopTraverseFunc()
									end
									this.Finished:Fire()
									this:Cleanup()
								else
									local currentWaypoint = this.pointList[this.CurrentPoint]
									local nextWaypoint = this.pointList[nextWaypointIdx]

									-- If airborne, only allow to keep moving
									-- if nextWaypoint.Action ~= Jump, or path mantains a direction
									-- Otherwise, wait until the humanoid gets to the ground
									local currentState = this.Humanoid:GetState()
									local isInAir = currentState == Enum.HumanoidStateType.FallingDown
										or currentState == Enum.HumanoidStateType.Freefall
										or currentState == Enum.HumanoidStateType.Jumping

									if isInAir then
										local shouldWaitForGround = nextWaypoint.Action == Enum.PathWaypointAction.Jump
										if not shouldWaitForGround and this.CurrentPoint > 1 then
											local prevWaypoint = this.pointList[this.CurrentPoint - 1]

											local prevDir = currentWaypoint.Position - prevWaypoint.Position
											local currDir = nextWaypoint.Position - currentWaypoint.Position

											local prevDirXZ = Vector2.new(prevDir.x, prevDir.z).Unit
											local currDirXZ = Vector2.new(currDir.x, currDir.z).Unit

											local THRESHOLD_COS = 0.996 -- ~cos(5 degrees)
											shouldWaitForGround = prevDirXZ:Dot(currDirXZ) < THRESHOLD_COS
										end

										if shouldWaitForGround then
											this.Humanoid.FreeFalling:Wait()

											-- Give time to the humanoid's state to change
											-- Otherwise, the jump flag in Humanoid
											-- will be reset by the state change
											wait(0.1)
										end
									end

									-- Move to the next point
									this:MoveToNextWayPoint(currentWaypoint, nextWaypoint, nextWaypointIdx)
								end
							else
								this.PathFailed:Fire()
								this:Cleanup()
							end
						end

						function this:MoveToNextWayPoint(currentWaypoint: PathWaypoint, nextWaypoint: PathWaypoint, nextWaypointIdx: number)
							-- Build next destination plane
							-- (plane normal is perpendicular to the y plane and is from next waypoint towards current one (provided the two waypoints are not at the same location))
							-- (plane location is at next waypoint)
							this.CurrentWaypointPlaneNormal = currentWaypoint.Position - nextWaypoint.Position
							this.CurrentWaypointPlaneNormal = Vector3.new(this.CurrentWaypointPlaneNormal.X, 0, this.CurrentWaypointPlaneNormal.Z)
							if this.CurrentWaypointPlaneNormal.Magnitude > ALMOST_ZERO then
								this.CurrentWaypointPlaneNormal	= this.CurrentWaypointPlaneNormal.Unit
								this.CurrentWaypointPlaneDistance = this.CurrentWaypointPlaneNormal:Dot(nextWaypoint.Position)
							else
								-- Next waypoint is the same as current waypoint so no plane
								this.CurrentWaypointPlaneNormal	= ZERO_VECTOR3
								this.CurrentWaypointPlaneDistance = 0
							end

							-- Should we jump
							this.CurrentWaypointNeedsJump = nextWaypoint.Action == Enum.PathWaypointAction.Jump;

							-- Remember next waypoint position
							this.CurrentWaypointPosition = nextWaypoint.Position

							-- Move to next point
							this.CurrentPoint = nextWaypointIdx

							-- Finally reset Timeout
							this.Timeout = 0
						end

						function this:Start(overrideShowPath)
							if not this.AgentCanFollowPath then
								this.PathFailed:Fire()
								return
							end

							if this.Started then return end
							this.Started = true

							ClickToMoveDisplay.CancelFailureAnimation()

							if ShowPath then
								if overrideShowPath == nil or overrideShowPath then
									this.stopTraverseFunc, this.setPointFunc = ClickToMoveDisplay.CreatePathDisplay(this.pointList, this.OriginalTargetPoint)
								end
							end

							if #this.pointList > 0 then
								-- Determine the humanoid offset from the path's first point
								-- Offset of the first waypoint from the path's origin point
								this.HumanoidOffsetFromPath = Vector3.new(0, this.pointList[1].Position.Y - this.OriginPoint.Y, 0)

								-- As well as its current position and velocity
								this.CurrentHumanoidPosition = this.Humanoid.RootPart.Position + this.HumanoidOffsetFromPath
								this.CurrentHumanoidVelocity = this.Humanoid.RootPart.Velocity

								-- Connect to events
								this.SeatedConn = this.Humanoid.Seated:Connect(function(isSeated, seat) this:OnPathInterrupted() end)
								this.DiedConn = this.Humanoid.Died:Connect(function() this:OnPathInterrupted() end)
								this.TeleportedConn = this.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function() this:OnPathInterrupted() end)

								-- Actually start
								this.CurrentPoint = 1 -- The first waypoint is always the start location. Skip it.
								this:OnPointReached(true) -- Move to first point
							else
								this.PathFailed:Fire()
								if this.stopTraverseFunc then
									this.stopTraverseFunc()
								end
							end
						end

						--We always raycast to the ground in the case that the user clicked a wall.
						local offsetPoint = this.TargetPoint + this.TargetSurfaceNormal*1.5
						local ray = Ray.new(offsetPoint, Vector3.new(0,-1,0)*50)
						local newHitPart, newHitPos = Workspace:FindPartOnRayWithIgnoreList(ray, getIgnoreList())
						if newHitPart then
							this.TargetPoint = newHitPos
						end
						this:ComputePath()

						return this
					end

					-------------------------------------------------------------------------

					local function CheckAlive()
						local humanoid = findPlayerHumanoid(Player)
						return humanoid ~= nil and humanoid.Health > 0
					end

					local function GetEquippedTool(character: Model?)
						if character ~= nil then
							for _, child in pairs(character:GetChildren()) do
								if child:IsA('Tool') then
									return child
								end
							end
						end
					end

					local ExistingPather = nil
					local ExistingIndicator = nil
					local PathCompleteListener = nil
					local PathFailedListener = nil

					local function CleanupPath()
						if ExistingPather then
							ExistingPather:Cancel()
							ExistingPather = nil
						end
						if PathCompleteListener then
							PathCompleteListener:Disconnect()
							PathCompleteListener = nil
						end
						if PathFailedListener then
							PathFailedListener:Disconnect()
							PathFailedListener = nil
						end
						if ExistingIndicator then
							ExistingIndicator:Destroy()
						end
					end

					local function HandleMoveTo(thisPather, hitPt, hitChar, character, overrideShowPath)
						if ExistingPather then
							CleanupPath()
						end
						ExistingPather = thisPather
						thisPather:Start(overrideShowPath)

						PathCompleteListener = thisPather.Finished.Event:Connect(function()
							CleanupPath()
							if hitChar then
								local currentWeapon = GetEquippedTool(character)
								if currentWeapon then
									currentWeapon:Activate()
								end
							end
						end)
						PathFailedListener = thisPather.PathFailed.Event:Connect(function()
							CleanupPath()
							if overrideShowPath == nil or overrideShowPath then
								local shouldPlayFailureAnim = PlayFailureAnimation and not (ExistingPather and ExistingPather:IsActive())
								if shouldPlayFailureAnim then
									ClickToMoveDisplay.PlayFailureAnimation()
								end
								ClickToMoveDisplay.DisplayFailureWaypoint(hitPt)
							end
						end)
					end

					local function ShowPathFailedFeedback(hitPt)
						if ExistingPather and ExistingPather:IsActive() then
							ExistingPather:Cancel()
						end
						if PlayFailureAnimation then
							ClickToMoveDisplay.PlayFailureAnimation()
						end
						ClickToMoveDisplay.DisplayFailureWaypoint(hitPt)
					end

					function OnTap(tapPositions: {Vector3}, goToPoint: Vector3?, wasTouchTap: boolean?)
						-- Good to remember if this is the latest tap event
						local camera = Workspace.CurrentCamera
						local character = Player.Character

						if not CheckAlive() then return end

						-- This is a path tap position
						if #tapPositions == 1 or goToPoint then
							if camera then
								local unitRay = camera:ScreenPointToRay(tapPositions[1].x, tapPositions[1].y)
								local ray = Ray.new(unitRay.Origin, unitRay.Direction*1000)

								local myHumanoid = findPlayerHumanoid(Player)
								local hitPart, hitPt, hitNormal = Utility.Raycast(ray, true, getIgnoreList())

								local hitChar, hitHumanoid = Utility.FindCharacterAncestor(hitPart)
								if wasTouchTap and hitHumanoid and StarterGui:GetCore("AvatarContextMenuEnabled") then
									local clickedPlayer = Players:GetPlayerFromCharacter(hitHumanoid.Parent)
									if clickedPlayer then
										CleanupPath()
										return
									end
								end
								if goToPoint then
									hitPt = goToPoint
									hitChar = nil
								end
								if hitPt and character then
									-- Clean up current path
									CleanupPath()
									local thisPather = Pather(hitPt, hitNormal)
									if thisPather:IsValidPath() then
										HandleMoveTo(thisPather, hitPt, hitChar, character)
									else
										-- Clean up
										thisPather:Cleanup()
										-- Feedback here for when we don't have a good path
										ShowPathFailedFeedback(hitPt)
									end
								end
							end
						elseif #tapPositions >= 2 then
							if camera then
								-- Do shoot
								local currentWeapon = GetEquippedTool(character)
								if currentWeapon then
									currentWeapon:Activate()
								end
							end
						end
					end

					local function DisconnectEvent(event)
						if event then
							event:Disconnect()
						end
					end

					--[[ The ClickToMove Controller Class ]]--
					local KeyboardController = Keyboard()
					local ClickToMove = setmetatable({}, KeyboardController)
					ClickToMove.__index = ClickToMove

					function ClickToMove.new(CONTROL_ACTION_PRIORITY)
						local self = setmetatable(KeyboardController.new(CONTROL_ACTION_PRIORITY), ClickToMove)

						self.fingerTouches = {}
						self.numUnsunkTouches = 0
						-- PC simulation
						self.mouse1Down = tick()
						self.mouse1DownPos = Vector2.new()
						self.mouse2DownTime = tick()
						self.mouse2DownPos = Vector2.new()
						self.mouse2UpTime = tick()

						self.keyboardMoveVector = ZERO_VECTOR3

						self.tapConn = nil
						self.inputBeganConn = nil
						self.inputChangedConn = nil
						self.inputEndedConn = nil
						self.humanoidDiedConn = nil
						self.characterChildAddedConn = nil
						self.onCharacterAddedConn = nil
						self.characterChildRemovedConn = nil
						self.renderSteppedConn = nil
						self.menuOpenedConnection = nil

						self.running = false

						self.wasdEnabled = false

						return self
					end

					function ClickToMove:DisconnectEvents()
						DisconnectEvent(self.tapConn)
						DisconnectEvent(self.inputBeganConn)
						DisconnectEvent(self.inputChangedConn)
						DisconnectEvent(self.inputEndedConn)
						DisconnectEvent(self.humanoidDiedConn)
						DisconnectEvent(self.characterChildAddedConn)
						DisconnectEvent(self.onCharacterAddedConn)
						DisconnectEvent(self.renderSteppedConn)
						DisconnectEvent(self.characterChildRemovedConn)
						DisconnectEvent(self.menuOpenedConnection)
					end

					function ClickToMove:OnTouchBegan(input, processed)
						if self.fingerTouches[input] == nil and not processed then
							self.numUnsunkTouches = self.numUnsunkTouches + 1
						end
						self.fingerTouches[input] = processed
					end

					function ClickToMove:OnTouchChanged(input, processed)
						if self.fingerTouches[input] == nil then
							self.fingerTouches[input] = processed
							if not processed then
								self.numUnsunkTouches = self.numUnsunkTouches + 1
							end
						end
					end

					function ClickToMove:OnTouchEnded(input, processed)
						if self.fingerTouches[input] ~= nil and self.fingerTouches[input] == false then
							self.numUnsunkTouches = self.numUnsunkTouches - 1
						end
						self.fingerTouches[input] = nil
					end


					function ClickToMove:OnCharacterAdded(character)
						self:DisconnectEvents()

						self.inputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
							if input.UserInputType == Enum.UserInputType.Touch then
								self:OnTouchBegan(input, processed)
							end

							-- Cancel path when you use the keyboard controls if wasd is enabled.
							if self.wasdEnabled and processed == false and input.UserInputType == Enum.UserInputType.Keyboard
								and movementKeys[input.KeyCode] then
								CleanupPath()
								ClickToMoveDisplay.CancelFailureAnimation()
							end
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								self.mouse1DownTime = tick()
								self.mouse1DownPos = input.Position
							end
							if input.UserInputType == Enum.UserInputType.MouseButton2 then
								self.mouse2DownTime = tick()
								self.mouse2DownPos = input.Position
							end
						end)

						self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, processed)
							if input.UserInputType == Enum.UserInputType.Touch then
								self:OnTouchChanged(input, processed)
							end
						end)

						self.inputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
							if input.UserInputType == Enum.UserInputType.Touch then
								self:OnTouchEnded(input, processed)
							end

							if input.UserInputType == Enum.UserInputType.MouseButton2 then
								self.mouse2UpTime = tick()
								local currPos: Vector3 = input.Position
								-- We allow click to move during path following or if there is no keyboard movement
								local allowed = ExistingPather or self.keyboardMoveVector.Magnitude <= 0
								if self.mouse2UpTime - self.mouse2DownTime < 0.25 and (currPos - self.mouse2DownPos).magnitude < 5 and allowed then
									local positions = {currPos}
									OnTap(positions)
								end
							end
						end)

						self.tapConn = UserInputService.TouchTap:Connect(function(touchPositions, processed)
							if not processed then
								OnTap(touchPositions, nil, true)
							end
						end)

						self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
							CleanupPath()
						end)

						local function OnCharacterChildAdded(child)
							if UserInputService.TouchEnabled then
								if child:IsA('Tool') then
									child.ManualActivationOnly = true
								end
							end
							if child:IsA('Humanoid') then
								DisconnectEvent(self.humanoidDiedConn)
								self.humanoidDiedConn = child.Died:Connect(function()
									if ExistingIndicator then
										DebrisService:AddItem(ExistingIndicator.Model, 1)
									end
								end)
							end
						end

						self.characterChildAddedConn = character.ChildAdded:Connect(function(child)
							OnCharacterChildAdded(child)
						end)
						self.characterChildRemovedConn = character.ChildRemoved:Connect(function(child)
							if UserInputService.TouchEnabled then
								if child:IsA('Tool') then
									child.ManualActivationOnly = false
								end
							end
						end)
						for _, child in pairs(character:GetChildren()) do
							OnCharacterChildAdded(child)
						end
					end

					function ClickToMove:Start()
						self:Enable(true)
					end

					function ClickToMove:Stop()
						self:Enable(false)
					end

					function ClickToMove:CleanupPath()
						CleanupPath()
					end

					function ClickToMove:Enable(enable: boolean, enableWASD: boolean, touchJumpController)
						if enable then
							if not self.running then
								if Player.Character then -- retro-listen
									self:OnCharacterAdded(Player.Character)
								end
								self.onCharacterAddedConn = Player.CharacterAdded:Connect(function(char)
									self:OnCharacterAdded(char)
								end)
								self.running = true
							end
							self.touchJumpController = touchJumpController
							if self.touchJumpController then
								self.touchJumpController:Enable(self.jumpEnabled)
							end
						else
							if self.running then
								self:DisconnectEvents()
								CleanupPath()
								-- Restore tool activation on shutdown
								if UserInputService.TouchEnabled then
									local character = Player.Character
									if character then
										for _, child in pairs(character:GetChildren()) do
											if child:IsA('Tool') then
												child.ManualActivationOnly = false
											end
										end
									end
								end
								self.running = false
							end
							if self.touchJumpController and not self.jumpEnabled then
								self.touchJumpController:Enable(true)
							end
							self.touchJumpController = nil
						end

						-- Extension for initializing Keyboard input as this class now derives from Keyboard
						if UserInputService.KeyboardEnabled and enable ~= self.enabled then

							self.forwardValue  = 0
							self.backwardValue = 0
							self.leftValue = 0
							self.rightValue = 0

							self.moveVector = ZERO_VECTOR3

							if enable then
								self:BindContextActions()
								self:ConnectFocusEventListeners()
							else
								self:UnbindContextActions()
								self:DisconnectFocusEventListeners()
							end
						end

						self.wasdEnabled = enable and enableWASD or false
						self.enabled = enable
					end

					function ClickToMove:OnRenderStepped(dt)
						-- Reset jump
						self.isJumping = false

						-- Handle Pather
						if ExistingPather then
							-- Let the Pather update
							ExistingPather:OnRenderStepped(dt)

							-- If we still have a Pather, set the resulting actions
							if ExistingPather then
								-- Setup move (NOT relative to camera)
								self.moveVector = ExistingPather.NextActionMoveDirection
								self.moveVectorIsCameraRelative = false

								-- Setup jump (but do NOT prevent the base Keayboard class from requesting jumps as well)
								if ExistingPather.NextActionJump then
									self.isJumping = true
								end
							else
								self.moveVector = self.keyboardMoveVector
								self.moveVectorIsCameraRelative = true
							end
						else
							self.moveVector = self.keyboardMoveVector
							self.moveVectorIsCameraRelative = true
						end

						-- Handle Keyboard's jump
						if self.jumpRequested then
							self.isJumping = true
						end
					end

					-- Overrides Keyboard:UpdateMovement(inputState) to conditionally consider self.wasdEnabled and let OnRenderStepped handle the movement
					function ClickToMove:UpdateMovement(inputState)
						if inputState == Enum.UserInputState.Cancel then
							self.keyboardMoveVector = ZERO_VECTOR3
						elseif self.wasdEnabled then
							self.keyboardMoveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
						end
					end

					-- Overrides Keyboard:UpdateJump() because jump is handled in OnRenderStepped
					function ClickToMove:UpdateJump()
						-- Nothing to do (handled in OnRenderStepped)
					end

					--Public developer facing functions
					function ClickToMove:SetShowPath(value)
						ShowPath = value
					end

					function ClickToMove:GetShowPath()
						return ShowPath
					end

					function ClickToMove:SetWaypointTexture(texture)
						ClickToMoveDisplay.SetWaypointTexture(texture)
					end

					function ClickToMove:GetWaypointTexture()
						return ClickToMoveDisplay.GetWaypointTexture()
					end

					function ClickToMove:SetWaypointRadius(radius)
						ClickToMoveDisplay.SetWaypointRadius(radius)
					end

					function ClickToMove:GetWaypointRadius()
						return ClickToMoveDisplay.GetWaypointRadius()
					end

					function ClickToMove:SetEndWaypointTexture(texture)
						ClickToMoveDisplay.SetEndWaypointTexture(texture)
					end

					function ClickToMove:GetEndWaypointTexture()
						return ClickToMoveDisplay.GetEndWaypointTexture()
					end

					function ClickToMove:SetWaypointsAlwaysOnTop(alwaysOnTop)
						ClickToMoveDisplay.SetWaypointsAlwaysOnTop(alwaysOnTop)
					end

					function ClickToMove:GetWaypointsAlwaysOnTop()
						return ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
					end

					function ClickToMove:SetFailureAnimationEnabled(enabled)
						PlayFailureAnimation = enabled
					end

					function ClickToMove:GetFailureAnimationEnabled()
						return PlayFailureAnimation
					end

					function ClickToMove:SetIgnoredPartsTag(tag)
						UpdateIgnoreTag(tag)
					end

					function ClickToMove:GetIgnoredPartsTag()
						return CurrentIgnoreTag
					end

					function ClickToMove:SetUseDirectPath(directPath)
						UseDirectPath = directPath
					end

					function ClickToMove:GetUseDirectPath()
						return UseDirectPath
					end

					function ClickToMove:SetAgentSizeIncreaseFactor(increaseFactorPercent: number)
						AgentSizeIncreaseFactor = 1.0 + (increaseFactorPercent / 100.0)
					end

					function ClickToMove:GetAgentSizeIncreaseFactor()
						return (AgentSizeIncreaseFactor - 1.0) * 100.0
					end

					function ClickToMove:SetUnreachableWaypointTimeout(timeoutInSec)
						UnreachableWaypointTimeout = timeoutInSec
					end

					function ClickToMove:GetUnreachableWaypointTimeout()
						return UnreachableWaypointTimeout
					end

					function ClickToMove:SetUserJumpEnabled(jumpEnabled)
						self.jumpEnabled = jumpEnabled
						if self.touchJumpController then
							self.touchJumpController:Enable(jumpEnabled)
						end
					end

					function ClickToMove:GetUserJumpEnabled()
						return self.jumpEnabled
					end

					function ClickToMove:MoveTo(position, showPath, useDirectPath)
						local character = Player.Character
						if character == nil then
							return false
						end
						local thisPather = Pather(position, Vector3.new(0, 1, 0), useDirectPath)
						if thisPather and thisPather:IsValidPath() then
							HandleMoveTo(thisPather, position, nil, character, showPath)
							return true
						end
						return false
					end

					return ClickToMove

				end
				function ClickToMoveDisplay()
					local ClickToMoveDisplay = {}

					local FAILURE_ANIMATION_ID = "rbxassetid://2874840706"

					local TrailDotIcon = "rbxasset://textures/ui/traildot.png"
					local EndWaypointIcon = "rbxasset://textures/ui/waypoint.png"

					local WaypointsAlwaysOnTop = false

					local WAYPOINT_INCLUDE_FACTOR = 2
					local LAST_DOT_DISTANCE = 3

					local WAYPOINT_BILLBOARD_SIZE = UDim2.new(0, 1.68 * 25, 0, 2 * 25)

					local ENDWAYPOINT_SIZE_OFFSET_MIN = Vector2.new(0, 0.5)
					local ENDWAYPOINT_SIZE_OFFSET_MAX = Vector2.new(0, 1)

					local FAIL_WAYPOINT_SIZE_OFFSET_CENTER = Vector2.new(0, 0.5)
					local FAIL_WAYPOINT_SIZE_OFFSET_LEFT = Vector2.new(0.1, 0.5)
					local FAIL_WAYPOINT_SIZE_OFFSET_RIGHT = Vector2.new(-0.1, 0.5)

					local FAILURE_TWEEN_LENGTH = 0.125
					local FAILURE_TWEEN_COUNT = 4

					local TWEEN_WAYPOINT_THRESHOLD = 5

					local TRAIL_DOT_PARENT_NAME = "ClickToMoveDisplay"

					local TrailDotSize = Vector2.new(1.5, 1.5)

					local TRAIL_DOT_MIN_SCALE = 1
					local TRAIL_DOT_MIN_DISTANCE = 10
					local TRAIL_DOT_MAX_SCALE = 2.5
					local TRAIL_DOT_MAX_DISTANCE = 100

					local PlayersService = game:GetService("Players")
					local TweenService = game:GetService("TweenService")
					local RunService = game:GetService("RunService")
					local Workspace = game:GetService("Workspace")

					local LocalPlayer = PlayersService.LocalPlayer

					local function CreateWaypointTemplates()
						local TrailDotTemplate = Instance.new("Part")
						TrailDotTemplate.Size = Vector3.new(1, 1, 1)
						TrailDotTemplate.Anchored = true
						TrailDotTemplate.CanCollide = false
						TrailDotTemplate.Name = "TrailDot"
						TrailDotTemplate.Transparency = 1
						local TrailDotImage = Instance.new("ImageHandleAdornment")
						TrailDotImage.Name = "TrailDotImage"
						TrailDotImage.Size = TrailDotSize
						TrailDotImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
						TrailDotImage.AlwaysOnTop = WaypointsAlwaysOnTop
						TrailDotImage.Image = TrailDotIcon
						TrailDotImage.Adornee = TrailDotTemplate
						TrailDotImage.Parent = TrailDotTemplate

						local EndWaypointTemplate = Instance.new("Part")
						EndWaypointTemplate.Size = Vector3.new(2, 2, 2)
						EndWaypointTemplate.Anchored = true
						EndWaypointTemplate.CanCollide = false
						EndWaypointTemplate.Name = "EndWaypoint"
						EndWaypointTemplate.Transparency = 1
						local EndWaypointImage = Instance.new("ImageHandleAdornment")
						EndWaypointImage.Name = "TrailDotImage"
						EndWaypointImage.Size = TrailDotSize
						EndWaypointImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
						EndWaypointImage.AlwaysOnTop = WaypointsAlwaysOnTop
						EndWaypointImage.Image = TrailDotIcon
						EndWaypointImage.Adornee = EndWaypointTemplate
						EndWaypointImage.Parent = EndWaypointTemplate
						local EndWaypointBillboard = Instance.new("BillboardGui")
						EndWaypointBillboard.Name = "EndWaypointBillboard"
						EndWaypointBillboard.Size = WAYPOINT_BILLBOARD_SIZE
						EndWaypointBillboard.LightInfluence = 0
						EndWaypointBillboard.SizeOffset = ENDWAYPOINT_SIZE_OFFSET_MIN
						EndWaypointBillboard.AlwaysOnTop = true
						EndWaypointBillboard.Adornee = EndWaypointTemplate
						EndWaypointBillboard.Parent = EndWaypointTemplate
						local EndWaypointImageLabel = Instance.new("ImageLabel")
						EndWaypointImageLabel.Image = EndWaypointIcon
						EndWaypointImageLabel.BackgroundTransparency = 1
						EndWaypointImageLabel.Size = UDim2.new(1, 0, 1, 0)
						EndWaypointImageLabel.Parent = EndWaypointBillboard


						local FailureWaypointTemplate = Instance.new("Part")
						FailureWaypointTemplate.Size = Vector3.new(2, 2, 2)
						FailureWaypointTemplate.Anchored = true
						FailureWaypointTemplate.CanCollide = false
						FailureWaypointTemplate.Name = "FailureWaypoint"
						FailureWaypointTemplate.Transparency = 1
						local FailureWaypointImage = Instance.new("ImageHandleAdornment")
						FailureWaypointImage.Name = "TrailDotImage"
						FailureWaypointImage.Size = TrailDotSize
						FailureWaypointImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
						FailureWaypointImage.AlwaysOnTop = WaypointsAlwaysOnTop
						FailureWaypointImage.Image = TrailDotIcon
						FailureWaypointImage.Adornee = FailureWaypointTemplate
						FailureWaypointImage.Parent = FailureWaypointTemplate
						local FailureWaypointBillboard = Instance.new("BillboardGui")
						FailureWaypointBillboard.Name = "FailureWaypointBillboard"
						FailureWaypointBillboard.Size = WAYPOINT_BILLBOARD_SIZE
						FailureWaypointBillboard.LightInfluence = 0
						FailureWaypointBillboard.SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_CENTER
						FailureWaypointBillboard.AlwaysOnTop = true
						FailureWaypointBillboard.Adornee = FailureWaypointTemplate
						FailureWaypointBillboard.Parent = FailureWaypointTemplate
						local FailureWaypointFrame = Instance.new("Frame")
						FailureWaypointFrame.BackgroundTransparency = 1
						FailureWaypointFrame.Size = UDim2.new(0, 0, 0, 0)
						FailureWaypointFrame.Position = UDim2.new(0.5, 0, 1, 0)
						FailureWaypointFrame.Parent = FailureWaypointBillboard
						local FailureWaypointImageLabel = Instance.new("ImageLabel")
						FailureWaypointImageLabel.Image = EndWaypointIcon
						FailureWaypointImageLabel.BackgroundTransparency = 1
						FailureWaypointImageLabel.Position = UDim2.new(
							0, -WAYPOINT_BILLBOARD_SIZE.X.Offset/2, 0, -WAYPOINT_BILLBOARD_SIZE.Y.Offset
						)
						FailureWaypointImageLabel.Size = WAYPOINT_BILLBOARD_SIZE
						FailureWaypointImageLabel.Parent = FailureWaypointFrame

						return TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate
					end

					local TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()

					local function getTrailDotParent()
						local camera = Workspace.CurrentCamera
						local trailParent = camera:FindFirstChild(TRAIL_DOT_PARENT_NAME)
						if not trailParent then
							trailParent = Instance.new("Model")
							trailParent.Name = TRAIL_DOT_PARENT_NAME
							trailParent.Parent = camera
						end
						return trailParent
					end

					local function placePathWaypoint(waypointModel, position: Vector3)
						local ray = Ray.new(position + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0))
						local hitPart, hitPoint, hitNormal = Workspace:FindPartOnRayWithIgnoreList(
							ray,
							{ Workspace.CurrentCamera, LocalPlayer.Character }
						)
						if hitPart then
							waypointModel.CFrame = CFrame.new(hitPoint, hitPoint + hitNormal)
							waypointModel.Parent = getTrailDotParent()
						end
					end

					local TrailDot = {}
					TrailDot.__index = TrailDot

					function TrailDot:Destroy()
						self.DisplayModel:Destroy()
					end

					function TrailDot:NewDisplayModel(position)
						local newDisplayModel: Part = TrailDotTemplate:Clone()
						placePathWaypoint(newDisplayModel, position)
						return newDisplayModel
					end

					function TrailDot.new(position, closestWaypoint)
						local self = setmetatable({}, TrailDot)

						self.DisplayModel = self:NewDisplayModel(position)
						self.ClosestWayPoint = closestWaypoint

						return self
					end

					local EndWaypoint = {}
					EndWaypoint.__index = EndWaypoint

					function EndWaypoint:Destroy()
						self.Destroyed = true
						self.Tween:Cancel()
						self.DisplayModel:Destroy()
					end

					function EndWaypoint:NewDisplayModel(position)
						local newDisplayModel: Part = EndWaypointTemplate:Clone()
						placePathWaypoint(newDisplayModel, position)
						return newDisplayModel
					end

					function EndWaypoint:CreateTween()
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true)
						local tween = TweenService:Create(
							self.DisplayModel.EndWaypointBillboard,
							tweenInfo,
							{ SizeOffset = ENDWAYPOINT_SIZE_OFFSET_MAX }
						)
						tween:Play()
						return tween
					end

					function EndWaypoint:TweenInFrom(originalPosition: Vector3)
						local currentPositon: Vector3 = self.DisplayModel.Position
						local studsOffset = originalPosition - currentPositon
						self.DisplayModel.EndWaypointBillboard.StudsOffset = Vector3.new(0, studsOffset.Y, 0)
						local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tween = TweenService:Create(
							self.DisplayModel.EndWaypointBillboard,
							tweenInfo,
							{ StudsOffset = Vector3.new(0, 0, 0) }
						)
						tween:Play()
						return tween
					end

					function EndWaypoint.new(position: Vector3, closestWaypoint: number?, originalPosition: Vector3?)
						local self = setmetatable({}, EndWaypoint)

						self.DisplayModel = self:NewDisplayModel(position)
						self.Destroyed = false
						if originalPosition and (originalPosition - position).magnitude > TWEEN_WAYPOINT_THRESHOLD then
							self.Tween = self:TweenInFrom(originalPosition)
							coroutine.wrap(function()
								self.Tween.Completed:Wait()
								if not self.Destroyed then
									self.Tween = self:CreateTween()
								end
							end)()
						else
							self.Tween = self:CreateTween()
						end
						self.ClosestWayPoint = closestWaypoint

						return self
					end

					local FailureWaypoint = {}
					FailureWaypoint.__index = FailureWaypoint

					function FailureWaypoint:Hide()
						self.DisplayModel.Parent = nil
					end

					function FailureWaypoint:Destroy()
						self.DisplayModel:Destroy()
					end

					function FailureWaypoint:NewDisplayModel(position)
						local newDisplayModel: Part = FailureWaypointTemplate:Clone()
						placePathWaypoint(newDisplayModel, position)
						local ray = Ray.new(position + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0))
						local hitPart, hitPoint, hitNormal = Workspace:FindPartOnRayWithIgnoreList(
							ray, { Workspace.CurrentCamera, LocalPlayer.Character }
						)
						if hitPart then
							newDisplayModel.CFrame = CFrame.new(hitPoint, hitPoint + hitNormal)
							newDisplayModel.Parent = getTrailDotParent()
						end
						return newDisplayModel
					end

					function FailureWaypoint:RunFailureTween()
						wait(FAILURE_TWEEN_LENGTH) -- Delay one tween length betfore starting tweening
						-- Tween out from center
						local tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tweenLeft = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
							{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_LEFT })
						tweenLeft:Play()

						local tweenLeftRoation = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
							{ Rotation = 10 })
						tweenLeftRoation:Play()

						tweenLeft.Completed:wait()

						-- Tween back and forth
						tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out,
							FAILURE_TWEEN_COUNT - 1, true)
						local tweenSideToSide = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
							{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_RIGHT})
						tweenSideToSide:Play()

						-- Tween flash dark and roate left and right
						tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out,
							FAILURE_TWEEN_COUNT - 1, true)
						local tweenFlash = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame.ImageLabel, tweenInfo,
							{ ImageColor3 = Color3.new(0.75, 0.75, 0.75)})
						tweenFlash:Play()

						local tweenRotate = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
							{ Rotation = -10 })
						tweenRotate:Play()

						tweenSideToSide.Completed:wait()

						-- Tween back to center
						tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tweenCenter = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
							{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_CENTER })
						tweenCenter:Play()

						local tweenRoation = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
							{ Rotation = 0 })
						tweenRoation:Play()

						tweenCenter.Completed:wait()

						wait(FAILURE_TWEEN_LENGTH) -- Delay one tween length betfore removing
					end

					function FailureWaypoint.new(position)
						local self = setmetatable({}, FailureWaypoint)

						self.DisplayModel = self:NewDisplayModel(position)

						return self
					end

					local failureAnimation = Instance.new("Animation")
					failureAnimation.AnimationId = FAILURE_ANIMATION_ID

					local lastHumanoid = nil
					local lastFailureAnimationTrack: AnimationTrack? = nil

					local function getFailureAnimationTrack(myHumanoid)
						if myHumanoid == lastHumanoid then
							return lastFailureAnimationTrack
						end
						lastFailureAnimationTrack = myHumanoid:LoadAnimation(failureAnimation)
						lastFailureAnimationTrack.Priority = Enum.AnimationPriority.Action
						lastFailureAnimationTrack.Looped = false
						return lastFailureAnimationTrack
					end

					local function findPlayerHumanoid()
						local character = LocalPlayer.Character
						if character then
							return character:FindFirstChildOfClass("Humanoid")
						end
					end

					local function createTrailDots(wayPoints: {PathWaypoint}, originalEndWaypoint: Vector3)
						local newTrailDots = {}
						local count = 1
						for i = 1, #wayPoints - 1 do
							local closeToEnd = (wayPoints[i].Position - wayPoints[#wayPoints].Position).magnitude < LAST_DOT_DISTANCE
							local includeWaypoint = i % WAYPOINT_INCLUDE_FACTOR == 0 and not closeToEnd
							if includeWaypoint then
								local trailDot = TrailDot.new(wayPoints[i].Position, i)
								newTrailDots[count] = trailDot
								count = count + 1
							end
						end

						local newEndWaypoint = EndWaypoint.new(wayPoints[#wayPoints].Position, #wayPoints, originalEndWaypoint)
						table.insert(newTrailDots, newEndWaypoint)

						local reversedTrailDots = {}
						count = 1
						for i = #newTrailDots, 1, -1 do
							reversedTrailDots[count] = newTrailDots[i]
							count = count + 1
						end
						return reversedTrailDots
					end

					local function getTrailDotScale(distanceToCamera: number, defaultSize: Vector2)
						local rangeLength = TRAIL_DOT_MAX_DISTANCE - TRAIL_DOT_MIN_DISTANCE
						local inRangePoint = math.clamp(distanceToCamera - TRAIL_DOT_MIN_DISTANCE, 0, rangeLength)/rangeLength
						local scale = TRAIL_DOT_MIN_SCALE + (TRAIL_DOT_MAX_SCALE - TRAIL_DOT_MIN_SCALE)*inRangePoint
						return defaultSize * scale
					end

					local createPathCount = 0
					-- originalEndWaypoint is optional, causes the waypoint to tween from that position.
					function ClickToMoveDisplay.CreatePathDisplay(wayPoints, originalEndWaypoint)
						createPathCount = createPathCount + 1
						local trailDots = createTrailDots(wayPoints, originalEndWaypoint)

						local function removePathBeforePoint(wayPointNumber)
							-- kill all trailDots before and at wayPointNumber
							for i = #trailDots, 1, -1 do
								local trailDot = trailDots[i]
								if trailDot.ClosestWayPoint <= wayPointNumber then
									trailDot:Destroy()
									trailDots[i] = nil
								else
									break
								end
							end
						end

						local reiszeTrailDotsUpdateName = "ClickToMoveResizeTrail" ..createPathCount
						local function resizeTrailDots()
							if #trailDots == 0 then
								RunService:UnbindFromRenderStep(reiszeTrailDotsUpdateName)
								return
							end
							local cameraPos = Workspace.CurrentCamera.CFrame.p
							for i = 1, #trailDots do
								local trailDotImage: ImageHandleAdornment = trailDots[i].DisplayModel:FindFirstChild("TrailDotImage")
								if trailDotImage then
									local distanceToCamera = (trailDots[i].DisplayModel.Position - cameraPos).magnitude
									trailDotImage.Size = getTrailDotScale(distanceToCamera, TrailDotSize)
								end
							end
						end
						RunService:BindToRenderStep(reiszeTrailDotsUpdateName, Enum.RenderPriority.Camera.Value - 1, resizeTrailDots)

						local function removePath()
							removePathBeforePoint(#wayPoints)
						end

						return removePath, removePathBeforePoint
					end

					local lastFailureWaypoint = nil
					function ClickToMoveDisplay.DisplayFailureWaypoint(position)
						if lastFailureWaypoint then
							lastFailureWaypoint:Hide()
						end
						local failureWaypoint = FailureWaypoint.new(position)
						lastFailureWaypoint = failureWaypoint
						coroutine.wrap(function()
							failureWaypoint:RunFailureTween()
							failureWaypoint:Destroy()
							failureWaypoint = nil
						end)()
					end

					function ClickToMoveDisplay.CreateEndWaypoint(position)
						return EndWaypoint.new(position)
					end

					function ClickToMoveDisplay.PlayFailureAnimation()
						local myHumanoid = findPlayerHumanoid()
						if myHumanoid then
							local animationTrack = getFailureAnimationTrack(myHumanoid)
							animationTrack:Play()
						end
					end

					function ClickToMoveDisplay.CancelFailureAnimation()
						if lastFailureAnimationTrack ~= nil and lastFailureAnimationTrack.IsPlaying then
							lastFailureAnimationTrack:Stop()
						end
					end

					function ClickToMoveDisplay.SetWaypointTexture(texture)
						TrailDotIcon = texture
						TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
					end

					function ClickToMoveDisplay.GetWaypointTexture()
						return TrailDotIcon
					end

					function ClickToMoveDisplay.SetWaypointRadius(radius)
						TrailDotSize = Vector2.new(radius, radius)
						TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
					end

					function ClickToMoveDisplay.GetWaypointRadius()
						return TrailDotSize.X
					end

					function ClickToMoveDisplay.SetEndWaypointTexture(texture)
						EndWaypointIcon = texture
						TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
					end

					function ClickToMoveDisplay.GetEndWaypointTexture()
						return EndWaypointIcon
					end

					function ClickToMoveDisplay.SetWaypointsAlwaysOnTop(alwaysOnTop)
						WaypointsAlwaysOnTop = alwaysOnTop
						TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
					end

					function ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
						return WaypointsAlwaysOnTop
					end

					return ClickToMoveDisplay

				end
				function DynamicThumbstick()
					--[[ Constants ]]--
					local ZERO_VECTOR3 = Vector3.new(0,0,0)
					local TOUCH_CONTROLS_SHEET = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

					local DYNAMIC_THUMBSTICK_ACTION_NAME = "DynamicThumbstickAction"
					local DYNAMIC_THUMBSTICK_ACTION_PRIORITY = Enum.ContextActionPriority.High.Value

					local MIDDLE_TRANSPARENCIES = {
						1 - 0.89,
						1 - 0.70,
						1 - 0.60,
						1 - 0.50,
						1 - 0.40,
						1 - 0.30,
						1 - 0.25
					}
					local NUM_MIDDLE_IMAGES = #MIDDLE_TRANSPARENCIES

					local FADE_IN_OUT_BACKGROUND = true
					local FADE_IN_OUT_MAX_ALPHA = 0.35

					local FADE_IN_OUT_HALF_DURATION_DEFAULT = 0.3
					local FADE_IN_OUT_BALANCE_DEFAULT = 0.5
					local ThumbstickFadeTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

					local Players = game:GetService("Players")
					local GuiService = game:GetService("GuiService")
					local UserInputService = game:GetService("UserInputService")
					--local ContextActionService = game:GetService("ContextActionService")
					local RunService = game:GetService("RunService")
					local TweenService = game:GetService("TweenService")

					local LocalPlayer = Players.LocalPlayer
					if not LocalPlayer then
						Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
						LocalPlayer = Players.LocalPlayer
					end

					--[[ The Module ]]--
					local BaseCharacterController = BaseCharacterController()
					local DynamicThumbstick = setmetatable({}, BaseCharacterController)
					DynamicThumbstick.__index = DynamicThumbstick

					function DynamicThumbstick.new()
						local self = setmetatable(BaseCharacterController.new(), DynamicThumbstick)

						self.moveTouchObject = nil
						self.moveTouchLockedIn = false
						self.moveTouchFirstChanged = false
						self.moveTouchStartPosition = nil

						self.startImage = nil
						self.endImage = nil
						self.middleImages = {}

						self.startImageFadeTween = nil
						self.endImageFadeTween = nil
						self.middleImageFadeTweens = {}

						self.isFirstTouch = true

						self.thumbstickFrame = nil

						self.onRenderSteppedConn = nil

						self.fadeInAndOutBalance = FADE_IN_OUT_BALANCE_DEFAULT
						self.fadeInAndOutHalfDuration = FADE_IN_OUT_HALF_DURATION_DEFAULT
						self.hasFadedBackgroundInPortrait = false
						self.hasFadedBackgroundInLandscape = false

						self.tweenInAlphaStart = nil
						self.tweenOutAlphaStart = nil

						return self
					end

					-- Note: Overrides base class GetIsJumping with get-and-clear behavior to do a single jump
					-- rather than sustained jumping. This is only to preserve the current behavior through the refactor.
					function DynamicThumbstick:GetIsJumping()
						local wasJumping = self.isJumping
						self.isJumping = false
						return wasJumping
					end

					function DynamicThumbstick:Enable(enable: boolean?, uiParentFrame): boolean
						if enable == nil then return false end			-- If nil, return false (invalid argument)
						enable = enable and true or false				-- Force anything non-nil to boolean before comparison
						if self.enabled == enable then return true end	-- If no state change, return true indicating already in requested state

						if enable then
							-- Enable
							if not self.thumbstickFrame then
								self:Create(uiParentFrame)
							end

							self:BindContextActions()
						else
							ContextActionService:UnbindAction(DYNAMIC_THUMBSTICK_ACTION_NAME)
							-- Disable
							self:OnInputEnded() -- Cleanup
						end

						self.enabled = enable
						self.thumbstickFrame.Visible = enable
					end

					-- Was called OnMoveTouchEnded in previous version
					function DynamicThumbstick:OnInputEnded()
						self.moveTouchObject = nil
						self.moveVector = ZERO_VECTOR3
						self:FadeThumbstick(false)
					end

					function DynamicThumbstick:FadeThumbstick(visible: boolean?)
						if not visible and self.moveTouchObject then
							return
						end
						if self.isFirstTouch then return end

						if self.startImageFadeTween then
							self.startImageFadeTween:Cancel()
						end
						if self.endImageFadeTween then
							self.endImageFadeTween:Cancel()
						end
						for i = 1, #self.middleImages do
							if self.middleImageFadeTweens[i] then
								self.middleImageFadeTweens[i]:Cancel()
							end
						end

						if visible then
							self.startImageFadeTween = TweenService:Create(self.startImage, ThumbstickFadeTweenInfo, { ImageTransparency = 0 })
							self.startImageFadeTween:Play()

							self.endImageFadeTween = TweenService:Create(self.endImage, ThumbstickFadeTweenInfo, { ImageTransparency = 0.2 })
							self.endImageFadeTween:Play()

							for i = 1, #self.middleImages do
								self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], ThumbstickFadeTweenInfo, { ImageTransparency = MIDDLE_TRANSPARENCIES[i] })
								self.middleImageFadeTweens[i]:Play()
							end
						else
							self.startImageFadeTween = TweenService:Create(self.startImage, ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
							self.startImageFadeTween:Play()

							self.endImageFadeTween = TweenService:Create(self.endImage, ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
							self.endImageFadeTween:Play()

							for i = 1, #self.middleImages do
								self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
								self.middleImageFadeTweens[i]:Play()
							end
						end
					end

					function DynamicThumbstick:FadeThumbstickFrame(fadeDuration: number, fadeRatio: number)
						self.fadeInAndOutHalfDuration = fadeDuration * 0.5
						self.fadeInAndOutBalance = fadeRatio
						self.tweenInAlphaStart = tick()
					end

					function DynamicThumbstick:InputInFrame(inputObject: InputObject)
						local frameCornerTopLeft: Vector2 = self.thumbstickFrame.AbsolutePosition
						local frameCornerBottomRight = frameCornerTopLeft + self.thumbstickFrame.AbsoluteSize
						local inputPosition = inputObject.Position
						if inputPosition.X >= frameCornerTopLeft.X and inputPosition.Y >= frameCornerTopLeft.Y then
							if inputPosition.X <= frameCornerBottomRight.X and inputPosition.Y <= frameCornerBottomRight.Y then
								return true
							end
						end
						return false
					end

					function DynamicThumbstick:DoFadeInBackground()
						local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
						local hasFadedBackgroundInOrientation = false

						-- only fade in/out the background once per orientation
						if playerGui then
							if playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or
								playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight then
								hasFadedBackgroundInOrientation = self.hasFadedBackgroundInLandscape
								self.hasFadedBackgroundInLandscape = true
							elseif playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait then
								hasFadedBackgroundInOrientation = self.hasFadedBackgroundInPortrait
								self.hasFadedBackgroundInPortrait = true
							end
						end

						if not hasFadedBackgroundInOrientation then
							self.fadeInAndOutHalfDuration = FADE_IN_OUT_HALF_DURATION_DEFAULT
							self.fadeInAndOutBalance = FADE_IN_OUT_BALANCE_DEFAULT
							self.tweenInAlphaStart = tick()
						end
					end

					function DynamicThumbstick:DoMove(direction: Vector3)
						local currentMoveVector: Vector3 = direction

						-- Scaled Radial Dead Zone
						local inputAxisMagnitude: number = currentMoveVector.magnitude
						if inputAxisMagnitude < self.radiusOfDeadZone then
							currentMoveVector = ZERO_VECTOR3
						else
							currentMoveVector = currentMoveVector.unit*(
								1 - math.max(0, (self.radiusOfMaxSpeed - currentMoveVector.magnitude)/self.radiusOfMaxSpeed)
							)
							currentMoveVector = Vector3.new(currentMoveVector.x, 0, currentMoveVector.y)
						end

						self.moveVector = currentMoveVector
					end


					function DynamicThumbstick:LayoutMiddleImages(startPos: Vector3, endPos: Vector3)
						local startDist = (self.thumbstickSize / 2) + self.middleSize
						local vector = endPos - startPos
						local distAvailable = vector.magnitude - (self.thumbstickRingSize / 2) - self.middleSize
						local direction = vector.unit

						local distNeeded = self.middleSpacing * NUM_MIDDLE_IMAGES
						local spacing = self.middleSpacing

						if distNeeded < distAvailable then
							spacing = distAvailable / NUM_MIDDLE_IMAGES
						end

						for i = 1, NUM_MIDDLE_IMAGES do
							local image = self.middleImages[i]
							local distWithout = startDist + (spacing * (i - 2))
							local currentDist = startDist + (spacing * (i - 1))

							if distWithout < distAvailable then
								local pos = endPos - direction * currentDist
								local exposedFraction = math.clamp(1 - ((currentDist - distAvailable) / spacing), 0, 1)

								image.Visible = true
								image.Position = UDim2.new(0, pos.X, 0, pos.Y)
								image.Size = UDim2.new(0, self.middleSize * exposedFraction, 0, self.middleSize * exposedFraction)
							else
								image.Visible = false
							end
						end
					end

					function DynamicThumbstick:MoveStick(pos)
						local vector2StartPosition = Vector2.new(self.moveTouchStartPosition.X, self.moveTouchStartPosition.Y)
						local startPos = vector2StartPosition - self.thumbstickFrame.AbsolutePosition
						local endPos = Vector2.new(pos.X, pos.Y) - self.thumbstickFrame.AbsolutePosition
						self.endImage.Position = UDim2.new(0, endPos.X, 0, endPos.Y)
						self:LayoutMiddleImages(startPos, endPos)
					end

					function DynamicThumbstick:BindContextActions()
						local function inputBegan(inputObject)
							if self.moveTouchObject then
								return Enum.ContextActionResult.Pass
							end

							if not self:InputInFrame(inputObject) then
								return Enum.ContextActionResult.Pass
							end

							if self.isFirstTouch then
								self.isFirstTouch = false
								local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0)
								TweenService:Create(self.startImage, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
								TweenService:Create(
									self.endImage,
									tweenInfo,
									{Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize), ImageColor3 = Color3.new(0,0,0)}
								):Play()
							end

							self.moveTouchLockedIn = false
							self.moveTouchObject = inputObject
							self.moveTouchStartPosition = inputObject.Position
							self.moveTouchFirstChanged = true

							if FADE_IN_OUT_BACKGROUND then
								self:DoFadeInBackground()
							end

							return Enum.ContextActionResult.Pass
						end

						local function inputChanged(inputObject: InputObject)
							if inputObject == self.moveTouchObject then
								if self.moveTouchFirstChanged then
									self.moveTouchFirstChanged = false

									local startPosVec2 = Vector2.new(
										inputObject.Position.X - self.thumbstickFrame.AbsolutePosition.X,
										inputObject.Position.Y - self.thumbstickFrame.AbsolutePosition.Y
									)
									self.startImage.Visible = true
									self.startImage.Position = UDim2.new(0, startPosVec2.X, 0, startPosVec2.Y)
									self.endImage.Visible = true
									self.endImage.Position = self.startImage.Position

									self:FadeThumbstick(true)
									self:MoveStick(inputObject.Position)
								end

								self.moveTouchLockedIn = true

								local direction = Vector2.new(
									inputObject.Position.x - self.moveTouchStartPosition.x,
									inputObject.Position.y - self.moveTouchStartPosition.y
								)
								if math.abs(direction.x) > 0 or math.abs(direction.y) > 0 then
									self:DoMove(direction)
									self:MoveStick(inputObject.Position)
								end
								return Enum.ContextActionResult.Sink
							end
							return Enum.ContextActionResult.Pass
						end

						local function inputEnded(inputObject)
							if inputObject == self.moveTouchObject then
								self:OnInputEnded()
								if self.moveTouchLockedIn then
									return Enum.ContextActionResult.Sink
								end
							end
							return Enum.ContextActionResult.Pass
						end

						local function handleInput(actionName, inputState, inputObject)
							if inputState == Enum.UserInputState.Begin then
								return inputBegan(inputObject)
							elseif inputState == Enum.UserInputState.Change then
								return inputChanged(inputObject)
							elseif inputState == Enum.UserInputState.End then
								return inputEnded(inputObject)
							elseif inputState == Enum.UserInputState.Cancel then
								self:OnInputEnded()
							end
						end

						ContextActionService:BindActionAtPriority(
							DYNAMIC_THUMBSTICK_ACTION_NAME,
							handleInput,
							false,
							DYNAMIC_THUMBSTICK_ACTION_PRIORITY,
							Enum.UserInputType.Touch)
					end

					function DynamicThumbstick:Create(parentFrame: GuiBase2d)
						if self.thumbstickFrame then
							self.thumbstickFrame:Destroy()
							self.thumbstickFrame = nil
							if self.onRenderSteppedConn then
								self.onRenderSteppedConn:Disconnect()
								self.onRenderSteppedConn = nil
							end
						end

						self.thumbstickSize = 45
						self.thumbstickRingSize = 20
						self.middleSize = 10
						self.middleSpacing = self.middleSize + 4
						self.radiusOfDeadZone = 2
						self.radiusOfMaxSpeed = 20

						local screenSize = parentFrame.AbsoluteSize
						local isBigScreen = math.min(screenSize.x, screenSize.y) > 500
						if isBigScreen then
							self.thumbstickSize = self.thumbstickSize * 2
							self.thumbstickRingSize = self.thumbstickRingSize * 2
							self.middleSize = self.middleSize * 2
							self.middleSpacing = self.middleSpacing * 2
							self.radiusOfDeadZone = self.radiusOfDeadZone * 2
							self.radiusOfMaxSpeed = self.radiusOfMaxSpeed * 2
						end

						local function layoutThumbstickFrame(portraitMode)
							if portraitMode then
								self.thumbstickFrame.Size = UDim2.new(1, 0, 0.4, 0)
								self.thumbstickFrame.Position = UDim2.new(0, 0, 0.6, 0)
							else
								self.thumbstickFrame.Size = UDim2.new(0.4, 0, 2/3, 0)
								self.thumbstickFrame.Position = UDim2.new(0, 0, 1/3, 0)
							end
						end

						self.thumbstickFrame = Instance.new("Frame")
						self.thumbstickFrame.BorderSizePixel = 0
						self.thumbstickFrame.Name = "DynamicThumbstickFrame"
						self.thumbstickFrame.Visible = false
						self.thumbstickFrame.BackgroundTransparency = 1.0
						self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
						self.thumbstickFrame.Active = false
						layoutThumbstickFrame(false)

						self.startImage = Instance.new("ImageLabel")
						self.startImage.Name = "ThumbstickStart"
						self.startImage.Visible = true
						self.startImage.BackgroundTransparency = 1
						self.startImage.Image = TOUCH_CONTROLS_SHEET
						self.startImage.ImageRectOffset = Vector2.new(1,1)
						self.startImage.ImageRectSize = Vector2.new(144, 144)
						self.startImage.ImageColor3 = Color3.new(0, 0, 0)
						self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
						self.startImage.Position = UDim2.new(0, self.thumbstickRingSize * 3.3, 1, -self.thumbstickRingSize  * 2.8)
						self.startImage.Size = UDim2.new(0, self.thumbstickRingSize  * 3.7, 0, self.thumbstickRingSize  * 3.7)
						self.startImage.ZIndex = 10
						self.startImage.Parent = self.thumbstickFrame

						self.endImage = Instance.new("ImageLabel")
						self.endImage.Name = "ThumbstickEnd"
						self.endImage.Visible = true
						self.endImage.BackgroundTransparency = 1
						self.endImage.Image = TOUCH_CONTROLS_SHEET
						self.endImage.ImageRectOffset = Vector2.new(1,1)
						self.endImage.ImageRectSize =  Vector2.new(144, 144)
						self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
						self.endImage.Position = self.startImage.Position
						self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
						self.endImage.ZIndex = 10
						self.endImage.Parent = self.thumbstickFrame

						for i = 1, NUM_MIDDLE_IMAGES do
							self.middleImages[i] = Instance.new("ImageLabel")
							self.middleImages[i].Name = "ThumbstickMiddle"
							self.middleImages[i].Visible = false
							self.middleImages[i].BackgroundTransparency = 1
							self.middleImages[i].Image = TOUCH_CONTROLS_SHEET
							self.middleImages[i].ImageRectOffset = Vector2.new(1,1)
							self.middleImages[i].ImageRectSize = Vector2.new(144, 144)
							self.middleImages[i].ImageTransparency = MIDDLE_TRANSPARENCIES[i]
							self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
							self.middleImages[i].ZIndex = 9
							self.middleImages[i].Parent = self.thumbstickFrame
						end

						local CameraChangedConn: RBXScriptConnection? = nil
						local function onCurrentCameraChanged()
							if CameraChangedConn then
								CameraChangedConn:Disconnect()
								CameraChangedConn = nil
							end
							local newCamera = workspace.CurrentCamera
							if newCamera then
								local function onViewportSizeChanged()
									local size = newCamera.ViewportSize
									local portraitMode = size.X < size.Y
									layoutThumbstickFrame(portraitMode)
								end
								CameraChangedConn = newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
								onViewportSizeChanged()
							end
						end
						workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)
						if workspace.CurrentCamera then
							onCurrentCameraChanged()
						end

						self.moveTouchStartPosition = nil

						self.startImageFadeTween = nil
						self.endImageFadeTween = nil
						self.middleImageFadeTweens = {}

						self.onRenderSteppedConn = RunService.RenderStepped:Connect(function()
							if self.tweenInAlphaStart ~= nil then
								local delta = tick() - self.tweenInAlphaStart
								local fadeInTime = (self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance)
								self.thumbstickFrame.BackgroundTransparency = 1 - FADE_IN_OUT_MAX_ALPHA*math.min(delta/fadeInTime, 1)
								if delta > fadeInTime then
									self.tweenOutAlphaStart = tick()
									self.tweenInAlphaStart = nil
								end
							elseif self.tweenOutAlphaStart ~= nil then
								local delta = tick() - self.tweenOutAlphaStart
								local fadeOutTime = (self.fadeInAndOutHalfDuration * 2) - (self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance)
								self.thumbstickFrame.BackgroundTransparency = 1 - FADE_IN_OUT_MAX_ALPHA + FADE_IN_OUT_MAX_ALPHA*math.min(delta/fadeOutTime, 1)
								if delta > fadeOutTime  then
									self.tweenOutAlphaStart = nil
								end
							end
						end)

						self.onTouchEndedConn = UserInputService.TouchEnded:connect(function(inputObject: InputObject)
							if inputObject == self.moveTouchObject then
								self:OnInputEnded()
							end
						end)

						GuiService.MenuOpened:connect(function()
							if self.moveTouchObject then
								self:OnInputEnded()
							end
						end)

						local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
						while not playerGui do
							LocalPlayer.ChildAdded:wait()
							playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
						end

						local playerGuiChangedConn = nil
						local originalScreenOrientationWasLandscape =	playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or
							playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

						local function longShowBackground()
							self.fadeInAndOutHalfDuration = 2.5
							self.fadeInAndOutBalance = 0.05
							self.tweenInAlphaStart = tick()
						end

						playerGuiChangedConn = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
							if (originalScreenOrientationWasLandscape and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait) or
								(not originalScreenOrientationWasLandscape and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait) then

								playerGuiChangedConn:disconnect()
								longShowBackground()

								if originalScreenOrientationWasLandscape then
									self.hasFadedBackgroundInPortrait = true
								else
									self.hasFadedBackgroundInLandscape = true
								end
							end
						end)

						self.thumbstickFrame.Parent = parentFrame

						if game:IsLoaded() then
							longShowBackground()
						else
							coroutine.wrap(function()
								game.Loaded:Wait()
								longShowBackground()
							end)()
						end
					end

					return DynamicThumbstick

				end
				function Gamepad()
	--[[
	Gamepad Character Control - This module handles controlling your avatar using a game console-style controller

	2018 PlayerScripts Update - AllYourBlox
--]]

					local UserInputService = game:GetService("UserInputService")
					--local ContextActionService = game:GetService("ContextActionService")

					--[[ Constants ]]--
					local ZERO_VECTOR3 = Vector3.new(0,0,0)
					local NONE = Enum.UserInputType.None
					local thumbstickDeadzone = 0.2

					--[[ The Module ]]--
					local BaseCharacterController = BaseCharacterController()
					local Gamepad = setmetatable({}, BaseCharacterController)
					Gamepad.__index = Gamepad

					function Gamepad.new(CONTROL_ACTION_PRIORITY)
						local self = setmetatable(BaseCharacterController.new(), Gamepad)

						self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

						self.forwardValue  = 0
						self.backwardValue = 0
						self.leftValue = 0
						self.rightValue = 0

						self.activeGamepad = NONE	-- Enum.UserInputType.Gamepad1, 2, 3...
						self.gamepadConnectedConn = nil
						self.gamepadDisconnectedConn = nil
						return self
					end

					function Gamepad:Enable(enable: boolean): boolean
						if not UserInputService.GamepadEnabled then
							return false
						end

						if enable == self.enabled then
							-- Module is already in the state being requested. True is returned here since the module will be in the state
							-- expected by the code that follows the Enable() call. This makes more sense than returning false to indicate
							-- no action was necessary. False indicates failure to be in requested/expected state.
							return true
						end

						self.forwardValue  = 0
						self.backwardValue = 0
						self.leftValue = 0
						self.rightValue = 0
						self.moveVector = ZERO_VECTOR3
						self.isJumping = false

						if enable then
							self.activeGamepad = self:GetHighestPriorityGamepad()
							if self.activeGamepad ~= NONE then
								self:BindContextActions()
								self:ConnectGamepadConnectionListeners()
							else
								-- No connected gamepads, failure to enable
								return false
							end
						else
							self:UnbindContextActions()
							self:DisconnectGamepadConnectionListeners()
							self.activeGamepad = NONE
						end

						self.enabled = enable
						return true
					end

					-- This function selects the lowest number gamepad from the currently-connected gamepad
					-- and sets it as the active gamepad
					function Gamepad:GetHighestPriorityGamepad()
						local connectedGamepads = UserInputService:GetConnectedGamepads()
						local bestGamepad = NONE -- Note that this value is higher than all valid gamepad values
						for _, gamepad in pairs(connectedGamepads) do
							if gamepad.Value < bestGamepad.Value then
								bestGamepad = gamepad
							end
						end
						return bestGamepad
					end

					function Gamepad:BindContextActions()

						if self.activeGamepad == NONE then
							-- There must be an active gamepad to set up bindings
							return false
						end

						local handleJumpAction = function(actionName, inputState, inputObject)
							self.isJumping = (inputState == Enum.UserInputState.Begin)
							return Enum.ContextActionResult.Sink
						end

						local handleThumbstickInput = function(actionName, inputState, inputObject)

							if inputState == Enum.UserInputState.Cancel then
								self.moveVector = ZERO_VECTOR3
								return Enum.ContextActionResult.Sink
							end

							if self.activeGamepad ~= inputObject.UserInputType then
								return Enum.ContextActionResult.Pass
							end
							if inputObject.KeyCode ~= Enum.KeyCode.Thumbstick1 then return end

							if inputObject.Position.magnitude > thumbstickDeadzone then
								self.moveVector  =  Vector3.new(inputObject.Position.X, 0, -inputObject.Position.Y)
							else
								self.moveVector = ZERO_VECTOR3
							end
							return Enum.ContextActionResult.Sink
						end

						ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
						ContextActionService:BindActionAtPriority("jumpAction", handleJumpAction, false,
							self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonA)
						ContextActionService:BindActionAtPriority("moveThumbstick", handleThumbstickInput, false,
							self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Thumbstick1)

						return true
					end

					function Gamepad:UnbindContextActions()
						if self.activeGamepad ~= NONE then
							ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
						end
						ContextActionService:UnbindAction("moveThumbstick")
						ContextActionService:UnbindAction("jumpAction")
					end

					function Gamepad:OnNewGamepadConnected()
						-- A new gamepad has been connected.
						local bestGamepad: Enum.UserInputType = self:GetHighestPriorityGamepad()

						if bestGamepad == self.activeGamepad then
							-- A new gamepad was connected, but our active gamepad is not changing
							return
						end

						if bestGamepad == NONE then
							-- There should be an active gamepad when GamepadConnected fires, so this should not
							-- normally be hit. If there is no active gamepad, unbind actions but leave
							-- the module enabled and continue to listen for a new gamepad connection.
							warn("Gamepad:OnNewGamepadConnected found no connected gamepads")
							self:UnbindContextActions()
							return
						end

						if self.activeGamepad ~= NONE then
							-- Switching from one active gamepad to another
							self:UnbindContextActions()
						end

						self.activeGamepad = bestGamepad
						self:BindContextActions()
					end

					function Gamepad:OnCurrentGamepadDisconnected()
						if self.activeGamepad ~= NONE then
							ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
						end

						local bestGamepad = self:GetHighestPriorityGamepad()

						if self.activeGamepad ~= NONE and bestGamepad == self.activeGamepad then
							warn("Gamepad:OnCurrentGamepadDisconnected found the supposedly disconnected gamepad in connectedGamepads.")
							self:UnbindContextActions()
							self.activeGamepad = NONE
							return
						end

						if bestGamepad == NONE then
							-- No active gamepad, unbinding actions but leaving gamepad connection listener active
							self:UnbindContextActions()
							self.activeGamepad = NONE
						else
							-- Set new gamepad as active and bind to tool activation
							self.activeGamepad = bestGamepad
							ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
						end
					end

					function Gamepad:ConnectGamepadConnectionListeners()
						self.gamepadConnectedConn = UserInputService.GamepadConnected:Connect(function(gamepadEnum)
							self:OnNewGamepadConnected()
						end)

						self.gamepadDisconnectedConn = UserInputService.GamepadDisconnected:Connect(function(gamepadEnum)
							if self.activeGamepad == gamepadEnum then
								self:OnCurrentGamepadDisconnected()
							end
						end)

					end

					function Gamepad:DisconnectGamepadConnectionListeners()
						if self.gamepadConnectedConn then
							self.gamepadConnectedConn:Disconnect()
							self.gamepadConnectedConn = nil
						end

						if self.gamepadDisconnectedConn then
							self.gamepadDisconnectedConn:Disconnect()
							self.gamepadDisconnectedConn = nil
						end
					end

					return Gamepad

				end
				function Keyboard()
	--[[
	Keyboard Character Control - This module handles controlling your avatar from a keyboard

	2018 PlayerScripts Update - AllYourBlox
--]]

					--[[ Roblox Services ]]--
					local UserInputService = game:GetService("UserInputService")
					--local ContextActionService = game:GetService("ContextActionService")

					--[[ Constants ]]--
					local ZERO_VECTOR3 = Vector3.new(0,0,0)

					--[[ The Module ]]--
					local BaseCharacterController = BaseCharacterController()
					local Keyboard = setmetatable({}, BaseCharacterController)
					Keyboard.__index = Keyboard

					function Keyboard.new(CONTROL_ACTION_PRIORITY)
						local self = setmetatable(BaseCharacterController.new(), Keyboard)

						self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

						self.textFocusReleasedConn = nil
						self.textFocusGainedConn = nil
						self.windowFocusReleasedConn = nil

						self.forwardValue  = 0
						self.backwardValue = 0
						self.leftValue = 0
						self.rightValue = 0

						self.jumpEnabled = true

						return self
					end

					function Keyboard:Enable(enable: boolean)
						if not UserInputService.KeyboardEnabled then
							return false
						end

						if enable == self.enabled then
							-- Module is already in the state being requested. True is returned here since the module will be in the state
							-- expected by the code that follows the Enable() call. This makes more sense than returning false to indicate
							-- no action was necessary. False indicates failure to be in requested/expected state.
							return true
						end

						self.forwardValue  = 0
						self.backwardValue = 0
						self.leftValue = 0
						self.rightValue = 0
						self.moveVector = ZERO_VECTOR3
						self.jumpRequested = false
						self:UpdateJump()

						if enable then
							self:BindContextActions()
							self:ConnectFocusEventListeners()
						else
							self:UnbindContextActions()
							self:DisconnectFocusEventListeners()
						end

						self.enabled = enable
						return true
					end

					function Keyboard:UpdateMovement(inputState)
						if inputState == Enum.UserInputState.Cancel then
							self.moveVector = ZERO_VECTOR3
						else
							self.moveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
						end
					end

					function Keyboard:UpdateJump()
						self.isJumping = self.jumpRequested
					end

					function Keyboard:BindContextActions()

						-- Note: In the previous version of this code, the movement values were not zeroed-out on UserInputState. Cancel, now they are,
						-- which fixes them from getting stuck on.
						-- We return ContextActionResult.Pass here for legacy reasons.
						-- Many games rely on gameProcessedEvent being false on UserInputService.InputBegan for these control actions.
						local handleMoveForward = function(actionName, inputState, inputObject)
							self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
							self:UpdateMovement(inputState)
							return Enum.ContextActionResult.Pass
						end

						local handleMoveBackward = function(actionName, inputState, inputObject)
							self.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
							self:UpdateMovement(inputState)
							return Enum.ContextActionResult.Pass
						end

						local handleMoveLeft = function(actionName, inputState, inputObject)
							self.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
							self:UpdateMovement(inputState)
							return Enum.ContextActionResult.Pass
						end

						local handleMoveRight = function(actionName, inputState, inputObject)
							self.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
							self:UpdateMovement(inputState)
							return Enum.ContextActionResult.Pass
						end

						local handleJumpAction = function(actionName, inputState, inputObject)
							self.jumpRequested = self.jumpEnabled and (inputState == Enum.UserInputState.Begin)
							self:UpdateJump()
							return Enum.ContextActionResult.Pass
						end

						-- TODO: Revert to KeyCode bindings so that in the future the abstraction layer from actual keys to
						-- movement direction is done in Lua
						ContextActionService:BindActionAtPriority("moveForwardAction", handleMoveForward, false,
							self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterForward)
						ContextActionService:BindActionAtPriority("moveBackwardAction", handleMoveBackward, false,
							self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterBackward)
						ContextActionService:BindActionAtPriority("moveLeftAction", handleMoveLeft, false,
							self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterLeft)
						ContextActionService:BindActionAtPriority("moveRightAction", handleMoveRight, false,
							self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterRight)
						ContextActionService:BindActionAtPriority("jumpAction", handleJumpAction, false,
							self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterJump)
					end

					function Keyboard:UnbindContextActions()
						ContextActionService:UnbindAction("moveForwardAction")
						ContextActionService:UnbindAction("moveBackwardAction")
						ContextActionService:UnbindAction("moveLeftAction")
						ContextActionService:UnbindAction("moveRightAction")
						ContextActionService:UnbindAction("jumpAction")
					end

					function Keyboard:ConnectFocusEventListeners()
						local function onFocusReleased()
							self.moveVector = ZERO_VECTOR3
							self.forwardValue  = 0
							self.backwardValue = 0
							self.leftValue = 0
							self.rightValue = 0
							self.jumpRequested = false
							self:UpdateJump()
						end

						local function onTextFocusGained(textboxFocused)
							self.jumpRequested = false
							self:UpdateJump()
						end

						self.textFocusReleasedConn = UserInputService.TextBoxFocusReleased:Connect(onFocusReleased)
						self.textFocusGainedConn = UserInputService.TextBoxFocused:Connect(onTextFocusGained)
						self.windowFocusReleasedConn = UserInputService.WindowFocused:Connect(onFocusReleased)
					end

					function Keyboard:DisconnectFocusEventListeners()
						if self.textFocusReleasedConn then
							self.textFocusReleasedConn:Disconnect()
							self.textFocusReleasedConn = nil
						end
						if self.textFocusGainedConn then
							self.textFocusGainedConn:Disconnect()
							self.textFocusGainedConn = nil
						end
						if self.windowFocusReleasedConn then
							self.windowFocusReleasedConn:Disconnect()
							self.windowFocusReleasedConn = nil
						end
					end

					return Keyboard

				end
				function PathDisplay()


					local PathDisplay = {}
					PathDisplay.spacing = 8
					PathDisplay.image = "rbxasset://textures/Cursors/Gamepad/Pointer.png"
					PathDisplay.imageSize = Vector2.new(2, 2)

					local currentPoints = {}
					local renderedPoints = {}

					local pointModel = Instance.new("Model")
					pointModel.Name = "PathDisplayPoints"

					local adorneePart = Instance.new("Part")
					adorneePart.Anchored = true
					adorneePart.CanCollide = false
					adorneePart.Transparency = 1
					adorneePart.Name = "PathDisplayAdornee"
					adorneePart.CFrame = CFrame.new(0, 0, 0)
					adorneePart.Parent = pointModel

					local pointPool = {}
					local poolTop = 30
					for i = 1, poolTop do
						local point = Instance.new("ImageHandleAdornment")
						point.Archivable = false
						point.Adornee = adorneePart
						point.Image = PathDisplay.image
						point.Size = PathDisplay.imageSize
						pointPool[i] = point
					end

					local function retrieveFromPool(): ImageHandleAdornment
						local point = pointPool[1]
						if not point then
							return
						end

						pointPool[1], pointPool[poolTop] = pointPool[poolTop], nil
						poolTop = poolTop - 1
						return point
					end

					local function returnToPool(point: ImageHandleAdornment)
						poolTop = poolTop + 1
						pointPool[poolTop] = point
					end

					local function renderPoint(point: Vector3, isLast): ImageHandleAdornment
						if poolTop == 0 then
							return
						end

						local rayDown = Ray.new(point + Vector3.new(0, 2, 0), Vector3.new(0, -8, 0))
						local hitPart, hitPoint, hitNormal = workspace:FindPartOnRayWithIgnoreList(rayDown, { game.Players.LocalPlayer.Character, workspace.CurrentCamera  }) 	
						if not hitPart then
							return
						end

						local pointCFrame = CFrame.new(hitPoint, hitPoint + hitNormal)

						local point = retrieveFromPool()
						point.CFrame = pointCFrame
						point.Parent = pointModel
						return point
					end

					function PathDisplay.setCurrentPoints(points)
						if typeof(points) == 'table' then
							currentPoints = points
						else
							currentPoints = {}
						end
					end

					function PathDisplay.clearRenderedPath()
						for _, oldPoint in ipairs(renderedPoints) do
							oldPoint.Parent = nil
							returnToPool(oldPoint)
						end
						renderedPoints = {}
						pointModel.Parent = nil
					end

					function PathDisplay.renderPath()
						PathDisplay.clearRenderedPath()
						if not currentPoints or #currentPoints == 0 then
							return
						end

						local currentIdx = #currentPoints
						local lastPos = currentPoints[currentIdx]	
						local distanceBudget = 0

						renderedPoints[1] = renderPoint(lastPos, true)
						if not renderedPoints[1] then
							return
						end

						while true do
							local currentPoint = currentPoints[currentIdx]
							local nextPoint = currentPoints[currentIdx - 1]

							if currentIdx < 2 then
								break
							else

								local toNextPoint = nextPoint - currentPoint
								local distToNextPoint = toNextPoint.magnitude	

								if distanceBudget > distToNextPoint then
									distanceBudget = distanceBudget - distToNextPoint
									currentIdx = currentIdx - 1
								else
									local dirToNextPoint = toNextPoint.unit
									local pointPos = currentPoint + (dirToNextPoint * distanceBudget)
									local point = renderPoint(pointPos, false)

									if point then
										renderedPoints[#renderedPoints + 1] = point
									end

									distanceBudget = distanceBudget + PathDisplay.spacing
								end
							end
						end

						pointModel.Parent = workspace.CurrentCamera
					end

					return PathDisplay

				end
				function TouchJump()
	--[[
	// FileName: TouchJump
	// Version 1.0
	// Written by: jmargh
	// Description: Implements jump controls for touch devices. Use with Thumbstick and Thumbpad
--]]

					local Players = game:GetService("Players")
					local GuiService = game:GetService("GuiService")

					--[[ Constants ]]--
					local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

					--[[ The Module ]]--
					local BaseCharacterController = BaseCharacterController()
					local TouchJump = setmetatable({}, BaseCharacterController)
					TouchJump.__index = TouchJump

					function TouchJump.new()
						local self = setmetatable(BaseCharacterController.new(), TouchJump)

						self.parentUIFrame = nil
						self.jumpButton = nil
						self.characterAddedConn = nil
						self.humanoidStateEnabledChangedConn = nil
						self.humanoidJumpPowerConn = nil
						self.humanoidParentConn = nil
						self.externallyEnabled = false
						self.jumpPower = 0
						self.jumpStateEnabled = true
						self.isJumping = false
						self.humanoid = nil -- saved reference because property change connections are made using it

						return self
					end

					function TouchJump:EnableButton(enable)
						if enable then
							if not self.jumpButton then
								self:Create()
							end
							local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
							if humanoid and self.externallyEnabled then
								if self.externallyEnabled then
									if humanoid.JumpPower > 0 then
										self.jumpButton.Visible = true
									end
								end
							end
						else
							self.jumpButton.Visible = false
							self.isJumping = false
							self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
						end
					end

					function TouchJump:UpdateEnabled()
						if self.jumpPower > 0 and self.jumpStateEnabled then
							self:EnableButton(true)
						else
							self:EnableButton(false)
						end
					end

					function TouchJump:HumanoidChanged(prop)
						local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
						if humanoid then
							if prop == "JumpPower" then
								self.jumpPower =  humanoid.JumpPower
								self:UpdateEnabled()
							elseif prop == "Parent" then
								if not humanoid.Parent then
									self.humanoidChangeConn:Disconnect()
								end
							end
						end
					end

					function TouchJump:HumanoidStateEnabledChanged(state, isEnabled)
						if state == Enum.HumanoidStateType.Jumping then
							self.jumpStateEnabled = isEnabled
							self:UpdateEnabled()
						end
					end

					function TouchJump:CharacterAdded(char)
						if self.humanoidChangeConn then
							self.humanoidChangeConn:Disconnect()
							self.humanoidChangeConn = nil
						end

						self.humanoid = char:FindFirstChildOfClass("Humanoid")
						while not self.humanoid do
							char.ChildAdded:wait()
							self.humanoid = char:FindFirstChildOfClass("Humanoid")
						end

						self.humanoidJumpPowerConn = self.humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
							self.jumpPower =  self.humanoid.JumpPower
							self:UpdateEnabled()
						end)

						self.humanoidParentConn = self.humanoid:GetPropertyChangedSignal("Parent"):Connect(function()
							if not self.humanoid.Parent then
								self.humanoidJumpPowerConn:Disconnect()
								self.humanoidJumpPowerConn = nil
								self.humanoidParentConn:Disconnect()
								self.humanoidParentConn = nil
							end
						end)

						self.humanoidStateEnabledChangedConn = self.humanoid.StateEnabledChanged:Connect(function(state, enabled)
							self:HumanoidStateEnabledChanged(state, enabled)
						end)

						self.jumpPower = self.humanoid.JumpPower
						self.jumpStateEnabled = self.humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
						self:UpdateEnabled()
					end

					function TouchJump:SetupCharacterAddedFunction()
						self.characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(char)
							self:CharacterAdded(char)
						end)
						if Players.LocalPlayer.Character then
							self:CharacterAdded(Players.LocalPlayer.Character)
						end
					end

					function TouchJump:Enable(enable, parentFrame)
						if parentFrame then
							self.parentUIFrame = parentFrame
						end
						self.externallyEnabled = enable
						self:EnableButton(enable)
					end

					function TouchJump:Create()
						if not self.parentUIFrame then
							return
						end

						if self.jumpButton then
							self.jumpButton:Destroy()
							self.jumpButton = nil
						end

						local minAxis = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y)
						local isSmallScreen = minAxis <= 500
						local jumpButtonSize = isSmallScreen and 70 or 120

						self.jumpButton = Instance.new("ImageButton")
						self.jumpButton.Name = "JumpButton"
						self.jumpButton.Visible = false
						self.jumpButton.BackgroundTransparency = 1
						self.jumpButton.Image = TOUCH_CONTROL_SHEET
						self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
						self.jumpButton.ImageRectSize = Vector2.new(144, 144)
						self.jumpButton.Size = UDim2.new(0, jumpButtonSize, 0, jumpButtonSize)

						self.jumpButton.Position = isSmallScreen and UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize - 20) or
							UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize * 1.75)

						local touchObject: InputObject? = nil
						self.jumpButton.InputBegan:connect(function(inputObject)
							--A touch that starts elsewhere on the screen will be sent to a frame's InputBegan event
							--if it moves over the frame. So we check that this is actually a new touch (inputObject.UserInputState ~= Enum.UserInputState.Begin)
							if touchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch
								or inputObject.UserInputState ~= Enum.UserInputState.Begin then
								return
							end

							touchObject = inputObject
							self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
							self.isJumping = true
						end)

						local OnInputEnded = function()
							touchObject = nil
							self.isJumping = false
							self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
						end

						self.jumpButton.InputEnded:connect(function(inputObject: InputObject)
							if inputObject == touchObject then
								OnInputEnded()
							end
						end)

						GuiService.MenuOpened:connect(function()
							if touchObject then
								OnInputEnded()
							end
						end)

						if not self.characterAddedConn then
							self:SetupCharacterAddedFunction()
						end

						self.jumpButton.Parent = self.parentUIFrame
					end

					return TouchJump

				end
				function TouchThumbstick()
	--[[
	
	TouchThumbstick
	
--]]
					local Players = game:GetService("Players")
					local GuiService = game:GetService("GuiService")
					local UserInputService = game:GetService("UserInputService")
					--[[ Constants ]]--
					local ZERO_VECTOR3 = Vector3.new(0,0,0)
					local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/TouchControlsSheet.png"
					--[[ The Module ]]--
					local BaseCharacterController = BaseCharacterController()
					local TouchThumbstick = setmetatable({}, BaseCharacterController)
					TouchThumbstick.__index = TouchThumbstick
					function TouchThumbstick.new()
						local self = setmetatable(BaseCharacterController.new(), TouchThumbstick)

						self.isFollowStick = false

						self.thumbstickFrame = nil
						self.moveTouchObject = nil
						self.onTouchMovedConn = nil
						self.onTouchEndedConn = nil
						self.screenPos = nil
						self.stickImage = nil
						self.thumbstickSize = nil -- Float

						return self
					end
					function TouchThumbstick:Enable(enable: boolean?, uiParentFrame)
						if enable == nil then return false end			-- If nil, return false (invalid argument)
						enable = enable and true or false				-- Force anything non-nil to boolean before comparison
						if self.enabled == enable then return true end	-- If no state change, return true indicating already in requested state

						self.moveVector = ZERO_VECTOR3
						self.isJumping = false

						if enable then
							-- Enable
							if not self.thumbstickFrame then
								self:Create(uiParentFrame)
							end
							self.thumbstickFrame.Visible = true
						else 
							-- Disable
							self.thumbstickFrame.Visible = false
							self:OnInputEnded()
						end
						self.enabled = enable
					end
					function TouchThumbstick:OnInputEnded()
						self.thumbstickFrame.Position = self.screenPos
						self.stickImage.Position = UDim2.new(0, self.thumbstickFrame.Size.X.Offset/2 - self.thumbstickSize/4, 0, self.thumbstickFrame.Size.Y.Offset/2 - self.thumbstickSize/4)

						self.moveVector = ZERO_VECTOR3
						self.isJumping = false
						self.thumbstickFrame.Position = self.screenPos
						self.moveTouchObject = nil
					end
					function TouchThumbstick:Create(parentFrame)

						if self.thumbstickFrame then
							self.thumbstickFrame:Destroy()
							self.thumbstickFrame = nil
							if self.onTouchMovedConn then
								self.onTouchMovedConn:Disconnect()
								self.onTouchMovedConn = nil
							end
							if self.onTouchEndedConn then
								self.onTouchEndedConn:Disconnect()
								self.onTouchEndedConn = nil
							end
						end

						local minAxis = math.min(parentFrame.AbsoluteSize.x, parentFrame.AbsoluteSize.y)
						local isSmallScreen = minAxis <= 500
						self.thumbstickSize = isSmallScreen and 70 or 120
						self.screenPos = isSmallScreen and UDim2.new(0, (self.thumbstickSize/2) - 10, 1, -self.thumbstickSize - 20) or
							UDim2.new(0, self.thumbstickSize/2, 1, -self.thumbstickSize * 1.75)

						self.thumbstickFrame = Instance.new("Frame")
						self.thumbstickFrame.Name = "ThumbstickFrame"
						self.thumbstickFrame.Active = true
						self.thumbstickFrame.Visible = false
						self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
						self.thumbstickFrame.Position = self.screenPos
						self.thumbstickFrame.BackgroundTransparency = 1

						local outerImage = Instance.new("ImageLabel")
						outerImage.Name = "OuterImage"
						outerImage.Image = TOUCH_CONTROL_SHEET
						outerImage.ImageRectOffset = Vector2.new()
						outerImage.ImageRectSize = Vector2.new(220, 220)
						outerImage.BackgroundTransparency = 1
						outerImage.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
						outerImage.Position = UDim2.new(0, 0, 0, 0)
						outerImage.Parent = self.thumbstickFrame

						self.stickImage = Instance.new("ImageLabel")
						self.stickImage.Name = "StickImage"
						self.stickImage.Image = TOUCH_CONTROL_SHEET
						self.stickImage.ImageRectOffset = Vector2.new(220, 0)
						self.stickImage.ImageRectSize = Vector2.new(111, 111)
						self.stickImage.BackgroundTransparency = 1
						self.stickImage.Size = UDim2.new(0, self.thumbstickSize/2, 0, self.thumbstickSize/2)
						self.stickImage.Position = UDim2.new(0, self.thumbstickSize/2 - self.thumbstickSize/4, 0, self.thumbstickSize/2 - self.thumbstickSize/4)
						self.stickImage.ZIndex = 2
						self.stickImage.Parent = self.thumbstickFrame

						local centerPosition = nil
						local deadZone = 0.05

						local function DoMove(direction: Vector2)

							local currentMoveVector = direction / (self.thumbstickSize/2)

							-- Scaled Radial Dead Zone
							local inputAxisMagnitude = currentMoveVector.magnitude
							if inputAxisMagnitude < deadZone then
								currentMoveVector = Vector3.new()
							else
								currentMoveVector = currentMoveVector.unit * ((inputAxisMagnitude - deadZone) / (1 - deadZone))
								-- NOTE: Making currentMoveVector a unit vector will cause the player to instantly go max speed
								-- must check for zero length vector is using unit
								currentMoveVector = Vector3.new(currentMoveVector.x, 0, currentMoveVector.y)
							end

							self.moveVector = currentMoveVector
						end

						local function MoveStick(pos: Vector3)
							local relativePosition = Vector2.new(pos.x - centerPosition.x, pos.y - centerPosition.y)
							local length = relativePosition.magnitude
							local maxLength = self.thumbstickFrame.AbsoluteSize.x/2
							if self.isFollowStick and length > maxLength then
								local offset = relativePosition.unit * maxLength
								self.thumbstickFrame.Position = UDim2.new(
									0, pos.x - self.thumbstickFrame.AbsoluteSize.x/2 - offset.x,
									0, pos.y - self.thumbstickFrame.AbsoluteSize.y/2 - offset.y)
							else
								length = math.min(length, maxLength)
								relativePosition = relativePosition.unit * length
							end
							self.stickImage.Position = UDim2.new(0, relativePosition.x + self.stickImage.AbsoluteSize.x/2, 0, relativePosition.y + self.stickImage.AbsoluteSize.y/2)
						end

						-- input connections
						self.thumbstickFrame.InputBegan:Connect(function(inputObject: InputObject)
							--A touch that starts elsewhere on the screen will be sent to a frame's InputBegan event
							--if it moves over the frame. So we check that this is actually a new touch (inputObject.UserInputState ~= Enum.UserInputState.Begin)
							if self.moveTouchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch
								or inputObject.UserInputState ~= Enum.UserInputState.Begin then
								return
							end

							self.moveTouchObject = inputObject
							self.thumbstickFrame.Position = UDim2.new(0, inputObject.Position.x - self.thumbstickFrame.Size.X.Offset/2, 0, inputObject.Position.y - self.thumbstickFrame.Size.Y.Offset/2)
							centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x/2,
								self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y/2)
							local direction = Vector2.new(inputObject.Position.x - centerPosition.x, inputObject.Position.y - centerPosition.y)
						end)

						self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(inputObject: InputObject, isProcessed: boolean)
							if inputObject == self.moveTouchObject then
								centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x/2,
									self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y/2)
								local direction = Vector2.new(inputObject.Position.x - centerPosition.x, inputObject.Position.y - centerPosition.y)
								DoMove(direction)
								MoveStick(inputObject.Position)
							end
						end)

						self.onTouchEndedConn = UserInputService.TouchEnded:Connect(function(inputObject, isProcessed)
							if inputObject == self.moveTouchObject then
								self:OnInputEnded()
							end
						end)

						GuiService.MenuOpened:Connect(function()
							if self.moveTouchObject then
								self:OnInputEnded()
							end
						end)	

						self.thumbstickFrame.Parent = parentFrame
					end
					return TouchThumbstick
				end
				function VRNavigation()
	--[[
		VRNavigation
--]]

					local VRService = game:GetService("VRService")
					local UserInputService = game:GetService("UserInputService")
					local RunService = game:GetService("RunService")
					local Players = game:GetService("Players")
					local PathfindingService = game:GetService("PathfindingService")
					--local ContextActionService = game:GetService("ContextActionService")
					local StarterGui = game:GetService("StarterGui")

					--local MasterControl = require(script.Parent)
					local PathDisplay = nil
					local LocalPlayer = Players.LocalPlayer

					--[[ Constants ]]--
					local RECALCULATE_PATH_THRESHOLD = 4
					local NO_PATH_THRESHOLD = 12
					local MAX_PATHING_DISTANCE = 200
					local POINT_REACHED_THRESHOLD = 1
					local OFFTRACK_TIME_THRESHOLD = 2
					local THUMBSTICK_DEADZONE = 0.22

					local ZERO_VECTOR3 = Vector3.new(0,0,0)
					local XZ_VECTOR3 = Vector3.new(1,0,1)

					--[[ Utility Functions ]]--
					local function IsFinite(num: number)
						return num == num and num ~= 1/0 and num ~= -1/0
					end

					local function IsFiniteVector3(vec3)
						return IsFinite(vec3.x) and IsFinite(vec3.y) and IsFinite(vec3.z)
					end

					local movementUpdateEvent = InstanceNew("BindableEvent")
					movementUpdateEvent.Name = "MovementUpdate"
					movementUpdateEvent.Parent = script

					coroutine.wrap(function()
						PathDisplay = PathDisplay()
					end)()


					--[[ The Class ]]--
					local BaseCharacterController = BaseCharacterController()
					local VRNavigation = setmetatable({}, BaseCharacterController)
					VRNavigation.__index = VRNavigation

					function VRNavigation.new(CONTROL_ACTION_PRIORITY)
						local self = setmetatable(BaseCharacterController.new(), VRNavigation)

						self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

						self.navigationRequestedConn = nil
						self.heartbeatConn = nil

						self.currentDestination = nil
						self.currentPath = nil
						self.currentPoints = nil
						self.currentPointIdx = 0

						self.expectedTimeToNextPoint = 0
						self.timeReachedLastPoint = tick()
						self.moving = false

						self.isJumpBound = false
						self.moveLatch = false

						self.userCFrameEnabledConn = nil

						return self
					end

					function VRNavigation:SetLaserPointerMode(mode)
						pcall(function()
							StarterGui:SetCore("VRLaserPointerMode", mode)
						end)
					end

					function VRNavigation:GetLocalHumanoid()
						local character = LocalPlayer.Character
						if not character then
							return
						end

						for _, child in pairs(character:GetChildren()) do
							if child:IsA("Humanoid") then
								return child
							end
						end
						return nil
					end

					function VRNavigation:HasBothHandControllers()
						return VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
					end

					function VRNavigation:HasAnyHandControllers()
						return VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) or VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
					end

					function VRNavigation:IsMobileVR()
						return UserInputService.TouchEnabled
					end

					function VRNavigation:HasGamepad()
						return UserInputService.GamepadEnabled
					end

					function VRNavigation:ShouldUseNavigationLaser()
						--Places where we use the navigation laser:
						-- mobile VR with any number of hands tracked
						-- desktop VR with only one hand tracked
						-- desktop VR with no hands and no gamepad (i.e. with Oculus remote?)
						--using an Xbox controller with a desktop VR headset means no laser since the user has a thumbstick.
						--in the future, we should query thumbstick presence with a features API
						if self:IsMobileVR() then
							return true
						else
							if self:HasBothHandControllers() then
								return false
							end
							if not self:HasAnyHandControllers() then
								return not self:HasGamepad()
							end
							return true
						end
					end



					function VRNavigation:StartFollowingPath(newPath)
						currentPath = newPath
						currentPoints = currentPath:GetPointCoordinates()
						currentPointIdx = 1
						moving = true

						timeReachedLastPoint = tick()

						local humanoid = self:GetLocalHumanoid()
						if humanoid and humanoid.Torso and #currentPoints >= 1 then
							local dist = (currentPoints[1] - humanoid.Torso.Position).magnitude
							expectedTimeToNextPoint = dist / humanoid.WalkSpeed
						end

						movementUpdateEvent:Fire("targetPoint", self.currentDestination)
					end

					function VRNavigation:GoToPoint(point)
						currentPath = true
						currentPoints = { point }
						currentPointIdx = 1
						moving = true

						local humanoid = self:GetLocalHumanoid()
						local distance = (humanoid.Torso.Position - point).magnitude
						local estimatedTimeRemaining = distance / humanoid.WalkSpeed

						timeReachedLastPoint = tick()
						expectedTimeToNextPoint = estimatedTimeRemaining

						movementUpdateEvent:Fire("targetPoint", point)
					end

					function VRNavigation:StopFollowingPath()
						currentPath = nil
						currentPoints = nil
						currentPointIdx = 0
						moving = false
						self.moveVector = ZERO_VECTOR3
					end

					function VRNavigation:TryComputePath(startPos: Vector3, destination: Vector3)
						local numAttempts = 0
						local newPath = nil

						while not newPath and numAttempts < 5 do
							newPath = PathfindingService:ComputeSmoothPathAsync(startPos, destination, MAX_PATHING_DISTANCE)
							numAttempts = numAttempts + 1

							if newPath.Status == Enum.PathStatus.ClosestNoPath or newPath.Status == Enum.PathStatus.ClosestOutOfRange then
								newPath = nil
								break
							end

							if newPath and newPath.Status == Enum.PathStatus.FailStartNotEmpty then
								startPos = startPos + (destination - startPos).unit
								newPath = nil
							end

							if newPath and newPath.Status == Enum.PathStatus.FailFinishNotEmpty then
								destination = destination + Vector3.new(0, 1, 0)
								newPath = nil
							end
						end

						return newPath
					end

					function VRNavigation:OnNavigationRequest(destinationCFrame: CFrame, inputUserCFrame: CFrame)
						local destinationPosition = destinationCFrame.p
						local lastDestination = self.currentDestination

						if not IsFiniteVector3(destinationPosition) then
							return
						end

						self.currentDestination = destinationPosition

						local humanoid = self:GetLocalHumanoid()
						if not humanoid or not humanoid.Torso then
							return
						end

						local currentPosition = humanoid.Torso.Position
						local distanceToDestination = (self.currentDestination - currentPosition).magnitude

						if distanceToDestination < NO_PATH_THRESHOLD then
							self:GoToPoint(self.currentDestination)
							return
						end

						if not lastDestination or (self.currentDestination - lastDestination).magnitude > RECALCULATE_PATH_THRESHOLD then
							local newPath = self:TryComputePath(currentPosition, self.currentDestination)
							if newPath then
								self:StartFollowingPath(newPath)
								if PathDisplay then
									PathDisplay.setCurrentPoints(self.currentPoints)
									PathDisplay.renderPath()
								end
							else
								self:StopFollowingPath()
								if PathDisplay then
									PathDisplay.clearRenderedPath()
								end
							end
						else
							if moving then
								self.currentPoints[#currentPoints] = self.currentDestination
							else
								self:GoToPoint(self.currentDestination)
							end
						end
					end

					function VRNavigation:OnJumpAction(actionName, inputState, inputObj)
						if inputState == Enum.UserInputState.Begin then
							self.isJumping = true
						end
						return Enum.ContextActionResult.Sink
					end
					function VRNavigation:BindJumpAction(active)
						if active then
							if not self.isJumpBound then
								self.isJumpBound = true
								ContextActionService:BindActionAtPriority("VRJumpAction", (function() return self:OnJumpAction() end), false,
								self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonA)
							end
						else
							if self.isJumpBound then
								self.isJumpBound = false
								ContextActionService:UnbindAction("VRJumpAction")
							end
						end
					end

					function VRNavigation:ControlCharacterGamepad(actionName, inputState, inputObject)
						if inputObject.KeyCode ~= Enum.KeyCode.Thumbstick1 then return end

						if inputState == Enum.UserInputState.Cancel then
							self.moveVector =  ZERO_VECTOR3
							return
						end

						if inputState ~= Enum.UserInputState.End then
							self:StopFollowingPath()
							if PathDisplay then
								PathDisplay.clearRenderedPath()
							end

							if self:ShouldUseNavigationLaser() then
								self:BindJumpAction(true)
								self:SetLaserPointerMode("Hidden")
							end

							if inputObject.Position.magnitude > THUMBSTICK_DEADZONE then
								self.moveVector = Vector3.new(inputObject.Position.X, 0, -inputObject.Position.Y)
								if self.moveVector.magnitude > 0 then
									self.moveVector = self.moveVector.unit * math.min(1, inputObject.Position.magnitude)
								end

								self.moveLatch = true
							end
						else
							self.moveVector =  ZERO_VECTOR3

							if self:ShouldUseNavigationLaser() then
								self:BindJumpAction(false)
								self:SetLaserPointerMode("Navigation")
							end

							if self.moveLatch then
								self.moveLatch = false
								movementUpdateEvent:Fire("offtrack")
							end
						end
						return Enum.ContextActionResult.Sink
					end

					function VRNavigation:OnHeartbeat(dt)
						local newMoveVector = self.moveVector
						local humanoid = self:GetLocalHumanoid()
						if not humanoid or not humanoid.Torso then
							return
						end

						if self.moving and self.currentPoints then
							local currentPosition = humanoid.Torso.Position
							local goalPosition = currentPoints[1]
							local vectorToGoal = (goalPosition - currentPosition) * XZ_VECTOR3
							local moveDist = vectorToGoal.magnitude
							local moveDir = vectorToGoal / moveDist

							if moveDist < POINT_REACHED_THRESHOLD then
								local estimatedTimeRemaining = 0
								local prevPoint = currentPoints[1]
								for i, point in pairs(currentPoints) do
									if i ~= 1 then
										local dist = (point - prevPoint).magnitude
										prevPoint = point
										estimatedTimeRemaining = estimatedTimeRemaining + (dist / humanoid.WalkSpeed)
									end
								end

								table.remove(currentPoints, 1)
								currentPointIdx = currentPointIdx + 1

								if #currentPoints == 0 then
									self:StopFollowingPath()
									if PathDisplay then
										PathDisplay.clearRenderedPath()
									end
									return
								else
									if PathDisplay then
										PathDisplay.setCurrentPoints(currentPoints)
										PathDisplay.renderPath()
									end

									local newGoal = currentPoints[1]
									local distanceToGoal = (newGoal - currentPosition).magnitude
									expectedTimeToNextPoint = distanceToGoal / humanoid.WalkSpeed
									timeReachedLastPoint = tick()
								end
							else
								local ignoreTable = {
									game.Players.LocalPlayer.Character,
									workspace.CurrentCamera
								}
								local obstructRay = Ray.new(currentPosition - Vector3.new(0, 1, 0), moveDir * 3)
								local obstructPart, obstructPoint, obstructNormal = workspace:FindPartOnRayWithIgnoreList(obstructRay, ignoreTable)

								if obstructPart then
									local heightOffset = Vector3.new(0, 100, 0)
									local jumpCheckRay = Ray.new(obstructPoint + moveDir * 0.5 + heightOffset, -heightOffset)
									local jumpCheckPart, jumpCheckPoint, jumpCheckNormal = workspace:FindPartOnRayWithIgnoreList(jumpCheckRay, ignoreTable)

									local heightDifference = jumpCheckPoint.Y - currentPosition.Y
									if heightDifference < 6 and heightDifference > -2 then
										humanoid.Jump = true
									end
								end

								local timeSinceLastPoint = tick() - timeReachedLastPoint
								if timeSinceLastPoint > expectedTimeToNextPoint + OFFTRACK_TIME_THRESHOLD then
									self:StopFollowingPath()
									if PathDisplay then
										PathDisplay.clearRenderedPath()
									end

									movementUpdateEvent:Fire("offtrack")
								end

								newMoveVector = self.moveVector:Lerp(moveDir, dt * 10)
							end
						end

						if IsFiniteVector3(newMoveVector) then
							self.moveVector = newMoveVector
						end
					end


					function VRNavigation:OnUserCFrameEnabled()
						if self:ShouldUseNavigationLaser() then
							self:BindJumpAction(false)
							self:SetLaserPointerMode("Navigation")
						else
							self:BindJumpAction(true)
							self:SetLaserPointerMode("Hidden")
						end
					end

					function VRNavigation:Enable(enable)

						self.moveVector = ZERO_VECTOR3
						self.isJumping = false

						if enable then
							self.navigationRequestedConn = VRService.NavigationRequested:Connect(function(destinationCFrame, inputUserCFrame) self:OnNavigationRequest(destinationCFrame, inputUserCFrame) end)
							self.heartbeatConn = RunService.Heartbeat:Connect(function(dt) self:OnHeartbeat(dt) end)

							ContextActionService:BindAction("MoveThumbstick", (function(actionName, inputState, inputObject) return self:ControlCharacterGamepad(actionName, inputState, inputObject) end),
							false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Thumbstick1)
							ContextActionService:BindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)

							self.userCFrameEnabledConn = VRService.UserCFrameEnabled:Connect(function() self:OnUserCFrameEnabled() end)
							self:OnUserCFrameEnabled()

							VRService:SetTouchpadMode(Enum.VRTouchpad.Left, Enum.VRTouchpadMode.VirtualThumbstick)
							VRService:SetTouchpadMode(Enum.VRTouchpad.Right, Enum.VRTouchpadMode.ABXY)

							self.enabled = true
						else
							-- Disable
							self:StopFollowingPath()

							ContextActionService:UnbindAction("MoveThumbstick")
							ContextActionService:UnbindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)

							self:BindJumpAction(false)
							self:SetLaserPointerMode("Disabled")

							if self.navigationRequestedConn then
								self.navigationRequestedConn:Disconnect()
								self.navigationRequestedConn = nil
							end
							if self.heartbeatConn then
								self.heartbeatConn:Disconnect()
								self.heartbeatConn = nil
							end
							if self.userCFrameEnabledConn then
								self.userCFrameEnabledConn:Disconnect()
								self.userCFrameEnabledConn = nil
							end
							self.enabled = false
						end
					end

					return VRNavigation

				end
				function VehicleController()
	--[[
	// FileName: VehicleControl
	// Version 1.0
	// Written by: jmargh
	// Description: Implements in-game vehicle controls for all input devices

	// NOTE: This works for basic vehicles (single vehicle seat). If you use custom VehicleSeat code,
	// multiple VehicleSeats or your own implementation of a VehicleSeat this will not work.
--]]
					--local ContextActionService = game:GetService("ContextActionService")

					--[[ Constants ]]--
					-- Set this to true if you want to instead use the triggers for the throttle
					local useTriggersForThrottle = true
					-- Also set this to true if you want the thumbstick to not affect throttle, only triggers when a gamepad is conected
					local onlyTriggersForThrottle = false
					local ZERO_VECTOR3 = Vector3.new(0,0,0)

					local AUTO_PILOT_DEFAULT_MAX_STEERING_ANGLE = 35


					-- Note that VehicleController does not derive from BaseCharacterController, it is a special case
					local VehicleController = {}
					VehicleController.__index = VehicleController

					function VehicleController.new(CONTROL_ACTION_PRIORITY)
						local self = setmetatable({}, VehicleController)

						self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

						self.enabled = false
						self.vehicleSeat = nil
						self.throttle = 0
						self.steer = 0

						self.acceleration = 0
						self.decceleration = 0
						self.turningRight = 0
						self.turningLeft = 0

						self.vehicleMoveVector = ZERO_VECTOR3

						self.autoPilot = {}
						self.autoPilot.MaxSpeed = 0
						self.autoPilot.MaxSteeringAngle = 0

						return self
					end

					function VehicleController:BindContextActions()
						if useTriggersForThrottle then
							ContextActionService:BindActionAtPriority("throttleAccel", (function(actionName, inputState, inputObject)
								self:OnThrottleAccel(actionName, inputState, inputObject)
								return Enum.ContextActionResult.Pass
							end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonR2)
							ContextActionService:BindActionAtPriority("throttleDeccel", (function(actionName, inputState, inputObject)
								self:OnThrottleDeccel(actionName, inputState, inputObject)
								return Enum.ContextActionResult.Pass
							end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonL2)
						end
						ContextActionService:BindActionAtPriority("arrowSteerRight", (function(actionName, inputState, inputObject)
							self:OnSteerRight(actionName, inputState, inputObject)
							return Enum.ContextActionResult.Pass
						end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Right)
						ContextActionService:BindActionAtPriority("arrowSteerLeft", (function(actionName, inputState, inputObject)
							self:OnSteerLeft(actionName, inputState, inputObject)
							return Enum.ContextActionResult.Pass
						end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Left)
					end

					function VehicleController:Enable(enable: boolean, vehicleSeat: VehicleSeat)
						if enable == self.enabled and vehicleSeat == self.vehicleSeat then
							return
						end

						self.enabled = enable
						self.vehicleMoveVector = ZERO_VECTOR3

						if enable then
							if vehicleSeat then
								self.vehicleSeat = vehicleSeat

								self:SetupAutoPilot()
								self:BindContextActions()
							end
						else
							if useTriggersForThrottle then
								ContextActionService:UnbindAction("throttleAccel")
								ContextActionService:UnbindAction("throttleDeccel")
							end
							ContextActionService:UnbindAction("arrowSteerRight")
							ContextActionService:UnbindAction("arrowSteerLeft")
							self.vehicleSeat = nil
						end
					end

					function VehicleController:OnThrottleAccel(actionName, inputState, inputObject)
						if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
							self.acceleration = 0
						else
							self.acceleration = -1
						end
						self.throttle = self.acceleration + self.decceleration
					end

					function VehicleController:OnThrottleDeccel(actionName, inputState, inputObject)
						if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
							self.decceleration = 0
						else
							self.decceleration = 1
						end
						self.throttle = self.acceleration + self.decceleration
					end

					function VehicleController:OnSteerRight(actionName, inputState, inputObject)
						if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
							self.turningRight = 0
						else
							self.turningRight = 1
						end
						self.steer = self.turningRight + self.turningLeft
					end

					function VehicleController:OnSteerLeft(actionName, inputState, inputObject)
						if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
							self.turningLeft = 0
						else
							self.turningLeft = -1
						end
						self.steer = self.turningRight + self.turningLeft
					end

					-- Call this from a function bound to Renderstep with Input Priority
					function VehicleController:Update(moveVector: Vector3, cameraRelative: boolean, usingGamepad: boolean)
						if self.vehicleSeat then
							if cameraRelative then
								-- This is the default steering mode
								moveVector = moveVector + Vector3.new(self.steer, 0, self.throttle)
								if usingGamepad and onlyTriggersForThrottle and useTriggersForThrottle then
									self.vehicleSeat.ThrottleFloat = -self.throttle
								else
									self.vehicleSeat.ThrottleFloat = -moveVector.Z
								end
								self.vehicleSeat.SteerFloat = moveVector.X

								return moveVector, true
							else
								-- This is the path following mode
								local localMoveVector = self.vehicleSeat.Occupant.RootPart.CFrame:VectorToObjectSpace(moveVector)

								self.vehicleSeat.ThrottleFloat = self:ComputeThrottle(localMoveVector)
								self.vehicleSeat.SteerFloat = self:ComputeSteer(localMoveVector)

								return ZERO_VECTOR3, true
							end
						end
						return moveVector, false
					end

					function VehicleController:ComputeThrottle(localMoveVector)
						if localMoveVector ~= ZERO_VECTOR3 then
							local throttle = -localMoveVector.Z
							return throttle
						else
							return 0.0
						end
					end

					function VehicleController:ComputeSteer(localMoveVector)
						if localMoveVector ~= ZERO_VECTOR3 then
							local steerAngle = -math.atan2(-localMoveVector.x, -localMoveVector.z) * (180 / math.pi)
							return steerAngle / self.autoPilot.MaxSteeringAngle
						else
							return 0.0
						end
					end

					function VehicleController:SetupAutoPilot()
						-- Setup default
						self.autoPilot.MaxSpeed = self.vehicleSeat.MaxSpeed
						self.autoPilot.MaxSteeringAngle = AUTO_PILOT_DEFAULT_MAX_STEERING_ANGLE

						-- VehicleSeat should have a MaxSteeringAngle as well.
						-- Or we could look for a child "AutoPilotConfigModule" to find these values
						-- Or allow developer to set them through the API as like the CLickToMove customization API
					end

					return VehicleController

				end
				local Keyboard = Keyboard()
				local Gamepad = Gamepad()
				local DynamicThumbstick = DynamicThumbstick()

				local FFlagUserFlagEnableNewVRSystem do
					local success, result = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserFlagEnableNewVRSystem")
					end)
					FFlagUserFlagEnableNewVRSystem = success and result
				end

				local FFlagUserMakeThumbstickDynamic do
					local success, value = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserMakeThumbstickDynamic")
					end)
					FFlagUserMakeThumbstickDynamic = success and value
				end

				local TouchThumbstick = FFlagUserMakeThumbstickDynamic and DynamicThumbstick or TouchThumbstick()

				-- These controllers handle only walk/run movement, jumping is handled by the
				-- TouchJump controller if any of these are active
				local ClickToMove = ClickToMoveController()
				local TouchJump = TouchJump()

				local VehicleController = VehicleController()

				local CONTROL_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

				-- Mapping from movement mode and lastInputType enum values to control modules to avoid huge if elseif switching
				local movementEnumToModuleMap = {
					[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
					[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
					[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
					[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
					[Enum.TouchMovementMode.Thumbstick] = TouchThumbstick,
					[Enum.DevTouchMovementMode.Thumbstick] = TouchThumbstick,
					[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
					[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
					[Enum.TouchMovementMode.ClickToMove] = ClickToMove,
					[Enum.DevTouchMovementMode.ClickToMove] = ClickToMove,

					-- Current default
					[Enum.TouchMovementMode.Default] = DynamicThumbstick,

					[Enum.ComputerMovementMode.Default] = Keyboard,
					[Enum.ComputerMovementMode.KeyboardMouse] = Keyboard,
					[Enum.DevComputerMovementMode.KeyboardMouse] = Keyboard,
					[Enum.DevComputerMovementMode.Scriptable] = nil,
					[Enum.ComputerMovementMode.ClickToMove] = ClickToMove,
					[Enum.DevComputerMovementMode.ClickToMove] = ClickToMove,
				}

				-- Keyboard controller is really keyboard and mouse controller
				local computerInputTypeToModuleMap = {
					[Enum.UserInputType.Keyboard] = Keyboard,
					[Enum.UserInputType.MouseButton1] = Keyboard,
					[Enum.UserInputType.MouseButton2] = Keyboard,
					[Enum.UserInputType.MouseButton3] = Keyboard,
					[Enum.UserInputType.MouseWheel] = Keyboard,
					[Enum.UserInputType.MouseMovement] = Keyboard,
					[Enum.UserInputType.Gamepad1] = Gamepad,
					[Enum.UserInputType.Gamepad2] = Gamepad,
					[Enum.UserInputType.Gamepad3] = Gamepad,
					[Enum.UserInputType.Gamepad4] = Gamepad,
				}

				local lastInputType
				function ControlModule.new()
					local self = setmetatable({},ControlModule)

					-- The Modules above are used to construct controller instances as-needed, and this
					-- table is a map from Module to the instance created from it
					self.controllers = {}

					self.activeControlModule = nil	-- Used to prevent unnecessarily expensive checks on each input event
					self.activeController = nil
					self.touchJumpController = nil
					--self.moveFunction = function(...)
					--	pcall(function(...)
					--		--Players.LocalPlayer.Move(...)
					--	end, ...)
					--end
					self.humanoid = nil
					self.lastInputType = Enum.UserInputType.None

					-- For Roblox self.vehicleController
					self.humanoidSeatedConn = nil
					self.vehicleController = nil

					self.touchControlFrame = nil

					self.vehicleController = VehicleController.new(CONTROL_ACTION_PRIORITY)

					coroutine.wrap(function()
						Players.LocalPlayer.CharacterAdded:Connect(function(char) self:OnCharacterAdded(char) end)
						Players.LocalPlayer.CharacterRemoving:Connect(function(char) self:OnCharacterRemoving(char) end)
						if Players.LocalPlayer.Character then
							self:OnCharacterAdded(Players.LocalPlayer.Character)
						end
					end)()


					RunService:BindToRenderStep("ControlScriptRenderstep", Enum.RenderPriority.Input.Value, function(dt)
						self:OnRenderStepped(dt)
					end)

					UserInputService.LastInputTypeChanged:Connect(function(newLastInputType)
						self:OnLastInputTypeChanged(newLastInputType)
					end)


					UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
						self:OnTouchMovementModeChange()
					end)
					Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
						self:OnTouchMovementModeChange()
					end)

					UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
						self:OnComputerMovementModeChange()
					end)
					Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
						self:OnComputerMovementModeChange()
					end)

					--[[ Touch Device UI ]]--
					self.playerGui = nil
					self.touchGui = nil
					self.playerGuiAddedConn = nil

					UserInputService:GetPropertyChangedSignal("ModalEnabled"):Connect(function()
						self:UpdateTouchGuiVisibility()
					end)

					if UserInputService.TouchEnabled then
						self.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
						if self.playerGui then
							self:CreateTouchGuiContainer()
							self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
						else
							self.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(child)
								if child:IsA("PlayerGui") then
									self.playerGui = child
									self:CreateTouchGuiContainer()
									self.playerGuiAddedConn:Disconnect()
									self.playerGuiAddedConn = nil
									self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
								end
							end)
						end
					else
						self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
					end

					return self
				end

				-- Convenience function so that calling code does not have to first get the activeController
				-- and then call GetMoveVector on it. When there is no active controller, this function returns the 
				-- zero vector
				function ControlModule:GetMoveVector(): Vector3
					if self.activeController then
						return self.activeController:GetMoveVector()
					end
					return Vector3.new(0,0,0)
				end

				function ControlModule:GetActiveController()
					return self.activeController
				end

				function ControlModule:EnableActiveControlModule()
					if self.activeControlModule == ClickToMove then
						-- For ClickToMove, when it is the player's choice, we also enable the full keyboard controls.
						-- When the developer is forcing click to move, the most keyboard controls (WASD) are not available, only jump.
						self.activeController:Enable(
							true,
							Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice,
							self.touchJumpController
						)
					elseif self.touchControlFrame then
						self.activeController:Enable(true, self.touchControlFrame)
					else
						self.activeController:Enable(true)
					end
				end

				function ControlModule:Enable(enable: boolean?)
					if not self.activeController then
						return
					end

					if enable == nil then
						enable = true
					end
					if enable then
						self:EnableActiveControlModule()
					else
						self:Disable()
					end
				end

				-- For those who prefer distinct functions
				function ControlModule:Disable()
					if self.activeController then
						self.activeController:Enable(false)

						if self.moveFunction then
							--self.moveFunction(Players.LocalPlayer, Vector3.new(0,0,0), true)
						end
					end
				end


				-- Returns module (possibly nil) and success code to differentiate returning nil due to error vs Scriptable
				function ControlModule:SelectComputerMovementModule(): ({}?, boolean)
					if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
						return nil, false
					end

					local computerModule
					local DevMovementMode = Players.LocalPlayer.DevComputerMovementMode

					if DevMovementMode == Enum.DevComputerMovementMode.UserChoice then
						computerModule = computerInputTypeToModuleMap[lastInputType]
						if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and computerModule == Keyboard then
							-- User has ClickToMove set in Settings, prefer ClickToMove controller for keyboard and mouse lastInputTypes
							computerModule = ClickToMove
						end
					else
						-- Developer has selected a mode that must be used.
						computerModule = movementEnumToModuleMap[DevMovementMode]

						-- computerModule is expected to be nil here only when developer has selected Scriptable
						if (not computerModule) and DevMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
							warn("No character control module is associated with DevComputerMovementMode ", DevMovementMode)
						end
					end

					if computerModule then
						return computerModule, true
					elseif DevMovementMode == Enum.DevComputerMovementMode.Scriptable then
						-- Special case where nil is returned and we actually want to set self.activeController to nil for Scriptable
						return nil, true
					else
						-- This case is for when computerModule is nil because of an error and no suitable control module could
						-- be found.
						return nil, false
					end
				end

				-- Choose current Touch control module based on settings (user, dev)
				-- Returns module (possibly nil) and success code to differentiate returning nil due to error vs Scriptable
				function ControlModule:SelectTouchModule(): ({}?, boolean)
					if not UserInputService.TouchEnabled then
						return nil, false
					end
					local touchModule
					local DevMovementMode = Players.LocalPlayer.DevTouchMovementMode
					if DevMovementMode == Enum.DevTouchMovementMode.UserChoice then
						touchModule = movementEnumToModuleMap[UserGameSettings.TouchMovementMode]
					elseif DevMovementMode == Enum.DevTouchMovementMode.Scriptable then
						return nil, true
					else
						touchModule = movementEnumToModuleMap[DevMovementMode]
					end
					return touchModule, true
				end

				local function calculateRawMoveVector(humanoid: Humanoid, cameraRelativeMoveVector: Vector3): Vector3
					local camera = Workspace.CurrentCamera
					if not camera then
						return cameraRelativeMoveVector
					end

					if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
						return camera.CFrame:VectorToWorldSpace(cameraRelativeMoveVector)
					end

					local cameraCFrame = camera.CFrame

					if VRService.VREnabled and FFlagUserFlagEnableNewVRSystem and humanoid.RootPart then
						-- movement relative to VR frustum
						local cameraDelta = humanoid.RootPart.CFrame.Position - cameraCFrame.Position
						if cameraDelta.Magnitude < 3 then -- "nearly" first person
							local vrFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
							cameraCFrame = cameraCFrame * vrFrame
						end
					end

					local c, s
					local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = cameraCFrame:GetComponents()
					if R12 < 1 and R12 > -1 then
						-- X and Z components from back vector.
						c = R22
						s = R02
					else
						-- In this case the camera is looking straight up or straight down.
						-- Use X components from right and up vectors.
						c = R00
						s = -R01*math.sign(R12)
					end
					local norm = math.sqrt(c*c + s*s)
					return Vector3.new(
						(c*cameraRelativeMoveVector.x + s*cameraRelativeMoveVector.z)/norm,
						0,
						(c*cameraRelativeMoveVector.z - s*cameraRelativeMoveVector.x)/norm
					)
				end

				function ControlModule:OnRenderStepped(dt)
					if self.activeController and self.activeController.enabled and self.humanoid then
						-- Give the controller a chance to adjust its state
						self.activeController:OnRenderStepped(dt)

						-- Now retrieve info from the controller
						local moveVector = self.activeController:GetMoveVector()
						local cameraRelative = self.activeController:IsMoveVectorCameraRelative()

						local clickToMoveController = self:GetClickToMoveController()
						if self.activeController ~= clickToMoveController then
							if moveVector.magnitude > 0 then
								-- Clean up any developer started MoveTo path
								clickToMoveController:CleanupPath()
							else
								-- Get move vector for developer started MoveTo
								clickToMoveController:OnRenderStepped(dt)
								moveVector = clickToMoveController:GetMoveVector()
								cameraRelative = clickToMoveController:IsMoveVectorCameraRelative()
							end
						end

						-- Are we driving a vehicle ?
						local vehicleConsumedInput = false
						if self.vehicleController then
							moveVector, vehicleConsumedInput = self.vehicleController:Update(moveVector, cameraRelative, self.activeControlModule==Gamepad)
						end

						-- If not, move the player
						-- Verification of vehicleConsumedInput is commented out to preserve legacy behavior,
						-- in case some game relies on Humanoid.MoveDirection still being set while in a VehicleSeat
						--if not vehicleConsumedInput then
						if cameraRelative then
							moveVector = calculateRawMoveVector(self.humanoid, moveVector)
						end
						--self.moveFunction(Players.LocalPlayer, moveVector, false)
						--end

						-- And make them jump if needed
						self.humanoid.Jump = self.activeController:GetIsJumping() or (self.touchJumpController and self.touchJumpController:GetIsJumping())
					end
				end

				function ControlModule:OnHumanoidSeated(active: boolean, currentSeatPart: BasePart)
					if active then
						if currentSeatPart and currentSeatPart:IsA("VehicleSeat") then
							if not self.vehicleController then
								self.vehicleController = self.vehicleController.new(CONTROL_ACTION_PRIORITY)
							end
							self.vehicleController:Enable(true, currentSeatPart)
						end
					else
						if self.vehicleController then
							self.vehicleController:Enable(false, currentSeatPart)
						end
					end
				end

				function ControlModule:OnCharacterAdded(char)
					self.humanoid = char:FindFirstChildOfClass("Humanoid")
					while not self.humanoid do
						char.ChildAdded:wait()
						self.humanoid = char:FindFirstChildOfClass("Humanoid")
					end

					self:UpdateTouchGuiVisibility()

					if self.humanoidSeatedConn then
						self.humanoidSeatedConn:Disconnect()
						self.humanoidSeatedConn = nil
					end
					self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(active, currentSeatPart)
						self:OnHumanoidSeated(active, currentSeatPart)
					end)
				end

				function ControlModule:OnCharacterRemoving(char)
					self.humanoid = nil

					self:UpdateTouchGuiVisibility()
				end

				function ControlModule:UpdateTouchGuiVisibility()
					if self.touchGui then
						local doShow = self.humanoid and not UserInputService.ModalEnabled
						self.touchGui.Enabled = not not doShow -- convert to bool
					end
				end

				-- Helper function to lazily instantiate a controller if it does not yet exist,
				-- disable the active controller if it is different from the on being switched to,
				-- and then enable the requested controller. The argument to this function must be
				-- a reference to one of the control modules, i.e. Keyboard, Gamepad, etc.
				function ControlModule:SwitchToController(controlModule)
					if not controlModule then
						if self.activeController then
							self.activeController:Enable(false)
						end
						self.activeController = nil
						self.activeControlModule = nil
					else
						if not self.controllers[controlModule] then
							self.controllers[controlModule] = controlModule.new(CONTROL_ACTION_PRIORITY)
						end

						if self.activeController ~= self.controllers[controlModule] then
							if self.activeController then
								self.activeController:Enable(false)
							end
							self.activeController = self.controllers[controlModule]
							self.activeControlModule = controlModule -- Only used to check if controller switch is necessary

							if self.touchControlFrame and (self.activeControlModule == ClickToMove
								or self.activeControlModule == TouchThumbstick
								or self.activeControlModule == DynamicThumbstick) then
								if not self.controllers[TouchJump] then
									self.controllers[TouchJump] = TouchJump.new()
								end
								self.touchJumpController = self.controllers[TouchJump]
								self.touchJumpController:Enable(true, self.touchControlFrame)
							else
								if self.touchJumpController then
									self.touchJumpController:Enable(false)
								end
							end

							self:EnableActiveControlModule()
						end
					end
				end

				function ControlModule:OnLastInputTypeChanged(newLastInputType)
					if lastInputType == newLastInputType then
						warn("LastInputType Change listener called with current type.")
					end
					lastInputType = newLastInputType

					if lastInputType == Enum.UserInputType.Touch then
						-- TODO: Check if touch module already active
						local touchModule, success = self:SelectTouchModule()
						if success then
							while not self.touchControlFrame do
								wait()
							end
							self:SwitchToController(touchModule)
						end
					elseif computerInputTypeToModuleMap[lastInputType] ~= nil then
						local computerModule = self:SelectComputerMovementModule()
						if computerModule then
							self:SwitchToController(computerModule)
						end
					end

					self:UpdateTouchGuiVisibility()
				end

				-- Called when any relevant values of GameSettings or LocalPlayer change, forcing re-evalulation of
				-- current control scheme
				function ControlModule:OnComputerMovementModeChange()
					local controlModule, success =  self:SelectComputerMovementModule()
					if success then
						self:SwitchToController(controlModule)
					end
				end

				function ControlModule:OnTouchMovementModeChange()
					local touchModule, success = self:SelectTouchModule()
					if success then
						while not self.touchControlFrame do
							wait()
						end
						self:SwitchToController(touchModule)
					end
				end
				function ControlModule:CreateTouchGuiContainer()
					if self.touchGui then self.touchGui:Destroy() end

					-- Container for all touch device guis
					self.touchGui = Instance.new("ScreenGui")
					self.touchGui.Name = "TouchGui"
					self.touchGui.ResetOnSpawn = false
					self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					self:UpdateTouchGuiVisibility()

					self.touchControlFrame = Instance.new("Frame")
					self.touchControlFrame.Name = "TouchControlFrame"
					self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
					self.touchControlFrame.BackgroundTransparency = 1
					self.touchControlFrame.Parent = self.touchGui

					self.touchGui.Parent = self.playerGui
				end

				function ControlModule:GetClickToMoveController()
					if not self.controllers[ClickToMove] then
						self.controllers[ClickToMove] = ClickToMove.new(CONTROL_ACTION_PRIORITY)
					end
					return self.controllers[ClickToMove]
				end

				return ControlModule.new()

			end
		end
		local Speed = 9
		local ClassicCamera
		local Camera = game:GetService("Workspace").CurrentCamera
		local CameraCFrame = Camera.CFrame
		local CameraFocus = Camera.Focus
		do
			local function CameraInput()
				--local ContextActionService = game:GetService("ContextActionService")
				local UserInputService = game:GetService("UserInputService")
				local Players = game:GetService("Players")
				local RunService = game:GetService("RunService")
				local UserGameSettings = UserSettings():GetService("UserGameSettings")
				local VRService = game:GetService("VRService")
				local StarterGui = game:GetService("StarterGui")

				local player = Players.LocalPlayer

				local CAMERA_INPUT_PRIORITY = Enum.ContextActionPriority.Default.Value
				local MB_TAP_LENGTH = 0.3 -- (s) length of time for a short mouse button tap to be registered

				local ROTATION_SPEED_KEYS = math.rad(120) -- (rad/s)
				local ROTATION_SPEED_MOUSE = Vector2.new(1, 0.77)*math.rad(0.5) -- (rad/s)
				local ROTATION_SPEED_POINTERACTION = Vector2.new(1, 0.77)*math.rad(7) -- (rad/s)
				local ROTATION_SPEED_TOUCH = Vector2.new(1, 0.66)*math.rad(1) -- (rad/s)
				local ROTATION_SPEED_GAMEPAD = Vector2.new(1, 0.77)*math.rad(4) -- (rad/s)

				local ZOOM_SPEED_MOUSE = 1 -- (scaled studs/wheel click)
				local ZOOM_SPEED_KEYS = 0.1 -- (studs/s)
				local ZOOM_SPEED_TOUCH = 0.04 -- (scaled studs/DIP %)

				local MIN_TOUCH_SENSITIVITY_FRACTION = 0.25 -- 25% sensitivity at 90°

				local FFlagUserFlagEnableNewVRSystem do
					local success, result = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserFlagEnableNewVRSystem")
					end)
					FFlagUserFlagEnableNewVRSystem = success and result
				end

				-- right mouse button up & down events
				local rmbDown, rmbUp do
					local rmbDownBindable = InstanceNew("BindableEvent")
					local rmbUpBindable = InstanceNew("BindableEvent")

					rmbDown = rmbDownBindable.Event
					rmbUp = rmbUpBindable.Event

					UserInputService.InputBegan:Connect(function(input, gpe)
						if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
							rmbDownBindable:Fire()
						end
					end)

					UserInputService.InputEnded:Connect(function(input, gpe)
						if input.UserInputType == Enum.UserInputType.MouseButton2 then
							rmbUpBindable:Fire()
						end
					end)
				end

				local thumbstickCurve do
					local K_CURVATURE = 2 -- amount of upwards curvature (0 is flat)
					local K_DEADZONE = 0.1 -- deadzone

					function thumbstickCurve(x)
						-- remove sign, apply linear deadzone
						local fDeadzone = (math.abs(x) - K_DEADZONE)/(1 - K_DEADZONE)

						-- apply exponential curve and scale to fit in [0, 1]
						local fCurve = (math.exp(K_CURVATURE*fDeadzone) - 1)/(math.exp(K_CURVATURE) - 1)

						-- reapply sign and clamp
						return math.sign(x)*math.clamp(fCurve, 0, 1)
					end
				end

				-- Adjust the touch sensitivity so that sensitivity is reduced when swiping up
				-- or down, but stays the same when swiping towards the middle of the screen
				local function adjustTouchPitchSensitivity(delta: Vector2): Vector2
					--local camera = workspace.CurrentCamera

					--if not camera then
					--	return delta
					--end

					-- get the camera pitch in world space
					local pitch = CameraCFrame:ToEulerAnglesYXZ()

					if delta.Y*pitch >= 0 then
						-- do not reduce sensitivity when pitching towards the horizon
						return delta
					end

					-- set up a line to fit:
					-- 1 = f(0)
					-- 0 = f(±pi/2)
					local curveY = 1 - (2*math.abs(pitch)/math.pi)^0.75

					-- remap curveY from [0, 1] -> [MIN_TOUCH_SENSITIVITY_FRACTION, 1]
					local sensitivity = curveY*(1 - MIN_TOUCH_SENSITIVITY_FRACTION) + MIN_TOUCH_SENSITIVITY_FRACTION

					return Vector2.new(1, sensitivity)*delta
				end

				local function isInDynamicThumbstickArea(pos: Vector3): boolean
					local playerGui = player:FindFirstChildOfClass("PlayerGui")
					local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
					local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
					local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

					if not thumbstickFrame then
						return false
					end

					if not touchGui.Enabled then
						return false
					end

					local posTopLeft = thumbstickFrame.AbsolutePosition
					local posBottomRight = posTopLeft + thumbstickFrame.AbsoluteSize

					return
						pos.X >= posTopLeft.X and
						pos.Y >= posTopLeft.Y and
						pos.X <= posBottomRight.X and
						pos.Y <= posBottomRight.Y
				end

				local worldDt = 1/60
				RunService.Stepped:Connect(function(_, _worldDt)
					worldDt = _worldDt
				end)

				local CameraInput = {}

				do
					local connectionList = {}
					local panInputCount = 0

					local function incPanInputCount()
						panInputCount = math.max(0, panInputCount + 1)
					end

					local function decPanInputCount()
						panInputCount = math.max(0, panInputCount - 1)
					end

					local touchPitchSensitivity = 1
					local gamepadState = {
						Thumbstick2 = Vector2.new(),
					}
					local keyboardState = {
						Left = 0,
						Right = 0,
						I = 0,
						O = 0
					}
					local mouseState = {
						Movement = Vector2.new(),
						Wheel = 0, -- PointerAction
						Pan = Vector2.new(), -- PointerAction
						Pinch = 0, -- PointerAction
					}
					local touchState = {
						Move = Vector2.new(),
						Pinch = 0,
					}

					local gamepadZoomPressBindable = InstanceNew("BindableEvent")
					CameraInput.gamepadZoomPress = gamepadZoomPressBindable.Event

					local gamepadResetBindable = VRService.VREnabled and FFlagUserFlagEnableNewVRSystem and InstanceNew("BindableEvent") or nil
					if VRService.VREnabled and FFlagUserFlagEnableNewVRSystem then
						CameraInput.gamepadReset = gamepadResetBindable.Event
					end

					function CameraInput.getRotationActivated(): boolean
						return panInputCount > 0 or gamepadState.Thumbstick2.Magnitude > 0
					end

					function CameraInput.getRotation(disableKeyboardRotation: boolean?): Vector2
						local inversionVector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())

						-- keyboard input is non-coalesced, so must account for time delta
						local kKeyboard = Vector2.new(keyboardState.Right - keyboardState.Left, 0)*worldDt
						local kGamepad = gamepadState.Thumbstick2
						local kMouse = mouseState.Movement
						local kPointerAction = mouseState.Pan
						local kTouch = adjustTouchPitchSensitivity(touchState.Move)

						if disableKeyboardRotation then
							kKeyboard = Vector2.new()
						end

						local result =
							kKeyboard*ROTATION_SPEED_KEYS +
							kGamepad*ROTATION_SPEED_GAMEPAD +
							kMouse*ROTATION_SPEED_MOUSE +
							kPointerAction*ROTATION_SPEED_POINTERACTION +
							kTouch*ROTATION_SPEED_TOUCH

						return result*inversionVector
					end

					function CameraInput.getZoomDelta(): number
						local kKeyboard = keyboardState.O - keyboardState.I
						local kMouse = -mouseState.Wheel + mouseState.Pinch
						local kTouch = -touchState.Pinch
						return kKeyboard*ZOOM_SPEED_KEYS + kMouse*ZOOM_SPEED_MOUSE + kTouch*ZOOM_SPEED_TOUCH
					end

					do
						local function thumbstick(action, state, input)
							local position = input.Position
							gamepadState[input.KeyCode.Name] = Vector2.new(thumbstickCurve(position.X), -thumbstickCurve(position.Y))
						end

						local function mouseMovement(input)
							local delta = input.Delta
							mouseState.Movement = Vector2.new(delta.X, delta.Y)
						end

						local function mouseWheel(action, state, input)
							mouseState.Wheel = input.Position.Z
							return Enum.ContextActionResult.Pass
						end

						local function keypress(action, state, input)
							keyboardState[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
						end

						local function gamepadZoomPress(action, state, input)
							if state == Enum.UserInputState.Begin then
								gamepadZoomPressBindable:Fire()
							end
						end

						local function gamepadReset(action, state, input)
							if state == Enum.UserInputState.Begin then
								gamepadResetBindable:Fire()
							end
						end

						local function resetInputDevices()
							for _, device in pairs({
								gamepadState,
								keyboardState,
								mouseState,
								touchState,
								}) do
								for k, v in pairs(device) do
									if type(v) == "boolean" then
										device[k] = false
									else
										device[k] *= 0 -- Mul by zero to preserve vector types
									end
								end
							end
						end

						local touchBegan, touchChanged, touchEnded, resetTouchState do
							-- Use TouchPan & TouchPinch when they work in the Studio emulator

							local touches: {[InputObject]: boolean?} = {} -- {[InputObject] = sunk}
							local dynamicThumbstickInput: InputObject? -- Special-cased 
							local lastPinchDiameter: number?

							function touchBegan(input: InputObject, sunk: boolean)
								assert(input.UserInputType == Enum.UserInputType.Touch)
								assert(input.UserInputState == Enum.UserInputState.Begin)

								if dynamicThumbstickInput == nil and isInDynamicThumbstickArea(input.Position) and not sunk then
									-- any finger down starting in the dynamic thumbstick area should always be
									-- ignored for camera purposes. these must be handled specially from all other
									-- inputs, as the DT does not sink inputs by itself
									dynamicThumbstickInput = input
									return
								end

								if not sunk then
									incPanInputCount()
								end

								-- register the finger
								touches[input] = sunk
							end

							function touchEnded(input: InputObject, sunk: boolean)
								assert(input.UserInputType == Enum.UserInputType.Touch)
								assert(input.UserInputState == Enum.UserInputState.End)

								-- reset the DT input
								if input == dynamicThumbstickInput then
									dynamicThumbstickInput = nil
								end

								-- reset pinch state if one unsunk finger lifts
								if touches[input] == false then
									lastPinchDiameter = nil
									decPanInputCount()
								end

								-- unregister input
								touches[input] = nil
							end

							function touchChanged(input, sunk)
								assert(input.UserInputType == Enum.UserInputType.Touch)
								assert(input.UserInputState == Enum.UserInputState.Change)

								-- ignore movement from the DT finger
								if input == dynamicThumbstickInput then
									return
								end

								-- fixup unknown touches
								if touches[input] == nil then
									touches[input] = sunk
								end

								-- collect unsunk touches
								local unsunkTouches = {}
								for touch, sunk in pairs(touches) do
									if not sunk then
										table.insert(unsunkTouches, touch)
									end
								end

								-- 1 finger: pan
								if #unsunkTouches == 1 then
									if touches[input] == false then
										local delta = input.Delta
										touchState.Move += Vector2.new(delta.X, delta.Y) -- total touch pan movement (reset at end of frame)
									end
								end

								-- 2 fingers: pinch
								if #unsunkTouches == 2 then
									local pinchDiameter = (unsunkTouches[1].Position - unsunkTouches[2].Position).Magnitude

									if lastPinchDiameter then
										touchState.Pinch += pinchDiameter - lastPinchDiameter
									end

									lastPinchDiameter = pinchDiameter
								else
									lastPinchDiameter = nil
								end
							end

							function resetTouchState()
								touches = {}
								dynamicThumbstickInput = nil
								lastPinchDiameter = nil
							end
						end

						local function pointerAction(wheel, pan, pinch, gpe)
							if not gpe then
								mouseState.Wheel = wheel
								mouseState.Pan = pan
								mouseState.Pinch = -pinch
							end
						end

						local function inputBegan(input, sunk)
							if input.UserInputType == Enum.UserInputType.Touch then
								touchBegan(input, sunk)

							elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not sunk then
								incPanInputCount()
							end
						end

						local function inputChanged(input, sunk)
							if input.UserInputType == Enum.UserInputType.Touch then
								touchChanged(input, sunk)

							elseif input.UserInputType == Enum.UserInputType.MouseMovement then
								mouseMovement(input)
							end
						end

						local function inputEnded(input, sunk)
							if input.UserInputType == Enum.UserInputType.Touch then
								touchEnded(input, sunk)

							elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
								decPanInputCount()
							end
						end

						local inputEnabled = false

						function CameraInput.setInputEnabled(_inputEnabled)
							if inputEnabled == _inputEnabled then
								return
							end
							inputEnabled = _inputEnabled

							resetInputDevices()
							resetTouchState()

							if inputEnabled then -- enable
								ContextActionService:BindActionAtPriority(
									"RbxCameraThumbstick",
									thumbstick,
									false,
									CAMERA_INPUT_PRIORITY,
									Enum.KeyCode.Thumbstick2
								)

								ContextActionService:BindActionAtPriority(
									"RbxCameraKeypress",
									keypress,
									false,
									CAMERA_INPUT_PRIORITY,
									Enum.KeyCode.Left,
									Enum.KeyCode.Right,
									Enum.KeyCode.I,
									Enum.KeyCode.O
								)

								if VRService.VREnabled and FFlagUserFlagEnableNewVRSystem then
									ContextActionService:BindAction(
										"RbxCameraGamepadReset",
										gamepadReset,
										false,
										Enum.KeyCode.ButtonL3
									)
								end

								ContextActionService:BindAction(
									"RbxCameraGamepadZoom",
									gamepadZoomPress,
									false,
									Enum.KeyCode.ButtonR3
								)

								table.insert(connectionList, UserInputService.InputBegan:Connect(inputBegan))
								table.insert(connectionList, UserInputService.InputChanged:Connect(inputChanged))
								table.insert(connectionList, UserInputService.InputEnded:Connect(inputEnded))
								table.insert(connectionList, UserInputService.PointerAction:Connect(pointerAction))

							else -- disable
								ContextActionService:UnbindAction("RbxCameraThumbstick")
								ContextActionService:UnbindAction("RbxCameraMouseMove")
								ContextActionService:UnbindAction("RbxCameraMouseWheel")
								ContextActionService:UnbindAction("RbxCameraKeypress")

								if FFlagUserFlagEnableNewVRSystem then
									ContextActionService:UnbindAction("RbxCameraGamepadZoom")
									if VRService.VREnabled then
										ContextActionService:UnbindAction("RbxCameraGamepadReset")
									end 
								end

								for _, conn in pairs(connectionList) do
									conn:Disconnect()
								end
								connectionList = {}
							end
						end

						function CameraInput.getInputEnabled()
							return inputEnabled
						end

						function CameraInput.resetInputForFrameEnd()
							mouseState.Movement = Vector2.new()
							touchState.Move = Vector2.new()
							touchState.Pinch = 0

							mouseState.Wheel = 0 -- PointerAction
							mouseState.Pan = Vector2.new() -- PointerAction
							mouseState.Pinch = 0 -- PointerAction
						end

						UserInputService.WindowFocused:Connect(resetInputDevices)
						UserInputService.WindowFocusReleased:Connect(resetInputDevices)
					end
				end

				-- Toggle pan
				do
					local holdPan = false
					local togglePan = false
					local lastRmbDown = 0 -- tick() timestamp of the last right mouse button down event

					function CameraInput.getHoldPan(): boolean
						return holdPan
					end

					function CameraInput.getTogglePan(): boolean
						return togglePan
					end

					function CameraInput.getPanning(): boolean
						return togglePan or holdPan
					end

					function CameraInput.setTogglePan(value: boolean)
						togglePan = value
					end

					local cameraToggleInputEnabled = false
					local rmbDownConnection
					local rmbUpConnection

					function CameraInput.enableCameraToggleInput()
						if cameraToggleInputEnabled then
							return
						end
						cameraToggleInputEnabled = true

						holdPan = false
						togglePan = false

						if rmbDownConnection then
							rmbDownConnection:Disconnect()
						end

						if rmbUpConnection then
							rmbUpConnection:Disconnect()
						end

						rmbDownConnection = rmbDown:Connect(function()
							holdPan = true
							lastRmbDown = tick()
						end)

						rmbUpConnection = rmbUp:Connect(function()
							holdPan = false
							if tick() - lastRmbDown < MB_TAP_LENGTH and (togglePan or UserInputService:GetMouseDelta().Magnitude < 2) then
								togglePan = not togglePan
							end
						end)
					end

					function CameraInput.disableCameraToggleInput()
						if not cameraToggleInputEnabled then
							return
						end
						cameraToggleInputEnabled = false

						if rmbDownConnection then
							rmbDownConnection:Disconnect()
							rmbDownConnection = nil
						end

						if rmbUpConnection then
							rmbUpConnection:Disconnect()
							rmbUpConnection = nil
						end
					end
				end

				return CameraInput
			end
			local function CameraUtils()
				--[[
	CameraUtils - Math utility functions shared by multiple camera scripts
	2018 Camera Update - AllYourBlox
--]]

				local CameraUtils = {}

				local function round(num: number)
					return math.floor(num + 0.5)
				end

				-- Critically damped spring class for fluid motion effects
				local Spring = {} do
					Spring.__index = Spring

					-- Initialize to a given undamped frequency and default position
					function Spring.new(freq, pos)
						return setmetatable({
							freq = freq,
							goal = pos,
							pos = pos,
							vel = 0,
						}, Spring)
					end

					-- Advance the spring simulation by `dt` seconds
					function Spring:step(dt: number)
						local f: number = self.freq*2*math.pi
						local g: Vector3 = self.goal
						local p0: Vector3 = self.pos
						local v0: Vector3 = self.vel

						local offset = p0 - g
						local decay = math.exp(-f*dt)

						local p1 = (offset*(1 + f*dt) + v0*dt)*decay + g
						local v1 = (v0*(1 - f*dt) - offset*(f*f*dt))*decay

						self.pos = p1
						self.vel = v1

						return p1
					end
				end

				CameraUtils.Spring = Spring

				-- map a value from one range to another
				function CameraUtils.map(x: number, inMin: number, inMax: number, outMin: number, outMax: number): number
					return (x - inMin)*(outMax - outMin)/(inMax - inMin) + outMin
				end

				-- maps a value from one range to another, clamping to the output range. order does not matter
				function CameraUtils.mapClamp(x: number, inMin: number, inMax: number, outMin: number, outMax: number): number
					return math.clamp(
						(x - inMin)*(outMax - outMin)/(inMax - inMin) + outMin,
						math.min(outMin, outMax),
						math.max(outMin, outMax)
					)
				end

				-- Ritter's loose bounding sphere algorithm
				function CameraUtils.getLooseBoundingSphere(parts: {BasePart})
					local points = table.create(#parts)
					for idx, part in pairs(parts) do
						points[idx] = part.Position
					end

					-- pick an arbitrary starting point
					local x = points[1]

					-- get y, the point furthest from x
					local y = x
					local yDist = 0

					for _, p in ipairs(points) do
						local pDist = (p - x).Magnitude

						if pDist > yDist then
							y = p
							yDist = pDist
						end
					end

					-- get z, the point furthest from y
					local z = y
					local zDist = 0

					for _, p in ipairs(points) do
						local pDist = (p - y).Magnitude

						if pDist > zDist then
							z = p
							zDist = pDist
						end
					end

					-- use (y, z) as the initial bounding sphere
					local sc = (y + z)*0.5
					local sr = (y - z).Magnitude*0.5

					-- expand sphere to fit any outlying points
					for _, p in ipairs(points) do
						local pDist = (p - sc).Magnitude

						if pDist > sr then
							-- shift to midpoint
							sc = sc + (pDist - sr)*0.5*(p - sc).Unit

							-- expand
							sr = (pDist + sr)*0.5
						end
					end

					return sc, sr
				end

				-- canonicalize an angle to +-180 degrees
				function CameraUtils.sanitizeAngle(a: number): number
					return (a + math.pi)%(2*math.pi) - math.pi
				end

				-- From TransparencyController
				function CameraUtils.Round(num: number, places: number): number
					local decimalPivot = 10^places
					return math.floor(num * decimalPivot + 0.5) / decimalPivot
				end

				function CameraUtils.IsFinite(val: number): boolean
					return val == val and val ~= math.huge and val ~= -math.huge
				end

				function CameraUtils.IsFiniteVector3(vec3: Vector3): boolean
					return CameraUtils.IsFinite(vec3.X) and CameraUtils.IsFinite(vec3.Y) and CameraUtils.IsFinite(vec3.Z)
				end

				-- Legacy implementation renamed
				function CameraUtils.GetAngleBetweenXZVectors(v1: Vector3, v2: Vector3): number
					return math.atan2(v2.X*v1.Z-v2.Z*v1.X, v2.X*v1.X+v2.Z*v1.Z)
				end

				function CameraUtils.RotateVectorByAngleAndRound(camLook: Vector3, rotateAngle: number, roundAmount: number): number
					if camLook.Magnitude > 0 then
						camLook = camLook.unit
						local currAngle = math.atan2(camLook.z, camLook.x)
						local newAngle = round((math.atan2(camLook.z, camLook.x) + rotateAngle) / roundAmount) * roundAmount
						return newAngle - currAngle
					end
					return 0
				end

				-- K is a tunable parameter that changes the shape of the S-curve
				-- the larger K is the more straight/linear the curve gets
				local k = 0.35
				local lowerK = 0.8
				local function SCurveTranform(t: number)
					t = math.clamp(t, -1, 1)
					if t >= 0 then
						return (k*t) / (k - t + 1)
					end
					return -((lowerK*-t) / (lowerK + t + 1))
				end

				local DEADZONE = 0.1
				local function toSCurveSpace(t: number)
					return (1 + DEADZONE) * (2*math.abs(t) - 1) - DEADZONE
				end

				local function fromSCurveSpace(t: number)
					return t/2 + 0.5
				end

				function CameraUtils.GamepadLinearToCurve(thumbstickPosition: Vector2)
					local function onAxis(axisValue)
						local sign = 1
						if axisValue < 0 then
							sign = -1
						end
						local point = fromSCurveSpace(SCurveTranform(toSCurveSpace(math.abs(axisValue))))
						point = point * sign
						return math.clamp(point, -1, 1)
					end
					return Vector2.new(onAxis(thumbstickPosition.x), onAxis(thumbstickPosition.y))
				end

				-- This function converts 4 different, redundant enumeration types to one standard so the values can be compared
				function CameraUtils.ConvertCameraModeEnumToStandard(enumValue: 
					Enum.TouchCameraMovementMode | 
					Enum.ComputerCameraMovementMode | 
					Enum.DevTouchCameraMovementMode |
					Enum.DevComputerCameraMovementMode): Enum.ComputerCameraMovementMode | Enum.DevComputerCameraMovementMode
					if enumValue == Enum.TouchCameraMovementMode.Default then
						return Enum.ComputerCameraMovementMode.Follow
					end

					if enumValue == Enum.ComputerCameraMovementMode.Default then
						return Enum.ComputerCameraMovementMode.Classic
					end

					if enumValue == Enum.TouchCameraMovementMode.Classic or
						enumValue == Enum.DevTouchCameraMovementMode.Classic or
						enumValue == Enum.DevComputerCameraMovementMode.Classic or
						enumValue == Enum.ComputerCameraMovementMode.Classic then
						return Enum.ComputerCameraMovementMode.Classic
					end

					if enumValue == Enum.TouchCameraMovementMode.Follow or
						enumValue == Enum.DevTouchCameraMovementMode.Follow or
						enumValue == Enum.DevComputerCameraMovementMode.Follow or
						enumValue == Enum.ComputerCameraMovementMode.Follow then
						return Enum.ComputerCameraMovementMode.Follow
					end

					if enumValue == Enum.TouchCameraMovementMode.Orbital or
						enumValue == Enum.DevTouchCameraMovementMode.Orbital or
						enumValue == Enum.DevComputerCameraMovementMode.Orbital or
						enumValue == Enum.ComputerCameraMovementMode.Orbital then
						return Enum.ComputerCameraMovementMode.Orbital
					end

					if enumValue == Enum.ComputerCameraMovementMode.CameraToggle or
						enumValue == Enum.DevComputerCameraMovementMode.CameraToggle then
						return Enum.ComputerCameraMovementMode.CameraToggle
					end

					-- Note: Only the Dev versions of the Enums have UserChoice as an option
					if enumValue == Enum.DevTouchCameraMovementMode.UserChoice or
						enumValue == Enum.DevComputerCameraMovementMode.UserChoice then
						return Enum.DevComputerCameraMovementMode.UserChoice
					end

					-- For any unmapped options return Classic camera
					return Enum.ComputerCameraMovementMode.Classic
				end

				return CameraUtils


			end
			local function Popper()
				--------------------------------------------------------------------------------
				-- Popper.lua
				-- Prevents your camera from clipping through walls.
				--------------------------------------------------------------------------------

				local Players = game:GetService("Players")

				local camera = game.Workspace.CurrentCamera

				local min = math.min
				local tan = math.tan
				local rad = math.rad
				local inf = math.huge
				local ray = Ray.new

				local function getTotalTransparency(part)
					return 1 - (1 - part.Transparency)*(1 - part.LocalTransparencyModifier)
				end

				local function eraseFromEnd(t, toSize)
					for i = #t, toSize + 1, -1 do
						t[i] = nil
					end
				end

				local nearPlaneZ, projX, projY do
					local function updateProjection()
						local fov = rad(camera.FieldOfView)
						local view = camera.ViewportSize
						local ar = view.X/view.Y

						projY = 2*tan(fov/2)
						projX = ar*projY
					end

					camera:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
					camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)

					updateProjection()

					nearPlaneZ = camera.NearPlaneZ
					camera:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
						nearPlaneZ = camera.NearPlaneZ
					end)
				end

				local blacklist = {} do
					local charMap = {}

					local function refreshIgnoreList()
						local n = 1
						blacklist = {}
						for _, character in pairs(charMap) do
							blacklist[n] = character
							n = n + 1
						end
					end

					local function playerAdded(player)
						local function characterAdded(character)
							charMap[player] = character
							refreshIgnoreList()
						end
						local function characterRemoving()
							charMap[player] = nil
							refreshIgnoreList()
						end

						player.CharacterAdded:Connect(characterAdded)
						player.CharacterRemoving:Connect(characterRemoving)
						if player.Character then
							characterAdded(player.Character)
						end
					end

					local function playerRemoving(player)
						charMap[player] = nil
						refreshIgnoreList()
					end

					Players.PlayerAdded:Connect(playerAdded)
					Players.PlayerRemoving:Connect(playerRemoving)

					for _, player in ipairs(Players:GetPlayers()) do
						playerAdded(player)
					end
					refreshIgnoreList()
				end

				--------------------------------------------------------------------------------------------
				-- Popper uses the level geometry find an upper bound on subject-to-camera distance.
				--
				-- Hard limits are applied immediately and unconditionally. They are generally caused
				-- when level geometry intersects with the near plane (with exceptions, see below).
				--
				-- Soft limits are only applied under certain conditions.
				-- They are caused when level geometry occludes the subject without actually intersecting
				-- with the near plane at the target distance.
				--
				-- Soft limits can be promoted to hard limits and hard limits can be demoted to soft limits.
				-- We usually don"t want the latter to happen.
				--
				-- A soft limit will be promoted to a hard limit if an obstruction
				-- lies between the current and target camera positions.
				--------------------------------------------------------------------------------------------

				local subjectRoot
				local subjectPart

				camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
					local subject = camera.CameraSubject
					if subject:IsA("Humanoid") then
						subjectPart = subject.RootPart
					elseif subject:IsA("BasePart") then
						subjectPart = subject
					else
						subjectPart = nil
					end
				end)

				local function canOcclude(part)
					-- Occluders must be:
					-- 1. Opaque
					-- 2. Interactable
					-- 3. Not in the same assembly as the subject

					return
						getTotalTransparency(part) < 0.25 and
						part.CanCollide and
						subjectRoot ~= (part:GetRootPart() or part) and
						not part:IsA("TrussPart")
				end

				-- Offsets for the volume visibility test
				local SCAN_SAMPLE_OFFSETS = {
					Vector2.new( 0.4, 0.0),
					Vector2.new(-0.4, 0.0),
					Vector2.new( 0.0,-0.4),
					Vector2.new( 0.0, 0.4),
					Vector2.new( 0.0, 0.2),
				}

				-- Maximum number of rays that can be cast 
				local QUERY_POINT_CAST_LIMIT = 64

				--------------------------------------------------------------------------------
				-- Piercing raycasts

				local function getCollisionPoint(origin, dir)
					local originalSize = #blacklist
					repeat
						local hitPart, hitPoint = workspace:FindPartOnRayWithIgnoreList(
							ray(origin, dir), blacklist, false, true
						)

						if hitPart then
							if hitPart.CanCollide then
								eraseFromEnd(blacklist, originalSize)
								return hitPoint, true
							end
							blacklist[#blacklist + 1] = hitPart
						end
					until not hitPart

					eraseFromEnd(blacklist, originalSize)
					return origin + dir, false
				end

				--------------------------------------------------------------------------------

				local function queryPoint(origin, unitDir, dist, lastPos)
					debug.profilebegin("queryPoint")

					local originalSize = #blacklist

					dist = dist + nearPlaneZ
					local target = origin + unitDir*dist

					local softLimit = inf
					local hardLimit = inf
					local movingOrigin = origin

					local numPierced = 0

					repeat
						local entryPart, entryPos = workspace:FindPartOnRayWithIgnoreList(ray(movingOrigin, target - movingOrigin), blacklist, false, true)
						numPierced += 1

						if entryPart then
							-- forces the current iteration into a hard limit to cap the number of raycasts
							local earlyAbort = numPierced >= QUERY_POINT_CAST_LIMIT

							if canOcclude(entryPart) or earlyAbort then
								local wl = {entryPart}
								local exitPart = workspace:FindPartOnRayWithWhitelist(ray(target, entryPos - target), wl, true)

								local lim = (entryPos - origin).Magnitude

								if exitPart and not earlyAbort then
									local promote = false
									if lastPos then
										promote =
											workspace:FindPartOnRayWithWhitelist(ray(lastPos, target - lastPos), wl, true) or
											workspace:FindPartOnRayWithWhitelist(ray(target, lastPos - target), wl, true)
									end

									if promote then
										-- Ostensibly a soft limit, but the camera has passed through it in the last frame, so promote to a hard limit.
										hardLimit = lim
									elseif dist < softLimit then
										-- Trivial soft limit
										softLimit = lim
									end
								else
									-- Trivial hard limit
									hardLimit = lim
								end
							end

							blacklist[#blacklist + 1] = entryPart
							movingOrigin = entryPos - unitDir*1e-3
						end
					until hardLimit < inf or not entryPart

					eraseFromEnd(blacklist, originalSize)

					debug.profileend()
					return softLimit - nearPlaneZ, hardLimit - nearPlaneZ
				end

				local function queryViewport(focus, dist)
					debug.profilebegin("queryViewport")

					local fP =  focus.p
					local fX =  focus.rightVector
					local fY =  focus.upVector
					local fZ = -focus.lookVector

					local viewport = camera.ViewportSize

					local hardBoxLimit = inf
					local softBoxLimit = inf

					-- Center the viewport on the PoI, sweep points on the edge towards the target, and take the minimum limits
					for viewX = 0, 1 do
						local worldX = fX*((viewX - 0.5)*projX)

						for viewY = 0, 1 do
							local worldY = fY*((viewY - 0.5)*projY)

							local origin = fP + nearPlaneZ*(worldX + worldY)
							local lastPos = camera:ViewportPointToRay(
								viewport.x*viewX,
								viewport.y*viewY
							).Origin

							local softPointLimit, hardPointLimit = queryPoint(origin, fZ, dist, lastPos)

							if hardPointLimit < hardBoxLimit then
								hardBoxLimit = hardPointLimit
							end
							if softPointLimit < softBoxLimit then
								softBoxLimit = softPointLimit
							end
						end
					end
					debug.profileend()

					return softBoxLimit, hardBoxLimit
				end

				local function testPromotion(focus, dist, focusExtrapolation)
					debug.profilebegin("testPromotion")

					local fP = focus.p
					local fX = focus.rightVector
					local fY = focus.upVector
					local fZ = -focus.lookVector

					do
						-- Dead reckoning the camera rotation and focus
						debug.profilebegin("extrapolate")

						local SAMPLE_DT = 0.0625
						local SAMPLE_MAX_T = 1.25

						local maxDist = (getCollisionPoint(fP, focusExtrapolation.posVelocity*SAMPLE_MAX_T) - fP).Magnitude
						-- Metric that decides how many samples to take
						local combinedSpeed = focusExtrapolation.posVelocity.magnitude

						for dt = 0, min(SAMPLE_MAX_T, focusExtrapolation.rotVelocity.magnitude + maxDist/combinedSpeed), SAMPLE_DT do
							local cfDt = focusExtrapolation.extrapolate(dt) -- Extrapolated CFrame at time dt

							if queryPoint(cfDt.p, -cfDt.lookVector, dist) >= dist then
								return false
							end
						end

						debug.profileend()
					end

					do
						-- Test screen-space offsets from the focus for the presence of soft limits
						debug.profilebegin("testOffsets")

						for _, offset in ipairs(SCAN_SAMPLE_OFFSETS) do
							local scaledOffset = offset
							local pos = getCollisionPoint(fP, fX*scaledOffset.x + fY*scaledOffset.y)
							if queryPoint(pos, (fP + fZ*dist - pos).Unit, dist) == inf then
								return false
							end
						end

						debug.profileend()
					end

					debug.profileend()
					return true
				end

				local function Popper(focus, targetDist, focusExtrapolation)
					debug.profilebegin("popper")

					subjectRoot = subjectPart and subjectPart:GetRootPart() or subjectPart

					local dist = targetDist
					local soft, hard = queryViewport(focus, targetDist)
					if hard < dist then
						dist = hard
					end
					if soft < dist and testPromotion(focus, targetDist, focusExtrapolation) then
						dist = soft
					end

					subjectRoot = nil

					debug.profileend()
					return dist
				end

				return Popper

			end
			local function ZoomController()
				--!strict
				-- Zoom
				-- Controls the distance between the focus and the camera.

				local ZOOM_STIFFNESS = 4.5
				local ZOOM_DEFAULT = 12.5
				local ZOOM_ACCELERATION = 0.0375

				local MIN_FOCUS_DIST = 0.5
				local DIST_OPAQUE = 1

				local Popper = Popper()

				local clamp = math.clamp
				local exp = math.exp
				local min = math.min
				local max = math.max
				local pi = math.pi

				local cameraMinZoomDistance, cameraMaxZoomDistance do
					local Player = game:GetService("Players").LocalPlayer

					local function updateBounds()
						cameraMinZoomDistance = 0.5--Player.CameraMinZoomDistance
						cameraMaxZoomDistance = 100000--Player.CameraMaxZoomDistance
					end

					updateBounds()

					--Player:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(updateBounds)
					--Player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(updateBounds)
				end

				local ConstrainedSpring = {} do
					ConstrainedSpring.__index = ConstrainedSpring

					function ConstrainedSpring.new(freq: number, x: number, minValue: number, maxValue: number)
						x = clamp(x, minValue, maxValue)
						return setmetatable({
							freq = freq, -- Undamped frequency (Hz)
							x = x, -- Current position
							v = 0, -- Current velocity
							minValue = minValue, -- Minimum bound
							maxValue = maxValue, -- Maximum bound
							goal = x, -- Goal position
						}, ConstrainedSpring)
					end

					function ConstrainedSpring:Step(dt: number)
						local freq = self.freq :: number * 2 * pi -- Convert from Hz to rad/s
						local x: number = self.x
						local v: number = self.v
						local minValue: number = self.minValue
						local maxValue: number = self.maxValue
						local goal: number = self.goal

						-- Solve the spring ODE for position and velocity after time t, assuming critical damping:
						--   2*f*x'[t] + x''[t] = f^2*(g - x[t])
						-- Knowns are x[0] and x'[0].
						-- Solve for x[t] and x'[t].

						local offset = goal - x
						local step = freq*dt
						local decay = exp(-step)

						local x1 = goal + (v*dt - offset*(step + 1))*decay
						local v1 = ((offset*freq - v)*step + v)*decay

						-- Constrain
						if x1 < minValue then
							x1 = minValue
							v1 = 0
						elseif x1 > maxValue then
							x1 = maxValue
							v1 = 0
						end

						self.x = x1
						self.v = v1

						return x1
					end
				end

				local zoomSpring = ConstrainedSpring.new(ZOOM_STIFFNESS, ZOOM_DEFAULT, MIN_FOCUS_DIST, cameraMaxZoomDistance)

				local function stepTargetZoom(z: number, dz: number, zoomMin: number, zoomMax: number)
					z = clamp(z + dz*(1 + z*ZOOM_ACCELERATION), zoomMin, zoomMax)
					if z < DIST_OPAQUE then
						z = dz <= 0 and zoomMin or DIST_OPAQUE
					end
					return z
				end

				local zoomDelta = 0

				local Zoom = {} do
					function Zoom.Update(renderDt: number, focus: CFrame, extrapolation)
						local poppedZoom = math.huge

						if zoomSpring.goal > DIST_OPAQUE then
							-- Make a pessimistic estimate of zoom distance for this step without accounting for poppercam
							local maxPossibleZoom = max(
								zoomSpring.x,
								stepTargetZoom(zoomSpring.goal, zoomDelta, cameraMinZoomDistance, cameraMaxZoomDistance)
							)

							-- Run the Popper algorithm on the feasible zoom range, [MIN_FOCUS_DIST, maxPossibleZoom]
							poppedZoom = Popper(
								focus*CFrame.new(0, 0, MIN_FOCUS_DIST),
								maxPossibleZoom - MIN_FOCUS_DIST,
								extrapolation
							) + MIN_FOCUS_DIST
						end

						zoomSpring.minValue = MIN_FOCUS_DIST
						zoomSpring.maxValue = min(cameraMaxZoomDistance, poppedZoom)

						return zoomSpring:Step(renderDt)
					end

					function Zoom.GetZoomRadius()
						return zoomSpring.x
					end

					function Zoom.SetZoomParameters(targetZoom, newZoomDelta)
						zoomSpring.goal = targetZoom--min(cameraMaxZoomDistance, max(targetZoom, cameraMinZoomDistance))
						zoomDelta = newZoomDelta-- + (targetZoom - zoomSpring.goal)
					end

					function Zoom.ReleaseSpring()
						zoomSpring.x = zoomSpring.goal
						zoomSpring.v = 0
					end	
				end

				return Zoom

			end
			local function BaseOcclusion()
				--[[
	BaseOcclusion - Abstract base class for character occlusion control modules
	2018 Camera Update - AllYourBlox
--]]

				--[[ The Module ]]--
				local BaseOcclusion = {}
				BaseOcclusion.__index = BaseOcclusion
				setmetatable(BaseOcclusion, {
					__call = function(_, ...)
						return BaseOcclusion.new(...)
					end
				})

				function BaseOcclusion.new()
					local self = setmetatable({}, BaseOcclusion)
					return self
				end

				-- Called when character is added
				function BaseOcclusion:CharacterAdded(char: Model, player: Player)
				end

				-- Called when character is about to be removed
				function BaseOcclusion:CharacterRemoving(char: Model, player: Player)
				end

				function BaseOcclusion:OnCameraSubjectChanged(newSubject)
				end

				--[[ Derived classes are required to override and implement all of the following functions ]]--
				function BaseOcclusion:GetOcclusionMode(): Enum.DevCameraOcclusionMode?
					-- Must be overridden in derived classes to return an Enum.DevCameraOcclusionMode value
					warn("BaseOcclusion GetOcclusionMode must be overridden by derived classes")
					return nil
				end

				function BaseOcclusion:Enable(enabled: boolean)
					warn("BaseOcclusion Enable must be overridden by derived classes")
				end

				function BaseOcclusion:Update(dt: number, desiredCameraCFrame: CFrame, desiredCameraFocus: CFrame)
					warn("BaseOcclusion Update must be overridden by derived classes")
					return desiredCameraCFrame, desiredCameraFocus
				end

				return BaseOcclusion

			end
			local function Poppercam()
				--[[
	Poppercam - Occlusion module that brings the camera closer to the subject when objects are blocking the view.
--]]

				local ZoomController = ZoomController()

				local TransformExtrapolator = {} do
					TransformExtrapolator.__index = TransformExtrapolator

					local CF_IDENTITY = CFrame.new()

					local function cframeToAxis(cframe: CFrame): Vector3
						local axis: Vector3, angle: number = cframe:toAxisAngle()
						return axis*angle
					end

					local function axisToCFrame(axis: Vector3): CFrame
						local angle: number = axis.magnitude
						if angle > 1e-5 then
							return CFrame.fromAxisAngle(axis, angle)
						end
						return CF_IDENTITY
					end

					local function extractRotation(cf: CFrame): CFrame
						local _, _, _, xx, yx, zx, xy, yy, zy, xz, yz, zz = cf:components()
						return CFrame.new(0, 0, 0, xx, yx, zx, xy, yy, zy, xz, yz, zz)
					end

					function TransformExtrapolator.new()
						return setmetatable({
							lastCFrame = nil,
						}, TransformExtrapolator)
					end

					function TransformExtrapolator:Step(dt: number, currentCFrame: CFrame)
						local lastCFrame = self.lastCFrame or currentCFrame
						self.lastCFrame = currentCFrame

						local currentPos = currentCFrame.p
						local currentRot = extractRotation(currentCFrame)

						local lastPos = lastCFrame.p
						local lastRot = extractRotation(lastCFrame)

						-- Estimate velocities from the delta between now and the last frame
						-- This estimation can be a little noisy.
						local dp = (currentPos - lastPos)/dt
						local dr = cframeToAxis(currentRot*lastRot:inverse())/dt

						local function extrapolate(t)
							local p = dp*t + currentPos
							local r = axisToCFrame(dr*t)*currentRot
							return r + p
						end

						return {
							extrapolate = extrapolate,
							posVelocity = dp,
							rotVelocity = dr,
						}
					end

					function TransformExtrapolator:Reset()
						self.lastCFrame = nil
					end
				end

				--[[ The Module ]]--
				local BaseOcclusion = BaseOcclusion()
				local Poppercam = setmetatable({}, BaseOcclusion)
				Poppercam.__index = Poppercam

				function Poppercam.new()
					local self = setmetatable(BaseOcclusion.new(), Poppercam)
					self.focusExtrapolator = TransformExtrapolator.new()
					self.zoomController = ZoomController
					return self
				end

				function Poppercam:GetOcclusionMode()
					return Enum.DevCameraOcclusionMode.Zoom
				end

				function Poppercam:Enable(enable)
					self.focusExtrapolator:Reset()
				end

				function Poppercam:Update(renderDt, desiredCameraCFrame, desiredCameraFocus, cameraController)
					local rotatedFocus = CFrame.new(desiredCameraFocus.p, desiredCameraCFrame.p)*CFrame.new(
					0, 0, 0,
					-1, 0, 0,
					0, 1, 0,
					0, 0, -1
					)
					local extrapolation = self.focusExtrapolator:Step(renderDt, rotatedFocus)
					local zoom = ZoomController.Update(renderDt, rotatedFocus, extrapolation)
					return rotatedFocus*CFrame.new(0, 0, zoom), desiredCameraFocus
				end

				-- Called when character is added
				function Poppercam:CharacterAdded(character, player)
				end

				-- Called when character is about to be removed
				function Poppercam:CharacterRemoving(character, player)
				end

				function Poppercam:OnCameraSubjectChanged(newSubject)
				end

				return Poppercam

			end
			local function CameraUI()
				local Players = game:GetService("Players")
				local TweenService = game:GetService("TweenService")

				local LocalPlayer = Players.LocalPlayer
				if not LocalPlayer then
					Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
					LocalPlayer = Players.LocalPlayer
				end

				local function waitForChildOfClass(parent: Instance, class: string)
					local child = parent:FindFirstChildOfClass(class)
					while not child or child.ClassName ~= class do
						child = parent.ChildAdded:Wait()
					end
					return child
				end

				local PlayerGui = waitForChildOfClass(LocalPlayer, "PlayerGui")

				local TOAST_OPEN_SIZE = UDim2.new(0, 326, 0, 58)
				local TOAST_CLOSED_SIZE = UDim2.new(0, 80, 0, 58)
				local TOAST_BACKGROUND_COLOR = Color3.fromRGB(32, 32, 32)
				local TOAST_BACKGROUND_TRANS = 0.4
				local TOAST_FOREGROUND_COLOR = Color3.fromRGB(200, 200, 200)
				local TOAST_FOREGROUND_TRANS = 0

				-- Convenient syntax for creating a tree of instanes
				local function create(className: string)
					return function(props)
						local inst = Instance.new(className)
						local parent = props.Parent
						props.Parent = nil
						for name, val in pairs(props) do
							if type(name) == "string" then
								inst[name] = val
							else
								val.Parent = inst
							end
						end
						-- Only set parent after all other properties are initialized
						inst.Parent = parent
						return inst
					end
				end

				local initialized = false

				local uiRoot: ScreenGui
				local toast
				local toastIcon
				local toastUpperText
				local toastLowerText

				local function initializeUI()
					assert(not initialized)

					uiRoot = create("ScreenGui"){
						Name = "RbxCameraUI",
						AutoLocalize = false,
						Enabled = true,
						DisplayOrder = -1, -- Appears behind default developer UI
						IgnoreGuiInset = false,
						ResetOnSpawn = false,
						ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

						create("ImageLabel"){
							Name = "Toast",
							Visible = false,
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0.5, 0, 0, 8),
							Size = TOAST_CLOSED_SIZE,
							Image = "rbxasset://textures/ui/Camera/CameraToast9Slice.png",
							ImageColor3 = TOAST_BACKGROUND_COLOR,
							ImageRectSize = Vector2.new(6, 6),
							ImageTransparency = 1,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(3, 3, 3, 3),
							ClipsDescendants = true,

							create("Frame"){
								Name = "IconBuffer",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 0, 0),
								Size = UDim2.new(0, 80, 1, 0),

								create("ImageLabel"){
									Name = "Icon",
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundTransparency = 1,
									Position = UDim2.new(0.5, 0, 0.5, 0),
									Size = UDim2.new(0, 48, 0, 48),
									ZIndex = 2,
									Image = "rbxasset://textures/ui/Camera/CameraToastIcon.png",
									ImageColor3 = TOAST_FOREGROUND_COLOR,
									ImageTransparency = 1,
								}
							},

							create("Frame"){
								Name = "TextBuffer",
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.new(0, 80, 0, 0),
								Size = UDim2.new(1, -80, 1, 0),
								ClipsDescendants = true,

								create("TextLabel"){
									Name = "Upper",
									AnchorPoint = Vector2.new(0, 1),
									BackgroundTransparency = 1,
									Position = UDim2.new(0, 0, 0.5, 0),
									Size = UDim2.new(1, 0, 0, 19),
									Font = Enum.Font.GothamSemibold,
									Text = "Camera control enabled",
									TextColor3 = TOAST_FOREGROUND_COLOR,
									TextTransparency = 1,
									TextSize = 19,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextYAlignment = Enum.TextYAlignment.Center,
								},

								create("TextLabel"){
									Name = "Lower",
									AnchorPoint = Vector2.new(0, 0),
									BackgroundTransparency = 1,
									Position = UDim2.new(0, 0, 0.5, 3),
									Size = UDim2.new(1, 0, 0, 15),
									Font = Enum.Font.Gotham,
									Text = "Right mouse button to toggle",
									TextColor3 = TOAST_FOREGROUND_COLOR,
									TextTransparency = 1,
									TextSize = 15,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextYAlignment = Enum.TextYAlignment.Center,
								},
							},
						},

						Parent = PlayerGui,
					}

					toast = uiRoot.Toast
					toastIcon = toast.IconBuffer.Icon
					toastUpperText = toast.TextBuffer.Upper
					toastLowerText = toast.TextBuffer.Lower

					initialized = true
				end

				local CameraUI = {}

				do
					-- Instantaneously disable the toast or enable for opening later on. Used when switching camera modes.
					function CameraUI.setCameraModeToastEnabled(enabled: boolean)
						if not enabled and not initialized then
							return
						end

						if not initialized then
							initializeUI()
						end

						toast.Visible = enabled
						if not enabled then
							CameraUI.setCameraModeToastOpen(false)
						end
					end

					local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					-- Tween the toast in or out. Toast must be enabled with setCameraModeToastEnabled.
					function CameraUI.setCameraModeToastOpen(open: boolean)
						assert(initialized)

						TweenService:Create(toast, tweenInfo, {
							Size = open and TOAST_OPEN_SIZE or TOAST_CLOSED_SIZE,
							ImageTransparency = open and TOAST_BACKGROUND_TRANS or 1,
						}):Play()

						TweenService:Create(toastIcon, tweenInfo, {
							ImageTransparency = open and TOAST_FOREGROUND_TRANS or 1,
						}):Play()

						TweenService:Create(toastUpperText, tweenInfo, {
							TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
						}):Play()

						TweenService:Create(toastLowerText, tweenInfo, {
							TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
						}):Play()
					end
				end

				return CameraUI

			end
			local function CameraToggleStateController()
				--!strict
				local Players = game:GetService("Players")
				local UserInputService = game:GetService("UserInputService")
				local GameSettings = UserSettings():GetService("UserGameSettings")

				local LocalPlayer = Players.LocalPlayer
				if not LocalPlayer then
					Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
					LocalPlayer = Players.LocalPlayer
				end

				local Mouse = LocalPlayer:GetMouse()

				local Input = CameraInput()
				local CameraUI = CameraUI()

				local lastTogglePan = false
				local lastTogglePanChange = tick()

				local CROSS_MOUSE_ICON = "rbxasset://textures/Cursors/CrossMouseIcon.png"

				local lockStateDirty = false
				local wasTogglePanOnTheLastTimeYouWentIntoFirstPerson = false
				local lastFirstPerson = false

				CameraUI.setCameraModeToastEnabled(false)

				return function(isFirstPerson: boolean)
					local togglePan = Input.getTogglePan()
					local toastTimeout = 3

					if isFirstPerson and togglePan ~= lastTogglePan then
						lockStateDirty = true
					end

					if lastTogglePan ~= togglePan or tick() - lastTogglePanChange > toastTimeout then
						local doShow = togglePan and tick() - lastTogglePanChange < toastTimeout

						CameraUI.setCameraModeToastOpen(doShow)

						if togglePan then
							lockStateDirty = false
						end
						lastTogglePanChange = tick()
						lastTogglePan = togglePan
					end

					if isFirstPerson ~= lastFirstPerson then
						if isFirstPerson then
							wasTogglePanOnTheLastTimeYouWentIntoFirstPerson = Input.getTogglePan()
							Input.setTogglePan(true)
						elseif not lockStateDirty then
							Input.setTogglePan(wasTogglePanOnTheLastTimeYouWentIntoFirstPerson)
						end
					end

					if isFirstPerson then
						if Input.getTogglePan() then
							Mouse.Icon = CROSS_MOUSE_ICON
							UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
							GameSettings.RotationType = Enum.RotationType.CameraRelative
						else
							Mouse.Icon = ""
							UserInputService.MouseBehavior = Enum.MouseBehavior.Default
							GameSettings.RotationType = Enum.RotationType.CameraRelative
						end

					elseif Input.getTogglePan() then
						Mouse.Icon = CROSS_MOUSE_ICON
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
						GameSettings.RotationType = Enum.RotationType.MovementRelative

					elseif Input.getHoldPan() then
						Mouse.Icon = ""
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
						GameSettings.RotationType = Enum.RotationType.MovementRelative

					else
						Mouse.Icon = ""
						UserInputService.MouseBehavior = Enum.MouseBehavior.Default
						GameSettings.RotationType = Enum.RotationType.MovementRelative
					end

					lastFirstPerson = isFirstPerson
				end

			end
			local function BaseCamera()
				--[[
	BaseCamera - Abstract base class for camera control modules
	2018 Camera Update - AllYourBlox
--]]

				--[[ Local Constants ]]--
				local UNIT_Z = Vector3.new(0,0,1)
				local X1_Y0_Z1 = Vector3.new(1,0,1)	--Note: not a unit vector, used for projecting onto XZ plane

				local DEFAULT_DISTANCE = 12.5	-- Studs
				local PORTRAIT_DEFAULT_DISTANCE = 25		-- Studs
				local FIRST_PERSON_DISTANCE_THRESHOLD = 1.0 -- Below this value, snap into first person

				-- Note: DotProduct check in CoordinateFrame::lookAt() prevents using values within about
				-- 8.11 degrees of the +/- Y axis, that's why these limits are currently 80 degrees
				local MIN_Y = math.rad(-80)
				local MAX_Y = math.rad(80)

				local VR_ANGLE = math.rad(15)
				local VR_LOW_INTENSITY_ROTATION = Vector2.new(math.rad(15), 0)
				local VR_HIGH_INTENSITY_ROTATION = Vector2.new(math.rad(45), 0)
				local VR_LOW_INTENSITY_REPEAT = 0.1
				local VR_HIGH_INTENSITY_REPEAT = 0.4

				local ZERO_VECTOR2 = Vector2.new(0,0)
				local ZERO_VECTOR3 = Vector3.new(0,0,0)

				local SEAT_OFFSET = Vector3.new(0,5,0)
				local VR_SEAT_OFFSET = Vector3.new(0,4,0)
				local HEAD_OFFSET = Vector3.new(0,1.5,0)
				local R15_HEAD_OFFSET = Vector3.new(0, 1.5, 0)
				local R15_HEAD_OFFSET_NO_SCALING = Vector3.new(0, 2, 0)
				local HUMANOID_ROOT_PART_SIZE = Vector3.new(2, 2, 1)

				local GAMEPAD_ZOOM_STEP_1 = 0
				local GAMEPAD_ZOOM_STEP_2 = 10
				local GAMEPAD_ZOOM_STEP_3 = 20

				local ZOOM_SENSITIVITY_CURVATURE = 0.5
				local FIRST_PERSON_DISTANCE_MIN = 0.5

				local Util = CameraUtils()
				local Poppercam = Poppercam().new()
				local ZoomController = Poppercam.zoomController
				local CameraToggleStateController = CameraToggleStateController()
				local CameraInput = CameraInput()
				local CameraUI = CameraUI()

				--[[ Roblox Services ]]--
				local Players = game:GetService("Players")
				local UserInputService = game:GetService("UserInputService")
				local StarterGui = game:GetService("StarterGui")
				local VRService = game:GetService("VRService")
				local UserGameSettings = UserSettings():GetService("UserGameSettings")

				local player = Players.LocalPlayer

				local FFlagUserFlagEnableNewVRSystem do
					local success, result = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserFlagEnableNewVRSystem")
					end)
					FFlagUserFlagEnableNewVRSystem = success and result
				end

				--[[ The Module ]]--
				local BaseCamera = {}
				BaseCamera.__index = BaseCamera

				function BaseCamera.new()
					local self = setmetatable({}, BaseCamera)

					-- So that derived classes have access to this
					self.FIRST_PERSON_DISTANCE_THRESHOLD = FIRST_PERSON_DISTANCE_THRESHOLD

					self.cameraType = nil
					self.cameraMovementMode = nil

					self.lastCameraTransform = nil
					self.lastUserPanCamera = tick()

					self.humanoidRootPart = nil
					self.humanoidCache = {}

					-- Subject and position on last update call
					self.lastSubject = nil
					self.lastSubjectPosition = Vector3.new(0, 5, 0)
					self.lastSubjectCFrame = CFrame.new(self.lastSubjectPosition)

					-- These subject distance members refer to the nominal camera-to-subject follow distance that the camera
					-- is trying to maintain, not the actual measured value.
					-- The default is updated when screen orientation or the min/max distances change,
					-- to be sure the default is always in range and appropriate for the orientation.
					self.defaultSubjectDistance = math.clamp(DEFAULT_DISTANCE, 0.5, 100000)
					self.currentSubjectDistance = math.clamp(DEFAULT_DISTANCE, 0.5, 100000)

					self.inFirstPerson = false
					self.inMouseLockedMode = false
					self.portraitMode = false
					self.isSmallTouchScreen = false

					-- Used by modules which want to reset the camera angle on respawn.
					self.resetCameraAngle = true

					self.enabled = false

					-- Input Event Connections

					self.PlayerGui = nil

					self.cameraChangedConn = nil
					self.viewportSizeChangedConn = nil

					-- VR Support
					self.shouldUseVRRotation = false
					self.VRRotationIntensityAvailable = false
					self.lastVRRotationIntensityCheckTime = 0
					self.lastVRRotationTime = 0
					self.vrRotateKeyCooldown = {}
					self.cameraTranslationConstraints = Vector3.new(1, 1, 1)
					self.humanoidJumpOrigin = nil
					self.trackingHumanoid = nil
					self.cameraFrozen = false
					self.subjectStateChangedConn = nil

					self.gamepadZoomPressConnection = nil

					-- Mouse locked formerly known as shift lock mode
					self.mouseLockOffset = ZERO_VECTOR3

					self.poppercam = Poppercam

					-- Initialization things used to always execute at game load time, but now these camera modules are instantiated
					-- when needed, so the code here may run well after the start of the game

					if player.Character then
						self:OnCharacterAdded(player.Character)
					end

					player.CharacterAdded:Connect(function(char)
						self:OnCharacterAdded(char)
					end)

					if self.cameraChangedConn then self.cameraChangedConn:Disconnect() end
					self.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
						--self:OnCurrentCameraChanged()
					end)
					self:OnCurrentCameraChanged()

					if self.playerCameraModeChangeConn then self.playerCameraModeChangeConn:Disconnect() end
					self.playerCameraModeChangeConn = player:GetPropertyChangedSignal("CameraMode"):Connect(function()
						self:OnPlayerCameraPropertyChange()
					end)

					if self.minDistanceChangeConn then self.minDistanceChangeConn:Disconnect() end
					self.minDistanceChangeConn = player:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
						self:OnPlayerCameraPropertyChange()
					end)

					if self.maxDistanceChangeConn then self.maxDistanceChangeConn:Disconnect() end
					self.maxDistanceChangeConn = player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
						self:OnPlayerCameraPropertyChange()
					end)

					if self.playerDevTouchMoveModeChangeConn then self.playerDevTouchMoveModeChangeConn:Disconnect() end
					self.playerDevTouchMoveModeChangeConn = player:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
						self:OnDevTouchMovementModeChanged()
					end)
					self:OnDevTouchMovementModeChanged() -- Init

					if self.gameSettingsTouchMoveMoveChangeConn then self.gameSettingsTouchMoveMoveChangeConn:Disconnect() end
					self.gameSettingsTouchMoveMoveChangeConn = UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
						self:OnGameSettingsTouchMovementModeChanged()
					end)
					self:OnGameSettingsTouchMovementModeChanged() -- Init

					UserGameSettings:SetCameraYInvertVisible()
					UserGameSettings:SetGamepadCameraSensitivityVisible()

					self.hasGameLoaded = game:IsLoaded()
					if not self.hasGameLoaded then
						self.gameLoadedConn = game.Loaded:Connect(function()
							self.hasGameLoaded = true
							self.gameLoadedConn:Disconnect()
							self.gameLoadedConn = nil
						end)
					end

					self:OnPlayerCameraPropertyChange()

					return self
				end

				function BaseCamera:GetModuleName()
					return "BaseCamera"
				end

				function BaseCamera:OnCharacterAdded(char)
					--self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
					self.humanoidRootPart = nil
					if UserInputService.TouchEnabled then
						self.PlayerGui = player:WaitForChild("PlayerGui")
						for _, child in ipairs(char:GetChildren()) do
							if child:IsA("Tool") then
								self.isAToolEquipped = true
							end
						end
						char.ChildAdded:Connect(function(child)
							if child:IsA("Tool") then
								self.isAToolEquipped = true
							end
						end)
						char.ChildRemoved:Connect(function(child)
							if child:IsA("Tool") then
								self.isAToolEquipped = false
							end
						end)
					end
				end

				function BaseCamera:GetHumanoidRootPart(): BasePart
					if not self.humanoidRootPart then
						if player.Character then
							local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								self.humanoidRootPart = humanoid.RootPart
							end
						end
					end
					return self.humanoidRootPart
				end

				function BaseCamera:GetBodyPartToFollow(humanoid: Humanoid, isDead: boolean) -- BasePart
					-- If the humanoid is dead, prefer the head part if one still exists as a sibling of the humanoid
					if humanoid:GetState() == Enum.HumanoidStateType.Dead then
						local character = humanoid.Parent
						if character and character:IsA("Model") then
							return character:FindFirstChild("Head") or humanoid.RootPart
						end
					end

					return humanoid.RootPart
				end

				function BaseCamera:GetSubjectCFrame(): CFrame
					if Focus then
						return Focus
					end
					local result = self.lastSubjectCFrame
					local camera = workspace.CurrentCamera
					local cameraSubject = camera and camera.CameraSubject

					if not cameraSubject then
						return result
					end

					if cameraSubject:IsA("Humanoid") then
						local humanoid = cameraSubject
						local humanoidIsDead = humanoid:GetState() == Enum.HumanoidStateType.Dead

						if (VRService.VREnabled and not FFlagUserFlagEnableNewVRSystem) and humanoidIsDead and humanoid == self.lastSubject then
							result = self.lastSubjectCFrame
						else
							local bodyPartToFollow = humanoid.RootPart

							-- If the humanoid is dead, prefer their head part as a follow target, if it exists
							if humanoidIsDead then
								if humanoid.Parent and humanoid.Parent:IsA("Model") then
									bodyPartToFollow = humanoid.Parent:FindFirstChild("Head") or bodyPartToFollow
								end
							end

							if bodyPartToFollow and bodyPartToFollow:IsA("BasePart") then
								local heightOffset
								if humanoid.RigType == Enum.HumanoidRigType.R15 then
									if humanoid.AutomaticScalingEnabled then
										heightOffset = R15_HEAD_OFFSET

										local rootPart = humanoid.RootPart
										if bodyPartToFollow == rootPart then
											local rootPartSizeOffset = (rootPart.Size.Y - HUMANOID_ROOT_PART_SIZE.Y)/2
											heightOffset = heightOffset + Vector3.new(0, rootPartSizeOffset, 0)
										end
									else
										heightOffset = R15_HEAD_OFFSET_NO_SCALING
									end
								else
									heightOffset = HEAD_OFFSET
								end

								if humanoidIsDead then
									heightOffset = ZERO_VECTOR3
								end

								result = bodyPartToFollow.CFrame*CFrame.new(heightOffset + humanoid.CameraOffset)
							end
						end

					elseif cameraSubject:IsA("BasePart") then
						result = cameraSubject.CFrame

					elseif cameraSubject:IsA("Model") then
						-- Model subjects are expected to have a PrimaryPart to determine orientation
						if cameraSubject.PrimaryPart then
							result = cameraSubject:GetPrimaryPartCFrame()
						else
							result = CFrame.new()
						end
					end

					if result then
						self.lastSubjectCFrame = result
					end

					return result
				end

				function BaseCamera:GetSubjectVelocity(): Vector3
					local camera = workspace.CurrentCamera
					local cameraSubject = camera and camera.CameraSubject

					if not cameraSubject then
						return ZERO_VECTOR3
					end

					if cameraSubject:IsA("BasePart") then
						return cameraSubject.Velocity

					elseif cameraSubject:IsA("Humanoid") then
						local rootPart = cameraSubject.RootPart

						if rootPart then
							return rootPart.Velocity
						end

					elseif cameraSubject:IsA("Model") then
						local primaryPart = cameraSubject.PrimaryPart

						if primaryPart then
							return primaryPart.Velocity
						end
					end

					return ZERO_VECTOR3
				end

				function BaseCamera:GetSubjectRotVelocity(): Vector3
					local camera = workspace.CurrentCamera
					local cameraSubject = camera and camera.CameraSubject

					if not cameraSubject then
						return ZERO_VECTOR3
					end

					if cameraSubject:IsA("BasePart") then
						return cameraSubject.RotVelocity

					elseif cameraSubject:IsA("Humanoid") then
						local rootPart = cameraSubject.RootPart

						if rootPart then
							return rootPart.RotVelocity
						end

					elseif cameraSubject:IsA("Model") then
						local primaryPart = cameraSubject.PrimaryPart

						if primaryPart then
							return primaryPart.RotVelocity
						end
					end

					return ZERO_VECTOR3
				end

				function BaseCamera:StepZoom(dt)
					local zoom: number = self.currentSubjectDistance
					local zoomDelta: number = CameraInput.getZoomDelta()

					--ZoomController.Update(dt or 0, CameraFocus)

					if math.abs(zoomDelta) > 0 then
						local newZoom

						if zoomDelta > 0 then
							newZoom = zoom + zoomDelta*(1 + zoom*ZOOM_SENSITIVITY_CURVATURE)
							newZoom = math.max(newZoom, self.FIRST_PERSON_DISTANCE_THRESHOLD)
						else
							newZoom = (zoom + zoomDelta)/(1 - zoomDelta*ZOOM_SENSITIVITY_CURVATURE)
							newZoom = math.max(newZoom, FIRST_PERSON_DISTANCE_MIN)
						end

						if newZoom < self.FIRST_PERSON_DISTANCE_THRESHOLD then
							newZoom = FIRST_PERSON_DISTANCE_MIN
						end


						self:SetCameraToSubjectDistance(newZoom)

						CameraInput.resetInputForFrameEnd()
					end

					return ZoomController.GetZoomRadius()
				end

				function BaseCamera:GetSubjectPosition(): Vector3
					local result = self.lastSubjectPosition
					if Focus then
						result = Focus.Position
					end
					local camera = game.Workspace.CurrentCamera
					local cameraSubject = camera and camera.CameraSubject

					if cameraSubject and not Focus then
						if cameraSubject:IsA("Humanoid") then
							local humanoid = cameraSubject
							local humanoidIsDead = humanoid:GetState() == Enum.HumanoidStateType.Dead

							if (VRService.VREnabled and not FFlagUserFlagEnableNewVRSystem) and humanoidIsDead and humanoid == self.lastSubject then
								result = self.lastSubjectPosition
							else
								local bodyPartToFollow = humanoid.RootPart

								-- If the humanoid is dead, prefer their head part as a follow target, if it exists
								if humanoidIsDead then
									if humanoid.Parent and humanoid.Parent:IsA("Model") then
										bodyPartToFollow = humanoid.Parent:FindFirstChild("Head") or bodyPartToFollow
									end
								end

								if bodyPartToFollow and bodyPartToFollow:IsA("BasePart") then
									local heightOffset
									if humanoid.RigType == Enum.HumanoidRigType.R15 then
										if humanoid.AutomaticScalingEnabled then
											heightOffset = R15_HEAD_OFFSET
											if bodyPartToFollow == humanoid.RootPart then
												local rootPartSizeOffset = (humanoid.RootPart.Size.Y/2) - (HUMANOID_ROOT_PART_SIZE.Y/2)
												heightOffset = heightOffset + Vector3.new(0, rootPartSizeOffset, 0)
											end
										else
											heightOffset = R15_HEAD_OFFSET_NO_SCALING
										end
									else
										heightOffset = HEAD_OFFSET
									end

									if humanoidIsDead then
										heightOffset = ZERO_VECTOR3
									end

									result = bodyPartToFollow.CFrame.p + bodyPartToFollow.CFrame:vectorToWorldSpace(heightOffset + humanoid.CameraOffset)
								end
							end

						elseif cameraSubject:IsA("VehicleSeat") then
							local offset = SEAT_OFFSET
							if VRService.VREnabled and not FFlagUserFlagEnableNewVRSystem then
								offset = VR_SEAT_OFFSET
							end
							result = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(offset)
						elseif cameraSubject:IsA("SkateboardPlatform") then
							result = cameraSubject.CFrame.p + SEAT_OFFSET
						elseif cameraSubject:IsA("BasePart") then
							result = cameraSubject.CFrame.p
						elseif cameraSubject:IsA("Model") then
							if cameraSubject.PrimaryPart then
								result = cameraSubject:GetPrimaryPartCFrame().p
							else
								result = cameraSubject:GetModelCFrame().p
							end
						end
					elseif not Focus then
						-- cameraSubject is nil
						-- Note: Previous RootCamera did not have this else case and let self.lastSubject and self.lastSubjectPosition
						-- both get set to nil in the case of cameraSubject being nil. This function now exits here to preserve the
						-- last set valid values for these, as nil values are not handled cases
						return
					end

					self.lastSubject = cameraSubject
					self.lastSubjectPosition = result

					return result
				end

				function BaseCamera:UpdateDefaultSubjectDistance()
					if self.portraitMode then
						self.defaultSubjectDistance = math.clamp(PORTRAIT_DEFAULT_DISTANCE, 0.5, 100000)
					else
						self.defaultSubjectDistance = math.clamp(DEFAULT_DISTANCE, 0.5, 100000)
					end
				end

				function BaseCamera:OnViewportSizeChanged()
					local camera = game.Workspace.CurrentCamera
					local size = camera.ViewportSize
					self.portraitMode = size.X < size.Y
					self.isSmallTouchScreen = UserInputService.TouchEnabled and (size.Y < 500 or size.X < 700)

					self:UpdateDefaultSubjectDistance()
				end

				-- Listener for changes to workspace.CurrentCamera
				function BaseCamera:OnCurrentCameraChanged()
					if UserInputService.TouchEnabled then
						if self.viewportSizeChangedConn then
							self.viewportSizeChangedConn:Disconnect()
							self.viewportSizeChangedConn = nil
						end

						local newCamera = game.Workspace.CurrentCamera

						if newCamera then
							self:OnViewportSizeChanged()
							self.viewportSizeChangedConn = newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
								self:OnViewportSizeChanged()
							end)
						end
					end

					-- VR support additions
					if self.cameraSubjectChangedConn then
						self.cameraSubjectChangedConn:Disconnect()
						self.cameraSubjectChangedConn = nil
					end

					--local camera = game.Workspace.CurrentCamera
					--if camera then
					--	self.cameraSubjectChangedConn = camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
					--		self:OnNewCameraSubject()
					--	end)
					--	self:OnNewCameraSubject()
					--end
				end

				function BaseCamera:OnDynamicThumbstickEnabled()
					if UserInputService.TouchEnabled then
						self.isDynamicThumbstickEnabled = true
					end
				end

				function BaseCamera:OnDynamicThumbstickDisabled()
					self.isDynamicThumbstickEnabled = false
				end

				function BaseCamera:OnGameSettingsTouchMovementModeChanged()
					if player.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
						if (UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.DynamicThumbstick
							or UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.Default) then
							self:OnDynamicThumbstickEnabled()
						else
							self:OnDynamicThumbstickDisabled()
						end
					end
				end

				function BaseCamera:OnDevTouchMovementModeChanged()
					if player.DevTouchMovementMode == Enum.DevTouchMovementMode.DynamicThumbstick then
						self:OnDynamicThumbstickEnabled()
					else
						self:OnGameSettingsTouchMovementModeChanged()
					end
				end

				function BaseCamera:OnPlayerCameraPropertyChange()
					-- This call forces re-evaluation of player.CameraMode and clamping to min/max distance which may have changed
					self:SetCameraToSubjectDistance(self.currentSubjectDistance)
				end

				function BaseCamera:InputTranslationToCameraAngleChange(translationVector, sensitivity)
					return translationVector * sensitivity
				end

				function BaseCamera:GamepadZoomPress()
					local dist = self:GetCameraToSubjectDistance()

					if dist > (GAMEPAD_ZOOM_STEP_2 + GAMEPAD_ZOOM_STEP_3)/2 then
						self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_2)
					elseif dist > (GAMEPAD_ZOOM_STEP_1 + GAMEPAD_ZOOM_STEP_2)/2 then
						self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_1)
					else
						self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_3)
					end
				end

				function BaseCamera:Enable(enable: boolean)
					if self.enabled ~= enable then
						self.enabled = enable
						if self.enabled then
							CameraInput.setInputEnabled(true)

							self.gamepadZoomPressConnection = CameraInput.gamepadZoomPress:Connect(function()
								self:GamepadZoomPress()
							end)

							if player.CameraMode == Enum.CameraMode.LockFirstPerson then
								self.currentSubjectDistance = 0.5
								if not self.inFirstPerson then
									self:EnterFirstPerson()
								end
							end
						else
							CameraInput.setInputEnabled(false)

							if self.gamepadZoomPressConnection then
								self.gamepadZoomPressConnection:Disconnect()
								self.gamepadZoomPressConnection = nil
							end
							-- Clean up additional event listeners and reset a bunch of properties
							self:Cleanup()
						end

						self:OnEnable(enable)
					end
				end

				function BaseCamera:OnEnable(enable: boolean)
					-- for derived camera
				end

				function BaseCamera:GetEnabled(): boolean
					return self.enabled
				end

				function BaseCamera:Cleanup()
					if self.subjectStateChangedConn then
						self.subjectStateChangedConn:Disconnect()
						self.subjectStateChangedConn = nil
					end
					if self.viewportSizeChangedConn then
						self.viewportSizeChangedConn:Disconnect()
						self.viewportSizeChangedConn = nil
					end

					self.lastCameraTransform = nil
					self.lastSubjectCFrame = nil

					-- Unlock mouse for example if right mouse button was being held down
					if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
						UserInputService.MouseBehavior = Enum.MouseBehavior.Default
					end
				end

				function BaseCamera:UpdateMouseBehavior()
					local blockToggleDueToClickToMove = UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove

					if self.isCameraToggle and blockToggleDueToClickToMove == false then
						CameraUI.setCameraModeToastEnabled(true)
						CameraInput.enableCameraToggleInput()
						CameraToggleStateController(self.inFirstPerson)
					else
						CameraUI.setCameraModeToastEnabled(false)
						CameraInput.disableCameraToggleInput()

						-- first time transition to first person mode or mouse-locked third person
						if self.inFirstPerson or self.inMouseLockedMode then
							UserGameSettings.RotationType = Enum.RotationType.CameraRelative
							UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
						else
							UserGameSettings.RotationType = Enum.RotationType.MovementRelative
							UserInputService.MouseBehavior = Enum.MouseBehavior.Default
						end
					end
				end

				function BaseCamera:UpdateForDistancePropertyChange()
					-- Calling this setter with the current value will force checking that it is still
					-- in range after a change to the min/max distance limits
					self:SetCameraToSubjectDistance(self.currentSubjectDistance)
				end

				function BaseCamera:SetCameraToSubjectDistance(desiredSubjectDistance: number, dt: number): number
					local lastSubjectDistance = self.currentSubjectDistance

					-- By default, camera modules will respect LockFirstPerson and override the currentSubjectDistance with 0
					-- regardless of what Player.CameraMinZoomDistance is set to, so that first person can be made
					-- available by the developer without needing to allow players to mousewheel dolly into first person.
					-- Some modules will override this function to remove or change first-person capability.
					if player.CameraMode == Enum.CameraMode.LockFirstPerson then
						self.currentSubjectDistance = 0.5
						if not self.inFirstPerson then
							self:EnterFirstPerson()
						end
					else
						local newSubjectDistance = math.clamp(desiredSubjectDistance, player.CameraMinZoomDistance, player.CameraMaxZoomDistance)
						if newSubjectDistance < FIRST_PERSON_DISTANCE_THRESHOLD then
							self.currentSubjectDistance = 0.5
							if not self.inFirstPerson then
								self:EnterFirstPerson()
							end
						else
							self.currentSubjectDistance = newSubjectDistance
							if self.inFirstPerson then
								self:LeaveFirstPerson()
							end
						end
					end

					-- Pass target distance and zoom direction to the zoom controller
					ZoomController.SetZoomParameters(self.currentSubjectDistance, math.sign(desiredSubjectDistance - lastSubjectDistance))

					-- Returned only for convenience to the caller to know the outcome
					return self.currentSubjectDistance
				end

				function BaseCamera:SetCameraType( cameraType )
					--Used by derived classes
					self.cameraType = cameraType
				end

				function BaseCamera:GetCameraType()
					return self.cameraType
				end

				-- Movement mode standardized to Enum.ComputerCameraMovementMode values
				function BaseCamera:SetCameraMovementMode( cameraMovementMode )
					self.cameraMovementMode = cameraMovementMode
				end

				function BaseCamera:GetCameraMovementMode()
					return self.cameraMovementMode
				end

				function BaseCamera:SetIsMouseLocked(mouseLocked: boolean)
					self.inMouseLockedMode = mouseLocked
				end

				function BaseCamera:GetIsMouseLocked(): boolean
					return self.inMouseLockedMode
				end

				function BaseCamera:SetMouseLockOffset(offsetVector)
					self.mouseLockOffset = offsetVector
				end

				function BaseCamera:GetMouseLockOffset()
					return self.mouseLockOffset
				end

				function BaseCamera:InFirstPerson(): boolean
					return self.inFirstPerson
				end

				function BaseCamera:EnterFirstPerson()
					-- Overridden in ClassicCamera, the only module which supports FirstPerson
				end

				function BaseCamera:LeaveFirstPerson()
					-- Overridden in ClassicCamera, the only module which supports FirstPerson
				end

				-- Nominal distance, set by dollying in and out with the mouse wheel or equivalent, not measured distance
				function BaseCamera:GetCameraToSubjectDistance(): number
					return self.currentSubjectDistance
				end

				-- Actual measured distance to the camera Focus point, which may be needed in special circumstances, but should
				-- never be used as the starting point for updating the nominal camera-to-subject distance (self.currentSubjectDistance)
				-- since that is a desired target value set only by mouse wheel (or equivalent) input, PopperCam, and clamped to min max camera distance
				function BaseCamera:GetMeasuredDistanceToFocus(): number?
					--local camera = game.Workspace.CurrentCamera
					--if camera then
					return (CameraCFrame.p - CameraFocus.p).magnitude
					--end
					--return nil
				end

				function BaseCamera:GetCameraLookVector(): Vector3
					return CameraCFrame.lookVector or UNIT_Z
					--return game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame.lookVector or UNIT_Z
				end

				function BaseCamera:CalculateNewLookCFrameFromArg(suppliedLookVector: Vector3?, rotateInput: Vector2): CFrame
					local currLookVector: Vector3 = suppliedLookVector or self:GetCameraLookVector()
					local currPitchAngle = math.asin(currLookVector.y)
					local yTheta = math.clamp(rotateInput.y, -MAX_Y + currPitchAngle, -MIN_Y + currPitchAngle)
					local constrainedRotateInput = Vector2.new(rotateInput.x, yTheta)
					local startCFrame = CFrame.new(ZERO_VECTOR3, currLookVector)
					local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.x, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.y,0,0)
					return newLookCFrame
				end

				function BaseCamera:CalculateNewLookVectorFromArg(suppliedLookVector: Vector3?, rotateInput: Vector2): Vector3
					local newLookCFrame = self:CalculateNewLookCFrameFromArg(suppliedLookVector, rotateInput)
					return newLookCFrame.lookVector
				end

				function BaseCamera:CalculateNewLookVectorVRFromArg(rotateInput: Vector2): Vector3
					local subjectPosition: Vector3 = self:GetSubjectPosition()
					local vecToSubject: Vector3 = (subjectPosition - CameraCFrame.p)
					local currLookVector: Vector3 = (vecToSubject * X1_Y0_Z1).unit
					local vrRotateInput: Vector2 = Vector2.new(rotateInput.x, 0)
					local startCFrame: CFrame = CFrame.new(ZERO_VECTOR3, currLookVector)
					local yawRotatedVector: Vector3 = (CFrame.Angles(0, -vrRotateInput.x, 0) * startCFrame * CFrame.Angles(-vrRotateInput.y,0,0)).lookVector
					return (yawRotatedVector * X1_Y0_Z1).unit
				end

				function BaseCamera:GetHumanoid(): Humanoid?
					local character = player and player.Character
					if character then
						local resultHumanoid = self.humanoidCache[player]
						if resultHumanoid and resultHumanoid.Parent == character then
							return resultHumanoid
						else
							self.humanoidCache[player] = nil -- Bust Old Cache
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								self.humanoidCache[player] = humanoid
							end
							return humanoid
						end
					end
					return nil
				end

				function BaseCamera:GetHumanoidPartToFollow(humanoid: Humanoid, humanoidStateType: Enum.HumanoidStateType) -- BasePart
					if humanoidStateType == Enum.HumanoidStateType.Dead then
						local character = humanoid.Parent
						if character then
							return character:FindFirstChild("Head") or humanoid.Torso
						else
							return humanoid.Torso
						end
					else
						return humanoid.Torso
					end
				end


				function BaseCamera:OnNewCameraSubject()
					if self.subjectStateChangedConn then
						self.subjectStateChangedConn:Disconnect()
						self.subjectStateChangedConn = nil
					end

					if not FFlagUserFlagEnableNewVRSystem then
						local humanoid = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject
						if self.trackingHumanoid ~= humanoid then
							self:CancelCameraFreeze()
						end

						if humanoid and humanoid:IsA("Humanoid") then
							self.subjectStateChangedConn = humanoid.StateChanged:Connect(function(oldState, newState)
								if VRService.VREnabled and newState == Enum.HumanoidStateType.Jumping and not self.inFirstPerson then
									self:StartCameraFreeze(self:GetSubjectPosition(), humanoid)
								elseif newState ~= Enum.HumanoidStateType.Jumping and newState ~= Enum.HumanoidStateType.Freefall then
									self:CancelCameraFreeze(true)
								end
							end)
						end
					end
				end

				function BaseCamera:IsInFirstPerson()
					return self.inFirstPerson
				end

				function BaseCamera:Update(dt)
					error("BaseCamera:Update() This is a virtual function that should never be getting called.", 2)
				end

				-- [[ VR Support Section ]] --
				function BaseCamera:GetCameraHeight()
					if VRService.VREnabled and not self.inFirstPerson then
						return math.sin(VR_ANGLE) * self.currentSubjectDistance
					end
					return 0
				end

				-- these are support functions for the "old VR code"
				if not FFlagUserFlagEnableNewVRSystem then
					function BaseCamera:CancelCameraFreeze(keepConstraints: boolean)
						if not keepConstraints then
							self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, 1, self.cameraTranslationConstraints.z)
						end
						if self.cameraFrozen then
							self.trackingHumanoid = nil
							self.cameraFrozen = false
						end
					end

					function BaseCamera:StartCameraFreeze(subjectPosition: Vector3, humanoidToTrack: Humanoid)
						if not self.cameraFrozen then
							self.humanoidJumpOrigin = subjectPosition
							self.trackingHumanoid = humanoidToTrack
							self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, 0, self.cameraTranslationConstraints.z)
							self.cameraFrozen = true
						end
					end

					function BaseCamera:ApplyVRTransform()
						if not VRService.VREnabled then
							return
						end

						--we only want this to happen in first person VR
						local rootJoint = self.humanoidRootPart and self.humanoidRootPart:FindFirstChild("RootJoint")
						if not rootJoint then
							return
						end

						local cameraSubject = game.Workspace.CurrentCamera.CameraSubject
						local isInVehicle = cameraSubject and cameraSubject:IsA("VehicleSeat")

						if self.inFirstPerson and not isInVehicle then
							local vrFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
							local vrRotation = vrFrame - vrFrame.p
							rootJoint.C0 = CFrame.new(vrRotation:vectorToObjectSpace(vrFrame.p)) * CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
						else
							rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
						end
					end


					function BaseCamera:ShouldUseVRRotation()
						if not VRService.VREnabled then
							return false
						end

						if not self.VRRotationIntensityAvailable and tick() - self.lastVRRotationIntensityCheckTime < 1 then
							return false
						end

						local success, vrRotationIntensity = pcall(function() return StarterGui:GetCore("VRRotationIntensity") end)
						self.VRRotationIntensityAvailable = success and vrRotationIntensity ~= nil
						self.lastVRRotationIntensityCheckTime = tick()

						self.shouldUseVRRotation = success and vrRotationIntensity ~= nil and vrRotationIntensity ~= "Smooth"

						return self.shouldUseVRRotation
					end

					function BaseCamera:GetVRRotationInput()
						local vrRotateSum = ZERO_VECTOR2
						local success, vrRotationIntensity = pcall(function() return StarterGui:GetCore("VRRotationIntensity") end)

						if not success then
							return
						end

						local vrGamepadRotation = ZERO_VECTOR2
						local delayExpired = (tick() - self.lastVRRotationTime) >= self:GetRepeatDelayValue(vrRotationIntensity)

						if math.abs(vrGamepadRotation.x) >= self:GetActivateValue() then
							if (delayExpired or not self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2]) then
								local sign = 1
								if vrGamepadRotation.x < 0 then
									sign = -1
								end
								vrRotateSum = vrRotateSum + self:GetRotateAmountValue(vrRotationIntensity) * sign
								self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = true
							end
						elseif math.abs(vrGamepadRotation.x) < self:GetActivateValue() - 0.1 then
							self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = nil
						end

						self.vrRotateKeyCooldown[Enum.KeyCode.Left] = nil
						self.vrRotateKeyCooldown[Enum.KeyCode.Right] = nil

						if vrRotateSum ~= ZERO_VECTOR2 then
							self.lastVRRotationTime = tick()
						end

						return vrRotateSum
					end


					function BaseCamera:GetVRFocus(subjectPosition, timeDelta)
						local lastFocus = self.LastCameraFocus or subjectPosition
						if not self.cameraFrozen then
							self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, math.min(1, self.cameraTranslationConstraints.y + 0.42 * timeDelta), self.cameraTranslationConstraints.z)
						end

						local newFocus
						if self.cameraFrozen and self.humanoidJumpOrigin and self.humanoidJumpOrigin.y > lastFocus.y then
							newFocus = CFrame.new(Vector3.new(subjectPosition.x, math.min(self.humanoidJumpOrigin.y, lastFocus.y + 5 * timeDelta), subjectPosition.z))
						else
							newFocus = CFrame.new(Vector3.new(subjectPosition.x, lastFocus.y, subjectPosition.z):lerp(subjectPosition, self.cameraTranslationConstraints.y))
						end

						if self.cameraFrozen then
							-- No longer in 3rd person
							if self.inFirstPerson then -- not VRService.VREnabled
								self:CancelCameraFreeze()
							end
							-- This case you jumped off a cliff and want to keep your character in view
							-- 0.5 is to fix floating point error when not jumping off cliffs
							if self.humanoidJumpOrigin and subjectPosition.y < (self.humanoidJumpOrigin.y - 0.5) then
								self:CancelCameraFreeze()
							end
						end

						return newFocus
					end

					function BaseCamera:GetRotateAmountValue(vrRotationIntensity: string?)
						vrRotationIntensity = vrRotationIntensity or StarterGui:GetCore("VRRotationIntensity")
						if vrRotationIntensity then
							if vrRotationIntensity == "Low" then
								return VR_LOW_INTENSITY_ROTATION
							elseif vrRotationIntensity == "High" then
								return VR_HIGH_INTENSITY_ROTATION
							end
						end
						return ZERO_VECTOR2
					end

					function BaseCamera:GetRepeatDelayValue(vrRotationIntensity: string?)
						vrRotationIntensity = vrRotationIntensity or StarterGui:GetCore("VRRotationIntensity")
						if vrRotationIntensity then
							if vrRotationIntensity == "Low" then
								return VR_LOW_INTENSITY_REPEAT
							elseif vrRotationIntensity == "High" then
								return VR_HIGH_INTENSITY_REPEAT
							end
						end
						return 0
					end
				end

				-- [[ End VR Support Section ]] --

				return BaseCamera

			end
			local function MouseLockController()
				--[[
	MouseLockController - Replacement for ShiftLockController, manages use of mouse-locked mode
	2018 Camera Update - AllYourBlox
--]]

				--[[ Constants ]]--
				local DEFAULT_MOUSE_LOCK_CURSOR = "rbxasset://textures/MouseLockedCursor.png"

				local CONTEXT_ACTION_NAME = "MouseLockSwitchAction"
				local MOUSELOCK_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

				--[[ Services ]]--
				local PlayersService = game:GetService("Players")
				local ContextActionService = game:GetService("ContextActionService")
				local Settings = UserSettings()	-- ignore warning
				local GameSettings = Settings.GameSettings
				local Mouse = PlayersService.LocalPlayer:GetMouse()

				--[[ The Module ]]--
				local MouseLockController = {}
				MouseLockController.__index = MouseLockController

				function MouseLockController.new()
					local self = setmetatable({}, MouseLockController)

					self.isMouseLocked = false
					self.savedMouseCursor = nil
					self.boundKeys = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift} -- defaults

					self.mouseLockToggledEvent = Instance.new("BindableEvent")

					local boundKeysObj: StringValue = script:FindFirstChild("BoundKeys") :: StringValue
					if (not boundKeysObj) or (not boundKeysObj:IsA("StringValue")) then
						-- If object with correct name was found, but it's not a StringValue, destroy and replace
						if boundKeysObj then
							boundKeysObj:Destroy()
						end

						boundKeysObj = Instance.new("StringValue")
						boundKeysObj.Name = "BoundKeys"
						boundKeysObj.Value = "LeftShift,RightShift"
						--boundKeysObj.Parent = script
					end

					if boundKeysObj then
						boundKeysObj.Changed:Connect(function(value)
							self:OnBoundKeysObjectChanged(value)
						end)
						self:OnBoundKeysObjectChanged(boundKeysObj.Value) -- Initial setup call
					end

					-- Watch for changes to user's ControlMode and ComputerMovementMode settings and update the feature availability accordingly
					GameSettings.Changed:Connect(function(property)
						if property == "ControlMode" or property == "ComputerMovementMode" then
							self:UpdateMouseLockAvailability()
						end
					end)

					-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
					PlayersService.LocalPlayer:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(function()
						self:UpdateMouseLockAvailability()
					end)

					-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
					PlayersService.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
						self:UpdateMouseLockAvailability()
					end)

					self:UpdateMouseLockAvailability()

					return self
				end

				function MouseLockController:GetIsMouseLocked()
					return self.isMouseLocked
				end

				function MouseLockController:GetBindableToggleEvent()
					return self.mouseLockToggledEvent.Event
				end

				function MouseLockController:GetMouseLockOffset()
					local offsetValueObj: Vector3Value = script:FindFirstChild("CameraOffset") :: Vector3Value
					if offsetValueObj and offsetValueObj:IsA("Vector3Value") then
						return offsetValueObj.Value
					else
						-- If CameraOffset object was found but not correct type, destroy
						if offsetValueObj then
							offsetValueObj:Destroy()
						end
						offsetValueObj = Instance.new("Vector3Value")
						offsetValueObj.Name = "CameraOffset"
						offsetValueObj.Value = Vector3.new(1.75,0,0) -- Legacy Default Value
						offsetValueObj.Parent = script
					end

					if offsetValueObj and offsetValueObj.Value then
						return offsetValueObj.Value
					end

					return Vector3.new(1.75,0,0)
				end

				function MouseLockController:UpdateMouseLockAvailability()
					local devAllowsMouseLock = true--PlayersService.LocalPlayer.DevEnableMouseLock
					local devMovementModeIsScriptable = true--PlayersService.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
					local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
					local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
					local MouseLockAvailable = true--devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable

					if MouseLockAvailable~=self.enabled then
						self:EnableMouseLock(MouseLockAvailable)
					end
				end

				function MouseLockController:OnBoundKeysObjectChanged(newValue: string)
					self.boundKeys = {} -- Overriding defaults, note: possibly with nothing at all if boundKeysObj.Value is "" or contains invalid values
					for token in string.gmatch(newValue,"[^%s,]+") do
						for _, keyEnum in pairs(Enum.KeyCode:GetEnumItems()) do
							if token == keyEnum.Name then
								self.boundKeys[#self.boundKeys+1] = keyEnum :: Enum.KeyCode
								break
							end
						end
					end
					self:UnbindContextActions()
					self:BindContextActions()
				end

				--[[ Local Functions ]]--
				function MouseLockController:OnMouseLockToggled()
					self.isMouseLocked = not self.isMouseLocked

					if self.isMouseLocked then
						local cursorImageValueObj: StringValue = script:FindFirstChild("CursorImage") :: StringValue
						if cursorImageValueObj and cursorImageValueObj:IsA("StringValue") and cursorImageValueObj.Value then
							self.savedMouseCursor = Mouse.Icon
							Mouse.Icon = cursorImageValueObj.Value
						else
							if cursorImageValueObj then
								cursorImageValueObj:Destroy()
							end
							cursorImageValueObj = Instance.new("StringValue")
							cursorImageValueObj.Name = "CursorImage"
							cursorImageValueObj.Value = DEFAULT_MOUSE_LOCK_CURSOR
							cursorImageValueObj.Parent = script
							self.savedMouseCursor = Mouse.Icon
							Mouse.Icon = DEFAULT_MOUSE_LOCK_CURSOR
						end
					else
						if self.savedMouseCursor then
							Mouse.Icon = self.savedMouseCursor
							self.savedMouseCursor = nil
						end
					end

					self.mouseLockToggledEvent:Fire()
				end

				function MouseLockController:DoMouseLockSwitch(name, state, input)
					if state == Enum.UserInputState.Begin then
						self:OnMouseLockToggled()
						return Enum.ContextActionResult.Sink
					end
					return Enum.ContextActionResult.Pass
				end

				function MouseLockController:BindContextActions()
					ContextActionService:BindActionAtPriority(CONTEXT_ACTION_NAME, function(name, state, input)
						return self:DoMouseLockSwitch(name, state, input)
					end, false, MOUSELOCK_ACTION_PRIORITY, unpack(self.boundKeys))
				end

				function MouseLockController:UnbindContextActions()
					ContextActionService:UnbindAction(CONTEXT_ACTION_NAME)
				end

				function MouseLockController:IsMouseLocked(): boolean
					return self.enabled and self.isMouseLocked
				end

				function MouseLockController:EnableMouseLock(enable: boolean)
					if enable ~= self.enabled then

						self.enabled = enable

						if self.enabled then
							-- Enabling the mode
							self:BindContextActions()
						else
							-- Disabling
							-- Restore mouse cursor
							if Mouse.Icon~="" then
								Mouse.Icon = ""
							end

							self:UnbindContextActions()

							-- If the mode is disabled while being used, fire the event to toggle it off
							if self.isMouseLocked then
								self.mouseLockToggledEvent:Fire()
							end

							self.isMouseLocked = false
						end

					end
				end

				return MouseLockController

			end
			--[[
	ClassicCamera - Classic Roblox camera control module
	2018 Camera Update - AllYourBlox

	Note: This module also handles camera control types Follow and Track, the
	latter of which is currently not distinguished from Classic
--]]

			-- Local private variables and constants
			local ZERO_VECTOR2 = Vector2.new(0,0)

			local tweenAcceleration = math.rad(220) -- Radians/Second^2
			local tweenSpeed = math.rad(0)          -- Radians/Second
			local tweenMaxSpeed = math.rad(250)     -- Radians/Second
			local TIME_BEFORE_AUTO_ROTATE = 2       -- Seconds, used when auto-aligning camera with vehicles

			local INITIAL_CAMERA_ANGLE = CFrame.fromOrientation(math.rad(-15), 0, 0)
			local ZOOM_SENSITIVITY_CURVATURE = 0.5
			local FIRST_PERSON_DISTANCE_MIN = 0.5

			--[[ Services ]]--
			local PlayersService = game:GetService("Players")
			local VRService = game:GetService("VRService")

			local CameraInput = CameraInput()
			--local Poppercam = Poppercam().new()
			--Poppercam:Enable(true)
			local Util = CameraUtils()

			--[[ The Module ]]--
			local BaseCamera = BaseCamera()
			local MouseLockController = MouseLockController().new()
			ClassicCamera = setmetatable({}, BaseCamera)
			ClassicCamera.__index = ClassicCamera

			function ClassicCamera.new()
				local self = setmetatable(BaseCamera.new(), ClassicCamera)

				self.GetIsMouseLocked = MouseLockController.GetIsMouseLocked
				self.GetMouseLockOffset = MouseLockController.GetMouseLockOffset

				self.isFollowCamera = false
				self.isCameraToggle = false
				self.lastUpdate = tick()
				self.cameraToggleSpring = Util.Spring.new(5, 0)

				return self
			end

			function ClassicCamera:GetCameraToggleOffset(dt: number)
				if self.isCameraToggle then
					local zoom = self.currentSubjectDistance

					if CameraInput.getTogglePan() then
						self.cameraToggleSpring.goal = math.clamp(Util.map(zoom, 0.5, self.FIRST_PERSON_DISTANCE_THRESHOLD, 0, 1), 0, 1)
					else
						self.cameraToggleSpring.goal = 0
					end

					local distanceOffset: number = math.clamp(Util.map(zoom, 0.5, 50000, 0, 1), 0, 1) + 1
					return Vector3.new(0, self.cameraToggleSpring:step(dt)*distanceOffset, 0)
				end

				return Vector3.new()
			end

			-- Movement mode standardized to Enum.ComputerCameraMovementMode values
			function ClassicCamera:SetCameraMovementMode(cameraMovementMode: Enum.ComputerCameraMovementMode)
				BaseCamera.SetCameraMovementMode(self, cameraMovementMode)

				self.isFollowCamera = cameraMovementMode == Enum.ComputerCameraMovementMode.Follow
				self.isCameraToggle = cameraMovementMode == Enum.ComputerCameraMovementMode.CameraToggle
			end
			function ClassicCamera:UpdatePoppercam(dt, desiredCameraCFrame, desiredCameraFocus, cameraController)
				return self.poppercam:Update(dt, desiredCameraCFrame, desiredCameraFocus, cameraController)
			end
			function ClassicCamera:Update()
				local now = tick()
				local timeDelta = now - self.lastUpdate

				local camera = workspace.CurrentCamera
				local newCameraCFrame = CameraCFrame
				local newCameraFocus = CameraFocus

				local overrideCameraLookVector = nil
				if self.resetCameraAngle then
					local rootPart: BasePart = self:GetHumanoidRootPart()
					if rootPart then
						overrideCameraLookVector = (rootPart.CFrame * INITIAL_CAMERA_ANGLE).lookVector
					else
						overrideCameraLookVector = INITIAL_CAMERA_ANGLE.lookVector
					end
					self.resetCameraAngle = false
				end

				local player = PlayersService.LocalPlayer
				local humanoid = self:GetHumanoid()
				--local cameraSubject = camera.CameraSubject
				--local isInVehicle = cameraSubject and cameraSubject:IsA("VehicleSeat")
				--local isOnASkateboard = cameraSubject and cameraSubject:IsA("SkateboardPlatform")
				--local isClimbing = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing

				if self.lastUpdate == nil or timeDelta > 1 then
					self.lastCameraTransform = nil
				end

				local rotateInput = CameraInput.getRotation()

				self:StepZoom()

				local cameraHeight = self:GetCameraHeight()

				-- Reset tween speed if user is panning
				if CameraInput.getRotation() ~= Vector2.new() then
					tweenSpeed = 0
					self.lastUserPanCamera = tick()
				end

				local userRecentlyPannedCamera = now - self.lastUserPanCamera < TIME_BEFORE_AUTO_ROTATE
				local subjectPosition: Vector3 = self:GetSubjectPosition()

				if subjectPosition and player then
					local zoom = self:GetCameraToSubjectDistance()
					if zoom < 0.5 then
						zoom = 0.5
					end

					if self:GetIsMouseLocked() and not self:IsInFirstPerson() then
						-- We need to use the right vector of the camera after rotation, not before
						local newLookCFrame: CFrame = self:CalculateNewLookCFrameFromArg(overrideCameraLookVector, rotateInput)

						local offset: Vector3 = self:GetMouseLockOffset()
						local cameraRelativeOffset: Vector3 = offset.X * newLookCFrame.rightVector + offset.Y * newLookCFrame.upVector + offset.Z * newLookCFrame.lookVector

						--offset can be NAN, NAN, NAN if newLookVector has only y component
						if Util.IsFiniteVector3(cameraRelativeOffset) then
							subjectPosition = subjectPosition + cameraRelativeOffset
						end
					else
						local userPanningTheCamera = CameraInput.getRotation() ~= Vector2.new()

						if not userPanningTheCamera and self.lastCameraTransform then

							local isInFirstPerson = self:IsInFirstPerson()

							--if (isInVehicle or isOnASkateboard or (self.isFollowCamera and isClimbing)) and self.lastUpdate and humanoid and humanoid.Torso then
							--	if isInFirstPerson then
							--		if self.lastSubjectCFrame and (isInVehicle or isOnASkateboard) and cameraSubject:IsA("BasePart") then
							--			local y = -Util.GetAngleBetweenXZVectors(self.lastSubjectCFrame.lookVector, cameraSubject.CFrame.lookVector)
							--			if Util.IsFinite(y) then
							--				rotateInput = rotateInput + Vector2.new(y, 0)
							--			end
							--			tweenSpeed = 0
							--		end
							--	elseif not userRecentlyPannedCamera then
							--		local forwardVector = humanoid.Torso.CFrame.lookVector
							--		tweenSpeed = math.clamp(tweenSpeed + tweenAcceleration * timeDelta, 0, tweenMaxSpeed)

							--		local percent = math.clamp(tweenSpeed * timeDelta, 0, 1)
							--		if self:IsInFirstPerson() and not (self.isFollowCamera and self.isClimbing) then
							--			percent = 1
							--		end

							--		local y = Util.GetAngleBetweenXZVectors(forwardVector, self:GetCameraLookVector())
							--		if Util.IsFinite(y) and math.abs(y) > 0.0001 then
							--			rotateInput = rotateInput + Vector2.new(y * percent, 0)
							--		end
							--	end

							--[[else]]if self.isFollowCamera and (not (isInFirstPerson or userRecentlyPannedCamera) and not VRService.VREnabled) then
								-- Logic that was unique to the old FollowCamera module
								local lastVec = -(self.lastCameraTransform.p - subjectPosition)

								local y = Util.GetAngleBetweenXZVectors(lastVec, self:GetCameraLookVector())

								-- This cutoff is to decide if the humanoid's angle of movement,
								-- relative to the camera's look vector, is enough that
								-- we want the camera to be following them. The point is to provide
								-- a sizable dead zone to allow more precise forward movements.
								local thetaCutoff = 0.4

								-- Check for NaNs
								if Util.IsFinite(y) and math.abs(y) > 0.0001 and math.abs(y) > thetaCutoff * timeDelta then
									rotateInput = rotateInput + Vector2.new(y, 0)
								end
							end
						end
					end

					if not self.isFollowCamera then
						local VREnabled = VRService.VREnabled

						if VREnabled then
							newCameraFocus = self:GetVRFocus(subjectPosition, timeDelta)
						else
							newCameraFocus = CFrame.new(subjectPosition)
						end

						local cameraFocusP = newCameraFocus.p
						if VREnabled and not self:IsInFirstPerson() then
							local vecToSubject = (subjectPosition - CameraCFrame.p)
							local distToSubject = vecToSubject.magnitude

							local flaggedRotateInput = rotateInput

							-- Only move the camera if it exceeded a maximum distance to the subject in VR
							if distToSubject > zoom or flaggedRotateInput.x ~= 0 then
								local desiredDist = math.min(distToSubject, zoom)
								vecToSubject = self:CalculateNewLookVectorFromArg(nil, rotateInput) * desiredDist
								local newPos = cameraFocusP - vecToSubject
								local desiredLookDir = CameraCFrame.lookVector
								if flaggedRotateInput.x ~= 0 then
									desiredLookDir = vecToSubject
								end
								local lookAt = Vector3.new(newPos.x + desiredLookDir.x, newPos.y, newPos.z + desiredLookDir.z)

								newCameraCFrame = CFrame.new(newPos, lookAt) + Vector3.new(0, cameraHeight, 0)
							end
						else
							local newLookVector = self:CalculateNewLookVectorFromArg(overrideCameraLookVector, rotateInput)
							newCameraCFrame = CFrame.new(cameraFocusP - (zoom * newLookVector), cameraFocusP)
						end
					else -- is FollowCamera
						local newLookVector = self:CalculateNewLookVectorFromArg(overrideCameraLookVector, rotateInput)

						if VRService.VREnabled then
							newCameraFocus = self:GetVRFocus(subjectPosition, timeDelta)
						else
							newCameraFocus = CFrame.new(subjectPosition)
						end
						newCameraCFrame = CFrame.new(newCameraFocus.p - (zoom * newLookVector), newCameraFocus.p) + Vector3.new(0, cameraHeight, 0)
					end

					local toggleOffset = self:GetCameraToggleOffset(timeDelta)
					newCameraFocus = newCameraFocus + toggleOffset
					newCameraCFrame = newCameraCFrame + toggleOffset

					local poppercamOffset = self:UpdatePoppercam(timeDelta, newCameraCFrame, newCameraFocus)

					newCameraCFrame = poppercamOffset

					self.lastCameraTransform = newCameraCFrame
					self.lastCameraFocus = newCameraFocus
					--if (isInVehicle or isOnASkateboard) and cameraSubject:IsA("BasePart") then
					--	self.lastSubjectCFrame = cameraSubject.CFrame
					--else
					--	self.lastSubjectCFrame = nil
					--end
					CameraInput.resetInputForFrameEnd()
				end

				self.lastUpdate = now
				return newCameraCFrame, newCameraFocus
			end

			function ClassicCamera:EnterFirstPerson()
				self.inFirstPerson = true
				self:UpdateMouseBehavior()
			end

			function ClassicCamera:LeaveFirstPerson()
				self.inFirstPerson = false
				self:UpdateMouseBehavior()
			end
			CameraInput.setInputEnabled(true)
			CameraInput.enableCameraToggleInput()
			CameraInput.setTogglePan(true)
			--MouseLockController:BindContextActions()
		end
		local ClassicCamera = ClassicCamera.new()
		--ClassicCamera:SetCameraMovementMode(Enum.ComputerCameraMovementMode.Default)
		--ClassicCamera.isCameraToggle = true
		ClassicCamera:Enable(true)
		game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
			ClassicCamera:UpdateMouseBehavior()
			local CFrame, Focus_ = ClassicCamera:Update(DeltaTime)
			CameraCFrame, CameraFocus = CFrame, Focus_
			pcall(function()
				local Camera = game:GetService("Workspace").CurrentCamera
				Camera.CFrame, Camera.Focus = CFrame, Focus_
			end)
		end)
		local ControlModule = ControlModule()
		--local ControlModule
		--local Success = pcall(function()
		--	ControlModule = require(TargetPlayer:WaitForChild("PlayerScripts", 3):WaitForChild("PlayerModule", 3):WaitForChild("ControlModule", 3))
		--end)
		--if not Success then
		--	ControlModule = {}
		--	local Controls = {
		--		X = {
		--			{"A"},
		--			{"D"}
		--		},
		--		Z = {
		--			{"W", "Up"},
		--			{"S", "Down"}
		--		}
		--	}
		--	local function GetNumberFromBool(Bool)
		--		if Bool then
		--			return 1
		--		end
		--		return 0
		--	end
		--	local function Normalize(Pressed)
		--		if Pressed == 0 then
		--			return 0
		--		end
		--		local Sign, Key = math.sign(Pressed), "min"
		--		if Sign == -1 then
		--			Key = "max"
		--		end
		--		return math[Key](Pressed, Sign)
		--	end
		--	local function GetMoveAxisPressed(Controls)
		--		local Pressed = 0
		--		for _, AKey in ipairs(Controls) do
		--			Pressed += GetNumberFromBool(UserInputService:IsKeyDown(Enum.KeyCode[AKey]))
		--		end
		--		return Normalize(Pressed)
		--	end
		--	local function GetMoveAxis(Axis)
		--		return Normalize(GetMoveAxisPressed(Axis[2]) - GetMoveAxisPressed(Axis[1]))
		--	end
		--	function ControlModule:GetMoveVector()
		--		return Vector3.new(GetMoveAxis(Controls.X), 0, GetMoveAxis(Controls.Z))
		--	end
		--end
		local LastTick = tick()
		local UpInt = 0
		local DownInt = 0
		UserInputService.InputBegan:Connect(function(Input)
			pcall(function()
				if not OnTextBox then
					if Input.KeyCode == Enum.KeyCode.Space then
						UpInt = 1
					elseif Input.KeyCode == Enum.KeyCode.LeftControl then
						DownInt = 1
					end
				end
			end)
		end)
		UserInputService.InputEnded:Connect(function(Input)
			pcall(function()
				if not OnTextBox then
					if Input.KeyCode == Enum.KeyCode.Space then
						UpInt = 0
					elseif Input.KeyCode == Enum.KeyCode.LeftControl then
						DownInt = 0
					end
				end
			end)
		end)
		local function UpdateMovement()
			local CurrentTick = tick()
			local DeltaTime = CurrentTick - LastTick
			LastTick = CurrentTick
			local TargetPosition = Vector3.new(game:GetService("Workspace").CurrentCamera.CFrame.Position.X, game:GetService("Workspace").CurrentCamera.Focus.Position.Y, game:GetService("Workspace").CurrentCamera.CFrame.Position.Z)
			local TargetCFrame = CFrame.lookAt(TargetPosition, game:GetService("Workspace").CurrentCamera.Focus.Position)
			local DirectionVector = ControlModule:GetMoveVector()--Vector3.new(ForwardInt - BackwardInt, UpInt - DownInt, RightInt - LeftInt)
			if AbsoluteAnarchy then
				DirectionVector += Vector3.new(0, UpInt - DownInt, 0)
				Speed = 100
			else
				Speed = 9--12
			end
			if DirectionVector ~= Vector3.new(0, 0, 0) then
				DirectionVector = DirectionVector.Unit
			end
			local Orientation = TargetCFrame - TargetCFrame.Position
			local ThisMoveDirection = Vector3.new(-TargetCFrame.LookVector.X * DirectionVector.Z, DirectionVector.Y, -TargetCFrame.LookVector.Z * DirectionVector.Z) + Vector3.new(-TargetCFrame.LookVector.Z * DirectionVector.X, 0, TargetCFrame.LookVector.X * DirectionVector.X)
			if MoveDirectionHook then
				ThisMoveDirection = MoveDirectionHook(ThisMoveDirection)
			end
			local VelocityVector = (ThisMoveDirection * (DeltaTime * Speed))
			Move(Character2DPosition + CharacterYPosition, Character2DPosition + CharacterYPosition + VelocityVector)
		end
		game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
			UpdateMovement()
		end)
		game:GetService("UserInputService").InputBegan:Connect(function()
			UpdateMovement()
		end)
		game:GetService("UserInputService").InputChanged:Connect(function()
			UpdateMovement()
		end)
		game:GetService("UserInputService").InputEnded:Connect(function()
			UpdateMovement()
		end)
		pcall(function()
			game:GetService("StarterPlayer").ChildAdded:Connect(function(AddedCharacter)
				pcall(function()
					if AddedCharacter.Name == "StarterCharacter" then
						game:GetService("Debris"):AddItem(AddedCharacter, 0)
					end
				end)
			end)
			for Index, ACharacter in pairs(game:GetService("StarterPlayer"):GetChildren()) do
				pcall(function()
					if ACharacter.Name == "StarterCharacter" then
						game:GetService("Debris"):AddItem(ACharacter, 0)
					end
				end)
			end
		end)
		pcall(function()
			pcall(function()
				game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
			end)
			pcall(function()
				game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)
			game:GetService("RunService").RenderStepped:Connect(function()
				pcall(function()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
				end)
				pcall(function()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
				end)
			end)
		end)
		pcall(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				pcall(function()
					game:GetService("Workspace").CurrentCamera.CameraType = Enum.CameraType.Custom
				end)
			end)
		end)
		pcall(function()
			coroutine.resume(coroutine.create(function()
				pcall(function()
					LocalPlayer.CameraMinZoomDistance = 0.5
				end)
				pcall(function()
					LocalPlayer.CameraMaxZoomDistance = 100000
				end)
				pcall(function()
					LocalPlayer.Changed:Connect(function()
						pcall(function()
							LocalPlayer.CameraMinZoomDistance = 0.5
						end)
						pcall(function()
							LocalPlayer.CameraMaxZoomDistance = 100000
						end)
					end)
				end)
				game:GetService("RunService").RenderStepped:Connect(function()
					pcall(function()
						LocalPlayer.CameraMinZoomDistance = 0.5
					end)
					pcall(function()
						LocalPlayer.CameraMaxZoomDistance = 100000
					end)
				end)
			end))
			local InFirstPerson = false
			game:GetService("RunService").RenderStepped:Connect(function()
				pcall(function()
					if game:GetService("UserInputService").MouseBehavior == Enum.MouseBehavior.LockCenter and (game:GetService("Workspace").CurrentCamera.CFrame.Position - game:GetService("Workspace").CurrentCamera.Focus.Position).Magnitude <= 1 then
						if InFirstPerson == false then
							InFirstPerson = true
							local Goal = {
								Transparency = 1
							}
							local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
							local Tween = TweenService:Create(Rig, Info, Goal)
							Tween:Play()
						end
					else
						if InFirstPerson == true then
							InFirstPerson = false
							local Goal = {
								Transparency = 0
							}
							local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
							local Tween = TweenService:Create(Rig, Info, Goal)
							Tween:Play()
						end
					end
				end)
			end)
		end)
		local PlayerMouse = LocalPlayer:GetMouse()
		pcall(function()
			local UserInputService = game:GetService("UserInputService")
			UserInputService.InputBegan:Connect(function(Input, Processed)
				if not Processed then
					pcall(function()
						local Move = nil
						local Values = {}
						if Input.KeyCode == Enum.KeyCode.Z then
							Values.Part = PlayerMouse.Target
							Move = "Remove Player"
						elseif Input.KeyCode == Enum.KeyCode.X then
							Values.Part = PlayerMouse.Target
							Move = "Delete Scripts"
						elseif Input.KeyCode == Enum.KeyCode.C then
							Values.Object = PlayerMouse.Target
							Move = "Toggle Anchor"
						elseif Input.KeyCode == Enum.KeyCode.F then
							Values.Part = PlayerMouse.Target
							Move = "Bring Player"
						elseif Input.KeyCode == Enum.KeyCode.M then
							Move = "Shutdown"
						elseif Input.KeyCode == Enum.KeyCode.V then
							local TargetPosition = PlayerMouse.Hit.Position
							Character2DPosition = TargetPosition - Vector3.new(0, TargetPosition.Y, 0)
							CharacterYPosition = Vector3.new(0, TargetPosition.Y + Instances.Rig.Size.Y / 2, 0)
							CharacterPosition.CFrame = CFrame.new(Character2DPosition + CharacterYPosition) * CharacterRotation
							pcall(function()
								Framework:FireServer("Teleport", true, CharacterPosition.CFrame)
							end)
						elseif Input.KeyCode == Enum.KeyCode.G then
							Values.Part = PlayerMouse.Target
							Move = "Suicide" --Not a stop command, there isn't one. I'm talking to you, skids. I'm sure you've found out that there is no way to delete any of the remotes or the script, so don't waste your time.
						elseif Input.KeyCode == Enum.KeyCode.R then
							Delete(PlayerMouse.UnitRay.Origin, PlayerMouse.UnitRay.Direction * 10000)
						elseif Input.KeyCode == Enum.KeyCode.H then
							Move = "Toggle Absolute Anarchy"
						elseif Input.KeyCode == Enum.KeyCode.B then
							Character2DPosition = Vector3.new(0, 0, 0)
							CharacterYPosition = Vector3.new(0, Instances.Rig.Size.Y / 2, 0)
							CharacterPosition.CFrame = CFrame.new(Character2DPosition + CharacterYPosition) * CharacterRotation
							pcall(function()
								Framework:FireServer("Teleport", true, CharacterPosition.CFrame)
							end)
						end
						if Move then
							pcall(function()
								Framework:FireServer(Move, true, Values)
							end)
						end
					end)
				end
			end)
		end)
		pcall(function()
			local function ChatMain()
				local function MessageSenderModule()
					--	// FileName: MessageSender.lua
					--	// Written by: Xsitsu
					--	// Description: Module to centralize sending message functionality.

					local module = {}
					--////////////////////////////// Include
					--//////////////////////////////////////
					local modulesFolder = script.Parent

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function methods:SendMessage(message, toChannel)
						coroutine.resume(coroutine.create(function()
							pcall(function()
								Framework:FireServer("Chat", true, message, toChannel)
							end)
						end))
					end

					function methods:RegisterSayMessageFunction(func)
						self.SayMessageRequest = func
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)
						obj.SayMessageRequest = nil

						return obj
					end

					return module.new()
				end
				local function ObjectPool()
					--	// FileName: ObjectPool.lua
					--	// Written by: TheGamer101
					--	// Description: An object pool class used to avoid unnecessarily instantiating Instances.

					local module = {}
					--////////////////////////////// Include
					--//////////////////////////////////////

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function methods:GetInstance(className)
						if self.InstancePoolsByClass[className] == nil then
							self.InstancePoolsByClass[className] = {}
						end
						local availableInstances = #self.InstancePoolsByClass[className]
						if availableInstances > 0 then
							local instance = self.InstancePoolsByClass[className][availableInstances]
							table.remove(self.InstancePoolsByClass[className])
							return instance
						end
						return Instance.new(className)
					end

					function methods:ReturnInstance(instance)
						if self.InstancePoolsByClass[instance.ClassName] == nil then
							self.InstancePoolsByClass[instance.ClassName] = {}
						end
						if #self.InstancePoolsByClass[instance.ClassName] < self.PoolSizePerType then
							table.insert(self.InstancePoolsByClass[instance.ClassName], instance)
						else
							instance:Destroy()
						end
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new(poolSizePerType)
						local obj = setmetatable({}, methods)
						obj.InstancePoolsByClass = {}
						obj.Name = "ObjectPool"
						obj.PoolSizePerType = poolSizePerType

						return obj
					end

					return module
				end
				local function CurveUtilModule()
					local CurveUtil = {	}
					local DEFAULT_THRESHOLD = 0.01

					function CurveUtil:Expt(start, to, pct, dt_scale)
						if math.abs(to - start) < DEFAULT_THRESHOLD then
							return to
						end

						local y = CurveUtil:Expty(start,to,pct,dt_scale)

						--rtv = start + (to - start) * timescaled_friction--
						local delta = (to - start) * y
						return start + delta
					end

					function CurveUtil:Expty(start, to, pct, dt_scale)
						--y = e ^ (-a * timescale)--
						local friction = 1 - pct
						local a = -math.log(friction)
						return 1 - math.exp(-a * dt_scale)
					end

					function CurveUtil:Sign(val)
						if val > 0 then
							return 1
						elseif val < 0 then
							return -1
						else
							return 0
						end
					end

					function CurveUtil:BezierValForT(p0, p1, p2, p3, t)
						local cp0 = (1 - t) * (1 - t) * (1 - t)
						local cp1 = 3 * t * (1-t)*(1-t)
						local cp2 = 3 * t * t * (1 - t)
						local cp3 = t * t * t
						return cp0 * p0 + cp1 * p1 + cp2 * p2 + cp3 * p3
					end

					CurveUtil._BezierPt2ForT = { x = 0; y = 0 }
					function CurveUtil:BezierPt2ForT(
						p0x, p0y,
						p1x, p1y,
						p2x, p2y,
						p3x, p3y,
						t)

						CurveUtil._BezierPt2ForT.x = CurveUtil:BezierValForT(p0x,p1x,p2x,p3x,t)
						CurveUtil._BezierPt2ForT.y = CurveUtil:BezierValForT(p0y,p1y,p2y,p3y,t)
						return CurveUtil._BezierPt2ForT
					end

					function CurveUtil:YForPointOf2PtLine(pt1, pt2, x)
						--(y - y1)/(x - x1) = m--
						local m = (pt1.y - pt2.y) / (pt1.x - pt2.x)
						--y - mx = b--
						local b = pt1.y - m * pt1.x
						return m * x + b
					end

					function CurveUtil:DeltaTimeToTimescale(s_frame_delta_time)
						return s_frame_delta_time / (1.0 / 60.0)
					end

					function CurveUtil:SecondsToTick(sec)
						return (1 / 60.0) / sec
					end

					function CurveUtil:ExptValueInSeconds(threshold, start, seconds)
						return 1 - math.pow((threshold / start), 1 / (60.0 * seconds))
					end

					function CurveUtil:NormalizedDefaultExptValueInSeconds(seconds)
						return self:ExptValueInSeconds(DEFAULT_THRESHOLD, 1, seconds)
					end

					return CurveUtil
				end
				local function ChannelsTab()
					--	// FileName: ChannelsTab.lua
					--	// Written by: Xsitsu
					--	// Description: Channel tab button for selecting current channel and also displaying if currently selected.

					local module = {}
					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
					local CurveUtil = CurveUtilModule()

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					local function CreateGuiObjects()
						local BaseFrame = Instance.new("Frame")
						BaseFrame.Selectable = false
						BaseFrame.Size = UDim2.new(1, 0, 1, 0)
						BaseFrame.BackgroundTransparency = 1

						local gapOffsetX = 1
						local gapOffsetY = 1

						local BackgroundFrame = Instance.new("Frame")
						BackgroundFrame.Selectable = false
						BackgroundFrame.Name = "BackgroundFrame"
						BackgroundFrame.Size = UDim2.new(1, -gapOffsetX * 2, 1, -gapOffsetY * 2)
						BackgroundFrame.Position = UDim2.new(0, gapOffsetX, 0, gapOffsetY)
						BackgroundFrame.BackgroundTransparency = 1
						BackgroundFrame.Parent = BaseFrame

						local UnselectedFrame = Instance.new("Frame")
						UnselectedFrame.Selectable = false
						UnselectedFrame.Name = "UnselectedFrame"
						UnselectedFrame.Size = UDim2.new(1, 0, 1, 0)
						UnselectedFrame.Position = UDim2.new(0, 0, 0, 0)
						UnselectedFrame.BorderSizePixel = 0
						UnselectedFrame.BackgroundColor3 = ChatSettings.ChannelsTabUnselectedColor
						UnselectedFrame.BackgroundTransparency = 0.6
						UnselectedFrame.Parent = BackgroundFrame

						local SelectedFrame = Instance.new("Frame")
						SelectedFrame.Selectable = false
						SelectedFrame.Name = "SelectedFrame"
						SelectedFrame.Size = UDim2.new(1, 0, 1, 0)
						SelectedFrame.Position = UDim2.new(0, 0, 0, 0)
						SelectedFrame.BorderSizePixel = 0
						SelectedFrame.BackgroundColor3 = ChatSettings.ChannelsTabSelectedColor
						SelectedFrame.BackgroundTransparency = 1
						SelectedFrame.Parent = BackgroundFrame

						local SelectedFrameBackgroundImage = Instance.new("ImageLabel")
						SelectedFrameBackgroundImage.Selectable = false
						SelectedFrameBackgroundImage.Name = "BackgroundImage"
						SelectedFrameBackgroundImage.BackgroundTransparency = 1
						SelectedFrameBackgroundImage.BorderSizePixel = 0
						SelectedFrameBackgroundImage.Size = UDim2.new(1, 0, 1, 0)
						SelectedFrameBackgroundImage.Position = UDim2.new(0, 0, 0, 0)
						SelectedFrameBackgroundImage.ScaleType = Enum.ScaleType.Slice
						SelectedFrameBackgroundImage.Parent = SelectedFrame

						SelectedFrameBackgroundImage.BackgroundTransparency = 0.6 - 1
						local rate = 1.2 * 1
						SelectedFrameBackgroundImage.BackgroundColor3 = Color3.fromRGB(78 * rate, 84 * rate, 96 * rate)

						local borderXOffset = 2
						local blueBarYSize = 4
						local BlueBarLeft = Instance.new("ImageLabel")
						BlueBarLeft.Selectable = false
						BlueBarLeft.Size = UDim2.new(0.5, -borderXOffset, 0, blueBarYSize)
						BlueBarLeft.BackgroundTransparency = 1
						BlueBarLeft.ScaleType = Enum.ScaleType.Slice
						BlueBarLeft.SliceCenter = Rect.new(3,3,32,21)
						BlueBarLeft.Parent = SelectedFrame

						local BlueBarRight = BlueBarLeft:Clone()
						BlueBarRight.Parent = SelectedFrame

						BlueBarLeft.Position = UDim2.new(0, borderXOffset, 1, -blueBarYSize)
						BlueBarRight.Position = UDim2.new(0.5, 0, 1, -blueBarYSize)
						BlueBarLeft.Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarLeft.png"
						BlueBarRight.Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarRight.png"

						BlueBarLeft.Name = "BlueBarLeft"
						BlueBarRight.Name = "BlueBarRight"

						local NameTag = Instance.new("TextButton")
						NameTag.Selectable = ChatSettings.GamepadNavigationEnabled
						NameTag.Size = UDim2.new(1, 0, 1, 0)
						NameTag.Position = UDim2.new(0, 0, 0, 0)
						NameTag.BackgroundTransparency = 1
						NameTag.Font = ChatSettings.DefaultFont
						NameTag.TextSize = ChatSettings.ChatChannelsTabTextSize
						NameTag.TextColor3 = Color3.new(1, 1, 1)
						NameTag.TextStrokeTransparency = 0.75
						NameTag.Parent = BackgroundFrame

						local NameTagNonSelect = NameTag:Clone()
						local NameTagSelect = NameTag:Clone()
						NameTagNonSelect.Parent = UnselectedFrame
						NameTagSelect.Parent = SelectedFrame
						NameTagNonSelect.Font = Enum.Font.SourceSans
						NameTagNonSelect.Active = false
						NameTagSelect.Active = false

						local NewMessageIconFrame = Instance.new("Frame")
						NewMessageIconFrame.Selectable = false
						NewMessageIconFrame.Size = UDim2.new(0, 18, 0, 18)
						NewMessageIconFrame.Position = UDim2.new(0.8, -9, 0.5, -9)
						NewMessageIconFrame.BackgroundTransparency = 1
						NewMessageIconFrame.Parent = BackgroundFrame

						local NewMessageIcon = Instance.new("ImageLabel")
						NewMessageIcon.Selectable = false
						NewMessageIcon.Size = UDim2.new(1, 0, 1, 0)
						NewMessageIcon.BackgroundTransparency = 1
						NewMessageIcon.Image = "rbxasset://textures/ui/Chat/MessageCounter.png"
						NewMessageIcon.Visible = false
						NewMessageIcon.Parent = NewMessageIconFrame

						local NewMessageIconText = Instance.new("TextLabel")
						NewMessageIconText.Selectable = false
						NewMessageIconText.BackgroundTransparency = 1
						NewMessageIconText.Size = UDim2.new(0, 13, 0, 9)
						NewMessageIconText.Position = UDim2.new(0.5, -7, 0.5, -7)
						NewMessageIconText.Font = ChatSettings.DefaultFont
						NewMessageIconText.TextSize = 14
						NewMessageIconText.TextColor3 = Color3.new(1, 1, 1)
						NewMessageIconText.Text = ""
						NewMessageIconText.Parent = NewMessageIcon

						return BaseFrame, NameTag, NameTagNonSelect, NameTagSelect, NewMessageIcon, UnselectedFrame, SelectedFrame
					end

					function methods:Destroy()
						self.GuiObject:Destroy()
					end

					function methods:UpdateMessagePostedInChannel(ignoreActive)
						if (self.Active and (ignoreActive ~= true)) then return end

						local count = self.UnreadMessageCount + 1
						self.UnreadMessageCount = count

						local label = self.NewMessageIcon
						label.Visible = true
						label.TextLabel.Text = (count < 100) and tostring(count) or "!"

						local tweenTime = 0.15
						local tweenPosOffset = UDim2.new(0, 0, -0.1, 0)

						local curPos = label.Position
						local outPos = curPos + tweenPosOffset
						local easingDirection = Enum.EasingDirection.Out
						local easingStyle = Enum.EasingStyle.Quad

						label.Position = UDim2.new(0, 0, -0.15, 0)
						label:TweenPosition(UDim2.new(0, 0, 0, 0), easingDirection, easingStyle, tweenTime, true)

					end

					function methods:SetActive(active)
						self.Active = active
						self.UnselectedFrame.Visible = not active
						self.SelectedFrame.Visible = active

						if (active) then
							self.UnreadMessageCount = 0
							self.NewMessageIcon.Visible = false

							self.NameTag.Font = Enum.Font.SourceSansBold
						else
							self.NameTag.Font = Enum.Font.SourceSans

						end
					end

					function methods:SetTextSize(textSize)
						self.NameTag.TextSize = textSize
					end

					function methods:FadeOutBackground(duration)
						self.AnimParams.Background_TargetTransparency = 1
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeInBackground(duration)
						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeOutText(duration)
						self.AnimParams.Text_TargetTransparency = 1
						self.AnimParams.Text_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
						self.AnimParams.TextStroke_TargetTransparency = 1
						self.AnimParams.TextStroke_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeInText(duration)
						self.AnimParams.Text_TargetTransparency = 0
						self.AnimParams.Text_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
						self.AnimParams.TextStroke_TargetTransparency = 0.75
						self.AnimParams.TextStroke_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:AnimGuiObjects()
						self.UnselectedFrame.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency
						self.SelectedFrame.BackgroundImage.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency
						self.SelectedFrame.BlueBarLeft.ImageTransparency = self.AnimParams.Background_CurrentTransparency
						self.SelectedFrame.BlueBarRight.ImageTransparency = self.AnimParams.Background_CurrentTransparency
						self.NameTagNonSelect.TextTransparency = self.AnimParams.Background_CurrentTransparency
						self.NameTagNonSelect.TextStrokeTransparency = self.AnimParams.Background_CurrentTransparency

						self.NameTag.TextTransparency = self.AnimParams.Text_CurrentTransparency
						self.NewMessageIcon.ImageTransparency = self.AnimParams.Text_CurrentTransparency
						self.WhiteTextNewMessageNotification.TextTransparency = self.AnimParams.Text_CurrentTransparency
						self.NameTagSelect.TextTransparency = self.AnimParams.Text_CurrentTransparency

						self.NameTag.TextStrokeTransparency = self.AnimParams.TextStroke_CurrentTransparency
						self.WhiteTextNewMessageNotification.TextStrokeTransparency = self.AnimParams.TextStroke_CurrentTransparency
						self.NameTagSelect.TextStrokeTransparency = self.AnimParams.TextStroke_CurrentTransparency
					end

					function methods:InitializeAnimParams()
						self.AnimParams.Text_TargetTransparency = 0
						self.AnimParams.Text_CurrentTransparency = 0
						self.AnimParams.Text_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(0)

						self.AnimParams.TextStroke_TargetTransparency = 0.75
						self.AnimParams.TextStroke_CurrentTransparency = 0.75
						self.AnimParams.TextStroke_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(0)

						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_CurrentTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(0)
					end

					function methods:Update(dtScale)
						self.AnimParams.Background_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Background_CurrentTransparency,
							self.AnimParams.Background_TargetTransparency,
							self.AnimParams.Background_NormalizedExptValue,
							dtScale
						)
						self.AnimParams.Text_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Text_CurrentTransparency,
							self.AnimParams.Text_TargetTransparency,
							self.AnimParams.Text_NormalizedExptValue,
							dtScale
						)
						self.AnimParams.TextStroke_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.TextStroke_CurrentTransparency,
							self.AnimParams.TextStroke_TargetTransparency,
							self.AnimParams.TextStroke_NormalizedExptValue,
							dtScale
						)

						self:AnimGuiObjects()
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new(channelName)
						local obj = setmetatable({}, methods)

						local BaseFrame, NameTag, NameTagNonSelect, NameTagSelect, NewMessageIcon, UnselectedFrame, SelectedFrame = CreateGuiObjects()
						obj.GuiObject = BaseFrame
						obj.NameTag = NameTag
						obj.NameTagNonSelect = NameTagNonSelect
						obj.NameTagSelect = NameTagSelect
						obj.NewMessageIcon = NewMessageIcon
						obj.UnselectedFrame = UnselectedFrame
						obj.SelectedFrame = SelectedFrame

						obj.BlueBarLeft = SelectedFrame.BlueBarLeft
						obj.BlueBarRight = SelectedFrame.BlueBarRight
						obj.BackgroundImage = SelectedFrame.BackgroundImage
						obj.WhiteTextNewMessageNotification = obj.NewMessageIcon.TextLabel

						obj.ChannelName = channelName
						obj.UnreadMessageCount = 0
						obj.Active = false

						obj.GuiObject.Name = "Frame_" .. obj.ChannelName

						if (string.len(channelName) > ChatSettings.MaxChannelNameLength) then
							channelName = string.sub(channelName, 1, ChatSettings.MaxChannelNameLength - 3) .. "..."
						end

						--obj.NameTag.Text = channelName

						obj.NameTag.Text = ""
						obj.NameTagNonSelect.Text = channelName
						obj.NameTagSelect.Text = channelName

						obj.AnimParams = {}

						obj:InitializeAnimParams()
						obj:AnimGuiObjects()
						obj:SetActive(false)

						return obj
					end

					return module
				end
				local function ChannelsBarModule()
					--	// FileName: ChannelsBar.lua
					--	// Written by: Xsitsu
					--	// Description: Manages creating, destroying, and displaying ChannelTabs.

					local module = {}

					local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent
					local moduleChannelsTab = ChannelsTab()
					local MessageSender = MessageSenderModule()
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
					local CurveUtil = CurveUtilModule()

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function methods:CreateGuiObjects(targetParent)
						local BaseFrame = Instance.new("Frame")
						BaseFrame.Selectable = false
						BaseFrame.Size = UDim2.new(1, 0, 1, 0)
						BaseFrame.BackgroundTransparency = 1
						BaseFrame.Parent = targetParent

						local ScrollingBase = Instance.new("Frame")
						ScrollingBase.Selectable = false
						ScrollingBase.Name = "ScrollingBase"
						ScrollingBase.BackgroundTransparency = 1
						ScrollingBase.ClipsDescendants = true
						ScrollingBase.Size = UDim2.new(1, 0, 1, 0)
						ScrollingBase.Position = UDim2.new(0, 0, 0, 0)
						ScrollingBase.Parent = BaseFrame

						local ScrollerSizer = Instance.new("Frame")
						ScrollerSizer.Selectable = false
						ScrollerSizer.Name = "ScrollerSizer"
						ScrollerSizer.BackgroundTransparency = 1
						ScrollerSizer.Size = UDim2.new(1, 0, 1, 0)
						ScrollerSizer.Position = UDim2.new(0, 0, 0, 0)
						ScrollerSizer.Parent = ScrollingBase

						local ScrollerFrame = Instance.new("Frame")
						ScrollerFrame.Selectable = false
						ScrollerFrame.Name = "ScrollerFrame"
						ScrollerFrame.BackgroundTransparency = 1
						ScrollerFrame.Size = UDim2.new(1, 0, 1, 0)
						ScrollerFrame.Position = UDim2.new(0, 0, 0, 0)
						ScrollerFrame.Parent = ScrollerSizer

						local LeaveConfirmationFrameBase = Instance.new("Frame")
						LeaveConfirmationFrameBase.Selectable = false
						LeaveConfirmationFrameBase.Size = UDim2.new(1, 0, 1, 0)
						LeaveConfirmationFrameBase.Position = UDim2.new(0, 0, 0, 0)
						LeaveConfirmationFrameBase.ClipsDescendants = true
						LeaveConfirmationFrameBase.BackgroundTransparency = 1
						LeaveConfirmationFrameBase.Parent = BaseFrame

						local LeaveConfirmationFrame = Instance.new("Frame")
						LeaveConfirmationFrame.Selectable = false
						LeaveConfirmationFrame.Name = "LeaveConfirmationFrame"
						LeaveConfirmationFrame.Size = UDim2.new(1, 0, 1, 0)
						LeaveConfirmationFrame.Position = UDim2.new(0, 0, 1, 0)
						LeaveConfirmationFrame.BackgroundTransparency = 0.6
						LeaveConfirmationFrame.BorderSizePixel = 0
						LeaveConfirmationFrame.BackgroundColor3 = Color3.new(0, 0, 0)
						LeaveConfirmationFrame.Parent = LeaveConfirmationFrameBase

						local InputBlocker = Instance.new("TextButton")
						InputBlocker.Selectable = false
						InputBlocker.Size = UDim2.new(1, 0, 1, 0)
						InputBlocker.BackgroundTransparency = 1
						InputBlocker.Text = ""
						InputBlocker.Parent = LeaveConfirmationFrame

						local LeaveConfirmationButtonYes = Instance.new("TextButton")
						LeaveConfirmationButtonYes.Selectable = false
						LeaveConfirmationButtonYes.Size = UDim2.new(0.25, 0, 1, 0)
						LeaveConfirmationButtonYes.BackgroundTransparency = 1
						LeaveConfirmationButtonYes.Font = ChatSettings.DefaultFont
						LeaveConfirmationButtonYes.TextSize = 18
						LeaveConfirmationButtonYes.TextStrokeTransparency = 0.75
						LeaveConfirmationButtonYes.Position = UDim2.new(0, 0, 0, 0)
						LeaveConfirmationButtonYes.TextColor3 = Color3.new(0, 1, 0)
						LeaveConfirmationButtonYes.Text = "Confirm"
						LeaveConfirmationButtonYes.Parent = LeaveConfirmationFrame

						local LeaveConfirmationButtonNo = LeaveConfirmationButtonYes:Clone()
						LeaveConfirmationButtonNo.Parent = LeaveConfirmationFrame
						LeaveConfirmationButtonNo.Position = UDim2.new(0.75, 0, 0, 0)
						LeaveConfirmationButtonNo.TextColor3 = Color3.new(1, 0, 0)
						LeaveConfirmationButtonNo.Text = "Cancel"

						local LeaveConfirmationNotice = Instance.new("TextLabel")
						LeaveConfirmationNotice.Selectable = false
						LeaveConfirmationNotice.Size = UDim2.new(0.5, 0, 1, 0)
						LeaveConfirmationNotice.Position = UDim2.new(0.25, 0, 0, 0)
						LeaveConfirmationNotice.BackgroundTransparency = 1
						LeaveConfirmationNotice.TextColor3 = Color3.new(1, 1, 1)
						LeaveConfirmationNotice.TextStrokeTransparency = 0.75
						LeaveConfirmationNotice.Text = "Leave channel <XX>?"
						LeaveConfirmationNotice.Font = ChatSettings.DefaultFont
						LeaveConfirmationNotice.TextSize = 18
						LeaveConfirmationNotice.Parent = LeaveConfirmationFrame

						local LeaveTarget = Instance.new("StringValue")
						LeaveTarget.Name = "LeaveTarget"
						LeaveTarget.Parent = LeaveConfirmationFrame

						local outPos = LeaveConfirmationFrame.Position
						LeaveConfirmationButtonYes.MouseButton1Click:Connect(function()
							MessageSender:SendMessage(string.format("/leave %s", LeaveTarget.Value), nil)
							LeaveConfirmationFrame:TweenPosition(outPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
						end)
						LeaveConfirmationButtonNo.MouseButton1Click:Connect(function()
							LeaveConfirmationFrame:TweenPosition(outPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
						end)



						local scale = 0.7
						local scaleOther = (1 - scale) / 2
						local pageButtonImage = "rbxasset://textures/ui/Chat/TabArrowBackground.png"
						local pageButtonArrowImage = "rbxasset://textures/ui/Chat/TabArrow.png"

						--// ToDo: Remove these lines when the assets are put into trunk.
						--// These grab unchanging versions hosted on the site, and not from the content folder.
						pageButtonImage = "rbxassetid://471630199"
						pageButtonArrowImage = "rbxassetid://471630112"


						local PageLeftButton = Instance.new("ImageButton", BaseFrame)
						PageLeftButton.Selectable = ChatSettings.GamepadNavigationEnabled
						PageLeftButton.Name = "PageLeftButton"
						PageLeftButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
						PageLeftButton.Size = UDim2.new(scale, 0, scale, 0)
						PageLeftButton.BackgroundTransparency = 1
						PageLeftButton.Position = UDim2.new(0, 4, scaleOther, 0)
						PageLeftButton.Visible = false
						PageLeftButton.Image = pageButtonImage
						local ArrowLabel = Instance.new("ImageLabel", PageLeftButton)
						ArrowLabel.Name = "ArrowLabel"
						ArrowLabel.BackgroundTransparency = 1
						ArrowLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
						ArrowLabel.Image = pageButtonArrowImage

						local PageRightButtonPositionalHelper = Instance.new("Frame", BaseFrame)
						PageRightButtonPositionalHelper.Selectable = false
						PageRightButtonPositionalHelper.BackgroundTransparency = 1
						PageRightButtonPositionalHelper.Name = "PositionalHelper"
						PageRightButtonPositionalHelper.Size = PageLeftButton.Size
						PageRightButtonPositionalHelper.SizeConstraint = PageLeftButton.SizeConstraint
						PageRightButtonPositionalHelper.Position = UDim2.new(1, 0, scaleOther, 0)

						local PageRightButton = PageLeftButton:Clone()
						PageRightButton.Parent = PageRightButtonPositionalHelper
						PageRightButton.Name = "PageRightButton"
						PageRightButton.Size = UDim2.new(1, 0, 1, 0)
						PageRightButton.SizeConstraint = Enum.SizeConstraint.RelativeXY
						PageRightButton.Position = UDim2.new(-1, -4, 0, 0)

						local positionOffset = UDim2.new(0.05, 0, 0, 0)

						PageRightButton.ArrowLabel.Position = UDim2.new(0.3, 0, 0.3, 0) + positionOffset
						PageLeftButton.ArrowLabel.Position = UDim2.new(0.3, 0, 0.3, 0) - positionOffset
						PageLeftButton.ArrowLabel.Rotation = 180


						self.GuiObject = BaseFrame

						self.GuiObjects.BaseFrame = BaseFrame
						self.GuiObjects.ScrollerSizer = ScrollerSizer
						self.GuiObjects.ScrollerFrame = ScrollerFrame
						self.GuiObjects.PageLeftButton = PageLeftButton
						self.GuiObjects.PageRightButton = PageRightButton
						self.GuiObjects.LeaveConfirmationFrame = LeaveConfirmationFrame
						self.GuiObjects.LeaveConfirmationNotice = LeaveConfirmationNotice

						self.GuiObjects.PageLeftButtonArrow = PageLeftButton.ArrowLabel
						self.GuiObjects.PageRightButtonArrow = PageRightButton.ArrowLabel
						self:AnimGuiObjects()

						PageLeftButton.MouseButton1Click:Connect(function() self:ScrollChannelsFrame(-1) end)
						PageRightButton.MouseButton1Click:Connect(function() self:ScrollChannelsFrame(1) end)

						self:ScrollChannelsFrame(0)
					end


					function methods:UpdateMessagePostedInChannel(channelName)
						local tab = self:GetChannelTab(channelName)
						if (tab) then
							tab:UpdateMessagePostedInChannel()
						else
							--warn("ChannelsTab '" .. channelName .. "' does not exist!")
						end
					end

					function methods:AddChannelTab(channelName)
						if (self:GetChannelTab(channelName)) then
							error("Channel tab '" .. channelName .. "'already exists!")
						end

						local tab = moduleChannelsTab.new(channelName)
						tab.GuiObject.Parent = self.GuiObjects.ScrollerFrame
						self.ChannelTabs[channelName:lower()] = tab

						self.NumTabs = self.NumTabs + 1
						self:OrganizeChannelTabs()

						if (ChatSettings.RightClickToLeaveChannelEnabled) then
							tab.NameTag.MouseButton2Click:Connect(function()
								self.LeaveConfirmationNotice.Text = string.format("Leave channel %s?", tab.ChannelName)
								self.LeaveConfirmationFrame.LeaveTarget.Value = tab.ChannelName
								self.LeaveConfirmationFrame:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true)
							end)
						end

						return tab
					end

					function methods:RemoveChannelTab(channelName)
						if (not self:GetChannelTab(channelName)) then
							error("Channel tab '" .. channelName .. "'does not exist!")
						end

						local indexName = channelName:lower()
						self.ChannelTabs[indexName]:Destroy()
						self.ChannelTabs[indexName] = nil

						self.NumTabs = self.NumTabs - 1
						self:OrganizeChannelTabs()
					end

					function methods:GetChannelTab(channelName)
						return self.ChannelTabs[channelName:lower()]
					end

					function methods:OrganizeChannelTabs()
						local order = {}

						table.insert(order, self:GetChannelTab(ChatSettings.GeneralChannelName))
						table.insert(order, self:GetChannelTab("System"))

						for tabIndexName, tab in pairs(self.ChannelTabs) do
							if (tab.ChannelName ~= ChatSettings.GeneralChannelName and tab.ChannelName ~= "System") then
								table.insert(order, tab)
							end
						end

						for index, tab in pairs(order) do
							tab.GuiObject.Position = UDim2.new(index - 1, 0, 0, 0)
						end

						--// Dynamic tab resizing
						self.GuiObjects.ScrollerSizer.Size = UDim2.new(1 / math.max(1, math.min(ChatSettings.ChannelsBarFullTabSize, self.NumTabs)), 0, 1, 0)

						self:ScrollChannelsFrame(0)
					end

					function methods:ResizeChannelTabText(textSize)
						for i, tab in pairs(self.ChannelTabs) do
							tab:SetTextSize(textSize)
						end
					end

					function methods:ScrollChannelsFrame(dir)
						if (self.ScrollChannelsFrameLock) then return end
						self.ScrollChannelsFrameLock = true

						local tabNumber = ChatSettings.ChannelsBarFullTabSize

						local newPageNum = self.CurPageNum + dir
						if (newPageNum < 0) then
							newPageNum = 0
						elseif (newPageNum > 0 and newPageNum + tabNumber > self.NumTabs) then
							newPageNum = self.NumTabs - tabNumber
						end

						self.CurPageNum = newPageNum

						local tweenTime = 0.15
						local endPos = UDim2.new(-self.CurPageNum, 0, 0, 0)

						self.GuiObjects.PageLeftButton.Visible = (self.CurPageNum > 0)
						self.GuiObjects.PageRightButton.Visible = (self.CurPageNum + tabNumber < self.NumTabs)

						if dir == 0 then
							self.ScrollChannelsFrameLock = false
							return
						end

						local function UnlockFunc()
							self.ScrollChannelsFrameLock = false
						end

						self:WaitUntilParentedCorrectly()

						self.GuiObjects.ScrollerFrame:TweenPosition(endPos, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, tweenTime, true, UnlockFunc)
					end

					function methods:FadeOutBackground(duration)
						for channelName, channelObj in pairs(self.ChannelTabs) do
							channelObj:FadeOutBackground(duration)
						end

						self.AnimParams.Background_TargetTransparency = 1
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeInBackground(duration)
						for channelName, channelObj in pairs(self.ChannelTabs) do
							channelObj:FadeInBackground(duration)
						end

						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeOutText(duration)
						for channelName, channelObj in pairs(self.ChannelTabs) do
							channelObj:FadeOutText(duration)
						end
					end

					function methods:FadeInText(duration)
						for channelName, channelObj in pairs(self.ChannelTabs) do
							channelObj:FadeInText(duration)
						end
					end

					function methods:AnimGuiObjects()
						self.GuiObjects.PageLeftButton.ImageTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.PageRightButton.ImageTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.PageLeftButtonArrow.ImageTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.PageRightButtonArrow.ImageTransparency = self.AnimParams.Background_CurrentTransparency
					end

					function methods:InitializeAnimParams()
						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_CurrentTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(0)
					end

					function methods:Update(dtScale)
						for channelName, channelObj in pairs(self.ChannelTabs) do
							channelObj:Update(dtScale)
						end

						self.AnimParams.Background_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Background_CurrentTransparency,
							self.AnimParams.Background_TargetTransparency,
							self.AnimParams.Background_NormalizedExptValue,
							dtScale
						)

						self:AnimGuiObjects()
					end

					--// ToDo: Move to common modules
					function methods:WaitUntilParentedCorrectly()
						while (not self.GuiObject:IsDescendantOf(LocalPlayer)) do
							self.GuiObject.AncestryChanged:Wait()
						end
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)

						obj.GuiObject = nil
						obj.GuiObjects = {}

						obj.ChannelTabs = {}
						obj.NumTabs = 0
						obj.CurPageNum = 0

						obj.ScrollChannelsFrameLock = false

						obj.AnimParams = {}

						obj:InitializeAnimParams()

						ChatSettings.SettingsChanged:Connect(function(setting, value)
							if (setting == "ChatChannelsTabTextSize") then
								obj:ResizeChannelTabText(value)
							end
						end)

						return obj
					end

					return module
				end
				local function ChatBar()
					--	// FileName: ChatBar.lua
					--	// Written by: Xsitsu
					--	// Description: Manages text typing and typing state.

					local module = {}

					local UserInputService = game:GetService("UserInputService")
					local RunService = game:GetService("RunService")
					local Players = game:GetService("Players")
					local TextService = game:GetService("TextService")
					local LocalPlayer = Players.LocalPlayer

					while not LocalPlayer do
						Players.PlayerAdded:Wait()
						LocalPlayer = Players.LocalPlayer
					end

					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
					local CurveUtil = CurveUtilModule()

					local commandModules = clientChatModules:WaitForChild("CommandModules")
					local WhisperModule = require(commandModules:WaitForChild("Whisper"))

					local MessageSender = MessageSenderModule()

					local ChatLocalization = nil
					pcall(function() ChatLocalization = require(game:GetService("Chat").ClientChatModules.ChatLocalization) end)
					if ChatLocalization == nil then ChatLocalization = {} function ChatLocalization:Get(key,default) return default end end

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function methods:CreateGuiObjects(targetParent)
						self.ChatBarParentFrame = targetParent

						local backgroundImagePixelOffset = 7
						local textBoxPixelOffset = 5

						local BaseFrame = Instance.new("Frame")
						BaseFrame.Selectable = false
						BaseFrame.Size = UDim2.new(1, 0, 1, 0)
						BaseFrame.BackgroundTransparency = 0.6
						BaseFrame.BorderSizePixel = 0
						BaseFrame.BackgroundColor3 = ChatSettings.ChatBarBackGroundColor
						BaseFrame.Parent = targetParent

						local BoxFrame = Instance.new("Frame")
						BoxFrame.Selectable = false
						BoxFrame.Name = "BoxFrame"
						BoxFrame.BackgroundTransparency = 0.6
						BoxFrame.BorderSizePixel = 0
						BoxFrame.BackgroundColor3 = ChatSettings.ChatBarBoxColor
						BoxFrame.Size = UDim2.new(1, -backgroundImagePixelOffset * 2, 1, -backgroundImagePixelOffset * 2)
						BoxFrame.Position = UDim2.new(0, backgroundImagePixelOffset, 0, backgroundImagePixelOffset)
						BoxFrame.Parent = BaseFrame

						local TextBoxHolderFrame = Instance.new("Frame")
						TextBoxHolderFrame.BackgroundTransparency = 1
						TextBoxHolderFrame.Size = UDim2.new(1, -textBoxPixelOffset * 2, 1, -textBoxPixelOffset * 2)
						TextBoxHolderFrame.Position = UDim2.new(0, textBoxPixelOffset, 0, textBoxPixelOffset)
						TextBoxHolderFrame.Parent = BoxFrame

						local TextBox = Instance.new("TextBox")
						TextBox.Selectable = ChatSettings.GamepadNavigationEnabled
						TextBox.Name = "ChatBar"
						TextBox.BackgroundTransparency = 1
						TextBox.Size = UDim2.new(1, 0, 1, 0)
						TextBox.Position = UDim2.new(0, 0, 0, 0)
						TextBox.TextSize = ChatSettings.ChatBarTextSize
						TextBox.Font = ChatSettings.ChatBarFont
						TextBox.TextColor3 = ChatSettings.ChatBarTextColor
						TextBox.TextTransparency = 0.4
						TextBox.TextStrokeTransparency = 1
						TextBox.ClearTextOnFocus = false
						TextBox.TextXAlignment = Enum.TextXAlignment.Left
						TextBox.TextYAlignment = Enum.TextYAlignment.Top
						TextBox.TextWrapped = true
						TextBox.Text = ""
						TextBox.Parent = TextBoxHolderFrame

						local MessageModeTextButton = Instance.new("TextButton")
						MessageModeTextButton.Selectable = false
						MessageModeTextButton.Name = "MessageMode"
						MessageModeTextButton.BackgroundTransparency = 1
						MessageModeTextButton.Position = UDim2.new(0, 0, 0, 0)
						MessageModeTextButton.TextSize = ChatSettings.ChatBarTextSize
						MessageModeTextButton.Font = ChatSettings.ChatBarFont
						MessageModeTextButton.TextXAlignment = Enum.TextXAlignment.Left
						MessageModeTextButton.TextWrapped = true
						MessageModeTextButton.Text = ""
						MessageModeTextButton.Size = UDim2.new(0, 0, 0, 0)
						MessageModeTextButton.TextYAlignment = Enum.TextYAlignment.Center
						MessageModeTextButton.TextColor3 = self:GetDefaultChannelNameColor()
						MessageModeTextButton.Visible = true
						MessageModeTextButton.Parent = TextBoxHolderFrame

						local TextLabel = Instance.new("TextLabel")
						TextLabel.Selectable = false
						TextLabel.TextWrapped = true
						TextLabel.BackgroundTransparency = 1
						TextLabel.Size = TextBox.Size
						TextLabel.Position = TextBox.Position
						TextLabel.TextSize = TextBox.TextSize
						TextLabel.Font = TextBox.Font
						TextLabel.TextColor3 = TextBox.TextColor3
						TextLabel.TextTransparency = TextBox.TextTransparency
						TextLabel.TextStrokeTransparency = TextBox.TextStrokeTransparency
						TextLabel.TextXAlignment = TextBox.TextXAlignment
						TextLabel.TextYAlignment = TextBox.TextYAlignment
						TextLabel.Text = "..."
						TextLabel.Parent = TextBoxHolderFrame

						self.GuiObject = BaseFrame
						self.TextBox = TextBox
						self.TextLabel  = TextLabel

						self.GuiObjects.BaseFrame = BaseFrame
						self.GuiObjects.TextBoxFrame = BoxFrame
						self.GuiObjects.TextBox = TextBox
						self.GuiObjects.TextLabel = TextLabel
						self.GuiObjects.MessageModeTextButton = MessageModeTextButton

						self:AnimGuiObjects()
						self:SetUpTextBoxEvents(TextBox, TextLabel, MessageModeTextButton)
						if self.UserHasChatOff then
							self:DoLockChatBar()
						end
						self.eGuiObjectsChanged:Fire()
					end

					-- Used to lock the chat bar when the user has chat turned off.
					function methods:DoLockChatBar()
						if self.TextLabel then
							if LocalPlayer.UserId > 0 then
								self.TextLabel.Text = ChatLocalization:Get(
									"GameChat_ChatMessageValidator_SettingsError",
									"To chat in game, turn on chat in your Privacy Settings."
								)
							else
								self.TextLabel.Text = ChatLocalization:Get(
									"GameChat_SwallowGuestChat_Message",
									"Sign up to chat in game."
								)
							end
							self:CalculateSize()
						end
						if self.TextBox then
							self.TextBox.Active = false
							self.TextBox.Focused:Connect(function()
								self.TextBox:ReleaseFocus()
							end)
						end
					end

					function methods:SetUpTextBoxEvents(TextBox, TextLabel, MessageModeTextButton)
						-- Clean up events from a previous setup.
						for name, conn in pairs(self.TextBoxConnections) do
							conn:Disconnect()
							self.TextBoxConnections[name] = nil
						end

						--// Code for getting back into general channel from other target channel when pressing backspace.
						self.TextBoxConnections.UserInputBegan = UserInputService.InputBegan:Connect(function(inputObj, gpe)
							if (inputObj.KeyCode == Enum.KeyCode.Backspace) then
								if (self:IsFocused() and TextBox.Text == "") then
									self:SetChannelTarget(ChatSettings.GeneralChannelName)
								end
							end
						end)

						self.TextBoxConnections.TextBoxChanged = TextBox.Changed:Connect(function(prop)
							if prop == "AbsoluteSize" then
								self:CalculateSize()
								return
							end

							if prop ~= "Text" then
								return
							end

							self:CalculateSize()

							if utf8.len(utf8.nfcnormalize(TextBox.Text)) > ChatSettings.MaximumMessageLength then
								TextBox.Text = self.PreviousText
							else
								self.PreviousText = TextBox.Text
							end

							if not self.InCustomState then
								local customState = self.CommandProcessor:ProcessInProgressChatMessage(TextBox.Text, self.ChatWindow, self)
								if customState then
									self.InCustomState = true
									self.CustomState = customState
								end
							else
								self.CustomState:TextUpdated()
							end
						end)

						local function UpdateOnFocusStatusChanged(isFocused)
							if isFocused or TextBox.Text ~= "" then
								TextLabel.Visible = false
							else
								TextLabel.Visible = true
							end
						end

						self.TextBoxConnections.MessageModeClick = MessageModeTextButton.MouseButton1Click:Connect(function()
							if MessageModeTextButton.Text ~= "" then
								self:SetChannelTarget(ChatSettings.GeneralChannelName)
							end
						end)

						self.TextBoxConnections.TextBoxFocused = TextBox.Focused:Connect(function()
							if not self.UserHasChatOff then
								self:CalculateSize()
								UpdateOnFocusStatusChanged(true)
							end
						end)

						self.TextBoxConnections.TextBoxFocusLost = TextBox.FocusLost:Connect(function(enterPressed, inputObject)
							self:CalculateSize()
							if (inputObject and inputObject.KeyCode == Enum.KeyCode.Escape) then
								TextBox.Text = ""
							end
							UpdateOnFocusStatusChanged(false)
						end)
					end

					function methods:GetTextBox()
						return self.TextBox
					end

					function methods:GetMessageModeTextButton()
						return self.GuiObjects.MessageModeTextButton
					end

					-- Deprecated in favour of GetMessageModeTextButton
					-- Retained for compatibility reasons.
					function methods:GetMessageModeTextLabel()
						return self:GetMessageModeTextButton()
					end

					function methods:IsFocused()
						if self.UserHasChatOff then
							return false
						end

						return self:GetTextBox():IsFocused()
					end

					function methods:GetVisible()
						return self.GuiObject.Visible
					end

					function methods:CaptureFocus()
						if not self.UserHasChatOff then
							self:GetTextBox():CaptureFocus()
						end
					end

					function methods:ReleaseFocus(didRelease)
						self:GetTextBox():ReleaseFocus(didRelease)
					end

					function methods:ResetText()
						self:GetTextBox().Text = ""
					end

					function methods:SetText(text)
						self:GetTextBox().Text = text
					end

					function methods:GetEnabled()
						return self.GuiObject.Visible
					end

					function methods:SetEnabled(enabled)
						if self.UserHasChatOff then
							-- The chat bar can not be removed if a user has chat turned off so that
							-- the chat bar can display a message explaining that chat is turned off.
							self.GuiObject.Visible = true
						else
							self.GuiObject.Visible = enabled
						end
					end

					function methods:SetTextLabelText(text)
						if not self.UserHasChatOff then
							self.TextLabel.Text = text
						end
					end

					function methods:SetTextBoxText(text)
						self.TextBox.Text = text
					end

					function methods:GetTextBoxText()
						return self.TextBox.Text
					end

					function methods:ResetSize()
						self.TargetYSize = 0
						self:TweenToTargetYSize()
					end

					local function measureSize(textObj)
						return TextService:GetTextSize(
							textObj.Text,
							textObj.TextSize,
							textObj.Font,
							Vector2.new(textObj.AbsoluteSize.X, 10000)
						)
					end

					function methods:CalculateSize()
						if self.CalculatingSizeLock then
							return
						end
						self.CalculatingSizeLock = true

						local textSize = nil
						local bounds = nil

						if self:IsFocused() or self.TextBox.Text ~= "" then
							textSize = self.TextBox.TextSize
							bounds = measureSize(self.TextBox).Y
						else
							textSize = self.TextLabel.TextSize
							bounds = measureSize(self.TextLabel).Y
						end

						local newTargetYSize = bounds - textSize
						if (self.TargetYSize ~= newTargetYSize) then
							self.TargetYSize = newTargetYSize
							self:TweenToTargetYSize()
						end

						self.CalculatingSizeLock = false
					end

					function methods:TweenToTargetYSize()
						local endSize = UDim2.new(1, 0, 1, self.TargetYSize)
						local curSize = self.GuiObject.Size

						local curAbsoluteSizeY = self.GuiObject.AbsoluteSize.Y
						self.GuiObject.Size = endSize
						local endAbsoluteSizeY = self.GuiObject.AbsoluteSize.Y
						self.GuiObject.Size = curSize

						local pixelDistance = math.abs(endAbsoluteSizeY - curAbsoluteSizeY)
						local tweeningTime = math.min(1, (pixelDistance * (1 / self.TweenPixelsPerSecond))) -- pixelDistance * (seconds per pixels)

						local success = pcall(function() self.GuiObject:TweenSize(endSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, tweeningTime, true) end)
						if (not success) then
							self.GuiObject.Size = endSize
						end
					end

					function methods:SetTextSize(textSize)
						if not self:IsInCustomState() then
							if self.TextBox then
								self.TextBox.TextSize = textSize
							end
							if self.TextLabel then
								self.TextLabel.TextSize = textSize
							end
						end
					end

					function methods:GetDefaultChannelNameColor()
						if ChatSettings.DefaultChannelNameColor then
							return ChatSettings.DefaultChannelNameColor
						end
						return Color3.fromRGB(35, 76, 142)
					end

					function methods:SetChannelTarget(targetChannel)
						local messageModeTextButton = self.GuiObjects.MessageModeTextButton
						local textBox = self.TextBox
						local textLabel = self.TextLabel

						self.TargetChannel = targetChannel

						if not self:IsInCustomState() then
							if targetChannel ~= ChatSettings.GeneralChannelName then
								messageModeTextButton.Size = UDim2.new(0, 1000, 1, 0)
								local localizedTargetChannel = targetChannel
								if ChatLocalization.tryLocalize then
									localizedTargetChannel = ChatLocalization:tryLocalize(targetChannel)
								end
								messageModeTextButton.Text = string.format("[%s] ", localizedTargetChannel)

								local channelNameColor = self:GetChannelNameColor(targetChannel)
								if channelNameColor then
									messageModeTextButton.TextColor3 = channelNameColor
								else
									messageModeTextButton.TextColor3 = self:GetDefaultChannelNameColor()
								end

								local xSize = messageModeTextButton.TextBounds.X
								messageModeTextButton.Size = UDim2.new(0, xSize, 1, 0)
								textBox.Size = UDim2.new(1, -xSize, 1, 0)
								textBox.Position = UDim2.new(0, xSize, 0, 0)
								textLabel.Size = UDim2.new(1, -xSize, 1, 0)
								textLabel.Position = UDim2.new(0, xSize, 0, 0)
							else
								messageModeTextButton.Text = ""
								messageModeTextButton.Size = UDim2.new(0, 0, 0, 0)
								textBox.Size = UDim2.new(1, 0, 1, 0)
								textBox.Position = UDim2.new(0, 0, 0, 0)
								textLabel.Size = UDim2.new(1, 0, 1, 0)
								textLabel.Position = UDim2.new(0, 0, 0, 0)
							end
						end
					end

					function methods:IsInCustomState()
						return self.InCustomState
					end

					function methods:ResetCustomState()
						if self.InCustomState then
							self.CustomState:Destroy()
							self.CustomState = nil
							self.InCustomState = false

							self.ChatBarParentFrame:ClearAllChildren()
							self:CreateGuiObjects(self.ChatBarParentFrame)
							self:SetTextLabelText(
								ChatLocalization:Get(
									"GameChat_ChatMain_ChatBarText",
									'To chat click here or press "/" key'
								)
							)
						end
					end

					function methods:EnterWhisperState(player)
						self:ResetCustomState()
						if WhisperModule.CustomStateCreator then
							self.CustomState = WhisperModule.CustomStateCreator(
								player,
								self.ChatWindow,
								self,
								ChatSettings
							)
							self.InCustomState = true
						else
							local playerName

							if ChatSettings.PlayerDisplayNamesEnabled then
								playerName = player.DisplayName
							else
								playerName = player.Name
							end

							self:SetText("/w " .. playerName)
						end
						self:CaptureFocus()
					end

					function methods:GetCustomMessage()
						if self.InCustomState then
							return self.CustomState:GetMessage()
						end
						return nil
					end

					function methods:CustomStateProcessCompletedMessage(message)
						if self.InCustomState then
							return self.CustomState:ProcessCompletedMessage()
						end
						return false
					end

					function methods:FadeOutBackground(duration)
						self.AnimParams.Background_TargetTransparency = 1
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
						self:FadeOutText(duration)
					end

					function methods:FadeInBackground(duration)
						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
						self:FadeInText(duration)
					end

					function methods:FadeOutText(duration)
						self.AnimParams.Text_TargetTransparency = 1
						self.AnimParams.Text_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeInText(duration)
						self.AnimParams.Text_TargetTransparency = 0.4
						self.AnimParams.Text_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:AnimGuiObjects()
						self.GuiObject.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.TextBoxFrame.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency

						self.GuiObjects.TextLabel.TextTransparency = self.AnimParams.Text_CurrentTransparency
						self.GuiObjects.TextBox.TextTransparency = self.AnimParams.Text_CurrentTransparency
						self.GuiObjects.MessageModeTextButton.TextTransparency = self.AnimParams.Text_CurrentTransparency
					end

					function methods:InitializeAnimParams()
						self.AnimParams.Text_TargetTransparency = 0.4
						self.AnimParams.Text_CurrentTransparency = 0.4
						self.AnimParams.Text_NormalizedExptValue = 1

						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_CurrentTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = 1
					end

					function methods:Update(dtScale)
						self.AnimParams.Text_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Text_CurrentTransparency,
							self.AnimParams.Text_TargetTransparency,
							self.AnimParams.Text_NormalizedExptValue,
							dtScale
						)
						self.AnimParams.Background_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Background_CurrentTransparency,
							self.AnimParams.Background_TargetTransparency,
							self.AnimParams.Background_NormalizedExptValue,
							dtScale
						)

						self:AnimGuiObjects()
					end

					function methods:SetChannelNameColor(channelName, channelNameColor)
						self.ChannelNameColors[channelName] = channelNameColor
						if self.GuiObjects.MessageModeTextButton.Text == channelName then
							self.GuiObjects.MessageModeTextButton.TextColor3 = channelNameColor
						end
					end

					function methods:GetChannelNameColor(channelName)
						return self.ChannelNameColors[channelName]
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new(CommandProcessor, ChatWindow)
						local obj = setmetatable({}, methods)

						obj.GuiObject = nil
						obj.ChatBarParentFrame = nil
						obj.TextBox = nil
						obj.TextLabel = nil
						obj.GuiObjects = {}
						obj.eGuiObjectsChanged = InstanceNew("BindableEvent")
						obj.GuiObjectsChanged = obj.eGuiObjectsChanged.Event
						obj.TextBoxConnections = {}
						obj.PreviousText = ""

						obj.InCustomState = false
						obj.CustomState = nil

						obj.TargetChannel = nil
						obj.CommandProcessor = CommandProcessor
						obj.ChatWindow = ChatWindow

						obj.TweenPixelsPerSecond = 500
						obj.TargetYSize = 0

						obj.AnimParams = {}
						obj.CalculatingSizeLock = false

						obj.ChannelNameColors = {}

						obj.UserHasChatOff = false

						obj:InitializeAnimParams()

						ChatSettings.SettingsChanged:Connect(function(setting, value)
							if (setting == "ChatBarTextSize") then
								obj:SetTextSize(value)
							end
						end)

						coroutine.wrap(function()
							local success, canLocalUserChat = pcall(function()
								return Chat:CanUserChatAsync(LocalPlayer.UserId)
							end)
							local canChat = success and (RunService:IsStudio() or canLocalUserChat)
							if canChat == false then
								obj.UserHasChatOff = true
								obj:DoLockChatBar()
							end
						end)()


						return obj
					end

					return module
				end
				local function ChatChannel()
					--	// FileName: ChatChannel.lua
					--	// Written by: Xsitsu
					--	// Description: ChatChannel class for handling messages being added and removed from the chat channel.

					local module = {}
					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent

					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function methods:Destroy()
						self.Destroyed = true
					end

					function methods:SetActive(active)
						if active == self.Active then
							return
						end
						if active == false then
							self.MessageLogDisplay:Clear()
						else
							self.MessageLogDisplay:SetCurrentChannelName(self.Name)
							for i = 1, #self.MessageLog do
								self.MessageLogDisplay:AddMessage(self.MessageLog[i])
							end
						end
						self.Active = active
					end

					function methods:UpdateMessageFiltered(messageData)
						local searchIndex = 1
						local searchTable = self.MessageLog
						local messageObj = nil
						while (#searchTable >= searchIndex) do
							local obj = searchTable[searchIndex]

							if (obj.ID == messageData.ID) then
								messageObj = obj
								break
							end

							searchIndex = searchIndex + 1
						end

						if messageObj then
							messageObj.Message = messageData.Message
							messageObj.IsFiltered = true
							if self.Active then
								self.MessageLogDisplay:UpdateMessageFiltered(messageObj)
							end
						else
							-- We have not seen this filtered message before, but we should still add it to our log.
							self:AddMessageToChannelByTimeStamp(messageData)
						end
					end

					function methods:AddMessageToChannel(messageData)
						table.insert(self.MessageLog, messageData)
						if self.Active then
							self.MessageLogDisplay:AddMessage(messageData)
						end
						if #self.MessageLog > ChatSettings.MessageHistoryLengthPerChannel then
							self:RemoveLastMessageFromChannel()
						end
					end

					function methods:InternalAddMessageAtTimeStamp(messageData)
						for i = 1, #self.MessageLog do
							if messageData.Time < self.MessageLog[i].Time then
								table.insert(self.MessageLog, i, messageData)
								return
							end
						end
						table.insert(self.MessageLog, messageData)
					end

					function methods:AddMessagesToChannelByTimeStamp(messageLog, startIndex)
						for i = startIndex, #messageLog do
							self:InternalAddMessageAtTimeStamp(messageLog[i])
						end
						while #self.MessageLog > ChatSettings.MessageHistoryLengthPerChannel do
							table.remove(self.MessageLog, 1)
						end
						if self.Active then
							self.MessageLogDisplay:Clear()
							for i = 1, #self.MessageLog do
								self.MessageLogDisplay:AddMessage(self.MessageLog[i])
							end
						end
					end

					function methods:AddMessageToChannelByTimeStamp(messageData)
						if #self.MessageLog >= 1 then
							-- These are the fast cases to evalutate.
							if self.MessageLog[1].Time > messageData.Time then
								return
							elseif messageData.Time >= self.MessageLog[#self.MessageLog].Time then
								self:AddMessageToChannel(messageData)
								return
							end

							for i = 1, #self.MessageLog do
								if messageData.Time < self.MessageLog[i].Time then
									table.insert(self.MessageLog, i, messageData)

									if #self.MessageLog > ChatSettings.MessageHistoryLengthPerChannel then
										self:RemoveLastMessageFromChannel()
									end

									if self.Active then
										self.MessageLogDisplay:AddMessageAtIndex(messageData, i)
									end

									return
								end
							end
						else
							self:AddMessageToChannel(messageData)
						end
					end

					function methods:RemoveLastMessageFromChannel()
						table.remove(self.MessageLog, 1)

						if self.Active then
							self.MessageLogDisplay:RemoveLastMessage()
						end
					end

					function methods:ClearMessageLog()
						self.MessageLog = {}

						if self.Active then
							self.MessageLogDisplay:Clear()
						end
					end

					function methods:RegisterChannelTab(tab)
						self.ChannelTab = tab
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new(channelName, messageLogDisplay)
						local obj = setmetatable({}, methods)
						obj.Destroyed = false
						obj.Active = false

						obj.MessageLog = {}
						obj.MessageLogDisplay = messageLogDisplay
						obj.ChannelTab = nil
						obj.Name = channelName

						return obj
					end

					return module
				end
				local function ChatWindow()
					--	// FileName: ChatWindow.lua
					--	// Written by: Xsitsu
					--	// Description: Main GUI window piece. Manages ChatBar, ChannelsBar, and ChatChannels.

					local FFlagFixMouseCapture = false do
						local ok, value = pcall(function()
							return UserSettings():IsUserFeatureEnabled("UserFixMouseCapture")
						end)
						if ok then
							FFlagFixMouseCapture = value
						end
					end

					local module = {}

					local Players = game:GetService("Players")
					local Chat = game:GetService("Chat")
					local LocalPlayer = Players.LocalPlayer
					local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

					local PHONE_SCREEN_WIDTH = 640
					local TABLET_SCREEN_WIDTH = 1024

					local DEVICE_PHONE = 1
					local DEVICE_TABLET = 2
					local DEVICE_DESKTOP = 3

					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent
					local moduleChatChannel = ChatChannel()
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
					local CurveUtil = CurveUtilModule()

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					function getClassicChatEnabled()
						if ChatSettings.ClassicChatEnabled ~= nil then
							return ChatSettings.ClassicChatEnabled
						end
						return Players.ClassicChat
					end

					function getBubbleChatEnabled()
						if ChatSettings.BubbleChatEnabled ~= nil then
							return ChatSettings.BubbleChatEnabled
						end
						return Players.BubbleChat
					end

					function bubbleChatOnly()
						return not getClassicChatEnabled() and getBubbleChatEnabled()
					end

					-- only merge property defined on target
					function mergeProps(source, target)
						if not source or not target then return end
						for prop, value in pairs(source) do
							if target[prop] ~= nil then
								target[prop] = value
							end
						end
					end

					function methods:CreateGuiObjects(targetParent)
						local userDefinedChatWindowStyle 
						pcall(function()
							userDefinedChatWindowStyle= Chat:InvokeChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, nil)
						end)

						-- merge the userdefined settings with the ChatSettings
						mergeProps(userDefinedChatWindowStyle, ChatSettings)

						local BaseFrame = Instance.new("Frame")
						BaseFrame.BackgroundTransparency = 1
						BaseFrame.Active = ChatSettings.WindowDraggable
						BaseFrame.Parent = targetParent
						BaseFrame.AutoLocalize = false

						local ChatBarParentFrame = Instance.new("Frame")
						ChatBarParentFrame.Selectable = false
						ChatBarParentFrame.Name = "ChatBarParentFrame"
						ChatBarParentFrame.BackgroundTransparency = 1
						ChatBarParentFrame.Parent = BaseFrame

						local ChannelsBarParentFrame = Instance.new("Frame")
						ChannelsBarParentFrame.Selectable = false
						ChannelsBarParentFrame.Name = "ChannelsBarParentFrame"
						ChannelsBarParentFrame.BackgroundTransparency = 1
						ChannelsBarParentFrame.Position = UDim2.new(0, 0, 0, 0)
						ChannelsBarParentFrame.Parent = BaseFrame

						local ChatChannelParentFrame = Instance.new("Frame")
						ChatChannelParentFrame.Selectable = false
						ChatChannelParentFrame.Name = "ChatChannelParentFrame"
						ChatChannelParentFrame.BackgroundTransparency = 1
						ChatChannelParentFrame.BackgroundColor3 = ChatSettings.BackGroundColor
						ChatChannelParentFrame.BackgroundTransparency = 0.6
						ChatChannelParentFrame.BorderSizePixel = 0
						ChatChannelParentFrame.Parent = BaseFrame

						local ChatResizerFrame = Instance.new("ImageButton")
						ChatResizerFrame.Selectable = false
						ChatResizerFrame.Image = ""
						ChatResizerFrame.BackgroundTransparency = 0.6
						ChatResizerFrame.BorderSizePixel = 0
						ChatResizerFrame.Visible = false
						ChatResizerFrame.BackgroundColor3 = ChatSettings.BackGroundColor
						ChatResizerFrame.Active = true
						if bubbleChatOnly() then
							ChatResizerFrame.Position = UDim2.new(1, -ChatResizerFrame.AbsoluteSize.X, 0, 0)
						else
							ChatResizerFrame.Position = UDim2.new(1, -ChatResizerFrame.AbsoluteSize.X, 1, -ChatResizerFrame.AbsoluteSize.Y)
						end
						ChatResizerFrame.Parent = BaseFrame

						local ResizeIcon = Instance.new("ImageLabel")
						ResizeIcon.Selectable = false
						ResizeIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
						ResizeIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
						ResizeIcon.BackgroundTransparency = 1
						ResizeIcon.Image = "rbxassetid://261880743"
						ResizeIcon.Parent = ChatResizerFrame

						local function GetScreenGuiParent()
							--// Travel up parent list until you find the ScreenGui that the chat window is parented to
							local screenGuiParent = BaseFrame
							while (screenGuiParent and not screenGuiParent:IsA("ScreenGui")) do
								screenGuiParent = screenGuiParent.Parent
							end

							return screenGuiParent
						end


						local deviceType = DEVICE_DESKTOP

						local screenGuiParent = GetScreenGuiParent()
						if (screenGuiParent.AbsoluteSize.X <= PHONE_SCREEN_WIDTH) then
							deviceType = DEVICE_PHONE

						elseif (screenGuiParent.AbsoluteSize.X <= TABLET_SCREEN_WIDTH) then
							deviceType = DEVICE_TABLET

						end

						local checkSizeLock = false
						local function doCheckSizeBounds()
							if (checkSizeLock) then return end
							checkSizeLock = true

							if (not BaseFrame:IsDescendantOf(PlayerGui)) then return end

							local screenGuiParent = GetScreenGuiParent()

							local minWinSize = ChatSettings.MinimumWindowSize
							local maxWinSize = ChatSettings.MaximumWindowSize

							local forceMinY = ChannelsBarParentFrame.AbsoluteSize.Y + ChatBarParentFrame.AbsoluteSize.Y

							local minSizePixelX = (minWinSize.X.Scale * screenGuiParent.AbsoluteSize.X) + minWinSize.X.Offset
							local minSizePixelY = math.max((minWinSize.Y.Scale * screenGuiParent.AbsoluteSize.Y) + minWinSize.Y.Offset, forceMinY)

							local maxSizePixelX = (maxWinSize.X.Scale * screenGuiParent.AbsoluteSize.X) + maxWinSize.X.Offset
							local maxSizePixelY = (maxWinSize.Y.Scale * screenGuiParent.AbsoluteSize.Y) + maxWinSize.Y.Offset

							local absSizeX = BaseFrame.AbsoluteSize.X
							local absSizeY = BaseFrame.AbsoluteSize.Y

							if (absSizeX < minSizePixelX) then
								local offset = UDim2.new(0, minSizePixelX - absSizeX, 0, 0)
								BaseFrame.Size = BaseFrame.Size + offset

							elseif (absSizeX > maxSizePixelX) then
								local offset = UDim2.new(0, maxSizePixelX - absSizeX, 0, 0)
								BaseFrame.Size = BaseFrame.Size + offset

							end

							if (absSizeY < minSizePixelY) then
								local offset = UDim2.new(0, 0, 0, minSizePixelY - absSizeY)
								BaseFrame.Size = BaseFrame.Size + offset

							elseif (absSizeY > maxSizePixelY) then
								local offset = UDim2.new(0, 0, 0, maxSizePixelY - absSizeY)
								BaseFrame.Size = BaseFrame.Size + offset

							end

							local xScale = BaseFrame.AbsoluteSize.X / screenGuiParent.AbsoluteSize.X
							local yScale = BaseFrame.AbsoluteSize.Y / screenGuiParent.AbsoluteSize.Y

							-- cap chat window scale at a value smaller than 0.5 to prevent center of screen overlap
							if FFlagFixMouseCapture then 
								xScale = math.min(xScale, 0.45)
								yScale = math.min(xScale, 0.45)
							end

							BaseFrame.Size = UDim2.new(xScale, 0, yScale, 0)

							checkSizeLock = false
						end


						BaseFrame.Changed:Connect(function(prop)
							if (prop == "AbsoluteSize") then
								doCheckSizeBounds()
							end
						end)



						ChatResizerFrame.DragBegin:Connect(function(startUdim)
							BaseFrame.Draggable = false
						end)

						local function UpdatePositionFromDrag(atPos)
							if ChatSettings.WindowDraggable == false and ChatSettings.WindowResizable == false then
								return
							end
							local newSize = atPos - BaseFrame.AbsolutePosition + ChatResizerFrame.AbsoluteSize
							BaseFrame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
							if bubbleChatOnly() then
								ChatResizerFrame.Position = UDim2.new(1, -ChatResizerFrame.AbsoluteSize.X, 0, 0)
							else
								ChatResizerFrame.Position = UDim2.new(1, -ChatResizerFrame.AbsoluteSize.X, 1, -ChatResizerFrame.AbsoluteSize.Y)
							end
						end

						ChatResizerFrame.DragStopped:Connect(function(endX, endY)
							BaseFrame.Draggable = ChatSettings.WindowDraggable
							--UpdatePositionFromDrag(Vector2.new(endX, endY))
						end)

						local resizeLock = false
						ChatResizerFrame.Changed:Connect(function(prop)
							if (prop == "AbsolutePosition" and not BaseFrame.Draggable) then
								if (resizeLock) then return end
								resizeLock = true

								UpdatePositionFromDrag(ChatResizerFrame.AbsolutePosition)

								resizeLock = false
							end
						end)

						local function CalculateChannelsBarPixelSize(textSize)
							if (deviceType == DEVICE_PHONE) then
								textSize = textSize or ChatSettings.ChatChannelsTabTextSizePhone
							else
								textSize = textSize or ChatSettings.ChatChannelsTabTextSize
							end

							local channelsBarTextYSize = textSize
							local chatChannelYSize = math.max(32, channelsBarTextYSize + 8) + 2

							return chatChannelYSize
						end

						local function CalculateChatBarPixelSize(textSize)
							if (deviceType == DEVICE_PHONE) then
								textSize = textSize or ChatSettings.ChatBarTextSizePhone
							else
								textSize = textSize or ChatSettings.ChatBarTextSize
							end

							local chatBarTextSizeY = textSize
							local chatBarYSize = chatBarTextSizeY + (7 * 2) + (5 * 2)

							return chatBarYSize
						end

						if bubbleChatOnly() then
							ChatBarParentFrame.Position = UDim2.new(0, 0, 0, 0)
							ChannelsBarParentFrame.Visible = false
							ChannelsBarParentFrame.Active = false
							ChatChannelParentFrame.Visible = false
							ChatChannelParentFrame.Active = false

							local useXScale = 0
							local useXOffset = 0

							local screenGuiParent = GetScreenGuiParent()

							if (deviceType == DEVICE_PHONE) then
								useXScale = ChatSettings.DefaultWindowSizePhone.X.Scale
								useXOffset = ChatSettings.DefaultWindowSizePhone.X.Offset

							elseif (deviceType == DEVICE_TABLET) then
								useXScale = ChatSettings.DefaultWindowSizeTablet.X.Scale
								useXOffset = ChatSettings.DefaultWindowSizeTablet.X.Offset

							else
								useXScale = ChatSettings.DefaultWindowSizeDesktop.X.Scale
								useXOffset = ChatSettings.DefaultWindowSizeDesktop.X.Offset

							end

							local chatBarYSize = CalculateChatBarPixelSize()

							BaseFrame.Size = UDim2.new(useXScale, useXOffset, 0, chatBarYSize)
							BaseFrame.Position = ChatSettings.DefaultWindowPosition

						else

							local screenGuiParent = GetScreenGuiParent()

							if (deviceType == DEVICE_PHONE) then
								BaseFrame.Size = ChatSettings.DefaultWindowSizePhone

							elseif (deviceType == DEVICE_TABLET) then
								BaseFrame.Size = ChatSettings.DefaultWindowSizeTablet

							else
								BaseFrame.Size = ChatSettings.DefaultWindowSizeDesktop

							end

							BaseFrame.Position = ChatSettings.DefaultWindowPosition

						end

						if (deviceType == DEVICE_PHONE) then
							ChatSettings.ChatWindowTextSize = ChatSettings.ChatWindowTextSizePhone
							ChatSettings.ChatChannelsTabTextSize = ChatSettings.ChatChannelsTabTextSizePhone
							ChatSettings.ChatBarTextSize = ChatSettings.ChatBarTextSizePhone
						end

						local function UpdateDraggable(enabled)
							BaseFrame.Active = enabled
							BaseFrame.Draggable = enabled
						end

						local function UpdateResizable(enabled)
							ChatResizerFrame.Visible = enabled
							ChatResizerFrame.Draggable = enabled

							local frameSizeY = ChatBarParentFrame.Size.Y.Offset

							if (enabled) then
								ChatBarParentFrame.Size = UDim2.new(1, -frameSizeY - 2, 0, frameSizeY)
								if not bubbleChatOnly() then
									ChatBarParentFrame.Position = UDim2.new(0, 0, 1, -frameSizeY)
								end
							else
								ChatBarParentFrame.Size = UDim2.new(1, 0, 0, frameSizeY)
								if not bubbleChatOnly() then
									ChatBarParentFrame.Position = UDim2.new(0, 0, 1, -frameSizeY)
								end
							end
						end

						local function UpdateChatChannelParentFrameSize()
							local channelsBarSize = CalculateChannelsBarPixelSize()
							local chatBarSize = CalculateChatBarPixelSize()

							if (ChatSettings.ShowChannelsBar) then
								ChatChannelParentFrame.Size = UDim2.new(1, 0, 1, -(channelsBarSize + chatBarSize + 2 + 2))
								ChatChannelParentFrame.Position = UDim2.new(0, 0, 0, channelsBarSize + 2)

							else
								ChatChannelParentFrame.Size = UDim2.new(1, 0, 1, -(chatBarSize + 2 + 2))
								ChatChannelParentFrame.Position = UDim2.new(0, 0, 0, 2)

							end
						end

						local function UpdateChatChannelsTabTextSize(size)
							local channelsBarSize = CalculateChannelsBarPixelSize(size)
							ChannelsBarParentFrame.Size = UDim2.new(1, 0, 0, channelsBarSize)

							UpdateChatChannelParentFrameSize()
						end

						local function UpdateChatBarTextSize(size)
							local chatBarSize = CalculateChatBarPixelSize(size)

							ChatBarParentFrame.Size = UDim2.new(1, 0, 0, chatBarSize)
							if not bubbleChatOnly() then
								ChatBarParentFrame.Position = UDim2.new(0, 0, 1, -chatBarSize)
							end

							ChatResizerFrame.Size = UDim2.new(0, chatBarSize, 0, chatBarSize)
							ChatResizerFrame.Position = UDim2.new(1, -chatBarSize, 1, -chatBarSize)

							UpdateChatChannelParentFrameSize()
							UpdateResizable(ChatSettings.WindowResizable)
						end

						local function UpdateShowChannelsBar(enabled)
							ChannelsBarParentFrame.Visible = enabled
							UpdateChatChannelParentFrameSize()
						end

						UpdateChatChannelsTabTextSize(ChatSettings.ChatChannelsTabTextSize)
						UpdateChatBarTextSize(ChatSettings.ChatBarTextSize)
						UpdateDraggable(ChatSettings.WindowDraggable)
						UpdateResizable(ChatSettings.WindowResizable)
						UpdateShowChannelsBar(ChatSettings.ShowChannelsBar)

						ChatSettings.SettingsChanged:Connect(function(setting, value)
							if (setting == "WindowDraggable") then
								UpdateDraggable(value)

							elseif (setting == "WindowResizable") then
								UpdateResizable(value)

							elseif (setting == "ChatChannelsTabTextSize") then
								UpdateChatChannelsTabTextSize(value)

							elseif (setting == "ChatBarTextSize") then
								UpdateChatBarTextSize(value)

							elseif (setting == "ShowChannelsBar") then
								UpdateShowChannelsBar(value)

							end
						end)

						self.GuiObject = BaseFrame

						self.GuiObjects.BaseFrame = BaseFrame
						self.GuiObjects.ChatBarParentFrame = ChatBarParentFrame
						self.GuiObjects.ChannelsBarParentFrame = ChannelsBarParentFrame
						self.GuiObjects.ChatChannelParentFrame = ChatChannelParentFrame
						self.GuiObjects.ChatResizerFrame = ChatResizerFrame
						self.GuiObjects.ResizeIcon = ResizeIcon
						self:AnimGuiObjects()
					end

					function methods:GetChatBar()
						return self.ChatBar
					end

					function methods:RegisterChatBar(ChatBar)
						self.ChatBar = ChatBar
						self.ChatBar:CreateGuiObjects(self.GuiObjects.ChatBarParentFrame)
					end

					function methods:RegisterChannelsBar(ChannelsBar)
						self.ChannelsBar = ChannelsBar
						self.ChannelsBar:CreateGuiObjects(self.GuiObjects.ChannelsBarParentFrame)
					end

					function methods:RegisterMessageLogDisplay(MessageLogDisplay)
						self.MessageLogDisplay = MessageLogDisplay
						self.MessageLogDisplay.GuiObject.Parent = self.GuiObjects.ChatChannelParentFrame
					end

					function methods:AddChannel(channelName)
						if (self:GetChannel(channelName)) then
							error("Channel '" .. channelName .. "' already exists!")
							return
						end

						local channel = moduleChatChannel.new(channelName, self.MessageLogDisplay)
						self.Channels[channelName:lower()] = channel

						channel:SetActive(false)

						local tab = self.ChannelsBar:AddChannelTab(channelName)
						tab.NameTag.MouseButton1Click:Connect(function()
							self:SwitchCurrentChannel(channelName)
						end)

						channel:RegisterChannelTab(tab)

						return channel
					end

					function methods:GetFirstChannel()
						--// Channels are not indexed numerically, so this function is necessary.
						--// Grabs and returns the first channel it happens to, or nil if none exist.
						for i, v in pairs(self.Channels) do
							return v
						end
						return nil
					end

					function methods:RemoveChannel(channelName)
						if (not self:GetChannel(channelName)) then
							error("Channel '" .. channelName .. "' does not exist!")
						end

						local indexName = channelName:lower()

						local needsChannelSwitch = false
						if (self.Channels[indexName] == self:GetCurrentChannel()) then
							needsChannelSwitch = true

							self:SwitchCurrentChannel(nil)
						end

						self.Channels[indexName]:Destroy()
						self.Channels[indexName] = nil

						self.ChannelsBar:RemoveChannelTab(channelName)

						if (needsChannelSwitch) then
							local generalChannelExists = (self:GetChannel(ChatSettings.GeneralChannelName) ~= nil)
							local removingGeneralChannel = (indexName == ChatSettings.GeneralChannelName:lower())

							local targetSwitchChannel = nil

							if (generalChannelExists and not removingGeneralChannel) then
								targetSwitchChannel = ChatSettings.GeneralChannelName
							else
								local firstChannel = self:GetFirstChannel()
								targetSwitchChannel = (firstChannel and firstChannel.Name or nil)
							end

							self:SwitchCurrentChannel(targetSwitchChannel)
						end

						if not ChatSettings.ShowChannelsBar then
							if self.ChatBar.TargetChannel == channelName then
								self.ChatBar:SetChannelTarget(ChatSettings.GeneralChannelName)
							end
						end
					end

					function methods:GetChannel(channelName)
						return channelName and self.Channels[channelName:lower()] or nil
					end

					function methods:GetTargetMessageChannel()
						if (not ChatSettings.ShowChannelsBar) then
							return self.ChatBar.TargetChannel
						else
							local curChannel = self:GetCurrentChannel()
							return curChannel and curChannel.Name
						end
					end

					function methods:GetCurrentChannel()
						return self.CurrentChannel
					end

					function methods:SwitchCurrentChannel(channelName)
						if (not ChatSettings.ShowChannelsBar) then
							local targ = self:GetChannel(channelName)
							if (targ) then
								self.ChatBar:SetChannelTarget(targ.Name)
							end

							channelName = ChatSettings.GeneralChannelName
						end

						local cur = self:GetCurrentChannel()
						local new = self:GetChannel(channelName)
						if new == nil then
							error(string.format("Channel '%s' does not exist.", channelName))
						end

						if (new ~= cur) then
							if (cur) then
								cur:SetActive(false)
								local tab = self.ChannelsBar:GetChannelTab(cur.Name)
								tab:SetActive(false)
							end

							if (new) then
								new:SetActive(true)
								local tab = self.ChannelsBar:GetChannelTab(new.Name)
								tab:SetActive(true)
							end

							self.CurrentChannel = new
						end

					end

					function methods:UpdateFrameVisibility()
						self.GuiObject.Visible = (self.Visible and self.CoreGuiEnabled)
					end

					function methods:GetVisible()
						return self.Visible
					end

					function methods:SetVisible(visible)
						self.Visible = visible
						self:UpdateFrameVisibility()
					end

					function methods:GetCoreGuiEnabled()
						return self.CoreGuiEnabled
					end

					function methods:SetCoreGuiEnabled(enabled)
						self.CoreGuiEnabled = enabled
						self:UpdateFrameVisibility()
					end

					function methods:EnableResizable()
						self.GuiObjects.ChatResizerFrame.Active = true
					end

					function methods:DisableResizable()
						self.GuiObjects.ChatResizerFrame.Active = false
					end

					function methods:FadeOutBackground(duration)
						self.ChannelsBar:FadeOutBackground(duration)
						self.MessageLogDisplay:FadeOutBackground(duration)
						self.ChatBar:FadeOutBackground(duration)

						self.AnimParams.Background_TargetTransparency = 1
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeInBackground(duration)
						self.ChannelsBar:FadeInBackground(duration)
						self.MessageLogDisplay:FadeInBackground(duration)
						self.ChatBar:FadeInBackground(duration)

						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(duration)
					end

					function methods:FadeOutText(duration)
						self.MessageLogDisplay:FadeOutText(duration)
						self.ChannelsBar:FadeOutText(duration)
					end

					function methods:FadeInText(duration)
						self.MessageLogDisplay:FadeInText(duration)
						self.ChannelsBar:FadeInText(duration)
					end

					function methods:AnimGuiObjects()
						self.GuiObjects.ChatChannelParentFrame.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.ChatResizerFrame.BackgroundTransparency = self.AnimParams.Background_CurrentTransparency
						self.GuiObjects.ResizeIcon.ImageTransparency = self.AnimParams.Background_CurrentTransparency
					end

					function methods:InitializeAnimParams()
						self.AnimParams.Background_TargetTransparency = 0.6
						self.AnimParams.Background_CurrentTransparency = 0.6
						self.AnimParams.Background_NormalizedExptValue = CurveUtil:NormalizedDefaultExptValueInSeconds(0)
					end

					function methods:Update(dtScale)
						self.ChatBar:Update(dtScale)
						self.ChannelsBar:Update(dtScale)
						self.MessageLogDisplay:Update(dtScale)

						self.AnimParams.Background_CurrentTransparency = CurveUtil:Expt(
							self.AnimParams.Background_CurrentTransparency,
							self.AnimParams.Background_TargetTransparency,
							self.AnimParams.Background_NormalizedExptValue,
							dtScale
						)

						self:AnimGuiObjects()
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)

						obj.GuiObject = nil
						obj.GuiObjects = {}

						obj.ChatBar = nil
						obj.ChannelsBar = nil
						obj.MessageLogDisplay = nil

						obj.Channels = {}
						obj.CurrentChannel = nil

						obj.Visible = true
						obj.CoreGuiEnabled = true

						obj.AnimParams = {}

						obj:InitializeAnimParams()

						return obj
					end

					return module
				end
				local function CommandProcessor()
					--	// FileName: ProcessCommands.lua
					--	// Written by: TheGamer101
					--	// Description: Module for processing commands using the client CommandModules

					local module = {}
					local methods = {}
					methods.__index = methods

					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local commandModules = clientChatModules:WaitForChild("CommandModules")
					local commandUtil = require(commandModules:WaitForChild("Util"))
					local modulesFolder = script.Parent
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))

					function methods:SetupCommandProcessors()
						local commands = commandModules:GetChildren()
						for i = 1, #commands do
							if commands[i]:IsA("ModuleScript") then
								if commands[i].Name ~= "Util" then
									local commandProcessor = require(commands[i])
									local processorType = commandProcessor[commandUtil.KEY_COMMAND_PROCESSOR_TYPE]
									local processorFunction = commandProcessor[commandUtil.KEY_PROCESSOR_FUNCTION]
									if processorType == commandUtil.IN_PROGRESS_MESSAGE_PROCESSOR then
										table.insert(self.InProgressMessageProcessors, processorFunction)
									elseif processorType == commandUtil.COMPLETED_MESSAGE_PROCESSOR then
										table.insert(self.CompletedMessageProcessors, processorFunction)
									end
								end
							end
						end
					end

					function methods:ProcessCompletedChatMessage(message, ChatWindow)
						for i = 1, #self.CompletedMessageProcessors do
							local processedCommand = self.CompletedMessageProcessors[i](message, ChatWindow, ChatSettings)
							if processedCommand then
								return true
							end
						end
						return false
					end

					function methods:ProcessInProgressChatMessage(message, ChatWindow, ChatBar)
						for i = 1, #self.InProgressMessageProcessors do
							local customState = self.InProgressMessageProcessors[i](message, ChatWindow, ChatBar, ChatSettings)
							if customState then
								return customState
							end
						end
						return nil
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)

						obj.CompletedMessageProcessors = {}
						obj.InProgressMessageProcessors = {}

						obj:SetupCommandProcessors()

						return obj
					end

					return module
				end
				local function MessageLabelCreator()
					--	// FileName: MessageLabelCreator.lua
					--	// Written by: Xsitsu
					--	// Description: Module to handle taking text and creating stylized GUI objects for display in ChatWindow.

					local OBJECT_POOL_SIZE = 50

					local module = {}
					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local messageCreatorModules = clientChatModules:WaitForChild("MessageCreatorModules")
					local messageCreatorUtil = require(messageCreatorModules:WaitForChild("Util"))
					local modulesFolder = script.Parent
					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
					local moduleObjectPool = ObjectPool()
					local MessageSender = MessageSenderModule()

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					-- merge properties on both table to target
					function mergeProps(source, target)
						if not source then return end
						for prop, value in pairs(source) do
							target[prop] = value
						end
					end

					function ReturnToObjectPoolRecursive(instance, objectPool)
						local children = instance:GetChildren()
						for i = 1, #children do
							ReturnToObjectPoolRecursive(children[i], objectPool)
						end
						instance.Parent = nil
						objectPool:ReturnInstance(instance)
					end

					function GetMessageCreators()
						local typeToFunction = {}
						local creators = messageCreatorModules:GetChildren()
						for i = 1, #creators do
							if creators[i]:IsA("ModuleScript") then
								if creators[i].Name ~= "Util" then
									local creator = require(creators[i])
									typeToFunction[creator[messageCreatorUtil.KEY_MESSAGE_TYPE]] = creator[messageCreatorUtil.KEY_CREATOR_FUNCTION]
								end
							end
						end
						return typeToFunction
					end

					function methods:WrapIntoMessageObject(messageData, createdMessageObject)
						local BaseFrame = createdMessageObject[messageCreatorUtil.KEY_BASE_FRAME]
						local BaseMessage = nil
						if messageCreatorUtil.KEY_BASE_MESSAGE then
							BaseMessage = createdMessageObject[messageCreatorUtil.KEY_BASE_MESSAGE]
						end
						local UpdateTextFunction = createdMessageObject[messageCreatorUtil.KEY_UPDATE_TEXT_FUNC]
						local GetHeightFunction = createdMessageObject[messageCreatorUtil.KEY_GET_HEIGHT]
						local FadeInFunction = createdMessageObject[messageCreatorUtil.KEY_FADE_IN]
						local FadeOutFunction = createdMessageObject[messageCreatorUtil.KEY_FADE_OUT]
						local UpdateAnimFunction = createdMessageObject[messageCreatorUtil.KEY_UPDATE_ANIMATION]

						local obj = {}

						obj.ID = messageData.ID
						obj.BaseFrame = BaseFrame
						obj.BaseMessage = BaseMessage
						obj.UpdateTextFunction = UpdateTextFunction or function() --[[warn("NO MESSAGE RESIZE FUNCTION")]] end
						obj.GetHeightFunction = GetHeightFunction
						obj.FadeInFunction = FadeInFunction
						obj.FadeOutFunction = FadeOutFunction
						obj.UpdateAnimFunction = UpdateAnimFunction
						obj.ObjectPool = self.ObjectPool
						obj.Destroyed = false

						function obj:Destroy()
							ReturnToObjectPoolRecursive(self.BaseFrame, self.ObjectPool)
							self.Destroyed = true
						end

						return obj
					end

					function methods:CreateMessageLabel(messageData, currentChannelName)

						messageData.Channel = currentChannelName
						local extraDeveloperFormatTable
						pcall(function()
							extraDeveloperFormatTable = Chat:InvokeChatCallback(Enum.ChatCallbackType.OnClientFormattingMessage, messageData)
						end)
						messageData.ExtraData = messageData.ExtraData or {}
						mergeProps(extraDeveloperFormatTable, messageData.ExtraData)

						local messageType = messageData.MessageType
						if self.MessageCreators[messageType] then
							local createdMessageObject = self.MessageCreators[messageType](messageData, currentChannelName)
							if createdMessageObject then
								return self:WrapIntoMessageObject(messageData, createdMessageObject)
							end
						elseif self.DefaultCreatorType then
							local createdMessageObject = self.MessageCreators[self.DefaultCreatorType](messageData, currentChannelName)
							if createdMessageObject then
								return self:WrapIntoMessageObject(messageData, createdMessageObject)
							end
						else
							error("No message creator available for message type: " ..messageType)
						end
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)

						obj.ObjectPool = moduleObjectPool.new(OBJECT_POOL_SIZE)
						obj.MessageCreators = GetMessageCreators()
						obj.DefaultCreatorType = messageCreatorUtil.DEFAULT_MESSAGE_CREATOR

						messageCreatorUtil:RegisterObjectPool(obj.ObjectPool)

						return obj
					end

					function module:GetStringTextBounds(text, font, textSize, sizeBounds)
						return messageCreatorUtil:GetStringTextBounds(text, font, textSize, sizeBounds)
					end

					return module
				end
				local function MessageLogDisplay()
					--	// FileName: MessageLogDisplay.lua
					--	// Written by: Xsitsu, TheGamer101
					--	// Description: ChatChannel window for displaying messages.

					local module = {}
					module.ScrollBarThickness = 4

					--////////////////////////////// Include
					--//////////////////////////////////////
					local Chat = game:GetService("Chat")
					local clientChatModules = Chat:WaitForChild("ClientChatModules")
					local modulesFolder = script.Parent
					local moduleMessageLabelCreator = MessageLabelCreator()
					local CurveUtil = CurveUtilModule()

					local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))

					local MessageLabelCreator = moduleMessageLabelCreator.new()

					--////////////////////////////// Methods
					--//////////////////////////////////////
					local methods = {}
					methods.__index = methods

					local function CreateGuiObjects()
						local BaseFrame = Instance.new("Frame")
						BaseFrame.Selectable = false
						BaseFrame.Size = UDim2.new(1, 0, 1, 0)
						BaseFrame.BackgroundTransparency = 1

						local Scroller = Instance.new("ScrollingFrame")
						Scroller.Selectable = ChatSettings.GamepadNavigationEnabled
						Scroller.Name = "Scroller"
						Scroller.BackgroundTransparency = 1
						Scroller.BorderSizePixel = 0
						Scroller.Position = UDim2.new(0, 0, 0, 3)
						Scroller.Size = UDim2.new(1, -4, 1, -6)
						Scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
						Scroller.ScrollBarThickness = module.ScrollBarThickness
						Scroller.Active = true
						Scroller.Parent = BaseFrame

						local Layout = Instance.new("UIListLayout")
						Layout.SortOrder = Enum.SortOrder.LayoutOrder
						Layout.Parent = Scroller

						return BaseFrame, Scroller, Layout
					end

					function methods:Destroy()
						self.GuiObject:Destroy()
						self.Destroyed = true
					end

					function methods:SetActive(active)
						self.GuiObject.Visible = active
					end

					function methods:UpdateMessageFiltered(messageData)
						local messageObject = nil
						local searchIndex = 1
						local searchTable = self.MessageObjectLog

						while (#searchTable >= searchIndex) do
							local obj = searchTable[searchIndex]

							if obj.ID == messageData.ID then
								messageObject = obj
								break
							end

							searchIndex = searchIndex + 1
						end

						if messageObject then
							messageObject.UpdateTextFunction(messageData)
							self:PositionMessageLabelInWindow(messageObject, searchIndex)
						end
					end

					function methods:AddMessage(messageData)
						self:WaitUntilParentedCorrectly()

						local messageObject = MessageLabelCreator:CreateMessageLabel(messageData, self.CurrentChannelName)
						if messageObject == nil then
							return
						end

						table.insert(self.MessageObjectLog, messageObject)
						self:PositionMessageLabelInWindow(messageObject, #self.MessageObjectLog)
					end

					function methods:AddMessageAtIndex(messageData, index)
						local messageObject = MessageLabelCreator:CreateMessageLabel(messageData, self.CurrentChannelName)
						if messageObject == nil then
							return
						end

						table.insert(self.MessageObjectLog, index, messageObject)

						self:PositionMessageLabelInWindow(messageObject, index)
					end

					function methods:RemoveLastMessage()
						self:WaitUntilParentedCorrectly()

						local lastMessage = self.MessageObjectLog[1]

						lastMessage:Destroy()
						table.remove(self.MessageObjectLog, 1)
					end

					function methods:IsScrolledDown()
						local yCanvasSize = self.Scroller.CanvasSize.Y.Offset
						local yContainerSize = self.Scroller.AbsoluteWindowSize.Y
						local yScrolledPosition = self.Scroller.CanvasPosition.Y

						return (yCanvasSize < yContainerSize or
							yCanvasSize - yScrolledPosition <= yContainerSize + 5)
					end

					function methods:UpdateMessageTextHeight(messageObject)
						local baseFrame = messageObject.BaseFrame
						for i = 1, 10 do
							if messageObject.BaseMessage.TextFits then
								break
							end

							local trySize = self.Scroller.AbsoluteSize.X - i
							baseFrame.Size = UDim2.new(1, 0, 0, messageObject.GetHeightFunction(trySize))
						end
					end

					function methods:PositionMessageLabelInWindow(messageObject, index)
						self:WaitUntilParentedCorrectly()

						local wasScrolledDown = self:IsScrolledDown()

						local baseFrame = messageObject.BaseFrame

						local layoutOrder = 1
						if self.MessageObjectLog[index - 1] then
							if index == #self.MessageObjectLog then
								layoutOrder = self.MessageObjectLog[index - 1].BaseFrame.LayoutOrder + 1
							else
								layoutOrder = self.MessageObjectLog[index - 1].BaseFrame.LayoutOrder
							end
						end
						baseFrame.LayoutOrder = layoutOrder

						baseFrame.Size = UDim2.new(1, 0, 0, messageObject.GetHeightFunction(self.Scroller.AbsoluteSize.X))
						baseFrame.Parent = self.Scroller

						if messageObject.BaseMessage then
							self:UpdateMessageTextHeight(messageObject)
						end

						if wasScrolledDown then
							self.Scroller.CanvasPosition = Vector2.new(
								0, math.max(0, self.Scroller.CanvasSize.Y.Offset - self.Scroller.AbsoluteSize.Y))
						end
					end

					function methods:ReorderAllMessages()
						self:WaitUntilParentedCorrectly()

						--// Reordering / reparenting with a size less than 1 causes weird glitches to happen
						-- with scrolling as repositioning happens.
						if self.GuiObject.AbsoluteSize.Y < 1 then return end

						local oldCanvasPositon = self.Scroller.CanvasPosition
						local wasScrolledDown = self:IsScrolledDown()

						for _, messageObject in pairs(self.MessageObjectLog) do
							self:UpdateMessageTextHeight(messageObject)
						end

						if not wasScrolledDown then
							self.Scroller.CanvasPosition = oldCanvasPositon
						else
							self.Scroller.CanvasPosition = Vector2.new(
								0, math.max(0, self.Scroller.CanvasSize.Y.Offset - self.Scroller.AbsoluteSize.Y))
						end
					end

					function methods:Clear()
						for _, v in pairs(self.MessageObjectLog) do
							v:Destroy()
						end
						self.MessageObjectLog = {}
					end

					function methods:SetCurrentChannelName(name)
						self.CurrentChannelName = name
					end

					function methods:FadeOutBackground(duration)
						--// Do nothing
					end

					function methods:FadeInBackground(duration)
						--// Do nothing
					end

					function methods:FadeOutText(duration)
						for i = 1, #self.MessageObjectLog do
							if self.MessageObjectLog[i].FadeOutFunction then
								self.MessageObjectLog[i].FadeOutFunction(duration, CurveUtil)
							end
						end
					end

					function methods:FadeInText(duration)
						for i = 1, #self.MessageObjectLog do
							if self.MessageObjectLog[i].FadeInFunction then
								self.MessageObjectLog[i].FadeInFunction(duration, CurveUtil)
							end
						end
					end

					function methods:Update(dtScale)
						for i = 1, #self.MessageObjectLog do
							if self.MessageObjectLog[i].UpdateAnimFunction then
								self.MessageObjectLog[i].UpdateAnimFunction(dtScale, CurveUtil)
							end
						end
					end

					--// ToDo: Move to common modules
					function methods:WaitUntilParentedCorrectly()
						while (not self.GuiObject:IsDescendantOf(LocalPlayer)) do
							self.GuiObject.AncestryChanged:Wait()
						end
					end

					--///////////////////////// Constructors
					--//////////////////////////////////////

					function module.new()
						local obj = setmetatable({}, methods)
						obj.Destroyed = false

						local BaseFrame, Scroller, Layout = CreateGuiObjects()
						obj.GuiObject = BaseFrame
						obj.Scroller = Scroller
						obj.Layout = Layout

						obj.MessageObjectLog = {}

						obj.Name = "MessageLogDisplay"
						obj.GuiObject.Name = "Frame_" .. obj.Name

						obj.CurrentChannelName = ""

						obj.GuiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
							spawn(function() obj:ReorderAllMessages() end)
						end)

						local wasScrolledDown = true

						obj.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
							local size = obj.Layout.AbsoluteContentSize
							obj.Scroller.CanvasSize = UDim2.new(0, 0, 0, size.Y)
							if wasScrolledDown then
								local windowSize = obj.Scroller.AbsoluteWindowSize
								obj.Scroller.CanvasPosition = Vector2.new(0, size.Y - windowSize.Y)
							end
						end)

						obj.Scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
							wasScrolledDown = obj:IsScrolledDown()
						end)

						return obj
					end

					return module
				end
				--	// FileName: ChatMain.lua
				--	// Written by: Xsitsu
				--	// Description: Main module to handle initializing chat window UI and hooking up events to individual UI pieces.

				local moduleApiTable = {}

				--// This section of code waits until all of the necessary RemoteEvents are found in EventFolder.
				--// I have to do some weird stuff since people could potentially already have pre-existing
				--// things in a folder with the same name, and they may have different class types.
				--// I do the useEvents thing and set EventFolder to useEvents so I can have a pseudo folder that
				--// the rest of the code can interface with and have the guarantee that the RemoteEvents they want
				--// exist with their desired names.

				local FFlagFixChatWindowHoverOver = false do
					local ok, value = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserFixChatWindowHoverOver")
					end)
					if ok then
						FFlagFixChatWindowHoverOver = value
					end
				end

				local FFlagFixMouseCapture = false do
					local ok, value = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserFixMouseCapture")
					end)
					if ok then
						FFlagFixMouseCapture = value
					end
				end

				local FFlagUserHandleChatHotKeyWithContextActionService = false do
					local ok, value = pcall(function()
						return UserSettings():IsUserFeatureEnabled("UserHandleChatHotKeyWithContextActionService")
					end)
					if ok then
						FFlagUserHandleChatHotKeyWithContextActionService = value
					end
				end

				local FILTER_MESSAGE_TIMEOUT = 60

				local RunService = game:GetService("RunService")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Chat = game:GetService("Chat")
				local StarterGui = game:GetService("StarterGui")
				--local ContextActionService = game:GetService("ContextActionService")

				local DefaultChatSystemChatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
				local EventFolder = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
				local clientChatModules = Chat:WaitForChild("ClientChatModules")
				local ChatConstants = require(clientChatModules:WaitForChild("ChatConstants"))
				local ChatSettings = require(clientChatModules:WaitForChild("ChatSettings"))
				local messageCreatorModules = clientChatModules:WaitForChild("MessageCreatorModules")
				local MessageCreatorUtil = require(messageCreatorModules:WaitForChild("Util"))

				local ChatLocalization = nil
				pcall(function() ChatLocalization = require(game:GetService("Chat").ClientChatModules.ChatLocalization) end)
				if ChatLocalization == nil then ChatLocalization = {} function ChatLocalization:Get(key,default) return default end end

				local numChildrenRemaining = 10 -- #waitChildren returns 0 because it's a dictionary
				local waitChildren =
					{
						OnNewMessage = "RemoteEvent",
						OnMessageDoneFiltering = "RemoteEvent",
						OnNewSystemMessage = "RemoteEvent",
						OnChannelJoined = "RemoteEvent",
						OnChannelLeft = "RemoteEvent",
						OnMuted = "RemoteEvent",
						OnUnmuted = "RemoteEvent",
						OnMainChannelSet = "RemoteEvent",

						SayMessageRequest = "RemoteEvent",
						GetInitDataRequest = "RemoteFunction",
					}
				-- waitChildren/EventFolder does not contain all the remote events, because the server version could be older than the client version.
				-- In that case it would not create the new events.
				-- These events are accessed directly from DefaultChatSystemChatEvents

				local useEvents = {}

				local FoundAllEventsEvent = InstanceNew("BindableEvent")

				function TryRemoveChildWithVerifyingIsCorrectType(child)
					if (waitChildren[child.Name] and child:IsA(waitChildren[child.Name])) then
						waitChildren[child.Name] = nil
						useEvents[child.Name] = child
						numChildrenRemaining = numChildrenRemaining - 1
					end
				end

				for i, child in pairs(EventFolder:GetChildren()) do
					TryRemoveChildWithVerifyingIsCorrectType(child)
				end

				if (numChildrenRemaining > 0) then
					local con = EventFolder.ChildAdded:Connect(function(child)
						TryRemoveChildWithVerifyingIsCorrectType(child)
						if (numChildrenRemaining < 1) then
							FoundAllEventsEvent:Fire()
						end
					end)

					FoundAllEventsEvent.Event:Wait()
					con:Disconnect()

					FoundAllEventsEvent:Destroy()
				end

				EventFolder = useEvents



				--// Rest of code after waiting for correct events.

				local UserInputService = game:GetService("UserInputService")
				local RunService = game:GetService("RunService")

				local Players = game:GetService("Players")
				local LocalPlayer = Players.LocalPlayer

				while not LocalPlayer do
					Players.ChildAdded:Wait()
					LocalPlayer = Players.LocalPlayer
				end

				local canChat = true

				local ChatDisplayOrder = BitIntegerLimit - 2
				if ChatSettings.ScreenGuiDisplayOrder ~= nil then
					ChatDisplayOrder = ChatSettings.ScreenGuiDisplayOrder
				end

				local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
				local GuiParent = Instance.new("ScreenGui")
				GuiParent.Name = "Chat"
				GuiParent.ResetOnSpawn = false
				GuiParent.DisplayOrder = ChatDisplayOrder
				GuiParent.Parent = PlayerGui

				local DidFirstChannelsLoads = false

				local modulesFolder = script

				local moduleChatWindow = ChatWindow()
				local moduleChatBar = ChatBar()
				local moduleChannelsBar = ChannelsBarModule()
				local moduleMessageLabelCreator = MessageLabelCreator()
				local moduleMessageLogDisplay = MessageLogDisplay()
				local moduleChatChannel = ChatChannel()
				local moduleCommandProcessor = CommandProcessor()

				local ChatWindow = moduleChatWindow.new()
				local ChannelsBar = moduleChannelsBar.new()
				local MessageLogDisplay = moduleMessageLogDisplay.new()
				local CommandProcessor = moduleCommandProcessor.new()
				local ChatBar = moduleChatBar.new(CommandProcessor, ChatWindow)

				ChatWindow:CreateGuiObjects(GuiParent)

				ChatWindow:RegisterChatBar(ChatBar)
				ChatWindow:RegisterChannelsBar(ChannelsBar)
				ChatWindow:RegisterMessageLogDisplay(MessageLogDisplay)

				MessageCreatorUtil:RegisterChatWindow(ChatWindow)

				local MessageSender = MessageSenderModule()
				MessageSender:RegisterSayMessageFunction(EventFolder.SayMessageRequest)



				if (UserInputService.TouchEnabled) then
					ChatBar:SetTextLabelText(ChatLocalization:Get("GameChat_ChatMain_ChatBarTextTouch",'Tap here to chat'))
				else
					ChatBar:SetTextLabelText(ChatLocalization:Get("GameChat_ChatMain_ChatBarText",'To chat click here or press "/" key'))
				end

				spawn(function()
					local CurveUtil = CurveUtilModule()
					local animationFps = ChatSettings.ChatAnimationFPS or 20.0

					local updateWaitTime = 1.0 / animationFps
					local lastTick = tick()
					while true do
						local currentTick = tick()
						local tickDelta = currentTick - lastTick
						local dtScale = CurveUtil:DeltaTimeToTimescale(tickDelta)

						if dtScale ~= 0 then
							pcall(function()
								ChatWindow:Update(dtScale)
							end)
						end

						lastTick = currentTick
						wait(updateWaitTime)
					end
				end)




				--////////////////////////////////////////////////////////////////////////////////////////////
				--////////////////////////////////////////////////////////////// Code to do chat window fading
				--////////////////////////////////////////////////////////////////////////////////////////////
				function CheckIfPointIsInSquare(checkPos, topLeft, bottomRight)
					return (topLeft.X <= checkPos.X and checkPos.X <= bottomRight.X and
						topLeft.Y <= checkPos.Y and checkPos.Y <= bottomRight.Y)
				end

				local backgroundIsFaded = false
				local textIsFaded = false
				local lastTextFadeTime = 0
				local lastBackgroundFadeTime = 0

				local fadedChanged = InstanceNew("BindableEvent")
				local mouseStateChanged = InstanceNew("BindableEvent")
				local chatBarFocusChanged = InstanceNew("BindableEvent")

				function DoBackgroundFadeIn(setFadingTime)
					lastBackgroundFadeTime = tick()
					backgroundIsFaded = false
					fadedChanged:Fire()
					ChatWindow:FadeInBackground((setFadingTime or ChatSettings.ChatDefaultFadeDuration))

					local currentChannelObject = ChatWindow:GetCurrentChannel()
					if (currentChannelObject) then

						local Scroller = MessageLogDisplay.Scroller
						Scroller.ScrollingEnabled = true
						Scroller.ScrollBarThickness = moduleMessageLogDisplay.ScrollBarThickness
					end
				end

				function DoBackgroundFadeOut(setFadingTime)
					lastBackgroundFadeTime = tick()
					backgroundIsFaded = true
					fadedChanged:Fire()
					ChatWindow:FadeOutBackground((setFadingTime or ChatSettings.ChatDefaultFadeDuration))

					local currentChannelObject = ChatWindow:GetCurrentChannel()
					if (currentChannelObject) then

						local Scroller = MessageLogDisplay.Scroller
						Scroller.ScrollingEnabled = false
						Scroller.ScrollBarThickness = 0
					end
				end

				function DoTextFadeIn(setFadingTime)
					lastTextFadeTime = tick()
					textIsFaded = false
					fadedChanged:Fire()
					ChatWindow:FadeInText((setFadingTime or ChatSettings.ChatDefaultFadeDuration) * 0)
				end

				function DoTextFadeOut(setFadingTime)
					lastTextFadeTime = tick()
					textIsFaded = true
					fadedChanged:Fire()
					ChatWindow:FadeOutText((setFadingTime or ChatSettings.ChatDefaultFadeDuration))
				end

				function DoFadeInFromNewInformation()
					DoTextFadeIn()
					if ChatSettings.ChatShouldFadeInFromNewInformation then
						DoBackgroundFadeIn()
					end
				end

				function InstantFadeIn()
					DoBackgroundFadeIn(0)
					DoTextFadeIn(0)
				end

				function InstantFadeOut()
					DoBackgroundFadeOut(0)
					DoTextFadeOut(0)
				end

				local mouseIsInWindow = nil
				function UpdateFadingForMouseState(mouseState)
					mouseIsInWindow = mouseState

					mouseStateChanged:Fire()

					if (ChatBar:IsFocused()) then return end

					if (mouseState) then
						DoBackgroundFadeIn()
						DoTextFadeIn()
					else
						DoBackgroundFadeIn()
					end
				end


				spawn(function()
					while true do
						RunService.RenderStepped:Wait()

						while (mouseIsInWindow or ChatBar:IsFocused()) do
							if (mouseIsInWindow) then
								mouseStateChanged.Event:Wait()
							end
							if (ChatBar:IsFocused()) then
								chatBarFocusChanged.Event:Wait()
							end
						end

						if (not backgroundIsFaded) then
							local timeDiff = tick() - lastBackgroundFadeTime
							if (timeDiff > ChatSettings.ChatWindowBackgroundFadeOutTime) then
								DoBackgroundFadeOut()
							end

						elseif (not textIsFaded) then
							local timeDiff = tick() - lastTextFadeTime
							if (timeDiff > ChatSettings.ChatWindowTextFadeOutTime) then
								DoTextFadeOut()
							end

						else
							fadedChanged.Event:Wait()

						end

					end
				end)

				function getClassicChatEnabled()
					if ChatSettings.ClassicChatEnabled ~= nil then
						return ChatSettings.ClassicChatEnabled
					end
					return Players.ClassicChat
				end

				function getBubbleChatEnabled()
					if ChatSettings.BubbleChatEnabled ~= nil then
						return ChatSettings.BubbleChatEnabled
					end
					return Players.BubbleChat
				end

				function bubbleChatOnly()
					return not getClassicChatEnabled() and getBubbleChatEnabled()
				end

				function UpdateMousePosition(mousePos, ignoreForFadeIn)
					if not (moduleApiTable.Visible and moduleApiTable.IsCoreGuiEnabled and (moduleApiTable.TopbarEnabled or ChatSettings.ChatOnWithTopBarOff)) then return end

					if bubbleChatOnly() then
						return
					end

					local windowPos = ChatWindow.GuiObject.AbsolutePosition
					local windowSize = ChatWindow.GuiObject.AbsoluteSize

					local newMouseState = CheckIfPointIsInSquare(mousePos, windowPos, windowPos + windowSize)

					if FFlagFixChatWindowHoverOver then
						if ignoreForFadeIn and newMouseState == true then
							return
						end
					end

					if (newMouseState ~= mouseIsInWindow) then
						UpdateFadingForMouseState(newMouseState)
					end
				end

				UserInputService.InputChanged:Connect(function(inputObject, gameProcessedEvent)
					if (inputObject.UserInputType == Enum.UserInputType.MouseMovement) then
						local mousePos = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
						UpdateMousePosition(mousePos, --[[ ignoreForFadeIn = ]] gameProcessedEvent)
					end
				end)

				UserInputService.TouchTap:Connect(function(tapPos, gameProcessedEvent)
					UpdateMousePosition(tapPos[1], --[[ ignoreForFadeIn = ]] false)
				end)

				UserInputService.TouchMoved:Connect(function(inputObject, gameProcessedEvent)
					local tapPos = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
					UpdateMousePosition(tapPos, --[[ ignoreForFadeIn = ]] false)
				end)

				if not FFlagFixMouseCapture then
					UserInputService.Changed:Connect(function(prop)
						if prop == "MouseBehavior" then
							if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
								local windowPos = ChatWindow.GuiObject.AbsolutePosition
								local windowSize = ChatWindow.GuiObject.AbsoluteSize
								local screenSize = GuiParent.AbsoluteSize

								local centerScreenIsInWindow = CheckIfPointIsInSquare(screenSize/2, windowPos, windowPos + windowSize)
								if centerScreenIsInWindow then
									UserInputService.MouseBehavior = Enum.MouseBehavior.Default
								end
							end
						end
					end)
				end

				--// Start and stop fading sequences / timers
				UpdateFadingForMouseState(true)
				UpdateFadingForMouseState(false)


				--////////////////////////////////////////////////////////////////////////////////////////////
				--///////////// Code to talk to topbar and maintain set/get core backwards compatibility stuff
				--////////////////////////////////////////////////////////////////////////////////////////////
				local Util = {}
				do
					function Util.Signal()
						local sig = {}

						local mSignaler = Instance.new('BindableEvent')

						local mArgData = nil
						local mArgDataCount = nil

						function sig:fire(...)
							mArgData = {...}
							mArgDataCount = select('#', ...)
							mSignaler:Fire()
						end

						function sig:Connect(f)
							if not f then error("connect(nil)", 2) end
							return mSignaler.Event:Connect(function()
								f(unpack(mArgData, 1, mArgDataCount))
							end)
						end

						function sig:Wait()
							mSignaler.Event:Wait()
							assert(mArgData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
							return unpack(mArgData, 1, mArgDataCount)
						end

						return sig
					end
				end


				function SetVisibility(val)
					ChatWindow:SetVisible(val)
					moduleApiTable.VisibilityStateChanged:fire(val)
					moduleApiTable.Visible = val

					if (moduleApiTable.IsCoreGuiEnabled) then
						if (val) then
							InstantFadeIn()
						else
							InstantFadeOut()
						end
					end
				end

				--//This is Diamo's work. He made this for input, replicated from the original.
				local TopBar = Instance.new("ScreenGui")
				TopBar.Name = "TopBar"
				TopBar.DisplayOrder = BitIntegerLimit - 1
				TopBar.IgnoreGuiInset = true
				TopBar.ResetOnSpawn = false
				local TopBarFrame = Instance.new("Frame")
				TopBarFrame.Name = "TopBarFrame"
				TopBarFrame.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				TopBarFrame.BackgroundTransparency = 1
				TopBarFrame.Size = UDim2.new(1, 0, 0, 36)
				TopBarFrame.Parent = TopBar
				local LeftFrame = Instance.new("Frame")
				LeftFrame.Name = "LeftFrame"
				LeftFrame.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				LeftFrame.BackgroundTransparency = 1
				LeftFrame.Position = UDim2.new(0, 16, 0, 0)
				LeftFrame.Size = UDim2.new(0.5, -16, 1, 0)
				LeftFrame.Parent = TopBarFrame
				local ChatIcon = Instance.new("TextButton")
				ChatIcon.Name = "ChatIcon"
				ChatIcon.Position = UDim2.new(0, 44, 0, 0)
				ChatIcon.Size = UDim2.new(0, 44, 1, 0)
				ChatIcon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				ChatIcon.BackgroundTransparency = 1
				ChatIcon.LayoutOrder = 2
				ChatIcon.Font = Enum.Font.Legacy
				ChatIcon.Text = ""
				ChatIcon.TextSize = 8
				ChatIcon.Parent = LeftFrame
				local BadgeContainer = Instance.new("Frame")
				BadgeContainer.Name = "BadgeContainer"
				BadgeContainer.Size = UDim2.new(1, 0, 1, 0)
				BadgeContainer.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				BadgeContainer.BackgroundTransparency = 1
				BadgeContainer.ZIndex = 2
				BadgeContainer.Parent = ChatIcon
				local Background = Instance.new("ImageButton")
				Background.Name = "Background"
				Background.AnchorPoint = Vector2.new(0, 1)
				Background.Position = UDim2.new(0, 0, 1, 0)
				Background.Size = UDim2.new(0, 32, 0, 32)
				Background.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				Background.BackgroundTransparency = 1
				Background.Image = "rbxasset://textures/ui/TopBar/iconBase.png"
				Background.Parent = ChatIcon
				local Icon = Instance.new("ImageLabel")
				Icon.Name = "Icon"
				Icon.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
				Icon.Size = UDim2.new(0, 20, 0, 20)
				Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				Icon.BackgroundTransparency = 1
				Icon.Image = "rbxasset://textures/ui/TopBar/chatOn.png"
				Icon.Parent = Background
				local StateOverlay = Instance.new("ImageLabel")
				StateOverlay.Name = "StateOverlay"
				StateOverlay.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
				StateOverlay.BackgroundTransparency = 1
				StateOverlay.Size = UDim2.new(1, 0, 1, 0)
				StateOverlay.ZIndex = 2
				StateOverlay.Image = "rbxasset://LuaPackages/Packages/_Index/UIBlox/UIBlox/App/ImageSet/ImageAtlas/img_set_1x_2.png"
				StateOverlay.ImageRectOffset = Vector2.new(490, 22)
				StateOverlay.ImageRectSize = Vector2.new(17, 17)
				StateOverlay.ImageTransparency = 1
				StateOverlay.ScaleType = Enum.ScaleType.Slice
				StateOverlay.SliceCenter = Rect.new(8, 8, 8, 8)
				StateOverlay.SliceScale = 1
				StateOverlay.Parent = Background
				TopBar.Parent = GuiParent
				local OnTextBox = false
				UserInputService.TextBoxFocused:Connect(function()
					OnTextBox = true
				end)
				UserInputService.TextBoxFocusReleased:Connect(function()
					OnTextBox = false
				end)
				Background.MouseButton1Down:Connect(function()
					pcall(function()
						StateOverlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
						StateOverlay.ImageTransparency = 0.7
					end)
				end)
				Background.Activated:Connect(function()
					if ChatWindow.Visible == false then
						pcall(function()
							Icon.Image = "rbxasset://textures/ui/TopBar/chatOn.png"
							StateOverlay.ImageTransparency = 1
							StateOverlay.ImageColor3 = Color3.fromRGB(255, 255, 255)
						end)
						pcall(function()
							SetVisibility(true)
						end)
					else
						pcall(function()
							Icon.Image = "rbxasset://textures/ui/TopBar/chatOff.png"
							StateOverlay.ImageTransparency = 1
							StateOverlay.ImageColor3 = Color3.fromRGB(255, 255, 255)
						end)
						pcall(function()
							SetVisibility(false)
						end)
					end
				end)
				UserInputService.InputBegan:Connect(function(Input)
					if not OnTextBox and Input.KeyCode == Enum.KeyCode.Slash then
						Icon.Image = "rbxasset://textures/ui/TopBar/chatOn.png"
					end
				end)
				Background.MouseEnter:Connect(function()
					pcall(function()
						StateOverlay.ImageTransparency = 0.9
					end)
				end)
				Background.MouseLeave:Connect(function()
					pcall(function()
						StateOverlay.ImageTransparency = 1
					end)
				end)

				do
					moduleApiTable.TopbarEnabled = true
					moduleApiTable.MessageCount = 0
					moduleApiTable.Visible = true
					moduleApiTable.IsCoreGuiEnabled = true

					function moduleApiTable:ToggleVisibility()
						SetVisibility(not ChatWindow:GetVisible())
					end

					function moduleApiTable:SetVisible(visible)
						if (ChatWindow:GetVisible() ~= visible) then
							SetVisibility(visible)
						end
					end

					function moduleApiTable:FocusChatBar()
						ChatBar:CaptureFocus()
					end

					function moduleApiTable:EnterWhisperState(player)
						ChatBar:EnterWhisperState(player)
					end

					function moduleApiTable:GetVisibility()
						return ChatWindow:GetVisible()
					end

					function moduleApiTable:GetMessageCount()
						return self.MessageCount
					end

					function moduleApiTable:TopbarEnabledChanged(enabled)
						self.TopbarEnabled = enabled
						self.CoreGuiEnabled:fire(game:GetService("StarterGui"):GetCoreGuiEnabled(Enum.CoreGuiType.Chat))
					end

					function moduleApiTable:IsFocused(useWasFocused)
						return ChatBar:IsFocused()
					end

					moduleApiTable.ChatBarFocusChanged = Util.Signal()
					moduleApiTable.VisibilityStateChanged = Util.Signal()
					moduleApiTable.MessagesChanged = Util.Signal()


					moduleApiTable.MessagePosted = Util.Signal()
					moduleApiTable.CoreGuiEnabled = Util.Signal()

					moduleApiTable.ChatMakeSystemMessageEvent = Util.Signal()
					moduleApiTable.ChatWindowPositionEvent = Util.Signal()
					moduleApiTable.ChatWindowSizeEvent = Util.Signal()
					moduleApiTable.ChatBarDisabledEvent = Util.Signal()


					function moduleApiTable:fChatWindowPosition()
						return ChatWindow.GuiObject.Position
					end

					function moduleApiTable:fChatWindowSize()
						return ChatWindow.GuiObject.Size
					end

					function moduleApiTable:fChatBarDisabled()
						return not ChatBar:GetEnabled()
					end

					if FFlagUserHandleChatHotKeyWithContextActionService then
						local TOGGLE_CHAT_ACTION_NAME = "ToggleChat"

						-- Callback when chat hotkey is pressed
						local function handleAction(actionName, inputState, inputObject)
							if actionName == TOGGLE_CHAT_ACTION_NAME and inputState == Enum.UserInputState.Begin and canChat and inputObject.UserInputType == Enum.UserInputType.Keyboard then
								DoChatBarFocus()
							end
						end
						ContextActionService:BindAction(TOGGLE_CHAT_ACTION_NAME, handleAction, true, Enum.KeyCode.Slash)
					else
						function moduleApiTable:SpecialKeyPressed(key, modifiers)
							if (key == Enum.SpecialKey.ChatHotkey) then
								if canChat then
									DoChatBarFocus()
								end
							end
						end
					end
				end
				--AHA! Sneaky, sneaky...
				moduleApiTable.CoreGuiEnabled:Connect(function(enabled)
					--moduleApiTable.IsCoreGuiEnabled = enabled

					--enabled = enabled and (moduleApiTable.TopbarEnabled or ChatSettings.ChatOnWithTopBarOff)

					--ChatWindow:SetCoreGuiEnabled(enabled)

					--if (not enabled) then
					--	ChatBar:ReleaseFocus()
					--	InstantFadeOut()
					--else
					--	InstantFadeIn()
					--end
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
				end)

				function trimTrailingSpaces(str)
					local lastSpace = #str
					while lastSpace > 0 do
						--- The pattern ^%s matches whitespace at the start of the string. (Starting from lastSpace)
						if str:find("^%s", lastSpace) then
							lastSpace = lastSpace - 1
						else
							break
						end
					end
					return str:sub(1, lastSpace)
				end

				moduleApiTable.ChatMakeSystemMessageEvent:Connect(function(valueTable)
					if (valueTable["Text"] and type(valueTable["Text"]) == "string") then
						while (not DidFirstChannelsLoads) do wait() end

						local channel = ChatSettings.GeneralChannelName
						local channelObj = ChatWindow:GetChannel(channel)

						if (channelObj) then
							local messageObject = {
								ID = -1,
								FromSpeaker = nil,
								SpeakerUserId = 0,
								OriginalChannel = channel,
								IsFiltered = true,
								MessageLength = string.len(valueTable.Text),
								Message = trimTrailingSpaces(valueTable.Text),
								MessageType = ChatConstants.MessageTypeSetCore,
								Time = os.time(),
								ExtraData = valueTable,
							}
							channelObj:AddMessageToChannel(messageObject)
							ChannelsBar:UpdateMessagePostedInChannel(channel)

							moduleApiTable.MessageCount = moduleApiTable.MessageCount + 1
							moduleApiTable.MessagesChanged:fire(moduleApiTable.MessageCount)
						end
					end
				end)

				moduleApiTable.ChatBarDisabledEvent:Connect(function(disabled)
					if canChat then
						ChatBar:SetEnabled(not disabled)
						if (disabled) then
							ChatBar:ReleaseFocus()
						end
					end
				end)

				moduleApiTable.ChatWindowSizeEvent:Connect(function(size)
					ChatWindow.GuiObject.Size = size
				end)

				moduleApiTable.ChatWindowPositionEvent:Connect(function(position)
					ChatWindow.GuiObject.Position = position
				end)

				--////////////////////////////////////////////////////////////////////////////////////////////
				--///////////////////////////////////////////////// Code to hook client UI up to server events
				--////////////////////////////////////////////////////////////////////////////////////////////

				function DoChatBarFocus()
					if (not ChatWindow:GetCoreGuiEnabled()) then return end
					if (not ChatBar:GetEnabled()) then return end

					if (not ChatBar:IsFocused() and ChatBar:GetVisible()) then
						moduleApiTable:SetVisible(true)
						InstantFadeIn()
						ChatBar:CaptureFocus()
						moduleApiTable.ChatBarFocusChanged:fire(true)
					end
				end

				chatBarFocusChanged.Event:Connect(function(focused)
					moduleApiTable.ChatBarFocusChanged:fire(focused)
				end)

				function DoSwitchCurrentChannel(targetChannel)
					if (ChatWindow:GetChannel(targetChannel)) then
						ChatWindow:SwitchCurrentChannel(targetChannel)
					end
				end

				function SendMessageToSelfInTargetChannel(message, channelName, extraData)
					local channelObj = ChatWindow:GetChannel(channelName)
					if (channelObj) then
						local messageData =
							{
								ID = -1,
								FromSpeaker = nil,
								SpeakerUserId = 0,
								OriginalChannel = channelName,
								IsFiltered = true,
								MessageLength = string.len(message),
								Message = trimTrailingSpaces(message),
								MessageType = ChatConstants.MessageTypeSystem,
								Time = os.time(),
								ExtraData = extraData,
							}

						channelObj:AddMessageToChannel(messageData)
					end
				end

				function chatBarFocused()
					if (not mouseIsInWindow) then
						DoBackgroundFadeIn()
						if (textIsFaded) then
							DoTextFadeIn()
						end
					end

					chatBarFocusChanged:Fire(true)
				end

				--// Event for making player say chat message.
				function chatBarFocusLost(enterPressed, inputObject)
					DoBackgroundFadeIn()
					chatBarFocusChanged:Fire(false)

					if (enterPressed) then
						local message = ChatBar:GetTextBox().Text

						if ChatBar:IsInCustomState() then
							local customMessage = ChatBar:GetCustomMessage()
							if customMessage then
								message = customMessage
							end
							local messageSunk = ChatBar:CustomStateProcessCompletedMessage(message)
							ChatBar:ResetCustomState()
							if messageSunk then
								return
							end
						end

						ChatBar:GetTextBox().Text = ""

						if message ~= "" then
							--// Sends signal to eventually call Player:Chat() to handle C++ side legacy stuff.
							moduleApiTable.MessagePosted:fire(message)

							if not CommandProcessor:ProcessCompletedChatMessage(message, ChatWindow) then
								if ChatSettings.DisallowedWhiteSpace then
									for i = 1, #ChatSettings.DisallowedWhiteSpace do
										if ChatSettings.DisallowedWhiteSpace[i] == "\t" then
											message = string.gsub(message, ChatSettings.DisallowedWhiteSpace[i], " ")
										else
											message = string.gsub(message, ChatSettings.DisallowedWhiteSpace[i], "")
										end
									end
								end
								message = string.gsub(message, "\n", "")
								message = string.gsub(message, "[ ]+", " ")

								local targetChannel = ChatWindow:GetTargetMessageChannel()
								if targetChannel then
									MessageSender:SendMessage(message, targetChannel)
								else
									MessageSender:SendMessage(message, nil)
								end
							end
						end

					end
				end

				local ChatBarConnections = {}
				function setupChatBarConnections()
					for i = 1, #ChatBarConnections do
						ChatBarConnections[i]:Disconnect()
					end
					ChatBarConnections = {}

					local focusLostConnection = ChatBar:GetTextBox().FocusLost:Connect(chatBarFocusLost)
					table.insert(ChatBarConnections, focusLostConnection)

					local focusGainedConnection = ChatBar:GetTextBox().Focused:Connect(chatBarFocused)
					table.insert(ChatBarConnections, focusGainedConnection)
				end

				setupChatBarConnections()
				ChatBar.GuiObjectsChanged:Connect(setupChatBarConnections)

				function getEchoMessagesInGeneral()
					if ChatSettings.EchoMessagesInGeneralChannel == nil then
						return true
					end
					return ChatSettings.EchoMessagesInGeneralChannel
				end

				EventFolder.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
					if not ChatSettings.ShowUserOwnFilteredMessage then
						if messageData.FromSpeaker == LocalPlayer.Name then
							return
						end
					end

					local channelName = messageData.OriginalChannel
					local channelObj = ChatWindow:GetChannel(channelName)
					if channelObj then
						channelObj:UpdateMessageFiltered(messageData)
					end

					if getEchoMessagesInGeneral() and ChatSettings.GeneralChannelName and channelName ~= ChatSettings.GeneralChannelName then
						local generalChannel = ChatWindow:GetChannel(ChatSettings.GeneralChannelName)
						if generalChannel then
							generalChannel:UpdateMessageFiltered(messageData)
						end
					end
				end)

				EventFolder.OnNewMessage.OnClientEvent:Connect(function(messageData, channelName)
					local channelObj = ChatWindow:GetChannel(channelName)
					if (channelObj) then
						channelObj:AddMessageToChannel(messageData)

						if (messageData.FromSpeaker ~= LocalPlayer.Name) then
							ChannelsBar:UpdateMessagePostedInChannel(channelName)
						end

						if getEchoMessagesInGeneral() and ChatSettings.GeneralChannelName and channelName ~= ChatSettings.GeneralChannelName then
							local generalChannel = ChatWindow:GetChannel(ChatSettings.GeneralChannelName)
							if generalChannel then
								generalChannel:AddMessageToChannel(messageData)
							end
						end

						moduleApiTable.MessageCount = moduleApiTable.MessageCount + 1
						moduleApiTable.MessagesChanged:fire(moduleApiTable.MessageCount)

						DoFadeInFromNewInformation()
					end
				end)

				EventFolder.OnNewSystemMessage.OnClientEvent:Connect(function(messageData, channelName)
					channelName = channelName or "System"

					local channelObj = ChatWindow:GetChannel(channelName)
					if (channelObj) then
						channelObj:AddMessageToChannel(messageData)

						ChannelsBar:UpdateMessagePostedInChannel(channelName)

						moduleApiTable.MessageCount = moduleApiTable.MessageCount + 1
						moduleApiTable.MessagesChanged:fire(moduleApiTable.MessageCount)

						DoFadeInFromNewInformation()

						if getEchoMessagesInGeneral() and ChatSettings.GeneralChannelName and channelName ~= ChatSettings.GeneralChannelName then
							local generalChannel = ChatWindow:GetChannel(ChatSettings.GeneralChannelName)
							if generalChannel then
								generalChannel:AddMessageToChannel(messageData)
							end
						end
					else
						--warn(string.format("Just received system message for channel I'm not in [%s]", channelName))
					end
				end)


				function HandleChannelJoined(channel, welcomeMessage, messageLog, channelNameColor, addHistoryToGeneralChannel,
					addWelcomeMessageToGeneralChannel)
					if ChatWindow:GetChannel(channel) then
						--- If the channel has already been added, remove it first.
						ChatWindow:RemoveChannel(channel)
					end

					if (channel == ChatSettings.GeneralChannelName) then
						DidFirstChannelsLoads = true
					end

					if channelNameColor then
						ChatBar:SetChannelNameColor(channel, channelNameColor)
					end

					local channelObj = ChatWindow:AddChannel(channel)

					if (channelObj) then
						if (channel == ChatSettings.GeneralChannelName) then
							DoSwitchCurrentChannel(channel)
						end

						if (messageLog) then
							local startIndex = 1
							if #messageLog > ChatSettings.MessageHistoryLengthPerChannel then
								startIndex = #messageLog - ChatSettings.MessageHistoryLengthPerChannel
							end

							for i = startIndex, #messageLog do
								channelObj:AddMessageToChannel(messageLog[i])
							end

							if getEchoMessagesInGeneral() and addHistoryToGeneralChannel then
								if ChatSettings.GeneralChannelName and channel ~= ChatSettings.GeneralChannelName then
									local generalChannel = ChatWindow:GetChannel(ChatSettings.GeneralChannelName)
									if generalChannel then
										generalChannel:AddMessagesToChannelByTimeStamp(messageLog, startIndex)
									end
								end
							end
						end

						if (welcomeMessage ~= "") then
							local welcomeMessageObject = {
								ID = -1,
								FromSpeaker = nil,
								SpeakerUserId = 0,
								OriginalChannel = channel,
								IsFiltered = true,
								MessageLength = string.len(welcomeMessage),
								Message = trimTrailingSpaces(welcomeMessage),
								MessageType = ChatConstants.MessageTypeWelcome,
								Time = os.time(),
								ExtraData = nil,
							}
							channelObj:AddMessageToChannel(welcomeMessageObject)

							if getEchoMessagesInGeneral() and addWelcomeMessageToGeneralChannel and not ChatSettings.ShowChannelsBar then
								if channel ~= ChatSettings.GeneralChannelName then
									local generalChannel = ChatWindow:GetChannel(ChatSettings.GeneralChannelName)
									if generalChannel then
										generalChannel:AddMessageToChannel(welcomeMessageObject)
									end
								end
							end
						end

						DoFadeInFromNewInformation()
					end

				end

				EventFolder.OnChannelJoined.OnClientEvent:Connect(function(channel, welcomeMessage, messageLog, channelNameColor)
					HandleChannelJoined(channel, welcomeMessage, messageLog, channelNameColor, false, true)
				end)

				EventFolder.OnChannelLeft.OnClientEvent:Connect(function(channel)
					ChatWindow:RemoveChannel(channel)

					DoFadeInFromNewInformation()
				end)

				EventFolder.OnMuted.OnClientEvent:Connect(function(channel)
					--// Do something eventually maybe?
					--// This used to take away the chat bar in channels the player was muted in.
					--// We found out this behavior was inconvenient for doing chat commands though.
				end)

				EventFolder.OnUnmuted.OnClientEvent:Connect(function(channel)
					--// Same as above.
				end)

				EventFolder.OnMainChannelSet.OnClientEvent:Connect(function(channel)
					DoSwitchCurrentChannel(channel)
				end)

				coroutine.wrap(function()
					-- ChannelNameColorUpdated may not exist if the client version is older than the server version.
					local ChannelNameColorUpdated = DefaultChatSystemChatEvents:WaitForChild("ChannelNameColorUpdated", 5)
					if ChannelNameColorUpdated then
						ChannelNameColorUpdated.OnClientEvent:Connect(function(channelName, channelNameColor)
							ChatBar:SetChannelNameColor(channelName, channelNameColor)
						end)
					end
				end)()


				--- Interaction with SetCore Player events.

				local PlayerBlockedEvent = nil
				local PlayerMutedEvent = nil
				local PlayerUnBlockedEvent = nil
				local PlayerUnMutedEvent = nil


				-- This is pcalled because the SetCore methods may not be released yet.
				pcall(function()
					PlayerBlockedEvent = StarterGui:GetCore("PlayerBlockedEvent")
					PlayerMutedEvent = StarterGui:GetCore("PlayerMutedEvent")
					PlayerUnBlockedEvent = StarterGui:GetCore("PlayerUnblockedEvent")
					PlayerUnMutedEvent = StarterGui:GetCore("PlayerUnmutedEvent")
				end)

				function SendSystemMessageToSelf(message)
					local currentChannel = ChatWindow:GetCurrentChannel()

					if currentChannel then
						local messageData =
							{
								ID = -1,
								FromSpeaker = nil,
								SpeakerUserId = 0,
								OriginalChannel = currentChannel.Name,
								IsFiltered = true,
								MessageLength = string.len(message),
								Message = trimTrailingSpaces(message),
								MessageType = ChatConstants.MessageTypeSystem,
								Time = os.time(),
								ExtraData = nil,
							}

						currentChannel:AddMessageToChannel(messageData)
					end
				end

				function MutePlayer(player)
					local mutePlayerRequest = DefaultChatSystemChatEvents:FindFirstChild("MutePlayerRequest")
					if mutePlayerRequest then
						return mutePlayerRequest:InvokeServer(player.Name)
					end
					return false
				end

				if PlayerBlockedEvent then
					PlayerBlockedEvent.Event:Connect(function(player)
						if MutePlayer(player) then
							local playerName

							if ChatSettings.PlayerDisplayNamesEnabled then
								playerName = player.DisplayName
							else
								playerName = player.Name
							end

							SendSystemMessageToSelf(
								string.gsub(
									ChatLocalization:Get(
										"GameChat_ChatMain_SpeakerHasBeenBlocked",
										string.format("Speaker '%s' has been blocked.", playerName)
									),
									"{RBX_NAME}", playerName
								)
							)
						end
					end)
				end

				if PlayerMutedEvent then
					PlayerMutedEvent.Event:Connect(function(player)
						if MutePlayer(player) then
							local playerName

							if ChatSettings.PlayerDisplayNamesEnabled then
								playerName = player.DisplayName
							else
								playerName = player.Name
							end

							SendSystemMessageToSelf(
								string.gsub(
									ChatLocalization:Get(
										"GameChat_ChatMain_SpeakerHasBeenMuted",
										string.format("Speaker '%s' has been muted.", playerName)
									),
									"{RBX_NAME}", playerName
								)
							)
						end
					end)
				end

				function UnmutePlayer(player)
					local unmutePlayerRequest = DefaultChatSystemChatEvents:FindFirstChild("UnMutePlayerRequest")
					if unmutePlayerRequest then
						return unmutePlayerRequest:InvokeServer(player.Name)
					end
					return false
				end

				if PlayerUnBlockedEvent then
					PlayerUnBlockedEvent.Event:Connect(function(player)
						if UnmutePlayer(player) then
							local playerName

							if ChatSettings.PlayerDisplayNamesEnabled then
								playerName = player.DisplayName
							else
								playerName = player.Name
							end

							SendSystemMessageToSelf(
								string.gsub(
									ChatLocalization:Get(
										"GameChat_ChatMain_SpeakerHasBeenUnBlocked",
										string.format("Speaker '%s' has been unblocked.", playerName)
									),
									"{RBX_NAME}", playerName
								)
							)
						end
					end)
				end

				if PlayerUnMutedEvent then
					PlayerUnMutedEvent.Event:Connect(function(player)
						if UnmutePlayer(player) then
							local playerName

							if ChatSettings.PlayerDisplayNamesEnabled then
								playerName = player.DisplayName
							else
								playerName = player.Name
							end

							SendSystemMessageToSelf(
								string.gsub(
									ChatLocalization:Get(
										"GameChat_ChatMain_SpeakerHasBeenUnMuted",
										string.format("Speaker '%s' has been unmuted.", playerName)
									),
									"{RBX_NAME}", playerName
								)
							)
						end
					end)
				end

				-- Get a list of blocked users from the corescripts.
				-- Spawned because this method can yeild.
				spawn(function()
					-- Pcalled because this method is not released on all platforms yet.
					if LocalPlayer.UserId > 0 then
						pcall(function()
							local blockedUserIds = StarterGui:GetCore("GetBlockedUserIds")
							if #blockedUserIds > 0 then
								local setInitalBlockedUserIds = DefaultChatSystemChatEvents:FindFirstChild("SetBlockedUserIdsRequest")
								if setInitalBlockedUserIds then
									setInitalBlockedUserIds:FireServer(blockedUserIds)
								end
							end
						end)
					end
				end)

				spawn(function()
					local success, canLocalUserChat = pcall(function()
						return Chat:CanUserChatAsync(LocalPlayer.UserId)
					end)
					if success then
						canChat = RunService:IsStudio() or canLocalUserChat
					end
				end)

				local initData = EventFolder.GetInitDataRequest:InvokeServer()

				-- Handle joining general channel first.
				for i, channelData in pairs(initData.Channels) do
					if channelData[1] == ChatSettings.GeneralChannelName then
						HandleChannelJoined(channelData[1], channelData[2], channelData[3], channelData[4], true, false)
					end
				end

				for i, channelData in pairs(initData.Channels) do
					if channelData[1] ~= ChatSettings.GeneralChannelName then
						HandleChannelJoined(channelData[1], channelData[2], channelData[3], channelData[4], true, false)
					end
				end

				return moduleApiTable
			end
			local Chat = ChatMain()

			--pcall(function()
			--	LocalPlayer.PlayerGui.Chat:Destroy()
			--end)

			game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			--	// FileName: ChatScript.lua
			--	// Written by: Xsitsu
			--	// Description: Hooks main chat module up to Topbar in corescripts.

			local FFlagUserHandleChatHotKeyWithContextActionService = false do
				local ok, value = pcall(function()
					return UserSettings():IsUserFeatureEnabled("UserHandleChatHotKeyWithContextActionService")
				end)
				if ok then
					FFlagUserHandleChatHotKeyWithContextActionService = value
				end
			end

			local StarterGui = game:GetService("StarterGui")
			local GuiService = game:GetService("GuiService")
			local ChatService = game:GetService("Chat")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			local MAX_COREGUI_CONNECTION_ATTEMPTS = 10

			local ClientChatModules = ChatService:WaitForChild("ClientChatModules")
			local ChatSettings = require(ClientChatModules:WaitForChild("ChatSettings"))

			local function DoEverything()
				local containerTable = {}
				containerTable.ChatWindow = {}
				containerTable.SetCore = {}
				containerTable.GetCore = {}

				containerTable.ChatWindow.ChatTypes = {}
				containerTable.ChatWindow.ChatTypes.BubbleChatEnabled = ChatSettings.BubbleChatEnabled
				containerTable.ChatWindow.ChatTypes.ClassicChatEnabled = ChatSettings.ClassicChatEnabled

				--// Connection functions
				local function ConnectEvent(name)
					local event = InstanceNew("BindableEvent")
					event.Name = name
					containerTable.ChatWindow[name] = event

					event.Event:Connect(function(...) Chat[name](Chat, ...) end)
				end

				local function ConnectFunction(name)
					local func = InstanceNew("BindableFunction")
					func.Name = name
					containerTable.ChatWindow[name] = func

					func.OnInvoke = function(...) return Chat[name](Chat, ...) end
				end

				local function ReverseConnectEvent(name)
					local event = InstanceNew("BindableEvent")
					event.Name = name
					containerTable.ChatWindow[name] = event

					Chat[name]:Connect(function(...) event:Fire(...) end)
				end

				local function ConnectSignal(name)
					local event = InstanceNew("BindableEvent")
					event.Name = name
					containerTable.ChatWindow[name] = event

					event.Event:Connect(function(...) Chat[name]:fire(...) end)
				end

				--Not CoreGui because it's mean't to be fake chat
				local function ConnectSetCore(name)
					local event = InstanceNew("BindableEvent")
					event.Name = name
					containerTable.SetCore[name] = event

					event.Event:Connect(function(...) Chat[name.."Event"]:fire(...) end)
				end

				local function ConnectGetCore(name)
					local func = InstanceNew("BindableFunction")
					func.Name = name
					containerTable.GetCore[name] = func

					func.OnInvoke = function(...) return Chat["f"..name](...) end
				end

				--// Do connections
				--ConnectEvent("ToggleVisibility")
				--ConnectEvent("SetVisible")
				--ConnectEvent("FocusChatBar")
				--ConnectEvent("EnterWhisperState")
				--ConnectFunction("GetVisibility")
				--ConnectFunction("GetMessageCount")
				--ConnectEvent("TopbarEnabledChanged")
				--ConnectFunction("IsFocused")

				--ReverseConnectEvent("ChatBarFocusChanged")
				--ReverseConnectEvent("VisibilityStateChanged")
				ReverseConnectEvent("MessagesChanged")
				ReverseConnectEvent("MessagePosted")

				--ConnectSignal("CoreGuiEnabled")

				ConnectSetCore("ChatMakeSystemMessage")
				--ConnectSetCore("ChatWindowPosition")
				--ConnectSetCore("ChatWindowSize")
				--ConnectGetCore("ChatWindowPosition")
				--ConnectGetCore("ChatWindowSize")
				--ConnectSetCore("ChatBarDisabled")
				--ConnectGetCore("ChatBarDisabled")

				if not FFlagUserHandleChatHotKeyWithContextActionService then    
					ConnectEvent("SpecialKeyPressed")
				end

				SetCoreGuiChatConnections(containerTable)
			end

			function SetCoreGuiChatConnections(containerTable)
				local tries = 0
				while tries < MAX_COREGUI_CONNECTION_ATTEMPTS do
					tries = tries + 1
					local success, ret = pcall(function() StarterGui:SetCore("CoreGuiChatConnections", containerTable) end)
					if success then
						break
					end
					if not success and tries == MAX_COREGUI_CONNECTION_ATTEMPTS then
						error("Error calling SetCore CoreGuiChatConnections: " .. ret)
					end
					wait()
				end
			end

			function checkBothChatTypesDisabled()
				if ChatSettings.BubbleChatEnabled ~= nil then
					if ChatSettings.ClassicChatEnabled ~= nil then
						return not (ChatSettings.BubbleChatEnabled or ChatSettings.ClassicChatEnabled)
					end
				end
				return false
			end

			if (not GuiService:IsTenFootInterface()) and (not game:GetService('UserInputService').VREnabled) then
				if not checkBothChatTypesDisabled() then
					DoEverything()
				else
					local containerTable = {}
					containerTable.ChatWindow = {}

					containerTable.ChatWindow.ChatTypes = {}
					containerTable.ChatWindow.ChatTypes.BubbleChatEnabled = false
					containerTable.ChatWindow.ChatTypes.ClassicChatEnabled = false
					SetCoreGuiChatConnections(containerTable)
				end
			else
				-- Make init data request to register as a speaker
				local EventFolder = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
				EventFolder.GetInitDataRequest:InvokeServer()
			end
		end)
	end
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local ClassScript = {}
	function ClassScript.new()
		--------------------------------------------------------------------------------
		-- Class by TerrodactyI
		--------------------------------------------------------------------------------
		--
		-- Inspired by Scrap Mechanic's class function. This library exports a single
		-- function that allows you to create classes. All other interaction with the
		-- library is performed by setting members of classes and creating instances of
		-- those classes.
		--
		--------------------------------------------------------------------------------
		--
		-- class(string className[, Class superclass]): Class
		--   Returns an empty Class with the provided className and superclass. All
		--   methods and fields of the superclass will be present in your class, and its
		--   constructors will be called when your class is instantiated.
		--
		--   Modification of the arguments passed to the constructors of a superclass is
		--   done using the __SuperArgs special method. See its documentation below.
		--
		--------------------------------------------------------------------------------
		--
		-- class:IsClass(any arg): bool
		--   Returns true if the `arg` is a Class created by this class function.
		--
		--   If this returns false, it could still be a class from a different copy of
		--   this module. However, it will not be identified as a class by any checks or
		--   functions in this script.
		--
		--------------------------------------------------------------------------------
		--
		-- class:IsInstance(any arg): bool
		--   Returns true if the provided argument is a ClassInstance.
		--
		--   If this returns false, it could still be an instance from a different copy
		--   of this module. However, it will not be identified as a class by any checks
		--   or functions in this script.
		--
		--------------------------------------------------------------------------------
		--
		-- class:IsClassOrInstance(any arg): bool
		--   Returns true if the provided argument is a Class or ClassInstance.
		--
		--   If this returns false, it could still be a class or instance from a
		--   different copy of this module. However, it will not be identified as such
		--   by any checks or functions in this script.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__Metatable: table?
		--   A metatable applied to all new instances of a class. All metamethods,
		--   including those such as __index, __newindex, __call, __tostring and so on
		--   should function correctly.
		--
		--   After any class or one of its subclasses has been instantiated at least
		--   once, its metatable will become locked. You will no longer be able to set
		--   the __Metatable field. However, before this happens, you are free to set or
		--   re-set __Metatable as many times as you want.
		--
		--   Once a metatable is locked, an immutable copy of it is created, and you can
		--   never change it again. Indexing __Metatable will also return an immutable
		--   copy of the metatable being used.
		--
		--   You do not need to define this field, it will not be used if it doesn't
		--   exist.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__Preconstruct(instance, ...): nil
		--   Called during instantiation before __SuperArgs or any superclass
		--   constructors are called.
		--
		--   This method will not be called if it doesn't exist.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__Construct(instance, ...): nil
		--   Called after __Preconstruct, __SuperArgs and all superclass constructors.
		--
		--   This method will not be called if it doesn't exist.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__SuperArgs(instance, ...): ...
		--   Called after __Preconstruct. Receives arguments passed to the constructor
		--   and returns the arguments to be passed to superclass constructors.
		--
		--   This method will not be called if it doesn't exist.
		--
		--------------------------------------------------------------------------------
		--
		-- <C: Class> C.__Class: C
		--   This class.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__Super: Class?
		--   The superclass of this class, or nil if there is none.
		--
		--   Attempting to set this field will result in an error.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__ClassName: string
		--   The name of this class.
		--
		--   Exercise caution in setting this value. It will be propagated correctly for
		--   you automatically, but expect to break systems that expect class names not
		--   to change.
		--
		--------------------------------------------------------------------------------
		--
		-- Class.__ClassLib: class
		--   Returns the class function that created this class. If you're integrating
		--   into an existing class system, this is recommended over requiring your own
		--   version of the Class ModuleScript, as multiple ModuleScripts are
		--   incompatible due to scoping.
		--
		--------------------------------------------------------------------------------
		--
		-- Class:__IsA(string | Class class): bool
		--   Returns true if this class or any of its superclasses is equal to the
		--   provided argument. If a string is provided, it checks the class names. If a
		--   Class is provided, it checks for reference equality in its superclasses.
		--
		--------------------------------------------------------------------------------
		--
		-- <C: Class> C:__Subclass(string className): Class<C>
		--   Returns a new subclass of this class with the provided class name.
		--
		--   Shorthand for class(className, C)
		--
		--------------------------------------------------------------------------------
		--
		-- Class:__...
		--   Do not attempt to set or index fields beginning with two underscores. They
		--   will error, as those names are reserved by this library for future
		--   revisions.
		--
		--------------------------------------------------------------------------------
		--
		-- <C: Class> C(...): ClassInstance<C>
		--   Creates a new instance of this class using the provided constructor
		--   arguments.
		--
		--   Constructor functions are called in an order and fashion similar to this:
		--
		--    class.__Preconstruct(instance, ...)
		--    local superArgs = class.__SuperArgs(instance, ...)
		--    class.__Super.__Preconstruct(instance, unpack(superArgs))
		--    -- and so on, up the tree, until there are no more superclasses left
		--    class.__Super.__Construct(instance, unpack(superArgs))
		--    class.__Construct(instance, ...)
		--
		--   The library implementation uses loops, a stack, and complex metatable
		--   arrangements. You can read it below, after all, this is the script
		--   containing it.
		--
		--------------------------------------------------------------------------------
		--
		-- ClassInstance:__Metatable
		-- ClassInstance:__Preconstruct
		-- ClassInstance:__Construct
		-- ClassInstance:__SuperArgs
		-- ClassInstance:__...
		--   An error is thrown if you attempt to index these at all. Do not access
		--   these from a class instance. You do not need to construct an instance
		--   manually.
		--
		--------------------------------------------------------------------------------
		--
		-- <C: Class> ClassInstance<C>:__Class: C
		--   The class of this class instance.
		--
		--------------------------------------------------------------------------------
		--
		-- ClassInstance:__Super: Class
		--   The superclass of this instance's class.
		--
		--------------------------------------------------------------------------------
		--
		-- ClassInstance:__ClassName: string
		--   The class name of this instance.
		--
		--------------------------------------------------------------------------------
		--
		-- ClassInstance.__ClassLib: class
		--   Returns the class function that created this class. If you're integrating
		--   into an existing class system, this is recommended over requiring your own
		--   version of the Class ModuleScript, as multiple ModuleScripts are
		--   incompatible due to scoping.
		--
		--------------------------------------------------------------------------------
		--
		-- ClassInstance:__IsA(string | Class class): bool
		--   Returns true if this class or any of its superclasses is equal to the
		--   provided argument. If a string is provided, it checks the class names. If a
		--   Class is provided, it checks for reference equality in its superclasses.
		--
		--------------------------------------------------------------------------------
		--
		-- <C: Class> ClassInstance<C>:__Subclass(string className): Class<C>
		--   Returns a new subclass of this class with the provided class name.
		--
		--   Shorthand for class(className, instance.__Class)
		--
		--------------------------------------------------------------------------------
		--
		-- That's the end of the documentation. Proceed at your own risk.
		--
		--------------------------------------------------------------------------------

		local class

		local weakKeys = {__mode = 'k'}

		local classes = setmetatable({}, weakKeys)
		local instances = setmetatable({}, weakKeys)

		local classMeta
		local instanceMeta

		local globalPrototype
		local globalClassPrototype
		local globalInstancePrototype

		local deepCopy do
			function deepCopy(tbl, seen)
				if type(tbl) ~= 'table' then return tbl end
				if type(seen) ~= 'table' then seen = {} end
				if seen[tbl] then return seen[tbl] end

				local result = {}
				seen[tbl] = result

				for k, v in pairs(tbl) do
					result[k] = deepCopy(v, seen)
				end

				return result
			end
		end
		local immutableView do
			local thingies = {}
			local seens = {}
			local immutableViewMt = {}

			function immutableViewMt:__index(key)
				local value = thingies[self]

				if type(value) == 'table' then
					return immutableView(value, seens[self])
				end

				return value
			end

			function immutableViewMt:__newindex(key, value)
				error('Immutable table', 2)
			end

			function immutableViewMt:__len()
				return #thingies[self]
			end

			function immutableViewMt:__pairs()
				return pairs(thingies[self])
			end

			function immutableViewMt:__ipairs()
				return ipairs(thingies[self])
			end

			immutableViewMt.__metatable = '<immutable table>'

			function immutableView(tbl, seen)
				if type(tbl) ~= 'table' then return tbl end
				if type(seen) ~= 'table' then seen = {} end
				if seen[tbl] then return seen[tbl] end

				local proxy = setmetatable({}, immutableViewMt)
				thingies[proxy] = tbl
				seens[proxy] = seen
				seen[tbl] = proxy

				return proxy
			end
		end

		classMeta = {} do
			function classMeta:__index(key)
				local classData = classes[self]

				if key == '__Metatable' then
					if classData.metatableLocked then
						return immutableView(classData.metatable)
					end

					return classData.metatable
				elseif key == '__Preconstruct' then
					return classData.preconstructor
				elseif key == '__Construct' then
					return classData.constructor
				elseif key == '__SuperArgs' then
					return classData.superArgs
				elseif key == '__Class' then
					return self
				elseif key == '__Super' then
					return classData.superclass
				elseif key == '__ClassName' then
					return classData.name
				elseif key == '__ClassLib' then
					return class
				elseif globalClassPrototype[key] then
					return globalClassPrototype[key]
				elseif globalPrototype[key] then
					return globalPrototype[key]
				elseif key:sub(1, 2) == '__' then
					error('Cannot index field beginning with __ (reserved)', 2)
				end

				if classData.metatable and classData.metatable.__index then
					return classData.metatable.__index(self, key)
				end

				if classData.superclass then
					return classData.superclass[key]
				end
			end

			function classMeta:__newindex(key, value)
				local classData = classes[self]

				if key == '__Metatable' then
					if not value or type(value) == 'table' then
						if classData.metatableLocked then
							error('__Metatable is locked and cannot be changed', 2)
						end

						classData.metatable = value
					else
						error('__Metatable can only be set to a table or nil', 2)
					end
				elseif key == '__Preconstruct' then
					if value ~= nil and type(value) ~= 'function' then
						error('__Preconstruct can only be set to a function or nil', 2)
					end

					classData.preconstructor = value
				elseif key == '__Construct' then
					if value ~= nil and type(value) ~= 'function' then
						error('__Construct can only be set to a function or nil', 2)
					end

					classData.constructor = value
				elseif key == '__SuperArgs' then
					if value ~= nil and type(value) ~= 'function' then
						error('__SuperArgs can only be set to a function or nil', 2)
					end

					classData.superArgs = value
				elseif key == '__Class' then
					error('Cannot set __Class field of class', 2)
				elseif key == '__Super' then
					error('Cannot set __Super field of class', 2)
				elseif key == '__ClassName' then
					classData.name = value
				elseif key == '__ClassLib' then
					error('Cannot set __ClassLib field of class', 2)
				elseif globalClassPrototype[key] then
					error('Cannot override global class prototype', 2)
				elseif globalPrototype[key] then
					error('Cannot override global prototype', 2)
				elseif key:sub(1, 2) == '__' then
					error('Cannot index field beginning with __ (reserved)', 2)
				else
					if classData.metatable and classData.metatable.__newindex then
						return classData.metatable.__newindex(self, key, value)
					end

					rawset(self, key, value)
				end
			end

			function classMeta:__call(...)
				local classData = classes[self]

				local instance = {}
				local thisInstanceMeta = classData.instanceMeta

				if not thisInstanceMeta then
					thisInstanceMeta = {}

					local stack = {classData}

					while stack[#stack].superclass do
						stack[#stack + 1] = classes[stack[#stack].superclass]
					end

					for i = #stack, 1, -1 do
						local classData = stack[i]
						local newLock = not classData.metatableLocked
						classData.metatableLocked = true

						if classData.metatable then
							if newLock then
								classData.metatable = deepCopy(classData.metatable)
							end

							for k, v in pairs(classData.metatable) do
								thisInstanceMeta[k] = v
							end
						end
					end

					for k, v in pairs(instanceMeta) do
						thisInstanceMeta[k] = v
					end

					classData.instanceMeta = thisInstanceMeta
				end

				local finalInstance = setmetatable(instance, thisInstanceMeta)
				instances[finalInstance] = self

				if classData.preconstructor then
					classData.preconstructor(finalInstance, ...)
				end

				local stack = {classData}
				local argsStack = {{...}}

				while stack[#stack].superclass do
					local classData = stack[#stack]
					local superArgs = argsStack[#stack]

					if classData.superArgs then
						superArgs = {classData.superArgs(finalInstance, unpack(superArgs))}
					end

					local superclassData = classes[stack[#stack].superclass]
					stack[#stack + 1] = superclassData
					argsStack[#stack] = superArgs

					if superclassData.preconstructor then
						superclassData.preconstructor(finalInstance, unpack(superArgs))
					end
				end

				while #stack > 0 do
					local classData = stack[#stack]
					local args = argsStack[#stack]

					if classData.constructor then
						classData.constructor(finalInstance, unpack(args))
					end

					stack[#stack] = nil
				end

				return finalInstance
			end

			function classMeta:__tostring()
				return self.__ClassName
			end

			classMeta.__metatable = '<Class>'
		end

		instanceMeta = {} do
			function instanceMeta:__index(key)
				local instanceClass = instances[self]
				local classData = classes[instanceClass]

				if key == '__Metatable' then
					error('Cannot index __Metatable field of class through instance', 2)
				elseif key == '__Preconstruct' then
					error('Cannot index __Preconstruct method of class through instance', 2)
				elseif key == '__Construct' then
					error('Cannot index __Construct method of class through instance', 2)
				elseif key == '__SuperArgs' then
					error('Cannot index __SuperArgs method of class through instance', 2)
				elseif key == '__Class' then
					return instanceClass
				elseif key == '__Super' then
					return classData.superclass
				elseif key == '__ClassName' then
					return classData.name
				elseif key == '__ClassLib' then
					return class
				elseif globalInstancePrototype[key] then
					return globalInstancePrototype[key]
				elseif globalPrototype[key] then
					return globalPrototype[key]
				elseif key:sub(1, 2) == '__' then
					error('Cannot index field beginning with __ (reserved)', 2)
				end

				return instanceClass[key]
			end

			function instanceMeta:__newindex(key, value)
				if key == '__Metatable' then
					error('Cannot index __Metatable field of class through instance', 2)
				elseif key == '__Prefonstruct' then
					error('Cannot index __Preconstruct method of class through instance', 2)
				elseif key == '__Construct' then
					error('Cannot index __Construct method of class through instance', 2)
				elseif key == '__SuperArgs' then
					error('Cannot index __SuperArgs method of class through instance', 2)
				elseif key == '__Class' then
					error('Cannot set __Class field of class instance', 2)
				elseif key == '__Super' then
					error('Cannot set __Super field of class instance', 2)
				elseif key == '__ClassName' then
					error('Cannot set __ClassName field of class instance', 2)
				elseif key == '__ClassLib' then
					error('Cannot set __ClassLib field of class instance', 2)
				elseif globalInstancePrototype[key] then
					error('Cannot override global instance prototype', 2)
				elseif globalPrototype[key] then
					error('Cannot override global prototype', 2)
				elseif key:sub(1, 2) == '__' then
					error('Cannot index field beginning with __ (reserved)', 2)
				end

				rawset(self, key, value)
			end

			function instanceMeta:__tostring()
				local classData = classes[instances[self]]

				if classData.metatable and classData.metatable.__tostring then
					return classData.metatable.__tostring()
				end

				return classData.name .. '()'
			end

			instanceMeta.__metatable = '<ClassInstance>'
		end

		globalPrototype = {} do
			function globalPrototype:__IsA(class)
				if not classes[class] and type(class) ~= 'string' then
					error('Must call __IsA method with a class or class name', 2)
				end

				local current = self.__Class

				while current ~= nil do
					if current == class or current.__ClassName == class then return true end

					current = current.__Super
				end

				return false
			end

			function globalPrototype:__Subclass(name)
				return class(name, self.__Class)
			end
		end

		globalClassPrototype = {}
		globalInstancePrototype = {}

		class = setmetatable({
			IsClass = function(self, arg)
				return classes[arg] ~= nil
			end,
			IsInstance = function(self, arg)
				return instances[arg] ~= nil
			end,
			IsClassOrInstance = function(self, arg)
				return self:IsClass(arg) or self:IsInstance(arg)
			end,
			__InternalState__CAUTION_DO_NOT_USE_YOU_DO_NOT_NEED_THIS__ = {
				classes = classes,
				instances = instances,

				classMeta = classMeta,
				instanceMeta = instanceMeta,

				globalPrototype = globalPrototype,
				globalClassPrototype = globalClassPrototype,
				globalInstancePrototype = globalInstancePrototype
			}
		}, {
			__call = function(self, name, superclass)
				if type(name) ~= 'string' then
					error('Class must have a name', 2)
				end

				if superclass ~= nil and not classes[superclass] then
					error('Superclass is not a class', 2)
				end

				local class = {}
				local classData = {
					name = name,
					superclass = superclass,
					metatable = nil,
					metatableLocked = false,
					instanceMeta = nil,
					preconstructor = nil,
					constructor = nil,
					superArgs = nil
				}

				classes[class] = classData

				return setmetatable(class, classMeta)
			end
		})

		return class
	end
	local MinischedScript = {}
	function MinischedScript.new(Yield)
		local class = ClassScript.new()

		local Minisched = class('Minisched') do
			function Minisched:__Construct(bind)
				self.schedule = {}

				if bind ~= false then
					--self:BindTo(game:GetService('RunService').Stepped)
					self:FastRepeat()
				end
			end

			function Minisched:SortSchedule()
				table.sort(self.schedule, function(a, b)
					return a.at < b.at
				end)
			end

			function Minisched:Schedule(coro, at, ...)
				local task = {coro = coro, at = at, args = table.pack(...)}

				table.insert(self.schedule, task)
				self:SortSchedule()

				return task
			end

			function Minisched:Unschedule(task)
				local i = table.find(self.schedule, task)
				if i then table.remove(self.schedule, i) end

				return i ~= nil
			end

			function Minisched:Resume(task, remove)
				if remove then self:Unschedule(task) end

				local status = coroutine.status(task.coro)
				if status ~= 'suspended' then
					--warn('Encountered a scheduled coroutine with status ' .. status)
					return
				end

				local parent = Minisched.Current
				Minisched.Current = self
				local results = table.pack(coroutine.resume(task.coro, table.unpack(task.args, 1, task.args.n)))
				Minisched.Current = parent

				if not results[1] then
					--warn(results[2])
					--warn(debug.traceback(task.coro))
				end

				return table.unpack(results, 1, results.n)
			end

			function Minisched:GetOverdueTasks(t, remove)
				local t = t or tick()
				local overdue = {}

				for _, task in ipairs(self.schedule) do
					if task.at > t then break end
					table.insert(overdue, task)
				end

				if remove then
					for i = 1, #overdue do
						table.remove(self.schedule, 1)
					end
				end

				return overdue
			end

			function Minisched:Dispatch()
				local cancel = false

				local ChangedConnection = Yield.Changed:Connect(function(Value)
					if Value == true then
						cancel = true
					end
				end)
				local overdue = self:GetOverdueTasks(tick(), true)

				for _, task in ipairs(overdue) do
					if cancel == false then
						self:Resume(task)
					end
				end
				pcall(function()
					ChangedConnection:Disconnect()
				end)
			end

			function Minisched:FastRepeat()
				coroutine.resume(coroutine.create(function()
					while true do
						self:Dispatch()
						wait(0.00001)
					end
				end))
			end

			function Minisched:BindTo(event)
				return event:Connect(function()
					self:Dispatch()
				end)
			end

			function Minisched:New(...)
				return Minisched(...)
			end

			--------------------------------------------------------------------------------
			-- Yields
			--------------------------------------------------------------------------------

			local function ensureYieldable()
				if not coroutine.isyieldable() then
					error('Cannot yield')
				end
			end

			function Minisched:Wait(t, ...)
				ensureYieldable()

				return coroutine.yield(self:Schedule(coroutine.running(), tick() + (t or 0), ...))
			end

			local function eventSchedule(self, event)
				local task = {coro = coroutine.running()}

				local conn
				conn = event:Connect(function(...)
					conn:Disconnect()
					task.args = table.pack(...)
					self:Resume(task)
				end)

				return conn
			end

			function Minisched:EventWait(event)
				ensureYieldable()
				eventSchedule(self, event)
				return coroutine.yield()
			end

			function Minisched:EventTimeout(event, t)
				ensureYieldable()

				local running = coroutine.running()

				local symbol = newproxy()
				local eventTask = eventSchedule(self, event)
				local waitTask = self:Schedule(running, tick() + (t or 0), symbol)
				local results = table.pack(coroutine.yield())

				if results[1] == symbol then
					eventTask:Disconnect()
					return false
				end

				self:Unschedule(waitTask)

				return true, table.unpack(results, 1, results.n)
			end

			function Minisched:Encapsulate(func, ...)
				ensureYieldable()

				local task = {coro = coroutine.running()}
				local err

				Minisched.Corospawn(function(...)
					local results = table.pack(pcall(func, ...))
					err = not results[1]
					task.args = not err and results or table.pack(results[2])
					self:Resume(task)
				end, ...)

				local results = table.pack(coroutine.yield())

				if err then
					error(results[1], 2)
				end

				return results
			end

			function Minisched:Clear()
				table.clear(self.schedule)
				Yield.Value = true
				self:Schedule(coroutine.create(function()
					Yield.Value = false
				end), tick())
			end

			--------------------------------------------------------------------------------
			-- Spawns
			--------------------------------------------------------------------------------

			function Minisched.Corospawn(func, ...)
				local coro = coroutine.create(func)
				return coro, coroutine.resume(coro, ...)
			end

			function Minisched.Quickspawn(func, ...)
				if not Minisched.QuickspawnEvent then
					Minisched.QuickspawnEvent = Instance.new('BindableEvent')
					Minisched.QuickspawnEvent.Event:Connect(function(func, ...)
						func(...)
					end)
				end

				Minisched.QuickspawnEvent:Fire(func, ...)
			end

			function Minisched:Queue(func, ...)
				local coro = coroutine.create(func)
				return coro, self:Schedule(coro, 0, ...)
			end

			function Minisched:Delegate(func, ...)
				local coro, queued = self:Queue(func, ...)
				return coro, self:Resume(queued, true)
			end

			function Minisched:Delay(func, t, ...)
				local coro = coroutine.create(func)
				return coro, self:Schedule(coro, tick() + (t or 0), ...)
			end

			--------------------------------------------------------------------------------
			-- Auto-targeting
			--------------------------------------------------------------------------------

			Minisched.Current = nil

			local function getCurrentMinisched()
				return Minisched.Current or error('Not running in Minisched')
			end

			function Minisched.TWait(...)         getCurrentMinisched():Wait(...)         end
			function Minisched.TEventWait(...)    getCurrentMinisched():EventWait(...)    end
			function Minisched.TEventTimeout(...) getCurrentMinisched():EventTimeout(...) end
			function Minisched.TEncapsulate(...)  getCurrentMinisched():Encapsulate(...)  end
			function Minisched.TQueue(...)        getCurrentMinisched():Queue(...)        end
			function Minisched.TDelegate(...)     getCurrentMinisched():Delegate(...)     end
			function Minisched.TDelay(...)        getCurrentMinisched():Delay(...)        end
		end

		return Minisched()
	end
	local CommandPrompt, CommandPromptQueue = nil, {}
	Framework:Connect("Execute Command", function(Command, Output)
		table.insert(CommandPromptQueue, {Command = Command, Output = Output})
		if not CommandPrompt then
			CommandPrompt = Instance.new("ScreenGui")
			CommandPrompt.Name = "commandPrompt"
			CommandPrompt.ResetOnSpawn = false
			CommandPrompt.DisplayOrder = ReservedDisplayOrder + 1
			local Frame = Instance.new("Frame")
			Frame.BackgroundColor3 = Color3.new(0, 0, 0)
			Frame.BackgroundTransparency = 0.3
			Frame.BorderSizePixel = 0
			Frame.Size = UDim2.new(0, 546, 0, 254)
			Frame.Parent = CommandPrompt
			local Input = Instance.new("TextLabel")
			Input.Name = "input"
			Input.BackgroundTransparency = 1
			Input.Position = UDim2.new(0.06, 0, 0, 0)
			Input.Size = UDim2.new(0, 513, 0, 23)
			Input.Font = Enum.Font.Code
			Input.Text = ""
			Input.TextColor3 = Color3.new(1, 1, 1)
			Input.TextSize = 14
			Input.TextWrapped = true
			Input.TextXAlignment = Enum.TextXAlignment.Left
			Input.Parent = Frame
			local Arrow = Instance.new("TextLabel")
			Arrow.Name = "arrow"
			Arrow.BackgroundTransparency = 1
			Arrow.Size = UDim2.new(0, 33, 0, 23)
			Arrow.Font = Enum.Font.Code
			Arrow.Text = ">"
			Arrow.TextColor3 = Color3.new(1, 1, 1)
			Arrow.TextSize = 14
			Arrow.TextTransparency = 0.25
			Arrow.Parent = Frame
			local Output = Instance.new("TextLabel")
			Output.Name = "output"
			Output.BackgroundTransparency = 1
			Output.Position = UDim2.new(0.018, 0, 0.091, 0)
			Output.Size = UDim2.new(0, 536, 0, 230)
			Output.Font = Enum.Font.Code
			Output.Text = ""
			Output.TextColor3 = Color3.new(1, 1, 1)
			Output.TextSize = 14
			Output.TextWrapped = true
			Output.TextXAlignment = Enum.TextXAlignment.Left
			Output.TextYAlignment = Enum.TextYAlignment.Top
			Output.Parent = Frame
			CommandPrompt.Parent = LocalPlayer:WaitForChild("PlayerGui")
			local Stop = false
			repeat
				local QueueItem = CommandPromptQueue[1]
				table.remove(CommandPromptQueue, 1)
				local Command, OutputString = QueueItem.Command, QueueItem.Output
				Input.MaxVisibleGraphemes = 0
				Input.Text = Command
				for Index = 1, string.len(Command) do
					Input.MaxVisibleGraphemes = Index
					wait(0.02)
				end
				wait(0.2)
				if Output.Text ~= "" then
					OutputString = OutputString.."\n"
				end
				Input.Text = ""
				Output.Text = OutputString..Output.Text
				if #CommandPromptQueue < 1 then
					local Tick = tick()
					local TimeElapsed = 0
					repeat
						local CurrentTick = tick()
						TimeElapsed += CurrentTick - Tick
						Tick = CurrentTick
						game:GetService("RunService").RenderStepped:Wait()
					until TimeElapsed >= 2 or #CommandPromptQueue > 0
					if #CommandPromptQueue < 1 then
						Stop = true
					end
				end
			until Stop
			CommandPrompt:Destroy()
			CommandPrompt = nil
		end
	end)
	local AffectedParts = {}
	function Delete(Origin, Direction, DeletedParts)
		pcall(function()
			local DeletingParts, DeletedParts = {}, DeletedParts or {}
			local function Raycast(World)
				pcall(function()
					if (World:IsA("ViewportFrame") or World == game:GetService("Workspace")) and World ~= Instances.Viewport[""] then
						local Results
						if World:IsA("ViewportFrame") then
							local WorldModel = InstanceNew("WorldModel")
							WorldModel.Name = ""
							local Parents = {}
							for _, AChild in ipairs(World:GetDescendants()) do
								pcall(function()
									if AChild:IsA("BasePart") then
										table.insert(Parents, {Instance = AChild, Parent = AChild.Parent})
										AChild.Parent = WorldModel
									end
								end)
							end
							WorldModel.Parent = World
							Results = WorldModel:Raycast(Origin, Direction, RaycastParams.new())
							for _, AChild in ipairs(Parents) do
								pcall(function()
									AChild.Instance.Parent = AChild.Parent
								end)
							end
							Parents = nil
							pcall(function()
								game:GetService("Debris"):AddItem(WorldModel, 0)
							end)
						else
							Results = World:Raycast(Origin, Direction, RaycastParams.new())
						end
						if Results then
							local Model = Results.Instance:FindFirstAncestorOfClass("Model")
							local Parts
							if not Model then
								Parts = {Results.Instance}
							else
								Parts = Model:GetDescendants()
							end
							for _, APart in ipairs(Parts) do
								pcall(function()
									if LocalPlayer == TargetPlayer then
										table.insert(DeletingParts, APart)
									end
								end)
								coroutine.resume(coroutine.create(function()
									pcall(function()
										if APart:IsA("BasePart") and not table.find(DeletedParts, APart) and not table.find(AffectedParts, APart) then
											pcall(function()
												table.insert(AffectedParts, APart)
											end)
											local Tween = RealTweenService:Create(APart, TweenInfo.new(), {Position = APart.Position + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)), Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)), Transparency = 1})
											local IsWhite = false
											local Glitches = game:GetService("RunService").RenderStepped:Connect(function()
												pcall(function()
													if IsWhite then
														APart.Color = Color3.new(1, 1, 1)
													else
														APart.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
													end
												end)
												pcall(function()
													IsWhite = not IsWhite
												end)
											end)
											APart.Anchored = true
											local Anchored = APart:GetPropertyChangedSignal("Anchored"):Connect(function()
												APart.Anchored = true
											end)
											APart.CanCollide = false
											local CanCollide = APart:GetPropertyChangedSignal("CanCollide"):Connect(function()
												APart.CanCollide = false
											end)
											pcall(function()
												Tween:Play()
												Tween.Completed:Wait()
											end)
											pcall(function()
												Glitches:Disconnect()
											end)
											pcall(function()
												Anchored:Disconnect()
											end)
											pcall(function()
												CanCollide:Disconnect()
											end)
											pcall(function()
												game:GetService("Debris"):AddItem(APart, 0)
											end)
											pcall(function()
												Framework:FireServer("Delete Instance", true, APart)
											end)
											pcall(function()
												table.remove(AffectedParts, table.find(AffectedParts, APart))
											end)
										end
									end)
								end))
							end
						end
					end
				end)
			end
			Raycast(game:GetService("Workspace"))
			for _, AWorld in ipairs(PlayerGui:GetDescendants()) do
				Raycast(AWorld)
			end
			if LocalPlayer == TargetPlayer then
				Framework:FireServer("Delete", true, {Origin = Origin, Direction = Direction, DeletedParts = DeletedParts})
			end
		end)
	end
	if LocalPlayer ~= TargetPlayer then
		Framework:Connect("Delete", Delete)
	end
	local Fonts = {
		Aller = function()
		--[[
	@Font Aller
	@Sizes {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8}
	@Author N/A
	@Link N/A
--]]

			local module = {}

			module.atlases = {
				[1] = "http://www.roblox.com/asset/?id=6462556879";
				[2] = "http://www.roblox.com/asset/?id=6462557854";
			};

			module.font = {
				information = {
					family = "Aller",
					styles = {"Regular"},
					sizes = {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8},
					useEnums = true
				},
				styles = {
					["Regular"] = {
						["96"] = {
							lineHeight = 94,
							firstAdjust = 17,
							characters = {
								["32"] = { x = 0, y = 0, width = 0, height = 0, xadvance = 22, yoffset = 93, atlas = 0 },
								["33"] = { x = 5, y = 0, width = 22, height = 72, xadvance = 28, yoffset = 24, atlas = 0 },
								["34"] = { x = 32, y = 0, width = 36, height = 31, xadvance = 40, yoffset = 23, atlas = 0 },
								["35"] = { x = 73, y = 0, width = 67, height = 68, xadvance = 69, yoffset = 26, atlas = 0 },
								["36"] = { x = 145, y = 0, width = 51, height = 88, xadvance = 55, yoffset = 17, atlas = 0 },
								["37"] = { x = 201, y = 0, width = 96, height = 72, xadvance = 98, yoffset = 24, atlas = 0 },
								["38"] = { x = 302, y = 0, width = 73, height = 74, xadvance = 71, yoffset = 22, atlas = 0 },
								["39"] = { x = 380, y = 0, width = 18, height = 31, xadvance = 22, yoffset = 23, atlas = 0 },
								["40"] = { x = 403, y = 0, width = 29, height = 93, xadvance = 30, yoffset = 18, atlas = 0 },
								["41"] = { x = 437, y = 0, width = 28, height = 93, xadvance = 30, yoffset = 18, atlas = 0 },
								["42"] = { x = 470, y = 0, width = 45, height = 42, xadvance = 45, yoffset = 24, atlas = 0 },
								["43"] = { x = 520, y = 0, width = 51, height = 48, xadvance = 57, yoffset = 36, atlas = 0 },
								["44"] = { x = 576, y = 0, width = 20, height = 26, xadvance = 20, yoffset = 80, atlas = 0 },
								["45"] = { x = 601, y = 0, width = 32, height = 13, xadvance = 34, yoffset = 60, atlas = 0 },
								["46"] = { x = 638, y = 0, width = 19, height = 16, xadvance = 22, yoffset = 80, atlas = 0 },
								["47"] = { x = 662, y = 0, width = 39, height = 73, xadvance = 38, yoffset = 23, atlas = 0 },
								["48"] = { x = 706, y = 0, width = 54, height = 62, xadvance = 56, yoffset = 32, atlas = 0 },
								["49"] = { x = 765, y = 0, width = 52, height = 61, xadvance = 56, yoffset = 32, atlas = 0 },
								["50"] = { x = 822, y = 0, width = 51, height = 61, xadvance = 56, yoffset = 32, atlas = 0 },
								["51"] = { x = 878, y = 0, width = 51, height = 67, xadvance = 56, yoffset = 33, atlas = 0 },
								["52"] = { x = 934, y = 0, width = 56, height = 68, xadvance = 56, yoffset = 31, atlas = 0 },
								["53"] = { x = 0, y = 99, width = 51, height = 67, xadvance = 56, yoffset = 33, atlas = 0 },
								["54"] = { x = 56, y = 99, width = 55, height = 69, xadvance = 56, yoffset = 25, atlas = 0 },
								["55"] = { x = 116, y = 99, width = 55, height = 68, xadvance = 56, yoffset = 33, atlas = 0 },
								["56"] = { x = 176, y = 99, width = 54, height = 69, xadvance = 56, yoffset = 25, atlas = 0 },
								["57"] = { x = 235, y = 99, width = 53, height = 69, xadvance = 56, yoffset = 32, atlas = 0 },
								["58"] = { x = 293, y = 99, width = 19, height = 53, xadvance = 22, yoffset = 43, atlas = 0 },
								["59"] = { x = 317, y = 99, width = 21, height = 64, xadvance = 24, yoffset = 42, atlas = 0 },
								["60"] = { x = 343, y = 99, width = 51, height = 49, xadvance = 56, yoffset = 36, atlas = 0 },
								["61"] = { x = 399, y = 99, width = 51, height = 31, xadvance = 57, yoffset = 45, atlas = 0 },
								["62"] = { x = 455, y = 99, width = 51, height = 49, xadvance = 56, yoffset = 36, atlas = 0 },
								["63"] = { x = 511, y = 99, width = 45, height = 72, xadvance = 46, yoffset = 24, atlas = 0 },
								["64"] = { x = 561, y = 99, width = 92, height = 88, xadvance = 95, yoffset = 22, atlas = 0 },
								["65"] = { x = 658, y = 99, width = 60, height = 68, xadvance = 58, yoffset = 26, atlas = 0 },
								["66"] = { x = 723, y = 99, width = 54, height = 70, xadvance = 56, yoffset = 24, atlas = 0 },
								["67"] = { x = 782, y = 99, width = 57, height = 69, xadvance = 58, yoffset = 24, atlas = 0 },
								["68"] = { x = 844, y = 99, width = 63, height = 69, xadvance = 66, yoffset = 24, atlas = 0 },
								["69"] = { x = 912, y = 99, width = 49, height = 67, xadvance = 51, yoffset = 26, atlas = 0 },
								["70"] = { x = 966, y = 99, width = 47, height = 68, xadvance = 48, yoffset = 26, atlas = 0 },
								["71"] = { x = 0, y = 198, width = 59, height = 69, xadvance = 64, yoffset = 24, atlas = 0 },
								["72"] = { x = 64, y = 198, width = 59, height = 68, xadvance = 64, yoffset = 25, atlas = 0 },
								["73"] = { x = 128, y = 198, width = 21, height = 68, xadvance = 26, yoffset = 25, atlas = 0 },
								["74"] = { x = 154, y = 198, width = 33, height = 68, xadvance = 38, yoffset = 26, atlas = 0 },
								["75"] = { x = 192, y = 198, width = 60, height = 68, xadvance = 57, yoffset = 25, atlas = 0 },
								["76"] = { x = 257, y = 198, width = 47, height = 68, xadvance = 47, yoffset = 25, atlas = 0 },
								["77"] = { x = 309, y = 198, width = 70, height = 68, xadvance = 76, yoffset = 25, atlas = 0 },
								["78"] = { x = 384, y = 198, width = 58, height = 68, xadvance = 64, yoffset = 25, atlas = 0 },
								["79"] = { x = 447, y = 198, width = 65, height = 69, xadvance = 68, yoffset = 24, atlas = 0 },
								["80"] = { x = 517, y = 198, width = 52, height = 69, xadvance = 53, yoffset = 24, atlas = 0 },
								["81"] = { x = 574, y = 198, width = 66, height = 83, xadvance = 68, yoffset = 24, atlas = 0 },
								["82"] = { x = 645, y = 198, width = 59, height = 69, xadvance = 56, yoffset = 24, atlas = 0 },
								["83"] = { x = 709, y = 198, width = 50, height = 69, xadvance = 52, yoffset = 24, atlas = 0 },
								["84"] = { x = 764, y = 198, width = 50, height = 68, xadvance = 50, yoffset = 26, atlas = 0 },
								["85"] = { x = 819, y = 198, width = 58, height = 69, xadvance = 63, yoffset = 25, atlas = 0 },
								["86"] = { x = 882, y = 198, width = 61, height = 68, xadvance = 59, yoffset = 25, atlas = 0 },
								["87"] = { x = 0, y = 297, width = 87, height = 68, xadvance = 86, yoffset = 25, atlas = 0 },
								["88"] = { x = 92, y = 297, width = 59, height = 68, xadvance = 57, yoffset = 25, atlas = 0 },
								["89"] = { x = 156, y = 297, width = 58, height = 68, xadvance = 56, yoffset = 25, atlas = 0 },
								["90"] = { x = 219, y = 297, width = 55, height = 67, xadvance = 53, yoffset = 26, atlas = 0 },
								["91"] = { x = 279, y = 297, width = 27, height = 92, xadvance = 29, yoffset = 19, atlas = 0 },
								["92"] = { x = 311, y = 297, width = 39, height = 73, xadvance = 39, yoffset = 23, atlas = 0 },
								["93"] = { x = 355, y = 297, width = 29, height = 92, xadvance = 31, yoffset = 19, atlas = 0 },
								["94"] = { x = 389, y = 297, width = 50, height = 38, xadvance = 52, yoffset = 23, atlas = 0 },
								["95"] = { x = 444, y = 297, width = 50, height = 11, xadvance = 48, yoffset = 93, atlas = 0 },
								["96"] = { x = 499, y = 297, width = 40, height = 18, xadvance = 47, yoffset = 22, atlas = 0 },
								["97"] = { x = 544, y = 297, width = 44, height = 50, xadvance = 48, yoffset = 44, atlas = 0 },
								["98"] = { x = 593, y = 297, width = 53, height = 70, xadvance = 55, yoffset = 24, atlas = 0 },
								["99"] = { x = 651, y = 297, width = 44, height = 50, xadvance = 44, yoffset = 44, atlas = 0 },
								["100"] = { x = 700, y = 297, width = 51, height = 70, xadvance = 56, yoffset = 24, atlas = 0 },
								["101"] = { x = 756, y = 297, width = 50, height = 51, xadvance = 52, yoffset = 44, atlas = 0 },
								["102"] = { x = 811, y = 297, width = 40, height = 71, xadvance = 36, yoffset = 23, atlas = 0 },
								["103"] = { x = 856, y = 297, width = 53, height = 73, xadvance = 52, yoffset = 44, atlas = 0 },
								["104"] = { x = 914, y = 297, width = 50, height = 69, xadvance = 54, yoffset = 24, atlas = 0 },
								["105"] = { x = 969, y = 297, width = 22, height = 70, xadvance = 27, yoffset = 24, atlas = 0 },
								["106"] = { x = 996, y = 297, width = 23, height = 87, xadvance = 28, yoffset = 24, atlas = 0 },
								["107"] = { x = 0, y = 396, width = 52, height = 69, xadvance = 49, yoffset = 24, atlas = 0 },
								["108"] = { x = 57, y = 396, width = 30, height = 70, xadvance = 28, yoffset = 24, atlas = 0 },
								["109"] = { x = 92, y = 396, width = 76, height = 50, xadvance = 80, yoffset = 44, atlas = 0 },
								["110"] = { x = 173, y = 396, width = 50, height = 50, xadvance = 54, yoffset = 44, atlas = 0 },
								["111"] = { x = 228, y = 396, width = 52, height = 51, xadvance = 54, yoffset = 44, atlas = 0 },
								["112"] = { x = 285, y = 396, width = 53, height = 71, xadvance = 55, yoffset = 44, atlas = 0 },
								["113"] = { x = 343, y = 396, width = 51, height = 71, xadvance = 56, yoffset = 44, atlas = 0 },
								["114"] = { x = 399, y = 396, width = 35, height = 49, xadvance = 35, yoffset = 45, atlas = 0 },
								["115"] = { x = 439, y = 396, width = 41, height = 51, xadvance = 42, yoffset = 44, atlas = 0 },
								["116"] = { x = 485, y = 396, width = 34, height = 61, xadvance = 33, yoffset = 33, atlas = 0 },
								["117"] = { x = 524, y = 396, width = 49, height = 50, xadvance = 54, yoffset = 45, atlas = 0 },
								["118"] = { x = 578, y = 396, width = 52, height = 49, xadvance = 50, yoffset = 45, atlas = 0 },
								["119"] = { x = 635, y = 396, width = 74, height = 49, xadvance = 73, yoffset = 45, atlas = 0 },
								["120"] = { x = 714, y = 396, width = 50, height = 49, xadvance = 48, yoffset = 45, atlas = 0 },
								["121"] = { x = 769, y = 396, width = 52, height = 72, xadvance = 50, yoffset = 45, atlas = 0 },
								["122"] = { x = 826, y = 396, width = 45, height = 48, xadvance = 44, yoffset = 45, atlas = 0 },
								["123"] = { x = 876, y = 396, width = 37, height = 92, xadvance = 39, yoffset = 19, atlas = 0 },
								["124"] = { x = 918, y = 396, width = 23, height = 94, xadvance = 32, yoffset = 17, atlas = 0 },
								["125"] = { x = 946, y = 396, width = 36, height = 92, xadvance = 38, yoffset = 19, atlas = 0 },
								["126"] = { x = 0, y = 495, width = 46, height = 18, xadvance = 45, yoffset = 46, atlas = 0 }
							},
							kerning = {
							}
						},
						["60"] = {
							lineHeight = 59,
							firstAdjust = 12,
							characters = {
								["32"] = { x = 0, y = 594, width = 0, height = 0, xadvance = 14, yoffset = 59, atlas = 0 },
								["33"] = { x = 5, y = 594, width = 14, height = 46, xadvance = 18, yoffset = 15, atlas = 0 },
								["34"] = { x = 24, y = 594, width = 23, height = 20, xadvance = 24, yoffset = 14, atlas = 0 },
								["35"] = { x = 52, y = 594, width = 41, height = 43, xadvance = 42, yoffset = 17, atlas = 0 },
								["36"] = { x = 98, y = 594, width = 33, height = 56, xadvance = 35, yoffset = 10, atlas = 0 },
								["37"] = { x = 136, y = 594, width = 60, height = 47, xadvance = 61, yoffset = 15, atlas = 0 },
								["38"] = { x = 201, y = 594, width = 46, height = 47, xadvance = 45, yoffset = 14, atlas = 0 },
								["39"] = { x = 252, y = 594, width = 12, height = 20, xadvance = 13, yoffset = 14, atlas = 0 },
								["40"] = { x = 269, y = 594, width = 18, height = 59, xadvance = 18, yoffset = 12, atlas = 0 },
								["41"] = { x = 292, y = 594, width = 18, height = 59, xadvance = 18, yoffset = 12, atlas = 0 },
								["42"] = { x = 315, y = 594, width = 29, height = 27, xadvance = 29, yoffset = 15, atlas = 0 },
								["43"] = { x = 349, y = 594, width = 32, height = 30, xadvance = 36, yoffset = 23, atlas = 0 },
								["44"] = { x = 386, y = 594, width = 13, height = 17, xadvance = 12, yoffset = 50, atlas = 0 },
								["45"] = { x = 404, y = 594, width = 20, height = 8, xadvance = 21, yoffset = 39, atlas = 0 },
								["46"] = { x = 429, y = 594, width = 12, height = 10, xadvance = 14, yoffset = 51, atlas = 0 },
								["47"] = { x = 446, y = 594, width = 24, height = 46, xadvance = 24, yoffset = 15, atlas = 0 },
								["48"] = { x = 475, y = 594, width = 34, height = 40, xadvance = 35, yoffset = 20, atlas = 0 },
								["49"] = { x = 514, y = 594, width = 32, height = 39, xadvance = 35, yoffset = 20, atlas = 0 },
								["50"] = { x = 551, y = 594, width = 32, height = 39, xadvance = 35, yoffset = 20, atlas = 0 },
								["51"] = { x = 588, y = 594, width = 33, height = 42, xadvance = 35, yoffset = 21, atlas = 0 },
								["52"] = { x = 626, y = 594, width = 35, height = 43, xadvance = 35, yoffset = 20, atlas = 0 },
								["53"] = { x = 666, y = 594, width = 32, height = 42, xadvance = 35, yoffset = 21, atlas = 0 },
								["54"] = { x = 703, y = 594, width = 34, height = 44, xadvance = 35, yoffset = 16, atlas = 0 },
								["55"] = { x = 742, y = 594, width = 34, height = 43, xadvance = 35, yoffset = 21, atlas = 0 },
								["56"] = { x = 781, y = 594, width = 34, height = 43, xadvance = 35, yoffset = 17, atlas = 0 },
								["57"] = { x = 820, y = 594, width = 34, height = 44, xadvance = 35, yoffset = 20, atlas = 0 },
								["58"] = { x = 859, y = 594, width = 12, height = 34, xadvance = 14, yoffset = 27, atlas = 0 },
								["59"] = { x = 876, y = 594, width = 13, height = 41, xadvance = 15, yoffset = 27, atlas = 0 },
								["60"] = { x = 894, y = 594, width = 32, height = 31, xadvance = 35, yoffset = 23, atlas = 0 },
								["61"] = { x = 931, y = 594, width = 32, height = 19, xadvance = 35, yoffset = 28, atlas = 0 },
								["62"] = { x = 968, y = 594, width = 32, height = 31, xadvance = 36, yoffset = 23, atlas = 0 },
								["63"] = { x = 0, y = 658, width = 28, height = 46, xadvance = 28, yoffset = 15, atlas = 0 },
								["64"] = { x = 33, y = 658, width = 58, height = 55, xadvance = 60, yoffset = 15, atlas = 0 },
								["65"] = { x = 96, y = 658, width = 38, height = 42, xadvance = 36, yoffset = 17, atlas = 0 },
								["66"] = { x = 139, y = 658, width = 34, height = 44, xadvance = 35, yoffset = 16, atlas = 0 },
								["67"] = { x = 178, y = 658, width = 35, height = 44, xadvance = 36, yoffset = 16, atlas = 0 },
								["68"] = { x = 218, y = 658, width = 40, height = 44, xadvance = 41, yoffset = 16, atlas = 0 },
								["69"] = { x = 263, y = 658, width = 31, height = 42, xadvance = 32, yoffset = 17, atlas = 0 },
								["70"] = { x = 299, y = 658, width = 29, height = 42, xadvance = 30, yoffset = 17, atlas = 0 },
								["71"] = { x = 333, y = 658, width = 37, height = 44, xadvance = 40, yoffset = 16, atlas = 0 },
								["72"] = { x = 375, y = 658, width = 37, height = 42, xadvance = 41, yoffset = 17, atlas = 0 },
								["73"] = { x = 417, y = 658, width = 14, height = 42, xadvance = 17, yoffset = 17, atlas = 0 },
								["74"] = { x = 436, y = 658, width = 21, height = 43, xadvance = 23, yoffset = 17, atlas = 0 },
								["75"] = { x = 462, y = 658, width = 38, height = 42, xadvance = 36, yoffset = 17, atlas = 0 },
								["76"] = { x = 505, y = 658, width = 30, height = 42, xadvance = 29, yoffset = 17, atlas = 0 },
								["77"] = { x = 540, y = 658, width = 44, height = 42, xadvance = 48, yoffset = 17, atlas = 0 },
								["78"] = { x = 589, y = 658, width = 38, height = 42, xadvance = 41, yoffset = 17, atlas = 0 },
								["79"] = { x = 632, y = 658, width = 41, height = 44, xadvance = 42, yoffset = 16, atlas = 0 },
								["80"] = { x = 678, y = 658, width = 33, height = 43, xadvance = 34, yoffset = 16, atlas = 0 },
								["81"] = { x = 716, y = 658, width = 41, height = 53, xadvance = 42, yoffset = 16, atlas = 0 },
								["82"] = { x = 762, y = 658, width = 37, height = 43, xadvance = 35, yoffset = 16, atlas = 0 },
								["83"] = { x = 804, y = 658, width = 31, height = 44, xadvance = 31, yoffset = 16, atlas = 0 },
								["84"] = { x = 840, y = 658, width = 31, height = 42, xadvance = 31, yoffset = 17, atlas = 0 },
								["85"] = { x = 876, y = 658, width = 36, height = 43, xadvance = 39, yoffset = 17, atlas = 0 },
								["86"] = { x = 917, y = 658, width = 38, height = 42, xadvance = 37, yoffset = 17, atlas = 0 },
								["87"] = { x = 960, y = 658, width = 55, height = 42, xadvance = 54, yoffset = 17, atlas = 0 },
								["88"] = { x = 0, y = 722, width = 37, height = 42, xadvance = 36, yoffset = 17, atlas = 0 },
								["89"] = { x = 42, y = 722, width = 36, height = 42, xadvance = 35, yoffset = 17, atlas = 0 },
								["90"] = { x = 83, y = 722, width = 34, height = 42, xadvance = 33, yoffset = 17, atlas = 0 },
								["91"] = { x = 122, y = 722, width = 17, height = 58, xadvance = 18, yoffset = 12, atlas = 0 },
								["92"] = { x = 144, y = 722, width = 24, height = 46, xadvance = 24, yoffset = 15, atlas = 0 },
								["93"] = { x = 173, y = 722, width = 18, height = 58, xadvance = 18, yoffset = 12, atlas = 0 },
								["94"] = { x = 196, y = 722, width = 31, height = 24, xadvance = 32, yoffset = 15, atlas = 0 },
								["95"] = { x = 232, y = 722, width = 31, height = 8, xadvance = 30, yoffset = 58, atlas = 0 },
								["96"] = { x = 268, y = 722, width = 25, height = 11, xadvance = 29, yoffset = 15, atlas = 0 },
								["97"] = { x = 298, y = 722, width = 29, height = 32, xadvance = 31, yoffset = 28, atlas = 0 },
								["98"] = { x = 332, y = 722, width = 33, height = 44, xadvance = 35, yoffset = 16, atlas = 0 },
								["99"] = { x = 370, y = 722, width = 27, height = 32, xadvance = 28, yoffset = 28, atlas = 0 },
								["100"] = { x = 402, y = 722, width = 32, height = 44, xadvance = 35, yoffset = 16, atlas = 0 },
								["101"] = { x = 439, y = 722, width = 31, height = 32, xadvance = 32, yoffset = 28, atlas = 0 },
								["102"] = { x = 475, y = 722, width = 26, height = 44, xadvance = 23, yoffset = 15, atlas = 0 },
								["103"] = { x = 506, y = 722, width = 34, height = 46, xadvance = 33, yoffset = 28, atlas = 0 },
								["104"] = { x = 545, y = 722, width = 32, height = 43, xadvance = 34, yoffset = 16, atlas = 0 },
								["105"] = { x = 582, y = 722, width = 15, height = 43, xadvance = 17, yoffset = 16, atlas = 0 },
								["106"] = { x = 602, y = 722, width = 14, height = 54, xadvance = 17, yoffset = 16, atlas = 0 },
								["107"] = { x = 621, y = 722, width = 33, height = 43, xadvance = 30, yoffset = 16, atlas = 0 },
								["108"] = { x = 659, y = 722, width = 18, height = 44, xadvance = 17, yoffset = 16, atlas = 0 },
								["109"] = { x = 682, y = 722, width = 49, height = 31, xadvance = 51, yoffset = 28, atlas = 0 },
								["110"] = { x = 736, y = 722, width = 32, height = 31, xadvance = 34, yoffset = 28, atlas = 0 },
								["111"] = { x = 773, y = 722, width = 32, height = 32, xadvance = 33, yoffset = 28, atlas = 0 },
								["112"] = { x = 810, y = 722, width = 33, height = 45, xadvance = 35, yoffset = 28, atlas = 0 },
								["113"] = { x = 848, y = 722, width = 32, height = 45, xadvance = 35, yoffset = 28, atlas = 0 },
								["114"] = { x = 885, y = 722, width = 22, height = 31, xadvance = 22, yoffset = 28, atlas = 0 },
								["115"] = { x = 912, y = 722, width = 25, height = 32, xadvance = 26, yoffset = 28, atlas = 0 },
								["116"] = { x = 942, y = 722, width = 21, height = 39, xadvance = 21, yoffset = 21, atlas = 0 },
								["117"] = { x = 968, y = 722, width = 31, height = 32, xadvance = 34, yoffset = 28, atlas = 0 },
								["118"] = { x = 0, y = 786, width = 33, height = 31, xadvance = 31, yoffset = 28, atlas = 0 },
								["119"] = { x = 38, y = 786, width = 47, height = 31, xadvance = 45, yoffset = 28, atlas = 0 },
								["120"] = { x = 90, y = 786, width = 32, height = 31, xadvance = 30, yoffset = 28, atlas = 0 },
								["121"] = { x = 127, y = 786, width = 33, height = 46, xadvance = 31, yoffset = 28, atlas = 0 },
								["122"] = { x = 165, y = 786, width = 28, height = 31, xadvance = 28, yoffset = 28, atlas = 0 },
								["123"] = { x = 198, y = 786, width = 23, height = 58, xadvance = 24, yoffset = 12, atlas = 0 },
								["124"] = { x = 226, y = 786, width = 15, height = 59, xadvance = 19, yoffset = 12, atlas = 0 },
								["125"] = { x = 246, y = 786, width = 23, height = 58, xadvance = 24, yoffset = 12, atlas = 0 },
								["126"] = { x = 274, y = 786, width = 29, height = 12, xadvance = 28, yoffset = 29, atlas = 0 }
							},
							kerning = {
							}
						},
						["48"] = {
							lineHeight = 48,
							firstAdjust = 9,
							characters = {
								["32"] = { x = 0, y = 850, width = 0, height = 0, xadvance = 11, yoffset = 48, atlas = 0 },
								["33"] = { x = 5, y = 850, width = 11, height = 37, xadvance = 14, yoffset = 12, atlas = 0 },
								["34"] = { x = 21, y = 850, width = 19, height = 16, xadvance = 20, yoffset = 12, atlas = 0 },
								["35"] = { x = 45, y = 850, width = 34, height = 35, xadvance = 35, yoffset = 14, atlas = 0 },
								["36"] = { x = 84, y = 850, width = 26, height = 45, xadvance = 27, yoffset = 9, atlas = 0 },
								["37"] = { x = 115, y = 850, width = 48, height = 39, xadvance = 49, yoffset = 13, atlas = 0 },
								["38"] = { x = 168, y = 850, width = 37, height = 38, xadvance = 36, yoffset = 12, atlas = 0 },
								["39"] = { x = 210, y = 850, width = 10, height = 16, xadvance = 11, yoffset = 12, atlas = 0 },
								["40"] = { x = 225, y = 850, width = 15, height = 48, xadvance = 15, yoffset = 9, atlas = 0 },
								["41"] = { x = 245, y = 850, width = 15, height = 48, xadvance = 15, yoffset = 9, atlas = 0 },
								["42"] = { x = 265, y = 850, width = 24, height = 22, xadvance = 24, yoffset = 12, atlas = 0 },
								["43"] = { x = 294, y = 850, width = 25, height = 24, xadvance = 28, yoffset = 19, atlas = 0 },
								["44"] = { x = 324, y = 850, width = 10, height = 14, xadvance = 10, yoffset = 41, atlas = 0 },
								["45"] = { x = 339, y = 850, width = 16, height = 7, xadvance = 17, yoffset = 31, atlas = 0 },
								["46"] = { x = 360, y = 850, width = 10, height = 8, xadvance = 12, yoffset = 41, atlas = 0 },
								["47"] = { x = 375, y = 850, width = 20, height = 37, xadvance = 19, yoffset = 12, atlas = 0 },
								["48"] = { x = 400, y = 850, width = 27, height = 32, xadvance = 28, yoffset = 17, atlas = 0 },
								["49"] = { x = 432, y = 850, width = 26, height = 31, xadvance = 28, yoffset = 17, atlas = 0 },
								["50"] = { x = 463, y = 850, width = 25, height = 31, xadvance = 28, yoffset = 17, atlas = 0 },
								["51"] = { x = 493, y = 850, width = 26, height = 34, xadvance = 28, yoffset = 17, atlas = 0 },
								["52"] = { x = 524, y = 850, width = 29, height = 35, xadvance = 28, yoffset = 16, atlas = 0 },
								["53"] = { x = 558, y = 850, width = 26, height = 34, xadvance = 28, yoffset = 17, atlas = 0 },
								["54"] = { x = 589, y = 850, width = 28, height = 36, xadvance = 28, yoffset = 13, atlas = 0 },
								["55"] = { x = 622, y = 850, width = 28, height = 35, xadvance = 28, yoffset = 17, atlas = 0 },
								["56"] = { x = 655, y = 850, width = 27, height = 35, xadvance = 28, yoffset = 14, atlas = 0 },
								["57"] = { x = 687, y = 850, width = 26, height = 36, xadvance = 28, yoffset = 16, atlas = 0 },
								["58"] = { x = 718, y = 850, width = 10, height = 27, xadvance = 12, yoffset = 22, atlas = 0 },
								["59"] = { x = 733, y = 850, width = 11, height = 33, xadvance = 13, yoffset = 22, atlas = 0 },
								["60"] = { x = 749, y = 850, width = 26, height = 25, xadvance = 28, yoffset = 19, atlas = 0 },
								["61"] = { x = 780, y = 850, width = 26, height = 15, xadvance = 29, yoffset = 23, atlas = 0 },
								["62"] = { x = 811, y = 850, width = 26, height = 25, xadvance = 28, yoffset = 19, atlas = 0 },
								["63"] = { x = 842, y = 850, width = 23, height = 37, xadvance = 23, yoffset = 12, atlas = 0 },
								["64"] = { x = 870, y = 850, width = 46, height = 45, xadvance = 47, yoffset = 11, atlas = 0 },
								["65"] = { x = 921, y = 850, width = 30, height = 34, xadvance = 29, yoffset = 14, atlas = 0 },
								["66"] = { x = 956, y = 850, width = 27, height = 36, xadvance = 28, yoffset = 13, atlas = 0 },
								["67"] = { x = 988, y = 850, width = 29, height = 36, xadvance = 29, yoffset = 13, atlas = 0 },
								["68"] = { x = 0, y = 903, width = 32, height = 36, xadvance = 33, yoffset = 13, atlas = 0 },
								["69"] = { x = 37, y = 903, width = 25, height = 34, xadvance = 25, yoffset = 14, atlas = 0 },
								["70"] = { x = 67, y = 903, width = 23, height = 34, xadvance = 24, yoffset = 14, atlas = 0 },
								["71"] = { x = 95, y = 903, width = 30, height = 36, xadvance = 32, yoffset = 13, atlas = 0 },
								["72"] = { x = 130, y = 903, width = 30, height = 34, xadvance = 32, yoffset = 14, atlas = 0 },
								["73"] = { x = 165, y = 903, width = 11, height = 34, xadvance = 13, yoffset = 14, atlas = 0 },
								["74"] = { x = 181, y = 903, width = 17, height = 35, xadvance = 19, yoffset = 14, atlas = 0 },
								["75"] = { x = 203, y = 903, width = 30, height = 34, xadvance = 28, yoffset = 14, atlas = 0 },
								["76"] = { x = 238, y = 903, width = 24, height = 34, xadvance = 23, yoffset = 14, atlas = 0 },
								["77"] = { x = 267, y = 903, width = 36, height = 34, xadvance = 38, yoffset = 14, atlas = 0 },
								["78"] = { x = 308, y = 903, width = 30, height = 34, xadvance = 32, yoffset = 14, atlas = 0 },
								["79"] = { x = 343, y = 903, width = 33, height = 36, xadvance = 35, yoffset = 13, atlas = 0 },
								["80"] = { x = 381, y = 903, width = 26, height = 35, xadvance = 27, yoffset = 13, atlas = 0 },
								["81"] = { x = 412, y = 903, width = 33, height = 43, xadvance = 34, yoffset = 13, atlas = 0 },
								["82"] = { x = 450, y = 903, width = 29, height = 35, xadvance = 28, yoffset = 13, atlas = 0 },
								["83"] = { x = 484, y = 903, width = 25, height = 36, xadvance = 26, yoffset = 13, atlas = 0 },
								["84"] = { x = 514, y = 903, width = 25, height = 34, xadvance = 25, yoffset = 14, atlas = 0 },
								["85"] = { x = 544, y = 903, width = 30, height = 35, xadvance = 32, yoffset = 14, atlas = 0 },
								["86"] = { x = 579, y = 903, width = 31, height = 34, xadvance = 29, yoffset = 14, atlas = 0 },
								["87"] = { x = 615, y = 903, width = 44, height = 34, xadvance = 43, yoffset = 14, atlas = 0 },
								["88"] = { x = 664, y = 903, width = 30, height = 34, xadvance = 29, yoffset = 14, atlas = 0 },
								["89"] = { x = 699, y = 903, width = 29, height = 34, xadvance = 27, yoffset = 14, atlas = 0 },
								["90"] = { x = 733, y = 903, width = 27, height = 34, xadvance = 26, yoffset = 14, atlas = 0 },
								["91"] = { x = 765, y = 903, width = 14, height = 47, xadvance = 15, yoffset = 10, atlas = 0 },
								["92"] = { x = 784, y = 903, width = 20, height = 37, xadvance = 19, yoffset = 12, atlas = 0 },
								["93"] = { x = 809, y = 903, width = 15, height = 47, xadvance = 15, yoffset = 10, atlas = 0 },
								["94"] = { x = 829, y = 903, width = 25, height = 20, xadvance = 26, yoffset = 12, atlas = 0 },
								["95"] = { x = 859, y = 903, width = 25, height = 7, xadvance = 24, yoffset = 46, atlas = 0 },
								["96"] = { x = 889, y = 903, width = 20, height = 9, xadvance = 23, yoffset = 12, atlas = 0 },
								["97"] = { x = 914, y = 903, width = 23, height = 26, xadvance = 24, yoffset = 23, atlas = 0 },
								["98"] = { x = 942, y = 903, width = 27, height = 36, xadvance = 28, yoffset = 13, atlas = 0 },
								["99"] = { x = 974, y = 903, width = 22, height = 26, xadvance = 23, yoffset = 23, atlas = 0 },
								["100"] = { x = 0, y = 956, width = 25, height = 36, xadvance = 28, yoffset = 13, atlas = 0 },
								["101"] = { x = 30, y = 956, width = 25, height = 26, xadvance = 26, yoffset = 23, atlas = 0 },
								["102"] = { x = 60, y = 956, width = 20, height = 35, xadvance = 18, yoffset = 13, atlas = 0 },
								["103"] = { x = 85, y = 956, width = 27, height = 36, xadvance = 26, yoffset = 23, atlas = 0 },
								["104"] = { x = 117, y = 956, width = 25, height = 35, xadvance = 27, yoffset = 13, atlas = 0 },
								["105"] = { x = 147, y = 956, width = 12, height = 35, xadvance = 14, yoffset = 13, atlas = 0 },
								["106"] = { x = 164, y = 956, width = 12, height = 44, xadvance = 14, yoffset = 13, atlas = 0 },
								["107"] = { x = 181, y = 956, width = 26, height = 35, xadvance = 24, yoffset = 13, atlas = 0 },
								["108"] = { x = 212, y = 956, width = 14, height = 36, xadvance = 13, yoffset = 13, atlas = 0 },
								["109"] = { x = 231, y = 956, width = 39, height = 25, xadvance = 40, yoffset = 23, atlas = 0 },
								["110"] = { x = 275, y = 956, width = 26, height = 25, xadvance = 27, yoffset = 23, atlas = 0 },
								["111"] = { x = 306, y = 956, width = 26, height = 26, xadvance = 27, yoffset = 23, atlas = 0 },
								["112"] = { x = 337, y = 956, width = 27, height = 36, xadvance = 28, yoffset = 23, atlas = 0 },
								["113"] = { x = 369, y = 956, width = 25, height = 36, xadvance = 28, yoffset = 23, atlas = 0 },
								["114"] = { x = 399, y = 956, width = 18, height = 25, xadvance = 18, yoffset = 23, atlas = 0 },
								["115"] = { x = 422, y = 956, width = 21, height = 26, xadvance = 22, yoffset = 23, atlas = 0 },
								["116"] = { x = 448, y = 956, width = 18, height = 32, xadvance = 17, yoffset = 17, atlas = 0 },
								["117"] = { x = 471, y = 956, width = 25, height = 26, xadvance = 27, yoffset = 23, atlas = 0 },
								["118"] = { x = 501, y = 956, width = 26, height = 25, xadvance = 25, yoffset = 23, atlas = 0 },
								["119"] = { x = 532, y = 956, width = 37, height = 25, xadvance = 36, yoffset = 23, atlas = 0 },
								["120"] = { x = 574, y = 956, width = 25, height = 25, xadvance = 24, yoffset = 23, atlas = 0 },
								["121"] = { x = 604, y = 956, width = 26, height = 36, xadvance = 25, yoffset = 23, atlas = 0 },
								["122"] = { x = 635, y = 956, width = 23, height = 25, xadvance = 23, yoffset = 23, atlas = 0 },
								["123"] = { x = 663, y = 956, width = 19, height = 47, xadvance = 20, yoffset = 10, atlas = 0 },
								["124"] = { x = 687, y = 956, width = 12, height = 48, xadvance = 16, yoffset = 9, atlas = 0 },
								["125"] = { x = 704, y = 956, width = 19, height = 47, xadvance = 20, yoffset = 10, atlas = 0 },
								["126"] = { x = 728, y = 956, width = 23, height = 10, xadvance = 22, yoffset = 24, atlas = 0 }
							},
							kerning = {
							}
						},
						["42"] = {
							lineHeight = 42,
							firstAdjust = 8,
							characters = {
								["32"] = { x = 0, y = 0, width = 0, height = 0, xadvance = 10, yoffset = 42, atlas = 1 },
								["33"] = { x = 5, y = 0, width = 9, height = 33, xadvance = 12, yoffset = 10, atlas = 1 },
								["34"] = { x = 19, y = 0, width = 17, height = 14, xadvance = 18, yoffset = 11, atlas = 1 },
								["35"] = { x = 41, y = 0, width = 30, height = 31, xadvance = 31, yoffset = 12, atlas = 1 },
								["36"] = { x = 76, y = 0, width = 23, height = 39, xadvance = 25, yoffset = 8, atlas = 1 },
								["37"] = { x = 104, y = 0, width = 43, height = 33, xadvance = 43, yoffset = 11, atlas = 1 },
								["38"] = { x = 152, y = 0, width = 32, height = 34, xadvance = 31, yoffset = 10, atlas = 1 },
								["39"] = { x = 189, y = 0, width = 9, height = 14, xadvance = 10, yoffset = 11, atlas = 1 },
								["40"] = { x = 203, y = 0, width = 13, height = 42, xadvance = 13, yoffset = 8, atlas = 1 },
								["41"] = { x = 221, y = 0, width = 13, height = 42, xadvance = 13, yoffset = 8, atlas = 1 },
								["42"] = { x = 239, y = 0, width = 21, height = 19, xadvance = 21, yoffset = 10, atlas = 1 },
								["43"] = { x = 265, y = 0, width = 22, height = 21, xadvance = 25, yoffset = 17, atlas = 1 },
								["44"] = { x = 292, y = 0, width = 9, height = 12, xadvance = 9, yoffset = 36, atlas = 1 },
								["45"] = { x = 306, y = 0, width = 14, height = 6, xadvance = 15, yoffset = 27, atlas = 1 },
								["46"] = { x = 325, y = 0, width = 8, height = 7, xadvance = 9, yoffset = 36, atlas = 1 },
								["47"] = { x = 338, y = 0, width = 17, height = 33, xadvance = 17, yoffset = 10, atlas = 1 },
								["48"] = { x = 360, y = 0, width = 24, height = 29, xadvance = 25, yoffset = 14, atlas = 1 },
								["49"] = { x = 389, y = 0, width = 22, height = 27, xadvance = 25, yoffset = 15, atlas = 1 },
								["50"] = { x = 416, y = 0, width = 22, height = 28, xadvance = 25, yoffset = 14, atlas = 1 },
								["51"] = { x = 443, y = 0, width = 23, height = 30, xadvance = 25, yoffset = 15, atlas = 1 },
								["52"] = { x = 471, y = 0, width = 25, height = 31, xadvance = 25, yoffset = 14, atlas = 1 },
								["53"] = { x = 501, y = 0, width = 22, height = 30, xadvance = 25, yoffset = 15, atlas = 1 },
								["54"] = { x = 528, y = 0, width = 24, height = 32, xadvance = 25, yoffset = 11, atlas = 1 },
								["55"] = { x = 557, y = 0, width = 24, height = 31, xadvance = 25, yoffset = 15, atlas = 1 },
								["56"] = { x = 586, y = 0, width = 24, height = 31, xadvance = 25, yoffset = 12, atlas = 1 },
								["57"] = { x = 615, y = 0, width = 23, height = 31, xadvance = 25, yoffset = 15, atlas = 1 },
								["58"] = { x = 643, y = 0, width = 8, height = 24, xadvance = 9, yoffset = 19, atlas = 1 },
								["59"] = { x = 656, y = 0, width = 9, height = 29, xadvance = 10, yoffset = 19, atlas = 1 },
								["60"] = { x = 670, y = 0, width = 23, height = 23, xadvance = 25, yoffset = 16, atlas = 1 },
								["61"] = { x = 698, y = 0, width = 22, height = 13, xadvance = 24, yoffset = 20, atlas = 1 },
								["62"] = { x = 725, y = 0, width = 22, height = 23, xadvance = 24, yoffset = 16, atlas = 1 },
								["63"] = { x = 752, y = 0, width = 20, height = 32, xadvance = 20, yoffset = 11, atlas = 1 },
								["64"] = { x = 777, y = 0, width = 41, height = 39, xadvance = 42, yoffset = 10, atlas = 1 },
								["65"] = { x = 823, y = 0, width = 26, height = 30, xadvance = 25, yoffset = 12, atlas = 1 },
								["66"] = { x = 854, y = 0, width = 24, height = 32, xadvance = 25, yoffset = 11, atlas = 1 },
								["67"] = { x = 883, y = 0, width = 25, height = 32, xadvance = 25, yoffset = 11, atlas = 1 },
								["68"] = { x = 913, y = 0, width = 28, height = 32, xadvance = 29, yoffset = 11, atlas = 1 },
								["69"] = { x = 946, y = 0, width = 22, height = 30, xadvance = 22, yoffset = 12, atlas = 1 },
								["70"] = { x = 973, y = 0, width = 21, height = 30, xadvance = 21, yoffset = 12, atlas = 1 },
								["71"] = { x = 0, y = 47, width = 26, height = 32, xadvance = 27, yoffset = 11, atlas = 1 },
								["72"] = { x = 31, y = 47, width = 26, height = 30, xadvance = 29, yoffset = 12, atlas = 1 },
								["73"] = { x = 62, y = 47, width = 10, height = 30, xadvance = 12, yoffset = 12, atlas = 1 },
								["74"] = { x = 77, y = 47, width = 15, height = 31, xadvance = 17, yoffset = 12, atlas = 1 },
								["75"] = { x = 97, y = 47, width = 27, height = 30, xadvance = 25, yoffset = 12, atlas = 1 },
								["76"] = { x = 129, y = 47, width = 21, height = 30, xadvance = 21, yoffset = 12, atlas = 1 },
								["77"] = { x = 155, y = 47, width = 32, height = 30, xadvance = 34, yoffset = 12, atlas = 1 },
								["78"] = { x = 192, y = 47, width = 26, height = 30, xadvance = 29, yoffset = 12, atlas = 1 },
								["79"] = { x = 223, y = 47, width = 28, height = 32, xadvance = 29, yoffset = 11, atlas = 1 },
								["80"] = { x = 256, y = 47, width = 23, height = 31, xadvance = 24, yoffset = 11, atlas = 1 },
								["81"] = { x = 284, y = 47, width = 28, height = 38, xadvance = 29, yoffset = 11, atlas = 1 },
								["82"] = { x = 317, y = 47, width = 27, height = 31, xadvance = 25, yoffset = 11, atlas = 1 },
								["83"] = { x = 349, y = 47, width = 22, height = 32, xadvance = 23, yoffset = 11, atlas = 1 },
								["84"] = { x = 376, y = 47, width = 22, height = 30, xadvance = 22, yoffset = 12, atlas = 1 },
								["85"] = { x = 403, y = 47, width = 25, height = 31, xadvance = 27, yoffset = 12, atlas = 1 },
								["86"] = { x = 433, y = 47, width = 27, height = 30, xadvance = 26, yoffset = 12, atlas = 1 },
								["87"] = { x = 465, y = 47, width = 38, height = 30, xadvance = 38, yoffset = 12, atlas = 1 },
								["88"] = { x = 508, y = 47, width = 26, height = 30, xadvance = 25, yoffset = 12, atlas = 1 },
								["89"] = { x = 539, y = 47, width = 26, height = 30, xadvance = 24, yoffset = 12, atlas = 1 },
								["90"] = { x = 570, y = 47, width = 25, height = 30, xadvance = 24, yoffset = 12, atlas = 1 },
								["91"] = { x = 600, y = 47, width = 12, height = 41, xadvance = 13, yoffset = 9, atlas = 1 },
								["92"] = { x = 617, y = 47, width = 17, height = 33, xadvance = 17, yoffset = 10, atlas = 1 },
								["93"] = { x = 639, y = 47, width = 13, height = 41, xadvance = 13, yoffset = 9, atlas = 1 },
								["94"] = { x = 657, y = 47, width = 22, height = 17, xadvance = 23, yoffset = 11, atlas = 1 },
								["95"] = { x = 684, y = 47, width = 22, height = 6, xadvance = 21, yoffset = 41, atlas = 1 },
								["96"] = { x = 711, y = 47, width = 18, height = 8, xadvance = 21, yoffset = 10, atlas = 1 },
								["97"] = { x = 734, y = 47, width = 20, height = 23, xadvance = 21, yoffset = 20, atlas = 1 },
								["98"] = { x = 759, y = 47, width = 23, height = 32, xadvance = 24, yoffset = 11, atlas = 1 },
								["99"] = { x = 787, y = 47, width = 19, height = 23, xadvance = 20, yoffset = 20, atlas = 1 },
								["100"] = { x = 811, y = 47, width = 22, height = 32, xadvance = 24, yoffset = 11, atlas = 1 },
								["101"] = { x = 838, y = 47, width = 22, height = 23, xadvance = 23, yoffset = 20, atlas = 1 },
								["102"] = { x = 865, y = 47, width = 18, height = 31, xadvance = 16, yoffset = 11, atlas = 1 },
								["103"] = { x = 888, y = 47, width = 24, height = 32, xadvance = 24, yoffset = 20, atlas = 1 },
								["104"] = { x = 917, y = 47, width = 22, height = 31, xadvance = 24, yoffset = 11, atlas = 1 },
								["105"] = { x = 944, y = 47, width = 10, height = 31, xadvance = 12, yoffset = 11, atlas = 1 },
								["106"] = { x = 959, y = 47, width = 11, height = 39, xadvance = 13, yoffset = 11, atlas = 1 },
								["107"] = { x = 975, y = 47, width = 23, height = 31, xadvance = 21, yoffset = 11, atlas = 1 },
								["108"] = { x = 1003, y = 47, width = 13, height = 32, xadvance = 12, yoffset = 11, atlas = 1 },
								["109"] = { x = 0, y = 94, width = 34, height = 22, xadvance = 36, yoffset = 20, atlas = 1 },
								["110"] = { x = 39, y = 94, width = 22, height = 22, xadvance = 24, yoffset = 20, atlas = 1 },
								["111"] = { x = 66, y = 94, width = 23, height = 23, xadvance = 24, yoffset = 20, atlas = 1 },
								["112"] = { x = 94, y = 94, width = 23, height = 32, xadvance = 24, yoffset = 20, atlas = 1 },
								["113"] = { x = 122, y = 94, width = 22, height = 32, xadvance = 24, yoffset = 20, atlas = 1 },
								["114"] = { x = 149, y = 94, width = 15, height = 22, xadvance = 15, yoffset = 20, atlas = 1 },
								["115"] = { x = 169, y = 94, width = 18, height = 23, xadvance = 18, yoffset = 20, atlas = 1 },
								["116"] = { x = 192, y = 94, width = 15, height = 28, xadvance = 15, yoffset = 15, atlas = 1 },
								["117"] = { x = 212, y = 94, width = 22, height = 23, xadvance = 23, yoffset = 20, atlas = 1 },
								["118"] = { x = 239, y = 94, width = 23, height = 22, xadvance = 22, yoffset = 20, atlas = 1 },
								["119"] = { x = 267, y = 94, width = 33, height = 22, xadvance = 32, yoffset = 20, atlas = 1 },
								["120"] = { x = 305, y = 94, width = 22, height = 22, xadvance = 21, yoffset = 20, atlas = 1 },
								["121"] = { x = 332, y = 94, width = 23, height = 32, xadvance = 22, yoffset = 20, atlas = 1 },
								["122"] = { x = 360, y = 94, width = 20, height = 22, xadvance = 19, yoffset = 20, atlas = 1 },
								["123"] = { x = 385, y = 94, width = 16, height = 41, xadvance = 17, yoffset = 9, atlas = 1 },
								["124"] = { x = 406, y = 94, width = 11, height = 42, xadvance = 14, yoffset = 8, atlas = 1 },
								["125"] = { x = 422, y = 94, width = 16, height = 41, xadvance = 17, yoffset = 9, atlas = 1 },
								["126"] = { x = 443, y = 94, width = 21, height = 9, xadvance = 20, yoffset = 21, atlas = 1 }
							},
							kerning = {
							}
						},
						["36"] = {
							lineHeight = 36,
							firstAdjust = 7,
							characters = {
								["32"] = { x = 0, y = 141, width = 0, height = 0, xadvance = 8, yoffset = 36, atlas = 1 },
								["33"] = { x = 5, y = 141, width = 8, height = 28, xadvance = 10, yoffset = 9, atlas = 1 },
								["34"] = { x = 18, y = 141, width = 13, height = 12, xadvance = 14, yoffset = 9, atlas = 1 },
								["35"] = { x = 36, y = 141, width = 25, height = 27, xadvance = 26, yoffset = 10, atlas = 1 },
								["36"] = { x = 66, y = 141, width = 19, height = 34, xadvance = 21, yoffset = 6, atlas = 1 },
								["37"] = { x = 90, y = 141, width = 37, height = 29, xadvance = 37, yoffset = 9, atlas = 1 },
								["38"] = { x = 132, y = 141, width = 28, height = 29, xadvance = 27, yoffset = 8, atlas = 1 },
								["39"] = { x = 165, y = 141, width = 7, height = 12, xadvance = 8, yoffset = 9, atlas = 1 },
								["40"] = { x = 177, y = 141, width = 12, height = 36, xadvance = 11, yoffset = 7, atlas = 1 },
								["41"] = { x = 194, y = 141, width = 11, height = 36, xadvance = 11, yoffset = 7, atlas = 1 },
								["42"] = { x = 210, y = 141, width = 17, height = 17, xadvance = 16, yoffset = 9, atlas = 1 },
								["43"] = { x = 232, y = 141, width = 19, height = 18, xadvance = 21, yoffset = 14, atlas = 1 },
								["44"] = { x = 256, y = 141, width = 8, height = 10, xadvance = 7, yoffset = 31, atlas = 1 },
								["45"] = { x = 269, y = 141, width = 12, height = 5, xadvance = 13, yoffset = 23, atlas = 1 },
								["46"] = { x = 286, y = 141, width = 7, height = 6, xadvance = 8, yoffset = 31, atlas = 1 },
								["47"] = { x = 298, y = 141, width = 15, height = 28, xadvance = 14, yoffset = 9, atlas = 1 },
								["48"] = { x = 318, y = 141, width = 21, height = 24, xadvance = 21, yoffset = 12, atlas = 1 },
								["49"] = { x = 344, y = 141, width = 20, height = 24, xadvance = 21, yoffset = 12, atlas = 1 },
								["50"] = { x = 369, y = 141, width = 19, height = 24, xadvance = 21, yoffset = 12, atlas = 1 },
								["51"] = { x = 393, y = 141, width = 19, height = 26, xadvance = 21, yoffset = 13, atlas = 1 },
								["52"] = { x = 417, y = 141, width = 22, height = 27, xadvance = 21, yoffset = 11, atlas = 1 },
								["53"] = { x = 444, y = 141, width = 19, height = 26, xadvance = 21, yoffset = 13, atlas = 1 },
								["54"] = { x = 468, y = 141, width = 20, height = 27, xadvance = 21, yoffset = 9, atlas = 1 },
								["55"] = { x = 493, y = 141, width = 20, height = 27, xadvance = 21, yoffset = 13, atlas = 1 },
								["56"] = { x = 518, y = 141, width = 20, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["57"] = { x = 543, y = 141, width = 20, height = 27, xadvance = 21, yoffset = 12, atlas = 1 },
								["58"] = { x = 568, y = 141, width = 7, height = 21, xadvance = 8, yoffset = 16, atlas = 1 },
								["59"] = { x = 580, y = 141, width = 8, height = 25, xadvance = 9, yoffset = 16, atlas = 1 },
								["60"] = { x = 593, y = 141, width = 19, height = 19, xadvance = 21, yoffset = 14, atlas = 1 },
								["61"] = { x = 617, y = 141, width = 19, height = 12, xadvance = 21, yoffset = 17, atlas = 1 },
								["62"] = { x = 641, y = 141, width = 19, height = 19, xadvance = 21, yoffset = 14, atlas = 1 },
								["63"] = { x = 665, y = 141, width = 17, height = 28, xadvance = 17, yoffset = 9, atlas = 1 },
								["64"] = { x = 687, y = 141, width = 35, height = 34, xadvance = 36, yoffset = 8, atlas = 1 },
								["65"] = { x = 727, y = 141, width = 23, height = 26, xadvance = 22, yoffset = 10, atlas = 1 },
								["66"] = { x = 755, y = 141, width = 20, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["67"] = { x = 780, y = 141, width = 21, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["68"] = { x = 806, y = 141, width = 23, height = 26, xadvance = 24, yoffset = 10, atlas = 1 },
								["69"] = { x = 834, y = 141, width = 18, height = 26, xadvance = 19, yoffset = 10, atlas = 1 },
								["70"] = { x = 857, y = 141, width = 17, height = 26, xadvance = 18, yoffset = 10, atlas = 1 },
								["71"] = { x = 879, y = 141, width = 22, height = 26, xadvance = 24, yoffset = 10, atlas = 1 },
								["72"] = { x = 906, y = 141, width = 22, height = 26, xadvance = 24, yoffset = 10, atlas = 1 },
								["73"] = { x = 933, y = 141, width = 8, height = 26, xadvance = 10, yoffset = 10, atlas = 1 },
								["74"] = { x = 946, y = 141, width = 13, height = 26, xadvance = 14, yoffset = 10, atlas = 1 },
								["75"] = { x = 964, y = 141, width = 23, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["76"] = { x = 992, y = 141, width = 18, height = 26, xadvance = 17, yoffset = 10, atlas = 1 },
								["77"] = { x = 0, y = 182, width = 26, height = 26, xadvance = 28, yoffset = 10, atlas = 1 },
								["78"] = { x = 31, y = 182, width = 22, height = 26, xadvance = 24, yoffset = 10, atlas = 1 },
								["79"] = { x = 58, y = 182, width = 24, height = 26, xadvance = 25, yoffset = 10, atlas = 1 },
								["80"] = { x = 87, y = 182, width = 19, height = 26, xadvance = 20, yoffset = 10, atlas = 1 },
								["81"] = { x = 111, y = 182, width = 24, height = 32, xadvance = 25, yoffset = 10, atlas = 1 },
								["82"] = { x = 140, y = 182, width = 22, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["83"] = { x = 167, y = 182, width = 18, height = 26, xadvance = 19, yoffset = 10, atlas = 1 },
								["84"] = { x = 190, y = 182, width = 19, height = 26, xadvance = 19, yoffset = 10, atlas = 1 },
								["85"] = { x = 214, y = 182, width = 22, height = 26, xadvance = 24, yoffset = 10, atlas = 1 },
								["86"] = { x = 241, y = 182, width = 23, height = 26, xadvance = 22, yoffset = 10, atlas = 1 },
								["87"] = { x = 269, y = 182, width = 33, height = 26, xadvance = 32, yoffset = 10, atlas = 1 },
								["88"] = { x = 307, y = 182, width = 23, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["89"] = { x = 335, y = 182, width = 22, height = 26, xadvance = 21, yoffset = 10, atlas = 1 },
								["90"] = { x = 362, y = 182, width = 20, height = 26, xadvance = 20, yoffset = 10, atlas = 1 },
								["91"] = { x = 387, y = 182, width = 11, height = 36, xadvance = 11, yoffset = 7, atlas = 1 },
								["92"] = { x = 403, y = 182, width = 15, height = 28, xadvance = 14, yoffset = 9, atlas = 1 },
								["93"] = { x = 423, y = 182, width = 11, height = 36, xadvance = 11, yoffset = 7, atlas = 1 },
								["94"] = { x = 439, y = 182, width = 19, height = 15, xadvance = 19, yoffset = 9, atlas = 1 },
								["95"] = { x = 463, y = 182, width = 18, height = 5, xadvance = 17, yoffset = 35, atlas = 1 },
								["96"] = { x = 486, y = 182, width = 15, height = 7, xadvance = 18, yoffset = 9, atlas = 1 },
								["97"] = { x = 506, y = 182, width = 17, height = 19, xadvance = 19, yoffset = 17, atlas = 1 },
								["98"] = { x = 528, y = 182, width = 20, height = 27, xadvance = 21, yoffset = 9, atlas = 1 },
								["99"] = { x = 553, y = 182, width = 17, height = 19, xadvance = 17, yoffset = 17, atlas = 1 },
								["100"] = { x = 575, y = 182, width = 19, height = 27, xadvance = 21, yoffset = 9, atlas = 1 },
								["101"] = { x = 599, y = 182, width = 19, height = 19, xadvance = 20, yoffset = 17, atlas = 1 },
								["102"] = { x = 623, y = 182, width = 16, height = 27, xadvance = 14, yoffset = 9, atlas = 1 },
								["103"] = { x = 644, y = 182, width = 21, height = 28, xadvance = 20, yoffset = 17, atlas = 1 },
								["104"] = { x = 670, y = 182, width = 19, height = 27, xadvance = 21, yoffset = 9, atlas = 1 },
								["105"] = { x = 694, y = 182, width = 8, height = 26, xadvance = 10, yoffset = 10, atlas = 1 },
								["106"] = { x = 707, y = 182, width = 9, height = 33, xadvance = 10, yoffset = 10, atlas = 1 },
								["107"] = { x = 721, y = 182, width = 20, height = 27, xadvance = 18, yoffset = 9, atlas = 1 },
								["108"] = { x = 746, y = 182, width = 11, height = 27, xadvance = 11, yoffset = 9, atlas = 1 },
								["109"] = { x = 762, y = 182, width = 29, height = 19, xadvance = 30, yoffset = 17, atlas = 1 },
								["110"] = { x = 796, y = 182, width = 19, height = 19, xadvance = 21, yoffset = 17, atlas = 1 },
								["111"] = { x = 820, y = 182, width = 20, height = 19, xadvance = 20, yoffset = 17, atlas = 1 },
								["112"] = { x = 845, y = 182, width = 20, height = 28, xadvance = 21, yoffset = 17, atlas = 1 },
								["113"] = { x = 870, y = 182, width = 19, height = 28, xadvance = 21, yoffset = 17, atlas = 1 },
								["114"] = { x = 894, y = 182, width = 14, height = 19, xadvance = 13, yoffset = 17, atlas = 1 },
								["115"] = { x = 913, y = 182, width = 15, height = 19, xadvance = 16, yoffset = 17, atlas = 1 },
								["116"] = { x = 933, y = 182, width = 13, height = 24, xadvance = 13, yoffset = 12, atlas = 1 },
								["117"] = { x = 951, y = 182, width = 19, height = 19, xadvance = 21, yoffset = 17, atlas = 1 },
								["118"] = { x = 975, y = 182, width = 20, height = 19, xadvance = 19, yoffset = 17, atlas = 1 },
								["119"] = { x = 0, y = 223, width = 28, height = 19, xadvance = 27, yoffset = 17, atlas = 1 },
								["120"] = { x = 33, y = 223, width = 19, height = 19, xadvance = 18, yoffset = 17, atlas = 1 },
								["121"] = { x = 57, y = 223, width = 20, height = 28, xadvance = 19, yoffset = 17, atlas = 1 },
								["122"] = { x = 82, y = 223, width = 17, height = 19, xadvance = 17, yoffset = 17, atlas = 1 },
								["123"] = { x = 104, y = 223, width = 14, height = 36, xadvance = 14, yoffset = 7, atlas = 1 },
								["124"] = { x = 123, y = 223, width = 9, height = 36, xadvance = 12, yoffset = 7, atlas = 1 },
								["125"] = { x = 137, y = 223, width = 14, height = 36, xadvance = 14, yoffset = 7, atlas = 1 },
								["126"] = { x = 156, y = 223, width = 18, height = 8, xadvance = 17, yoffset = 17, atlas = 1 }
							},
							kerning = {
							}
						},
						["32"] = {
							lineHeight = 32,
							firstAdjust = 6,
							characters = {
								["32"] = { x = 0, y = 264, width = 0, height = 0, xadvance = 7, yoffset = 32, atlas = 1 },
								["33"] = { x = 5, y = 264, width = 7, height = 25, xadvance = 9, yoffset = 8, atlas = 1 },
								["34"] = { x = 17, y = 264, width = 12, height = 11, xadvance = 13, yoffset = 8, atlas = 1 },
								["35"] = { x = 34, y = 264, width = 22, height = 24, xadvance = 23, yoffset = 9, atlas = 1 },
								["36"] = { x = 61, y = 264, width = 17, height = 31, xadvance = 18, yoffset = 5, atlas = 1 },
								["37"] = { x = 83, y = 264, width = 33, height = 27, xadvance = 34, yoffset = 8, atlas = 1 },
								["38"] = { x = 121, y = 264, width = 25, height = 26, xadvance = 24, yoffset = 7, atlas = 1 },
								["39"] = { x = 151, y = 264, width = 6, height = 11, xadvance = 7, yoffset = 8, atlas = 1 },
								["40"] = { x = 162, y = 264, width = 10, height = 32, xadvance = 10, yoffset = 6, atlas = 1 },
								["41"] = { x = 177, y = 264, width = 9, height = 32, xadvance = 10, yoffset = 6, atlas = 1 },
								["42"] = { x = 191, y = 264, width = 16, height = 15, xadvance = 16, yoffset = 8, atlas = 1 },
								["43"] = { x = 212, y = 264, width = 17, height = 17, xadvance = 19, yoffset = 12, atlas = 1 },
								["44"] = { x = 234, y = 264, width = 7, height = 9, xadvance = 7, yoffset = 28, atlas = 1 },
								["45"] = { x = 246, y = 264, width = 11, height = 5, xadvance = 12, yoffset = 20, atlas = 1 },
								["46"] = { x = 262, y = 264, width = 6, height = 5, xadvance = 7, yoffset = 28, atlas = 1 },
								["47"] = { x = 273, y = 264, width = 13, height = 25, xadvance = 13, yoffset = 8, atlas = 1 },
								["48"] = { x = 291, y = 264, width = 18, height = 22, xadvance = 19, yoffset = 10, atlas = 1 },
								["49"] = { x = 314, y = 264, width = 17, height = 21, xadvance = 19, yoffset = 11, atlas = 1 },
								["50"] = { x = 336, y = 264, width = 17, height = 21, xadvance = 19, yoffset = 11, atlas = 1 },
								["51"] = { x = 358, y = 264, width = 17, height = 24, xadvance = 19, yoffset = 10, atlas = 1 },
								["52"] = { x = 380, y = 264, width = 19, height = 24, xadvance = 19, yoffset = 10, atlas = 1 },
								["53"] = { x = 404, y = 264, width = 17, height = 24, xadvance = 19, yoffset = 10, atlas = 1 },
								["54"] = { x = 426, y = 264, width = 18, height = 24, xadvance = 19, yoffset = 8, atlas = 1 },
								["55"] = { x = 449, y = 264, width = 18, height = 24, xadvance = 19, yoffset = 11, atlas = 1 },
								["56"] = { x = 472, y = 264, width = 18, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["57"] = { x = 495, y = 264, width = 18, height = 24, xadvance = 19, yoffset = 11, atlas = 1 },
								["58"] = { x = 518, y = 264, width = 6, height = 18, xadvance = 7, yoffset = 15, atlas = 1 },
								["59"] = { x = 529, y = 264, width = 7, height = 22, xadvance = 8, yoffset = 15, atlas = 1 },
								["60"] = { x = 541, y = 264, width = 17, height = 18, xadvance = 19, yoffset = 12, atlas = 1 },
								["61"] = { x = 563, y = 264, width = 17, height = 11, xadvance = 19, yoffset = 15, atlas = 1 },
								["62"] = { x = 585, y = 264, width = 17, height = 18, xadvance = 19, yoffset = 12, atlas = 1 },
								["63"] = { x = 607, y = 264, width = 15, height = 24, xadvance = 16, yoffset = 8, atlas = 1 },
								["64"] = { x = 627, y = 264, width = 31, height = 31, xadvance = 32, yoffset = 7, atlas = 1 },
								["65"] = { x = 663, y = 264, width = 20, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["66"] = { x = 688, y = 264, width = 18, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["67"] = { x = 711, y = 264, width = 19, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["68"] = { x = 735, y = 264, width = 21, height = 23, xadvance = 22, yoffset = 9, atlas = 1 },
								["69"] = { x = 761, y = 264, width = 17, height = 23, xadvance = 17, yoffset = 9, atlas = 1 },
								["70"] = { x = 783, y = 264, width = 16, height = 23, xadvance = 16, yoffset = 9, atlas = 1 },
								["71"] = { x = 804, y = 264, width = 20, height = 23, xadvance = 21, yoffset = 9, atlas = 1 },
								["72"] = { x = 829, y = 264, width = 20, height = 23, xadvance = 22, yoffset = 9, atlas = 1 },
								["73"] = { x = 854, y = 264, width = 7, height = 23, xadvance = 9, yoffset = 9, atlas = 1 },
								["74"] = { x = 866, y = 264, width = 11, height = 23, xadvance = 13, yoffset = 9, atlas = 1 },
								["75"] = { x = 882, y = 264, width = 20, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["76"] = { x = 907, y = 264, width = 16, height = 23, xadvance = 16, yoffset = 9, atlas = 1 },
								["77"] = { x = 928, y = 264, width = 24, height = 23, xadvance = 26, yoffset = 9, atlas = 1 },
								["78"] = { x = 957, y = 264, width = 20, height = 23, xadvance = 22, yoffset = 9, atlas = 1 },
								["79"] = { x = 982, y = 264, width = 22, height = 23, xadvance = 23, yoffset = 9, atlas = 1 },
								["80"] = { x = 0, y = 301, width = 17, height = 23, xadvance = 18, yoffset = 9, atlas = 1 },
								["81"] = { x = 22, y = 301, width = 22, height = 28, xadvance = 23, yoffset = 9, atlas = 1 },
								["82"] = { x = 49, y = 301, width = 20, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["83"] = { x = 74, y = 301, width = 16, height = 23, xadvance = 17, yoffset = 9, atlas = 1 },
								["84"] = { x = 95, y = 301, width = 17, height = 23, xadvance = 17, yoffset = 9, atlas = 1 },
								["85"] = { x = 117, y = 301, width = 20, height = 23, xadvance = 22, yoffset = 9, atlas = 1 },
								["86"] = { x = 142, y = 301, width = 21, height = 23, xadvance = 20, yoffset = 9, atlas = 1 },
								["87"] = { x = 168, y = 301, width = 29, height = 23, xadvance = 29, yoffset = 9, atlas = 1 },
								["88"] = { x = 202, y = 301, width = 20, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["89"] = { x = 227, y = 301, width = 20, height = 23, xadvance = 19, yoffset = 9, atlas = 1 },
								["90"] = { x = 252, y = 301, width = 18, height = 23, xadvance = 18, yoffset = 9, atlas = 1 },
								["91"] = { x = 275, y = 301, width = 10, height = 32, xadvance = 10, yoffset = 6, atlas = 1 },
								["92"] = { x = 290, y = 301, width = 13, height = 25, xadvance = 13, yoffset = 8, atlas = 1 },
								["93"] = { x = 308, y = 301, width = 10, height = 32, xadvance = 11, yoffset = 6, atlas = 1 },
								["94"] = { x = 323, y = 301, width = 17, height = 13, xadvance = 17, yoffset = 8, atlas = 1 },
								["95"] = { x = 345, y = 301, width = 16, height = 5, xadvance = 15, yoffset = 31, atlas = 1 },
								["96"] = { x = 366, y = 301, width = 14, height = 6, xadvance = 16, yoffset = 8, atlas = 1 },
								["97"] = { x = 385, y = 301, width = 15, height = 17, xadvance = 16, yoffset = 15, atlas = 1 },
								["98"] = { x = 405, y = 301, width = 18, height = 24, xadvance = 19, yoffset = 8, atlas = 1 },
								["99"] = { x = 428, y = 301, width = 15, height = 17, xadvance = 15, yoffset = 15, atlas = 1 },
								["100"] = { x = 448, y = 301, width = 17, height = 24, xadvance = 19, yoffset = 8, atlas = 1 },
								["101"] = { x = 470, y = 301, width = 17, height = 17, xadvance = 18, yoffset = 15, atlas = 1 },
								["102"] = { x = 492, y = 301, width = 15, height = 24, xadvance = 13, yoffset = 8, atlas = 1 },
								["103"] = { x = 512, y = 301, width = 19, height = 25, xadvance = 18, yoffset = 15, atlas = 1 },
								["104"] = { x = 536, y = 301, width = 17, height = 24, xadvance = 18, yoffset = 8, atlas = 1 },
								["105"] = { x = 558, y = 301, width = 8, height = 23, xadvance = 10, yoffset = 9, atlas = 1 },
								["106"] = { x = 571, y = 301, width = 8, height = 29, xadvance = 10, yoffset = 9, atlas = 1 },
								["107"] = { x = 584, y = 301, width = 18, height = 24, xadvance = 17, yoffset = 8, atlas = 1 },
								["108"] = { x = 607, y = 301, width = 10, height = 24, xadvance = 10, yoffset = 8, atlas = 1 },
								["109"] = { x = 622, y = 301, width = 26, height = 17, xadvance = 27, yoffset = 15, atlas = 1 },
								["110"] = { x = 653, y = 301, width = 17, height = 17, xadvance = 18, yoffset = 15, atlas = 1 },
								["111"] = { x = 675, y = 301, width = 18, height = 17, xadvance = 19, yoffset = 15, atlas = 1 },
								["112"] = { x = 698, y = 301, width = 18, height = 25, xadvance = 19, yoffset = 15, atlas = 1 },
								["113"] = { x = 721, y = 301, width = 17, height = 25, xadvance = 19, yoffset = 15, atlas = 1 },
								["114"] = { x = 743, y = 301, width = 12, height = 17, xadvance = 12, yoffset = 15, atlas = 1 },
								["115"] = { x = 760, y = 301, width = 14, height = 17, xadvance = 14, yoffset = 15, atlas = 1 },
								["116"] = { x = 779, y = 301, width = 11, height = 21, xadvance = 11, yoffset = 11, atlas = 1 },
								["117"] = { x = 795, y = 301, width = 17, height = 17, xadvance = 19, yoffset = 15, atlas = 1 },
								["118"] = { x = 817, y = 301, width = 18, height = 17, xadvance = 17, yoffset = 15, atlas = 1 },
								["119"] = { x = 840, y = 301, width = 25, height = 17, xadvance = 24, yoffset = 15, atlas = 1 },
								["120"] = { x = 870, y = 301, width = 17, height = 17, xadvance = 16, yoffset = 15, atlas = 1 },
								["121"] = { x = 892, y = 301, width = 17, height = 25, xadvance = 17, yoffset = 15, atlas = 1 },
								["122"] = { x = 914, y = 301, width = 16, height = 17, xadvance = 15, yoffset = 15, atlas = 1 },
								["123"] = { x = 935, y = 301, width = 12, height = 32, xadvance = 13, yoffset = 6, atlas = 1 },
								["124"] = { x = 952, y = 301, width = 8, height = 32, xadvance = 11, yoffset = 6, atlas = 1 },
								["125"] = { x = 965, y = 301, width = 12, height = 32, xadvance = 12, yoffset = 6, atlas = 1 },
								["126"] = { x = 982, y = 301, width = 16, height = 7, xadvance = 15, yoffset = 16, atlas = 1 }
							},
							kerning = {
							}
						},
						["28"] = {
							lineHeight = 27,
							firstAdjust = 5,
							characters = {
								["32"] = { x = 0, y = 338, width = 0, height = 0, xadvance = 6, yoffset = 27, atlas = 1 },
								["33"] = { x = 5, y = 338, width = 7, height = 20, xadvance = 8, yoffset = 7, atlas = 1 },
								["34"] = { x = 17, y = 338, width = 11, height = 9, xadvance = 11, yoffset = 7, atlas = 1 },
								["35"] = { x = 33, y = 338, width = 19, height = 20, xadvance = 20, yoffset = 8, atlas = 1 },
								["36"] = { x = 57, y = 338, width = 16, height = 25, xadvance = 16, yoffset = 5, atlas = 1 },
								["37"] = { x = 78, y = 338, width = 29, height = 20, xadvance = 30, yoffset = 7, atlas = 1 },
								["38"] = { x = 112, y = 338, width = 22, height = 21, xadvance = 21, yoffset = 7, atlas = 1 },
								["39"] = { x = 139, y = 338, width = 6, height = 9, xadvance = 6, yoffset = 7, atlas = 1 },
								["40"] = { x = 150, y = 338, width = 9, height = 27, xadvance = 9, yoffset = 5, atlas = 1 },
								["41"] = { x = 164, y = 338, width = 9, height = 27, xadvance = 9, yoffset = 5, atlas = 1 },
								["42"] = { x = 178, y = 338, width = 13, height = 12, xadvance = 13, yoffset = 7, atlas = 1 },
								["43"] = { x = 196, y = 338, width = 15, height = 14, xadvance = 17, yoffset = 10, atlas = 1 },
								["44"] = { x = 216, y = 338, width = 6, height = 8, xadvance = 6, yoffset = 23, atlas = 1 },
								["45"] = { x = 227, y = 338, width = 10, height = 4, xadvance = 11, yoffset = 17, atlas = 1 },
								["46"] = { x = 242, y = 338, width = 6, height = 4, xadvance = 6, yoffset = 23, atlas = 1 },
								["47"] = { x = 253, y = 338, width = 12, height = 20, xadvance = 11, yoffset = 7, atlas = 1 },
								["48"] = { x = 270, y = 338, width = 17, height = 18, xadvance = 16, yoffset = 9, atlas = 1 },
								["49"] = { x = 292, y = 338, width = 15, height = 18, xadvance = 16, yoffset = 9, atlas = 1 },
								["50"] = { x = 312, y = 338, width = 15, height = 18, xadvance = 16, yoffset = 9, atlas = 1 },
								["51"] = { x = 332, y = 338, width = 15, height = 19, xadvance = 16, yoffset = 10, atlas = 1 },
								["52"] = { x = 352, y = 338, width = 17, height = 20, xadvance = 16, yoffset = 9, atlas = 1 },
								["53"] = { x = 374, y = 338, width = 15, height = 19, xadvance = 16, yoffset = 10, atlas = 1 },
								["54"] = { x = 394, y = 338, width = 16, height = 20, xadvance = 16, yoffset = 7, atlas = 1 },
								["55"] = { x = 415, y = 338, width = 16, height = 20, xadvance = 16, yoffset = 10, atlas = 1 },
								["56"] = { x = 436, y = 338, width = 16, height = 19, xadvance = 16, yoffset = 8, atlas = 1 },
								["57"] = { x = 457, y = 338, width = 16, height = 20, xadvance = 16, yoffset = 9, atlas = 1 },
								["58"] = { x = 478, y = 338, width = 6, height = 14, xadvance = 6, yoffset = 13, atlas = 1 },
								["59"] = { x = 489, y = 338, width = 6, height = 18, xadvance = 6, yoffset = 13, atlas = 1 },
								["60"] = { x = 500, y = 338, width = 15, height = 15, xadvance = 17, yoffset = 10, atlas = 1 },
								["61"] = { x = 520, y = 338, width = 15, height = 9, xadvance = 17, yoffset = 13, atlas = 1 },
								["62"] = { x = 540, y = 338, width = 15, height = 15, xadvance = 17, yoffset = 10, atlas = 1 },
								["63"] = { x = 560, y = 338, width = 13, height = 20, xadvance = 14, yoffset = 7, atlas = 1 },
								["64"] = { x = 578, y = 338, width = 28, height = 25, xadvance = 28, yoffset = 7, atlas = 1 },
								["65"] = { x = 611, y = 338, width = 18, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["66"] = { x = 634, y = 338, width = 16, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["67"] = { x = 655, y = 338, width = 17, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["68"] = { x = 677, y = 338, width = 19, height = 19, xadvance = 19, yoffset = 8, atlas = 1 },
								["69"] = { x = 701, y = 338, width = 15, height = 19, xadvance = 15, yoffset = 8, atlas = 1 },
								["70"] = { x = 721, y = 338, width = 14, height = 19, xadvance = 15, yoffset = 8, atlas = 1 },
								["71"] = { x = 740, y = 338, width = 18, height = 19, xadvance = 19, yoffset = 8, atlas = 1 },
								["72"] = { x = 763, y = 338, width = 18, height = 19, xadvance = 19, yoffset = 8, atlas = 1 },
								["73"] = { x = 786, y = 338, width = 7, height = 19, xadvance = 8, yoffset = 8, atlas = 1 },
								["74"] = { x = 798, y = 338, width = 11, height = 19, xadvance = 12, yoffset = 8, atlas = 1 },
								["75"] = { x = 814, y = 338, width = 18, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["76"] = { x = 837, y = 338, width = 14, height = 19, xadvance = 14, yoffset = 8, atlas = 1 },
								["77"] = { x = 856, y = 338, width = 21, height = 19, xadvance = 23, yoffset = 8, atlas = 1 },
								["78"] = { x = 882, y = 338, width = 18, height = 19, xadvance = 19, yoffset = 8, atlas = 1 },
								["79"] = { x = 905, y = 338, width = 19, height = 19, xadvance = 20, yoffset = 8, atlas = 1 },
								["80"] = { x = 929, y = 338, width = 16, height = 19, xadvance = 16, yoffset = 8, atlas = 1 },
								["81"] = { x = 950, y = 338, width = 19, height = 23, xadvance = 20, yoffset = 8, atlas = 1 },
								["82"] = { x = 974, y = 338, width = 18, height = 19, xadvance = 16, yoffset = 8, atlas = 1 },
								["83"] = { x = 997, y = 338, width = 15, height = 19, xadvance = 15, yoffset = 8, atlas = 1 },
								["84"] = { x = 0, y = 370, width = 15, height = 19, xadvance = 15, yoffset = 8, atlas = 1 },
								["85"] = { x = 20, y = 370, width = 18, height = 19, xadvance = 19, yoffset = 8, atlas = 1 },
								["86"] = { x = 43, y = 370, width = 18, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["87"] = { x = 66, y = 370, width = 26, height = 19, xadvance = 25, yoffset = 8, atlas = 1 },
								["88"] = { x = 97, y = 370, width = 18, height = 19, xadvance = 17, yoffset = 8, atlas = 1 },
								["89"] = { x = 120, y = 370, width = 17, height = 19, xadvance = 16, yoffset = 8, atlas = 1 },
								["90"] = { x = 142, y = 370, width = 16, height = 19, xadvance = 16, yoffset = 8, atlas = 1 },
								["91"] = { x = 163, y = 370, width = 9, height = 26, xadvance = 9, yoffset = 6, atlas = 1 },
								["92"] = { x = 177, y = 370, width = 12, height = 20, xadvance = 11, yoffset = 7, atlas = 1 },
								["93"] = { x = 194, y = 370, width = 9, height = 26, xadvance = 9, yoffset = 6, atlas = 1 },
								["94"] = { x = 208, y = 370, width = 15, height = 11, xadvance = 15, yoffset = 7, atlas = 1 },
								["95"] = { x = 228, y = 370, width = 14, height = 4, xadvance = 13, yoffset = 26, atlas = 1 },
								["96"] = { x = 247, y = 370, width = 12, height = 5, xadvance = 14, yoffset = 7, atlas = 1 },
								["97"] = { x = 264, y = 370, width = 14, height = 14, xadvance = 14, yoffset = 13, atlas = 1 },
								["98"] = { x = 283, y = 370, width = 15, height = 20, xadvance = 16, yoffset = 7, atlas = 1 },
								["99"] = { x = 303, y = 370, width = 13, height = 14, xadvance = 14, yoffset = 13, atlas = 1 },
								["100"] = { x = 321, y = 370, width = 15, height = 20, xadvance = 16, yoffset = 7, atlas = 1 },
								["101"] = { x = 341, y = 370, width = 15, height = 14, xadvance = 16, yoffset = 13, atlas = 1 },
								["102"] = { x = 361, y = 370, width = 12, height = 20, xadvance = 11, yoffset = 7, atlas = 1 },
								["103"] = { x = 378, y = 370, width = 16, height = 20, xadvance = 16, yoffset = 13, atlas = 1 },
								["104"] = { x = 399, y = 370, width = 15, height = 20, xadvance = 15, yoffset = 7, atlas = 1 },
								["105"] = { x = 419, y = 370, width = 7, height = 19, xadvance = 9, yoffset = 8, atlas = 1 },
								["106"] = { x = 431, y = 370, width = 7, height = 24, xadvance = 8, yoffset = 8, atlas = 1 },
								["107"] = { x = 443, y = 370, width = 15, height = 20, xadvance = 14, yoffset = 7, atlas = 1 },
								["108"] = { x = 463, y = 370, width = 8, height = 20, xadvance = 8, yoffset = 7, atlas = 1 },
								["109"] = { x = 476, y = 370, width = 22, height = 14, xadvance = 22, yoffset = 13, atlas = 1 },
								["110"] = { x = 503, y = 370, width = 15, height = 14, xadvance = 15, yoffset = 13, atlas = 1 },
								["111"] = { x = 523, y = 370, width = 16, height = 14, xadvance = 16, yoffset = 13, atlas = 1 },
								["112"] = { x = 544, y = 370, width = 15, height = 20, xadvance = 16, yoffset = 13, atlas = 1 },
								["113"] = { x = 564, y = 370, width = 15, height = 20, xadvance = 16, yoffset = 13, atlas = 1 },
								["114"] = { x = 584, y = 370, width = 10, height = 14, xadvance = 10, yoffset = 13, atlas = 1 },
								["115"] = { x = 599, y = 370, width = 12, height = 14, xadvance = 13, yoffset = 13, atlas = 1 },
								["116"] = { x = 616, y = 370, width = 10, height = 18, xadvance = 10, yoffset = 9, atlas = 1 },
								["117"] = { x = 631, y = 370, width = 14, height = 14, xadvance = 15, yoffset = 13, atlas = 1 },
								["118"] = { x = 650, y = 370, width = 16, height = 14, xadvance = 15, yoffset = 13, atlas = 1 },
								["119"] = { x = 671, y = 370, width = 22, height = 14, xadvance = 21, yoffset = 13, atlas = 1 },
								["120"] = { x = 698, y = 370, width = 15, height = 14, xadvance = 14, yoffset = 13, atlas = 1 },
								["121"] = { x = 718, y = 370, width = 15, height = 20, xadvance = 14, yoffset = 13, atlas = 1 },
								["122"] = { x = 738, y = 370, width = 13, height = 14, xadvance = 13, yoffset = 13, atlas = 1 },
								["123"] = { x = 756, y = 370, width = 10, height = 26, xadvance = 11, yoffset = 6, atlas = 1 },
								["124"] = { x = 771, y = 370, width = 8, height = 27, xadvance = 10, yoffset = 5, atlas = 1 },
								["125"] = { x = 784, y = 370, width = 11, height = 26, xadvance = 12, yoffset = 6, atlas = 1 },
								["126"] = { x = 800, y = 370, width = 14, height = 6, xadvance = 13, yoffset = 13, atlas = 1 }
							},
							kerning = {
							}
						},
						["24"] = {
							lineHeight = 23,
							firstAdjust = 4,
							characters = {
								["32"] = { x = 0, y = 402, width = 0, height = 0, xadvance = 6, yoffset = 23, atlas = 1 },
								["33"] = { x = 5, y = 402, width = 6, height = 17, xadvance = 7, yoffset = 6, atlas = 1 },
								["34"] = { x = 16, y = 402, width = 9, height = 8, xadvance = 10, yoffset = 6, atlas = 1 },
								["35"] = { x = 30, y = 402, width = 17, height = 17, xadvance = 18, yoffset = 7, atlas = 1 },
								["36"] = { x = 52, y = 402, width = 13, height = 22, xadvance = 14, yoffset = 4, atlas = 1 },
								["37"] = { x = 70, y = 402, width = 25, height = 17, xadvance = 25, yoffset = 6, atlas = 1 },
								["38"] = { x = 100, y = 402, width = 19, height = 18, xadvance = 18, yoffset = 6, atlas = 1 },
								["39"] = { x = 124, y = 402, width = 5, height = 8, xadvance = 6, yoffset = 6, atlas = 1 },
								["40"] = { x = 134, y = 402, width = 8, height = 23, xadvance = 8, yoffset = 4, atlas = 1 },
								["41"] = { x = 147, y = 402, width = 7, height = 23, xadvance = 7, yoffset = 4, atlas = 1 },
								["42"] = { x = 159, y = 402, width = 11, height = 10, xadvance = 11, yoffset = 6, atlas = 1 },
								["43"] = { x = 175, y = 402, width = 12, height = 12, xadvance = 13, yoffset = 9, atlas = 1 },
								["44"] = { x = 192, y = 402, width = 5, height = 7, xadvance = 5, yoffset = 19, atlas = 1 },
								["45"] = { x = 202, y = 402, width = 8, height = 3, xadvance = 9, yoffset = 15, atlas = 1 },
								["46"] = { x = 215, y = 402, width = 5, height = 4, xadvance = 5, yoffset = 19, atlas = 1 },
								["47"] = { x = 225, y = 402, width = 10, height = 17, xadvance = 10, yoffset = 6, atlas = 1 },
								["48"] = { x = 240, y = 402, width = 14, height = 15, xadvance = 14, yoffset = 8, atlas = 1 },
								["49"] = { x = 259, y = 402, width = 13, height = 15, xadvance = 14, yoffset = 8, atlas = 1 },
								["50"] = { x = 277, y = 402, width = 13, height = 15, xadvance = 14, yoffset = 8, atlas = 1 },
								["51"] = { x = 295, y = 402, width = 13, height = 16, xadvance = 14, yoffset = 9, atlas = 1 },
								["52"] = { x = 313, y = 402, width = 14, height = 17, xadvance = 14, yoffset = 7, atlas = 1 },
								["53"] = { x = 332, y = 402, width = 12, height = 16, xadvance = 14, yoffset = 9, atlas = 1 },
								["54"] = { x = 349, y = 402, width = 14, height = 17, xadvance = 14, yoffset = 6, atlas = 1 },
								["55"] = { x = 368, y = 402, width = 14, height = 17, xadvance = 14, yoffset = 8, atlas = 1 },
								["56"] = { x = 387, y = 402, width = 14, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["57"] = { x = 406, y = 402, width = 14, height = 17, xadvance = 14, yoffset = 8, atlas = 1 },
								["58"] = { x = 425, y = 402, width = 5, height = 12, xadvance = 5, yoffset = 11, atlas = 1 },
								["59"] = { x = 435, y = 402, width = 5, height = 16, xadvance = 5, yoffset = 11, atlas = 1 },
								["60"] = { x = 445, y = 402, width = 12, height = 12, xadvance = 13, yoffset = 9, atlas = 1 },
								["61"] = { x = 462, y = 402, width = 12, height = 7, xadvance = 13, yoffset = 11, atlas = 1 },
								["62"] = { x = 479, y = 402, width = 12, height = 13, xadvance = 13, yoffset = 9, atlas = 1 },
								["63"] = { x = 496, y = 402, width = 11, height = 17, xadvance = 11, yoffset = 6, atlas = 1 },
								["64"] = { x = 512, y = 402, width = 24, height = 21, xadvance = 24, yoffset = 6, atlas = 1 },
								["65"] = { x = 541, y = 402, width = 15, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["66"] = { x = 561, y = 402, width = 13, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["67"] = { x = 579, y = 402, width = 15, height = 16, xadvance = 15, yoffset = 7, atlas = 1 },
								["68"] = { x = 599, y = 402, width = 15, height = 16, xadvance = 16, yoffset = 7, atlas = 1 },
								["69"] = { x = 619, y = 402, width = 12, height = 16, xadvance = 12, yoffset = 7, atlas = 1 },
								["70"] = { x = 636, y = 402, width = 12, height = 16, xadvance = 11, yoffset = 7, atlas = 1 },
								["71"] = { x = 653, y = 402, width = 15, height = 16, xadvance = 16, yoffset = 7, atlas = 1 },
								["72"] = { x = 673, y = 402, width = 14, height = 16, xadvance = 15, yoffset = 7, atlas = 1 },
								["73"] = { x = 692, y = 402, width = 5, height = 16, xadvance = 6, yoffset = 7, atlas = 1 },
								["74"] = { x = 702, y = 402, width = 9, height = 16, xadvance = 10, yoffset = 7, atlas = 1 },
								["75"] = { x = 716, y = 402, width = 15, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["76"] = { x = 736, y = 402, width = 11, height = 16, xadvance = 11, yoffset = 7, atlas = 1 },
								["77"] = { x = 752, y = 402, width = 18, height = 16, xadvance = 20, yoffset = 7, atlas = 1 },
								["78"] = { x = 775, y = 402, width = 14, height = 16, xadvance = 15, yoffset = 7, atlas = 1 },
								["79"] = { x = 794, y = 402, width = 17, height = 16, xadvance = 17, yoffset = 7, atlas = 1 },
								["80"] = { x = 816, y = 402, width = 13, height = 16, xadvance = 13, yoffset = 7, atlas = 1 },
								["81"] = { x = 834, y = 402, width = 17, height = 20, xadvance = 18, yoffset = 7, atlas = 1 },
								["82"] = { x = 856, y = 402, width = 15, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["83"] = { x = 876, y = 402, width = 13, height = 16, xadvance = 13, yoffset = 7, atlas = 1 },
								["84"] = { x = 894, y = 402, width = 13, height = 16, xadvance = 13, yoffset = 7, atlas = 1 },
								["85"] = { x = 912, y = 402, width = 14, height = 16, xadvance = 15, yoffset = 7, atlas = 1 },
								["86"] = { x = 931, y = 402, width = 16, height = 16, xadvance = 15, yoffset = 7, atlas = 1 },
								["87"] = { x = 952, y = 402, width = 22, height = 16, xadvance = 22, yoffset = 7, atlas = 1 },
								["88"] = { x = 979, y = 402, width = 15, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["89"] = { x = 999, y = 402, width = 15, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["90"] = { x = 0, y = 430, width = 14, height = 16, xadvance = 14, yoffset = 7, atlas = 1 },
								["91"] = { x = 19, y = 430, width = 8, height = 22, xadvance = 8, yoffset = 5, atlas = 1 },
								["92"] = { x = 32, y = 430, width = 10, height = 17, xadvance = 10, yoffset = 6, atlas = 1 },
								["93"] = { x = 47, y = 430, width = 8, height = 22, xadvance = 8, yoffset = 5, atlas = 1 },
								["94"] = { x = 60, y = 430, width = 13, height = 10, xadvance = 13, yoffset = 6, atlas = 1 },
								["95"] = { x = 78, y = 430, width = 13, height = 3, xadvance = 13, yoffset = 23, atlas = 1 },
								["96"] = { x = 96, y = 430, width = 10, height = 4, xadvance = 12, yoffset = 6, atlas = 1 },
								["97"] = { x = 111, y = 430, width = 12, height = 12, xadvance = 13, yoffset = 11, atlas = 1 },
								["98"] = { x = 128, y = 430, width = 13, height = 17, xadvance = 14, yoffset = 6, atlas = 1 },
								["99"] = { x = 146, y = 430, width = 11, height = 12, xadvance = 12, yoffset = 11, atlas = 1 },
								["100"] = { x = 162, y = 430, width = 13, height = 17, xadvance = 14, yoffset = 6, atlas = 1 },
								["101"] = { x = 180, y = 430, width = 13, height = 12, xadvance = 14, yoffset = 11, atlas = 1 },
								["102"] = { x = 198, y = 430, width = 11, height = 17, xadvance = 10, yoffset = 6, atlas = 1 },
								["103"] = { x = 214, y = 430, width = 14, height = 17, xadvance = 14, yoffset = 11, atlas = 1 },
								["104"] = { x = 233, y = 430, width = 13, height = 17, xadvance = 14, yoffset = 6, atlas = 1 },
								["105"] = { x = 251, y = 430, width = 5, height = 16, xadvance = 6, yoffset = 7, atlas = 1 },
								["106"] = { x = 261, y = 430, width = 6, height = 20, xadvance = 7, yoffset = 7, atlas = 1 },
								["107"] = { x = 272, y = 430, width = 13, height = 17, xadvance = 12, yoffset = 6, atlas = 1 },
								["108"] = { x = 290, y = 430, width = 7, height = 17, xadvance = 7, yoffset = 6, atlas = 1 },
								["109"] = { x = 302, y = 430, width = 19, height = 12, xadvance = 20, yoffset = 11, atlas = 1 },
								["110"] = { x = 326, y = 430, width = 12, height = 12, xadvance = 13, yoffset = 11, atlas = 1 },
								["111"] = { x = 343, y = 430, width = 14, height = 12, xadvance = 14, yoffset = 11, atlas = 1 },
								["112"] = { x = 362, y = 430, width = 13, height = 17, xadvance = 14, yoffset = 11, atlas = 1 },
								["113"] = { x = 380, y = 430, width = 13, height = 17, xadvance = 14, yoffset = 11, atlas = 1 },
								["114"] = { x = 398, y = 430, width = 9, height = 12, xadvance = 9, yoffset = 11, atlas = 1 },
								["115"] = { x = 412, y = 430, width = 11, height = 12, xadvance = 11, yoffset = 11, atlas = 1 },
								["116"] = { x = 428, y = 430, width = 9, height = 15, xadvance = 9, yoffset = 8, atlas = 1 },
								["117"] = { x = 442, y = 430, width = 12, height = 12, xadvance = 13, yoffset = 11, atlas = 1 },
								["118"] = { x = 459, y = 430, width = 13, height = 12, xadvance = 12, yoffset = 11, atlas = 1 },
								["119"] = { x = 477, y = 430, width = 19, height = 12, xadvance = 18, yoffset = 11, atlas = 1 },
								["120"] = { x = 501, y = 430, width = 13, height = 12, xadvance = 12, yoffset = 11, atlas = 1 },
								["121"] = { x = 519, y = 430, width = 13, height = 17, xadvance = 12, yoffset = 11, atlas = 1 },
								["122"] = { x = 537, y = 430, width = 12, height = 12, xadvance = 12, yoffset = 11, atlas = 1 },
								["123"] = { x = 554, y = 430, width = 9, height = 22, xadvance = 10, yoffset = 5, atlas = 1 },
								["124"] = { x = 568, y = 430, width = 6, height = 23, xadvance = 8, yoffset = 4, atlas = 1 },
								["125"] = { x = 579, y = 430, width = 9, height = 22, xadvance = 10, yoffset = 5, atlas = 1 },
								["126"] = { x = 593, y = 430, width = 12, height = 6, xadvance = 11, yoffset = 11, atlas = 1 }
							},
							kerning = {
							}
						},
						["18"] = {
							lineHeight = 17,
							firstAdjust = 3,
							characters = {
								["32"] = { x = 0, y = 458, width = 0, height = 0, xadvance = 4, yoffset = 17, atlas = 1 },
								["33"] = { x = 5, y = 458, width = 4, height = 13, xadvance = 5, yoffset = 4, atlas = 1 },
								["34"] = { x = 14, y = 458, width = 7, height = 6, xadvance = 8, yoffset = 4, atlas = 1 },
								["35"] = { x = 26, y = 458, width = 13, height = 13, xadvance = 14, yoffset = 5, atlas = 1 },
								["36"] = { x = 44, y = 458, width = 10, height = 16, xadvance = 11, yoffset = 3, atlas = 1 },
								["37"] = { x = 59, y = 458, width = 19, height = 13, xadvance = 19, yoffset = 4, atlas = 1 },
								["38"] = { x = 83, y = 458, width = 14, height = 14, xadvance = 14, yoffset = 4, atlas = 1 },
								["39"] = { x = 102, y = 458, width = 4, height = 6, xadvance = 4, yoffset = 4, atlas = 1 },
								["40"] = { x = 111, y = 458, width = 7, height = 17, xadvance = 6, yoffset = 3, atlas = 1 },
								["41"] = { x = 123, y = 458, width = 6, height = 17, xadvance = 6, yoffset = 3, atlas = 1 },
								["42"] = { x = 134, y = 458, width = 9, height = 8, xadvance = 8, yoffset = 4, atlas = 1 },
								["43"] = { x = 148, y = 458, width = 9, height = 9, xadvance = 10, yoffset = 6, atlas = 1 },
								["44"] = { x = 162, y = 458, width = 4, height = 5, xadvance = 4, yoffset = 14, atlas = 1 },
								["45"] = { x = 171, y = 458, width = 7, height = 3, xadvance = 8, yoffset = 10, atlas = 1 },
								["46"] = { x = 183, y = 458, width = 4, height = 3, xadvance = 4, yoffset = 14, atlas = 1 },
								["47"] = { x = 192, y = 458, width = 8, height = 13, xadvance = 7, yoffset = 4, atlas = 1 },
								["48"] = { x = 205, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["49"] = { x = 221, y = 458, width = 10, height = 11, xadvance = 11, yoffset = 6, atlas = 1 },
								["50"] = { x = 236, y = 458, width = 10, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["51"] = { x = 251, y = 458, width = 10, height = 13, xadvance = 11, yoffset = 5, atlas = 1 },
								["52"] = { x = 266, y = 458, width = 11, height = 13, xadvance = 11, yoffset = 5, atlas = 1 },
								["53"] = { x = 282, y = 458, width = 10, height = 13, xadvance = 11, yoffset = 5, atlas = 1 },
								["54"] = { x = 297, y = 458, width = 11, height = 13, xadvance = 11, yoffset = 4, atlas = 1 },
								["55"] = { x = 313, y = 458, width = 11, height = 14, xadvance = 11, yoffset = 5, atlas = 1 },
								["56"] = { x = 329, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["57"] = { x = 345, y = 458, width = 11, height = 13, xadvance = 11, yoffset = 5, atlas = 1 },
								["58"] = { x = 361, y = 458, width = 4, height = 9, xadvance = 4, yoffset = 8, atlas = 1 },
								["59"] = { x = 370, y = 458, width = 4, height = 12, xadvance = 4, yoffset = 8, atlas = 1 },
								["60"] = { x = 379, y = 458, width = 10, height = 10, xadvance = 11, yoffset = 6, atlas = 1 },
								["61"] = { x = 394, y = 458, width = 9, height = 6, xadvance = 10, yoffset = 8, atlas = 1 },
								["62"] = { x = 408, y = 458, width = 10, height = 10, xadvance = 11, yoffset = 6, atlas = 1 },
								["63"] = { x = 423, y = 458, width = 9, height = 13, xadvance = 9, yoffset = 4, atlas = 1 },
								["64"] = { x = 437, y = 458, width = 18, height = 17, xadvance = 19, yoffset = 4, atlas = 1 },
								["65"] = { x = 460, y = 458, width = 12, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["66"] = { x = 477, y = 458, width = 10, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["67"] = { x = 492, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["68"] = { x = 508, y = 458, width = 12, height = 12, xadvance = 12, yoffset = 5, atlas = 1 },
								["69"] = { x = 525, y = 458, width = 10, height = 12, xadvance = 9, yoffset = 5, atlas = 1 },
								["70"] = { x = 540, y = 458, width = 9, height = 12, xadvance = 9, yoffset = 5, atlas = 1 },
								["71"] = { x = 554, y = 458, width = 12, height = 12, xadvance = 13, yoffset = 5, atlas = 1 },
								["72"] = { x = 571, y = 458, width = 11, height = 12, xadvance = 12, yoffset = 5, atlas = 1 },
								["73"] = { x = 587, y = 458, width = 4, height = 12, xadvance = 5, yoffset = 5, atlas = 1 },
								["74"] = { x = 596, y = 458, width = 7, height = 12, xadvance = 8, yoffset = 5, atlas = 1 },
								["75"] = { x = 608, y = 458, width = 12, height = 12, xadvance = 10, yoffset = 5, atlas = 1 },
								["76"] = { x = 625, y = 458, width = 9, height = 12, xadvance = 9, yoffset = 5, atlas = 1 },
								["77"] = { x = 639, y = 458, width = 13, height = 12, xadvance = 14, yoffset = 5, atlas = 1 },
								["78"] = { x = 657, y = 458, width = 11, height = 12, xadvance = 12, yoffset = 5, atlas = 1 },
								["79"] = { x = 673, y = 458, width = 13, height = 12, xadvance = 13, yoffset = 5, atlas = 1 },
								["80"] = { x = 691, y = 458, width = 10, height = 12, xadvance = 10, yoffset = 5, atlas = 1 },
								["81"] = { x = 706, y = 458, width = 13, height = 15, xadvance = 13, yoffset = 5, atlas = 1 },
								["82"] = { x = 724, y = 458, width = 12, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["83"] = { x = 741, y = 458, width = 10, height = 12, xadvance = 10, yoffset = 5, atlas = 1 },
								["84"] = { x = 756, y = 458, width = 9, height = 12, xadvance = 9, yoffset = 5, atlas = 1 },
								["85"] = { x = 770, y = 458, width = 11, height = 12, xadvance = 12, yoffset = 5, atlas = 1 },
								["86"] = { x = 786, y = 458, width = 12, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["87"] = { x = 803, y = 458, width = 17, height = 12, xadvance = 16, yoffset = 5, atlas = 1 },
								["88"] = { x = 825, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["89"] = { x = 841, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["90"] = { x = 857, y = 458, width = 11, height = 12, xadvance = 11, yoffset = 5, atlas = 1 },
								["91"] = { x = 873, y = 458, width = 6, height = 17, xadvance = 6, yoffset = 3, atlas = 1 },
								["92"] = { x = 884, y = 458, width = 8, height = 13, xadvance = 7, yoffset = 4, atlas = 1 },
								["93"] = { x = 897, y = 458, width = 6, height = 17, xadvance = 6, yoffset = 3, atlas = 1 },
								["94"] = { x = 908, y = 458, width = 10, height = 7, xadvance = 10, yoffset = 4, atlas = 1 },
								["95"] = { x = 923, y = 458, width = 10, height = 3, xadvance = 10, yoffset = 16, atlas = 1 },
								["96"] = { x = 938, y = 458, width = 8, height = 3, xadvance = 9, yoffset = 4, atlas = 1 },
								["97"] = { x = 951, y = 458, width = 9, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["98"] = { x = 965, y = 458, width = 10, height = 13, xadvance = 11, yoffset = 4, atlas = 1 },
								["99"] = { x = 980, y = 458, width = 9, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["100"] = { x = 994, y = 458, width = 10, height = 13, xadvance = 11, yoffset = 4, atlas = 1 },
								["101"] = { x = 1009, y = 458, width = 10, height = 9, xadvance = 11, yoffset = 8, atlas = 1 },
								["102"] = { x = 0, y = 480, width = 9, height = 13, xadvance = 8, yoffset = 4, atlas = 1 },
								["103"] = { x = 14, y = 480, width = 11, height = 13, xadvance = 11, yoffset = 8, atlas = 1 },
								["104"] = { x = 30, y = 480, width = 10, height = 13, xadvance = 10, yoffset = 4, atlas = 1 },
								["105"] = { x = 45, y = 480, width = 4, height = 12, xadvance = 5, yoffset = 5, atlas = 1 },
								["106"] = { x = 54, y = 480, width = 4, height = 15, xadvance = 5, yoffset = 5, atlas = 1 },
								["107"] = { x = 63, y = 480, width = 10, height = 13, xadvance = 9, yoffset = 4, atlas = 1 },
								["108"] = { x = 78, y = 480, width = 6, height = 13, xadvance = 5, yoffset = 4, atlas = 1 },
								["109"] = { x = 89, y = 480, width = 15, height = 9, xadvance = 15, yoffset = 8, atlas = 1 },
								["110"] = { x = 109, y = 480, width = 10, height = 9, xadvance = 10, yoffset = 8, atlas = 1 },
								["111"] = { x = 124, y = 480, width = 10, height = 9, xadvance = 11, yoffset = 8, atlas = 1 },
								["112"] = { x = 139, y = 480, width = 10, height = 13, xadvance = 11, yoffset = 8, atlas = 1 },
								["113"] = { x = 154, y = 480, width = 10, height = 13, xadvance = 11, yoffset = 8, atlas = 1 },
								["114"] = { x = 169, y = 480, width = 7, height = 9, xadvance = 7, yoffset = 8, atlas = 1 },
								["115"] = { x = 181, y = 480, width = 8, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["116"] = { x = 194, y = 480, width = 6, height = 11, xadvance = 6, yoffset = 6, atlas = 1 },
								["117"] = { x = 205, y = 480, width = 10, height = 9, xadvance = 11, yoffset = 8, atlas = 1 },
								["118"] = { x = 220, y = 480, width = 10, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["119"] = { x = 235, y = 480, width = 14, height = 9, xadvance = 14, yoffset = 8, atlas = 1 },
								["120"] = { x = 254, y = 480, width = 10, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["121"] = { x = 269, y = 480, width = 10, height = 13, xadvance = 9, yoffset = 8, atlas = 1 },
								["122"] = { x = 284, y = 480, width = 9, height = 9, xadvance = 9, yoffset = 8, atlas = 1 },
								["123"] = { x = 298, y = 480, width = 7, height = 17, xadvance = 7, yoffset = 3, atlas = 1 },
								["124"] = { x = 310, y = 480, width = 5, height = 17, xadvance = 6, yoffset = 3, atlas = 1 },
								["125"] = { x = 320, y = 480, width = 7, height = 17, xadvance = 7, yoffset = 3, atlas = 1 },
								["126"] = { x = 332, y = 480, width = 9, height = 5, xadvance = 8, yoffset = 7, atlas = 1 }
							},
							kerning = {
							}
						},
						["14"] = {
							lineHeight = 13,
							firstAdjust = 2,
							characters = {
								["32"] = { x = 0, y = 502, width = 0, height = 0, xadvance = 3, yoffset = 13, atlas = 1 },
								["33"] = { x = 5, y = 502, width = 4, height = 10, xadvance = 4, yoffset = 3, atlas = 1 },
								["34"] = { x = 14, y = 502, width = 6, height = 4, xadvance = 7, yoffset = 3, atlas = 1 },
								["35"] = { x = 25, y = 502, width = 10, height = 11, xadvance = 10, yoffset = 3, atlas = 1 },
								["36"] = { x = 40, y = 502, width = 8, height = 13, xadvance = 8, yoffset = 2, atlas = 1 },
								["37"] = { x = 53, y = 502, width = 15, height = 10, xadvance = 16, yoffset = 3, atlas = 1 },
								["38"] = { x = 73, y = 502, width = 11, height = 11, xadvance = 11, yoffset = 3, atlas = 1 },
								["39"] = { x = 89, y = 502, width = 4, height = 4, xadvance = 4, yoffset = 3, atlas = 1 },
								["40"] = { x = 98, y = 502, width = 5, height = 13, xadvance = 5, yoffset = 3, atlas = 1 },
								["41"] = { x = 108, y = 502, width = 5, height = 13, xadvance = 5, yoffset = 3, atlas = 1 },
								["42"] = { x = 118, y = 502, width = 8, height = 6, xadvance = 8, yoffset = 3, atlas = 1 },
								["43"] = { x = 131, y = 502, width = 8, height = 7, xadvance = 8, yoffset = 5, atlas = 1 },
								["44"] = { x = 144, y = 502, width = 3, height = 4, xadvance = 3, yoffset = 11, atlas = 1 },
								["45"] = { x = 152, y = 502, width = 5, height = 2, xadvance = 6, yoffset = 8, atlas = 1 },
								["46"] = { x = 162, y = 502, width = 4, height = 2, xadvance = 4, yoffset = 11, atlas = 1 },
								["47"] = { x = 171, y = 502, width = 6, height = 10, xadvance = 6, yoffset = 3, atlas = 1 },
								["48"] = { x = 182, y = 502, width = 9, height = 9, xadvance = 8, yoffset = 4, atlas = 1 },
								["49"] = { x = 196, y = 502, width = 9, height = 9, xadvance = 8, yoffset = 4, atlas = 1 },
								["50"] = { x = 210, y = 502, width = 8, height = 9, xadvance = 8, yoffset = 4, atlas = 1 },
								["51"] = { x = 223, y = 502, width = 8, height = 10, xadvance = 8, yoffset = 4, atlas = 1 },
								["52"] = { x = 236, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 4, atlas = 1 },
								["53"] = { x = 250, y = 502, width = 7, height = 10, xadvance = 8, yoffset = 4, atlas = 1 },
								["54"] = { x = 262, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["55"] = { x = 276, y = 502, width = 8, height = 10, xadvance = 8, yoffset = 4, atlas = 1 },
								["56"] = { x = 289, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["57"] = { x = 303, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 4, atlas = 1 },
								["58"] = { x = 317, y = 502, width = 4, height = 7, xadvance = 4, yoffset = 6, atlas = 1 },
								["59"] = { x = 326, y = 502, width = 4, height = 9, xadvance = 4, yoffset = 6, atlas = 1 },
								["60"] = { x = 335, y = 502, width = 8, height = 8, xadvance = 8, yoffset = 4, atlas = 1 },
								["61"] = { x = 348, y = 502, width = 8, height = 4, xadvance = 9, yoffset = 6, atlas = 1 },
								["62"] = { x = 361, y = 502, width = 8, height = 8, xadvance = 8, yoffset = 4, atlas = 1 },
								["63"] = { x = 374, y = 502, width = 7, height = 10, xadvance = 7, yoffset = 3, atlas = 1 },
								["64"] = { x = 386, y = 502, width = 15, height = 13, xadvance = 15, yoffset = 3, atlas = 1 },
								["65"] = { x = 406, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["66"] = { x = 420, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["67"] = { x = 433, y = 502, width = 9, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["68"] = { x = 447, y = 502, width = 10, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["69"] = { x = 462, y = 502, width = 8, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["70"] = { x = 475, y = 502, width = 7, height = 10, xadvance = 7, yoffset = 3, atlas = 1 },
								["71"] = { x = 487, y = 502, width = 10, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["72"] = { x = 502, y = 502, width = 9, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["73"] = { x = 516, y = 502, width = 4, height = 10, xadvance = 4, yoffset = 3, atlas = 1 },
								["74"] = { x = 525, y = 502, width = 6, height = 10, xadvance = 6, yoffset = 3, atlas = 1 },
								["75"] = { x = 536, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["76"] = { x = 550, y = 502, width = 8, height = 10, xadvance = 7, yoffset = 3, atlas = 1 },
								["77"] = { x = 563, y = 502, width = 11, height = 10, xadvance = 11, yoffset = 3, atlas = 1 },
								["78"] = { x = 579, y = 502, width = 9, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["79"] = { x = 593, y = 502, width = 10, height = 10, xadvance = 11, yoffset = 3, atlas = 1 },
								["80"] = { x = 608, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["81"] = { x = 621, y = 502, width = 10, height = 12, xadvance = 11, yoffset = 3, atlas = 1 },
								["82"] = { x = 636, y = 502, width = 10, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["83"] = { x = 651, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["84"] = { x = 664, y = 502, width = 8, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["85"] = { x = 677, y = 502, width = 9, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["86"] = { x = 691, y = 502, width = 9, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["87"] = { x = 705, y = 502, width = 13, height = 10, xadvance = 13, yoffset = 3, atlas = 1 },
								["88"] = { x = 723, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["89"] = { x = 737, y = 502, width = 9, height = 10, xadvance = 8, yoffset = 3, atlas = 1 },
								["90"] = { x = 751, y = 502, width = 9, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["91"] = { x = 765, y = 502, width = 5, height = 13, xadvance = 5, yoffset = 3, atlas = 1 },
								["92"] = { x = 775, y = 502, width = 6, height = 10, xadvance = 6, yoffset = 3, atlas = 1 },
								["93"] = { x = 786, y = 502, width = 5, height = 13, xadvance = 5, yoffset = 3, atlas = 1 },
								["94"] = { x = 796, y = 502, width = 8, height = 6, xadvance = 8, yoffset = 3, atlas = 1 },
								["95"] = { x = 809, y = 502, width = 8, height = 2, xadvance = 7, yoffset = 13, atlas = 1 },
								["96"] = { x = 822, y = 502, width = 6, height = 3, xadvance = 7, yoffset = 3, atlas = 1 },
								["97"] = { x = 833, y = 502, width = 8, height = 7, xadvance = 8, yoffset = 6, atlas = 1 },
								["98"] = { x = 846, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["99"] = { x = 859, y = 502, width = 8, height = 7, xadvance = 7, yoffset = 6, atlas = 1 },
								["100"] = { x = 872, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["101"] = { x = 885, y = 502, width = 8, height = 7, xadvance = 9, yoffset = 6, atlas = 1 },
								["102"] = { x = 898, y = 502, width = 6, height = 10, xadvance = 5, yoffset = 3, atlas = 1 },
								["103"] = { x = 909, y = 502, width = 9, height = 10, xadvance = 9, yoffset = 6, atlas = 1 },
								["104"] = { x = 923, y = 502, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["105"] = { x = 936, y = 502, width = 4, height = 10, xadvance = 4, yoffset = 3, atlas = 1 },
								["106"] = { x = 945, y = 502, width = 4, height = 13, xadvance = 4, yoffset = 3, atlas = 1 },
								["107"] = { x = 954, y = 502, width = 8, height = 10, xadvance = 7, yoffset = 3, atlas = 1 },
								["108"] = { x = 967, y = 502, width = 5, height = 10, xadvance = 4, yoffset = 3, atlas = 1 },
								["109"] = { x = 977, y = 502, width = 12, height = 7, xadvance = 12, yoffset = 6, atlas = 1 },
								["110"] = { x = 994, y = 502, width = 8, height = 7, xadvance = 9, yoffset = 6, atlas = 1 },
								["111"] = { x = 1007, y = 502, width = 9, height = 7, xadvance = 9, yoffset = 6, atlas = 1 },
								["112"] = { x = 0, y = 520, width = 8, height = 10, xadvance = 9, yoffset = 6, atlas = 1 },
								["113"] = { x = 13, y = 520, width = 8, height = 10, xadvance = 9, yoffset = 6, atlas = 1 },
								["114"] = { x = 26, y = 520, width = 6, height = 7, xadvance = 5, yoffset = 6, atlas = 1 },
								["115"] = { x = 37, y = 520, width = 7, height = 7, xadvance = 7, yoffset = 6, atlas = 1 },
								["116"] = { x = 49, y = 520, width = 6, height = 9, xadvance = 5, yoffset = 4, atlas = 1 },
								["117"] = { x = 60, y = 520, width = 8, height = 7, xadvance = 8, yoffset = 6, atlas = 1 },
								["118"] = { x = 73, y = 520, width = 8, height = 7, xadvance = 7, yoffset = 6, atlas = 1 },
								["119"] = { x = 86, y = 520, width = 11, height = 7, xadvance = 11, yoffset = 6, atlas = 1 },
								["120"] = { x = 102, y = 520, width = 8, height = 7, xadvance = 7, yoffset = 6, atlas = 1 },
								["121"] = { x = 115, y = 520, width = 8, height = 10, xadvance = 7, yoffset = 6, atlas = 1 },
								["122"] = { x = 128, y = 520, width = 7, height = 7, xadvance = 7, yoffset = 6, atlas = 1 },
								["123"] = { x = 140, y = 520, width = 6, height = 13, xadvance = 6, yoffset = 3, atlas = 1 },
								["124"] = { x = 151, y = 520, width = 4, height = 13, xadvance = 4, yoffset = 3, atlas = 1 },
								["125"] = { x = 160, y = 520, width = 6, height = 13, xadvance = 6, yoffset = 3, atlas = 1 },
								["126"] = { x = 171, y = 520, width = 7, height = 4, xadvance = 7, yoffset = 5, atlas = 1 }
							},
							kerning = {
							}
						},
						["12"] = {
							lineHeight = 13,
							firstAdjust = 1,
							characters = {
								["32"] = { x = 0, y = 538, width = 0, height = 0, xadvance = 3, yoffset = 11, atlas = 1 },
								["33"] = { x = 5, y = 538, width = 3, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["34"] = { x = 13, y = 538, width = 5, height = 4, xadvance = 6, yoffset = 3, atlas = 1 },
								["35"] = { x = 23, y = 538, width = 9, height = 9, xadvance = 9, yoffset = 3, atlas = 1 },
								["36"] = { x = 37, y = 538, width = 7, height = 12, xadvance = 7, yoffset = 1, atlas = 1 },
								["37"] = { x = 49, y = 538, width = 13, height = 8, xadvance = 13, yoffset = 3, atlas = 1 },
								["38"] = { x = 67, y = 538, width = 10, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["39"] = { x = 82, y = 538, width = 3, height = 4, xadvance = 3, yoffset = 3, atlas = 1 },
								["40"] = { x = 90, y = 538, width = 5, height = 11, xadvance = 5, yoffset = 2, atlas = 1 },
								["41"] = { x = 100, y = 538, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["42"] = { x = 109, y = 538, width = 6, height = 6, xadvance = 6, yoffset = 3, atlas = 1 },
								["43"] = { x = 120, y = 538, width = 7, height = 6, xadvance = 8, yoffset = 4, atlas = 1 },
								["44"] = { x = 132, y = 538, width = 3, height = 3, xadvance = 3, yoffset = 10, atlas = 1 },
								["45"] = { x = 140, y = 538, width = 4, height = 3, xadvance = 4, yoffset = 6, atlas = 1 },
								["46"] = { x = 149, y = 538, width = 3, height = 2, xadvance = 3, yoffset = 9, atlas = 1 },
								["47"] = { x = 157, y = 538, width = 5, height = 8, xadvance = 5, yoffset = 3, atlas = 1 },
								["48"] = { x = 167, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["49"] = { x = 180, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["50"] = { x = 192, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["51"] = { x = 204, y = 538, width = 6, height = 10, xadvance = 7, yoffset = 2, atlas = 1 },
								["52"] = { x = 215, y = 538, width = 7, height = 9, xadvance = 7, yoffset = 3, atlas = 1 },
								["53"] = { x = 227, y = 538, width = 6, height = 10, xadvance = 7, yoffset = 2, atlas = 1 },
								["54"] = { x = 238, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["55"] = { x = 250, y = 538, width = 7, height = 9, xadvance = 7, yoffset = 3, atlas = 1 },
								["56"] = { x = 262, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["57"] = { x = 274, y = 538, width = 7, height = 10, xadvance = 7, yoffset = 3, atlas = 1 },
								["58"] = { x = 286, y = 538, width = 3, height = 6, xadvance = 3, yoffset = 5, atlas = 1 },
								["59"] = { x = 294, y = 538, width = 3, height = 8, xadvance = 3, yoffset = 5, atlas = 1 },
								["60"] = { x = 302, y = 538, width = 7, height = 6, xadvance = 7, yoffset = 4, atlas = 1 },
								["61"] = { x = 314, y = 538, width = 7, height = 4, xadvance = 7, yoffset = 5, atlas = 1 },
								["62"] = { x = 326, y = 538, width = 7, height = 6, xadvance = 7, yoffset = 4, atlas = 1 },
								["63"] = { x = 338, y = 538, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["64"] = { x = 349, y = 538, width = 12, height = 11, xadvance = 13, yoffset = 3, atlas = 1 },
								["65"] = { x = 366, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["66"] = { x = 379, y = 538, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["67"] = { x = 391, y = 538, width = 8, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["68"] = { x = 404, y = 538, width = 8, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["69"] = { x = 417, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["70"] = { x = 429, y = 538, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["71"] = { x = 441, y = 538, width = 8, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["72"] = { x = 454, y = 538, width = 8, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["73"] = { x = 467, y = 538, width = 3, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["74"] = { x = 475, y = 538, width = 5, height = 8, xadvance = 5, yoffset = 3, atlas = 1 },
								["75"] = { x = 485, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["76"] = { x = 498, y = 538, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["77"] = { x = 510, y = 538, width = 9, height = 8, xadvance = 10, yoffset = 3, atlas = 1 },
								["78"] = { x = 524, y = 538, width = 8, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["79"] = { x = 537, y = 538, width = 9, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["80"] = { x = 551, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["81"] = { x = 563, y = 538, width = 9, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["82"] = { x = 577, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["83"] = { x = 590, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["84"] = { x = 602, y = 538, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["85"] = { x = 614, y = 538, width = 8, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["86"] = { x = 627, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["87"] = { x = 640, y = 538, width = 11, height = 8, xadvance = 11, yoffset = 3, atlas = 1 },
								["88"] = { x = 656, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["89"] = { x = 669, y = 538, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["90"] = { x = 682, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["91"] = { x = 694, y = 538, width = 5, height = 13, xadvance = 5, yoffset = 1, atlas = 1 },
								["92"] = { x = 704, y = 538, width = 5, height = 8, xadvance = 5, yoffset = 3, atlas = 1 },
								["93"] = { x = 714, y = 538, width = 4, height = 13, xadvance = 4, yoffset = 1, atlas = 1 },
								["94"] = { x = 723, y = 538, width = 7, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["95"] = { x = 735, y = 538, width = 7, height = 3, xadvance = 6, yoffset = 10, atlas = 1 },
								["96"] = { x = 747, y = 538, width = 5, height = 2, xadvance = 6, yoffset = 3, atlas = 1 },
								["97"] = { x = 757, y = 538, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["98"] = { x = 768, y = 538, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["99"] = { x = 780, y = 538, width = 7, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["100"] = { x = 792, y = 538, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["101"] = { x = 804, y = 538, width = 7, height = 6, xadvance = 8, yoffset = 5, atlas = 1 },
								["102"] = { x = 816, y = 538, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["103"] = { x = 826, y = 538, width = 8, height = 9, xadvance = 8, yoffset = 5, atlas = 1 },
								["104"] = { x = 839, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["105"] = { x = 851, y = 538, width = 3, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["106"] = { x = 859, y = 538, width = 3, height = 11, xadvance = 3, yoffset = 3, atlas = 1 },
								["107"] = { x = 867, y = 538, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["108"] = { x = 879, y = 538, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["109"] = { x = 889, y = 538, width = 10, height = 6, xadvance = 10, yoffset = 5, atlas = 1 },
								["110"] = { x = 904, y = 538, width = 7, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["111"] = { x = 916, y = 538, width = 7, height = 6, xadvance = 8, yoffset = 5, atlas = 1 },
								["112"] = { x = 928, y = 538, width = 7, height = 9, xadvance = 8, yoffset = 5, atlas = 1 },
								["113"] = { x = 940, y = 538, width = 7, height = 9, xadvance = 8, yoffset = 5, atlas = 1 },
								["114"] = { x = 952, y = 538, width = 5, height = 6, xadvance = 5, yoffset = 5, atlas = 1 },
								["115"] = { x = 962, y = 538, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["116"] = { x = 973, y = 538, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["117"] = { x = 983, y = 538, width = 7, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["118"] = { x = 995, y = 538, width = 7, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["119"] = { x = 1007, y = 538, width = 10, height = 6, xadvance = 9, yoffset = 5, atlas = 1 },
								["120"] = { x = 0, y = 556, width = 7, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["121"] = { x = 12, y = 556, width = 7, height = 9, xadvance = 6, yoffset = 5, atlas = 1 },
								["122"] = { x = 24, y = 556, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["123"] = { x = 35, y = 556, width = 5, height = 13, xadvance = 4, yoffset = 1, atlas = 1 },
								["124"] = { x = 45, y = 556, width = 3, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["125"] = { x = 53, y = 556, width = 5, height = 13, xadvance = 5, yoffset = 1, atlas = 1 },
								["126"] = { x = 63, y = 556, width = 6, height = 3, xadvance = 6, yoffset = 5, atlas = 1 }
							},
							kerning = {
							}
						},
						["11"] = {
							lineHeight = 13,
							firstAdjust = 1,
							characters = {
								["32"] = { x = 0, y = 574, width = 0, height = 0, xadvance = 3, yoffset = 11, atlas = 1 },
								["33"] = { x = 5, y = 574, width = 3, height = 8, xadvance = 3, yoffset = 3, atlas = 1 },
								["34"] = { x = 13, y = 574, width = 5, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["35"] = { x = 23, y = 574, width = 8, height = 9, xadvance = 8, yoffset = 3, atlas = 1 },
								["36"] = { x = 36, y = 574, width = 7, height = 12, xadvance = 7, yoffset = 1, atlas = 1 },
								["37"] = { x = 48, y = 574, width = 12, height = 8, xadvance = 13, yoffset = 3, atlas = 1 },
								["38"] = { x = 65, y = 574, width = 10, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["39"] = { x = 80, y = 574, width = 3, height = 4, xadvance = 3, yoffset = 3, atlas = 1 },
								["40"] = { x = 88, y = 574, width = 5, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["41"] = { x = 98, y = 574, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["42"] = { x = 107, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 3, atlas = 1 },
								["43"] = { x = 118, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["44"] = { x = 129, y = 574, width = 3, height = 3, xadvance = 2, yoffset = 10, atlas = 1 },
								["45"] = { x = 137, y = 574, width = 4, height = 3, xadvance = 4, yoffset = 6, atlas = 1 },
								["46"] = { x = 146, y = 574, width = 3, height = 2, xadvance = 3, yoffset = 9, atlas = 1 },
								["47"] = { x = 154, y = 574, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["48"] = { x = 164, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["49"] = { x = 176, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["50"] = { x = 188, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["51"] = { x = 199, y = 574, width = 6, height = 10, xadvance = 6, yoffset = 2, atlas = 1 },
								["52"] = { x = 210, y = 574, width = 7, height = 9, xadvance = 6, yoffset = 3, atlas = 1 },
								["53"] = { x = 222, y = 574, width = 6, height = 10, xadvance = 6, yoffset = 2, atlas = 1 },
								["54"] = { x = 233, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["55"] = { x = 245, y = 574, width = 7, height = 9, xadvance = 6, yoffset = 3, atlas = 1 },
								["56"] = { x = 257, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["57"] = { x = 269, y = 574, width = 7, height = 10, xadvance = 6, yoffset = 3, atlas = 1 },
								["58"] = { x = 281, y = 574, width = 3, height = 6, xadvance = 3, yoffset = 5, atlas = 1 },
								["59"] = { x = 289, y = 574, width = 3, height = 8, xadvance = 3, yoffset = 5, atlas = 1 },
								["60"] = { x = 297, y = 574, width = 7, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["61"] = { x = 309, y = 574, width = 6, height = 4, xadvance = 6, yoffset = 5, atlas = 1 },
								["62"] = { x = 320, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["63"] = { x = 331, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["64"] = { x = 342, y = 574, width = 11, height = 11, xadvance = 12, yoffset = 3, atlas = 1 },
								["65"] = { x = 358, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["66"] = { x = 370, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["67"] = { x = 382, y = 574, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["68"] = { x = 395, y = 574, width = 8, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["69"] = { x = 408, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["70"] = { x = 419, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["71"] = { x = 430, y = 574, width = 8, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["72"] = { x = 443, y = 574, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["73"] = { x = 455, y = 574, width = 3, height = 8, xadvance = 3, yoffset = 3, atlas = 1 },
								["74"] = { x = 463, y = 574, width = 5, height = 8, xadvance = 5, yoffset = 3, atlas = 1 },
								["75"] = { x = 473, y = 574, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["76"] = { x = 486, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["77"] = { x = 497, y = 574, width = 9, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["78"] = { x = 511, y = 574, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["79"] = { x = 523, y = 574, width = 8, height = 8, xadvance = 9, yoffset = 3, atlas = 1 },
								["80"] = { x = 536, y = 574, width = 6, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["81"] = { x = 547, y = 574, width = 8, height = 10, xadvance = 9, yoffset = 3, atlas = 1 },
								["82"] = { x = 560, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["83"] = { x = 572, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["84"] = { x = 583, y = 574, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["85"] = { x = 594, y = 574, width = 7, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["86"] = { x = 606, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["87"] = { x = 618, y = 574, width = 10, height = 8, xadvance = 10, yoffset = 3, atlas = 1 },
								["88"] = { x = 633, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["89"] = { x = 645, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["90"] = { x = 657, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["91"] = { x = 669, y = 574, width = 4, height = 13, xadvance = 4, yoffset = 1, atlas = 1 },
								["92"] = { x = 678, y = 574, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["93"] = { x = 688, y = 574, width = 4, height = 13, xadvance = 4, yoffset = 1, atlas = 1 },
								["94"] = { x = 697, y = 574, width = 6, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["95"] = { x = 708, y = 574, width = 6, height = 3, xadvance = 5, yoffset = 10, atlas = 1 },
								["96"] = { x = 719, y = 574, width = 5, height = 2, xadvance = 5, yoffset = 3, atlas = 1 },
								["97"] = { x = 729, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["98"] = { x = 740, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["99"] = { x = 752, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["100"] = { x = 763, y = 574, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["101"] = { x = 775, y = 574, width = 6, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["102"] = { x = 786, y = 574, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["103"] = { x = 796, y = 574, width = 8, height = 9, xadvance = 8, yoffset = 5, atlas = 1 },
								["104"] = { x = 809, y = 574, width = 6, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["105"] = { x = 820, y = 574, width = 3, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["106"] = { x = 828, y = 574, width = 3, height = 11, xadvance = 3, yoffset = 3, atlas = 1 },
								["107"] = { x = 836, y = 574, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["108"] = { x = 848, y = 574, width = 4, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["109"] = { x = 857, y = 574, width = 10, height = 6, xadvance = 10, yoffset = 5, atlas = 1 },
								["110"] = { x = 872, y = 574, width = 6, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["111"] = { x = 883, y = 574, width = 7, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["112"] = { x = 895, y = 574, width = 7, height = 9, xadvance = 7, yoffset = 5, atlas = 1 },
								["113"] = { x = 907, y = 574, width = 7, height = 9, xadvance = 7, yoffset = 5, atlas = 1 },
								["114"] = { x = 919, y = 574, width = 5, height = 6, xadvance = 4, yoffset = 5, atlas = 1 },
								["115"] = { x = 929, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["116"] = { x = 940, y = 574, width = 5, height = 8, xadvance = 4, yoffset = 3, atlas = 1 },
								["117"] = { x = 950, y = 574, width = 6, height = 6, xadvance = 7, yoffset = 5, atlas = 1 },
								["118"] = { x = 961, y = 574, width = 6, height = 6, xadvance = 6, yoffset = 5, atlas = 1 },
								["119"] = { x = 972, y = 574, width = 9, height = 6, xadvance = 8, yoffset = 5, atlas = 1 },
								["120"] = { x = 986, y = 574, width = 6, height = 6, xadvance = 5, yoffset = 5, atlas = 1 },
								["121"] = { x = 997, y = 574, width = 6, height = 9, xadvance = 6, yoffset = 5, atlas = 1 },
								["122"] = { x = 1008, y = 574, width = 6, height = 6, xadvance = 5, yoffset = 5, atlas = 1 },
								["123"] = { x = 0, y = 592, width = 4, height = 13, xadvance = 4, yoffset = 1, atlas = 1 },
								["124"] = { x = 9, y = 592, width = 3, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["125"] = { x = 17, y = 592, width = 5, height = 13, xadvance = 5, yoffset = 1, atlas = 1 },
								["126"] = { x = 27, y = 592, width = 6, height = 4, xadvance = 5, yoffset = 4, atlas = 1 }
							},
							kerning = {
							}
						},
						["10"] = {
							lineHeight = 11,
							firstAdjust = 2,
							characters = {
								["32"] = { x = 0, y = 610, width = 0, height = 0, xadvance = 2, yoffset = 10, atlas = 1 },
								["33"] = { x = 5, y = 610, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["34"] = { x = 13, y = 610, width = 5, height = 3, xadvance = 5, yoffset = 3, atlas = 1 },
								["35"] = { x = 23, y = 610, width = 7, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["36"] = { x = 35, y = 610, width = 6, height = 9, xadvance = 6, yoffset = 2, atlas = 1 },
								["37"] = { x = 46, y = 610, width = 11, height = 7, xadvance = 12, yoffset = 3, atlas = 1 },
								["38"] = { x = 62, y = 610, width = 9, height = 8, xadvance = 8, yoffset = 3, atlas = 1 },
								["39"] = { x = 76, y = 610, width = 3, height = 3, xadvance = 3, yoffset = 3, atlas = 1 },
								["40"] = { x = 84, y = 610, width = 4, height = 10, xadvance = 4, yoffset = 2, atlas = 1 },
								["41"] = { x = 93, y = 610, width = 3, height = 10, xadvance = 3, yoffset = 2, atlas = 1 },
								["42"] = { x = 101, y = 610, width = 6, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["43"] = { x = 112, y = 610, width = 6, height = 5, xadvance = 6, yoffset = 4, atlas = 1 },
								["44"] = { x = 123, y = 610, width = 3, height = 3, xadvance = 2, yoffset = 8, atlas = 1 },
								["45"] = { x = 131, y = 610, width = 4, height = 3, xadvance = 4, yoffset = 6, atlas = 1 },
								["46"] = { x = 140, y = 610, width = 3, height = 2, xadvance = 2, yoffset = 8, atlas = 1 },
								["47"] = { x = 148, y = 610, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["48"] = { x = 157, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["49"] = { x = 169, y = 610, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["50"] = { x = 180, y = 610, width = 5, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["51"] = { x = 190, y = 610, width = 6, height = 9, xadvance = 6, yoffset = 2, atlas = 1 },
								["52"] = { x = 201, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 4, atlas = 1 },
								["53"] = { x = 212, y = 610, width = 6, height = 9, xadvance = 6, yoffset = 2, atlas = 1 },
								["54"] = { x = 223, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["55"] = { x = 234, y = 610, width = 6, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["56"] = { x = 245, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["57"] = { x = 257, y = 610, width = 6, height = 9, xadvance = 6, yoffset = 3, atlas = 1 },
								["58"] = { x = 268, y = 610, width = 3, height = 5, xadvance = 2, yoffset = 5, atlas = 1 },
								["59"] = { x = 276, y = 610, width = 3, height = 7, xadvance = 3, yoffset = 5, atlas = 1 },
								["60"] = { x = 284, y = 610, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["61"] = { x = 295, y = 610, width = 6, height = 4, xadvance = 6, yoffset = 5, atlas = 1 },
								["62"] = { x = 306, y = 610, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["63"] = { x = 317, y = 610, width = 5, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["64"] = { x = 327, y = 610, width = 11, height = 10, xadvance = 11, yoffset = 3, atlas = 1 },
								["65"] = { x = 343, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["66"] = { x = 355, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["67"] = { x = 366, y = 610, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["68"] = { x = 378, y = 610, width = 7, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["69"] = { x = 390, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["70"] = { x = 401, y = 610, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["71"] = { x = 412, y = 610, width = 7, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["72"] = { x = 424, y = 610, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["73"] = { x = 436, y = 610, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["74"] = { x = 444, y = 610, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["75"] = { x = 453, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["76"] = { x = 465, y = 610, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["77"] = { x = 476, y = 610, width = 8, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["78"] = { x = 489, y = 610, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["79"] = { x = 501, y = 610, width = 8, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["80"] = { x = 514, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["81"] = { x = 525, y = 610, width = 8, height = 9, xadvance = 8, yoffset = 3, atlas = 1 },
								["82"] = { x = 538, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["83"] = { x = 550, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["84"] = { x = 561, y = 610, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["85"] = { x = 572, y = 610, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["86"] = { x = 584, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["87"] = { x = 596, y = 610, width = 10, height = 7, xadvance = 9, yoffset = 3, atlas = 1 },
								["88"] = { x = 611, y = 610, width = 7, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["89"] = { x = 623, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["90"] = { x = 634, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["91"] = { x = 645, y = 610, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["92"] = { x = 654, y = 610, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["93"] = { x = 663, y = 610, width = 3, height = 11, xadvance = 3, yoffset = 2, atlas = 1 },
								["94"] = { x = 671, y = 610, width = 6, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["95"] = { x = 682, y = 610, width = 6, height = 3, xadvance = 5, yoffset = 9, atlas = 1 },
								["96"] = { x = 693, y = 610, width = 5, height = 2, xadvance = 5, yoffset = 3, atlas = 1 },
								["97"] = { x = 703, y = 610, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["98"] = { x = 714, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["99"] = { x = 725, y = 610, width = 6, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["100"] = { x = 736, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["101"] = { x = 747, y = 610, width = 6, height = 5, xadvance = 7, yoffset = 5, atlas = 1 },
								["102"] = { x = 758, y = 610, width = 5, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["103"] = { x = 768, y = 610, width = 7, height = 7, xadvance = 7, yoffset = 5, atlas = 1 },
								["104"] = { x = 780, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["105"] = { x = 791, y = 610, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["106"] = { x = 799, y = 610, width = 3, height = 9, xadvance = 3, yoffset = 3, atlas = 1 },
								["107"] = { x = 807, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["108"] = { x = 818, y = 610, width = 4, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["109"] = { x = 827, y = 610, width = 9, height = 5, xadvance = 9, yoffset = 5, atlas = 1 },
								["110"] = { x = 841, y = 610, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["111"] = { x = 852, y = 610, width = 6, height = 5, xadvance = 7, yoffset = 5, atlas = 1 },
								["112"] = { x = 863, y = 610, width = 6, height = 7, xadvance = 7, yoffset = 5, atlas = 1 },
								["113"] = { x = 874, y = 610, width = 6, height = 7, xadvance = 6, yoffset = 5, atlas = 1 },
								["114"] = { x = 885, y = 610, width = 5, height = 5, xadvance = 4, yoffset = 5, atlas = 1 },
								["115"] = { x = 895, y = 610, width = 5, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["116"] = { x = 905, y = 610, width = 4, height = 6, xadvance = 4, yoffset = 4, atlas = 1 },
								["117"] = { x = 914, y = 610, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["118"] = { x = 925, y = 610, width = 6, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["119"] = { x = 936, y = 610, width = 8, height = 5, xadvance = 8, yoffset = 5, atlas = 1 },
								["120"] = { x = 949, y = 610, width = 6, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["121"] = { x = 960, y = 610, width = 6, height = 7, xadvance = 5, yoffset = 5, atlas = 1 },
								["122"] = { x = 971, y = 610, width = 5, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["123"] = { x = 981, y = 610, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["124"] = { x = 990, y = 610, width = 3, height = 10, xadvance = 3, yoffset = 2, atlas = 1 },
								["125"] = { x = 998, y = 610, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["126"] = { x = 1007, y = 610, width = 5, height = 3, xadvance = 5, yoffset = 5, atlas = 1 }
							},
							kerning = {
							}
						},
						["9"] = {
							lineHeight = 11,
							firstAdjust = 2,
							characters = {
								["32"] = { x = 0, y = 626, width = 0, height = 0, xadvance = 2, yoffset = 10, atlas = 1 },
								["33"] = { x = 5, y = 626, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["34"] = { x = 13, y = 626, width = 5, height = 3, xadvance = 5, yoffset = 3, atlas = 1 },
								["35"] = { x = 23, y = 626, width = 7, height = 8, xadvance = 6, yoffset = 3, atlas = 1 },
								["36"] = { x = 35, y = 626, width = 6, height = 9, xadvance = 6, yoffset = 2, atlas = 1 },
								["37"] = { x = 46, y = 626, width = 11, height = 7, xadvance = 11, yoffset = 3, atlas = 1 },
								["38"] = { x = 62, y = 626, width = 8, height = 8, xadvance = 7, yoffset = 3, atlas = 1 },
								["39"] = { x = 75, y = 626, width = 3, height = 3, xadvance = 3, yoffset = 3, atlas = 1 },
								["40"] = { x = 83, y = 626, width = 4, height = 10, xadvance = 3, yoffset = 2, atlas = 1 },
								["41"] = { x = 92, y = 626, width = 4, height = 10, xadvance = 4, yoffset = 2, atlas = 1 },
								["42"] = { x = 101, y = 626, width = 5, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["43"] = { x = 111, y = 626, width = 5, height = 5, xadvance = 5, yoffset = 4, atlas = 1 },
								["44"] = { x = 121, y = 626, width = 2, height = 3, xadvance = 2, yoffset = 8, atlas = 1 },
								["45"] = { x = 128, y = 626, width = 3, height = 3, xadvance = 3, yoffset = 6, atlas = 1 },
								["46"] = { x = 136, y = 626, width = 2, height = 2, xadvance = 2, yoffset = 8, atlas = 1 },
								["47"] = { x = 143, y = 626, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["48"] = { x = 152, y = 626, width = 7, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["49"] = { x = 164, y = 626, width = 6, height = 6, xadvance = 5, yoffset = 4, atlas = 1 },
								["50"] = { x = 175, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["51"] = { x = 185, y = 626, width = 6, height = 9, xadvance = 5, yoffset = 2, atlas = 1 },
								["52"] = { x = 196, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 4, atlas = 1 },
								["53"] = { x = 206, y = 626, width = 6, height = 9, xadvance = 5, yoffset = 2, atlas = 1 },
								["54"] = { x = 217, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["55"] = { x = 228, y = 626, width = 6, height = 8, xadvance = 5, yoffset = 3, atlas = 1 },
								["56"] = { x = 239, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["57"] = { x = 250, y = 626, width = 6, height = 9, xadvance = 5, yoffset = 3, atlas = 1 },
								["58"] = { x = 261, y = 626, width = 2, height = 5, xadvance = 2, yoffset = 5, atlas = 1 },
								["59"] = { x = 268, y = 626, width = 2, height = 7, xadvance = 2, yoffset = 5, atlas = 1 },
								["60"] = { x = 275, y = 626, width = 5, height = 6, xadvance = 5, yoffset = 4, atlas = 1 },
								["61"] = { x = 285, y = 626, width = 5, height = 4, xadvance = 5, yoffset = 5, atlas = 1 },
								["62"] = { x = 295, y = 626, width = 5, height = 6, xadvance = 5, yoffset = 4, atlas = 1 },
								["63"] = { x = 305, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["64"] = { x = 315, y = 626, width = 10, height = 10, xadvance = 10, yoffset = 3, atlas = 1 },
								["65"] = { x = 330, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["66"] = { x = 341, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["67"] = { x = 352, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["68"] = { x = 363, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["69"] = { x = 375, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["70"] = { x = 385, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["71"] = { x = 395, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["72"] = { x = 407, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["73"] = { x = 419, y = 626, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["74"] = { x = 427, y = 626, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["75"] = { x = 436, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["76"] = { x = 447, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["77"] = { x = 457, y = 626, width = 8, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["78"] = { x = 470, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["79"] = { x = 482, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["80"] = { x = 494, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["81"] = { x = 505, y = 626, width = 7, height = 9, xadvance = 7, yoffset = 3, atlas = 1 },
								["82"] = { x = 517, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["83"] = { x = 528, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["84"] = { x = 539, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["85"] = { x = 549, y = 626, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["86"] = { x = 561, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["87"] = { x = 572, y = 626, width = 9, height = 7, xadvance = 8, yoffset = 3, atlas = 1 },
								["88"] = { x = 586, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["89"] = { x = 597, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["90"] = { x = 608, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["91"] = { x = 619, y = 626, width = 4, height = 11, xadvance = 3, yoffset = 2, atlas = 1 },
								["92"] = { x = 628, y = 626, width = 4, height = 7, xadvance = 4, yoffset = 3, atlas = 1 },
								["93"] = { x = 637, y = 626, width = 4, height = 11, xadvance = 4, yoffset = 2, atlas = 1 },
								["94"] = { x = 646, y = 626, width = 5, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["95"] = { x = 656, y = 626, width = 5, height = 3, xadvance = 4, yoffset = 9, atlas = 1 },
								["96"] = { x = 666, y = 626, width = 4, height = 2, xadvance = 4, yoffset = 3, atlas = 1 },
								["97"] = { x = 675, y = 626, width = 5, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["98"] = { x = 685, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["99"] = { x = 696, y = 626, width = 5, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["100"] = { x = 706, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["101"] = { x = 717, y = 626, width = 5, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["102"] = { x = 727, y = 626, width = 4, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["103"] = { x = 736, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 5, atlas = 1 },
								["104"] = { x = 747, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 3, atlas = 1 },
								["105"] = { x = 758, y = 626, width = 3, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["106"] = { x = 766, y = 626, width = 3, height = 9, xadvance = 3, yoffset = 3, atlas = 1 },
								["107"] = { x = 774, y = 626, width = 6, height = 7, xadvance = 5, yoffset = 3, atlas = 1 },
								["108"] = { x = 785, y = 626, width = 4, height = 7, xadvance = 3, yoffset = 3, atlas = 1 },
								["109"] = { x = 794, y = 626, width = 9, height = 5, xadvance = 9, yoffset = 5, atlas = 1 },
								["110"] = { x = 808, y = 626, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["111"] = { x = 819, y = 626, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["112"] = { x = 830, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 5, atlas = 1 },
								["113"] = { x = 841, y = 626, width = 6, height = 7, xadvance = 6, yoffset = 5, atlas = 1 },
								["114"] = { x = 852, y = 626, width = 4, height = 5, xadvance = 4, yoffset = 5, atlas = 1 },
								["115"] = { x = 861, y = 626, width = 5, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["116"] = { x = 871, y = 626, width = 4, height = 6, xadvance = 3, yoffset = 4, atlas = 1 },
								["117"] = { x = 880, y = 626, width = 6, height = 5, xadvance = 6, yoffset = 5, atlas = 1 },
								["118"] = { x = 891, y = 626, width = 5, height = 5, xadvance = 5, yoffset = 5, atlas = 1 },
								["119"] = { x = 901, y = 626, width = 7, height = 5, xadvance = 7, yoffset = 5, atlas = 1 },
								["120"] = { x = 913, y = 626, width = 5, height = 5, xadvance = 4, yoffset = 5, atlas = 1 },
								["121"] = { x = 923, y = 626, width = 5, height = 7, xadvance = 5, yoffset = 5, atlas = 1 },
								["122"] = { x = 933, y = 626, width = 5, height = 5, xadvance = 4, yoffset = 5, atlas = 1 },
								["123"] = { x = 943, y = 626, width = 4, height = 11, xadvance = 3, yoffset = 2, atlas = 1 },
								["124"] = { x = 952, y = 626, width = 3, height = 10, xadvance = 3, yoffset = 2, atlas = 1 },
								["125"] = { x = 960, y = 626, width = 3, height = 11, xadvance = 3, yoffset = 2, atlas = 1 },
								["126"] = { x = 968, y = 626, width = 5, height = 3, xadvance = 4, yoffset = 5, atlas = 1 }
							},
							kerning = {
							}
						},
						["8"] = {
							lineHeight = 8,
							firstAdjust = 1,
							characters = {
								["32"] = { x = 0, y = 642, width = 0, height = 0, xadvance = 2, yoffset = 8, atlas = 1 },
								["33"] = { x = 5, y = 642, width = 3, height = 6, xadvance = 3, yoffset = 2, atlas = 1 },
								["34"] = { x = 13, y = 642, width = 4, height = 3, xadvance = 5, yoffset = 2, atlas = 1 },
								["35"] = { x = 22, y = 642, width = 6, height = 6, xadvance = 6, yoffset = 3, atlas = 1 },
								["36"] = { x = 33, y = 642, width = 5, height = 7, xadvance = 6, yoffset = 2, atlas = 1 },
								["37"] = { x = 43, y = 642, width = 9, height = 6, xadvance = 10, yoffset = 2, atlas = 1 },
								["38"] = { x = 57, y = 642, width = 8, height = 6, xadvance = 7, yoffset = 2, atlas = 1 },
								["39"] = { x = 70, y = 642, width = 3, height = 3, xadvance = 3, yoffset = 2, atlas = 1 },
								["40"] = { x = 78, y = 642, width = 4, height = 8, xadvance = 3, yoffset = 1, atlas = 1 },
								["41"] = { x = 87, y = 642, width = 3, height = 8, xadvance = 3, yoffset = 1, atlas = 1 },
								["42"] = { x = 95, y = 642, width = 5, height = 3, xadvance = 4, yoffset = 2, atlas = 1 },
								["43"] = { x = 105, y = 642, width = 5, height = 4, xadvance = 5, yoffset = 3, atlas = 1 },
								["44"] = { x = 115, y = 642, width = 2, height = 2, xadvance = 2, yoffset = 7, atlas = 1 },
								["45"] = { x = 122, y = 642, width = 3, height = 1, xadvance = 3, yoffset = 5, atlas = 1 },
								["46"] = { x = 130, y = 642, width = 2, height = 1, xadvance = 2, yoffset = 7, atlas = 1 },
								["47"] = { x = 137, y = 642, width = 4, height = 6, xadvance = 3, yoffset = 2, atlas = 1 },
								["48"] = { x = 146, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["49"] = { x = 156, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["50"] = { x = 166, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["51"] = { x = 176, y = 642, width = 4, height = 5, xadvance = 5, yoffset = 4, atlas = 1 },
								["52"] = { x = 185, y = 642, width = 5, height = 6, xadvance = 5, yoffset = 2, atlas = 1 },
								["53"] = { x = 195, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 4, atlas = 1 },
								["54"] = { x = 205, y = 642, width = 6, height = 6, xadvance = 5, yoffset = 2, atlas = 1 },
								["55"] = { x = 216, y = 642, width = 5, height = 6, xadvance = 5, yoffset = 3, atlas = 1 },
								["56"] = { x = 226, y = 642, width = 6, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["57"] = { x = 237, y = 642, width = 5, height = 6, xadvance = 5, yoffset = 3, atlas = 1 },
								["58"] = { x = 247, y = 642, width = 2, height = 4, xadvance = 2, yoffset = 4, atlas = 1 },
								["59"] = { x = 254, y = 642, width = 2, height = 5, xadvance = 2, yoffset = 4, atlas = 1 },
								["60"] = { x = 261, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["61"] = { x = 271, y = 642, width = 5, height = 2, xadvance = 5, yoffset = 4, atlas = 1 },
								["62"] = { x = 281, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["63"] = { x = 291, y = 642, width = 4, height = 6, xadvance = 4, yoffset = 2, atlas = 1 },
								["64"] = { x = 300, y = 642, width = 8, height = 8, xadvance = 9, yoffset = 2, atlas = 1 },
								["65"] = { x = 313, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["66"] = { x = 323, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["67"] = { x = 333, y = 642, width = 6, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["68"] = { x = 344, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["69"] = { x = 354, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["70"] = { x = 364, y = 642, width = 5, height = 5, xadvance = 4, yoffset = 3, atlas = 1 },
								["71"] = { x = 374, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["72"] = { x = 384, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["73"] = { x = 394, y = 642, width = 3, height = 5, xadvance = 3, yoffset = 3, atlas = 1 },
								["74"] = { x = 402, y = 642, width = 4, height = 5, xadvance = 4, yoffset = 3, atlas = 1 },
								["75"] = { x = 411, y = 642, width = 6, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["76"] = { x = 422, y = 642, width = 5, height = 5, xadvance = 4, yoffset = 3, atlas = 1 },
								["77"] = { x = 432, y = 642, width = 6, height = 5, xadvance = 7, yoffset = 3, atlas = 1 },
								["78"] = { x = 443, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["79"] = { x = 453, y = 642, width = 6, height = 5, xadvance = 7, yoffset = 3, atlas = 1 },
								["80"] = { x = 464, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["81"] = { x = 474, y = 642, width = 7, height = 7, xadvance = 7, yoffset = 3, atlas = 1 },
								["82"] = { x = 486, y = 642, width = 6, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["83"] = { x = 497, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["84"] = { x = 507, y = 642, width = 5, height = 5, xadvance = 4, yoffset = 3, atlas = 1 },
								["85"] = { x = 517, y = 642, width = 5, height = 5, xadvance = 6, yoffset = 3, atlas = 1 },
								["86"] = { x = 527, y = 642, width = 6, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["87"] = { x = 538, y = 642, width = 8, height = 5, xadvance = 7, yoffset = 3, atlas = 1 },
								["88"] = { x = 551, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["89"] = { x = 561, y = 642, width = 5, height = 5, xadvance = 5, yoffset = 3, atlas = 1 },
								["90"] = { x = 571, y = 642, width = 5, height = 5, xadvance = 4, yoffset = 3, atlas = 1 },
								["91"] = { x = 581, y = 642, width = 3, height = 7, xadvance = 3, yoffset = 2, atlas = 1 },
								["92"] = { x = 589, y = 642, width = 4, height = 6, xadvance = 3, yoffset = 2, atlas = 1 },
								["93"] = { x = 598, y = 642, width = 3, height = 7, xadvance = 3, yoffset = 2, atlas = 1 },
								["94"] = { x = 606, y = 642, width = 5, height = 3, xadvance = 4, yoffset = 2, atlas = 1 },
								["95"] = { x = 616, y = 642, width = 5, height = 1, xadvance = 4, yoffset = 8, atlas = 1 },
								["96"] = { x = 626, y = 642, width = 4, height = 2, xadvance = 4, yoffset = 2, atlas = 1 },
								["97"] = { x = 635, y = 642, width = 5, height = 4, xadvance = 5, yoffset = 4, atlas = 1 },
								["98"] = { x = 645, y = 642, width = 5, height = 6, xadvance = 6, yoffset = 2, atlas = 1 },
								["99"] = { x = 655, y = 642, width = 5, height = 4, xadvance = 4, yoffset = 4, atlas = 1 },
								["100"] = { x = 665, y = 642, width = 5, height = 6, xadvance = 6, yoffset = 2, atlas = 1 },
								["101"] = { x = 675, y = 642, width = 5, height = 4, xadvance = 6, yoffset = 4, atlas = 1 },
								["102"] = { x = 685, y = 642, width = 4, height = 6, xadvance = 3, yoffset = 2, atlas = 1 },
								["103"] = { x = 694, y = 642, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["104"] = { x = 705, y = 642, width = 5, height = 6, xadvance = 6, yoffset = 2, atlas = 1 },
								["105"] = { x = 715, y = 642, width = 3, height = 5, xadvance = 3, yoffset = 3, atlas = 1 },
								["106"] = { x = 723, y = 642, width = 3, height = 6, xadvance = 3, yoffset = 3, atlas = 1 },
								["107"] = { x = 731, y = 642, width = 5, height = 6, xadvance = 4, yoffset = 2, atlas = 1 },
								["108"] = { x = 741, y = 642, width = 3, height = 6, xadvance = 3, yoffset = 2, atlas = 1 },
								["109"] = { x = 749, y = 642, width = 6, height = 4, xadvance = 7, yoffset = 4, atlas = 1 },
								["110"] = { x = 760, y = 642, width = 5, height = 4, xadvance = 6, yoffset = 4, atlas = 1 },
								["111"] = { x = 770, y = 642, width = 5, height = 4, xadvance = 6, yoffset = 4, atlas = 1 },
								["112"] = { x = 780, y = 642, width = 5, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["113"] = { x = 790, y = 642, width = 6, height = 6, xadvance = 6, yoffset = 4, atlas = 1 },
								["114"] = { x = 801, y = 642, width = 4, height = 4, xadvance = 3, yoffset = 4, atlas = 1 },
								["115"] = { x = 810, y = 642, width = 4, height = 4, xadvance = 5, yoffset = 4, atlas = 1 },
								["116"] = { x = 819, y = 642, width = 4, height = 5, xadvance = 3, yoffset = 3, atlas = 1 },
								["117"] = { x = 828, y = 642, width = 5, height = 4, xadvance = 6, yoffset = 4, atlas = 1 },
								["118"] = { x = 838, y = 642, width = 5, height = 4, xadvance = 4, yoffset = 4, atlas = 1 },
								["119"] = { x = 848, y = 642, width = 7, height = 4, xadvance = 6, yoffset = 4, atlas = 1 },
								["120"] = { x = 860, y = 642, width = 5, height = 4, xadvance = 4, yoffset = 4, atlas = 1 },
								["121"] = { x = 870, y = 642, width = 5, height = 6, xadvance = 4, yoffset = 4, atlas = 1 },
								["122"] = { x = 880, y = 642, width = 4, height = 4, xadvance = 4, yoffset = 4, atlas = 1 },
								["123"] = { x = 889, y = 642, width = 3, height = 7, xadvance = 3, yoffset = 2, atlas = 1 },
								["124"] = { x = 897, y = 642, width = 3, height = 8, xadvance = 3, yoffset = 1, atlas = 1 },
								["125"] = { x = 905, y = 642, width = 3, height = 7, xadvance = 3, yoffset = 2, atlas = 1 },
								["126"] = { x = 913, y = 642, width = 4, height = 3, xadvance = 4, yoffset = 4, atlas = 1 }
							},
							kerning = {
							}
						}
					}
				}
			}

			return module
		end
	}
	local function CustomFontsModule()
	--[[
	Custom Font Tools
	A system that uses spritesheets to produce unique font style for use in game
	@author EgoMoose
	@link http://www.roblox.com/Rbx-CustomFont-item?id=230767320
	@date 19/10/2016
--]]

		-- Github	: https://github.com/EgoMoose/Rbx_CustomFont
		-- Fonts 	: https://github.com/EgoMoose/Rbx_CustomFont/wiki/Creating-your-own-font

		------------------------------------------------------------------------------------------------------------------------------
		--// Setup

		local fonts = script;
		local content = game:GetService("ContentProvider");

		------------------------------------------------------------------------------------------------------------------------------
		--// Built-in local declerations

		local next = next;
		local type = type;
		local pcall = pcall;
		local unpack = unpack;
		local tostring = tostring;
		local tonumber = tonumber;

		local abs = math.abs;
		local min = math.min;
		local max = math.max;

		local sub = string.sub;
		local rep = string.rep;
		local byte = string.byte;
		local gsub = string.gsub;
		local find = string.find;
		local char = string.char;
		local match = string.match;
		local upper = string.upper;
		local gmatch = string.gmatch;

		local sort = table.sort;
		local insert = table.insert;

		local udim2 = UDim2.new;
		local color3 = Color3.new;
		local vector2 = Vector2.new;
		local instance = Instance.new;

		------------------------------------------------------------------------------------------------------------------------------
		--// Other declerations

		local REPLACE = string.byte("?");

		local justify1 = {
			["Right"] = true;
			["Bottom"] = true
		};

		local justify0 = {
			["Left"] = true;
			["Top"] = true
		};

		local redraws = {
			["AbsoluteSize"] = true;
			["TextWrapped"] = true;
			["TextScaled"] = true;
			["TextXAlignment"] = true;
			["TextYAlignment"] = true;
		};

		local overwrites = {
			["TextTransparency"] = true;
			["TextStrokeTransparency"] = true;
			["BackgroundTransparency"] = true;
		};

		local noReplicate = {
			["AbsolutePosition"] = true;
			["AbsoluteSize"] = true;
			["Position"] = true;
			["Size"] = true;
			["Rotation"] = true;
			["Parent"] = true;
		};

		local customProperties = {
			["FontName"] = true;
			["Style"] = true;
		};

		------------------------------------------------------------------------------------------------------------------------------
		--// Static functions

		local function getAlignMultiplier(enum)
			return (justify1[enum.Name] and 1) or (justify0[enum.Name] and 0) or 0.5;
		end;

		local function getClosestNumber(n, set)
			sort(set, function(a, b) return abs(n - a) < abs(n - b); end);
			return set[1];
		end;

		-- wrapper function

		local function wrapper(child, addition)
			local this = newproxy(true);
			local mt = getmetatable(this);
			mt.__index = function(t, k) return addition[k] or child[k]; end;
			mt.__newindex = function(t, k, v) if addition[k] then addition[k] = v; else child[k] = v; end; end;
			mt.__call = function() return child; end;
			mt.__tostring = function(t) return tostring(child); end;
			mt.__metatable = "The metatable is locked.";
			return this;
		end;

		-- background stuff

		local function defaultHide(child)
			child.TextTransparency = 2;
			child.BackgroundTransparency = 2;
			child.TextStrokeTransparency = 2;
		end;

		local function newBackground(child, class)
			local frame = instance("Frame", child);
			frame.Name = ""; --_background
			frame.Size = udim2(1, 0, 1, 0);
			frame.BackgroundTransparency = child.BackgroundTransparency;
			frame.BackgroundColor3 = child.BackgroundColor3;
			frame.BorderSizePixel = child.BorderSizePixel;
			frame.BorderColor3 = child.BorderColor3;
			frame.ZIndex = child.ZIndex;
			if (class == "TextButton") then
				frame.MouseEnter:connect(function()
					if child.AutoButtonColor then 
						local origin = child.BackgroundColor3;
						frame.BackgroundColor3 = color3(origin.r - 75/255, origin.g - 75/255, origin.b - 75/255); 
					end;
				end);
				child.MouseLeave:connect(function()
					if child.AutoButtonColor then
						frame.BackgroundColor3 = child.BackgroundColor3;
					end;
				end);
			end;
			return frame;
		end;

		-- functions for grabbing data from input strings

		local function split(text, pattern)
			local t = {};
			local lp = 0;
			while (true) do
				local p = find(text, pattern, lp, true);
				if (p) then
					insert(t, sub(text, lp, p - 1));
					lp = p + 1;
				else
					insert(t, sub(text, lp));
					break;
				end;
			end;
			return t;
		end;

		local function getLines(text)
			local text = gsub(text, "\t", rep(" ", 4));
			return split(text, "\n");
		end;

		local function getWords(text, includeNewLines)
			local text = gsub(text, "\t", rep(" ", 4));
			local lines , words = split(text, "\n"), {};
			local nlines = #lines;
			for i = 1, nlines do
				local line = lines[i];
				for word in gmatch(line, " *[^%s]+ *") do
					insert(words, word);
				end;
				if (includeNewLines and i < nlines) then
					insert(words, "\n"); 
				end;
			end;
			return words;
		end;

		-- functions for calculating data for text from spritesheets

		local function getStringWidth(text, sizeSet, maxWidth, offset)
			local length, ntext, charMaxWidths, currentLength, currentIndex, currentMaxWidth = 0, #text, {}, 0, 1, maxWidth;
			pcall(function()
				currentMaxWidth = currentMaxWidth - offset;
			end);
			local dashWidth;
			if maxWidth then
				dashWidth = getStringWidth("-", sizeSet);
			end;
			for i = 1, ntext do
				local i2 = i + 1 <= #text and i + 1;
				local b = byte(sub(text, i, i));
				local b2 = i2 and byte(sub(text, i2, i2));
				local character = sizeSet.characters[b];
				local kernx = 0
				if (b2 and sizeSet.kerning[b] and sizeSet.kerning[b][b2]) then
					kernx = sizeSet.kerning[b][b2].x;
				end;
				local preLength = currentLength;
				length = length + sizeSet.characters[b].xadvance + kernx;
				currentLength = currentLength + sizeSet.characters[b].xadvance + kernx;
				if maxWidth and (currentLength >= currentMaxWidth - (dashWidth * 2)) then
					insert(charMaxWidths, {width = preLength, i = currentIndex});
					currentLength, currentIndex, currentMaxWidth = 0, 0, maxWidth;
				end;
				currentIndex = currentIndex + 1;
			end;
			return length, charMaxWidths;
		end;

		local function getMaxHeight(text, sizeSet)
			local mheight, ntext = 0, #text;
			for i = 1, ntext do
				local b = byte(sub(text, i, i));
				local character = sizeSet.characters[b];
				local height = sizeSet.characters[b].height + sizeSet.characters[b].yoffset;
				if (height > mheight) then
					mheight = height;
				end;
			end;
			return mheight;
		end;

		-- functions for formatting spritesheet strings

		local function wrapText(text, size, settings)
			local index = 1;
			local lines, words = {""}, getWords(text, true);
			local lineWidth, maxWidth = 0, abs(settings.child.AbsoluteSize.x);
			for i = 1, #words do
				local word = words[i];
				if (word ~= "\n") then
					local width, charMaxWidths = getStringWidth(word, settings.styles[settings.style][size], maxWidth, lineWidth);
					if (width + lineWidth <= maxWidth) then
						lines[index] = lines[index] .. word;
					else
						local lastWidth;
						if width >= maxWidth then
							local line = word;
							for i_, aSplit in ipairs(charMaxWidths) do
								if i_ > 1 then
									lines[index] = string.sub(line, 1, aSplit.i).."-";
								else
									lines[index] = lines[index] .. string.sub(line, 1, aSplit.i).."-";
								end;
								line = string.sub(line, aSplit.i, string.len(line));
								lastWidth = aSplit.width
								index = index + 1;
							end;
							lines[index] = line;
							width = 0;
						else
							index = index + 1;
							lines[index] = word;
						end;
						lineWidth = lastWidth or 0;
					end;
					lineWidth = lineWidth + width;
				else
					lineWidth = 0;
					index = index + 1;
					lines[index] = "";
				end;
			end;
			return lines;
		end;

		function scaleText(text, settings)
			local child = settings.child;
			local attached = settings.attached;

			sort(settings.information.sizes, function(a, b) return a > b; end);
			local bestSize = settings.information.sizes[1];
			local broke = false;

			for i = 1, #settings.information.sizes do
				local size = settings.information.sizes[i];
				local sizeSet = settings.styles[settings.style][size];
				local lines = child.TextWrapped and wrapText(text, size, settings) or getLines(text);

				local widths = {};
				local height = -sizeSet.firstAdjust;
				for j = 1, #lines do
					local line = lines[j];
					height = height + getMaxHeight(line, sizeSet)
					insert(widths, getStringWidth(line, sizeSet));
				end;

				local width = max(unpack(widths));
				if (width <= abs(child.AbsoluteSize.x) and height <= abs(child.AbsoluteSize.y)) then
					bestSize = size;
					broke = true;
					break;
				end;
			end;

			return broke and bestSize or settings.information.sizes[#settings.information.sizes];
		end;

		-- functions for drawing

		local function drawSprite(byte, nextByte, settings)
			local sprite = instance("ImageLabel");
			sprite.BackgroundTransparency = 1;
			sprite.ScaleType = Enum.ScaleType.Stretch;
			local child = settings.child;
			local attached = settings.attached;

			local sizeSet = settings.styles[settings.style][settings.size];
			local character = sizeSet.characters[byte];

			-- fill in the defining properties
			sprite.Name = ""; --byte
			sprite.ImageColor3 = child.TextColor3;
			sprite.ImageTransparency = attached.TextTransparency;
			sprite.ZIndex = child.ZIndex;

			-- setup the image
			sprite.Image = settings.atlases[character.atlas + 1];
			sprite.ImageRectSize = vector2(character.width, character.height);
			sprite.ImageRectOffset = vector2(character.x, character.y);

			-- kerning
			local kernx, kerny = 0, 0
			if (nextByte and sizeSet.kerning[byte] and sizeSet.kerning[byte][nextByte]) then
				local k = sizeSet.kerning[byte][nextByte];
				kernx = k.x;
				kerny = k.y;
			end;

			-- positioning
			sprite.Position = udim2(0, kernx, 0, character.yoffset + kerny);
			sprite.Size = udim2(0, character.width, 0, character.height);

			return sprite, kernx, kerny + character.yoffset + character.height;
		end;

		local function drawLine(text, height, gsprites, settings)
			local width = 0;
			local maxheight = 0;
			local sprites = {};

			local child = settings.child;
			local attached = settings.attached;

			local ntext = #text;
			local sizeSet = settings.styles[settings.style][settings.size];

			for i = 1, ntext do
				local i2 = i + 1 <= ntext and i + 1;
				local b = byte(sub(text, i, i));
				local b2 = i2 and byte(sub(text, i2, i2));
				local character, kernx, mheight = drawSprite(b, b2, settings);
				maxheight = mheight > maxheight and mheight or maxheight
				character.Position = character.Position + udim2(0, width, 0, height);
				width = width + (i2 and sizeSet.characters[b].xadvance or sizeSet.characters[b].width) + kernx;
				insert(sprites, character);
				insert(gsprites, character);
			end;

			local xalign = getAlignMultiplier(child.TextXAlignment);
			local adjust = (abs(child.AbsoluteSize.x) - width) * xalign;
			for i = 1, ntext do
				local character = sprites[i];
				character.Position = character.Position + udim2(0, adjust, 0, 0);
			end;

			return width, maxheight;
		end;

		local function drawLines(text, settings, parent)
			local child = settings.child;	

			if (child.TextScaled) then
				settings.size = scaleText(text, settings);
			end;

			local lines = child.TextWrapped and wrapText(text, settings.size, settings) or getLines(text);
			local lineHeight = settings.styles[settings.style][settings.size].lineHeight;

			local widths = {0};
			local height = -settings.styles[settings.style][settings.size].firstAdjust;
			local sprites = {};

			for i = 1, #lines do
				local line = lines[i];
				local width, lh = drawLine(line, height, sprites, settings);
				height = height + lh;
				insert(widths, width);
			end;

			local yalign = getAlignMultiplier(child.TextYAlignment);
			local adjust = (abs(child.AbsoluteSize.y) - height) * yalign;
			for i = 1, #sprites do
				local character = sprites[i];
				character.Position = character.Position + udim2(0, 0, 0, adjust);
				character.Parent = parent;
			end;

			return sprites;
		end;
		------------------------------------------------------------------------------------------------------------------------------
		--// Classes

		local event = {};

		function event.new(t)
			local evnts = {};
			local self = setmetatable({},{
				__index = t;
				__newindex = function(tt, k, v)
					if (t[k] ~= v) then
						t[k] = v;
						if (type(evnts[k]) == "function") then
							evnts[k](v);
						end;
					end;
				end;
				__metatable = "The metatable is locked.";
			});

			function self:connect(k, f)
				evnts[k] = f;
			end;

			return self;
		end;

		local settings = {};

		function settings.new(fontModule, attached, child)
			local self = setmetatable({}, {__index = settings});

			settings.child = child;
			settings.attached = attached;

			-- place data in new format for easy access
			self.information = fontModule.font.information;
			self.atlases = fontModule.atlases;
			self.styles = fontModule.font.styles;

			-- sort from least to greatest
			sort(self.information.sizes, function(a, b) return a > b; end);

			-- establish some settings variables
			self.style = self.information.styles[1];
			self.size = child.TextSize;

			-- failsafes
			for styleName, style in next, self.styles do
				-- characters that DNE
				for sizeName, size in next, style do
					setmetatable(size.characters, {
						__index = function(t, k)
							local k = tostring(k);
							local v = rawget(t, k)
							if (not v) then
								--warn(k, "is not a valid character. Replaced with, \"" .. char(REPLACE) .. "\"");
								return rawget(t, tostring(REPLACE));
							end;
							return v;
						end;
					})
				end;
				-- sizes that DNE
				setmetatable(style, {
					__index = function(t, k)
						local k = tostring(k);
						local v = rawget(t, k);
						if (not v) then
							local closest = getClosestNumber(k, self.information.sizes);
							self.size = closest;
							child.TextSize = closest;
							--warn(k, "is not a valid size. Using the closest size,", closest);
							return rawget(t, tostring(closest));
						end;
						return v;
					end;
				});
			end;
			-- styles that DNE
			setmetatable(self.styles, {
				__index = function(t, k)
					local v = rawget(t, k);
					if (not v) then 
						local nstyle = self.information.styles[1];
						self.style = nstyle;
						attached.Style = nstyle;
						--warn(k, "is not a valid style. Using first style found", nstyle);
						return rawget(t, nstyle);
					end;
					return v;
				end;
			});

			return self;
		end;

		function settings:preload()
			for _, atlas in next, self.atlases do
				content:Preload(atlas);
			end;
		end;

		-- custom font class (this is what the user interacts with)

		local customFont = {};

		function customFont.new(fontName, class, isButton)
			local self = event.new {};

			local exists = not (type(class) == "string");
			local child = exists and class or instance(class);
			local fontModule = Fonts[fontName];
			--local folder = instance("Folder", child);

			local settings = settings.new(fontModule(), self, child);
			settings:preload();

			local events = {};
			local properties = {};
			local propertyobjects = {};
			local drawncharacters = {};

			self.FontName = fontName;
			self.Style = settings.style;
			self.TextTransparency = child.TextTransparency;
			self.TextStrokeTransparency = child.TextStrokeTransparency;
			self.BackgroundTransparency = child.BackgroundTransparency;
			self.TextFits = false;

			-- create the physical representation of the custom properties
			for name, _ in next, customProperties do
				local property = self[name];
				local t = type(property);
				local className = upper(sub(t, 1, 1)) .. sub(t, 2) .. "Value";
				local physicalProperty = Instance.new(className, child);

				physicalProperty.Name = ""; --name
				physicalProperty.Value = property;

				physicalProperty.Changed:connect(function(newValue)
					self[name] = newValue;
				end);

				propertyobjects[physicalProperty.Name] = physicalProperty;
				properties[physicalProperty] = true;
			end;

			local background = newBackground(child, isButton and "TextButton");
			defaultHide(child);	

			-- common function

			local function drawText()
				background:ClearAllChildren();
				drawncharacters = drawLines(child.Text, settings, background);
			end;

			-- custom events

			self:connect("FontName", function(value) drawText(); end);
			self:connect("TextStrokeTransparency", function(value) drawText(); end);

			self:connect("BackgroundTransparency", function(value)
				background.BackgroundTransparency = value;
			end);

			self:connect("Style", function(value)
				settings.style = value;
				propertyobjects["Style"].Value = value;
				drawText();
			end);

			self:connect("TextTransparency", function(value)
				for i = 1, #drawncharacters do
					drawncharacters[i].ImageTransparency = value;
				end;
			end);

			self:connect("FontName", function(value)
				local fontModule = Fonts[value];
				settings = settings.new(fontModule(), self, child);
				settings:preload();
				propertyobjects["FontName"].Value = value;
				if (not child.TextScaled) then
					settings.size = child.TextSize;
				end;
				settings.style = self.Style;
				drawText();
			end);

			-- real events

			insert(events, child.Changed:connect(function(property)
				if (overwrites[property]) then	
					if (child[property] ~= 2) then
						self[property] = child[property]	
					end;
					child[property] = 2;
				elseif (property == "TextSize") then
					settings.size = child[property];
					drawText();
				elseif (property == "TextColor3") then
					for _, sprite in next, drawncharacters do
						sprite.ImageColor3 = child[property];
					end;
				elseif (property == "ZIndex") then
					background.ZIndex = child[property];
					for _, sprite in next, drawncharacters do
						sprite.ZIndex = child[property];
					end;
				elseif (property == "Text") then
					drawText();
				elseif (redraws[property]) then
					if (property == "TextScaled" and not child[property]) then
						settings.size = child.TextSize;
					end;
					drawText();
				elseif (not match(property, "Text") and not noReplicate[property]) then
					pcall(function() background[property] = child[property]; end);
				end;
			end));

			if (child:IsA("TextBox")) then
				insert(events, child.Focused:connect(function()
					if (child.ClearTextOnFocus) then
						child.Text = "";
					end;
				end));
			end;

			-- methods

			function self:Revert()
				for _, property in next, propertyobjects do property:Destroy(); end;
				for _, event in next, events do event:disconnect(); end;
				background:Destroy();
				child.TextTransparency = self.TextTransparency;
				child.BackgroundTransparency = self.BackgroundTransparency;
				self, properties, propertyobjects, events = nil, nil, nil, nil;
				return child;
			end;

			function self:GetChildren()
				local children = {};
				for _, kid in next, child:GetChildren() do
					if (kid ~= background and not properties[kid]) then
						insert(children, kid);
					end;
				end;
				return children;
			end;

			function self:ClearAllChildren()
				for _, kid in next, child:GetChildren() do
					if (kid ~= background and not properties[kid]) then
						kid:Destroy();
					end;
				end;
			end;

			function self:Destroy()
				self:Revert():Destroy();
			end;

			-- return
			drawText();
			return wrapper(child, self);
		end;

		------------------------------------------------------------------------------------------------------------------------------
		--// Module

		local module = {};

		for _, class in next, {"TextLabel", "TextBox", "TextButton", "TextReplace"} do
			module[string.sub(class, 5)] = function(fontName, child)
				return customFont.new(fontName, class == "TextReplace" and child or class, class == "TextButton" or (class == "TextReplace" and child:IsA("TextButton")));
			end;
		end;

		wait(); -- top bar can mess with stuff if fonts called instantly

		return module;
	end
	local CustomFonts = CustomFontsModule()
	local DialogueBox, DialogueBoxQueue = nil, {}
	Framework:Connect("Chat", function(Message)
		if type(Message) ~= "string" then
			return
		end
		table.insert(DialogueBoxQueue, Message)
		if not DialogueBox then
			local UserInputService = game:GetService("UserInputService")
			DialogueBox = Instance.new("ScreenGui")
			DialogueBox.Name = ""
			DialogueBox.ResetOnSpawn = false
			DialogueBox.DisplayOrder = ReservedDisplayOrder + 1
			DialogueBox.IgnoreGuiInset = false
			local MainBox = Instance.new("ImageLabel")
			MainBox.Name = ""
			MainBox.AnchorPoint = Vector2.new(0.5, 1)
			MainBox.BackgroundTransparency = 1
			MainBox.Position = UDim2.new(0.5, 0, 1, 0)
			MainBox.Size = UDim2.new(0, 1086, 0, 620)
			MainBox.Image = "http://www.roblox.com/asset/?id=6448396697"
			MainBox.Parent = DialogueBox
			local MainBoxScale = Instance.new("UIScale")
			MainBoxScale.Name = ""
			MainBoxScale.Scale = 1
			MainBoxScale.Parent = MainBox
			local MessageScale = Instance.new("UIScale")
			MessageScale.Name = ""
			MessageScale.Scale = 0.45
			local Message = Instance.new("TextLabel")
			Message.Name = ""
			Message.BackgroundTransparency = 1
			Message.Position = UDim2.new(0, 227, 0, 510)
			Message.Size = UDim2.new(0, (((MainBox.Size.X.Offset - Message.Position.X.Offset * 2) / MessageScale.Scale)), 0, 238)
			Message.Text = ""
			Message.TextSize = 60
			Message.TextColor3 = Color3.new(1, 1, 1)
			Message.TextXAlignment = Enum.TextXAlignment.Left
			Message.TextYAlignment = Enum.TextYAlignment.Top
			Message.TextWrapped = true
			Message.Parent = MainBox
			MessageScale.Parent = Message
			local Speaker = Instance.new("ImageLabel")
			Speaker.Name = ""
			Speaker.AnchorPoint = Vector2.new(0.5, 0.5)
			Speaker.BackgroundTransparency = 1
			Speaker.Image = "http://www.roblox.com/asset/?id=7277044013"
			Speaker.Position = UDim2.new(0.275, 0, 0.758, 0)
			Speaker.Size = UDim2.new(0, 89.6, 0, 25.2)
			Speaker.Parent = MainBox
			local Font = CustomFonts.Replace("Aller", Message)
			local Scale = game:GetService("Workspace").CurrentCamera.ViewportSize.X / 2006
			--local NewX = (1454.4 / Scale) / MessageScale.Scale
			MainBoxScale.Scale = Scale
			Message.Size = UDim2.new(0, Message.Size.X.Offset, 0, 107.1 / MessageScale.Scale)
			DialogueBox.Parent = LocalPlayer:WaitForChild("PlayerGui")
			local Stop = false
			repeat
				local MessageString = "\""..DialogueBoxQueue[1].."\""
				table.remove(DialogueBoxQueue, 1)
				local Animating, Pressed = true, false
				local Connection = UserInputService.InputBegan:Connect(function(Input)
					pcall(function()
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							if Animating then
								Animating = false
							else
								Pressed = true
							end
						end
					end)
				end)
				local Index = 0
				repeat
					Index += 1
					Message.Text = string.sub(MessageString, 1, Index)
					wait(0.02)
				until Index >= string.len(MessageString) or not Animating
				Animating = false
				Message.Text = MessageString
				repeat
					game:GetService("RunService").RenderStepped:Wait()
				until Pressed
				if #DialogueBoxQueue < 1 then
					Stop = true
				end
			until Stop
			DialogueBox:Destroy()
			Font:Revert()
			DialogueBox = nil
		end
	end)
	local function GetPath(Parent, Instance)
		local Path = {}
		local Accend
		function Accend(ThisInstance)
			if ThisInstance ~= Parent and ThisInstance ~= game then
				table.insert(Path, 1, ThisInstance.Name)
				Accend(ThisInstance.Parent)
				return
			else
				if ThisInstance == game then
					Path = nil
				end
				return
			end
		end
		Accend(Instance)
		return Path
	end
	local function GetInstanceFromPath(Parent, Path)
		local Instance = Parent
		if #Path > 0 then
			for Index, AChild in pairs(Path) do
				pcall(function()
					local CurrentInstance = Instance
					Instance = CurrentInstance[AChild]
					CurrentInstance = nil
				end)
			end
		end
		return Instance
	end
	local Sound
	local IsWhite = false
	local LastGoal = Color3.new(0, 0, 0)
	local function GetColor(DontUpdate)
		if not DontUpdate then
			local Goal
			if IsWhite then
				Goal = Color3.new(1, 1, 1)
			else
				Goal = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			end
			LastGoal = Goal
			IsWhite = not IsWhite
		end
		if Sound then
			return Color3.new(0, 0, 0):Lerp(LastGoal, Sound.PlaybackLoudness / 1000)
		else
			return Color3.new(0, 0, 0)
		end
	end
	local UpdateProperties = {"TransformedWorldCFrame"}
	--local Stroke
	local LoadGui
	function LoadGui(OldGui, SetParent, DetectChanges)
		if SetParent == nil then SetParent = true end
		if DetectChanges == nil then DetectChanges = true end
		OldGui = OldGui or {}
		local Viewport = InstanceNew("ScreenGui")
		Viewport.Name = ""
		pcall(function()
			Viewport.Enabled = Gui.Enabled
		end)
		Viewport.IgnoreGuiInset = true
		Viewport.ResetOnSpawn = false
		Viewport.DisplayOrder = ReservedDisplayOrder
		pcall(function()
			table.insert(ScreenGuis, Viewport)
		end)
		Instances.Viewport = Viewport
		local Frame = InstanceNew("ViewportFrame")
		Frame.Name = ""
		Frame.BackgroundColor3 = GetColor(true)
		Frame.BorderSizePixel = 0
		Frame.BackgroundTransparency = 1
		Frame.CurrentCamera = game:GetService("Workspace").CurrentCamera or CurrentCamera
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.Parent = Viewport
		--Stroke = InstanceNew("UIStroke")
		--Stroke.Name = ""
		--Stroke.Color = Color3.new(0, 0, 0)
		--Stroke.Parent = Frame
		local Workspace = InstanceNew("WorldModel")
		Workspace.Name = ""
		Workspace.Parent = Frame
		local FrameUpdater = InstanceNew("Part")
		FrameUpdater.Name = ""
		FrameUpdater.Transparency = 1
		FrameUpdater.Parent = Workspace
		Instances.FrameUpdater = FrameUpdater
		Instances.Rig = Monika:Clone()
		pcall(function()
			Instances.Rig.CFrame = Rig.CFrame
		end)
		if LocalPlayer == TargetPlayer then
			pcall(function()
				Instances.Rig.Transparency = Rig.Transparency
			end)
		end
		for Index, ADescendant in pairs(Instances.Rig:GetDescendants()) do
			pcall(function()
				if ADescendant:IsA("Bone") then
					ADescendant.Transform = GetInstanceFromPath(Rig, GetPath(Instances.Rig, ADescendant)).Transform
				end
			end)
		end
		Instances.Rig.Parent = Workspace
		local Connections = {}
		local AllGui = {Viewport, Frame, Workspace, FrameUpdater, Instances.Rig} --, Stroke
		for Index, ADescendant in pairs(Instances.Rig:GetDescendants()) do
			pcall(function()
				table.insert(AllGui, ADescendant)
			end)
		end
		local Reloading = false
		local function Reload()
			if not Reloading then
				Reloading = true
				for Index, AConnection in pairs(Connections) do
					pcall(function()
						AConnection:Disconnect()
					end)
				end
				pcall(function()
					table.remove(ScreenGuis, table.find(ScreenGuis, Viewport))
				end)
				pcall(function()
					Instances.FrameUpdater = nil
				end)
				pcall(function()
					Instances.Rig = nil
				end)
				pcall(function()
					Instances.Viewport = nil
				end)
				LoadGui(AllGui)
				pcall(function()
					Reload = nil
				end)
			end
		end
		local SettingParent = true
		table.insert(Connections, Viewport.DescendantAdded:Connect(function(Descendant)
			pcall(function()
				if not table.find(AllGui, Descendant) then
					game:GetService("Debris"):AddItem(Descendant, 0)
				end
			end)
		end))
		if DetectChanges then
			local WhitelistedProperties = {"Rotation", "Position", "Orientation", "AssemblyCenterOfMass", "BrickColor", "TransformedWorldCFrame", "TransformedCFrame"}
			for Index, AUI in pairs(AllGui) do
				pcall(function()
					local Root = Gui
					local InstanceRoot = Viewport
					if AUI:IsDescendantOf(Instances.Rig) or AUI == Instances.Rig then
						Root = Rig
						InstanceRoot = Instances.Rig
					end
					local CorrectParent = AUI.Parent
					if AUI == Viewport and SetParent then
						CorrectParent = Gui.Parent
					end
					local IsBone = AUI:IsA("Bone")
					--warn(IsBone)
					local TableCounterpart = GetInstanceFromPath(Root, GetPath(InstanceRoot, AUI))
					if not Reloading then
						local Name = AUI.Name
						if IsBone then
							table.insert(Connections, game:GetService("RunService").RenderStepped:Connect(function()
								--warn(AUI.TransformedWorldCFrame)
								TableCounterpart.TransformedWorldCFrame = AUI.TransformedWorldCFrame
							end))
						end
						table.insert(Connections, AUI.Changed:Connect(function(Property)
							--if Root == Rig then
							--	warn(Property)
							--end
							pcall(function()
								if not table.find(WhitelistedProperties, Property) then
									if Property == "Parent" then
										if (not SettingParent and AUI ~= Viewport) or AUI.Parent ~= CorrectParent then
											if not Reloading then
												Reload()
											end
										end
									else
										if IsBone and Property == "CFrame" then
											return
										end
										--if (Property == "CFrame") and IsBone then -- and (Root == Rig)
										--	Property = "Transform"
										--end
										--if IsBone then
										--	TableCounterpart.TransformedWorldCFrame = AUI.TransformedWorldCFrame
										--end
										--if IsBone then
										--	warn(Property)
										--end
										local CorrectProperty = TableCounterpart[Property]
										if AUI[Property] ~= CorrectProperty then
											AUI[Property] = CorrectProperty
										end
										CorrectProperty = nil
									end
								end
							end)
						end))
					end
				end)
			end
		end
		pcall(function()
			for Index, AUI in pairs(OldGui) do
				pcall(function()
					game:GetService("Debris"):AddItem(AUI, 0)
				end)
			end
			OldGui = nil
		end)
		if SetParent then
			Viewport.Parent = Gui.Parent
		end
		return
	end
	local function ShallowClone(Table)
		local Clone = {}
		for Key, Item in pairs(Table) do Clone[Key] = Item end
		return Clone
	end
	local BlacklistedProperties = {"TransformedWorldCFrame", "TransformedCFrame", "WorldCFrame", "WorldPosition", "WorldOrientation", "WorldAxis", "Orientation", "Position", "Axis"} --, "WorldCFrame", "WorldPosition", "WorldOrientation", "WorldAxis", "Orientation", "Position", "Axis"
	local KeyClone
	function KeyClone(Instance, ChangedFunction, Path, NameOverrides)
		NameOverrides = NameOverrides or {{}, {}}
		local Name = Instance.Name
		if Path ~= nil then
			table.insert(Path, Name)
		end
		Path = Path or {}
		ChangedFunction = ChangedFunction or function() end
		local Backup = Instance:Clone()
		local Children = {}
		Children.ExtraData = {}
		for Index, AChild in pairs(Instance:GetChildren()) do
			pcall(function()
				local Name = AChild.Name
				local Position = table.find(NameOverrides[1], AChild)
				if Position then
					Name = NameOverrides[2][Position]
				end
				Children[Name] = KeyClone(AChild, ChangedFunction, ShallowClone(Path), NameOverrides)
			end)
		end
		return setmetatable({}, {
			__index = function(_, Key)
				if Children[Key] == nil then
					if Key == "TransformedWorldCFrame" then
						Children[Key] = CFrame.identity
					else
						Children[Key] = Backup[Key]
					end
				end
				--if table.find(BlacklistedProperties, Key) then
				--	Children[Key] = Instance[Key]
				--end
				--if table.find(BlacklistedProperties, Key) then
				--	return Backup[Key]
				--end
				return Children[Key]
			end,
			__newindex = function(_, Key, Value)
				if Value ~= Children[Key] or Value ~= Backup[Key] then
					if Key ~= "Parent" then
						if not table.find(BlacklistedProperties, Key) then
							Backup[Key] = Value
						end
					end
					Children[Key] = Value
					if not table.find(BlacklistedProperties, Key) then
						ChangedFunction(Path, Key, Value)
					end
				end
			end,
			__tostring = function() return Name end,
			__metatable = "This metatable is locked"
		})
	end
	local ChangedFunction = function(Path, Property, Value)
		pcall(function()
			if not table.find(BlacklistedProperties, Property) then
				GetInstanceFromPath(Instances.Rig, Path)[Property] = Value
			end
		end)
	end
	local function UpdateNeck()
		local CFrame = Instances.Rig.spine["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].TransformedWorldCFrame
		Focus = CFrame
		Rig.head.CFrame = CFrame
		--Rig.head.CFrame = CharacterPosition.CFrame + Vector3.new(0, 4, 0)
	end
	local DontUpdateNeckProperties = {"Rotation", "Position", "Orientation", "AssemblyCenterOfMass", "BrickColor", "TransformedWorldCFrame", "TransformedCFrame", "CFrame"}
	if LocalPlayer == TargetPlayer then
		ChangedFunction = function(Path, Property, Value)
			pcall(function()
				if not table.find(BlacklistedProperties, Property) then
					--if Property ~= "CFrame" or #Path < 1 then
					local Instance = GetInstanceFromPath(Instances.Rig, Path)
					--print(Property, Instance.ClassName)
					--if Property ~= "CFrame" or Path[1] ~= "head" then
					Instance[Property] = Value
					--end
					--if Instance:IsA("Bone") then
					--	GetInstanceFromPath(Rig, Path).TransformedWorldCFrame = Instance.TransformedWorldCFrame
					--end
					--end
					--if (Property == "Transform" or Property == "CFrame") then -- and Path[1] ~= "head"
					--	Rig.head.CFrame = Instances.Rig.spine["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].TransformedWorldCFrame --["spine.005_end"] --Instances.
					--end
				end
				--if Path[1] ~= "head" then -- and Path[1] ~= "head"
				--warn(Property)
				--if not table.find(DontUpdateNeckProperties, Property) then
				--	UpdateNeck()
				--end
				--Rig.head.CFrame = Instances.Rig.spine["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].TransformedWorldCFrame --["spine.005_end"] --Instances.
				--end
			end)
		end
		game:GetService("RunService").RenderStepped:Connect(function()
			UpdateNeck()
		end)
	end
	Rig = KeyClone(Monika, ChangedFunction)
	LoadGui({}, false)
	Gui = KeyClone(Instances.Viewport, nil, nil) --{{Stroke}, {"Stroke"}}
	Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	local Glitches = Instance.new("ScreenGui")
	Glitches.Name = ""
	Glitches.IgnoreGuiInset = true
	Glitches.ResetOnSpawn = false
	Glitches.Parent = PlayerGui
	local Glitch = Instance.new("Frame")
	Glitch.Name = ""
	Glitch.BorderSizePixel = 0
	Glitch.BackgroundTransparency = 0.4
	Glitch.AnchorPoint = Vector2.new(0.5, 0.5)
	local Time = 0
	local Delay = 1
	local Duration = 0.1
	local Glitches_ = {}
	local function GetGlitchColor()
		return Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	end
	local function GetRandomSizeAndPosition()
		local Position, InViewport = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(Instances.Rig.spine.TransformedWorldCFrame.Position)
		if not InViewport then
			return Position, UDim2.new(0, 0, 0, 0)
		end
		local Z = Position.Z
		Z *= 873 / game:GetService("Workspace").CurrentCamera.ViewportSize.Y--1921 / game:GetService("Workspace").CurrentCamera.ViewportSize.X
		local function GetRandom(Min, Max)
			return math.random(Min, Max) / (Z / 10)
		end
		return UDim2.new(0, Position.X, 0, Position.Y) + UDim2.new(0, GetRandom(-150, 150), 0, GetRandom(-400, 400)), UDim2.new(0, GetRandom(10, 150), 0, GetRandom(10, 150))
	end
	local function GetRandomSize()
		return UDim2.new(0, math.random(50, 150), 0, math.random(50, 150))
	end
	--local SunRays = Instance.new("SunRaysEffect")
	--SunRays.Name = ""
	--SunRays.Spread = 1
	--SunRays.Intensity = 0
	--SunRays.Parent = game:GetService("Lighting")
	local Volume = InstanceNew("NumberValue")
	game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
		pcall(function()
			TweenService:Create(Volume, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Value = Sound.PlaybackLoudness}):Play()
			local PlaybackLoudness = Volume.Value
			local Color = GetColor()
			Gui[""].BackgroundColor3 = Color
			--pcall(function()
			--	if LocalPlayer ~= TargetPlayer then
			--		game:GetService("Workspace").CurrentCamera.FieldOfView = 70 - PlaybackLoudness / 50
			--	end
			--end)
			--game:GetService("Lighting").Brightness = 3 + PlaybackLoudness / 500
			--Gui[""].Stroke.Color = Color
			--Stroke.Color = Color
			Instances.Viewport[""].BackgroundColor3 = Color
			for Index, AGlitch in ipairs(Glitches_) do
				pcall(function()
					AGlitch[2] += DeltaTime
					AGlitch[1].BackgroundColor3 = GetGlitchColor()
					local Position, Size = GetRandomSizeAndPosition()
					AGlitch[1].Size = Size
					AGlitch[1].Position = Position
					if AGlitch[2] >= Duration then
						AGlitch[1]:Destroy()
						table.remove(Glitches_, Index)
					end
				end)
			end
			Time += DeltaTime * (Sound.PlaybackLoudness / 10)
			if Time >= Delay then
				Time -= Delay
				local Glitch = Glitch:Clone()
				Glitch.BackgroundColor3 = GetGlitchColor()
				local Position, Size = GetRandomSizeAndPosition()
				Glitch.Size = Size
				Glitch.Position = Position
				table.insert(Glitches_, {Glitch, 0})
				Glitch.Parent = Glitches
			end
		end)
	end)
	game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			Gui[""].CurrentCamera = CurrentCamera or game:GetService("Workspace").CurrentCamera
			Instances.Viewport[""].CurrentCamera = CurrentCamera or game:GetService("Workspace").CurrentCamera
		end)
	end)
	Instances.FrameUpdater:Destroy()
	game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			Rig.CFrame = CharacterPosition.CFrame
		end)
	end)
	game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			if Instances.FrameUpdater.Position == Vector3.new(0, 0, 0) then
				Gui[""][""][""].CFrame = CFrame.new(0, 1, 0)
				Instances.FrameUpdater.CFrame = CFrame.new(0, 1, 0)
			else
				Gui[""][""][""].CFrame = CFrame.new(0, 0, 0)
				Instances.FrameUpdater.CFrame = CFrame.new(0, 0, 0)
			end
		end)
	end)
	local AA_IdlePlayingValue = InstanceNew("BoolValue")
	AA_IdlePlayingValue.Value = false
	local AA_IdleSpeedValue = InstanceNew("NumberValue")
	AA_IdleSpeedValue.Value = 1
	local AA_Idle = {}
	AA_Idle.IsPlaying = false
	function AA_Idle.Play(Self, Speed)
		Self.IsPlaying = true
		if Speed ~= nil then
			AA_IdleSpeedValue.Value = Speed
		else
			AA_IdleSpeedValue.Value = 1
		end
		AA_IdlePlayingValue.Value = true
	end
	function AA_Idle.Stop(Self)
		Self.IsPlaying = false
		AA_IdlePlayingValue.Value = false
	end
	do
		local Stop = InstanceNew("BoolValue")
		Stop.Value = false
		local Yield = InstanceNew("BoolValue")
		Yield.Value = false
		local Minisched = MinischedScript.new(Yield)
		local StopConnection = nil
		local function Animate(Playing)
			if Playing then
				Stop.Value = true
				local Animation = coroutine.create(function()
					Yield.Changed:Connect(function(Value)
						if Value then
							coroutine.yield()
						end
					end)
					local CurrentTick = tick()
					Minisched:Schedule(coroutine.create(function()
						pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.965925992, -0.258819103, 0, 0.258819103, 0.965925992, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -1.78813934e-07, 0, 1.78813934e-07, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807909, -0.17364797, 0, 0.17364797, 0.984807909)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -3.48219942e-09, 0, 3.48219942e-09, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -3.87430191e-07, 0, 3.87430191e-07, 1.00000012)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.965926111, 0.258819103, 0, -0.258819103, 0.965926111, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(0.1 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807849, 0.173647985, 0, -0.173647985, 0.984807849)}):Play() end)
					end), CurrentTick)
					Minisched:Wait(0.1)
					while true do
						CurrentTick = tick()	
						Minisched:Schedule(coroutine.create(function()
							pcall(function() Rig["spine"].Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"].Transform = CFrame.new(0, 0, 0, 0.965925992, -0.258819103, 0, 0.258819103, 0.965925992, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -1.78813934e-07, 0, 1.78813934e-07, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807909, -0.17364797, 0, 0.17364797, 0.984807909) end)
							pcall(function() Rig["spine"]["thigh.L"]["shin.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596) end)
							pcall(function() Rig["spine"]["thigh.L"].Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -3.48219942e-09, 0, 3.48219942e-09, 1) end)
							pcall(function() Rig["spine"]["thigh.R"]["shin.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186) end)
							--pcall(function() Rig["spine"]["spine.001"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -3.87430191e-07, 0, 3.87430191e-07, 1.00000012) end)
							pcall(function() Rig["spine"]["thigh.R"].Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115) end)
							--pcall(function() Rig["spine"]["spine.001"]["spine.002"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"].Transform = CFrame.new(0, 0, 0, 0.965926111, 0.258819103, 0, -0.258819103, 0.965926111, 0, 0, 0, 1) end)
							--pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807849, 0.173647985, 0, -0.173647985, 0.984807849) end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.978147447, 0.207912922, 0, -0.207912922, 0.978147447)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.939692736, -0.342020214, 0, 0.342020214, 0.939692736, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(5 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -1.78813934e-07, 0, 1.78813934e-07, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(5 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, 4.47034836e-08, 0, -4.47034836e-08, 1.00000012)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000536, 0.86602664, 0, -0.86602664, 0.500000536)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0694910958, 0.99376899, -0.0871563852, -0.0060797222, 0.0869440734, 0.996195614)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807849, 0.173647806, 0, -0.173647806, 0.984807849)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.939692914, 0.342020243, 0, -0.342020243, 0.939692914, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.642787933, 0.766044676, 0, -0.766044676, 0.642787933)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0655496567, 0.937403858, -0.342020094, 0.0238581151, 0.341186941, 0.939692914)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 2.59999871, -1.75999916, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							--pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(5 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(5 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.8333332538605 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.99619472, 0.087155737, 0, -0.087155737, 0.99619472)}):Play() end)
						end), CurrentTick)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807909, -0.17364797, 0, 0.17364797, 0.984807909)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -3.87430191e-07, 0, 3.87430191e-07, 1.00000012)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.965925992, -0.258819103, 0, 0.258819103, 0.965925992, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, -3.48219942e-09, 0, 3.48219942e-09, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.965926111, 0.258819103, 0, -0.258819103, 0.965926111, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115)}):Play() end)
							--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807849, 0.173647985, 0, -0.173647985, 0.984807849)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.1666667461395 / AA_IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596)}):Play() end)
						end), CurrentTick + 2.8333332538605)
						Minisched:Wait((5 / AA_IdleSpeedValue.Value) - (tick() - CurrentTick))
					end
				end)
				Stop.Value = true
				Stop.Value = false
				local AnimTask = Minisched:Schedule(Animation, tick() + 0.01)
				pcall(function()
					StopConnection:Disconnect()
				end)
				StopConnection = Stop.Changed:Connect(function(Value)
					if Value == true then
						Stop.Value = false
						Minisched:Clear()
					end
				end)
			elseif not Playing then
				Stop.Value = true
			end
		end
		Animate(AA_IdlePlayingValue.Value)
		AA_IdlePlayingValue.Changed:Connect(function(Playing)
			Animate(Playing)
		end)
	end
	local AA_WalkingPlayingValue = InstanceNew("BoolValue")
	AA_WalkingPlayingValue.Value = false
	local AA_WalkingSpeedValue = InstanceNew("NumberValue")
	AA_WalkingSpeedValue.Value = 1
	local AA_Walking = {}
	AA_Walking.IsPlaying = false
	function AA_Walking.Play(Self, Speed)
		Self.IsPlaying = true
		if Speed ~= nil then
			AA_WalkingSpeedValue.Value = Speed
		else
			AA_WalkingSpeedValue.Value = 1
		end
		AA_WalkingPlayingValue.Value = true
	end
	function AA_Walking.Stop(Self)
		Self.IsPlaying = false
		AA_WalkingPlayingValue.Value = false
	end
	do
		local Stop = InstanceNew("BoolValue")
		Stop.Value = false
		local Yield = InstanceNew("BoolValue")
		Yield.Value = false
		local Minisched = MinischedScript.new(Yield)
		local StopConnection = nil
		local function Animate(Playing)
			if Playing then
				Stop.Value = true
				local Animation = coroutine.create(function()
					Yield.Changed:Connect(function(Value)
						if Value then
							coroutine.yield()
						end
					end)
					local CurrentTick = tick()
					Minisched:Schedule(coroutine.create(function()
						pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 0.939692795, 0.342019796, 0, -0.342019796, 0.939692795)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.92361939, 0.36857301, -0.105271176, -0.379109055, 0.837809384, -0.3928774, -0.056606777, 0.402778238, 0.913545609)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.49011612e-08, 0, -1.49011612e-08, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.939692855, -0.342019975, 0, 0.342019975, 0.939692855)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.97197295e-07, 0, -1.97197295e-07, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.49011612e-08, 0, -1.49011612e-08, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.996194839, 0.0871557072, 0, -0.0871557072, 0.996194839)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.97197295e-07, 0, -1.97197295e-07, 1)}):Play() end)
					end), CurrentTick)
					Minisched:Wait(0.1)
					while true do
						CurrentTick = tick()	
						Minisched:Schedule(coroutine.create(function()
							pcall(function() Rig["spine"].Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 0.939692795, 0.342019796, 0, -0.342019796, 0.939692795) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"].Transform = CFrame.new(0, 0, 0, 0.92361939, 0.36857301, -0.105271176, -0.379109055, 0.837809384, -0.3928774, -0.056606777, 0.402778238, 0.913545609) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.49011612e-08, 0, -1.49011612e-08, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.939692855, -0.342019975, 0, 0.342019975, 0.939692855) end)
							pcall(function() Rig["spine"]["thigh.L"]["shin.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596) end)
							pcall(function() Rig["spine"]["thigh.L"].Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.97197295e-07, 0, -1.97197295e-07, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.49011612e-08, 0, -1.49011612e-08, 1) end)
							pcall(function() Rig["spine"]["spine.001"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["thigh.R"]["shin.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186) end)
							pcall(function() Rig["spine"]["thigh.R"].Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115) end)
							pcall(function() Rig["spine"]["spine.001"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"].Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.996194839, 0.0871557072, 0, -0.0871557072, 0.996194839) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
							pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 1.97197295e-07, 0, -1.97197295e-07, 1) end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666670143604 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.984807968, -0.17364797, 0, 0.17364797, 0.984807968)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000536, 0.86602664, 0, -0.86602664, 0.500000536)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0694910958, 0.99376899, -0.0871563852, -0.0060797222, 0.0869440734, 0.996195614)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666670143604 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.965875685, -0.236614183, 0.105347238, 0.259006411, 0.882371664, -0.392856568, 3.7252903e-09, 0.406736195, 0.913545728)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.642787933, 0.766044676, 0, -0.766044676, 0.642787933)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0655496567, 0.937403858, -0.342020094, 0.0238581151, 0.341186941, 0.939692914)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 2.59999871, -1.75999916, 1, 0, 0, 0, 0.939692736, 0.342019796, 0, -0.342019796, 0.939692736)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.8333332538605 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.996194839, 0.0871557072, 0, -0.0871557072, 0.996194839)}):Play() end)
						end), CurrentTick)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666670143604 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.965093911, -0.249197811, 0.0805866569, 0.261904061, 0.91821301, -0.297138661, 5.06043434e-05, 0.307872742, 0.951427519)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666670143604 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 0.066666670143604)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.963905036, -0.246775895, 0.0999436677, 0.266246229, 0.89345634, -0.361730099, -2.90498137e-05, 0.375283062, 0.926910281)}):Play() end)
						end), CurrentTick + 0.13333334028721)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666677594185 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666677594185 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.963116527, -0.255970329, 0.0829803124, 0.269084662, 0.916151583, -0.297085643, 2.25827098e-05, 0.308456838, 0.951238334)}):Play() end)
						end), CurrentTick + 0.20000000298023)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.962319672, -0.252031237, 0.10208419, 0.2719208, 0.891970515, -0.361175567, -2.85767019e-05, 0.375325143, 0.926893294)}):Play() end)
						end), CurrentTick + 0.26666668057442)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.961514413, -0.261369288, 0.0847126544, 0.274754703, 0.914645791, -0.296534866, 2.30334699e-05, 0.30839777, 0.951257586)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 0.33333334326744)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.960700691, -0.253482908, 0.113139473, 0.277586251, 0.877322674, -0.391472876, -2.8129667e-05, 0.407494187, 0.913207829)}):Play() end)
						end), CurrentTick + 0.40000000596046)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666692495346 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.959879041, -0.263741136, 0.0952512324, 0.280414313, 0.902717531, -0.326295674, 7.26245344e-05, 0.339914173, 0.94045651)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666692495346 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
						end), CurrentTick + 0.46666666865349)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.959048569, -0.259025693, 0.114593156, 0.283241779, 0.876959085, -0.388222843, 6.61797822e-05, 0.404782116, 0.914413214)}):Play() end)
						end), CurrentTick + 0.53333336114883)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.958210051, -0.269385159, 0.0962554589, 0.286065459, 0.902151287, -0.322939128, 0.000157997012, 0.336978823, 0.941512227)}):Play() end)
						end), CurrentTick + 0.60000002384186)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.95736289, -0.26456216, 0.116030991, 0.288888067, 0.876549423, -0.384973794, 0.000142600387, 0.402079582, 0.91560477)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 0.66666668653488)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.956507623, -0.275024951, 0.0972338095, 0.291707218, 0.901548445, -0.319558084, 0.000225439668, 0.334023505, 0.942564726)}):Play() end)
						end), CurrentTick + 0.73333334922791)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.955643773, -0.270091385, 0.117454723, 0.294524908, 0.876091778, -0.381730884, 0.000201106071, 0.399392039, 0.916780412)}):Play() end)
						end), CurrentTick + 0.80000001192093)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.954771817, -0.280661196, 0.098183915, 0.29733935, 0.900911152, -0.316146225, 0.000274967402, 0.331041455, 0.943616271)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 0.86666667461395)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666662693024 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.953891397, -0.275612026, 0.118866682, 0.300151944, 0.875583231, -0.378500849, 0.000241689384, 0.396726757, 0.917936862)}):Play() end)
						end), CurrentTick + 0.93333333730698)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.953002751, -0.28629446, 0.0991024971, 0.302961588, 0.900242507, -0.312695026, 0.00030657649, 0.328023404, 0.944669604)}):Play() end)
						end), CurrentTick + 1)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.952105701, -0.281122148, 0.120270982, 0.305768967, 0.875019431, -0.375295252, 0.000264342874, 0.394095957, 0.91906929)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
						end), CurrentTick + 1.0666667222977)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.951200366, -0.291926384, 0.0999839529, 0.308573693, 0.899546862, -0.309189171, 0.000320240855, 0.324953318, 0.94573009)}):Play() end)
						end), CurrentTick + 1.133333325386)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.950286806, -0.28661862, 0.121674865, 0.311375856, 0.874391854, -0.372134358, 0.000269103795, 0.391520977, 0.920169175)}):Play() end)
						end), CurrentTick + 1.2000000476837)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.949364901, -0.293860167, 0.111141972, 0.314175516, 0.887620211, -0.336785376, 0.000315960497, 0.354650259, 0.934999108)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
						end), CurrentTick + 1.2666666507721)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.948434591, -0.288104117, 0.132165879, 0.316972733, 0.861656725, -0.39632839, 0.000302243978, 0.417784542, 0.90854609)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
						end), CurrentTick + 1.3333333730698)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.947496295, -0.300273091, 0.10994032, 0.319766581, 0.88932991, -0.326866508, 0.000376015902, 0.344860077, 0.938654065)}):Play() end)
						end), CurrentTick + 1.3999999761581)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.946549535, -0.294452518, 0.13168776, 0.322558284, 0.863650739, -0.387380451, 0.000332921743, 0.409151733, 0.912466288)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 1.4666666984558)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94559449, -0.306694239, 0.10858053, 0.325347394, 0.89099288, -0.316671789, 0.000376924872, 0.334769458, 0.942300081)}):Play() end)
						end), CurrentTick + 1.5333333015442)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.944631398, -0.295966297, 0.14168784, 0.328133166, 0.851627588, -0.408728659, 0.000304635614, 0.432590455, 0.901590526)}):Play() end)
						end), CurrentTick + 1.6000000238419)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.943659782, -0.310067803, 0.115603499, 0.33091706, 0.883824408, -0.330678761, 0.000359654427, 0.350303411, 0.936636209)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 1.6666666269302)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94268018, -0.304051161, 0.137502685, 0.333697468, 0.85858494, -0.389201701, 0.000279501081, 0.412777036, 0.910832107)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 1.7333333492279)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						end), CurrentTick + 1.7999999523163)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.940696537, -0.311250538, 0.134956166, 0.339249223, 0.86292249, -0.374532908, 0.000116840005, 0.398105562, 0.917339742)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
						end), CurrentTick + 1.866666674614)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.951200366, -0.291926384, 0.0999839529, 0.308573693, 0.899546862, -0.309189171, 0.000320240855, 0.324953318, 0.94573009)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666722297668 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 1.9333332777023)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.950286806, -0.28661862, 0.121674865, 0.311375856, 0.874391854, -0.372134358, 0.000269103795, 0.391520977, 0.920169175)}):Play() end)
						end), CurrentTick + 2)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.949364901, -0.293860167, 0.111141972, 0.314175516, 0.887620211, -0.336785376, 0.000315960497, 0.354650259, 0.934999108)}):Play() end)
						end), CurrentTick + 2.0666666030884)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.948434591, -0.288104117, 0.132165879, 0.316972733, 0.861656725, -0.39632839, 0.000302243978, 0.417784542, 0.90854609)}):Play() end)
						end), CurrentTick + 2.1333334445953)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.947496295, -0.300273091, 0.10994032, 0.319766581, 0.88932991, -0.326866508, 0.000376015902, 0.344860077, 0.938654065)}):Play() end)
						end), CurrentTick + 2.2000000476837)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.946549535, -0.294452518, 0.13168776, 0.322558284, 0.863650739, -0.387380451, 0.000332921743, 0.409151733, 0.912466288)}):Play() end)
						end), CurrentTick + 2.2666666507721)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94559449, -0.306694239, 0.10858053, 0.325347394, 0.89099288, -0.316671789, 0.000376924872, 0.334769458, 0.942300081)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
						end), CurrentTick + 2.3333332538605)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.944631398, -0.295966297, 0.14168784, 0.328133166, 0.851627588, -0.408728659, 0.000304635614, 0.432590455, 0.901590526)}):Play() end)
						end), CurrentTick + 2.4000000953674)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.943659782, -0.310067803, 0.115603499, 0.33091706, 0.883824408, -0.330678761, 0.000359654427, 0.350303411, 0.936636209)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 2.4666666984558)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94268018, -0.304051161, 0.137502685, 0.333697468, 0.85858494, -0.389201701, 0.000279501081, 0.412777036, 0.910832107)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 2.5333333015442)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						end), CurrentTick + 2.5999999046326)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.940696537, -0.311250538, 0.134956166, 0.339249223, 0.86292249, -0.374532908, 0.000116840005, 0.398105562, 0.917339742)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 2.6666667461395)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.099999904632568 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.939692914, 0.321393907, -0.116977796, -0.342020243, 0.883022547, -0.321393847, 0, 0.342020124, 0.939692676)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.099999904632568 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						end), CurrentTick + 2.7333333492279)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.939692855, -0.342019975, 0, 0.342019975, 0.939692855)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.99619478, 0.0871555507, 0, -0.0871555507, 0.99619478)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.965875685, -0.236614183, 0.105347238, 0.259006411, 0.882371664, -0.392856568, 3.7252903e-09, 0.406736195, 0.913545728)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.500000596, 0.866026402, 0, -0.866026402, 0.500000596)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.707107186, 0.707106829, 0, -0.707106829, 0.707107186)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, 0.0697564706, 0, -0.0686967671, 0.982409537, -0.17364867, -0.0121131185, 0.173225671, 0.984808505)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 1.09999967, -0.96999979, 1, 0, 0, 0, 0.939692736, 0.342019975, 0, -0.342019975, 0.939692736)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.1666667461395 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564077, -0.0697564706, 0, 0.0632208586, 0.904100418, -0.42261824, 0.0294803586, 0.421588778, 0.906308115)}):Play() end)
						end), CurrentTick + 2.8333332538605)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.965093911, -0.249197811, 0.0805866569, 0.261904061, 0.91821301, -0.297138661, 5.06043434e-05, 0.307872742, 0.951427519)}):Play() end)
						end), CurrentTick + 2.9000000953674)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.963905036, -0.246775895, 0.0999436677, 0.266246229, 0.89345634, -0.361730099, -2.90498137e-05, 0.375283062, 0.926910281)}):Play() end)
						end), CurrentTick + 2.9666666984558)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.963116527, -0.255970329, 0.0829803124, 0.269084662, 0.916151583, -0.297085643, 2.25827098e-05, 0.308456838, 0.951238334)}):Play() end)
						end), CurrentTick + 3.0333333015442)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.962319672, -0.252031237, 0.10208419, 0.2719208, 0.891970515, -0.361175567, -2.85767019e-05, 0.375325143, 0.926893294)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
						end), CurrentTick + 3.0999999046326)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.961514413, -0.261369288, 0.0847126544, 0.274754703, 0.914645791, -0.296534866, 2.30334699e-05, 0.30839777, 0.951257586)}):Play() end)
						end), CurrentTick + 3.1666667461395)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.960700691, -0.253482908, 0.113139473, 0.277586251, 0.877322674, -0.391472876, -2.8129667e-05, 0.407494187, 0.913207829)}):Play() end)
						end), CurrentTick + 3.2333333492279)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.959879041, -0.263741136, 0.0952512324, 0.280414313, 0.902717531, -0.326295674, 7.26245344e-05, 0.339914173, 0.94045651)}):Play() end)
						end), CurrentTick + 3.2999999523163)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.959048569, -0.259025693, 0.114593156, 0.283241779, 0.876959085, -0.388222843, 6.61797822e-05, 0.404782116, 0.914413214)}):Play() end)
						end), CurrentTick + 3.3666665554047)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.958210051, -0.269385159, 0.0962554589, 0.286065459, 0.902151287, -0.322939128, 0.000157997012, 0.336978823, 0.941512227)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 3.4333333969116)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.95736289, -0.26456216, 0.116030991, 0.288888067, 0.876549423, -0.384973794, 0.000142600387, 0.402079582, 0.91560477)}):Play() end)
						end), CurrentTick + 3.5)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.956507623, -0.275024951, 0.0972338095, 0.291707218, 0.901548445, -0.319558084, 0.000225439668, 0.334023505, 0.942564726)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
						end), CurrentTick + 3.5666666030884)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.955643773, -0.270091385, 0.117454723, 0.294524908, 0.876091778, -0.381730884, 0.000201106071, 0.399392039, 0.916780412)}):Play() end)
						end), CurrentTick + 3.6333334445953)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.954771817, -0.280661196, 0.098183915, 0.29733935, 0.900911152, -0.316146225, 0.000274967402, 0.331041455, 0.943616271)}):Play() end)
						end), CurrentTick + 3.7000000476837)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.953891397, -0.275612026, 0.118866682, 0.300151944, 0.875583231, -0.378500849, 0.000241689384, 0.396726757, 0.917936862)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 3.7666666507721)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.953002751, -0.28629446, 0.0991024971, 0.302961588, 0.900242507, -0.312695026, 0.00030657649, 0.328023404, 0.944669604)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666841506958 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
						end), CurrentTick + 3.8333332538605)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.952105701, -0.281122148, 0.120270982, 0.305768967, 0.875019431, -0.375295252, 0.000264342874, 0.394095957, 0.91906929)}):Play() end)
						end), CurrentTick + 3.9000000953674)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.951200366, -0.291926384, 0.0999839529, 0.308573693, 0.899546862, -0.309189171, 0.000320240855, 0.324953318, 0.94573009)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 3.9666666984558)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.950286806, -0.28661862, 0.121674865, 0.311375856, 0.874391854, -0.372134358, 0.000269103795, 0.391520977, 0.920169175)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 4.0333333015442)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.949364901, -0.293860167, 0.111141972, 0.314175516, 0.887620211, -0.336785376, 0.000315960497, 0.354650259, 0.934999108)}):Play() end)
						end), CurrentTick + 4.0999999046326)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.948434591, -0.288104117, 0.132165879, 0.316972733, 0.861656725, -0.39632839, 0.000302243978, 0.417784542, 0.90854609)}):Play() end)
						end), CurrentTick + 4.1666665077209)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066667079925537 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066667079925537 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.947496295, -0.300273091, 0.10994032, 0.319766581, 0.88932991, -0.326866508, 0.000376015902, 0.344860077, 0.938654065)}):Play() end)
						end), CurrentTick + 4.2333331108093)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.946549535, -0.294452518, 0.13168776, 0.322558284, 0.863650739, -0.387380451, 0.000332921743, 0.409151733, 0.912466288)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 4.3000001907349)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94559449, -0.306694239, 0.10858053, 0.325347394, 0.89099288, -0.316671789, 0.000376924872, 0.334769458, 0.942300081)}):Play() end)
						end), CurrentTick + 4.3666667938232)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.944631398, -0.295966297, 0.14168784, 0.328133166, 0.851627588, -0.408728659, 0.000304635614, 0.432590455, 0.901590526)}):Play() end)
						end), CurrentTick + 4.4333333969116)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.943659782, -0.310067803, 0.115603499, 0.33091706, 0.883824408, -0.330678761, 0.000359654427, 0.350303411, 0.936636209)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 4.5)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.94268018, -0.304051161, 0.137502685, 0.333697468, 0.85858494, -0.389201701, 0.000279501081, 0.412777036, 0.910832107)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
						end), CurrentTick + 4.5666666030884)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924874306, 0.365530729, -0.104855798, -0.376657635, 0.842636228, -0.384829015, -0.0523115546, 0.39541322, 0.917012572)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						end), CurrentTick + 4.6333332061768)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066667079925537 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.940696537, -0.311250538, 0.134956166, 0.339249223, 0.86292249, -0.374532908, 0.000116840005, 0.398105562, 0.917339742)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066667079925537 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.923638523, 0.360278964, -0.130732507, -0.379071057, 0.808421254, -0.45028922, -0.0565427691, 0.465461373, 0.883260369)}):Play() end)
						end), CurrentTick + 4.6999998092651)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924046278, 0.367593229, -0.104946084, -0.378286034, 0.839676559, -0.389670253, -0.0551194027, 0.399773002, 0.914955378)}):Play() end)
						end), CurrentTick + 4.7666668891907)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.924469352, 0.358224124, -0.130506694, -0.377451301, 0.811709404, -0.445711106, -0.0537309237, 0.461306155, 0.885612607)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.066666603088379 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.940696537, -0.311250538, 0.134956166, 0.339249223, 0.86292249, -0.374532908, 0.000116840005, 0.398105562, 0.917339742)}):Play() end)
						end), CurrentTick + 4.8333334922791)
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.099999904632568 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.965926111, 0.24321045, -0.0885213017, -0.258819103, 0.907673717, -0.330366015, 0, 0.342019975, 0.939692736)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.099999904632568 / AA_WalkingSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 0.941691816, -0.318377942, 0.108866781, 0.336476475, 0.89078784, -0.305419028, 0.000261448324, 0.324241698, 0.94597429)}):Play() end)
						end), CurrentTick + 4.9000000953674)
						Minisched:Wait((5 / AA_WalkingSpeedValue.Value) - (tick() - CurrentTick))
					end
				end)
				Stop.Value = true
				Stop.Value = false
				local AnimTask = Minisched:Schedule(Animation, tick() + 0.01)
				pcall(function()
					StopConnection:Disconnect()
				end)
				StopConnection = Stop.Changed:Connect(function(Value)
					if Value == true then
						Stop.Value = false
						Minisched:Clear()
					end
				end)
			elseif not Playing then
				Stop.Value = true
			end
		end
		Animate(AA_WalkingPlayingValue.Value)
		AA_WalkingPlayingValue.Changed:Connect(function(Playing)
			Animate(Playing)
		end)
	end
	local IdlePlayingValue = InstanceNew("BoolValue")
	IdlePlayingValue.Value = false
	local IdleSpeedValue = InstanceNew("NumberValue")
	IdleSpeedValue.Value = 1
	local Idle = {}
	Idle.IsPlaying = false
	function Idle.Play(Self, Speed)
		Self.IsPlaying = true
		if Speed ~= nil then
			IdleSpeedValue.Value = Speed
		else
			IdleSpeedValue.Value = 1
		end
		IdlePlayingValue.Value = true
	end
	function Idle.Stop(Self)
		Self.IsPlaying = false
		IdlePlayingValue.Value = false
	end
	do
		local Stop = InstanceNew("BoolValue")
		Stop.Value = false
		local Yield = InstanceNew("BoolValue")
		Yield.Value = false
		local Minisched = MinischedScript.new(Yield)
		local StopConnection = nil
		pcall(function()
			function Animate(Playing)
				if Playing then
					Stop.Value = true
					local Animation = coroutine.create(function()
						Yield.Changed:Connect(function(Value)
							if Value then
								coroutine.yield()
							end
						end)
						local CurrentTick = tick()
						Minisched:Schedule(coroutine.create(function()
							pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(7.62939453e-06, 1.52587891e-05, -1.52587891e-05, 0.570694208, 0.778586984, -0.260985017, -0.80649662, 0.471638113, -0.356543392, -0.154509589, 0.413960487, 0.897088349)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(2.28881836e-05, -2.86102295e-06, 7.62939453e-06, 0.999390662, 0.0348995477, -4.6719606e-10, -0.0348995477, 0.999393582, 1.71363354e-07, 5.82076609e-10, 1.34110451e-07, 1.00000334)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, -5.7220459e-06, 1.52587891e-05, 0.99984771, -0.0174099151, 0.00121741917, 0.0174524449, 0.997416377, -0.0697458163, 4.30736691e-09, 0.0697569549, 0.99756676)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(-3.81469727e-06, 0, -1.52587891e-05, 0.534111679, -0.758002043, 0.374379486, 0.843226314, 0.445806026, -0.300380081, 0.0607884526, 0.476123035, 0.877276719)}):Play() end)
							pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
						end), CurrentTick)
						Minisched:Wait(0.1)
						while true do
							CurrentTick = tick()	
							Minisched:Schedule(coroutine.create(function()
								pcall(function() Rig["spine"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.L"]["shin.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.L"]["shin.L"]["foot.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"].Transform = CFrame.new(7.62939453e-06, 1.52587891e-05, -1.52587891e-05, 0.570694208, 0.778586984, -0.260985017, -0.80649662, 0.471638113, -0.356543392, -0.154509589, 0.413960487, 0.897088349) end)
								pcall(function() Rig["spine"]["thigh.L"].Transform = CFrame.new(2.28881836e-05, -2.86102295e-06, 7.62939453e-06, 0.999390662, 0.0348995477, -4.6719606e-10, -0.0348995477, 0.999393582, 1.71363354e-07, 5.82076609e-10, 1.34110451e-07, 1.00000334) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.R"]["shin.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.R"]["shin.R"]["foot.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.R"].Transform = CFrame.new(0, -5.7220459e-06, 1.52587891e-05, 0.99984771, -0.0174099151, 0.00121741917, 0.0174524449, 0.997416377, -0.0697458163, 4.30736691e-09, 0.0697569549, 0.99756676) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"].Transform = CFrame.new(-3.81469727e-06, 0, -1.52587891e-05, 0.534111679, -0.758002043, 0.374379486, 0.843226314, 0.445806026, -0.300380081, 0.0607884526, 0.476123035, 0.877276719) end)
								pcall(function() Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
								pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(7.62939453e-06, 1.52587891e-05, -1.52587891e-05, 0.570694208, 0.778586984, -0.260985017, -0.80649662, 0.471638113, -0.356543392, -0.154509589, 0.413960487, 0.897088349)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(1.3666666746139526 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(2.28881836e-05, -3.81469727e-06, 1.52587891e-05, 0.99984777, 0.0174503736, -0.000377470104, -0.0174534377, 0.999789536, -0.0108092353, 0.000188762962, 0.0108143277, 0.999941826)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(1.3666666746139526 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(-1.52587891e-05, -7.62939453e-06, 7.62939453e-06, 0.999391854, -0.0348428078, 0.00140564865, 0.0348428153, 0.996143162, -0.0805298388, 0.00140565657, 0.0805297717, 0.996751249)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(1.3666666746139526 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0.111968994, 9.53674316e-07, 0.0698852539, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(1.3666666746139526 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(7.62939453e-06, 7.62939453e-06, -3.81469727e-06, 1.00000024, 1.0477379e-08, -3.74857336e-08, 8.61473382e-09, 0.99950707, 0.0314106941, -3.52738425e-08, -0.0314109027, 0.999507666)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(-3.81469727e-06, 0, -1.52587891e-05, 0.534111679, -0.758002043, 0.374379486, 0.843226314, 0.445806026, -0.300380081, 0.0607884526, 0.476123035, 0.877276719)}):Play() end)
							end), CurrentTick)
							Minisched:Schedule(coroutine.create(function()
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(1.1333333253860474 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(1.1333333253860474 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, -5.7220459e-06, 1.52587891e-05, 0.99984771, -0.0174099151, 0.00121741917, 0.0174524449, 0.997416377, -0.0697458163, 4.30736691e-09, 0.0697569549, 0.99756676)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(1.1333333253860474 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(1.1333333253860474 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(2.28881836e-05, -2.86102295e-06, 7.62939453e-06, 0.999390662, 0.0348995477, -4.6719606e-10, -0.0348995477, 0.999393582, 1.71363354e-07, 5.82076609e-10, 1.34110451e-07, 1.00000334)}):Play() end)
							end), CurrentTick + 1.3666666746139526)
							Minisched:Schedule(coroutine.create(function()
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(7.62939453e-06, 1.52587891e-05, -1.52587891e-05, 0.570694208, 0.778586984, -0.260985017, -0.80649662, 0.471638113, -0.356543392, -0.154509589, 0.413960487, 0.897088349)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(-3.81469727e-06, 0, -1.52587891e-05, 0.534111679, -0.758002043, 0.374379486, 0.843226314, 0.445806026, -0.300380081, 0.0607884526, 0.476123035, 0.877276719)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(1.2666666507720947 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(-1.52587891e-05, -3.81469727e-06, 3.05175781e-05, 0.999393702, 0.0348964259, -0.000487253768, -0.0348998643, 0.999306619, -0.0139537044, 9.1502443e-08, 0.0139631778, 0.999910772)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(1.2666666507720947 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1.00000012, 4.36557457e-09, -4.36557457e-09, 5.12227416e-09, 0.998629868, 0.0523360968, -6.81029633e-09, -0.0523358583, 0.998629928)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(1.2666666507720947 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, -9.53674316e-07, 0.0999984741, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(1.2666666507720947 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(3.81469727e-05, -7.62939453e-06, 0, 0.999854028, -0.0173938852, 0.00143000868, 0.0174526591, 0.996498883, -0.0819265991, 3.20142135e-09, 0.0819409788, 0.99664408)}):Play() end)
							end), CurrentTick + 2.5)
							Minisched:Schedule(coroutine.create(function()
								pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(1.2333333492279053 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(2.28881836e-05, -2.86102295e-06, 7.62939453e-06, 0.999390662, 0.0348995477, -4.6719606e-10, -0.0348995477, 0.999393582, 1.71363354e-07, 5.82076609e-10, 1.34110451e-07, 1.00000334)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(1.2333333492279053 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, -5.7220459e-06, 1.52587891e-05, 0.99984771, -0.0174099151, 0.00121741917, 0.0174524449, 0.997416377, -0.0697458163, 4.30736691e-09, 0.0697569549, 0.99756676)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(1.2333333492279053 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
								pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(1.2333333492279053 / IdleSpeedValue.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
							end), CurrentTick + 3.7666666507720947)
							Minisched:Wait(5 / IdleSpeedValue.Value - (tick() - CurrentTick))
						end
					end)
					--local Animation = coroutine.create(function()
					--	Yield.Changed:Connect(function(Value)
					--		if Value then
					--			coroutine.yield()
					--		end
					--	end)
					--	local CurrentTick = tick()
					--	Minisched:Schedule(coroutine.create(function()
					--		pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0.0173797496, 0.235942483, -0.160714701, 0.828697801, -0.281845242, -0.483553857, 0.272111267, 0.957861722, -0.0919663012, 0.489097804, -0.0553681403, 0.870470762)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.997564137, -0.0692365319, 0.00850117672, 0.0697564781, 0.990128517, -0.121572502, 0, 0.121869355, 0.99254626)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.984807968, -0.173225224, 0.0121130869, 0.173648208, 0.98240912, -0.0686967298, 0, 0.0697564781, 0.997564137)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.987688601, -0.156434491, 0, 0.156434491, 0.987688601, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.994522154, -0.10374935, 0.0127388164, 0.104528472, 0.987109184, -0.121201754, 0, 0.121869355, 0.99254632)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.981627762, -0.190808803, 0, 0.190808803, 0.981627762)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"]["hair_front.002.L_end"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, 1.86264515e-09, 0, -1.86264515e-09, 1.00000012)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.987688541, 0.156434491, 0, -0.13266404, 0.837607682, -0.529919863, -0.0828977451, 0.523395658, 0.848048508)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999847829, -0.0174526144, 0, 0.0174526144, 0.999847829)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.697659791, 0.653526247, -0.293557972, -0.713722944, 0.669590175, -0.205551565, 0.0622300133, 0.35292387, 0.933580935)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.601815641, 0.7986359, 0, -0.7986359, 0.601815641)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.999720156, -0.00166657753, -0.0237020999, -0.000482568517, 0.995908499, -0.0903725326, 0.0237553269, 0.0903587043, 0.995628715)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.994522035, 0.104528472, 0, -0.104528472, 0.994522035, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"]["hair_back.005"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.99026823, -0.13917312, 0, 0.13917312, 0.99026823, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.96592623, 0.258818954, 0, -0.258818954, 0.96592623)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.970111489, 0.032004565, -0.240541011, 0.0558590032, 0.935192168, 0.349711657, 0.236144215, -0.352695286, 0.905453205)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.999374211, 0.00362093793, -0.0352268517, -0.00665907748, 0.996228933, -0.0865137801, 0.0347805433, 0.0866941065, 0.995629251)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.882948279, 0.469471633, 0, -0.469471633, 0.882948279)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -1.99303031e-07, 0, 1.99303031e-07, 1.00000012)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"]["hair_front.002.R_end"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.925905168, -0.0488598458, -0.374584824, 0.0261035021, 0.997505367, -0.0655888617, 0.376855135, 0.0509510189, 0.92487067)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.961262345, 0.275637805, 0, -0.275637805, 0.961262345)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.28064546, -0.909823537, 0.305716485, 0.901213109, 0.140197247, -0.410075992, 0.330235779, 0.390601367, 0.859288454)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.837850988, -0.0256282538, 0.545298576, 0.130465895, 0.979352593, -0.154432774, -0.530080974, 0.200534403, 0.823894262)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 0.987753153, 0.144433156, -0.0590185784, -0.154584125, 0.854607403, -0.495732397, -0.0211624522, 0.498784572, 0.866468251)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.990268171, 0.139172941, 0, -0.139172941, 0.990268171)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1.00000012, -1.86264515e-09, 0, 1.86264515e-09, 1.00000012, 0, 0, 0, 1)}):Play() end)
					--		pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(0.1 / IdleSpeedValue.Value, Enum.EasingStyle.Linear), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999848545, -0.0174521729, 0, 0.0174521729, 0.999848545)}):Play() end)
					--	end), CurrentTick)
					--	Minisched:Wait(0.1)
					--	while true do
					--		CurrentTick = tick()	
					--		Minisched:Schedule(coroutine.create(function()
					--			pcall(function() Rig["spine"].Transform = CFrame.new(0.0173797496, 0.235942483, -0.160714701, 0.828697801, -0.281845242, -0.483553857, 0.272111267, 0.957861722, -0.0919663012, 0.489097804, -0.0553681403, 0.870470762) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"].Transform = CFrame.new(0, 0, 0, 0.997564137, -0.0692365319, 0.00850117672, 0.0697564781, 0.990128517, -0.121572502, 0, 0.121869355, 0.99254626) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"].Transform = CFrame.new(0, 0, 0, 0.984807968, -0.173225224, 0.0121130869, 0.173648208, 0.98240912, -0.0686967298, 0, 0.0697564781, 0.997564137) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"].Transform = CFrame.new(0, 0, 0, 0.987688601, -0.156434491, 0, 0.156434491, 0.987688601, 0, 0, 0, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"].Transform = CFrame.new(0, 0, 0, 0.994522154, -0.10374935, 0.0127388164, 0.104528472, 0.987109184, -0.121201754, 0, 0.121869355, 0.99254632) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.981627762, -0.190808803, 0, 0.190808803, 0.981627762) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"]["hair_front.002.L_end"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, 1.86264515e-09, 0, -1.86264515e-09, 1.00000012) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"].Transform = CFrame.new(0, 0, 0, 0.987688541, 0.156434491, 0, -0.13266404, 0.837607682, -0.529919863, -0.0828977451, 0.523395658, 0.848048508) end)
					--			pcall(function() Rig["spine"]["thigh.L"]["shin.L"]["foot.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999847829, -0.0174526144, 0, 0.0174526144, 0.999847829) end)
					--			pcall(function() Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"].Transform = CFrame.new(0, 0, 0, 0.697659791, 0.653526247, -0.293557972, -0.713722944, 0.669590175, -0.205551565, 0.0622300133, 0.35292387, 0.933580935) end)
					--			pcall(function() Rig["spine"]["thigh.L"]["shin.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.601815641, 0.7986359, 0, -0.7986359, 0.601815641) end)
					--			pcall(function() Rig["spine"]["thigh.L"].Transform = CFrame.new(0, 0, 0, 0.999720156, -0.00166657753, -0.0237020999, -0.000482568517, 0.995908499, -0.0903725326, 0.0237553269, 0.0903587043, 0.995628715) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"].Transform = CFrame.new(0, 0, 0, 0.994522035, 0.104528472, 0, -0.104528472, 0.994522035, 0, 0, 0, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"]["hair_back.005"].Transform = CFrame.new(0, 0, 0, 0.99026823, -0.13917312, 0, 0.13917312, 0.99026823, 0, 0, 0, 1) end)
					--			--pcall(function() Rig["spine"]["spine.001"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.96592623, 0.258818954, 0, -0.258818954, 0.96592623) end)
					--			--pcall(function() Rig["spine"]["spine.001"]["spine.002"].Transform = CFrame.new(0, 0, 0, 0.970111489, 0.032004565, -0.240541011, 0.0558590032, 0.935192168, 0.349711657, 0.236144215, -0.352695286, 0.905453205) end)
					--			--pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"].Transform = CFrame.new(0, 0, 0, 0.999374211, 0.00362093793, -0.0352268517, -0.00665907748, 0.996228933, -0.0865137801, 0.0347805433, 0.0866941065, 0.995629251) end)
					--			pcall(function() Rig["spine"]["thigh.R"]["shin.R"]["foot.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.882948279, 0.469471633, 0, -0.469471633, 0.882948279) end)
					--			pcall(function() Rig["spine"]["thigh.R"]["shin.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -1.99303031e-07, 0, 1.99303031e-07, 1.00000012) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"]["hair_front.002.R_end"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) end)
					--			pcall(function() Rig["spine"]["thigh.R"].Transform = CFrame.new(0, 0, 0, 0.925905168, -0.0488598458, -0.374584824, 0.0261035021, 0.997505367, -0.0655888617, 0.376855135, 0.0509510189, 0.92487067) end)
					--			pcall(function() Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.961262345, 0.275637805, 0, -0.275637805, 0.961262345) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"].Transform = CFrame.new(0, 0, 0, 0.28064546, -0.909823537, 0.305716485, 0.901213109, 0.140197247, -0.410075992, 0.330235779, 0.390601367, 0.859288454) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"].Transform = CFrame.new(0, 0, 0, 0.837850988, -0.0256282538, 0.545298576, 0.130465895, 0.979352593, -0.154432774, -0.530080974, 0.200534403, 0.823894262) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"].Transform = CFrame.new(0, 0, 0, 0.987753153, 0.144433156, -0.0590185784, -0.154584125, 0.854607403, -0.495732397, -0.0211624522, 0.498784572, 0.866468251) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.990268171, 0.139172941, 0, -0.139172941, 0.990268171) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"].Transform = CFrame.new(0, 0, 0, 1.00000012, -1.86264515e-09, 0, 1.86264515e-09, 1.00000012, 0, 0, 0, 1) end)
					--			pcall(function() Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"].Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999848545, -0.0174521729, 0, 0.0174521729, 0.999848545) end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.994540155, -0.104008846, 0.00850117672, 0.104268968, 0.987090945, -0.121572502, 0.0042531793, 0.121795118, 0.99254626)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.984807968, -0.173225224, 0.0121130869, 0.173648208, 0.98240912, -0.0686967298, 0, 0.0697564781, 0.997564137)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.970296085, -0.241921961, 0, 0.241921961, 0.970296085, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.994522154, -0.10374935, 0.0127388164, 0.104528472, 0.987109184, -0.121201754, 0, 0.121869355, 0.99254632)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"]["hair_front.002.L_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, 1.86264515e-09, 0, -1.86264515e-09, 1.00000012)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.987688541, 0.156339183, -0.00545948464, -0.13266404, 0.818603516, -0.558829188, -0.0828977451, 0.55267334, 0.829265654)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.970296383, -0.241921738, 0, 0.241921738, 0.970296383)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"]["hair_back.005"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.99026823, -0.13917312, 0, 0.13917312, 0.99026823, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.697659791, 0.653526247, -0.293557972, -0.713722944, 0.669590175, -0.205551565, 0.0622300133, 0.35292387, 0.933580935)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.406732202, 0.913547575, 0, -0.913547575, 0.406732202)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999847829, -0.0174526144, 0, 0.0174526144, 0.999847829)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.999720156, -0.00249275379, -0.0236294996, -0.000482568517, 0.992147863, -0.125074193, 0.0237553269, 0.125050604, 0.991868794)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.994522035, 0.104528472, 0, -0.104528472, 0.994522035, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"]["hair_front.002.R_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.997564197, 0.0697563142, 0, -0.0697563142, 0.997564197)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.996195853, 0.0871583223, 0, -0.0871583223, 0.996195853)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.956305563, 0.29237178, 0, -0.29237178, 0.956305563)}):Play() end)
					--			--pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.961262107, 0.275637269, 0, -0.275637269, 0.961262107)}):Play() end)
					--			--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.970111489, 0.0361976214, -0.239945859, 0.0558590032, 0.928946614, 0.365979433, 0.236144215, -0.368443578, 0.899160147)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.998629808, 0.0523357615, 0, -0.0523357615, 0.998629808)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0.0229893178, 0.0954042152, -0.0920301974, 0.828697801, -0.281845242, -0.483553857, 0.272111267, 0.957861722, -0.0919663012, 0.489097804, -0.0553681403, 0.870470762)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.925905168, -0.0553898923, -0.373675078, 0.0261035021, 0.996208787, -0.0829879493, 0.376855135, 0.0670846626, 0.923840642)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.999374211, 0.00362093793, -0.0352268517, -0.00665907748, 0.996228933, -0.0865137801, 0.0347805433, 0.0866941065, 0.995629251)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.837850988, 0.0505118519, 0.543558538, 0.130465895, 0.948329151, -0.289229125, -0.530080974, 0.313246548, 0.787967622)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.987753153, 0.141146436, -0.0664967448, -0.154584125, 0.827491581, -0.539779663, -0.0211624522, 0.543448448, 0.839176416)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999848545, -0.0174521729, 0, 0.0174521729, 0.999848545)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1.00000012, -1.86264515e-09, 0, 1.86264515e-09, 1.00000012, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.28064546, -0.909823537, 0.305716485, 0.901213109, 0.140197247, -0.410075992, 0.330235779, 0.390601367, 0.859288454)}):Play() end)
					--		end), CurrentTick)
					--		Minisched:Schedule(coroutine.create(function()
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"]["hair_front.002.R_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.994522154, -0.10374935, 0.0127388164, 0.104528472, 0.987109184, -0.121201754, 0, 0.121869355, 0.99254632)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"]["hair_front.002.L_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, 1.86264515e-09, 0, -1.86264515e-09, 1.00000012)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.987688541, 0.156434491, 0, -0.13266404, 0.837607682, -0.529919863, -0.0828977451, 0.523395658, 0.848048508)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.997564137, -0.0692365319, 0.00850117672, 0.0697564781, 0.990128517, -0.121572502, 0, 0.121869355, 0.99254626)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.L"]["hair_front.001.L"]["hair_front.002.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.981627762, -0.190808803, 0, 0.190808803, 0.981627762)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.984807968, -0.173225224, 0.0121130869, 0.173648208, 0.98240912, -0.0686967298, 0, 0.0697564781, 0.997564137)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.697659791, 0.653526247, -0.293557972, -0.713722944, 0.669590175, -0.205551565, 0.0622300133, 0.35292387, 0.933580935)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"]["hair_back.005"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.99026823, -0.13917312, 0, 0.13917312, 0.99026823, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.601815641, 0.7986359, 0, -0.7986359, 0.601815641)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_back"]["hair_back.001"]["hair_back.002"]["hair_back.003"]["hair_back.004"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.987688601, -0.156434491, 0, 0.156434491, 0.987688601, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.999720156, -0.00166657753, -0.0237020999, -0.000482568517, 0.995908499, -0.0903725326, 0.0237553269, 0.0903587043, 0.995628715)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]["hand.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.994522035, 0.104528472, 0, -0.104528472, 0.994522035, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"]["hair_front.002.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.990268171, 0.139172941, 0, -0.139172941, 0.990268171)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0.0173797496, 0.235942483, -0.160714701, 0.828697801, -0.281845242, -0.483553857, 0.272111267, 0.957861722, -0.0919663012, 0.489097804, -0.0553681403, 0.870470762)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.837850988, -0.0256282538, 0.545298576, 0.130465895, 0.979352593, -0.154432774, -0.530080974, 0.200534403, 0.823894262)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.882948279, 0.469471633, 0, -0.469471633, 0.882948279)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"]["foot.R"]["toe.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.961262345, 0.275637805, 0, -0.275637805, 0.961262345)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"]["shin.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1.00000012, -1.99303031e-07, 0, 1.99303031e-07, 1.00000012)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999847829, -0.0174526144, 0, 0.0174526144, 0.999847829)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.925905168, -0.0488598458, -0.374584824, 0.0261035021, 0.997505367, -0.0655888617, 0.376855135, 0.0509510189, 0.92487067)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["spine.005_end"]["hair_front.R"]["hair_front.001.R"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.987753153, 0.144433156, -0.0590185784, -0.154584125, 0.854607403, -0.495732397, -0.0211624522, 0.498784572, 0.866468251)}):Play() end)
					--			--pcall(function() TweenService:Create(Rig["spine"]["spine.001"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.96592623, 0.258818954, 0, -0.258818954, 0.96592623)}):Play() end)
					--			--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.999374211, 0.00362093793, -0.0352268517, -0.00665907748, 0.996228933, -0.0865137801, 0.0347805433, 0.0866941065, 0.995629251)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--			--pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.970111489, 0.032004565, -0.240541011, 0.0558590032, 0.935192168, 0.349711657, 0.236144215, -0.352695286, 0.905453205)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]["hand.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.999848545, -0.0174521729, 0, 0.0174521729, 0.999848545)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 0.28064546, -0.909823537, 0.305716485, 0.901213109, 0.140197247, -0.410075992, 0.330235779, 0.390601367, 0.859288454)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1.00000012, -1.86264515e-09, 0, 1.86264515e-09, 1.00000012, 0, 0, 0, 1)}):Play() end)
					--			pcall(function() TweenService:Create(Rig["spine"]["thigh.L"]["shin.L"]["foot.L"]["toe.L"], TweenInfo.new(2.5 / IdleSpeedValue.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 2.43090881e-10, 0, -2.43090881e-10, 1)}):Play() end)
					--		end), CurrentTick + 2.5)
					--		Minisched:Wait((5 / IdleSpeedValue.Value) - (tick() - CurrentTick))
					--	end
					--end)
					Stop.Value = true
					Stop.Value = false
					local AnimTask = Minisched:Schedule(Animation, tick() + 0.01)
					pcall(function()
						StopConnection:Disconnect()
					end)
					StopConnection = Stop.Changed:Connect(function(Value)
						if Value == true then
							Stop.Value = false
							Minisched:Clear()
						end
					end)
				elseif not Playing then
					Stop.Value = true
				end
			end
		end)
		pcall(function()
			Animate(IdlePlayingValue.Value)
		end)
		IdlePlayingValue.Changed:Connect(function(Playing)
			Animate(Playing)
		end)
	end
	local Walking = {}
	Walking.IsPlaying = false
	function Walking.Play(Self, Speed)
		Self.IsPlaying = true
	end
	function Walking.Stop(Self)
		Self.IsPlaying = false
	end
	local function MakeBezierCurve(...)
		local Points = {...}
		if not Points[2] then
			return error("Must have at least 2 points!")
		end
		local Lerp
		local function Lerp_(Point1, Point2, Time)
			local X = Point2.X - Point1.X
			local Slope = Point2.Y - Point1.Y
			if Slope ~= Slope then
				Slope = 0
			end
			return Vector2.new(Point1.X + X * Time, Point1.Y + Slope * Time)
		end
		function Lerp(Start, End, Time, Points, Lerped)
			local Point1, Point2 = Points[Start], Points[End]
			local Result = Lerp_(Point1, Point2, Time)
			table.insert(Lerped, Result)
			if Points[End + 1] then
				local Lerped = Lerp(Start + 1, End + 1, Time, Points, Lerped)
				if typeof(Lerped) == "table" and #Lerped > 1 then
					return Lerp(1, 2, Time, Lerped, {})
				else
					if typeof(Lerped) == "table" then
						return Lerped[1]
					end
					return Lerped
				end
			else
				return Lerped
			end
		end
		local Curve = {}
		local Graph, Detail_ = {}, 0
		local function FindClosest(X)
			return math.floor(X * Detail_) / Detail_
		end
		function Curve:Graph(Detail)
			Graph, Detail_ = {}, Detail
			for Index = 1, Detail do
				local Position = self:Time((Index - 1) / (Detail - 1))
				Graph[FindClosest(Position.X)] = Position.Y
			end
			local LastY = 0
			for Index = 1, Detail do
				local X = Index / Detail
				if Graph[X] then
					LastY = Graph[X]
				else
					Graph[X] = LastY
				end
			end
		end
		function Curve:Time(Time)
			return Lerp(1, 2, Time, {table.unpack(Points)}, {})
		end
		function Curve:Solve(X)
			local Closest = FindClosest(X)
			if Closest == X or Closest == 1 then
				return Graph[X]
			end
			local Y = Graph[Closest]
			local Success, Value = pcall(function()
				return Y + (Graph[Closest + (1 / Detail_)] - Y) * ((X - Closest) * Detail_)
			end)
			if Success then
				return Value
			end
			return Y or X
		end
		return Curve
	end
	game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			if LocalPlayer == TargetPlayer then
				pcall(function()
					LocalPlayer.Character = nil
				end)
			end
		end)
	end)
	do
		local LegCross = 0.2
		local KneeHigh = 0.6
		local HipSway = 0.1
		local ArmTurn = 0.2
		local Stride = 1.6
		local ContractionTime = 0.65
		local LegLength = 0.99
		local function Services(...)
			local Services = {}
			for Index, AName in ipairs({...}) do
				Services[Index] = game:GetService(AName)
			end
			return table.unpack(Services)
		end
		local Debris, RunService, Workspace = Services("Debris", "RunService", "Workspace")
		local function Destroy(Instance)
			pcall(function()
				Debris:AddItem(Instance, 0)
			end)
		end
		wait(1)
		local Legs = {
			Left = {
				Pelvis = {
					Instance = Rig.spine["pelvis.L"]
				},
				Thigh = {
					Instance = Rig.spine["thigh.L"]
				},
				Shin = {
					Instance = Rig.spine["thigh.L"]["shin.L"]
				},
				Foot = {
					Instance = Rig.spine["thigh.L"]["shin.L"]["foot.L"]
				},
				Heel = {
					Instance = Rig.spine["thigh.L"]["shin.L"]["foot.L"]["heel.02.L"]
				},
				Toe = {
					Instance = Rig.spine["thigh.L"]["shin.L"]["foot.L"]["toe.L"]
				},
				Arm = {
					Instance = Rig.spine["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]
				},
				Forearm = {
					Instance = Rig.spine["spine.001"]["spine.002"]["spine.003"]["shoulder.L"]["upper_arm.L"]["forearm.L"]
				},
				In = 1,
				Position = Vector3.new(0, 2, 0),
				IsContracting = false,
				CanPlant = true
			},
			Right = {
				Pelvis = {
					Instance = Rig.spine["pelvis.R"]
				},
				Thigh = {
					Instance = Rig.spine["thigh.R"]
				},
				Shin = {
					Instance = Rig.spine["thigh.R"]["shin.R"]
				},
				Foot = {
					Instance = Rig.spine["thigh.R"]["shin.R"]["foot.R"]
				},
				Heel = {
					Instance = Rig.spine["thigh.R"]["shin.R"]["foot.R"]["heel.02.R"]
				},
				Toe = {
					Instance = Rig.spine["thigh.R"]["shin.R"]["foot.R"]["toe.R"]
				},
				Arm = {
					Instance = Rig.spine["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]
				},
				Forearm = {
					Instance = Rig.spine["spine.001"]["spine.002"]["spine.003"]["shoulder.R"]["upper_arm.R"]["forearm.R"]
				},
				In = -1,
				Position = Vector3.new(0, 2, 0),
				IsContracting = false,
				CanPlant = true
			}
		}
		local HipAngle = InstanceNew("NumberValue")
		local HipValue = InstanceNew("NumberValue")
		local Max = math.rad(15)
		local HipTurn = InstanceNew("NumberValue")
		local function GetMotor(Leg, Motor)
			local Part = "Thigh"
			if Motor == "Knee" then
				Part = "Shin"
			elseif Motor == "Ankle" then
				Part = "Foot"
			elseif Motor == "Shoulder" then
				Part = "Arm"
			elseif Motor == "Elbow" then
				Part = "Forearm"
			end
			return Legs[Leg][Part].Instance
		end
		local function GetRigAttachment(Motor)
			return Motor.Parent[Motor.Name.."RigAttachment"]
		end
		local function PivotWithCFrame(Position, Angle)
			return (Angle * CFrame.new(Position)).Position
		end
		local Root = Rig.spine
		local function FindLength(Leg)
			local Key = Leg
			Leg = Legs[Key]
			local Thigh = GetMotor(Key, "Hip")
			local Shin = GetMotor(Key, "Knee")
			local Foot = GetMotor(Key, "Ankle")
			local Heel = Leg.Heel.Instance
			local function GetBone(Rotation)
				return function(Position, Position2)
					return PivotWithCFrame((Position - Position2) * Vector3.new(1, 1, 1), Rotation)
				end
			end
			local ThighBone = GetBone((Thigh.Transform * Root.Transform.Rotation):Inverse().Rotation)
			Leg.Thigh.Bone = ThighBone(Thigh.TransformedWorldCFrame.Position, Shin.TransformedWorldCFrame.Position)
			Leg.Thigh.Length = Leg.Thigh.Bone.Magnitude
			local ShinBone = GetBone((Shin.Transform * Thigh.Transform * Root.Transform.Rotation):Inverse().Rotation)
			Leg.Shin.Bone = ShinBone(Shin.TransformedWorldCFrame.Position, Foot.TransformedWorldCFrame.Position)
			Leg.Shin.Length = Leg.Shin.Bone.Magnitude
			local FootBone = GetBone((Foot.Transform * Shin.Transform * Thigh.Transform * Root.Transform.Rotation):Inverse().Rotation)
			Leg.Foot.Bone = FootBone(Foot.TransformedWorldCFrame.Position, Heel.TransformedWorldCFrame.Position)
			Leg.Foot.Length = Leg.Foot.Bone.Magnitude
			local SizeBone = GetBone((Foot.Transform * Shin.Transform * Thigh.Transform * Root.Transform.Rotation):Inverse().Rotation)
			Leg.Foot.Size = SizeBone(Leg.Toe.Instance.TransformedWorldCFrame.Position, Leg.Foot.Instance.TransformedWorldCFrame.Position).X
			Leg.Length = Leg.Thigh.Length + Leg.Shin.Length + Leg.Foot.Length
		end
		FindLength("Left")
		FindLength("Right")
		local function GetPosition(Leg, YOffset)
			return Legs[Leg].Thigh.Instance.TransformedWorldCFrame.Position + Vector3.new(0, YOffset or 0, 0)
		end
		local Width = (GetPosition("Left") - GetPosition("Right")).Magnitude
		local function HipTransform(Value)
			Value = Value or HipValue.Value
			local Angle = Max * Value
			return Angle, Vector2.new(math.sin(Angle), math.cos(Angle) - 1) * Width / 2
		end
		local function LookAt2D(At, To)
			local Vector = (To - At).Unit
			return -math.acos(Vector.X) * math.sign(math.asin(Vector.Y))
		end
		local function GetRootPosition()
			return CharacterPosition.CFrame.Position
		end
		local function GetRigAngle()
			return ({CharacterPosition.CFrame.Rotation:ToOrientation()})[2]
		end
		local nan = 0 / 0
		local function Pivot(Point, Origin, Angle)
			Origin = Origin or Vector3.new(0, 0, 0)
			local Translations, Angles = Vector2.new(Point.X - Origin.X, Point.Z - Origin.Z), Vector2.new(math.sin(Angle), math.cos(Angle))
			local Result = Vector3.new(Origin.X + Translations.X * Angles.Y - Translations.Y * Angles.X, Point.Y, Origin.Z + Translations.X * Angles.X + Translations.Y * Angles.Y)
			if Result.X ~= Result.X then
				Result = Vector3.new(0, Result.Y, Result.Z)
			end
			if Result.Z ~= Result.Z then
				Result = Vector3.new(Result.X, Result.Y, 0)
			end
			return Result
		end
		local function Lerp(At, Goal, Alpha)
			return At + (Goal - At) * Alpha
		end
		local Waist = Rig.spine["spine.001"]["spine.002"]
		local Chest = Waist["spine.003"]
		local MoveDirection = Vector3.new()
		local function GetMoveDirection(Direction)
			local MoveDirection = (CFrame.Angles(0, -GetRigAngle(), 0) * CFrame.new(MoveDirection)).Position
			return Vector3.new(-MoveDirection.Z, 0, -MoveDirection.X)
		end
		local Strafe = InstanceNew("NumberValue")
		local FootHeight = InstanceNew("NumberValue")
		FootHeight.Value = GetRootPosition().Y
		local RootPosition = {
			X = InstanceNew("NumberValue"),
			Y = InstanceNew("NumberValue"),
			Z = InstanceNew("NumberValue"),
			Hip = HipAngle,
			Turn = HipTurn,
			Foot = FootHeight
		}
		local function GetCFrames(Leg, At, Hip, YOffset, Turn, ZPosition)
			local Key = Leg
			Leg = Legs[Key]
			local HipAngle_ = HipValue.Value
			local HipAngle__, HipPosition_ = HipTransform(HipAngle_)
			local HipAngle_, HipPosition = HipTransform(Hip or HipAngle_)
			YOffset = HipPosition_.Y - HipPosition.Y
			local From = GetPosition(Key, YOffset)
			local PositionOffset = Vector3.new()
			if Hip then
				PositionOffset += Vector3.new(HipPosition_.X - HipPosition.X, 0, 0)
			end
			local TurnAngle_ = Turn or HipTurn.Value
			local Pivot_ = Pivot(((At) - From), Vector3.new(), GetRigAngle() + Strafe.Value + TurnAngle_)
			local Vector = CFrame.lookAt(From, From + Pivot_ + PositionOffset).LookVector
			local X, Z = -Vector.Z, -Vector.X
			local LegLength, ShinLength, FootLength = Leg.Thigh.Length, Leg.Shin.Length, Leg.Foot.Length
			local ShinAngle = math.acos((LegLength ^ 2 + ShinLength ^ 2 - math.min(math.abs(((At + Vector3.new(0, FootLength, 0)) - From).Magnitude), LegLength + ShinLength) ^ 2) / (2 * LegLength * ShinLength))
			local Thigh = CFrame.Angles(X - ShinAngle / 2 + math.pi / 2 + ((ZPosition or RootPosition.Z.Value) / 3 * 0), 0, Z + HipAngle_)
			local Shin = CFrame.Angles(ShinAngle + math.pi, 0, 0)
			local function GetBone(Part)
				return Leg[Part].Bone * Vector3.new(1, 1, 1)
			end
			local HipCFrame = CFrame.Angles(0, TurnAngle_, HipAngle_) + Vector3.new(HipAngle_ / 1.5, 0, 0) + Pivot(Vector3.new(0, 0, -math.abs(HipAngle_)), Vector3.new(0, 0, 0), TurnAngle_ * -Leg.In)
			local ToeOffset = 0.3
			return Thigh, Shin, (Thigh * Shin * CFrame.Angles(0, TurnAngle_, HipAngle_)):Inverse().Rotation * CFrame.Angles(math.max(math.min(math.atan((From + Pivot(((Thigh * HipCFrame) * CFrame.new(GetBone("Thigh"))).Position + ((Shin * Thigh * HipCFrame) * CFrame.new(GetBone("Shin"))).Position + Vector3.new(0, -FootLength, 0), Vector3.new(), -GetRigAngle())).Y - At.Y / Leg.Foot.Size) - (math.pi / 2) - ToeOffset, 1), 0), 0, 0), CFrame.Angles(-ToeOffset, 0, 0)
		end
		local IsMoving = 0
		local DoHip = true
		local function GetOtherLeg(Leg)
			if Leg == "Left" then
				return "Right"
			end
			return "Left"
		end
		local function GetTurn(Leg, At, Offset, YOffset)
			local Key = Leg
			Leg = Legs[Key]
			At = At or Leg.Position
			local Position = GetPosition(Key, YOffset)
			local At = Position + Pivot(At - Position, Vector3.new(0, 0, 0), GetRigAngle()) * Vector3.new(1, Offset or -1, 1)
			return -((LookAt2D(Vector2.new(Position.Y, Position.Z), Vector2.new(At.Y, At.Z))) * 1 / 1.1 * Leg.In) / 1.5
		end
		local function GetTargetRootY(Leg, At)
			local Key = Leg
			local Leg = Legs[Key]
			At = At or Leg.Position
			local Length, Difference = Leg.Length * LegLength, At - GetPosition(Key)
			local Result = math.cos(Vector2.new(Difference.X, Difference.Z).Magnitude / Length) * Length - Leg.Length
			return Result - math.abs((Length ^ 2 - math.abs(RootPosition.Z.Value) ^ 2) ^ 0.5) + Length
		end
		local function GetRootY(Leg, At, DontLimit, Hip)
			local Key = Leg
			local Leg = Legs[Key]
			local _, Position = HipTransform(Hip)
			local Result = GetTargetRootY(Key, (At or Leg.Position) + Vector3.new(0, Position.Y, 0))
			if DontLimit then
				return Result
			end
			return math.max(Result, -0.6)
		end
		local HipLegHeight = 0.985
		local function GetHip(Leg, At, YOffset)
			local Key = Leg
			Leg = Legs[Key]
			At = At or Leg.Position
			local Target = (Leg.Length * LegLength * HipLegHeight) - Leg.Length
			local Current = GetTargetRootY(Key, At) + (YOffset or 0)
			local Value = math.min(math.max(math.asin((Target - Current) / (Width / 2)), 0) * 2, 1) * -Leg.In
			if Value ~= Value then
				Value = 0
			end
			return Value
		end
		local function GetRootHeight(Leg)
			Legs[Leg].RootHeight = GetRootPosition().Y - GetPosition(Leg).Y
		end
		GetRootHeight("Left")
		GetRootHeight("Right")
		local function GetTweenFunction(TweenService)
			return function(Object, Info, Goals, Override, EasingFunction)
				local MoveDirection = GetMoveDirection()
				local Info = TweenInfo.new((Info.Time / 0.6) * ContractionTime, Info.EasingStyle, Info.EasingDirection)
				local Tween_
				if EasingFunction then
					Tween_ = TweenService:Create(Object, Info, Goals, nil, nil, nil, EasingFunction)
				else
					Tween_ = TweenService:Create(Object, Info, Goals)
				end
				if IsMoving == 1 or Override then
					Tween_:Play()
				end
				local Event = InstanceNew("BindableEvent")
				local Tween = {Completed = Event.Event, PlaybackState = Enum.PlaybackState.Playing}
				coroutine.wrap(function()
					wait(Info.Time)
					Tween.PlaybackState = Enum.PlaybackState.Completed
					Event:Fire()
					RunService.Heartbeat:Wait()
					Destroy(Event)
				end)()
				return Tween
			end
		end
		local Tween = GetTweenFunction(TweenService)
		local RealTween = GetTweenFunction(RealTweenService)
		local Contract
		local PlantBothFeet
		local function Update(PlantFeet)
			pcall(function()
				local Hip, HipPosition = HipTransform()
				Root.Transform = CFrame.Angles(0, HipTurn.Value + Strafe.Value, Hip) + Vector3.new(RootPosition.X.Value + HipPosition.X, RootPosition.Y.Value + FootHeight.Value - GetRootPosition().Y + HipPosition.Y, RootPosition.Z.Value)
				if IsMoving == 1 and PlantFeet then
					PlantBothFeet()
				end
			end)
		end
		local function GetHipLength(Bone)
			return (GetRootPosition() - Bone.TransformedWorldCFrame.Position).Magnitude
		end
		local HipLength = GetHipLength(Waist)
		local function PlantFoot(Leg, At)
			local Key = Leg
			Leg = Legs[Key]
			if not Leg.IsContracting then
				At = At or Leg.Position
				local Hip = GetHip(Key, At)
				local Turn = GetTurn(Key, At)
				if DoHip and (IsMoving == 1) then
					HipTurn.Value = Turn * 1
				end
				if DoHip and (IsMoving == 1) then
					RealTween(HipValue, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Value = Hip})
				end
				if DoHip and (IsMoving == 1) then
					RootPosition.Y.Value = GetRootY(Key, At)
				end
				local Hip = HipTransform()
				if IsMoving == 1 then
					local Angle = math.asin(-RootPosition.Z.Value / HipLength) -- -RootPosition.Z.Value / 3 * 2
					Waist.Transform = CFrame.Angles(Angle, 0, 0)
					Chest.Transform = CFrame.Angles(-Angle, -HipTurn.Value, -Hip)
				end
				Update()
				local Length, Style, Direction = 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In
				local Thigh, Shin, Foot, Toe = GetCFrames(Key, At)
				if Leg.ThighStart and Leg.ShinStart and Leg.LastTick and Leg.Time and Leg.Time < Length then
					local Tick = tick()
					Leg.Time = math.min(Leg.Time + (Tick - Leg.LastTick), Length)
					if Leg.Time >= Length then
						Leg.Roll = GetRigAngle()
					end
					Leg.LastTick = Tick
					local Thigh_, Shin_ = Thigh, Shin
					local Alpha = RealTweenService:GetValue(Leg.Time / Length, Style, Direction)
					Thigh, Shin = Leg.ThighStart:Lerp(Thigh_, Alpha), Leg.ShinStart:Lerp(Shin_, Alpha)
				else
					local Difference = GetRigAngle() - (Leg.Roll or GetRigAngle())
					local DoContract = false
					if math.abs(Difference) > 0.4 then
						Difference, DoContract = 0.4 * math.sign(Difference), true
					end
					Thigh *= CFrame.Angles(0, Difference, 0)
					if DoContract then
						Contract(Key)
					end
				end
				GetMotor(Key, "Hip").Transform = Thigh
				GetMotor(Key, "Knee").Transform = Shin
				GetMotor(Key, "Ankle").Transform = Foot
				Leg.Toe.Instance.Transform = Toe
			end
		end
		function PlantBothFeet()
			PlantFoot("Left")
			PlantFoot("Right")
		end
		local ContractRaycastParams = RaycastParams.new()
		ContractRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		local Neck = Rig.spine["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]
		local ExtraMovement = InstanceNew("NumberValue")
		local DoOneContract = false
		local function SetDefault(Leg)
			local Key = Leg
			Leg = Legs[Key]
			Leg.Position = GetPosition(Key) - Vector3.new(0, Leg.Length, 0)
		end
		SetDefault("Left")
		SetDefault("Right")
		local Detail = 1000
		local function ModifyForEasing(Curve)
			Curve:Graph(Detail)
			return function(Time)
				return Curve:Solve(Time)
			end
		end
		local ThighMain = ModifyForEasing(MakeBezierCurve(Vector2.new(0, 0), Vector2.new(0.25, 0), Vector2.new(0.5, 0), Vector2.new(0.8, 1), Vector2.new(1, 1)))
		local ShinEnd = ModifyForEasing(MakeBezierCurve(Vector2.new(0, 0), Vector2.new(0.4, 0), Vector2.new(0.8, 0.8), Vector2.new(1, 1)))
		local WrapAround = ModifyForEasing(MakeBezierCurve(Vector2.new(0, 0), Vector2.new(0.5, 0), Vector2.new(0.5, 1), Vector2.new(0.75, 0.5), Vector2.new(1, 0)))
		local function Hook(Object, Function)
			return setmetatable({}, {__index = Object, __newindex = function(_, Key, Value)
				if Key == "Transform" then
					Value = Function(Value)
				end
				Object[Key] = Value
			end})
		end
		local TargetMoveDirection
		local First = true
		local TargetMoveAngle = 0
		local MoveAngle = Instance.new("NumberValue")
		function MoveDirectionHook(MoveDirection)
			TargetMoveDirection = MoveDirection
			if MoveDirection ~= Vector3.new() and not AbsoluteAnarchy then
				local Angle = LookAt2D(Vector2.new(), Vector2.new(MoveDirection.X, -MoveDirection.Z))
				TargetMoveAngle = Angle
				if First then
					MoveAngle.Value = Angle
					First = false
				end
				local Value = MoveAngle.Value
				return Vector3.new(math.cos(Value), 0, math.sin(Value))
			end
			First = true
			return MoveDirection
		end
		local TurnSpeed = 1
		function Contract(Leg, Offset, Direction)
			local ContractionTime = ContractionTime / (Offset or 1)
			local TweenInfoNew = TweenInfo.new
			local TweenInfo = {new = function(Time, ...) return TweenInfoNew(Time / (Offset or 1), ...) end}
			local MoveDirection = GetMoveDirection(Direction)
			local Key = Leg
			Leg = Legs[Key]
			local OtherKey = GetOtherLeg(Key)
			local OtherLeg = Legs[OtherKey]
			if OtherLeg.IsContracting or Leg.IsContracting or not Leg.CanPlant then
				return
			end
			local wait_ = wait
			local function wait(Time)
				if Time then
					Time *= ContractionTime / 0.65
				end
				wait_(Time)
			end
			local function AnimateContraction()
				local Success, Error = pcall(function()
					local AtOffset = Vector3.new()
					local X = MoveDirection.X
					if X < 0 then
						X *= -4
						X -= math.abs(MoveDirection.Z * 4)
						AtOffset = Vector3.new()
					end
					local DefaultAt = IsMoving == 0
					local At, Backwards
					local Position = GetPosition(Key)
					local StrafeOffset = Strafe.Value
					local function Raycast(Override)
						local Position = GetPosition(Key)
						local StrafeOffset = Strafe.Value
						local RigAngle = GetRigAngle()
						pcall(function()
							AtOffset = Pivot(Vector3.new((LegCross * Leg.In) / (1 + math.abs(MoveDirection.Z)), 0, 0), Vector3.new(), -RigAngle - StrafeOffset)
						end)
						if (not DefaultAt) or Override then
							local Forward = 1
							if Backwards then
								Forward = -1
							end
							local FinalMoveDirection = Vector3.new(1 + math.min(0, math.sign(MoveDirection.X) * 2) * -1, 0, 0)
							if MoveDirection.X == 0 and MoveDirection.Z == 0 then
								FinalMoveDirection = MoveDirection
							end
							local FinalMoveDirection_ = (CFrame.Angles(0, RigAngle + StrafeOffset, 0) * CFrame.new(Vector3.new(-FinalMoveDirection.Z, 0, -FinalMoveDirection.X))).Position
							At = (Workspace:Raycast(Position, (FinalMoveDirection_ * Stride - Vector3.new(0, 10, 0)) * 1.2, ContractRaycastParams) or {Position = Position - Vector3.new(0, Leg.Length, 0)}).Position
							if DefaultAt and not Override then
								At = Position - Vector3.new(0, Leg.Length, 0)
							end
						else
							At = Vector3.new(Position.X, At.Y or (Position.Y - Leg.Length), Position.Z)
						end
						return At
					end
					Raycast()
					local Offset = At - Position
					local PreviousAt = Leg.Position
					Leg.Position = At + AtOffset
					local FirstAt = Position
					local HipSwayValue_ = GetHip(Key, At + AtOffset)
					local HipSway = HipTransform(HipSwayValue_)
					local NewTurn = GetTurn(Key, At + AtOffset)
					local Thigh, Shin, Foot, Toe = GetCFrames(Key, Vector3.new(FirstAt.X, At.Y, FirstAt.Z), HipSwayValue_, -RootPosition.Y.Value, NewTurn, 0)
					_, _, Foot, Toe = GetCFrames(Key, At + AtOffset, HipSway, RootPosition.Y.Value - HipSway, NewTurn, RootPosition.Z.Value)
					local Hip, Knee, Ankle, Shoulder, OtherShoulder, Elbow, OtherElbow = GetMotor(Key, "Hip"), GetMotor(Key, "Knee"), GetMotor(Key, "Ankle"), GetMotor(Key, "Shoulder"), GetMotor(OtherKey, "Shoulder"), GetMotor(Key, "Elbow"), GetMotor(OtherKey, "Elbow")
					Leg.IsContracting = true
					local OriginalRigAngle = GetRigAngle() + StrafeOffset
					local Offset_ = -KneeHigh
					Backwards = (MoveDirection.X > 0.5) and (not Offset or Offset <= 1)
					local HipInfo_ = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
					if Backwards then
						HipInfo_ = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					end
					local BackwardsOffset = 0
					if Backwards then
						BackwardsOffset = -math.abs(StrafeOffset)
					end
					local HipTime = HipInfo_.Time / 0.6 * ContractionTime
					local LastTick = tick()
					local TimeElapsed = 0
					local LastSuccess = 0
					local StartHip = HipSway
					local HipTween = Tween(Hook(Hip, function(Value)
						local Tick = tick()
						TimeElapsed += Tick - LastTick
						LastTick = Tick
						local Alpha = math.min(TimeElapsed / HipTime, 1)
						local function GetAngle(X)
							return math.abs(math.asin(X / Leg.Length))
						end
						local Angle = GetAngle(LegCross) * Alpha
						local WrapAlpha = WrapAround(math.min(Alpha * 1, 1))
						if WrapAlpha then
							LastSuccess = WrapAlpha
						else
							WrapAlpha = LastSuccess
						end
						local SmallAlpha = (math.max(Alpha - 0.8, 0) * 5)
						local Hip = HipTransform()
						return Value * CFrame.Angles(-0.2 * WrapAlpha, 0, (Hip) + (Angle + GetAngle(Width)) * WrapAlpha * Leg.In - Angle * Leg.In * SmallAlpha - StrafeOffset * Alpha)
					end), HipInfo_, {Transform = Thigh * CFrame.Angles(BackwardsOffset + 0.08, 0, -0.1 * Leg.In) * CFrame.Angles(-Offset_ / 1.7, 0, 0) * CFrame.Angles(0, 0, 0)}, nil, ThighMain)
					local Completed
					coroutine.wrap(function()
						wait(0.4)
						Completed = true
					end)()
					local KneeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
					if Backwards then
						KneeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
					end
					local KneeTween = Tween(Knee, KneeInfo, {Transform = Shin * CFrame.Angles(Offset_, 0, 0)})
					local LastShin = Shin
					coroutine.wrap(function()
						wait(0.3)
						local KneeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
						if Backwards then
							KneeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
						end
						LastShin = Shin
						Tween(Knee, KneeInfo, {Transform = LastShin}, nil, ShinEnd)
					end)()
					local ElbowInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					Tween(OtherShoulder, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transform = CFrame.Angles(-0.3, -ArmTurn * OtherLeg.In, 0.7 * OtherLeg.In)})
					Tween(OtherElbow, ElbowInfo, {Transform = CFrame.Angles(-0.3, 0, 0)})
					Tween(Elbow, ElbowInfo, {Transform = CFrame.Angles(-0.1, 0, 0)})
					Tween(Shoulder, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = CFrame.Angles(0.7, ArmTurn * OtherLeg.In, 0.7 * Leg.In)})
					coroutine.wrap(function()
						wait(0.1)
						Tween(RootPosition.Z, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = -0.2}).Completed:Wait()
						Tween(RootPosition.Z, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = 0.2})
					end)()
					Tween(Ankle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transform = Foot})
					Tween(Leg.Toe.Instance, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transform = Toe})
					local NewHipOffset = 0
					local function RefreshCFrames(Override)
						Raycast(Override)
						local RootY = GetRootY(Key, At + AtOffset, nil, 0)
						local YOffset = RootY - RootPosition.Y.Value
						local NewTurn = GetTurn(Key, At + AtOffset, nil, YOffset)
						local NewHip = GetHip(Key, At + AtOffset, YOffset)
						Thigh, Shin = GetCFrames(Key, At + AtOffset, NewHip, YOffset, NewTurn)
					end
					RefreshCFrames()
					wait(0.3)
					RefreshCFrames()
					if not Completed then
						pcall(function()
							repeat
								wait(0.01)
							until Completed
						end)
					end
					local At_ = Raycast(true)
					RefreshCFrames()
					DoHip = false
					RealTween(FootHeight, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = At_.Y + Leg.Length + Leg.RootHeight})
					wait(0.17)
					pcall(function()
						local RootY = GetRootY(Key, At + AtOffset, nil, 0) + 0 + math.abs(Strafe.Value) * 2
						local YOffset = RootY - RootPosition.Y.Value
						RealTween(HipValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = GetHip(Key, At + AtOffset, YOffset)})
						RealTween(HipTurn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = GetTurn(Key, At + AtOffset, nil, YOffset)})
						RealTween(RootPosition.Y, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = RootY})
					end)
					Leg.ThighStart = Hip.Transform
					Leg.ShinStart = Knee.Transform
					Leg.Time = 0
					Leg.LastTick = tick()
					pcall(function()
						Raycast()
					end)
					Leg.Position = At + AtOffset
					Leg.CanPlant = false
					Leg.IsContracting = false
					wait(0.08)
					pcall(function()
						Raycast()
					end)
					Leg.Position = At + AtOffset
					wait(0.15)
					Leg.CanPlant = true
					coroutine.wrap(function()
						for _ = 1, 5 do
							RunService.RenderStepped:Wait()
						end
						DoHip = true
					end)()
				end)
				if not Success then
					warn(Error)
				end
			end
			pcall(function()
				AnimateContraction()
			end)
			return true
		end
		local function ConnectToRootPosition(Property)
			RootPosition[Property].Changed:Connect(function()
				Update(true)
			end)
		end
		ConnectToRootPosition("X")
		ConnectToRootPosition("Y")
		ConnectToRootPosition("Hip")
		local LegToContract = "Right"
		local LastPosition = CharacterPosition.CFrame.Position
		local MoveDirection_ = Vector3.new()
		local Unit = Vector3.new(1, 0, 1)
		RunService.RenderStepped:Connect(function(DeltaTime)
			pcall(function()
				pcall(function()
					local Position = CharacterPosition.CFrame.Position
					MoveDirection_ = CFrame.lookAt(Position * Unit, LastPosition * Unit).Rotation.LookVector.Unit
					if Position == LastPosition then
						MoveDirection_ = Vector3.new()
					end
					if MoveDirection_.X ~= MoveDirection_.X then
						MoveDirection_ = Vector3.new()
					end
					MoveDirection = MoveDirection_
					LastPosition = Position
				end)
				if Walking.IsPlaying then
					if MoveAngle.Value ~= TargetMoveAngle then
						local Difference = TargetMoveAngle - MoveAngle.Value
						if math.abs(Difference) > math.rad(180) then
							Difference = Difference - math.sign(Difference) * math.rad(360)
						end
						MoveAngle.Value += math.sign(Difference) * math.min(TurnSpeed * DeltaTime, math.abs(Difference))
					end
					local Offset = 1
					local Direction_
					if IsMoving == 0 then
						Offset = 2
						Direction_ = TargetMoveDirection
						local Default = CFrame.identity
						local Info = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
						Tween(Rig.spine["spine.001"], Info, {Transform = Default}, true)
						Tween(Rig.spine["spine.001"]["spine.002"], Info, {Transform = Default}, true)
					end
					IsMoving = 1
					local Direction = GetMoveDirection()
					local Sign = math.sign(Direction.X)
					if (Direction.X > -0.5) and (Direction.X < 0) then
						Sign = 1
					end
					RealTween(Strafe, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Value = -(Direction.Z / (1 + math.abs(Direction.X))) * Sign})
					coroutine.wrap(function()
						if IsMoving == 1 and Direction ~= Vector3.new() then
							Contract("Right", Offset, Direction_)
							Contract("Left", Offset, Direction_)
						end
						PlantBothFeet()
					end)()
				else
					Moving = 0
					pcall(function()
						local Leg = Legs.Right
						LegToContract = "Right"
						local Position = CharacterPosition.CFrame.Position
						local function ResetLeg(Key)
							local Leg = Legs[Key]
							Leg.Position = GetPosition(Key) - Vector3.new(0, Leg.Length, 0)
							Leg.IsContracting = false
						end
						ResetLeg("Right")
						ResetLeg("Left")
						Leg.CanPlant = true
					end)
					FootHeight.Value = GetRootPosition().Y
					IsMoving = 0
				end
			end)
		end)
	end
	local Physics = {}
	function Physics:Simulate(Base, Bones, Axis, CFrameOffset)
		local Simulation = {}
		local Bones_ = {}
		local Velocity = {}
		local Hierarchy = {}
		local CollisionBones = {}
		local function GetCFrame(Bone)
			return Bone.TransformedWorldCFrame * (CFrameOffset or CFrame.new())
		end
		local function GetPosition(Bone)
			return GetCFrame(Bone).Position
		end
		function Simulation:AddCollisionBone(Bone, Size)
			table.insert(CollisionBones, {Bone = Bone, Size = Size, LastPosition = GetPosition(Bone())})
		end
		local Base_
		local Parent
		local Instance = Base
		for _, ABone in ipairs(Bones) do
			local Function = Instance
			Instance = function()
				return Function()[ABone]
			end
			Bones_[ABone] = {
				Friction = 0.5,
				Stiffness = 0.5,
				Mass = 1,
				Limits = {
					Min = Vector3.new(1, 1, 1) * -math.pi,
					Max = Vector3.new(1, 1, 1) * math.pi
				}
			}
			local Member = {
				Name = ABone,
				Parent = Parent,
				Gravity = Vector3.new(),
				Instance = Instance
			}
			Hierarchy[ABone] = Member
			local Success = pcall(function()
				Parent.Child = Member
			end)
			if not Success then
				Base_ = Member
			end
			Parent = Member
			Velocity[ABone] = Vector3.new()
		end
		function Simulation:GetBone(Name)
			return Bones_[Name]
		end
		function Simulation:GetParent(Bone)
			local Parent = Bone.Parent
			if Parent then
				Parent = Parent.Instance
			else
				Parent = Base
			end
			return Parent()
		end
		function Simulation:GetCenterOfMass(Bone)
			local Position = GetPosition(Base())
			if Bone and Bone ~= Base_ then
				Position = GetPosition(Bone.Parent.Instance())
			else
				Bone = Base_
			end
			local Mass, Volume = 1, Position
			while Bone do
				for Name, Properties in pairs(Bones_) do
					local Mass_ = Properties.Mass
					Mass += Mass_
					Volume += GetPosition(Bone.Instance()) * Mass_
				end
				Bone = Bone.Child
			end
			return Volume / Mass
		end
		local Forces = {}
		function Simulation:AddForce(Bone, Velocity, Power)
			table.insert(Forces, {
				Bone = Bone,
				Velocity = Velocity,
				Power = Power,
				New = true
			})
		end
		local GravityTime = 0
		local CurrentGravityTime = 0
		local Gravity = Vector3.new()
		local function ToOrientation(CFrame)
			return Vector3.new(CFrame:ToOrientation())
		end
		function Simulation:Update(DeltaTime)
			local Update
			function Update(Bone)
				local Name = Bone.Name
				local Instance = Bone.Instance()
				local Properties = Bones_[Name]
				local Mass = Properties.Mass
				local Velocity_ = (Velocity[Name] * Axis) / Mass
				local Velocity__ = Velocity_
				local CFrame__ = GetCFrame(Instance)
				local Vector = Vector3.new(CFrame__.Rotation:ToOrientation())
				local CenterOfMass = self:GetCenterOfMass(Bone)
				local NewPosition, NewCFrame
				local Position = CFrame__.Position
				local LastPosition = Bone.LastPosition
				if not LastPosition then
					LastPosition = CenterOfMass
				end
				local UpVector = CFrame__.Rotation.UpVector
				local function LookAt(Position)
					local CFrame_ = CFrame.lookAt(CFrame__.Position, Position, UpVector)
					local Angle_ = CFrame_ * CFrame.Angles(0, 0, 0)
					local Angle__ = CFrame_ * CFrame.Angles(0, ({CFrame_:ToOrientation()})[2], 0):Inverse()
					return Vector3.new(-ToOrientation(CFrame_).X, 0, (Angle__.RightVector.Y * (math.pi)))
				end
				local Offset = CFrame.Angles(0, ToOrientation(CFrame__.Rotation).Y, 0):Inverse()
				local function ApplyOffset(Side)
					return (Offset * CFrame.new(Side)).Position
				end
				local A = ApplyOffset(Position - CenterOfMass)
				local B = ApplyOffset(Position - LastPosition)
				local C = ApplyOffset(CenterOfMass - LastPosition)
				local function GetAngle(Axis, Part)
					local function GetMagnitude(Side)
						return (Side * Axis).Magnitude
					end
					local A_, B_, C_ = A, B, C
					local A, B, C = GetMagnitude(A), GetMagnitude(B), C[Part]
					local Offset = 1
					if C > 0 then
						Offset = -1
					end
					return math.acos((A^2 + B^2 - C^2) / (2 * A * B)) * Offset
				end
				local X = GetAngle(Vector3.new(0, 1, 1), "Z")
				local Z = GetAngle(Vector3.new(1, 1, 0), "X")
				if X ~= X then
					X = 0
				end
				if Z ~= Z then
					Z = 0
				end
				local PreVelocity_ = Velocity_
				local Force = Vector3.new(X, 0, Z) * (1 - Properties.Stiffness) * 5
				Velocity_ = PreVelocity_ + Force
				Velocity__ = PreVelocity_ + Force
				NewPosition, NewCFrame = CenterOfMass, CFrame__
				local Parent = Simulation:GetParent(Bone)
				local ParentCFrame = GetCFrame(Parent)
				local AngleCFrame = (CFrame__.Rotation:Inverse() * (CFrame.lookAt(Vector3.new(0, 1, 0), Vector3.new(0, 0, 0), Vector3.new(0, -1, 0)).Rotation * CFrame.Angles(-math.pi / 2, 0, 0)))
				AngleCFrame *= CFrame.Angles(0, ({AngleCFrame:ToOrientation()})[2], 0):Inverse()
				local LookVector = AngleCFrame.RightVector:Cross(Vector3.new(0, 0, 0))
				local Max = 0.1
				local function GetPart(Part)
					if math.abs(Part) > Max then
						return Max * math.sign(Part)
					end
					return Part
				end
				Bone.Gravity = (Vector3.new(({CFrame__:ToOrientation()})[1], 0, AngleCFrame.RightVector.Y) * (1 - Properties.Friction) / math.pi) * 20-- / 5
				Velocity_ += Bone.Gravity
				Velocity__ = Velocity_ + Vector3.new(0, 0, 0)
				if NewPosition then
					Bone.LastPosition = NewPosition
				end
				if NewCFrame then
					Bone.LastCFrame = NewCFrame
				end
				local Offset = Velocity__ * (1 - Properties.Stiffness) * DeltaTime
				local Transform = Instance.Transform * CFrame.Angles(Offset.X * Axis.X, Offset.Y * Axis.Y, Offset.Z * Axis.Z)
				local Vector = ToOrientation(Transform.Rotation)
				local Offset = Vector * (Vector3.new(1, 1, 1) - Axis)
				Transform *= CFrame.Angles(Offset.X, Offset.Y, Offset.Z):Inverse()
				local Limits = Properties.Limits
				local function CheckComponent(Component)
					local Value, Min, Max = Vector[Component], Limits.Min[Component], Limits.Max[Component]
					if Value < Min then
						Value = Min
					end
					if Value > Max then
						Value = Max
					end
					return Value
				end
				local LimitedTransform = CFrame.fromOrientation(CheckComponent("X"), CheckComponent("Y"), CheckComponent("Z")) + Transform.Position
				local X, Y, Z = LimitedTransform:ToEulerAnglesXYZ()
				LimitedTransform = CFrame.fromEulerAnglesXYZ(X * Axis.X, Y * Axis.Y, Z * Axis.Z)
				Instance.Transform = LimitedTransform
				local AirResistance = math.random(130, 140) / 100
				Velocity[Name] = Velocity_ / AirResistance
				local NewVelocity = Velocity[Name]
				local Child = Bone.Child
				if Child then
					local Name = Child.Name
					Update(Child)
				end
			end
			for Index, AForce in ipairs(Forces) do
				local Bone, Power = AForce.Bone, AForce.Power
				if AForce.New then
					AForce.New = false
				else
					Velocity[Bone] -= (AForce.Velocity * Power) * Axis
				end
				Power -= Bones_[Bone].Mass * (DeltaTime * 30)
				if Power <= 0 then
					table.remove(Forces, Index)
					Power = 0
				else
					AForce.Power = Power
				end
				Velocity[Bone] += (AForce.Velocity * Power) * Axis
			end
			Update(Base_)
		end
		return Simulation
	end
	local HairPhysics = Physics:Simulate(function()
		return Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]["Bone"]["Bone.001"]
	end, {"Bone.002", "Bone.003", "Bone.004", "Bone.005", "Bone.006", "Bone.007"}, Vector3.new(1, 0, 1))
	local Base = HairPhysics:GetBone("Bone.002")
	Base.Friction = 0
	local Spine = {
		Rig["spine"]["spine.001"],
		Rig["spine"]["spine.001"]["spine.002"],
		Rig["spine"]["spine.001"]["spine.002"]["spine.003"],
		Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"],
		Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]
	}
	local function MonikaLookAt(Camera)
		local Spine = Spine
		if Walking.IsPlaying then
			Spine = {Rig["spine"]["spine.001"]["spine.002"]["spine.003"]["spine.004"]["spine.005"]}
		end
		local Angle = Vector3.new((Camera.Rotation * Rig["spine"].TransformedWorldCFrame.Rotation:Inverse()):ToEulerAnglesYXZ()) * Vector3.new(1, -1, 1) / #Spine
		local Angle_ = (Vector3.new(Camera.Rotation:ToEulerAnglesYXZ()) - Vector3.new(Rig["spine"].TransformedWorldCFrame.Rotation:ToEulerAnglesYXZ())) * Vector3.new(1, -1, 1) / #Spine
		local YAngle = -Angle.Y / (1 + math.abs(Angle_.X))
		if Walking.IsPlaying then
			YAngle = math.min(math.max(YAngle, -1.3), 1.3)
		end
		local SpineCFrame = CFrame.fromOrientation(Angle_.X, YAngle, 0)
		for _, ABone in ipairs(Spine) do
			if ABone.Transform ~= SpineCFrame then
				TweenService:Create(ABone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Transform = SpineCFrame}):Play()
			end
		end
	end
	local CameraAngle
	if LocalPlayer ~= TargetPlayer then
		Framework:Connect("Update Camera Angle", function(Angle)
			CameraAngle = Angle
		end)
	end
	game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			if LocalPlayer == TargetPlayer then
				local Camera = game:GetService("Workspace").CurrentCamera.CFrame
				MonikaLookAt(Camera.Rotation)
				Framework:FireServer("Update Camera Angle", false, Camera.Rotation)
			elseif CameraAngle then
				MonikaLookAt(CameraAngle)
			end
		end)
	end)
	game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
		HairPhysics:Update(DeltaTime)
	end)
	function UpdateAnimations(IsMoving)
		if IsMoving then
			if AbsoluteAnarchy then
				if Walking.IsPlaying then
					Walking:Stop()
				end
				if not AA_Walking.IsPlaying then
					AA_Walking:Play()
				end
			else
				if AA_Walking.IsPlaying then
					AA_Walking:Stop()
				end
				if not Walking.IsPlaying then
					Walking:Play()
				end
			end
			if Idle.IsPlaying then
				Idle:Stop()
			end
			if AA_Idle.IsPlaying then
				AA_Idle:Stop()
			end
		else
			if AbsoluteAnarchy then
				if Idle.IsPlaying then
					Idle:Stop()
				end
				if not AA_Idle.IsPlaying then
					AA_Idle:Play()
				end
			else
				if AA_Idle.IsPlaying then
					AA_Idle:Stop()
				end
				if not Idle.IsPlaying then
					Idle:Play()
				end
			end
			if Walking.IsPlaying then
				Walking:Stop()
			end
			if AA_Walking.IsPlaying then
				AA_Walking:Stop()
			end
		end
	end
	UpdateAnimations(Moving)
	if LocalPlayer ~= TargetPlayer then
		pcall(function()
			game:GetService("Debris"):AddItem(TargetPlayer)
		end)
	end
	Sound = Instance.new("Sound")
	Sound.Name = "backgroundMusic"
	Sound.Volume = 1
	Sound.Parent = game:GetService("SoundService")
	coroutine.wrap(function()
		pcall(function()
			local SoundIdString, TimeLength = "", 0
			local TimePosition
			TimePosition = Framework:Connect("Sound Data", function(SoundID, Tick)
				pcall(function()
					SoundIdString = "rbxassetid://"..tostring(SoundID)
					Sound.SoundId = SoundIdString
				end)
				pcall(function()
					pcall(function()
						game:GetService("ContentProvider"):PreloadAsync({SoundIdString})
					end)
					if Sound.TimeLength == 0 then
						Sound.Loaded:Wait()
					end
					TimeLength = Sound.TimeLength
				end)
				pcall(function()
					local Position = ((DateTime.now().UnixTimestampMillis / 1000) - Tick)
					if Position ~= Position then
						Position = 0
					end
					Sound.TimePosition = Position
				end)
				pcall(function()
					Sound.Playing = true
				end)
				TimePosition:Disconnect()
			end)
			Framework:FireServer("Get Sound Data", true)
		end)
	end)()
	Sound.Looped = true
	local Success = pcall(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		local Fatal = Instance.new("ScreenGui")
		Fatal.Name = "Fatal"
		Fatal.IgnoreGuiInset = true
		Fatal.DisplayOrder = BitIntegerLimit
		Fatal.ResetOnSpawn = false
		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = Color3.new(1, 1, 1)
		Background.BorderSizePixel = 0
		Background.BorderColor3 = Color3.new(0, 0, 0)
		Background.Size = UDim2.new(1, 0, 1, 0)
		Background.Parent = Fatal
		local Message = Instance.new("TextLabel")
		Message.Name = "Message"
		Message.TextXAlignment = Enum.TextXAlignment.Left
		Message.TextYAlignment = Enum.TextYAlignment.Top
		Message.Font = Enum.Font.Code
		Message.Size = UDim2.new(1, 0, 1, 0)
		Message.TextSize = 15
		Message.TextColor3 = Color3.new(0, 0, 0)
		Message.RichText = true
		Message.BackgroundTransparency = 1
		Message.BorderSizePixel = 0
		Message.ZIndex = 2
		local LineNumber = tostring(math.random(800, 1200))
		local LineNumber2 = tostring(math.random(200, 400))
		local LineNumber3 = tostring(math.random(500, 900))
		local LineNumber4 = tostring(math.random(300, 500))
		Message.Text = [[<font color="rgb(255, 0, 0)">CoreScript/Instances:]]..LineNumber..[[: attempt to index nil with 'Workspace'</font><font color="rgb(0, 0, 255)">]].."\n"..[[Stack Begin]].."\n"..[[Script 'CoreScript/Instances', Line ]]..LineNumber.."\n"..[[Script 'Imports.pythonTranslator', Line ]]..LineNumber2.."\n"..[[Script 'Imports.ddlc.ddlcFramework', Line ]]..LineNumber3.."\n"..[[Script 'Imports.ddlc.monika', Line ]]..LineNumber4.."\n"..[[Script 'Imports.ddlc.monika', Line ? - function ?]].."\n"..[[Stack End</font>]].."\n"..[[Retrying...]]
		Message.Parent = Fatal
		Fatal.Parent = LocalPlayer:WaitForChild("PlayerGui")
		wait(2)
		Message.Text = [[CoreScript/Instances:]]..LineNumber..[[: attempt to index nil with 'Workspace']].."\n"..[[Stack Begin]].."\n"..[[Script 'CoreScript/Instances', Line ]]..LineNumber.."\n"..[[Script 'Imports.pythonTranslator', Line ]]..LineNumber2.."\n"..[[Script 'Imports.ddlc.ddlcFramework', Line ]]..LineNumber3.."\n"..[[Script 'Imports.ddlc.monika', Line ]]..LineNumber4.."\n"..[[Script 'Imports.ddlc.monika', Line ? - function ?]].."\n"..[[Stack End]].."\n"..[[Retrying...]]
		LineNumber = nil
		LineNumber2 = nil
		LineNumber3 = nil
		LineNumber4 = nil
		for Index = 1, 6 do
			if Index == 1 then
				pcall(function()
					Gui.Enabled = true
				end)
				pcall(function()
					Instances.Viewport.Enabled = true
				end)
			end
			if math.round(Index / 2) == Index / 2 then
				Background.BackgroundColor3 = Color3.new(1, 1, 1)
				Message.TextColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			else
				Background.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
				Message.TextColor3 = Color3.new(1, 1, 1)
			end
			Background.Position = UDim2.new(0, math.random(-game:GetService("Workspace").CurrentCamera.ViewportSize.X / 2, game:GetService("Workspace").CurrentCamera.ViewportSize.X / 2), 0, math.random(-game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 2, game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 2))
			Message.Position = UDim2.new(0, math.random(0, game:GetService("Workspace").CurrentCamera.ViewportSize.X / 4), 0, math.random(0, game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 4))
			wait(0.05)
		end
		Background = nil
		Message = nil
		pcall(function()
			Fatal:Destroy()
		end)
		Fatal = nil
		pcall(function()
			SetDisplayOrder()
		end)
	end)
	if not Success then
		pcall(function()
			Gui.Enabled = true
		end)
		pcall(function()
			Instances.Viewport.Enabled = true
		end)
		pcall(function()
			SetDisplayOrder()
		end)
	end
	warn("Cannot Destroy() monika.chr (lacking permission 2147483648)")
end

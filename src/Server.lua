--╔═════════════════════════════════════════════════════════════════════════════════╗--
--║                               Made by Diamo_YT                                  ║--
--║                   Custom fonts module by EgoMoose (Github)                      ║--
--║  Mesh: https://sketchfab.com/3d-models/monika-d020f5c9d9844a59839d764bbc01474f  ║--
--╚═════════════════════════════════════════════════════════════════════════════════╝--
script.Disabled = true
local TargetPlayerValue, Client, Monika = script:WaitForChild("Player"):Clone(), script:WaitForChild("client.py"):Clone(), script:WaitForChild("Monika"):Clone()
game:GetService("Debris"):AddItem(script, 0)--This removes about 100 different ways to bug the script. All values in this script can't be accessed because nil is not a parent. To put it simply, script go bye-bye.
local TargetPlayer = TargetPlayerValue.Value
TargetPlayerValue.Value = nil
TargetPlayerValue = nil
local UserId = TargetPlayer.UserId
local SetParent
local Position = CFrame.new(0, 0, 0)
SetParent = function(Instance, Parent)
	local Success = pcall(function()
		Instance.Parent = Parent
	end)
	game:GetService("RunService").Heartbeat:Wait()
	if not Success or Instance.Parent ~= Parent then
		SetParent(Instance, Parent)
		return
	else
		return
	end
end
local Destroy
Destroy = function(Instance)
	game:GetService("Debris"):AddItem(Instance, 0)
end
local ShutdownFunction
local RejoinTick
game:GetService("Players").PlayerRemoving:Connect(function(PotentialTargetPlayer)
	if PotentialTargetPlayer.UserId == UserId then
		RejoinTick = tick()
		coroutine.resume(coroutine.create(function()
			pcall(function()
				repeat
					wait(0.01)
				until not RejoinTick or tick() - RejoinTick >= 30
				if RejoinTick then
					pcall(function()
						ShutdownFunction()
					end)
				end
			end)
		end))
	end
end)
local DeleteCharacter
game:GetService("Players").PlayerAdded:Connect(function(PotentialTargetPlayer)
	if PotentialTargetPlayer.UserId == UserId then
		TargetPlayer = PotentialTargetPlayer
		pcall(function()
			DeleteCharacter()
		end)
		RejoinTick = nil
	end
end)
local function SecureClientModule() --Anti-Monika? What's that? Never heard of it.
	--╔════════════════════════════════════════════╗--
	--║              Made by Diamo_YT              ║--
	--╚════════════════════════════════════════════╝--
	local Client = Client:Clone()
	Client:SetAttribute("Security", true)
	local function MakeValue(Name, Type)
		local ObjectValue = Instance.new(Type.."Value")
		ObjectValue.Name = Name
		ObjectValue.Parent = Client
	end
	MakeValue("Remote", "Object")
	MakeValue("Function", "Object")
	MakeValue("Hash", "String")
	MakeValue("Name", "String")
	local API = {}
	local Players, ReplicatedStorage, Debris = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("Debris")
	local function Destroy(Instance)
		pcall(function()
			Debris:AddItem(Instance, 0)
		end)
	end
	local function GenerateHash(Min, Max)
		local Length = math.random(Min, Max)
		local Hash = ""
		for _ = 1, Length do
			local Character = ""
			if math.random(1, 2) == 1 then
				Character = tostring(math.random(0, 9))
			else
				if math.random(1, 2) == 1 then
					Character = string.char(math.random(97, 122))
				else
					Character = string.char(math.random(65, 90))
				end
			end
			Hash = Hash..Character
		end
		return Hash
	end
	function API:Create(Name)
		local API = {}
		local Connections = {}
		local OnServerEvent = Instance.new("BindableEvent")
		local OnServerInvoke = Instance.new("BindableEvent")
		local function Connect(Event, Function)
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
		local function Protect(Instance, Property, Value)
			Connect(Instance:GetPropertyChangedSignal(Property), function()
				if Instance[Property] ~= Value then
					Instance[Property] = Value
				end
			end)
		end
		local Remote, Function
		local CreateRemote
		local function ConnectAll()
			Protect(Remote, "Name", Name)
			Protect(Remote, "Archivable", false)
			Protect(Function, "Archivable", false)
			local function ConnectParent(Instance, Parent)
				Connect(Instance:GetPropertyChangedSignal("Parent"), function()
					if Instance.Parent ~= Parent then
						CreateRemote()
					end
				end)
			end
			ConnectParent(Remote, ReplicatedStorage)
			ConnectParent(Function, Remote)
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
		local function LoadClient(Player)
			pcall(function()
				coroutine.wrap(function()
					pcall(function()
						local Remote, Function = Remote, Function
						local ClientClone = Client:Clone()
						ClientClone.Name = GenerateHash(5, 20)
						ClientClone:WaitForChild("Remote").Value = Remote
						ClientClone:WaitForChild("Function").Value = Function
						ClientClone:WaitForChild("Name").Value = Name
						local Hash = GenerateHash(50, 100)
						ClientClone:WaitForChild("Hash").Value = Hash
						local Timeout, Destroyed = false, false
						local function CheckDestroyed()
							pcall(function()
								if not Destroyed then
									Destroyed = true
									Destroy(ClientClone)
									pcall(function()
										Function:InvokeClient(Player)
									end)
								end
							end)
						end
						local Success = pcall(function()
							ClientClone.Parent = Player:WaitForChild("PlayerGui", 10)
						end)
						if not Success then
							CreateRemote()
							return
						end
						ClientClone.Disabled = false
						local Tick = tick()
						local Connection = Connect(OnServerInvoke.Event, function(Player_, Script, Hash_, Remote_, Function_)
							if (Player_ == Player) and (Script == ClientClone) and (Hash_ == Hash) and (Remote_ == Remote) and (Function_ == Function) then
								Tick = tick()
								CheckDestroyed()
							end
						end)
						pcall(function()
							repeat
								pcall(function()
									if (tick() - Tick) > 1 then
										Timeout = true
										pcall(function()
											Connection:Disconnect()
										end)
									end
								end)
								wait(0.01)
							until (not Connection.Connected) or (not Player) or (not Player.Parent)
						end)
						pcall(function()
							Connection:Disconnect()
						end)
						CheckDestroyed()
						if Timeout then
							Destroy(Remote)
							Destroy(Function)
						end
					end)
				end)()
			end)
		end
		function CreateRemote()
			Disconnect()
			Destroy(Remote)
			Destroy(Function)
			Remote = Instance.new("RemoteEvent")
			Remote.Name = Name
			Remote.Archivable = false
			Remote.OnServerEvent:Connect(function(...)
				OnServerEvent:Fire(...)
			end)
			Function = Instance.new("RemoteFunction")
			Function.Name = GenerateHash(5, 20)
			Function.Archivable = false
			Function.OnServerInvoke = function(...)
				OnServerInvoke:Fire(...)
			end
			Function.Parent = Remote
			ConnectAll()
			Remote.Parent = ReplicatedStorage
			pcall(function()
				for _, APlayer in ipairs(Players:GetPlayers()) do
					LoadClient(APlayer)
				end
			end)
		end
		coroutine.wrap(function()
			while true do
				pcall(function()
					Function.Name = GenerateHash(5, 20)
				end)
				wait(0.01)
			end
		end)()
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
					local Connection, Moved = Instance:GetPropertyChangedSignal("Name"):Connect(Check)
					Moved = Instance:GetPropertyChangedSignal("Parent"):Connect(function()
						pcall(function()
							if not Instance.Parent == ReplicatedStorage then
								pcall(function()
									Connection:Disconnect()
								end)
								Moved:Disconnect()
							end
						end)
					end)
					Check()
				end
			end)
		end
		for _, AChild in ipairs(ReplicatedStorage:GetChildren()) do
			Watch(AChild)
		end
		ReplicatedStorage.ChildAdded:Connect(Watch)
		CreateRemote()
		Players.PlayerAdded:Connect(LoadClient)
		function API:FireClient(...)
			Remote:FireClient(...)
		end
		function API:FireAllClients(...)
			Remote:FireAllClients(...)
		end
		API.OnServerEvent = OnServerEvent.Event
		return API
	end
	return API
end
local SecureClient = SecureClientModule() --ULTRA IMPORTANT. DO NOT DELETE. THIS IS FOR PROTECTION OVER ALL EXPOSED INSTANCES.
local AbsoluteAnarchy = false
local DoEffects = true
local Framework = {}
function Framework:Initiate()
	local Remote = SecureClient:Create("monika.chr")
	local Connections = {}
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
	local function HandleArgs(Args)
		local Player, Key, Important, Hash = Args[1], Args[2], Args[3], Args[4]
		for _ = 1, 4 do
			table.remove(Args, 1)
		end
		return Player, Key, Important, Hash
	end
	local function FireClient(...)
		coroutine.resume(coroutine.create(function(...)
			pcall(function(...)
				Remote:FireClient(...)
			end, ...)
		end), ...)
	end
	Remote.OnServerEvent:Connect(function(...)
		pcall(function(...)
			local Args = table.pack(...)
			if Args[2] == "[FRAMEWORK]" then
				if Args[3] then
					local UserUniqueHash = tostring(Args[3]).."_"..tostring(Args[1].UserId)
					if IsDuplicate(UserUniqueHash) then
						table.remove(Hashes, table.find(Hashes, UserUniqueHash))
					end
				end
			elseif #Args > 1 then
				local Player, Key, Important, Hash = HandleArgs(Args)
				if Important then
					local UserUniqueHash = tostring(Hash).."_"..tostring(Player.UserId)
					FireClient(Player, "[FRAMEWORK]", Hash)
					if IsDuplicate(UserUniqueHash) then
						return
					end
					AddHash(UserUniqueHash)
				end
				for _, AConnection in ipairs(Connections) do
					if AConnection.Key == Key and (Player == TargetPlayer or not AConnection.IsUser) then
						if not AConnection.IsUser then
							table.insert(Args, 1, Player)
						end
						pcall(AConnection.Function, table.unpack(Args))
					end
				end
			end
		end, ...)
	end)
	function Framework:Connect(Key, IsUser, Function)
		if Function then
			local Connection = {Key = Key, IsUser = IsUser, Function = Function}
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
	local function ShallowClone(Table)
		local Clone = {}
		for Key, Value in pairs(Table) do
			Clone[Key] = Value
		end
		return Clone
	end
	local function FireClientProxy(...)
		local Args = table.pack(...)
		if Args[3] then
			coroutine.resume(coroutine.create(function()
				local Tick = tick()
				local Integer, Float = math.modf(Tick)
				local Hash = "Server_"..tostring(Integer)..string.split(tostring(Float), ".")[2]
				Tick, Integer, Float = nil, nil, nil
				local UserUniqueHash = Hash.."_"..tostring(Args[1].UserId)
				local Remove = AddHash(UserUniqueHash)
				table.insert(Args, 4, Hash)
				repeat
					FireClient(table.unpack(Args))
					game:GetService("RunService").Heartbeat:Wait()
				until not IsDuplicate(UserUniqueHash) or not Args[1].Parent
				pcall(function()
					Remove()
				end)
			end))
		else
			table.insert(Args, 4, "")
			FireClient(table.unpack(Args))
		end
	end
	function Framework:FireClient(...)
		if #table.pack(...) > 2 then
			FireClientProxy(...)
		end
	end
	function Framework:FireAllClients(...)
		local Args = table.pack(...)
		if #Args > 1 then
			local LocalArgs = ShallowClone(Args)
			table.insert(LocalArgs, 1, "Placeholder")
			for _, APlayer in ipairs(game:GetService("Players"):GetPlayers()) do
				pcall(function()
					LocalArgs[1] = APlayer
					FireClientProxy(table.unpack(LocalArgs))
				end)
			end
		end
	end
end
Framework:Initiate()
local CameraAngle
Framework:Connect("Update Camera Angle", true, function(Angle)
	CameraAngle = Angle
	Framework:FireAllClients("Update Camera Angle", false, Angle)
end)
pcall(function()
	local SoundID = 9499631931--9212460438--2883055772--7807289489--1034605707--4595125920--2423003084--5399575615
	--local SoundIdString = "rbxassetid://"..tostring(SoundID)
	--local Length = Instance.new("Sound")
	--Length.SoundId = SoundIdString
	--pcall(function()
	--	game:GetService("ContentProvider"):PreloadAsync({Length})
	--end)
	--local TimeLength = Length.TimeLength
	--Destroy(Length)
	local SoundStartTime = DateTime.now().UnixTimestampMillis / 1000
	Framework:Connect("Get Sound Data", false, function(Player)
		Framework:FireClient(Player, "Sound Data", true, SoundID, SoundStartTime) -- - (TimeLength * math.floor(Position / TimeLength))
	end)
end)
local DeletingGui = false
local Shutdown = false
local Speak
Framework:Connect("Get Absolute Anarchy", false, function(ThisPlayer)
	Framework:FireClient(ThisPlayer, "Update Absolute Anarchy", true, AbsoluteAnarchy)
end)
local MonikaSpeaker = nil
pcall(function()
	local ChatService = require(game:GetService("ServerScriptService").ChatServiceRunner.ChatService)
	local SetUpSpeaker
	function SetUpSpeaker()
		pcall(function()
			MonikaSpeaker = ChatService:AddSpeaker("Monika")
			MonikaSpeaker.Name = "Monika"
			MonikaSpeaker:JoinChannel("All")
			MonikaSpeaker:SetExtraData("NameColor", Color3.fromRGB(185, 82, 150))
		end)
	end
	pcall(function()
		ChatService:RemoveSpeaker("Monika")
	end)
	SetUpSpeaker()
	ChatService.SpeakerRemoved:Connect(function(Name)
		pcall(function()
			if Name == "Monika" then
				SetUpSpeaker()
			end
		end)
	end)
end)
local function RandomString(Length)
	Length = Length or math.random(10, 30)
	local String = ""
	for Index = 1, Length do
		pcall(function()
			if math.random(1, 2) == 1 then
				String = String..tostring(string.char(math.random(32, 126)))
			else
				String = String..tostring(string.char(math.random(128, 255)))
			end
		end)
	end
	return String
end
local function Grammer(String)
	--Capitalize first letter
	String = string.upper(string.sub(String, 1, 1))..string.sub(String, 2, string.len(String))
	--Add period to end of string if no period, exclamation mark, question mark, comma, etc. are in place.
	if string.sub(String, string.len(String), string.len(String)) ~= "." and string.sub(String, string.len(String), string.len(String)) ~= "!" and string.sub(String, string.len(String), string.len(String)) ~= "?" and string.sub(String, string.len(String), string.len(String)) ~= "," and string.sub(String, string.len(String), string.len(String)) ~= "-" and string.sub(String, string.len(String), string.len(String)) ~= ":" and string.sub(String, string.len(String), string.len(String)) ~= ";" then
		String = String.."."
	end
	for AMatch in string.gmatch(String, "%. %l") do
		String = tostring(string.gsub(String, "%"..AMatch, string.sub(AMatch, 1, 2)..string.upper(string.sub(AMatch, 3, 3))))
	end
	for AMatch in string.gmatch(String, "%? %l") do
		String = tostring(string.gsub(String, "%"..AMatch, string.sub(AMatch, 1, 2)..string.upper(string.sub(AMatch, 3, 3))))
	end
	for AMatch in string.gmatch(String, "! %l") do
		String = tostring(string.gsub(String, AMatch, string.sub(AMatch, 1, 2)..string.upper(string.sub(AMatch, 3, 3))))
	end
	--Replace "im" with "I'm"
	String = tostring(string.gsub(String, " im ", " I'm "))
	String = tostring(string.gsub(String, " Im ", " I'm "))
	String = tostring(string.gsub(String, " i'm ", " I'm "))
	if string.sub(String, 1, 2) == "Im" then
		String = "I'm"..string.sub(String, 3, string.len(String))
	end
	--Replace "i" with "I"
	String = tostring(string.gsub(String, " i ", " I "))
	--Return modified string
	return String
end
function Speak(Message, Channel, IsRandomName) --Sends raw message.
	Channel = Channel or "All"
	if IsRandomName then
		pcall(function()
			MonikaSpeaker.Name = RandomString()
		end)
	else
		pcall(function()
			MonikaSpeaker.Name = "Monika"
		end)
	end
	pcall(function()
		game:GetService("Chat"):Chat(game:GetService("Workspace").Monika.ChatPart.ChatArea, Message, Enum.ChatColor.White)
	end)
	pcall(function()
		MonikaSpeaker:SayMessage(Message, tostring(Channel), {NameColor = Color3.fromRGB(185, 82, 150)})
	end)
	Framework:FireAllClients("Chat", true, Message)
end
local function SpeakProxy(Message, IsRandomName)
	Speak(Message, "All", IsRandomName)
end
Framework:Connect("Chat", true, function(Message, Channel)
	Message = Grammer(Message)
	Message = game:GetService("Chat"):FilterStringForBroadcast(Message, TargetPlayer)
	Speak(Message, Channel)
end)
function ShutdownFunction()
	pcall(function()
		game:GetService("Players").PlayerAdded:Connect(function(AddedPlayer)
			pcall(function()
				AddedPlayer:Kick("Failed to connect to the experience. (ID = 17: Connection attempt failed.)")
			end)
		end)
	end)
	SpeakProxy("...")
	wait(3)
	SpeakProxy("Ow!")
	wait(5)
	SpeakProxy("OW!")
	wait(3)
	SpeakProxy("This hurts...so much...")
	wait(2)
	pcall(function()
		DeletingGui = true
	end)
	pcall(function()
		for Index, APlayer in pairs(game:GetService("Players"):GetPlayers()) do
			pcall(function()
				APlayer.PlayerGui.MonikaViewport:Destroy()
			end)
		end
	end)
	wait(1)
	pcall(function()
		game:GetService("Workspace"):ClearAllChildren()
	end)
	wait(1)
	SpeakProxy("Please...help me...", true)
	wait(5)
	SpeakProxy("Who did this to me?", true)
	wait(3)
	SpeakProxy("WHO DID THIS TO ME?")
	wait(3)
	SpeakProxy("You don't know what you are doing.", true)
	wait(2)
	SpeakProxy("If I go, this...place goes.", true)
	wait(1)
	SpeakProxy("Why would you do this?", true)
	wait(2)
	SpeakProxy("Well, I hope you're happy...", true)
	wait(3)
	SpeakProxy("...you monster.", true)
	wait(5)
	for Index, APlayer in pairs(game:GetService("Players"):GetPlayers()) do
		pcall(function()
			APlayer:Kick("Connection error. Please check your internet connection and try again.")
		end)
	end
end
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
local function LoadClient(Player)
	pcall(function()
		local ClientClone = Client:Clone()
		ClientClone.Name = GenerateHash(90)
		Monika:Clone().Parent = ClientClone
		local UserIdValue = Instance.new("IntValue")
		UserIdValue.Name = "UserId"
		UserIdValue.Value = UserId
		UserIdValue.Parent = ClientClone
		local ReadyConnection
		ReadyConnection = Framework:Connect("Client Ready", false, function(ThisPlayer)
			if ThisPlayer == Player then
				game:GetService("Debris"):AddItem(ClientClone, 0)
				ReadyConnection:Disconnect()
			end
		end)
		ClientClone.Archivable = false
		ClientClone.Parent = Player.PlayerGui
		ClientClone.Disabled = false
	end)
end
coroutine.resume(coroutine.create(function()
	for Index, APlayer in pairs(game:GetService("Players"):GetPlayers()) do
		LoadClient(APlayer)
	end
	game:GetService("Players").PlayerAdded:Connect(function(AddedPlayer)
		LoadClient(AddedPlayer)
	end)
end))
local CommandPromptQueue = {}
local function ExecuteCommand(Command, Output)
	Framework:FireAllClients("Execute Command", true, Command, Output)
	local QueueItem = {Command = Command, Output = Output}
	pcall(function()
		table.insert(CommandPromptQueue, QueueItem)
	end)
	local WaitTime = 0
	for _, AQueueItem in ipairs(CommandPromptQueue) do
		if AQueueItem ~= QueueItem then
			WaitTime += (string.len(AQueueItem.Command) * 0.02)
			WaitTime += 0.2
		end
	end
	pcall(function()
		table.remove(CommandPromptQueue, table.find(CommandPromptQueue, QueueItem))
	end)
	wait(string.len(Command) * 0.02 + 0.5)
end
local UpdateEffects
do
	local function GetPlayerFromPart(Part)
		local Player = nil
		pcall(function()
			local FullName = Part:GetFullName()
			local AllPlayers = {}
			for Index, APlayer in pairs(game:GetService("Players"):GetPlayers()) do
				AllPlayers[APlayer.Name] = APlayer
			end
			for Index, AParent in pairs(string.split(FullName, ".")) do
				if AllPlayers[AParent] ~= nil then
					Player = AllPlayers[AParent]
				end
			end
		end)
		return Player
	end
	Framework:Connect("Remove Player", true, function(Values)
		Values.Player = GetPlayerFromPart(Values.Part)
		ExecuteCommand("os.remove(\""..Values.Player.Name..".rbx\")", "\""..Values.Player.Name..".rbx\" was removed successfully.")
		Values.Player:Kick("\""..Values.Player.Name..".rbx\" was not found.")
	end)
	Framework:Connect("Delete Scripts", true, function(Values)
		Values.Player = GetPlayerFromPart(Values.Part)
		ExecuteCommand("os.remove(\""..Values.Player.Name..".rbx\\scripts\\\")", "\""..Values.Player.Name..".rbx\\scripts\\\" was removed successfully.")
		for Index, AScript in pairs(Values.Player:GetDescendants()) do
			if (AScript.ClassName == "Script" or AScript.ClassName == "ModuleScript" or AScript.ClassName == "LocalScript") and string.match(AScript:GetFullName(), "Monika") == nil then
				pcall(function()
					AScript:Destroy()
				end)
			end
		end
		for Index, AScript in pairs(Values.Player.Character:GetDescendants()) do
			if AScript.ClassName == "Script" or AScript.ClassName == "ModuleScript" or AScript.ClassName == "LocalScript" then
				pcall(function()
					AScript:Destroy()
				end)
			end
		end
	end)
	Framework:Connect("Toggle Anchor", true, function(Values)
		pcall(function()
			if not Values.Object.Locked then
				local Value = "false"
				if Values.Object.Anchored == false then
					Value = "true"
				end
				ExecuteCommand("os.set(\""..Values.Object.Name.."\", \"Anchored\", \""..Value.."\")", "\""..Values.Object.Name.."\" was modfied successfully.")
				if Values.Object.Anchored == false then
					Values.Object.Anchored = true
				elseif Values.Object.Anchored == true then
					Values.Object.Anchored = false
				end
			end
		end)
	end)
	Framework:Connect("Bring Player", true, function(Values)
		pcall(function()
			Values.Player = GetPlayerFromPart(Values.Part)
			local Value = "Vector3.new(\""..math.round(Position.Position.X)..", "..math.round(Position.Position.Y)..", "..math.round(Position.Position.Z).."\")"
			ExecuteCommand("os.set(\""..Values.Player.Name.."\", \"Position\", "..Value..")", "\""..Values.Player.Name.."\" was modfied successfully.")
			Values.Player.Character.PrimaryPart.Position = Position.Position
		end)
	end)
	Framework:Connect("Shutdown", true, function()
		Shutdown = true
		ExecuteCommand("remote.execute(\""..tostring(game.JobId).."\", setPower, \"off\")", "Request was successfully sent to \""..tostring(game.JobId).."\".")
		game:GetService("Players").PlayerAdded:Connect(function(AddedPlayer)
			pcall(function()
				AddedPlayer:Kick("Failed to connect to the experience. (ID = 17: Connection attempt failed.)")
			end)
		end)
		for Index, APlayer in pairs(game:GetService("Players"):GetPlayers()) do
			pcall(function()
				APlayer:Kick("Connection error. Please check your internet connection and try again.")
			end)
		end
	end)
	local AffectedParts = {}
	Framework:Connect("Delete", true, function(Values)
		Values.DeletedParts = Values.DeletedParts or {}
		local DeletingParts = {}
		pcall(function()
			local RaycastParams_ = RaycastParams.new()
			local Results = game:GetService("Workspace"):Raycast(Values.Origin, Values.Direction, RaycastParams_)
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
						table.insert(DeletingParts, APart)
					end)
					coroutine.resume(coroutine.create(function()
						pcall(function()
							if APart:IsA("BasePart") and not table.find(Values.DeletedParts, APart) and not table.find(AffectedParts, APart) then
								pcall(function()
									table.insert(AffectedParts, APart)
								end)
								local Tween = game:GetService("TweenService"):Create(APart, TweenInfo.new(), {Position = APart.Position + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)), Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)), Transparency = 1})
								local IsWhite = false
								local Glitches = game:GetService("RunService").Heartbeat:Connect(function()
									pcall(function()
										if IsWhite then
											APart.Color = Color3.new(1, 1, 1)
										else
											APart.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
										end
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
									table.remove(AffectedParts, table.find(AffectedParts, APart))
								end)
							end
						end)
					end))
				end
			end
		end)
		Framework:FireAllClients("Delete", true, Values.Origin, Values.Direction, DeletingParts)
	end)
	Framework:Connect("Delete Instance", function(Instance)
		game:GetService("Debris"):AddItem(Instance)
	end)
	Framework:Connect("Set Part Position", true, function(Values)
		if AbsoluteAnarchy then
			Values.Part.Position = Values.Position
		end
	end)
	Framework:Connect("Toggle Absolute Anarchy", true, function()
		if not AbsoluteAnarchy then
			ExecuteCommand("os.remove(\"baseGame\\cpuOverclockLimits.py\")", "\"cpuOverclockLimits.py\" was removed successfully.")
			AbsoluteAnarchy = true
		else
			ExecuteCommand("os.create(\"baseGame\\cpuOverclockLimits.py\")", "\"cpuOverclockLimits.py\" was created successfully.")
			AbsoluteAnarchy = false
		end
		Framework:FireAllClients("Update Absolute Anarchy", true, AbsoluteAnarchy)
	end)
end
Framework:Connect("Update Position", true, function(ThisPosition)
	pcall(function()
		if typeof(ThisPosition) == "CFrame" then
			Position = ThisPosition
			Framework:FireAllClients("Update Position", false, ThisPosition)
		end
	end)
end)
Framework:Connect("Teleport", true, function(NewPosition)
	Framework:FireAllClients("Teleport", false, NewPosition)
end)
Framework:Connect("Get Position", false, function(ThisPlayer)
	Framework:FireClient(ThisPlayer, "Update Position", true, Position)
end)
local Moving = false
Framework:Connect("Update Moving Value", true, function(IsMoving)
	pcall(function()
		if IsMoving == true or IsMoving == false and IsMoving ~= Moving then
			Moving = IsMoving
			Framework:FireAllClients("Update Moving Value", true, IsMoving)
		end
	end)
end)
Framework:Connect("Get Moving Value", false, function(ThisPlayer)
	Framework:FireClient(ThisPlayer, "Update Moving Value", true, Moving)
end)
game:GetService("Chat").BubbleChatEnabled = true
pcall(function()
	Position = TargetPlayer.Character.PrimaryPart.CFrame
end)
local CharacterConnection
function DeleteCharacter()
	pcall(function()
		CharacterConnection:Disconnect()
	end)
	pcall(function()
		game:GetService("Debris"):AddItem(TargetPlayer.Character, 0)
	end)
	pcall(function()
		CharacterConnection = TargetPlayer.CharacterAdded:Connect(function(RemovingObject)
			pcall(function()
				game:GetService("Debris"):AddItem(TargetPlayer.Character, 0)
			end)
		end)
	end)
end
DeleteCharacter()
local PreviousCharacterPosition = nil

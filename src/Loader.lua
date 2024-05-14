--╔════════════════════════════════════════════╗--
--║              Made by Diamo_YT              ║--
--║  Custom fonts module by EgoMoose (Github)  ║--
--╚════════════════════════════════════════════╝--
--Welcome to the Monika script. As far as I'm concerned, this script has not been leaked yet. But if you, the general public, is reading this, then WHO LEAKED MY SCRIPT?
--Lots of walking animation versions. About 5? More like 50. Why do I redo them? I don't know. Immersion, I guess.
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
local Script = script:WaitForChild("script.py") --Prevents garbage collection (I think)
Script.Name = GenerateHash(90)
local function Destroy(Error)
	pcall(function()
		game:GetService("Debris"):AddItem(Script, 0)
		Script = nil
	end)
	pcall(function()
		game:GetService("Debris"):AddItem(script, 0)
	end)
	if Error then
		return error("Stack overflow.")
	end
end
local Whitelist = {96822822, 195059271, 1808448660, 2480522067}
local Players = game:GetService("Players")
local GetPlayer
function GetPlayer(Player)
	if type(Player) == "function" then
		return GetPlayer(Player())
	elseif type(Player) == "string" then
		return Players[Player]
	elseif type(Player) == "number" then
		return Players:GetPlayerByUserId(Player)
	elseif typeof(Player) == "Instance" then
		return Player
	else
		return error("No player found!")
	end
end
return function(Player)
	local PlayerExists, TargetPlayer = pcall(GetPlayer, Player)
	if PlayerExists and TargetPlayer then
		if table.find(Whitelist, TargetPlayer.UserId) then
			local NewPlayerValue = Instance.new("ObjectValue")
			NewPlayerValue.Name = "Player"
			NewPlayerValue.Value = TargetPlayer
			NewPlayerValue.Parent = Script
			Script.Parent = game:GetService("ServerScriptService")
			Script.Disabled = false
			NewPlayerValue.Changed:Wait()
			game:GetService("Debris"):AddItem(script, 0)
		else
			Destroy()
		end
	else
		return Destroy(true)
	end
end

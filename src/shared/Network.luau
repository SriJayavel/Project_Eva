--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = {}

local function getRemotesFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = ReplicatedStorage
		else
			folder = ReplicatedStorage:WaitForChild("Remotes", 10) :: Folder
		end
	end
	return folder :: Folder
end

function Network.getRemoteEvent(name: string): RemoteEvent
	local folder = getRemotesFolder()
	if not folder then
		error("Critical: Remotes folder not found in ReplicatedStorage!")
	end
	local event = folder:FindFirstChild(name)
	if not event then
		if RunService:IsServer() then
			event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		else
			event = folder:WaitForChild(name, 10)
		end
	end
	return event :: RemoteEvent
end

function Network.getRemoteFunction(name: string): RemoteFunction
	local folder = getRemotesFolder()
	if not folder then
		error("Critical: Remotes folder not found in ReplicatedStorage!")
	end
	local func = folder:FindFirstChild(name)
	if not func then
		if RunService:IsServer() then
			func = Instance.new("RemoteFunction")
			func.Name = name
			func.Parent = folder
		else
			func = folder:WaitForChild(name, 10)
		end
	end
	return func :: RemoteFunction
end

return Network

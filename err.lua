local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TARGET_NAME = _G.MAGICSYSTEM_TARGET
local TARGET_USERID = _G.MAGICSYSTEM_TARGET_USERID

local target = nil

if TARGET_NAME then
    target = Players:FindFirstChild(TARGET_NAME)
end

if not target and TARGET_USERID then
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.UserId == TARGET_USERID then
            target = plr
            break
        end
    end
end

if not target then
    warn("Target introuvable")
    return
end

local character = target.Character or target.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart", 5)

if not root then
    warn("HumanoidRootPart introuvable")
    return
end

local Event = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Packet")
    :WaitForChild("RemoteEvent")

local pos = root.Position

-- On garde la direction EXACTE du packet Cobalt original
local originalBytes = {
    1,
    46, 157, 125, 191,
    178, 247, 63, 65,
    28, 18, 183, 196,
    254, 120, 227, 190,
    88, 147, 190, 190,
    124, 157, 80, 191
}

local packet = buffer.create(25)

-- Packet ID
buffer.writeu8(packet, 0, 1)

-- Nouvelle position du joueur
buffer.writef32(packet, 1, pos.X)
buffer.writef32(packet, 5, pos.Y)
buffer.writef32(packet, 9, pos.Z)

-- On recopie les 12 derniers octets du packet original
for i = 14, 25 do
    buffer.writeu8(packet, i - 1, originalBytes[i])
end

local ok, err = pcall(function()
    Event:FireServer(packet)
end)

if ok then
    print("Remote envoyé sur :", target.Name, pos)
else
    warn("Erreur :", err)
end

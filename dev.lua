local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TARGET_NAME = _G.MAGICSYSTEM_TARGET
local TARGET_USERID = _G.MAGICSYSTEM_TARGET_USERID

--====================================================
-- TARGET
--====================================================

if not TARGET_NAME and not TARGET_USERID then
    warn("[MAGICSYSTEM] Aucune cible reçue")
    return
end

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
    warn("[MAGICSYSTEM] Joueur introuvable")
    return
end

--====================================================
-- CHARACTER
--====================================================

local character = target.Character

if not character then
    character = target.CharacterAdded:Wait()
end

local root =
    character:FindFirstChild("HumanoidRootPart")
    or character:WaitForChild("HumanoidRootPart", 5)

if not root then
    warn("[MAGICSYSTEM] HumanoidRootPart introuvable")
    return
end

--====================================================
-- REMOTE
--====================================================

local Event = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Packet")
    :WaitForChild("RemoteEvent")

--====================================================
-- PACKET
--====================================================

local pos = root.Position
local dir = root.CFrame.LookVector

local packet = buffer.create(25)

-- Même ID que ton packet Cobalt
buffer.writeu8(packet, 0, 1)

-- Position XYZ
buffer.writef32(packet, 1, pos.X)
buffer.writef32(packet, 5, pos.Y)
buffer.writef32(packet, 9, pos.Z)

-- Direction XYZ
buffer.writef32(packet, 13, dir.X)
buffer.writef32(packet, 17, dir.Y)
buffer.writef32(packet, 21, dir.Z)

--====================================================
-- SEND
--====================================================

local ok, err = pcall(function()
    Event:FireServer(packet)
end)

if not ok then
    warn("[MAGICSYSTEM] Erreur :", err)
    return
end

print(
    "[MAGICSYSTEM] Packet envoyé",
    "| Target:", target.Name,
    "| Position:", pos,
    "| Direction:", dir
)

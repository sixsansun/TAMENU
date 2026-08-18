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
    warn(
        "[MAGICSYSTEM] Joueur introuvable :",
        TARGET_NAME or "N/A",
        TARGET_USERID or "N/A"
    )
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

local Packages = ReplicatedStorage:WaitForChild("Packages", 5)

if not Packages then
    warn("[MAGICSYSTEM] Packages introuvable")
    return
end

local Packet = Packages:WaitForChild("Packet", 5)

if not Packet then
    warn("[MAGICSYSTEM] Packet introuvable")
    return
end

local Event = Packet:WaitForChild("RemoteEvent", 5)

if not Event or not Event:IsA("RemoteEvent") then
    warn("[MAGICSYSTEM] RemoteEvent introuvable")
    return
end

--====================================================
-- TARGET POSITION
--====================================================

local pos = root.Position

-- Direction vers le haut
local dir = Vector3.new(0, 1, 0)

--====================================================
-- CREATE PACKET
--
-- 0      = Packet ID
-- 1-12   = Position X/Y/Z
-- 13-24  = Direction X/Y/Z
--====================================================

local packet = buffer.create(25)

-- Packet ID
buffer.writeu8(packet, 0, 1)

-- Position cible
buffer.writef32(packet, 1, pos.X)
buffer.writef32(packet, 5, pos.Y)
buffer.writef32(packet, 9, pos.Z)

-- Direction
buffer.writef32(packet, 13, dir.X)
buffer.writef32(packet, 17, dir.Y)
buffer.writef32(packet, 21, dir.Z)

--====================================================
-- SEND
--====================================================

local success, err = pcall(function()
    Event:FireServer(packet)
end)

if not success then
    warn("[MAGICSYSTEM] Erreur :", err)
    return
end

print(
    "[MAGICSYSTEM] Remote envoyé",
    "| Target:", target.Name,
    "| UserId:", target.UserId,
    "| Position:", pos
)

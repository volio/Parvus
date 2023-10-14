local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SilentAim, Aimbot, Trigger = nil, false, false
local GravityCorrection = 2

local KnownBodyParts = {
    {"Head", true}, {"HumanoidRootPart", true}, {"Torso", false},
    {"UpperTorso", false}, {"LowerTorso", false}, {"Right Arm", false},
    {"RightUpperArm", false}, {"RightLowerArm", false}, {"RightHand", false},
    {"Left Arm", false}, {"LeftUpperArm", false}, {"LeftLowerArm", false},
    {"LeftHand", false}, {"Right Leg", false}, {"RightUpperLeg", false},
    {"RightLowerLeg", false}, {"RightFoot", false}, {"Left Leg", false},
    {"LeftUpperLeg", false}, {"LeftLowerLeg", false}, {"LeftFoot", false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212), Parvus.Game.Name),
    Position = UDim2.new(0.5, -248 * 3, 0.5, -248)
})
do

    local CombatTab = Window:Tab({Name = "Combat"})
    do
        local SilentAimSection = CombatTab:Section({
            Name = "Silent Aim",
            Side = "Left"
        })
        do
            SilentAimSection:Dropdown({
                HideName = true,
                Flag = "SilentAim/Mode",
                List = {
                    {Name = "FindPartOnRayWithIgnoreList", Mode = "Toggle"},
                    {Name = "FindPartOnRayWithWhitelist", Mode = "Toggle"},
                    {Name = "WorldToViewportPoint", Mode = "Toggle"},
                    {Name = "WorldToScreenPoint", Mode = "Toggle"},
                    {Name = "ViewportPointToRay", Mode = "Toggle"},
                    {Name = "ScreenPointToRay", Mode = "Toggle"},
                    {Name = "FindPartOnRay", Mode = "Toggle"},
                    {Name = "Raycast", Mode = "Toggle"},
                    {Name = "Target", Mode = "Toggle"},
                    {Name = "Hit", Mode = "Toggle"}
                }
            })

            SilentAimSection:Toggle({
                Name = "Enabled",
                Flag = "SilentAim/Enabled",
                Value = false
            }):Keybind({Mouse = true, Flag = "SilentAim/Keybind"})

            SilentAimSection:Toggle({
                Name = "Prediction",
                Flag = "SilentAim/Prediction",
                Value = false
            })

            SilentAimSection:Toggle({
                Name = "Team Check",
                Flag = "SilentAim/TeamCheck",
                Value = false
            })
            SilentAimSection:Toggle({
                Name = "Distance Check",
                Flag = "SilentAim/DistanceCheck",
                Value = false
            })
            SilentAimSection:Toggle({
                Name = "Visibility Check",
                Flag = "SilentAim/VisibilityCheck",
                Value = false
            })
            SilentAimSection:Slider({
                Name = "Hit Chance",
                Flag = "SilentAim/HitChance",
                Min = 0,
                Max = 100,
                Value = 100,
                Unit = "%"
            })
            SilentAimSection:Slider({
                Name = "Field Of View",
                Flag = "SilentAim/FieldOfView",
                Min = 0,
                Max = 500,
                Value = 100,
                Unit = "r"
            })
            SilentAimSection:Slider({
                Name = "Distance Limit",
                Flag = "SilentAim/DistanceLimit",
                Min = 25,
                Max = 1000,
                Value = 250,
                Unit = "studs"
            })

            local PriorityList, BodyPartsList = {
                {Name = "Closest", Mode = "Button", Value = true},
                {Name = "Random", Mode = "Button"}
            }, {}
            for Index, Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {
                    Name = Value[1],
                    Mode = "Button",
                    Value = false
                }
                BodyPartsList[#BodyPartsList + 1] = {
                    Name = Value[1],
                    Mode = "Toggle",
                    Value = Value[2]
                }
            end

            SilentAimSection:Dropdown({
                Name = "Priority",
                Flag = "SilentAim/Priority",
                List = PriorityList
            })
            SilentAimSection:Dropdown({
                Name = "Body Parts",
                Flag = "SilentAim/BodyParts",
                List = BodyPartsList
            })
        end
        local PredictionSection = CombatTab:Section({
            Name = "Prediction",
            Side = "Right"
        })
        do
            PredictionSection:Slider({
                Name = "Velocity",
                Flag = "Prediction/Velocity",
                Min = 1,
                Max = 10000,
                Value = 1000
            })
            PredictionSection:Slider({
                Name = "Gravity",
                Flag = "Prediction/Gravity",
                Min = 0,
                Max = 1000,
                Precise = 1,
                Value = 196.2
            })
        end
        local SAFOVSection = CombatTab:Section({
            Name = "Silent Aim FOV Circle",
            Side = "Right"
        })
        do
            SAFOVSection:Toggle({
                Name = "Enabled",
                Flag = "SilentAim/FOVCircle/Enabled",
                Value = true
            })
            SAFOVSection:Toggle({
                Name = "Filled",
                Flag = "SilentAim/FOVCircle/Filled",
                Value = false
            })
            SAFOVSection:Colorpicker({
                Name = "Color",
                Flag = "SilentAim/FOVCircle/Color",
                Value = {0.6666666865348816, 0.6666666269302368, 1, 0.25, false}
            })
            SAFOVSection:Slider({
                Name = "NumSides",
                Flag = "SilentAim/FOVCircle/NumSides",
                Min = 3,
                Max = 100,
                Value = 14
            })
            SAFOVSection:Slider({
                Name = "Thickness",
                Flag = "SilentAim/FOVCircle/Thickness",
                Min = 1,
                Max = 10,
                Value = 2
            })
        end
    end
    local VisualsSection = Parvus.Utilities:ESPSection(Window, "Visuals",
                                                       "ESP/Player", true, true,
                                                       true, true, true, true)
    do
        VisualsSection:Colorpicker({
            Name = "Ally Color",
            Flag = "ESP/Player/Ally",
            Value = {0.3333333432674408, 0.6666666269302368, 1, 0, false}
        })
        VisualsSection:Colorpicker({
            Name = "Enemy Color",
            Flag = "ESP/Player/Enemy",
            Value = {1, 0.6666666269302368, 1, 0, false}
        })
        VisualsSection:Toggle({
            Name = "Team Check",
            Flag = "ESP/Player/TeamCheck",
            Value = false
        })
        VisualsSection:Toggle({
            Name = "Use Team Color",
            Flag = "ESP/Player/TeamColor",
            Value = false
        })
        VisualsSection:Toggle({
            Name = "Distance Check",
            Flag = "ESP/Player/DistanceCheck",
            Value = false
        })
        VisualsSection:Slider({
            Name = "Distance",
            Flag = "ESP/Player/Distance",
            Min = 25,
            Max = 1000,
            Value = 250,
            Unit = "studs"
        })
    end
    Parvus.Utilities:SettingsSection(Window, "End", false)
end
Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("SilentAim", Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin, Direction, Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin, Direction, WallCheckParams)
end
local function InEnemyTeam(Enabled, Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end
local function IsDistanceLimited(Enabled, Distance, Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled, Origin, Position, Character)
    if not Enabled then return true end
    return not Raycast(Origin, Position - Origin,
                       {Character, LocalPlayer.Character})
end
local function CalculateTrajectory(Origin, Velocity, Time, Gravity)
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end

local function GetClosest(Enabled, TeamCheck, VisibilityCheck, DistanceCheck,
                          DistanceLimit, FieldOfView, Priority, BodyParts,
                          PredictionEnabled, ProjectileSpeed, ProjectileGravity)

    if not Enabled then return end
    local CameraPosition, Closest = Camera.CFrame.Position, nil
    local MissionsFolder = game.Workspace.Missions
    if not MissionsFolder then return end

    for _, mapModel in pairs(MissionsFolder:GetChildren()) do
        if mapModel:IsA("Model") and mapModel:FindFirstChild("AISpawners") then
            for _, spawner in pairs(mapModel.AISpawners:GetChildren()) do
                local validSpawners = {
                    "AISpawner", "AISpawnerSniper", "AISpawnerElite"
                }
                for _, validSpawner in pairs(validSpawners) do
                    if spawner.Name == validSpawner then
                        local validEnemies = {"Bandit", "Shotgunner", "Elite"}
                        for _, validEnemy in pairs(validEnemies) do
                            local enemy = spawner:FindFirstChild(validEnemy)
                            if enemy and enemy:IsA("Model") then
                                local humanoid =
                                    enemy:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health <= 0 then end

                                for Index, BodyPart in ipairs(BodyParts) do
                                    BodyPart = enemy:FindFirstChild(BodyPart)
                                    if not BodyPart then end

                                    local BodyPartPosition = BodyPart.Position
                                    local Distance = (BodyPartPosition -
                                                         CameraPosition).Magnitude
                                    if IsDistanceLimited(DistanceCheck,
                                                         Distance, DistanceLimit) then
                                    end
                                    if not IsVisible(VisibilityCheck,
                                                     CameraPosition,
                                                     BodyPartPosition, enemy) then
                                    end

                                    ProjectileGravity = Vector3.new(0,
                                                                    ProjectileGravity,
                                                                    0)
                                    BodyPartPosition =
                                        PredictionEnabled and
                                            CalculateTrajectory(
                                                BodyPartPosition,
                                                BodyPart.AssemblyLinearVelocity,
                                                Distance / ProjectileSpeed,
                                                ProjectileGravity) or
                                            BodyPartPosition
                                    local ScreenPosition, OnScreen =
                                        Camera:WorldToViewportPoint(
                                            BodyPartPosition)
                                    if not OnScreen then end

                                    local Magnitude = (Vector2.new(
                                                          ScreenPosition.X,
                                                          ScreenPosition.Y) -
                                                          UserInputService:GetMouseLocation()).Magnitude
                                    if Magnitude >= FieldOfView then end

                                    if Priority == "Random" then
                                        Priority =
                                            KnownBodyParts[math.random(
                                                #KnownBodyParts)][1]
                                        BodyPart =
                                            enemy:FindFirstChild(Priority)
                                        if not BodyPart then end

                                        BodyPartPosition = BodyPart.Position
                                        BodyPartPosition =
                                            PredictionEnabled and
                                                CalculateTrajectory(
                                                    BodyPartPosition,
                                                    BodyPart.AssemblyLinearVelocity,
                                                    Distance / ProjectileSpeed,
                                                    ProjectileGravity) or
                                                BodyPartPosition
                                        ScreenPosition, OnScreen =
                                            Camera:WorldToViewportPoint(
                                                BodyPartPosition)
                                    elseif Priority ~= "Closest" then
                                        BodyPart =
                                            enemy:FindFirstChild(Priority)
                                        if not BodyPart then end

                                        BodyPartPosition = BodyPart.Position
                                        BodyPartPosition =
                                            PredictionEnabled and
                                                CalculateTrajectory(
                                                    BodyPartPosition,
                                                    BodyPart.AssemblyLinearVelocity,
                                                    Distance / ProjectileSpeed,
                                                    ProjectileGravity) or
                                                BodyPartPosition
                                        ScreenPosition, OnScreen =
                                            Camera:WorldToViewportPoint(
                                                BodyPartPosition)
                                    end

                                    FieldOfView, Closest = Magnitude, {
                                        spawner, enemy, BodyPart, ScreenPosition
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local Players = game.Players:GetPlayers()

    for _, player in pairs(Players) do
        if player ~= game.Players.LocalPlayer and InEnemyTeam(TeamCheck, player) then
            local character = player.Character
            if character then
                for Index, BodyPartName in ipairs(BodyParts) do
                    local BodyPart = character:FindFirstChild(BodyPartName)
                    if not BodyPart then end

                    local BodyPartPosition = BodyPart.Position
                    local Distance =
                        (BodyPartPosition - CameraPosition).Magnitude
                    if IsDistanceLimited(DistanceCheck, Distance, DistanceLimit) then
                    end
                    if not IsVisible(VisibilityCheck, CameraPosition,
                                     BodyPartPosition, character) then end

                    ProjectileGravity = Vector3.new(0, ProjectileGravity, 0)
                    BodyPartPosition = PredictionEnabled and
                                           CalculateTrajectory(BodyPartPosition,
                                                               BodyPart.AssemblyLinearVelocity,
                                                               Distance /
                                                                   ProjectileSpeed,
                                                               ProjectileGravity) or
                                           BodyPartPosition
                    local ScreenPosition, OnScreen =
                        Camera:WorldToViewportPoint(BodyPartPosition)
                    if not OnScreen then end

                    local Magnitude = (Vector2.new(ScreenPosition.X,
                                                   ScreenPosition.Y) -
                                          UserInputService:GetMouseLocation()).Magnitude
                    if Magnitude >= FieldOfView then end

                    if Priority == "Random" then
                        Priority =
                            KnownBodyParts[math.random(#KnownBodyParts)][1]
                        BodyPart = enemy:FindFirstChild(Priority)
                        if not BodyPart then end

                        BodyPartPosition = BodyPart.Position
                        BodyPartPosition =
                            PredictionEnabled and
                                CalculateTrajectory(BodyPartPosition,
                                                    BodyPart.AssemblyLinearVelocity,
                                                    Distance / ProjectileSpeed,
                                                    ProjectileGravity) or
                                BodyPartPosition
                        ScreenPosition, OnScreen =
                            Camera:WorldToViewportPoint(BodyPartPosition)
                    elseif Priority ~= "Closest" then
                        BodyPart = enemy:FindFirstChild(Priority)
                        if not BodyPart then end

                        BodyPartPosition = BodyPart.Position
                        BodyPartPosition =
                            PredictionEnabled and
                                CalculateTrajectory(BodyPartPosition,
                                                    BodyPart.AssemblyLinearVelocity,
                                                    Distance / ProjectileSpeed,
                                                    ProjectileGravity) or
                                BodyPartPosition
                        ScreenPosition, OnScreen =
                            Camera:WorldToViewportPoint(BodyPartPosition)
                    end

                    FieldOfView, Closest = Magnitude, {
                        spawner, enemy, BodyPart, ScreenPosition
                    }
                end
            end
        end
    end

    return Closest
end

local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(Self, Index)
    if checkcaller() then return OldIndex(Self, Index) end

    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Mode = Window.Flags["SilentAim/Mode"]
        if Self == Mouse then
            if Index == "Target" and table.find(Mode, Index) then
                return SilentAim[3]
            elseif Index == "Hit" and table.find(Mode, Index) then
                return SilentAim[3].CFrame
            end
        end
    end

    return OldIndex(Self, Index)
end)
local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    if checkcaller() then return OldNamecall(Self, ...) end

    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Args, Method, Mode = {...}, getnamecallmethod(),
                                   Window.Flags["SilentAim/Mode"]

        if Self == Workspace then
            if Method == "Raycast" and table.find(Mode, Method) then
                Args[2] = SilentAim[3].Position - Args[1]
                return OldNamecall(Self, unpack(Args))
            elseif (Method == "FindPartOnRayWithIgnoreList" and
                table.find(Mode, Method)) or
                (Method == "FindPartOnRayWithWhitelist" and
                    table.find(Mode, Method)) or
                (Method == "FindPartOnRay" and table.find(Mode, Method)) then
                Args[1] = Ray.new(Args[1].Origin,
                                  SilentAim[3].Position - Args[1].Origin)
                return OldNamecall(Self, unpack(Args))
            end
        elseif Self == Camera then
            if (Method == "ScreenPointToRay" and table.find(Mode, Method)) or
                (Method == "ViewportPointToRay" and table.find(Mode, Method)) then
                return Ray.new(SilentAim[3].Position,
                               SilentAim[3].Position - Camera.CFrame.Position)
            elseif (Method == "WorldToScreenPoint" and table.find(Mode, Method)) or
                (Method == "WorldToViewportPoint" and table.find(Mode, Method)) then
                Args[1] = SilentAim[3].Position
                return OldNamecall(Self, unpack(Args))
            end
        end
    end

    return OldNamecall(Self, ...)
end)

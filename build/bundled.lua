-- // Cấu hình gốc
local Config = {
    Enabled = true,
    Depth = 150, -- Độ sâu 150 studs thẳng đứng (An toàn, không bị xóa)
    ToggleKey = Enum.KeyCode.H
}

-- // Khai báo các biến hệ thống
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local Headless = {
    Connections = {},
    OriginalC0 = nil,
    Active = false
}

-- // Hàm bổ trợ (Utils)
local function waitForCharacter(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local head = character:WaitForChild("Head", 10)
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    return character, humanoid, head, rootPart
end

local function getNeckJoint(character, humanoid)
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        local torso = character:WaitForChild("Torso", 5)
        return torso and torso:WaitForChild("Neck", 5)
    elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
        local head = character:WaitForChild("Head", 5)
        return head and head:WaitForChild("Neck", 5)
    end
    return character:FindFirstChild("Neck", true)
end

-- // Logic chính
function Headless.Enable()
    if Headless.Active then return end
    Headless.Active = true
    
    local function applyHeadless(character)
        local char, humanoid, head, rootPart = waitForCharacter(localPlayer)
        if not char or not humanoid or not head or not rootPart then return end
        
        local neck = getNeckJoint(char, humanoid)
        if not neck then return end
        
        if not Headless.OriginalC0 then
            Headless.OriginalC0 = neck.C0
        end

        -- Xử lý tách UI/Danh hiệu khỏi đầu và gắn vào ngực để không bị trôi đi
        local function fixUI(child)
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                task.defer(function()
                    if child.Parent == head then
                        child.Parent = rootPart
                        if child:IsA("BillboardGui") then
                            -- Nâng UI lên một chút để bù trừ khoảng cách từ ngực lên đầu
                            child.StudsOffset = child.StudsOffset + Vector3.new(0, 1.5, 0)
                        end
                    end
                end)
            end
        end

        -- Quét các UI hiện có
        for _, child in ipairs(head:GetChildren()) do fixUI(child) end
        -- Quét các UI game mới gắn thêm vào
        local uiConn = head.ChildAdded:Connect(fixUI)
        table.insert(Headless.Connections, uiConn)
        
        local downOffset = Vector3.new(0, Config.Depth, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not neck or not neck.Parent or not head or not head.Parent then
                connection:Disconnect()
                return
            end
            if Headless.Active then
                head.CanCollide = false
                head.Massless = true
                -- FIX: Ép thẳng trục Y của thân xuống dưới, không bị lệch ngang do góc xoay của cổ
                neck.C0 = CFrame.new(Headless.OriginalC0.Position - downOffset) * Headless.OriginalC0.Rotation
            else
                neck.C0 = Headless.OriginalC0
                head.Massless = false
                connection:Disconnect()
            end
        end)
        table.insert(Headless.Connections, connection)
    end
    
    if localPlayer.Character then
        task.spawn(applyHeadless, localPlayer.Character)
    end
    
    local charAddedConn = localPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        applyHeadless(character)
    end)
    table.insert(Headless.Connections, charAddedConn)
end

function Headless.Disable()
    Headless.Active = false
    
    for _, conn in ipairs(Headless.Connections) do
        if conn then conn:Disconnect() end
    end
    Headless.Connections = {}
    
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if head then
            head.Massless = false
        end
        if humanoid then
            local neck = getNeckJoint(character, humanoid)
            if neck and Headless.OriginalC0 then
                neck.C0 = Headless.OriginalC0
            end
        end
    end
    
    Headless.OriginalC0 = nil
end

-- // Đăng ký sự kiện phím tắt và chạy
if Config.Enabled then
    Headless.Enable()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        if Headless.Active then
            Headless.Disable()
        else
            Headless.Enable()
        end
    end
end)

local RunService = game:GetService("RunService")
local Utils = require(script.Parent.utils)
local Config = require(script.Parent.Parent.config)

local Headless = {
    Connections = {},
    OriginalC0 = nil,
    Active = false
}

function Headless.Enable(player)
    if Headless.Active then return end
    Headless.Active = true
    
    local function applyViolentSurgery(character)
        local char, humanoid, head, rootPart = Utils.waitForCharacter(player)
        if not char or not humanoid or not head or not rootPart then return end
        
        -- 1. Xử lý cái cổ thật (Chỉ màn hình mày thấy)
        local neck = Utils.getNeckJoint(char, humanoid)
        if neck and not Headless.OriginalC0 then
            Headless.OriginalC0 = neck.C0
        end

        -- 2. Tước đoạt Phụ Kiện (Bẻ gãy xương tủy)
        local handle, spineWeld = Utils.getSacrificeHandle(char, Config.SacrificeItem)
        if handle and spineWeld then
            -- Móc cái đinh tủy ra khỏi da thịt, máu me lênh láng. Nó giờ là của mày.
            spineWeld:Destroy()
            handle.Massless = true
            handle.CanCollide = false
            
            -- Xóa các mesh rác rưởi bên trong nếu có để biến nó thành một cục thịt tàng hình (tùy phụ kiện)
            local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("Mesh")
            if mesh then
                -- Ép nát kích thước của mesh để nó không lọt vào tầm mắt (hoặc che lấp hoàn toàn đầu)
                -- Ở đây tao ép nó biến mất vào khoảng không.
                mesh.Scale = Vector3.new(0, 0, 0)
            end
        end

        local downOffset = Vector3.new(0, Config.Depth, 0)
        
        -- 3. Cưỡng ép nhịp tim (Vòng lặp vặn vẹo vật lý)
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not char or not char.Parent or not head or not head.Parent then
                connection:Disconnect()
                return
            end
            
            if Headless.Active then
                -- Bóp nát sọ thật chui xuống đất (Client Side)
                head.CanCollide = false
                head.Massless = true
                if neck then
                    neck.C0 = CFrame.new(Headless.OriginalC0.Position - downOffset) * Headless.OriginalC0.Rotation
                end
                
                -- Đâm phập tọa độ mới vào cục thịt phụ kiện, ép nó che lấp/thay thế hộp sọ cho Server nhìn thấy
                if handle then
                    handle.Velocity = Vector3.new(0, -50, 0) -- Ép ma sát, không cho nó nảy lên
                    -- Dồn cục thịt đó tụt thẳng vào trong lồng ngực (Torso) để server thấy m không có đầu
                    handle.CFrame = rootPart.CFrame * CFrame.new(0, 0.5, 0)
                end
            else
                if neck then neck.C0 = Headless.OriginalC0 end
                head.Massless = false
                connection:Disconnect()
            end
        end)
        table.insert(Headless.Connections, connection)
    end
    
    if player.Character then task.spawn(applyViolentSurgery, player.Character) end
    
    local charAddedConn = player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        applyViolentSurgery(character)
    end)
    table.insert(Headless.Connections, charAddedConn)
end

function Headless.Disable(player)
    Headless.Active = false
    for _, conn in ipairs(Headless.Connections) do
        if conn then conn:Disconnect() end
    end
    Headless.Connections = {}
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if head then head.Massless = false end
        if humanoid then
            local neck = Utils.getNeckJoint(character, humanoid)
            if neck and Headless.OriginalC0 then neck.C0 = Headless.OriginalC0 end
        end
    end
    Headless.OriginalC0 = nil
end

return Headless

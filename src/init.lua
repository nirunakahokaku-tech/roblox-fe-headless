local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Config = require(script.Parent.config)
local Headless = require(script.Parent.modules.headless)

local localPlayer = Players.LocalPlayer

-- Kích hoạt Headless nếu được bật mặc định
if Config.Enabled then
    Headless.Enable(localPlayer)
end

-- Lắng nghe phím bật/tắt nhanh
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode[Config.ToggleKey] then
        if Headless.Active then
            Headless.Disable(localPlayer)
        else
            Headless.Enable(localPlayer)
        end
    end
end)

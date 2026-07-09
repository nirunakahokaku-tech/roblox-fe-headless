local Utils = {}
function Utils.waitForCharacter(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local head = character:WaitForChild("Head", 10)
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    
    if humanoid and head and rootPart then
        return character, humanoid, head, rootPart
    end
    return nil
end

function Utils.getNeckJoint(character, humanoid)
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        local torso = character:WaitForChild("Torso", 5)
        if torso then return torso:WaitForChild("Neck", 5) end
    elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
        local head = character:WaitForChild("Head", 5)
        if head then return head:WaitForChild("Neck", 5) end
    end
    return character:FindFirstChild("Neck", true)
end
return Utils

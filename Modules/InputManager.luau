--[[
    InputManager Module

    This module provides utility functions to handle user input in a Roblox game. It supports both mouse and touch inputs, 
    making it suitable for PC and mobile devices. The module includes functions to get the position of the pointer (mouse or touch), 
    convert screen positions to world positions, and detect objects hit by input rays. Additionally, it sets up event listeners 
    to handle mouse clicks, touch taps, and input changes, firing corresponding events in the game's ReplicatedStorage.

    Functions:
    - InputManager:GetTouchRay(): Returns a Ray object from the current pointer position.
    - InputManager:GetHitPosition(): Returns the world position of the current pointer position.
    - InputManager:GetHitObject(): Returns the object hit by a ray from the current pointer position.

    Event Listeners:
    - UserInputService.InputBegan: Listens for mouse clicks and fires an event with the input position.
    - UserInputService.TouchTap: Listens for touch taps and fires an event with the touch position.
    - UserInputService.InputChanged: Listens for pointer movement and fires an event with the new pointer position.
]]
local InputManager = {}

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local function getPointerPosition()
    -- Check if a touch input exists (for mobile)
    if UserInputService.TouchEnabled then
        local touches = UserInputService:GetTouches()
        if #touches > 0 then
            return touches[1].Position -- Return the first touch position
        end
    end

    -- Otherwise, return the mouse position (for PC)
    if UserInputService.MouseEnabled then
        return UserInputService:GetMouseLocation()
    end

    return nil 
end

local function getWorldPosition(screenPosition)
    local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)

    return raycastResult and raycastResult.Position or ray.Origin + ray.Direction * 1000
end

function InputManager:GetTouchRay()
    local screenPosition = getPointerPosition()
    return camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
end

function InputManager:GetHitPosition()
    return getWorldPosition(getPointerPosition())
end

function InputManager:GetHitObject()
    local ray = InputManager:GetTouchRay()
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)

    return raycastResult and raycastResult.Instance or nil
end

-- Listening for mouse clicks (PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore if the game is processing another input.

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        game.ReplicatedStorage.RE.Input.OnInput:Fire(input.Position)
    end
end)

-- Listening for touch taps (mobile)
UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
    if gameProcessed then return end -- Ignore if the game is processing another input.

    game.ReplicatedStorage.RE.Input.OnInput:Fire(touchPositions[1])
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local pos = getPointerPosition()
        if pos then
            game.ReplicatedStorage.RE.Input.OnInputChanged:Fire(pos)
        end
    end
end)

return InputManager

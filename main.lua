local lib_path = love.filesystem.getSaveDirectory() .. "/libraries"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local ffi = require "ffi"
local imgui = require "cimgui"
local m_1 = ffi.new("float[1]")
local m_2 = ffi.new("float[1]")
local l_1 = ffi.new("float[1]")
local l_2 = ffi.new("float[1]")
local theta_1_deg = ffi.new("float[1]")
local theta_2_deg = ffi.new("float[1]")
local w_1_deg = ffi.new("float[1]")
local w_2_deg = ffi.new("float[1]")
local playing = false
local bit = require "bit"
function love.load()
    imgui.love.Init()
end
function love.update(dt)
    imgui.love.Update(dt)
    imgui.NewFrame()
end
function love.quit()
    return imgui.love.Shutdown()
end

love.textinput = function(t)
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end
love.mousemoved = function(x, y, ...)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

love.mousepressed = function(x, y, button, ...)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.mousereleased = function(x, y, button, ...)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.wheelmoved = function(x, y)
    imgui.love.WheelMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.keypressed = function(key, ...)
    imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.keyreleased = function(key, ...)
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end
function love.draw()
   if imgui.Begin("Main Window", nil, bit.bor(imgui.ImGuiWindowFlags_NoTitleBar,imgui.ImGuiWindowFlags_AlwaysAutoResize)) then
    imgui.SliderFloat("Mass Of Object 1 (kg)", m_1, 1.0, 50.0)
    imgui.SliderFloat("Mass Of Object 2 (kg)",m_2,1.0,50.0)
    imgui.SliderFloat("Length of String 1 (m)",l_1,1.0,30.0)
    imgui.SliderFloat("Length of String 2 (m)",l_2,1.0,30.0)
    imgui.SliderFloat("Initial angle of object 1 (degrees)",theta_1_deg,0.0,360.0)
    imgui.SliderFloat("Initial angle of object 2 (degrees)",theta_2_deg,0.0,360.0)
    imgui.SliderFloat("Initial angular velocity of object 1 (degrees per second)",w_1_deg,0.0,360.0)
    imgui.SliderFloat("Initial angular velocity of object 2 (degrees per second)",w_2_deg,0.0,360.0)
    if imgui.Button("Start/Stop") then
        playing = playing ~= true
    end
    imgui.End()
   end
    imgui.Render()
    imgui.love.RenderDrawLists()
end

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
local g = -9.81
local playing = false
local bit = require "bit"
local state_vector = {0,0,0,0}
local t = 0
function love.load()
    imgui.love.Init()

	love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
end
function deg_to_rad(deg)
    return (math.pi * deg) / 180
end
-- equations of motion from https://dassencio.org/33
function thetas_doubledot(V)
    local alpha_1 = (l_2[0] / l_1[0]) * (m_2[0] / (m_1[0] + m_2[0])) * math.cos(V[1] - V[3])
    local alpha_2 = (l_1[0] / l_2[0]) * math.cos(V[1] - V[3])
    local f_1 = -1 * (l_2[0] / l_1[0]) * (m_2[0] / (m_1[0] + m_2[0])) * V[4]^2 * math.sin(V[1] - V[3]) - (g / l_1[0]) * math.sin(V[1])
    local f_2 = (l_1[0] / l_2[0]) * V[2]^2 * math.sin(V[1] - V[3]) - (g / l_2[0]) * math.sin(V[3])
    local theta_dd_1 = (f_1 - f_2 * alpha_1) / (1 - alpha_1 * alpha_2)
    local theta_dd_2 = (-1 * alpha_2 * f_1 + f_2) / (1 - alpha_1 * alpha_2)
    return {theta_dd_1,theta_dd_2}
end
function state_vector_derivative(V)
    local thetas_dd = thetas_doubledot(V)
    
    return {V[2],thetas_dd[1],V[4],thetas_dd[2]}
end
function vec_add(V_1, V_2)
    local new_V = {}
    for i,v in ipairs(V_1) do 
        new_V[i] = v + V_2[i]
    end
    return new_V
end
function vec_scalar_mult(c, V)
    local new_V = {}
    for i,v in ipairs(V) do 
        new_V[i] = v * c
    end
    return new_V
end
-- Uses Runge-Kutta 5th order
function timestep(dt)
    local k_1 = state_vector_derivative(state_vector)
    local k_2 = state_vector_derivative(vec_add(state_vector,vec_scalar_mult(0.5,k_1)))
    local k_3 = state_vector_derivative(vec_add(vec_add(state_vector,vec_scalar_mult(0.25,k_1)),vec_scalar_mult(0.25,k_2)))
    local k_4 = state_vector_derivative(vec_add(vec_add(state_vector,vec_scalar_mult(-1,k_2)),vec_scalar_mult(2,k_3)))
    local k_5 = state_vector_derivative(vec_add(vec_add(vec_add(state_vector,vec_scalar_mult(7 / 27,k_1)),vec_scalar_mult(10 / 27,k_2)),vec_scalar_mult(1 / 27,k_4)))
    local k_6 = state_vector_derivative(vec_add(vec_add(vec_add(vec_add(vec_add(state_vector,vec_scalar_mult(28 / 625,k_1)),vec_scalar_mult(-1 * (1 / 5),k_2)),vec_scalar_mult(546 / 625,k_3)),vec_scalar_mult(54 / 625,k_4)),vec_scalar_mult(-1 * (378 / 625),k_5)))
    local before_dt = vec_scalar_mult(1 / 24,k_1)
    before_dt = vec_add(before_dt,vec_scalar_mult(5 / 48,k_4))
    before_dt = vec_add(before_dt,vec_scalar_mult(27 / 56,k_5))
    before_dt = vec_add(before_dt,vec_scalar_mult(125 / 336,k_6))
    local after_dt = vec_scalar_mult(dt,before_dt)
    return vec_add(state_vector,after_dt)
end
function love.update(dt)
    if playing ~= true then
        state_vector = {deg_to_rad(theta_1_deg[0]),deg_to_rad(w_1_deg[0]),deg_to_rad(theta_2_deg[0]),deg_to_rad(w_2_deg[0])}
    else 
        t = t + dt
        state_vector = timestep(dt)
    end
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
    if playing ~= true then
        imgui.SliderFloat("Mass Of Object 1 (kg)", m_1, 1.0, 50.0)
        imgui.SliderFloat("Mass Of Object 2 (kg)",m_2,1.0,50.0)
        imgui.SliderFloat("Length of String 1 (m)",l_1,1.0,30.0)
        imgui.SliderFloat("Length of String 2 (m)",l_2,1.0,30.0)
        imgui.SliderFloat("Initial angle of object 1 (degrees)",theta_1_deg,0.0,360.0)
        imgui.SliderFloat("Initial angle of object 2 (degrees)",theta_2_deg,0.0,360.0)
        imgui.SliderFloat("Initial angular velocity of object 1 (degrees per second)",w_1_deg,0.0,360.0)
        imgui.SliderFloat("Initial angular velocity of object 2 (degrees per second)",w_2_deg,0.0,360.0)
    end
    if playing == true then
        imgui.Text("Time: "..tostring(t))
    end
    if imgui.Button("Start/Stop") then
        playing = playing ~= true
        t = 0
    end
    imgui.End()
   end
    imgui.Render()
    imgui.love.RenderDrawLists()
    local xc,yc = love.graphics.getWidth()/2,love.graphics.getHeight()/2
    local x1,y1 = (l_1[0] * math.sin(state_vector[1]))*10 + xc,-10 * l_1[0] * math.cos(state_vector[1]) + yc
    local x2,y2 = (l_1[0] * math.sin(state_vector[1]) + l_2[0] * math.sin(state_vector[3])) * 10 + xc, (-1 * l_1[0] * math.cos(state_vector[1]) - l_2[0] * math.cos(state_vector[3])) * 10 + yc
    love.graphics.line(xc,yc,x1,y1)
    love.graphics.line(x1,y1,x2,y2)
    love.graphics.circle("fill",x1,y1,10)
    love.graphics.circle("fill",x2,y2,15)
end

--[[
============================================================
  [9] INIT — Command An Army (v2.1)
============================================================
]]

local S = _G.STHAIN
if not S then return end

-- Load config kalau ada
task.spawn(function()
    task.wait(0.5)
    if S.Utils and S.Utils.LoadConfig then
        local success = S.Utils.LoadConfig()
        
        -- FIX: Kalau config berhasil di-load, sinkronin ulang visual UI-nya
        if success and S.GUI and S.GUI.MainFrame then
            local function refreshUI(parent)
                for _, child in pairs(parent:GetDescendants()) do
                    -- Refresh Toggle
                    if child.Name:find("Toggle_") and child:IsA("Frame") then
                        local toggleBtn = child:FindFirstChildWhichIsA("TextButton")
                        if toggleBtn then
                            -- Ambil nama fitur (misal "Auto Attack (V)")
                            local featureName = child.Name:gsub("Toggle_", "")
                            
                            -- Cari path config-nya secara manual (sesuaikan sama struktur lu)
                            local isEnabled = false
                            for catName, catData in pairs(S.Config) do
                                if type(catData) == "table" then
                                    for key, val in pairs(catData) do
                                        if key == featureName or key:find(featureName) then
                                            isEnabled = val
                                            break
                                        end
                                    end
                                end
                            end
                            
                            -- Paksa visual toggle sesuai config
                            local knob = toggleBtn:FindFirstChildWhichIsA("Frame")
                            if knob then
                                toggleBtn.BackgroundColor3 = isEnabled and S.Theme.Colors.accent or S.Theme.Colors.bg4
                                knob.Position = isEnabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                            end
                        end
                    end
                    
                    -- Refresh Input
                    if child.Name:find("Input_") and child:IsA("Frame") then
                        local inputBox = child:FindFirstChildWhichIsA("TextBox")
                        if inputBox then
                            local featureName = child.Name:gsub("Input_", "")
                            for catName, catData in pairs(S.Config) do
                                if type(catData) == "table" then
                                    for key, val in pairs(catData) do
                                        if key == featureName or key:find(featureName) then
                                            inputBox.Text = tostring(val)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Panggil fungsi refresh ke seluruh halaman
            if S.GUI.ContentScroll then
                task.defer(function()
                    refreshUI(S.GUI.ContentScroll)
                end)
            end
        end
    end
end)

-- Script kiểm tra online status và tích hợp với Shouko.dev Tool
-- Tác giả: Shouko.dev
-- Phiên bản: 1.0

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Cấu hình
local CHECK_INTERVAL = 20 -- Thời gian giữa các lần kiểm tra (giây)
local OUTPUT_FILE = "check_executor.main" -- Tên file output
local USER_ID = tostring(Players.LocalPlayer.UserId) -- Lấy UserID của người chơi

-- Hàm kiểm tra online status
local function checkOnlineStatus()
    local success, result = pcall(function()
        -- Gọi API để kiểm tra online status
        local response = HttpService:RequestAsync({
            Url = "https://presence.roblox.com/v1/presence/users",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                userIds = {tonumber(USER_ID)}
            })
        })
        
        local data = HttpService:JSONDecode(response.Body)
        return data.userPresences[1].userPresenceType
    end)
    
    if not success then
        -- Thử với backup API nếu API chính fail
        success, result = pcall(function()
            local response = HttpService:RequestAsync({
                Url = "https://presence.roproxy.com/v1/presence/users",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    userIds = {tonumber(USER_ID)}
                })
            })
            
            local data = HttpService:JSONDecode(response.Body)
            return data.userPresences[1].userPresenceType
        end)
    end
    
    return success, result
end

-- Hàm ghi kết quả ra file
local function writeStatusToFile(status)
    local workspacePath
    if RunService:IsStudio() then
        workspacePath = "Shouko.dev/" -- Đường dẫn test trong Studio
    else
        -- Tìm đường dẫn workspace của executor
        local executorPaths = {
            "/storage/emulated/0/Fluxus/Workspace/",
            "/storage/emulated/0/Codex/Workspace/",
            "/storage/emulated/0/krnl/workspace/",
            "/storage/emulated/0/Delta/Autoexecute/"
        }
        
        for _, path in ipairs(executorPaths) do
            if isfolder(path) then
                workspacePath = path
                break
            end
        end
    end
    
    if workspacePath then
        local filePath = workspacePath .. USER_ID .. ".main"
        writefile(filePath, tostring(status))
        return true
    end
    return false
end

-- Hàm main
local function main()
    while true do
        local success, presenceType = checkOnlineStatus()
        
        if success then
            -- 1 = Offline, 2 = Online, 3 = InGame, 4 = InStudio
            local status = presenceType == 2 or presenceType == 3
            
            if writeStatusToFile(status) then
                print("[Shouko.dev] Online status updated:", status and "Online" or "Offline")
            else
                warn("[Shouko.dev] Failed to write status file!")
            end
        else
            warn("[Shouko.dev] Failed to check online status:", presenceType)
        end
        
        wait(CHECK_INTERVAL)
    end
end

-- Khởi chạy
print("[Shouko.dev] Online checker initialized for user:", USER_ID)
main()
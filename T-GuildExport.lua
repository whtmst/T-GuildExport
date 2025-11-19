-- T-GuildExport for Turtle WoW 1.18
-- Usage: /tge export

T_GuildExport = {}

function T_GuildExport.ExportGuildRoster()
    -- Update guild data first
    GuildRoster()
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Собираю данные гильдии...")
    
    -- Schedule data saving after short delay
    T_GuildExport.scheduleTime = GetTime() + 3
    T_GuildExport.scheduleFunc = T_GuildExport.SaveGuildData
end

function T_GuildExport.SaveGuildData()
    if not T_GuildExportDB then
        T_GuildExportDB = {}
    end
    
    local memberCount = GetNumGuildMembers()
    if memberCount == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Данные гильдии не найдены. Вы состоите в гильдии?")
        return
    end
    
    -- Clear previous data
    T_GuildExportDB = {}
    
    -- Save timestamp
    T_GuildExportDB.exportTime = date("%Y-%m-%d %H:%M:%S")
    T_GuildExportDB.members = {}
    
    -- Collect member data
    for i = 1, memberCount do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
        
        -- Fix for note fields sometimes being nil
        note = note or ""
        officernote = officernote or ""
        
        local memberData = {
            name = name,
            level = level or 0,
            rank = rank or "",
            note = note,
            officernote = officernote,
            class = class or "Unknown",
            zone = zone or "Unknown",
            online = online or false
        }
        
        table.insert(T_GuildExportDB.members, memberData)
    end
    
    -- Sort by name
    table.sort(T_GuildExportDB.members, function(a, b) 
        return a.name < b.name 
    end)
    
    local count = 0
    for _ in pairs(T_GuildExportDB.members) do
        count = count + 1
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Успешно сохранено " .. count .. " участников гильдии!")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: |cFFFFFF00ВАЖНО:|r Выйдите из игры или используйте |cFF00FF00/logout|r для сохранения данных в файл!")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Файл будет здесь: |cFF00FF00WTF\\Account\\ВАШ_АККАУНТ\\SavedVariables\\T-GuildExport.lua|r")
end

-- Simple scheduler using OnUpdate
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
    if T_GuildExport.scheduleFunc and T_GuildExport.scheduleTime and GetTime() > T_GuildExport.scheduleTime then
        T_GuildExport.scheduleFunc()
        T_GuildExport.scheduleFunc = nil
        T_GuildExport.scheduleTime = nil
    end
end)

-- Slash command handler
SlashCmdList["T_GUILDEXPORT"] = function(msg)
    if msg == "export" then
        T_GuildExport.ExportGuildRoster()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Использование: |cFF00FF00/tge export|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r: Экспортирует список гильдии в файл SavedVariables")
    end
end

SLASH_T_GUILDEXPORT1 = "/tge"

-- Register events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF11A6ECT-GuildExport|r загружен. Используйте |cFF00FF00/tge export|r для сохранения списка гильдии.")
end)

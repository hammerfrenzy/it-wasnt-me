-- Note: The name of the .toc file must  match the name of the addon's folder
-- Also, apparently Lua wants functions to be defined before they're used,
-- at least when they're thrown in ad hoc like this.

-- Register our addon's chat prefix
local addonMessagePrefix = 'IWM_CHAT_PREFIX'
C_ChatInfo.RegisterAddonMessagePrefix(addonMessagePrefix)

local function StartBlameProcess()
    SendChatMessage('it wasn\'t me.', 'SAY')
end

-----------------------------------------------
-- REGISTER SLASH COMMAND
-----------------------------------------------

-- We'll register this later to run when our slash command is recognized.
local function SlashCommandHandler(msg, _) -- _ here is 'editBox'
    if msg == 'blame' then
        StartBlameProcess()
    end
end

-- Name the slash command. When the game sees this /[command] input,
-- it takes the name from SLASH_[YourNameHere] (ITWASNTME in our case)
-- and then uses that to check the global SlashCmdList.
SLASH_ITWASNTME1 = '/iwm'

-- Tell the game's chat handler what to run when the slash command is entered.
SlashCmdList['ITWASNTME'] = SlashCommandHandler

-----------------------------------------------
-- EVENT HANDLING
-- List of events: https://wowpedia.fandom.com/wiki/Events
-----------------------------------------------

-- Create a frame for listening to events
-- Events must come through a frame
local frame = CreateFrame('Frame')

-- A container to hold events we want to register
local events = {}

-- Simply for testing purposes
function events:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        local playerName = UnitName('player')

        local success = C_ChatInfo
            .SendAddonMessage(addonMessagePrefix,
                'BROUGHT TO YOU BY SLEEP DEPRIVATION!',
                'WHISPER',
                playerName)

        if success then
            print('it was sent')
        else
            print('ADDON CHAT NOT SENT')
        end
    end
end

-- Fired when an addon sends a chat message
-- It sounds like these are supposed to be visible to players,
-- but I haven't been able to verify that. I don't see the
-- whisper that is sent as part of PLAYER_ENTERING_WORLD.
function events:CHAT_MSG_ADDON(prefix, message, channel, sender, ...)
    if prefix == addonMessagePrefix then
        print(sender .. ' sent \'' .. message .. '\' ' .. ' in ' .. channel)
    end
end

-- Parameters sent by the event are
local function DispatchEvent(self, event, ...)
    events[event](self, ...)
end

-- Register the events we added to the events var
for event, _ in pairs(events) do
    frame:RegisterEvent(event)
end

-- Pass incoming events to the correct event handler
frame:SetScript("OnEvent", DispatchEvent)

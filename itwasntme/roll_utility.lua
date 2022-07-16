function IWM_RollUtility.EmoteForRoll(roll)
    print('emoting for roll')
    local message = ''

    -- General case messages
    if roll <= 9 then
        message = 'fumbles the die! It comes up ' .. roll .. '!'
    elseif roll <= 29 then
        message = 'rolls the die off the table. After picking it up, it\'s only a ' .. roll .. '.'
    elseif roll <= 49 then
        message = 'throws the die as hard as they can... but only get a ' .. roll .. '.'
    elseif roll <= 69 then
        message = 'makes an OK roll and gets an OK result of ' .. roll .. '.'
    elseif roll <= 89 then
        message = 'rolls with precision! A ' .. roll .. '!'
    else
        message = 'has a gleam in their eye. The die shows ' .. roll .. '!'
    end

    -- Special messages
    if roll == 69 then
        message = 'unleashes a secret technique! The die rolls... it\'s a 69!!!'
    end

    if roll == 100 then
        message = 'scores a critical hit! It\'s a perfect 100!'

    end

    SendChatMessage(message, 'EMOTE')
end

-- OK! AI.Censor FiveM
-- Copyright (C) 2021 OkaeriPoland
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

AddEventHandler('chatMessage', function(source, name, message)

    if IsPlayerAceAllowed(source, 'aicensor.bypass') then
        return
    end

    local onResponse = function(statusCode, response, headers)

        if not response then
            print('[OK! AI.Censor] Nie udalo sie zweryfikowac wiadomosci ' .. GetPlayerName(source) .. ', kod ' .. statusCode)
            return
        end

        local data = json.decode(response)
        if not data.general.swear then
            return
        end

        CancelEvent()
        print('[OK! AI.Censor] Zablokowano wiadomosc ' .. GetPlayerName(source) .. ' (' .. message .. ')')

        local chatEventData = { args = { "AI.Censor", AiCensorMessages.Blocked }, color = { 249, 166, 0 } }
        TriggerClientEvent('chat:addMessage', source, chatEventData)
    end

    local headers = {
        ['User-Agent'] = 'Okaeri-FiveM/1.0 (aicensor)',
        ['Token'] = AiCensorConfig.Token
    }

    local content = {}
    if AiCensorConfig.FilterUsernames then
        content.phrase = name
    elseif AiCensorConfig.FilterMessages then
        content.phrase = message
    elseif AiCensorConfig.FilterUsernames and AiCensorConfig.FilterMessages then
        content.phrase = name .. ' <object:separator> ' .. message
    end

    PerformHttpRequest('https://ai-censor.okaeri.eu/predict', onResponse, 'POST', json.encode(content), headers)
end)
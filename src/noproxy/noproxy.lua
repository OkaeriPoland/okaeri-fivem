-- OK! No.Proxy FiveM
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

function splitString(text, separator)
    local parts = {};
    i = 1
    for token in string.gmatch(text, "([^" .. separator .. "]+)") do
        parts[i] = token
        i = i + 1
    end
    return parts
end

function resolveIfBlock(response)
    return string.find(str, '"block": ?true')
end

function resolvePlayerIp(source)
    ip = GetPlayerEP(source)
    if not string.match(ip, ':') then
        return ip
    end
    return splitString(ip, ':')[1]
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)

    if GetNumPlayerIndices() >= GetConvarInt('sv_maxclients', 32) then
        return
    end

    deferrals.defer()
    deferrals.update(NoProxyMessages.Verification)

    if IsPlayerAceAllowed(source, 'noproxy.bypass') then
        deferrals.done()
        return
    end

    local playerAddress = resolvePlayerIp(source)
    local onResponse = function(statusCode, response, headers)

        if not response then
            print('[OK! No.Proxy] Nie udalo sie zweryfikowac gracza ' .. playerName .. ', kod ' .. statusCode .. ': ' .. response)
            return
        end

        if not resolveIfBlock(response) then
            return
        end

        deferrals.done(NoProxyMessages.Proxy)
        print('[OK! No.Proxy] Zablokowano gracza ' .. playerName .. ' (IP: ' .. playerAddress .. ')')
    end

    PerformHttpRequest('https://noproxy-api.okaeri.eu/v1/' .. playerAddress, onResponse, 'GET', nil, { 'Authorization: Bearer ' .. NoProxyConfig.Token })
end)

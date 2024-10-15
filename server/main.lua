local playersInJail = {}

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	exports.oxmysql:execute('SELECT jail_time FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
		if result[1] and result[1].jail_time > 0 then
			TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
		end
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	playersInJail[playerId] = nil
end)

-- Use 'AddEventHandler' to listen for the 'oxmysql:ready' event
AddEventHandler('oxmysql:ready', function()
	Citizen.Wait(2000)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers do
		Citizen.Wait(100)
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		exports.oxmysql:execute('SELECT jail_time FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
			if result[1] and result[1].jail_time > 0 then
				TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
			end
		end)
	end
end)

ESX.RegisterCommand('jail', 'admin', function(xPlayer, args, showError)
	TriggerEvent('esx_jail:sendToJail', args.playerId, args.time * 60)
end, true, {help = 'Jail a player', validate = true, arguments = {
	{name = 'playerId', help = 'player id', type = 'playerId'},
	{name = 'time', help = 'jail time in minutes', type = 'number'}
}})

ESX.RegisterCommand('unjail', 'admin', function(xPlayer, args, showError)
	unjailPlayer(args.playerId)
end, true, {help = 'Unjail a player', validate = true, arguments = {
	{name = 'playerId', help = 'player id', type = 'playerId'}
}})

RegisterNetEvent('esx_jail:sendToJail')
AddEventHandler('esx_jail:sendToJail', function(playerId, jailTime, quiet)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if not playersInJail[playerId] then
			exports.oxmysql:execute('UPDATE users SET jail_time = ? WHERE identifier = ?', { jailTime, xPlayer.identifier }, function(rowsChanged)
				xPlayer.triggerEvent('esx_policejob:unrestrain')
				xPlayer.triggerEvent('esx_jail:jailPlayer', jailTime)
				playersInJail[playerId] = {timeRemaining = jailTime, identifier = xPlayer.getIdentifier()}

				if not quiet then
					TriggerClientEvent('chat:addMessage', -1, {args = {'Judge', ('%s has been jailed for %s minutes.'):format(xPlayer.getName(), ESX.Math.Round(jailTime / 60))}, color = {147, 196, 109}})
				end
			end)
		end
	end
end)

function unjailPlayer(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if playersInJail[playerId] then
			exports.oxmysql:execute('UPDATE users SET jail_time = 0 WHERE identifier = ?', { xPlayer.identifier }, function(rowsChanged)
				TriggerClientEvent('chat:addMessage', -1, {args = {'Judge', ('%s has been released from jail.'):format(xPlayer.getName())}, color = {147, 196, 109}})
				playersInJail[playerId] = nil
				xPlayer.triggerEvent('esx_jail:unjailPlayer')
			end)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)

		for playerId, data in pairs(playersInJail) do
			playersInJail[playerId].timeRemaining = data.timeRemaining - 1

			if data.timeRemaining < 1 then
				unjailPlayer(playerId)
			end
		end
	end
end)

-- Updated thread without 'Async.parallelLimit'
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.JailTimeSyncInterval)

		for playerId, data in pairs(playersInJail) do
			-- Update jail time for each player
			exports.oxmysql:execute('UPDATE users SET jail_time = ? WHERE identifier = ?', { data.timeRemaining, data.identifier })
		end
	end
end)

local isInJail, unjail = false, false
local jailTime, fastTimer = 0, 0

-- Initialize ESX
ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx_jail:jailPlayer')
AddEventHandler('esx_jail:jailPlayer', function(_jailTime)
	jailTime = _jailTime
	fastTimer = jailTime

	local playerPed = PlayerPedId()

	-- Apply prison uniform
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.prison_wear.female)
		end
	end)

	SetPedArmour(playerPed, 0)
	ESX.Game.Teleport(playerPed, Config.JailLocation)
	isInJail, unjail = true, false

	-- Main jail loop
	while not unjail do
		playerPed = PlayerPedId()

		RemoveAllPedWeapons(playerPed, true)
		if IsPedInAnyVehicle(playerPed, false) then
			ClearPedTasksImmediately(playerPed)
		end

		Citizen.Wait(20000) -- Wait 20 seconds before checking escape attempt

		-- Is the player trying to escape?
		local distance = #(GetEntityCoords(playerPed) - vector3(Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z))
		if distance > 10.0 then
			ESX.Game.Teleport(playerPed, Config.JailLocation)
			TriggerEvent('chat:addMessage', {args = {_U('judge'), _U('escape_attempt')}, color = {147, 196, 109}})
		end
	end

	-- Release player from jail
	ESX.Game.Teleport(playerPed, Config.JailBlip)
	isInJail = false

	-- Restore player skin
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
end)

-- Jail timer thread
Citizen.CreateThread(function()
	while true do
		if jailTime > 0 and isInJail then
			Citizen.Wait(1000) -- Update every second

			fastTimer = fastTimer - 1
			draw2dText(_U('remaining_msg', fastTimer), 0.175, 0.955)

			if fastTimer <= 0 then
				TriggerEvent('esx_jail:unjailPlayer')
			end
		else
			Citizen.Wait(5000) -- No need to run the loop frequently if not in jail
		end
	end
end)

RegisterNetEvent('esx_jail:unjailPlayer')
AddEventHandler('esx_jail:unjailPlayer', function()
	unjail, jailTime, fastTimer = true, 0, 0
end)

AddEventHandler('playerSpawned', function(spawn)
	if isInJail then
		ESX.Game.Teleport(PlayerPedId(), Config.JailLocation)
	end
end)

-- Create jail blip on the map
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.JailBlip)

	SetBlipSprite(blip, 188)
	SetBlipScale(blip, 1.9)
	SetBlipColour(blip, 6)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(_U('blip_name'))
	EndTextCommandSetBlipName(blip)
end)

-- Function to draw 2D text on screen
function draw2dText(text, x, y)
	SetTextFont(4)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end

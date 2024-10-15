# esx_jail

Let cops jail people!

- [FiveM Forum thread](https://forum.fivem.net/t/release-esx-jailer/82896)

# Features

- Jail people!
- Saves jail info to database, aka anti-combat
- Keeps jail time updated

# Installation

1. Clone the project and add it to your resorces directory
2. Add the project to your `server.cfg`
3. Import `esx_jail.sql` in your database
4. Select language in `config.lua`
5. (Optional) See below on how to jail via `esx_policejob`

# Dependencies
oxmysql (I removed async since it was crap) - [oxmysql](https://github.com/overextended/oxmysql)

# How to jail

- Use the `esx_jail:sendToJail(source, jailTime)` server side trigger
- Use the `/jail playerID jailTime` command (only admins)
- Use the `/unjail playerID` to unjail a player (only admins)


# Requirements

- ESX
- skinchanger

# Based off
- [Original script](https://forum.fivem.net/t/release-fx-jailer-1-1-0-0/41963)
- [dbjailer](https://github.com/SSPU1W/dbjailer)
- [oxmysql](https://github.com/overextended/oxmysql)

# Add to menu

Example in `esx_policejob: client/main.lua`:

```lua
		{icon = "fas fa-idkyet", title = TranslateCap('fine'), value = 'fine'},
		{icon = "fas fa-idkyet", title = TranslateCap('jail'), value = 'jail'},
		{icon = "fas fa-idkyet", title = TranslateCap('unpaid_bills'), value = 'unpaid_bills'}
		
		
					elseif action == 'license' then
						ShowPlayerLicense(closestPlayer)
					elseif action == 'jail' then
						JailPlayer(GetPlayerServerId(closestPlayer))
					elseif action == 'unpaid_bills' then
		end

---

function JailPlayer(player)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'jail_menu', {
		title = _U('jail_menu_info'),
	}, function (data2, menu)
		local jailTime = tonumber(data2.value)
		if jailTime == nil then
			ESX.ShowNotification('invalid number!')
		else
			TriggerServerEvent("esx_jail:sendToJail", player, jailTime * 60)
			menu.close()
		end
	end, function (data2, menu)
		menu.close()
	end)
end
```

This is for English local only for esx_policejob. Add this line below to (esx_policejob/locales/en.lua) this is needed so that it says in the interact menu (Jail). This is the same concept for all other locales BUT make sure you edit the line ({label = _U('blah blah'),			value = 'blah blah'}) so that it matches your lang. So whatever word you put in Jail you need to match this in locales (['blah blah'] = 'blah blah',)
```
['jail'] = 'jail',
```


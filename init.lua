ticketmaster = {}


local modpath = minetest.get_modpath(minetest.get_current_modname())
  dofile(modpath.."/database.lua")
  dofile(modpath.."/functions.lua")

minetest.register_privilege("ticketmaster", {
	  description = "Players whith this priv can see and treat tickets. (Just for Server-Team Members)",
	  give_to_singleplayer = true,
	  give_to_admin = true,
	  --on_grant = function(name, granter_name),
	  --on_revoke = function(name, revoker_name),
	})

minetest.register_chatcommand("ticket", {
        --params = "<param1> <param2>",
        description = "Players: Create a ticket. Server-Team: See all open tickets.",
        privs = {interact=true},
        func = function(player_name, param)
          if	minetest.check_player_privs(player_name, { ticketmaster=true }) then
            ticketmaster.show_team_formspec(player_name)
          else
            ticketmaster.show_player_formspec(player_name)
          end
        end
    })


-- Send the team frequently messages, if there are tickets open
minetest.after(280, function() ticketmaster.notify_timer()  end)
function ticketmaster.notify_timer()
  ticketmaster.notify_tickets()
  minetest.after(280, function() ticketmaster.notify_timer()  end)
end

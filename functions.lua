function ticketmaster.create(player_name, title, message, position)
  local ticket = {}
  ticket.player_name = player_name
  ticket.title = title
  ticket.message = message
  ticket.position = position
  ticket.date = os.date("%Y-%m-%d  %H:%M")
  ticketmaster.add_entry("open_tickets", ticket)
end

-- Player Formspec
function ticketmaster.show_player_formspec(player_name)
  minetest.show_formspec(player_name, "ticket_player", "size[10,10]"..
     		"label[0,0;Send a Ticket:]" ..
        "field[0.3,1;9.8,1;title;Title:;Subject]" ..
     		"textarea[0.3,2;9.8,8;message;Message:;Type in your Message here.\nYour Position will be sended automaticly.]"..
        "button[0.5,9;4,1;cancel;Cancel]"..
        "button[5.5,9;4,1;send;Send]"
     	)
end

-- Button Save
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_player" and fields.send ~= nil and fields.send ~= "" then
    ticketmaster.create(player:get_player_name(), fields.title, fields.message, player:get_pos())
    minetest.chat_send_player(player:get_player_name(), "Ticket sucessfully sended!")
    minetest.close_formspec(player:get_player_name(), "ticket_player")
    minetest.log("action", player:get_player_name().." opens a ticket.")
    ticketmaster.notify_tickets()
  end
end)

-- Button Cancel
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_player" and fields.cancel ~= nil and fields.cancel ~= "" then
    minetest.close_formspec(player:get_player_name(), "ticket_player")
  end
end)

ticketmaster.current_entry = {}
-- Team Formspec:
function ticketmaster.show_team_formspec(player_name)
  local open_tickets = ticketmaster.get_table("open_tickets") or "HEHEHE"
  local open_ticketss = ""
  local i = 1
  local ticket_r = {}
  -- print(open_tickets)
  for k, v in pairs(open_tickets) do
    -- print(v)
    -- print(tostring(k).."    "..v.title)
    ticket_r[i] = k
    i = i +1
    open_ticketss = open_ticketss..minetest.formspec_escape(v.title).." from "..minetest.formspec_escape(v.player_name)..","
  end
  ticketmaster.current_entry[player_name.."TABLE"] = ticket_r
  minetest.show_formspec(player_name, "ticket_team_list", "size[10,10]"..
  "label[0,0;Ticket Viewer:]" ..
  "label[0.2,0.5;Doubleclick to open an entry. Press ESC to close this window.]" ..
  "textlist[0.3,1;9,8.5;open_tickets;"..open_ticketss.."]"..
  "label[7.5,9.7;Ticketmaster by Jean3219]"
     	)
end

-- Select List
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_team_list" and fields.open_tickets then
    local selector = minetest.explode_textlist_event(fields.open_tickets)
    if selector.type == "DCL" then
      ticketmaster.show_team_message(player:get_player_name(), selector.index)
    end
  end
end)


-- TICKET ENTRY:
function ticketmaster.show_team_message(player_name, list_idx)
  local ticket = ticketmaster.get_entry("open_tickets", ticketmaster.current_entry[player_name.."TABLE"][list_idx])
  if not ticket then return end
  ticketmaster.current_entry[player_name.."TICKET"] = ticketmaster.current_entry[player_name.."TABLE"][list_idx]
  minetest.show_formspec(player_name, "ticket_entry", "size[10,10]"..
    "label[0,0;From: "..minetest.formspec_escape(ticket.player_name).."]" ..
    "label[3,0;Position: "..math.floor(ticket.position.x).." "..math.floor(ticket.position.y).." "..math.floor(ticket.position.z).."]" ..
    "label[6,0;Date: "..minetest.formspec_escape(ticket.date).."]" ..
    "label[0,0.5;Subject: "..minetest.formspec_escape(ticket.title).."]" ..
    "textarea[0.3,1.2;9.8,8;message;Message:;Your answer here.\n\n"..ticket.player_name.." wrote:\n"..minetest.formspec_escape(ticket.message).."\nPosition: "..math.floor(ticket.position.x).." "..math.floor(ticket.position.y).." "..math.floor(ticket.position.z).."]"..
    "button[0.5,9;2,1;close;Close]"..
    "button[3,9;2,1;done;Mark as Done]"..
    "button[5.5,9;2,1;mail;Send Mail]"..
    "button[8,9;2,1;teleport;Teleport to Position]"
  )
end

-- Button Close
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_entry" and fields.close ~= nil and fields.close ~= "" then
    ticketmaster.show_team_formspec(player:get_player_name())
  end
end)

-- Button Mark as Done
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_entry" and fields.done ~= nil and fields.done ~= "" then
    ticketmaster.remove_entry("open_tickets", ticketmaster.current_entry[player:get_player_name().."TICKET"])
    minetest.log("action", player:get_player_name().." closes a ticket.")
    ticketmaster.show_team_formspec(player:get_player_name())
  end
end)

-- Button Send Mail
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_entry" and fields.mail ~= nil and fields.mail ~= "" then
    local ticket = ticketmaster.get_entry("open_tickets", ticketmaster.current_entry[player:get_player_name().."TICKET"])
    mail.send(player:get_player_name(),ticket.player_name,"Ticket: "..ticket.title,fields.message)
    ticketmaster.remove_entry("open_tickets", ticketmaster.current_entry[player:get_player_name().."TICKET"])
    minetest.log("action", player:get_player_name().." closes a ticket.")
    minetest.chat_send_player(player:get_player_name(), "Mail sucessfully sended. Ticket marked as done.")
    ticketmaster.show_team_formspec(player:get_player_name())
  end
end)

-- Button Teleport
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "ticket_entry" and fields.teleport ~= nil and fields.teleport ~= "" then
    local ticket = ticketmaster.get_entry("open_tickets", ticketmaster.current_entry[player:get_player_name().."TICKET"])
    player:set_pos(ticket.position)
    minetest.chat_send_player(player:get_player_name(), "Teleporting you to ticket position...")
    minetest.close_formspec(player:get_player_name(), "ticket_entry")
  end
end)


function ticketmaster.notify_tickets()
  if ticketmaster.get_size("open_tickets") == 0 then return end
  for k, v in pairs(minetest.get_connected_players()) do
    if	minetest.check_player_privs(v:get_player_name(), { ticketmaster=true }) then
      minetest.chat_send_player(v:get_player_name(), "There are open tickets available. To see them, type /ticket")
    end
  end
end

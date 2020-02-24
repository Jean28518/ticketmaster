-- database by Jean3219.
-- Released under MIT License.

local storage = minetest.get_mod_storage()
ticketmaster = {}

function ticketmaster.get_table(table_s) -- returns a table. On the left side there is the unique id stored, on the right side the entry
  local table = minetest.deserialize(storage:get_string(table_s))
  if table == nil then
    table = {}
  end
  return table
end

local function save_table(table_s, table)
  storage:set_string(table_s, minetest.serialize(table))
end

function ticketmaster.save_int(int_s, int)
  storage:set_int(int_s, int)
end

function ticketmaster.load_int(int_s)
  return storage:get_int(int_s)
end

function ticketmaster.add_entry(table_s, value) -- Returns the unique id of entry, otherwise returns -1
  local id = ticketmaster.load_int(table_s.."ID_STORAGE") or 0
  local size = ticketmaster.load_int(table_s.."SIZE_STORAGE") or 0
  if value ~= nil then
    local table = ticketmaster.get_table(table_s) or {}
    id = id + 1
    table[id] = value
    size = size + 1
    save_table(table_s, table)
    ticketmaster.save_int(table_s.."ID_STORAGE", id)
    ticketmaster.save_int(table_s.."SIZE_STORAGE", size)
    return id
  else
    return -1
  end
end

function ticketmaster.remove_entry(table_s, id)
  local table = ticketmaster.get_table(table_s)
  local size = ticketmaster.load_int(table_s.."SIZE_STORAGE") or 0
  table[id] = nil
  save_table(table_s, table)
  size = size -1
  ticketmaster.save_int(table_s.."SIZE_STORAGE", size)
end

function ticketmaster.get_size(table_s)
  return ticketmaster.load_int(table_s.."SIZE_STORAGE") or 0
end

function ticketmaster.delete_table(table_s)
  table = {}
  save_table(table_s, table)
  ticketmaster.save_int(table_s.."ID_STORAGE", 0)
  ticketmaster.save_int(table_s.."SIZE_STORAGE", 0)
end

function ticketmaster.get_entry(table_s, id)
  local table = ticketmaster.get_table(table_s)
  return table[id]
end

local add_user_cfg = load_from_file('data/add_user_cfg.lua')

local function template_add_user(base, to_username, from_username, chat_name, chat_id)
   base = base or ''
   chat_name = string.gsub(chat_name, '_', ' ') or ''
   base = string.gsub(base, "{to_username}", to_username)
   base = string.gsub(base, "{from_username}", from_username)
   base = string.gsub(base, "{chat_name}", chat_name)
   base = string.gsub(base, "{chat_id}", chat_id)
   return base
end

function chat_new_user_link(msg)
   local pattern = add_user_cfg.initial_chat_msg_link
   if msg.from.username then
       to_username = "@"..msg.from.username
   else
       to_username = string.gsub(msg.from.print_name, "_", " ")
   end
   if msg.action.link_issuer.username then
       from_username = "@"..msg.action.link_issuer.username
   else
       from_username = string.gsub(msg.action.link_issuer.print_name, "_", " ")
   end
   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

function chat_bot_invited_link(msg)
   local pattern = add_user_cfg.invited_chat_msg_link
   if msg.from.username then
       to_username = "@"..msg.from.username
   else
       to_username = string.gsub(msg.from.print_name, "_", " ")
   end
   if msg.action.link_issuer.username then
       from_username = msg.action.link_issuer.username
   else
       from_username = string.gsub(msg.action.link_issuer.print_name, "_", " ")
   end
   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

function chat_new_user(msg)
   local pattern = add_user_cfg.initial_chat_msg
   if msg.action.user.username then
       to_username = "@"..msg.action.user.username
   else
       to_username = string.gsub(msg.action.user.print_name, "_", " ")
   end
   if msg.from.username then
       from_username = '@'..msg.from.username
   else
       from_username = string.gsub(msg.from.print_name, "_", " ")
   end
   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

function chat_bot_invited(msg)
   local pattern = add_user_cfg.invited_chat_msg
   if msg.action.user.username then
       to_username = "@"..msg.action.user.username
   else
       to_username = string.gsub(msg.action.user.print_name, "_", " ")
   end
   if msg.from.username then
       from_username = '@'..msg.from.username
   else
       from_username = string.gsub(msg.from.print_name, "_", " ")
   end
   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

local function description_rules(msg, nama)
   local data = load_data(_config.moderation.data)
   if data[tostring(msg.to.id)] then
      local about = ""
      local rules = ""
      if data[tostring(msg.to.id)]["description"] then
         about = data[tostring(msg.to.id)]["description"]
         about = "\nDescription :\n"..about.."\n"
      end
      if data[tostring(msg.to.id)]["rules"] then
         rules = data[tostring(msg.to.id)]["rules"]
         rules = "\nRules :\n"..rules.."\n"
      end
      local sambutan = "You are in group '"..string.gsub(msg.to.print_name, "_", " ").."'\n"
      local text = sambutan..about..rules.."\n"
      local text = text.."Please welcome "..nama
      local receiver = get_receiver(msg)
      send_large_msg(receiver, text, ok_cb, false)
   end
end

local function run(msg, matches)
   if not msg.service then
      return "Are you trying to troll me?"
   end
   --vardump(msg)
   if matches[1] == "chat_add_user" then
      if msg.action.user.id == our_id then
          chat_bot_invited(msg)
      else
          if msg.action.user.username then
              nama = "@"..msg.action.user.username
          else
              nama = string.gsub(msg.action.user.print_name, "_", " ")
          end
          chat_new_user(msg)
          description_rules(msg, nama)
      end
   elseif matches[1] == "chat_add_user_link" then
      if msg.from.id == 0 then
          chat_bot_invited_link(msg)
      else
          if not msg.from.username then
              nama = string.gsub(msg.from.print_name, "_", " ")
          else
              nama = "@"..msg.from.username
          end
          chat_new_user_link(msg)
          description_rules(msg, nama)
      end
   elseif matches[1] == "chat_del_user" then
       local bye_name = msg.action.user.first_name
       return 'Bye '..bye_name..'!'
   end
end

return {
   description = "Service plugin that sends a custom message when an user enters a chat.",
   usage = "Welcoming new member.",
   patterns = {
      "^!!tgservice (chat_add_user)$",
      "^!!tgservice (chat_add_user_link)$",
      "^!!tgservice (chat_del_user)$",
      "^!!tgservice (.+)$",
   },
   hidden = true,
   run = run
}

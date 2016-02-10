local ltn12 = require "ltn12"
--local http = require "socket.http"
local https = require "ssl.https"

local bot_key = "154113076:AAGqUrkMvVAOTX7j4c0PfQbDII-QPkH323I"
local BASE_URL = 'https://api.telegram.org/bot'..bot_key.. '/'

local function kick_user(user_id, chat_id)
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id
	if user_id == our_id then
		send_large_msg(chat,'Are you kidding?')
		return nil
	end
	local data = load_data(_config.moderation.data)
	if data[tostring('admins')] then
		 if data[tostring('admins')][tostring(user_id)] then
				send_large_msg(chat, 'You can\'t kick admin!')
				return nil
     end
  end
  chat_del_user(chat, user, ok_cb, true)
end

local function ban_user(user_id, chat_id)
  local hash =  'banned:'..chat_id..':'..user_id
  redis:set(hash, true)
	if user_id == our_id then
		send_large_msg(chat, 'Are you kidding?')
		return nil
	end
	local data = load_data(_config.moderation.data)
	if data[tostring('admins')] then
		 if data[tostring('admins')][tostring(user_id)] then
				send_large_msg(chat, 'You can\'t ban admin!')
				return nil
     end
  end
  kick_user(user_id, chat_id)
end

local function superban_user(user_id, chat_id)
  local hash =  'superbanned:'..user_id
  redis:set(hash, true)
	if user_id == our_id then
		send_large_msg(chat, 'Are you kidding?')
		return nil
	end
  kick_user(user_id, chat_id)
end

function is_botmod(botmsg)
  local var = false
  local data = load_data(_config.moderation.data)
  local user = botmsg.from.id
  if data[tostring(-botmsg.chat.id)] then
    if data[tostring(-botmsg.chat.id)]['moderators'] then
      if data[tostring(-botmsg.chat.id)]['moderators'][tostring(user)] then
        var = true
      end
    end
  end
  if data['admins'] then
    if data['admins'][tostring(user)] then
      var = true
    end
  end
  for v,user in pairs(_config.sudo_users) do
    if user == botmsg.from.id then
        var = true
    end
  end
  return var
end

local function promote(user_id, user_name, chat_id)
  local receiver = 'chat#id'..chat_id
  local data = load_data(_config.moderation.data)
	if not data[tostring(chat_id)] then
		send_large_msg(receiver, 'Group is not added.')
		return
	end
	if data[tostring(chat_id)]['moderators'][tostring(user_id)] then
		send_large_msg(receiver, user_name..' is already a moderator.')
		return
  end
    data[tostring(chat_id)]['moderators'][tostring(user_id)] = user_name
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, '@'..user_name..' has been promoted.')
		return
end

local function demote(user_id, user_name, chat_id)
  local data = load_data(_config.moderation.data)
  local receiver = 'chat#id'..chat_id
	if not data[tostring(chat_id)] then
		send_large_msg(receiver, 'Group is not added.')
		return
	end
	if not data[tostring(chat_id)]['moderators'][tostring(user_id)] then
		send_large_msg(receiver, user_name..' is not a moderator.')
	end
	data[tostring(chat_id)]['moderators'][tostring(user_id)] = nil
	save_data(_config.moderation.data, data)
	send_large_msg(receiver, '@'..user_name..' has been demoted.')
	return
end

function on_bot_msg(botmsg)
	if not botmsg.chat.type == "group" then return end
	--vardump(botmsg)
	if botmsg.reply_to_message then
		if not is_botmod(botmsg) then return end
		local chat_id = string.gsub(botmsg.reply_to_message.chat.id, "-", "")
		local user_id = botmsg.reply_to_message.from.id
		if botmsg.reply_to_message.from.username then
			user_name = botmsg.reply_to_message.from.username
		else
			user_name = botmsg.reply_to_message.from.first_name
		end
		if botmsg.text == "!kick" then
			kick_user(user_id, chat_id)
		end
		if botmsg.text == "!ban" then
			ban_user(user_id, chat_id)
		end
		if botmsg.text == "!superban" then
			superban_user(user_id, chat_id)
		end
		if botmsg.text == "!promote" then
			promote(user_id, user_name, chat_id)
		end
		if botmsg.text == "!demote" then
			demote(user_id, user_name, chat_id)
		end
	end
end

local function send_request(url)
	local dat, res = https.request(url)
	local tab = JSON.decode(dat)
	if res ~= 200 then
		print('Connection error.')
		return false
	end
	if not tab.ok then
		print(tab.description)
		return false
	end
	return tab
end

function get_updates(offset)
	local url = BASE_URL .. 'getUpdates?timeout=30'
	if offset then
		url = url .. '&offset=' .. offset
	end
	return send_request(url)
end

last_update = 0
local function pre_process(msg)
	local res = get_updates(last_update+1)
	if not res then
		print('Error getting updates.')
	else
		for i,v in ipairs(res.result) do
			if v.update_id > last_update then
				last_update = v.update_id
				on_bot_msg(v.message, msg)
			end
		end
	end
	return msg
end

local function run(msg, matches)
	if not is_chat_msg(msg) then return end
	local res = get_updates(last_update+1)
	if not res then
		print('Error getting updates.')
	else
		for i,v in ipairs(res.result) do
			if v.update_id > last_update then
				last_update = v.update_id
				on_bot_msg(v.message, msg)
			end
		end
	end
end

return {
  description = "Simplest plugin ever!",
  usage = "For debug purpose",
  patterns = {
    "^(!kick)$",
    "^(!ban)$",
    "^(!superban)$",
		"^(!promote)$",
		"^(!demote)$"
  }, 
  run = run,
  --pre_process = pre_process,
  moderated = true,
  hide = true
}

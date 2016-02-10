do

-- CUSTOM FLUXPRO
local function is_spromoted(chat_id, user_id)
  local hash =  'sprom:'..chat_id..':'..user_id
  local spromoted = redis:get(hash)
  return spromoted or false
end

local function spromote(receiver, user_id, member_username)
  local chat_id = string.gsub(receiver, 'chat#id', '')
  local data = load_data(_config.moderation.data)
  if not data[tostring(chat_id)] then
  	return send_large_msg(receiver, 'Group is not added.')
  end
  if data[tostring(chat_id)]['moderators'][tostring(user_id)] then
  	if is_spromoted(chat_id, user_id) then
  		return send_large_msg(receiver, 'Already as moderator leader')
  	end
  	local hash =  'sprom:'..chat_id..':'..user_id
	redis:set(hash, true)
	send_large_msg(receiver, 'User @'..member_username..' ['..user_id..'] promoted as moderator leader')
	return
  else
  	data[tostring(chat_id)]['moderators'][tostring(member_id)] = member_username
    save_data(_config.moderation.data, data)
    local hash =  'sprom:'..chat_id..':'..user_id
    redis:set(hash, true)
    send_large_msg(receiver, 'User @'..member_username..' ['..user_id..'] promoted as moderator leader')
    return
  end
end

local function sdemote(receiver, user_id, member_username)
  local chat_id = string.gsub(receiver, 'chat#id', '')
  if not is_spromoted(chat_id, user_id) then
  	return send_large_msg(receiver, 'Not a moderator leader')
  end
  local data = load_data(_config.moderation.data)
  data[chat_id]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  local hash =  'sprom:'..chat_id..':'..user_id
  redis:del(hash)
  send_large_msg(receiver, 'User '..member_username..' ['..user_id..'] demoted!')
end

-- END CUSTOM FLUXPRO

local function check_member(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local data = cb_extra.data
   local msg = cb_extra.msg
   for k,v in pairs(result.members) do
      local member_id = v.id
      if member_id ~= our_id then
          local username = v.username
          data[tostring(msg.to.id)] = {
              moderators = {[tostring(member_id)] = username},
              settings = {
                  set_name = string.gsub(msg.to.print_name, '_', ' '),
                  lock_name = 'no',
                  lock_photo = 'no',
                  lock_member = 'no',
                  lock_spam = 'yes',
                  }
            }
          save_data(_config.moderation.data, data)
          return send_large_msg(receiver, 'You have been promoted as moderator for this group.')
      end
    end
end

local function automodadd(msg)
    local data = load_data(_config.moderation.data)
	if msg.action.type == 'chat_created' then
	    receiver = get_receiver(msg)
	    chat_info(receiver, check_member,{receiver=receiver, data=data, msg = msg})
	else
	    if data[tostring(msg.to.id)] then
		    return 'Group is already added.'
	    end
	    if msg.from.username then
	        username = msg.from.username
	    else
	        username = msg.from.print_name
	    end
        -- create data array in moderation.json
	    data[tostring(msg.to.id)] = {
	        moderators ={[tostring(msg.from.id)] = username},
	        settings = {
	            set_name = string.gsub(msg.to.print_name, '_', ' '),
	            lock_name = 'no',
	            lock_photo = 'no',
	            lock_member = 'no',
	            lock_spam = 'yes',
	            }
	        }
	    save_data(_config.moderation.data, data)
	    return 'Group has been added, and @'..username..' has been promoted as moderator for this group.'
	 end
end

local function modadd(msg)
    -- superuser and admins only (because sudo are always has privilege)
    if not is_admin(msg) then
        return "You're not admin"
    end
    local data = load_data(_config.moderation.data)
	if data[tostring(msg.to.id)] then
		return 'Group is already added.'
	end
    -- create data array in moderation.json
	data[tostring(msg.to.id)] = {
	    moderators ={},
	    settings = {
	        set_name = string.gsub(msg.to.print_name, '_', ' '),
	        lock_name = 'no',
	        lock_photo = 'no',
	        lock_member = 'no',
	        lock_spam = 'yes',
	        }
	    }
	save_data(_config.moderation.data, data)

	return 'Group has been added.'
end

local function modrem(msg)
    -- superuser and admins only (because sudo are always has privilege)
    if not is_admin(msg) then
        return "You're not admin"
    end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	data[tostring(msg.to.id)] = nil
	save_data(_config.moderation.data, data)

	return 'Group has been removed'
end

local function promote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
	if not data[group] then
		return send_large_msg(receiver, 'Group is not added.')
	end
	if data[group]['moderators'][tostring(member_id)] then
		return send_large_msg(receiver, member_username..' is already a moderator.')
    end
    data[group]['moderators'][tostring(member_id)] = member_username
    save_data(_config.moderation.data, data)
    return send_large_msg(receiver, '@'..member_username..' has been promoted.')
end

local function demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
	if not data[group] then
		return send_large_msg(receiver, 'Group is not added.')
	end
	if not data[group]['moderators'][tostring(member_id)] then
		return send_large_msg(receiver, member_username..' is not a moderator.')
	end
	data[group]['moderators'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' has been demoted.')
end

local function admin_promote(receiver, member_username, member_id)	
	local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end

	if data['admins'][tostring(member_id)] then
		return send_large_msg(receiver, member_username..' is already as admin.')
	end
	
	data['admins'][tostring(member_id)] = member_username
	save_data(_config.moderation.data, data)
	return send_large_msg(receiver, '@'..member_username..' has been promoted as admin.')
end

local function admin_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end

	if not data['admins'][tostring(member_id)] then
		return send_large_msg(receiver, member_username..' is not an admin.')
	end

	data['admins'][tostring(member_id)] = nil
	save_data(_config.moderation.data, data)

	return send_large_msg(receiver, 'Admin '..member_username..' has been demoted.')
end

local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'No user @'..member..' in this group.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
      	member_username = member
      	member_id = v.id
      	if mod_cmd == 'promote' then
      	    return promote(receiver, member_username, member_id)
      	elseif mod_cmd == 'demote' then
      		if is_spromoted(string.gsub(receiver,'chat#id', ''), member_id) then
      			return send_large_msg(receiver, 'Cant\'t demote leader')
      		end
      	    return demote(receiver, member_username, member_id)
      	elseif mod_cmd == 'adminprom' then
      	    return admin_promote(receiver, member_username, member_id)
      	elseif mod_cmd == 'admindem' then
      	    return admin_demote(receiver, member_username, member_id)
      	elseif mod_cmd == 'spromote' then
      	    return spromote(receiver, member_id, member_username)
      	elseif mod_cmd == 'sdemote' then
      	    return sdemote(receiver, member_id, member_username)
      	end
      end
   end
   send_large_msg(receiver, text)
end

local function modlist(msg)
    local data = load_data(_config.moderation.data)
	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end
	-- determine if table is empty
	if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
		return 'No moderator in this group.'
	end
	local message = 'List of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
	for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
		if is_spromoted(msg.to.id, k) then
			message = message .. '- '..v..' [' ..k.. '] * \n'
		else
			message = message .. '- '..v..' [' ..k.. '] \n'
		end
	end

	return message
end

local function admin_list(msg)
    local data = load_data(_config.moderation.data)
	if not data['admins'] then
		data['admins'] = {}
		save_data(_config.moderation.data, data)
	end
	if next(data['admins']) == nil then --fix way
		return 'No admin available.'
	end
	local message = 'List for Bot admins:\n'
	for k,v in pairs(data['admins']) do
		message = message .. '- ' .. v ..' ['..k..'] \n'
	end
	return message
end

function run(msg, matches)
  if not is_chat_msg(msg) then
    return "Only works on group"
  end
  local mod_cmd = matches[1]
  local receiver = get_receiver(msg)
  if matches[1] == 'modadd' then
    return modadd(msg)
  end
  if matches[1] == 'modrem' then
    return modrem(msg)
  end
  if matches[1] == 'promote' and matches[2] then
    if not is_momod(msg) then
        return "Only moderator can promote"
    end
	local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'demote' and matches[2] then
    if not is_momod(msg) then
        return "Only moderator can demote"
    end
    if string.gsub(matches[2], "@", "") == msg.from.username then
        return "You can't demote yourself"
    end
	local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  -- CUSTOM FLUXPRO
  if matches[1] == 'spromote' and matches[2] then
    if not is_admin(msg) then
        return "Only admin can promote moderator leader"
    end
	local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'sdemote' and matches[2] then
    if not is_admin(msg) then
        return "Only moderator can demote moderator leader"
    end
    if string.match(matches[2], '^%d+$') then
    	return sdemote(receiver, matches[2], matches[2])
    end
	local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  -- END CUSTOM FLUXPRO
  if matches[1] == 'modlist' then
    return modlist(msg)
  end
  if matches[1] == 'adminprom' then
    if not is_admin(msg) then
        return "Only sudo can promote user as admin"
    end
	local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'admindem' then
    if not is_admin(msg) then
        return "Only sudo can promote user as admin"
    end
    if string.match(matches[2], '^%d+$') then
        admin_demote(receiver, matches[2], matches[2])
    else
        local member = string.gsub(matches[2], "@", "")
        chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
    end
    --local member = string.gsub(matches[2], "@", "")
    --chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'adminlist' then
    if not is_admin(msg) then
        return 'Admin only!'
    end
    return admin_list(msg)
  end
  if matches[1] == 'chat_add_user' and msg.action.user.id == our_id then
    --return automodadd(msg)
  end
  if matches[1] == 'chat_created' and msg.from.id == 0 then
    return automodadd(msg)
  end
end

return {
  description = "Moderation plugin", 
  usage = {
      user = {
          "!modlist : List of moderators",
          },
      moderator = {
          "!promote <username> : Promote user as moderator",
          "!demote <username> : Demote user from moderator",
          },
      admin = {
          "!modadd : Add group to moderation list",
          "!modrem : Remove group from moderation list",
          "!spromote : Promote user as moderator leader",
          "!sdemote : Demote user from being moderator leader",
          },
      sudo = {
          "!adminprom <username> : Promote user as admin (must be done from a group)",
          "!admindem <username> : Demote user from admin (must be done from a group)",
          "!admindem <id> : Demote user from admin (must be done from a group)",
          },
      },
  patterns = {
    "^!(modadd)$",
    "^!(modrem)$",
    "^!(spromote) (.*)$",
    "^!(sdemote) (.*)$",
    "^!(promote) (.*)$",
    "^!(demote) (.*)$",
    "^!(modlist)$",
    "^!(adminprom) (.*)$", -- sudoers only
    "^!(admindem) (.*)$", -- sudoers only
    "^!(adminlist)$",
    "^!!tgservice (chat_add_user)$",
    "^!!tgservice (chat_created)$",
  }, 
  run = run,
}

end
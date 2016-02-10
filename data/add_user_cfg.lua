do 
_ = {

  -- when a user were invited by other member
  initial_chat_msg = "Hi {to_username}! Welcome to \'{chat_name}\'.\nYou have been invited by {from_username}",
  -- {to_username} {from_username} {chat_name} {chat_id}

  -- when a user joined via invite link
  initial_chat_msg_link = "Hi {to_username}! Welcome to \'{chat_name}\'.\nYou just joined this group via invite link",

  -- when bot was invited into a group chat
  invited_chat_msg = "Thanks {from_username} for inviting me. Nice to know you all members of \'{chat_name}\'.",

  -- when bot joined via invite link
  invited_chat_msg_link = "Hello all members of \'{chat_name}\'. I\'m joined this group via invite link. Nice to know you all."
}

return _
end

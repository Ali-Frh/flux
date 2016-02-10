local function run(msg, matches)
	local chat = "chat#id35062675"
	if matches[1] == "feedback" and matches[2] then
		local text = "Feedback from\nName : "..string.gsub(msg.from.print_name, "_", " ").."\nID : "..msg.from.id.."\n------------------------\n\n"..matches[2]
		send_large_msg(chat, text)
		return "Thanks for your feedback"
	end
end

return {
   description = "Feedback from user plugin",
   usage = {
      "!feedback <message> : Send your feedback to bot admin",
   },
   patterns = {
      "^!(feedback) (.+)$",
   },
   run = run
}

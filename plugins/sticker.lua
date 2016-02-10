local function stickers_names( )
  local stickers = {}
  for k, v in pairs(scandir("data/stickers")) do
    -- Ends with .webp
    if (v:match(".webp$")) then
      table.insert(stickers, v)
    end
  end
  return stickers
end

local function random_sticker(msg)
	local receiver = get_receiver(msg)
	local stickers = stickers_names()
	local sticker = stickers[math.random(#stickers)]
	local file = "data/stickers/"..sticker
	--vardump(sticker)
	send_document(receiver, file, ok_cb, false)
end

local function run(msg, matches)
	if matches[1] == "!sticker" then
		return random_sticker(msg)
	end
end

return {
  description = "Send random sticker!",
  usage = "!sticker : Send random sticker",
  patterns = {
    "^!sticker$",
  }, 
  run = run,
}

do local _ = {
  disabled_channels = {
    ["chat#id98399"] = false,
    ["chat#id1265323"] = false,
    ["chat#id5398007"] = true,
    ["chat#id11297237"] = false,
    ["chat#id11722905"] = false,
    ["chat#id13697637"] = false,
    ["chat#id13720181"] = true,
    ["chat#id18051199"] = false,
    ["chat#id21786529"] = true,
    ["chat#id21865259"] = false,
    ["chat#id24546427"] = true,
    ["chat#id25217650"] = false,
    ["chat#id30964800"] = false,
    ["chat#id31804957"] = false,
    ["chat#id32765374"] = false,
    ["chat#id37467063"] = false
  },
  disabled_plugin_on_chat = {
    ["chat#id649259"] = {
      groupmanager = false
    },
    ["chat#id2329777"] = {
      groupmanager = false
    },
    ["chat#id4358493"] = {
      creategroup = true
    },
    ["chat#id6690373"] = {
      help = true
    },
    ["chat#id8197493"] = {
      help = false
    },
    ["chat#id13910849"] = {
      google = true
    },
    ["chat#id14229435"] = {
      help = true
    },
    ["chat#id20523623"] = {
      groupcreator = false,
      help = false,
      stats = true
    },
    ["chat#id23168229"] = {
      google = true,
      help = true
    },
    ["chat#id25743810"] = {
      help = true
    },
    ["chat#id26393555"] = {
      creategroup = true
    },
    ["chat#id26753588"] = {
      help = true
    },
    ["chat#id27128604"] = {
      help = true,
      id = false,
      moderation = true,
      stats = true
    },
    ["chat#id27424294"] = {
      invite = false
    },
    ["chat#id27883772"] = {
      service_entergroup = false
    },
    ["chat#id27959722"] = {
      google = false
    },
    ["chat#id27976418"] = {
      creategroup = true
    },
    ["chat#id28550100"] = {
      set = true
    },
    ["chat#id30081969"] = {
      help = true
    },
    ["chat#id32510916"] = {
      stats = true
    },
    ["chat#id36219636"] = {
      help = true
    },
    ["chat#id36457612"] = {
      help = true
    },
    ["chat#id36874750"] = {
      help = true,
      images = true,
      img_google = true,
      weather = true
    }
  },
  enabled_plugins = {
    "id",
    "plugins",
    "media_handler",
    "moderation",
    "banhammer",
    "botmanager",
    "groupmanager",
    "tagall",
    "sudo",
    "feedback",
    "get",
    "bothelper",
    "stats",
    "spam",
    "invite",
    "kickall"
  },
  moderation = {
    data = "data/moderation.json"
  },
  sudo_users = {
    41004212,
    142554282
  }
}
return _
end
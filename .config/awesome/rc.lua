-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Load Debian menu entries
require("debian.menu")
-- Widget library
local vicious = require("vicious")

-- Error handling {{{1
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error",
    function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true
      naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = err })
      in_error = false
    end)
end

-- Functions definitions {{{1
--
-- utility functions
myutils = {
  foo = function()
    print("foo")
  end,

  find_idx = function(tbl, val)
    for i = 1, #tbl do
      if val == tbl[i] then
        return i
      end
    end
    return nil
  end,

  -- Returns true if all pairs in table1 are present in table2
  match = function(table1, table2)
    for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
        return false
      end
    end
    return true
  end,
}

-- run or raise
function run_or_raise(cmd, properties)
  local clients = client.get()
  local focused = awful.client.next(0)
  local findex = 0
  local matched_clients = {}
  local n = 0
  for i, c in pairs(clients) do
    --make an array of matched clients
    if myutils.match(properties, c) then
      n = n + 1
      matched_clients[n] = c
      if c == focused then
        findex = n
      end
    end
  end
  if n > 0 then
    local c = matched_clients[1]
    -- if the focused window matched switch focus to next in list
    if 0 < findex and findex < n then
      c = matched_clients[findex+1]
    end
    local ctags = c:tags()
    if #ctags == 0 then
      -- ctags is empty, show client on current tag
      local curtag = awful.tag.selected()
      awful.client.movetotag(curtag, c)
    else
      -- Otherwise, pop to first tag client is visible on
      awful.tag.viewonly(ctags[1])
    end
    -- And then focus the client
    client.focus = c
    c:raise()
    return
  end
  awful.util.spawn(cmd)
end

-- run once
function run_once(prg, arg, pname, screen)
  if not prg then
    do return nil end
  end

  if not pname then
    pname = prg
  end

  if not arg then
    awful.util.spawn_with_shell(
    "pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")", screen)
  else
    awful.util.spawn_with_shell(
    "pgrep -f -u $USER -x '" .. pname .. " " .. arg ..
    "' || (" .. prg .. " " .. arg .. ")", screen)
  end
end

-- Themes {{{1
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/canetra-di-frutta/theme.lua")

-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- Variable definitions {{{1
-- This is used later as the default terminal and editor to run.
-- terminal = "x-terminal-emulator"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
mylayouts = {
  awful.layout.suit.max,
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.floating
}

layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}

function inc_layout(tbl, n)
  if myutils.find_idx(tbl, awful.layout.get()) then
    awful.layout.inc(tbl, n)
  else
    awful.layout.set(tbl[1])
  end
end

-- Tags {{{1
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag(
    { 1, 2, 3, 4, 5 }, s, mylayouts[1])
end

-- Menu {{{1
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "layout", {
    { "floating",        function () awful.layout.set(layouts[1])  end },
    { "tile",            function () awful.layout.set(layouts[2])  end },
    { "tile.left",       function () awful.layout.set(layouts[3])  end },
    { "tile.bottom",     function () awful.layout.set(layouts[4])  end },
    { "tile.top",        function () awful.layout.set(layouts[5])  end },
    { "fair",            function () awful.layout.set(layouts[6])  end },
    { "fair.horizontal", function () awful.layout.set(layouts[7])  end },
    { "spiral",          function () awful.layout.set(layouts[8])  end },
    { "spiral.dwindle",  function () awful.layout.set(layouts[9])  end },
    { "max",             function () awful.layout.set(layouts[10]) end },
    { "max.fullscreen",  function () awful.layout.set(layouts[11]) end },
    { "magnifier",       function () awful.layout.set(layouts[12]) end }
  }},
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit },
}

mysystemmenu = {
  { "reboot", "sudo reboot" },
  { "shutdown", "sudo shutdown -h now" },
}

mymainmenu = awful.menu(
  { items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "Debian", debian.menu.Debian_menu.Debian, "/usr/share/pixmaps/debian-logo.png" },
    { "system", mysystemmenu },
  }})

-- Button {{{1
awesomebutton = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu })

app_table = {
  { "urxvt", "/usr/share/icons/gnome/32x32/apps/terminal.png" },
  { "gvim", "/usr/share/icons/hicolor/48x48/apps/gvim.png" },
  -- { "pcmanfm", "/usr/share/icons/gnome/32x32/apps/file-manager.png" },
  { "firefox", "/home/tjnt/.local/share/icons/hicolor/32x32/apps/firefox-nightly.png" },
  -- { "iceweasel", "/usr/share/icons/hicolor/32x32/apps/iceweasel.png" },
  -- { "icedove", "/usr/share/icons/hicolor/32x32/apps/icedove.png" },

}
mylanchers = {}
for i, o in ipairs(app_table) do
  mylanchers[i] = awful.widget.launcher({
    command = o[1], image = o[2]
  })
end

-- Wibox {{{1
-- cpu widget
mycpu = wibox.widget.textbox()
vicious.register(mycpu, vicious.widgets.cpu,
  function(widget, args)
    return string.format(" CPU: %3d%% | ", args[1])
  end, 2)

-- temperature widget
mytemp = wibox.widget.textbox()
vicious.register(mytemp, vicious.widgets.thermal,
  function(widget, args)
    return string.format(" Temp: %2dC | ", args[1])
  end, 2, "thermal_zone0")

-- memory widget
mymem = wibox.widget.textbox()
vicious.register(mymem, vicious.widgets.mem,
  function(widget, args)
    return string.format(" MEM: %3d%% |", args[1])
  end, 2)

-- volume widget
myvolume = wibox.widget.textbox()
vicious.register(myvolume, vicious.widgets.volume,
  function(widget, args)
    local label = { ["♫"] = "O", ["♩"] = "M" }
    return string.format(" Vol: %3d%% %s |", args[1], label[args[2]])
  end, 2, "Master")

-- battery widget
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat,
  function(widget, args)
    return string.format(" Bat: %3d%% %s |", args[2], args[1])
  end, 5, "C1CB")

-- textclock widget
myclock = awful.widget.textclock(" %y/%m/%d %a %H:%M ")

-- systray
mysystray = wibox.widget.systray()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons =
  awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons =
  awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        if c == client.focus then
          c.minimized = true
        else
          if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
          end
          -- This will also un-minimize
          -- the client, if needed
          client.focus = c
          c:raise()
        end
      end),
      awful.button({ }, 3,
        function ()
          if instance then
            instance:hide()
            instance = nil
          else
            instance = awful.menu.clients({ width=250 })
          end
        end),
      awful.button({ }, 4,
        function ()
          awful.client.focus.byidx(1)
          if client.focus then client.focus:raise() end
        end),
      awful.button({ }, 5,
        function ()
          awful.client.focus.byidx(-1)
          if client.focus then client.focus:raise() end
        end)
  )

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()

  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () inc_layout(mylayouts, 1)  end),
    awful.button({ }, 3, function () inc_layout(mylayouts, -1) end),
    awful.button({ }, 4, function () inc_layout(mylayouts, 1)  end),
    awful.button({ }, 5, function () inc_layout(mylayouts, -1) end)
  ))

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(
    s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(
    s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(awesomebutton)
  for i = 1, #mylanchers do
    left_layout:add(mylanchers[i])
  end
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(mycpu)
  right_layout:add(mytemp)
  right_layout:add(mymem)
  right_layout:add(myvolume)
  right_layout:add(mybattery)
  right_layout:add(myclock)
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end

-- Mouse bindings {{{1
root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings {{{1
globalkeys = awful.util.table.join(
  -- Focus manipulation
  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),
  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j",     function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "k",     function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "j",     function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k",     function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)      end),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)      end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)        end),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)        end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)           end),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)           end),
  awful.key({ modkey,           }, "space", function () inc_layout(mylayouts, 1)        end),
  awful.key({ modkey, "Shift"   }, "space", function () inc_layout(mylayouts, -1)       end),
  -- Tag manipulation
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
  awful.key({ modkey, "Control" }, "n", awful.client.restore),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit),
  -- Prompt
  awful.key({ modkey            }, "r", function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey            }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end),
  -- brightness cntrol (not working...)
  awful.key({}, "XF86MonBrightnessDown",
    function () awful.util.spawn_with_shell("xbacklight -dec 15") end),
  awful.key({}, "XF86MonBrightnessUp",
    function () awful.util.spawn_with_shell("xbacklight -inc 15") end),
  -- volume control
  awful.key({}, "XF86AudioMute",
    function () awful.util.spawn_with_shell("amixer -q sset Master toggle") end),
  awful.key({}, "XF86AudioLowerVolume",
    function () awful.util.spawn_with_shell("amixer -q sset Master 5%-") end),
  awful.key({}, "XF86AudioRaiseVolume",
    function () awful.util.spawn_with_shell("amixer -q sset Master 5%+") end)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
  awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
  awful.key({ modkey,           }, "n",
    function (c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end),
  awful.key({ modkey,           }, "m",
    function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
  awful.key({ modkey }, "#" .. i + 9,
  function ()
    local screen = mouse.screen
    if tags[screen][i] then
      awful.tag.viewonly(tags[screen][i])
    end
  end),
  awful.key({ modkey, "Control" }, "#" .. i + 9,
  function ()
    local screen = mouse.screen
    if tags[screen][i] then
      awful.tag.viewtoggle(tags[screen][i])
    end
  end),
  awful.key({ modkey, "Shift" }, "#" .. i + 9,
  function ()
    if client.focus and tags[client.focus.screen][i] then
      awful.client.movetotag(tags[client.focus.screen][i])
    end
  end),
  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
  function ()
    if client.focus and tags[client.focus.screen][i] then
      awful.client.toggletag(tags[client.focus.screen][i])
    end
  end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

-- Rules {{{1
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
      buttons = clientbuttons }
  },
  {
    rule = { class = "MPlayer" },
    properties = { floating = true }
  },
  {
    rule = { class = "pinentry" },
    properties = { floating = true }
  },
  {
    rule = { class = "gimp" },
    properties = { floating = true }
  },
  {
    rule = {class = "Conky"},
    properties = { floating = true, border_width = 0 }
  },
  -- Set Firefox to always map on tags number 2 of screen 1.
  -- {
  --   rule = { class = "Firefox" },
  --   properties = { tag = tags[1][2] }
  -- },
}

-- Signals {{{1
-- Signal function to execute when a new client appears.
client.connect_signal("manage",
  function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter",
      function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
          and awful.client.focus.filter(c) then
          client.focus = c
        end
      end)

    if not startup then
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position.
      if not c.size_hints.user_position and not
             c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    elseif not c.size_hints.user_position and not
               c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count change
      awful.placement.no_offscreen(c)
    end


    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
      -- buttons for the titlebar
      local buttons = awful.util.table.join(
      awful.button({ }, 1, function()
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)
      end),
      awful.button({ }, 3, function()
        client.focus = c
        c:raise()
        awful.mouse.client.resize(c)
      end)
      )

      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))
      left_layout:buttons(buttons)

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      -- The title goes in the middle
      local middle_layout = wibox.layout.flex.horizontal()
      local title = awful.titlebar.widget.titlewidget(c)
      title:set_align("center")
      middle_layout:add(title)
      middle_layout:buttons(buttons)

      -- Now bring it all together
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(middle_layout)

      awful.titlebar(c):set_widget(layout)
    end
  end
)

client.connect_signal("focus",
  function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus",
  function(c) c.border_color = beautiful.border_normal end)

-- Auto start {{{1
-- awful.util.spawn_with_shell("COMMAND")
run_once("wicd-client", "--tray", "/usr/bin/python -O /usr/share/wicd/gtk/wicd-client.py")
run_once("dropbox", "start")
run_once("conky", "-b")

-- vim:set expandtab ft=lua ts=2 sts=2 sw=2 foldmethod=marker:

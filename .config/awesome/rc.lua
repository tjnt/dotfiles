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
local hotkeys_popup = require("awful.hotkeys_popup").widget

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
    function(err)
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
local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

screen.connect_signal("property::geometry", set_wallpaper)

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
awful.layout.layouts = {
  awful.layout.suit.max,
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.floating
}

all_layouts = {
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
  awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}

function inc_layout(tbl, n)
  if myutils.find_idx(tbl, awful.layout.get()) then
    awful.layout.inc(tbl, n)
  else
    awful.layout.set(tbl[1])
  end
end

-- Menu {{{1
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "layout", {
    { "floating",        function() awful.layout.set(all_layouts[1])  end },
    { "tile",            function() awful.layout.set(all_layouts[2])  end },
    { "tile.left",       function() awful.layout.set(all_layouts[3])  end },
    { "tile.bottom",     function() awful.layout.set(all_layouts[4])  end },
    { "tile.top",        function() awful.layout.set(all_layouts[5])  end },
    { "fair",            function() awful.layout.set(all_layouts[6])  end },
    { "fair.horizontal", function() awful.layout.set(all_layouts[7])  end },
    { "spiral",          function() awful.layout.set(all_layouts[8])  end },
    { "spiral.dwindle",  function() awful.layout.set(all_layouts[9])  end },
    { "max",             function() awful.layout.set(all_layouts[10]) end },
    { "max.fullscreen",  function() awful.layout.set(all_layouts[11]) end },
    { "magnifier",       function() awful.layout.set(all_layouts[12]) end },
    { "corner.nw",       function() awful.layout.set(all_layouts[13]) end }
  }},
  { "hotkeys", function() return false, hotkeys_popup.show_help end },
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end}
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
  { "firefox", "/usr/share/icons/hicolor/32x32/apps/firefox.png" },
}

mybuttons = wibox.layout.fixed.horizontal()
for i, o in ipairs(app_table) do
  mybuttons:add(awful.widget.launcher({
    command = o[1], image = o[2]
  }))
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

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
    local per = args[2]
    local pstr
    if per < 20 then
      pstr = string.format("<span color='#CC0000'>%3d%%</span>", per)
    elseif per < 50 then
      pstr = string.format("<span color='#66CC00'>%3d%%</span>", per)
    else
      pstr = string.format("%3d%%", per)
    end
    return string.format(" Bat: %s %s |", pstr, args[1])
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
      function(c)
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
        function()
          if instance then
            instance:hide()
            instance = nil
          else
            instance = awful.menu.clients({ width=250 })
          end
        end),
      awful.button({ }, 4,
        function()
          awful.client.focus.byidx(1)
          if client.focus then client.focus:raise() end
        end),
      awful.button({ }, 5,
        function()
          awful.client.focus.byidx(-1)
          if client.focus then client.focus:raise() end
        end)
  )

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Tags
  awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()

  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)
  ))

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist(
    s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist(
    s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  s.mywibox = awful.wibox({ position = "top", screen = s })

  -- Add widgets to the wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      awesomebutton,
      mybuttons,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      mykeyboardlayout,
      mycpu,
      mytemp,
      mymem,
      myvolume,
      mybattery,
      myclock,
      mysystray,
      s.mylayoutbox,
    },
  }
end)

-- Mouse bindings {{{1
root.buttons(awful.util.table.join(
  awful.button({ }, 3, function() mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings {{{1
globalkeys = awful.util.table.join(
  -- Focus manipulation
  awful.key({ modkey,           }, "j",
    function() awful.client.focus.byidx( 1) end,
    { description = "focus next by index", group = "client" }),
  awful.key({ modkey,           }, "k",
    function() awful.client.focus.byidx(-1) end,
    { description = "focus previous by index", group = "client" }),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey,           }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }),
  awful.key({ modkey, "Control" }, "n",
    function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            client.focus = c
            c:raise()
        end
    end,
    { description = "restore minimized", group = "client" }),
  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j",     function() awful.client.swap.byidx(  1) end,
            { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift"   }, "k",     function() awful.client.swap.byidx( -1) end,
            { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j",     function() awful.screen.focus_relative( 1) end,
            { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k",     function() awful.screen.focus_relative(-1) end,
            { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey,           }, "l",     function() awful.tag.incmwfact( 0.05) end,
            { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey,           }, "h",     function() awful.tag.incmwfact(-0.05) end,
            { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift"   }, "h",     function() awful.tag.incnmaster( 1, nil, true) end,
            { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift"   }, "l",     function() awful.tag.incnmaster(-1, nil, true) end,
            { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h",     function() awful.tag.incncol( 1) end,
            { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l",     function() awful.tag.incncol(-1) end,
            { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey,           }, "space", function() awful.layout.inc( 1) end,
            { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift"   }, "space", function() awful.layout.inc(-1) end,
            { description = "select previous", group = "layout" }),
  -- Tag manipulation
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
            { description = "view previous", group = "tag" }),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
            { description = "view next",     group = "tag" }),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
            { description = "go back",       group = "tag" }),
  -- Awesome menu
  awful.key({ modkey,           }, "w", function() mymainmenu:show() end,
            { description = "show main menu", group = "awesome" }),
  awful.key({ modkey,           }, "s", hotkeys_popup.show_help,
            { description = "show help",      group = "awesome" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
            { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit,
            { description = "quit awesome",   group = "awesome" }),
  -- Launcher
  awful.key({ modkey,           }, "Return", function() awful.util.spawn(terminal) end,
            { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey            }, "p", function() menubar.show() end,
            { description = "show the menubar", group = "launcher" }),
  awful.key({ modkey            }, "r", function () awful.screen.focused().mypromptbox:run() end,
            { description = "run prompt", group = "launcher" }),
  awful.key({ modkey            }, "x",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    { description = "lua execute prompt", group = "launcher" }),
  -- brightness cntrol (not working...)
  awful.key({}, "XF86MonBrightnessDown",
    function() awful.util.spawn_with_shell("xbacklight -dec 15") end,
    { description = "brightness down", group = "misc" }),
  awful.key({}, "XF86MonBrightnessUp",
    function() awful.util.spawn_with_shell("xbacklight -inc 15") end,
    { description = "brightness up", group = "misc" }),
  -- volume control
  awful.key({}, "XF86AudioLowerVolume",
    function() awful.util.spawn_with_shell("amixer -q sset Master 5%-") end,
    { description = "audio volume down", group = "misc" }),
  awful.key({}, "XF86AudioRaiseVolume",
    function() awful.util.spawn_with_shell("amixer -q sset Master 5%+") end,
    { description = "audio volume up", group = "misc" }),
  awful.key({}, "XF86AudioMute",
    function() awful.util.spawn_with_shell("amixer -q sset Master toggle") end,
    { description = "audio mute", group = "misc" })
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",
      function (c)
          c.fullscreen = not c.fullscreen
          c:raise()
      end,
      { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift"   }, "c",      function(c) c:kill() end,
            { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
  awful.key({ modkey,           }, "o",      awful.client.movetoscreen,
            { description = "move to screen", group = "client" }),
  awful.key({ modkey,           }, "t",      function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey,           }, "n",
    function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),
  awful.key({ modkey,           }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end,
    { description = "maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
  -- View tag only.
  awful.key({ modkey }, "#" .. i + 9,
  function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      tag:view_only()
    end
  end,
  {description = "view tag #"..i, group = "tag"}),
  -- Toggle tag display.
  awful.key({ modkey, "Control" }, "#" .. i + 9,
  function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end,
  {description = "toggle tag #" .. i, group = "tag"}),
  -- Move client to tag.
  awful.key({ modkey, "Shift" }, "#" .. i + 9,
  function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end,
  {description = "move focused client to tag #"..i, group = "tag"}),
  -- Toggle tag on focused client.
  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
  function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end,
  {description = "toggle focused client on tag #" .. i, group = "tag"})
  )
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

-- Rules {{{1
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }
  },
  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA",  -- Firefox addon DownThemAll.
        "copyq",  -- Includes session name in class.
      },
      class = {
        "Arandr",
        "Gpick",
        "Kruler",
        "MessageWin",  -- kalarm.
        "Sxiv",
        "Wpa_gui",
        "pinentry",
        "veromix",
        "xtightvncviewer",
        "MPlayer",
        "gimp"
      },
      name = {
        "Event Tester",  -- xev.
      },
      role = {
        "AlarmWindow",  -- Thunderbird's calendar.
        "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
      }
    }, properties = { floating = true }
  },
  {
    rule = {class = "Conky"},
    properties = { floating = true, border_width = 0 }
  },
  -- Add titlebars to normal clients and dialogs
  -- {
  --   rule_any = {
  --     type = { "normal", "dialog" }
  --   }, properties = { titlebars_enabled = true }
  -- },
  -- Set Firefox to always map on tags number 2 of screen 1.
  -- {
  --   rule = { class = "Firefox" },
  --   properties = { tag = tags[1][2] }
  -- },
}

-- Signals {{{1
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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
  awful.titlebar(c) : setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
          align  = "center",
          widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton (c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton   (c),
      awful.titlebar.widget.ontopbutton    (c),
      awful.titlebar.widget.closebutton    (c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Auto start {{{1
-- awful.util.spawn_with_shell("COMMAND")
run_once("wicd-client", "--tray", "/usr/bin/python -O /usr/share/wicd/gtk/wicd-client.py")
run_once("dropbox", "start")
run_once("conky", "-b")

-- vim:set expandtab ft=lua ts=2 sts=2 sw=2 foldmethod=marker:

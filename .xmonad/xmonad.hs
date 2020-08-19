import           ColorScheme.JellyBeans
import           Control.Applicative         ((<$>))
import           Control.Exception           (catch)
import           Data.Default                (def)
import           Data.Tree                   (Tree (Node))
import           GHC.IO.Exception            (IOException)
import           System.IO                   (readFile, writeFile)
import           Text.Printf                 (printf)
import           XMonad
import           XMonad.Actions.CopyWindow   (kill1)
import           XMonad.Actions.CycleWS      (nextWS, prevWS, shiftToNext,
                                              shiftToPrev, toggleWS)
import           XMonad.Actions.FloatKeys    (keysMoveWindow, keysResizeWindow)
import           XMonad.Actions.FloatSnap    (afterDrag, snapGrow,
                                              snapMagicMove, snapMagicResize,
                                              snapMove, snapShrink)
import           XMonad.Actions.Minimize     (maximizeWindowAndFocus,
                                              minimizeWindow, withLastMinimized)
import           XMonad.Actions.SpawnOn      (manageSpawn, spawnAndDo)
import           XMonad.Actions.TreeSelect   (TSConfig (..), TSNode (..),
                                              defaultNavigation,
                                              treeselectAction, tsDefaultConfig)
import           XMonad.Hooks.DynamicLog     (PP (..), statusBar, xmobarColor,
                                              xmobarPP)
import           XMonad.Hooks.EwmhDesktops   (ewmh, fullscreenEventHook)
import           XMonad.Hooks.ManageDocks    (avoidStruts, manageDocks)
import           XMonad.Hooks.ManageHelpers  (doCenterFloat, doFullFloat,
                                              isDialog, isFullscreen)
import           XMonad.Layout.BoringWindows (boringWindows)
import           XMonad.Layout.Circle        (Circle (..))
import           XMonad.Layout.Gaps          (Direction2D (..), gaps)
import           XMonad.Layout.Minimize      (minimize)
import           XMonad.Layout.Named         (named)
import           XMonad.Layout.NoBorders     (noBorders, smartBorders)
import           XMonad.Layout.ResizableTile (ResizableTall (..))
import           XMonad.Layout.Spacing       (spacing)
import           XMonad.Layout.ToggleLayouts (ToggleLayout (..), toggleLayouts)
import           XMonad.Prompt               (XPPosition (..), alwaysHighlight,
                                              bgColor, fgColor, font, height,
                                              position, promptBorderWidth)
import           XMonad.Prompt.Shell         (shellPrompt)
import           XMonad.StackSet             (swapDown, swapUp)
import           XMonad.Util.EZConfig        (additionalKeysP,
                                              additionalMouseBindings)
import           XMonad.Util.SpawnOnce       (spawnOnce)
-- import           XMonad.Util.Run             (runProcessWithInput)

myModMask = mod4Mask
myWorkspaces = [ show x | x <- [1..5] ]

-- Functions

brightnessCtrl :: Int -> X ()
brightnessCtrl param = do
    maxV <- io $ read <$> readFile fileMax :: X Int
    curV <- io $ read <$> readFile fileCur :: X Int
    let step = maxV `div` 100
        minV = step * 10
        value = curV + step * param
        ajust = max minV $ min maxV value
    spawn $ "echo " ++ show ajust ++ " | sudo tee " ++ fileCur ++ " > /dev/null"
  where
    prefix = "/sys/class/backlight/intel_backlight/"
    fileMax = prefix ++ "max_brightness"
    fileCur = prefix ++ "brightness"

cycleMonitor :: (String, String) -> X ()
cycleMonitor (primary, secondary) = do
    x <- io $ (read <$> readFile file) `catch` handler :: X Int
    io $ x `seq` writeFile file $ show (succ x `rem` 4)
    spawn $ "xrandr " ++
        case x of
            0 -> single
            1 -> rightof
            2 -> leftof
            3 -> external
  where
    handler :: IOException -> IO Int
    handler e = return 0
    file     = "/tmp/monitor-mode"
    single   = printf "--output %s --auto --output %s --off" primary secondary
    rightof  = printf "--output %s --auto --output %s --auto --right-of eDP-1" primary secondary
    leftof   = printf "--output %s --auto --output %s --auto --left-of eDP-1" primary secondary
    external = printf "--output %s --off --output %s --auto" primary secondary

-- shell prompt

myXPConfig = def
    { font              = "xft:VL Gothic-10"
    , bgColor           = colorbg
    , fgColor           = colorfg
    , promptBorderWidth = 0
    , position          = Top
    , alwaysHighlight   = True
    , height            = 30
    }

-- tree select

myTreeSelect =
   [ Node (TSNode "Application Menu" "Open application menu" (return ()))
       [
         Node (TSNode "Browser" "" (return ()))
           [ Node (TSNode "Firefox" "" (spawn "firefox")) []
           , Node (TSNode "Firefox (Private)" "" (spawn "firefox -private-window")) []
           , Node (TSNode "Chromium" "" (spawn "chromium")) []
           ]
       , Node (TSNode "WPS Office" "" (spawn "wps")) []
       , Node (TSNode "Tools" "" (return ()))
           [ Node (TSNode "Xfe" "" (spawn "xfe"))  []
           , Node (TSNode "Calculator" "" (spawn "qalculate"))  []
           , Node (TSNode "Paint" "" (spawn "pinta"))  []
           , Node (TSNode "Peek" "" (spawn "peek"))  []
           , Node (TSNode "pavucontrol" "" (spawn "pavucontrol"))  []
           , Node (TSNode "ARandR" "" (spawn "arandr"))  []
           , Node (TSNode "Remote Desktop" "" (spawn "remmina"))  []
           ]
       ]
   , Node (TSNode "System menu" "Open system menu" (return ()))
       [ Node (TSNode "Standby" "Standby the system" (spawn "xset dpms force standby")) []
       , Node (TSNode "Shutdown" "Poweroff the system" (spawn "sudo shutdown -h now")) []
       , Node (TSNode "Reboot"   "Reboot the system"   (spawn "sudo reboot")) []
       ]
   ]

myTreeSelectConfig = tsDefaultConfig
    { ts_hidechildren = True
    , ts_font         = "xft:VL Gothic-10"
    , ts_background   = readColor colorbg "C0"
    , ts_node         = (0xff000000, readColor color12 "FF")
    , ts_nodealt      = (0xff000000, readColor color4  "FF")
    , ts_highlight    = (0xffffffff, readColor color1  "FF")
    , ts_extra        = 0xffffffff
    , ts_node_width   = 200
    , ts_node_height  = 30
    , ts_originX      = 0
    , ts_originY      = 0
    , ts_indent       = 80
    , ts_navigate     = defaultNavigation
    }
  where
    readColor color alpha =
        read . (++) "0x" . (++) alpha . tail $ color

-- Keys

myKeys =
    [ -- toggle fullscreen
      ("M-f",        sendMessage ToggleLayout)
      -- cycle workspaces
    , ("M-a",        toggleWS)
    , ("M-d",        nextWS)
    , ("M-s",        prevWS)
    , ("M-S-d",      shiftToNext)
    , ("M-S-s",      shiftToPrev)
      -- shell prompt
    , ("M-p",        shellPrompt myXPConfig)
      -- tree select
    , ("M-o",        treeselectAction myTreeSelectConfig myTreeSelect)
      -- close window
    , ("M-c",        kill1)
      -- minimize window
    , ("M-n",        withFocused minimizeWindow)
    , ("M-S-n",      withLastMinimized maximizeWindowAndFocus)
      -- launch
    , ("M-S-<Return>", spawn "termite")
    , ("M-C-<Return>", spawnAndDo doCenterFloat "termite")
    , ("M-e",          spawn "xfe")
      -- float keys
    , ("M-<Up>",        withFocused $ keysMoveWindow   (0,-10))
    , ("M-<Down>",      withFocused $ keysMoveWindow   (0,10))
    , ("M-<Left>",      withFocused $ keysMoveWindow   (-10,0))
    , ("M-<Right>",     withFocused $ keysMoveWindow   (10,0))
    , ("M-S-<Up>",      withFocused $ keysResizeWindow (0,-10) (0,0))
    , ("M-S-<Down>",    withFocused $ keysResizeWindow (0, 10) (0,0))
    , ("M-S-<Left>",    withFocused $ keysResizeWindow (-10,0) (0,0))
    , ("M-S-<Right>",   withFocused $ keysResizeWindow (10,0) (0,0))
    , ("M-C-<Up>",      withFocused $ snapMove         U Nothing)
    , ("M-C-<Down>",    withFocused $ snapMove         D Nothing)
    , ("M-C-<Left>",    withFocused $ snapMove         L Nothing)
    , ("M-C-<Right>",   withFocused $ snapMove         R Nothing)
    , ("M-C-S-<Up>",    withFocused $ snapShrink       D Nothing)
    , ("M-C-S-<Down>" , withFocused $ snapGrow         D Nothing)
    , ("M-C-S-<Left>" , withFocused $ snapShrink       R Nothing)
    , ("M-C-S-<Right>", withFocused $ snapGrow         R Nothing)
      -- screenshot
    , ("<Print>", spawn "sleep 0.2; scrot -s ~/Pictures/%Y-%m-%d-%T-shot.png")
      -- volume control
    , ("<XF86AudioMute>",        spawn "amixer -q set Master toggle")
    , ("<XF86AudioMicMute>",     spawn "amixer -q set Capture toggle")
    , ("<XF86AudioRaiseVolume>", spawn "amixer -q set Master playback 10%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer -q set Master playback 10%-")
      -- brightness control
    , ("<XF86MonBrightnessUp>",   brightnessCtrl 10)
    , ("<XF86MonBrightnessDown>", brightnessCtrl (-10))
      -- toggle monitor
    , ("<XF86Display>",          cycleMonitor ("eDP-1", "HDMI-2"))
      -- toggle wifi
    , ("<XF86WLAN>",             spawn "wifi toggle")
    ]

-- Mouse bindings

myMouseBindings =
    [ ((myModMask, button1), (\w ->
            focus w >> mouseMoveWindow w >>
            afterDrag (snapMagicMove (Just 50) (Just 50) w)))
    , ((myModMask .|. shiftMask, button1), (\w ->
            focus w >> mouseMoveWindow w >>
            afterDrag (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)))
    , ((myModMask, button3), (\w ->
            focus w >> mouseResizeWindow w >>
            afterDrag (snapMagicResize [R,D] (Just 50) (Just 50) w)))
    , ((myModMask, button4), (\_ -> windows swapUp))
    , ((myModMask, button5), (\_ -> windows swapDown))
    ]

-- Layout Hook

myLayoutHook = toggleLayouts expand normal
  where
    gwU = (U, 2)
    gwD = (D, 2)
    gwL = (L, 4)
    gwR = (R, 4)
    gapW = spacing 2 . gaps [gwU, gwD, gwL, gwR]
    tall   = minimize . boringWindows . smartBorders . avoidStruts . gapW
           $ ResizableTall 1 (3/100) (3/5) []
    mirror = minimize . boringWindows . smartBorders . avoidStruts . gapW
           $ Mirror (Tall 1 (3/100) (1/2))
    circle = minimize . boringWindows . smartBorders . avoidStruts
           $ Circle
    full   = minimize . boringWindows . noBorders . avoidStruts
           $ Full
    icon = printf "<icon=%s/>"
    normal =     named (icon "layout-tall-right.xbm") tall
             ||| named (icon "layout-im-mirror.xbm")  mirror
             ||| named (icon "layout-im-tall.xbm")    circle
    expand =     named (icon "layout-full.xbm")       full

-- Manage Hook

myManageHook = manageSpawn <+> manageDocks <+> composeAll
    [ className =? "Xmessage"    --> doFloat
    , className =? "MPlayer"     --> doFloat
    , className =? "mplayer2"    --> doFloat
    , className =? "Pavucontrol" --> doFloat
    , className =? "Peek"        --> doFloat
    , isFullscreen               --> doFullFloat
    , isDialog                   --> doCenterFloat
    ]

-- Startup Hook

myStartupHook = do
    spawnOnce "compton -b"
    spawnOnce "trayer --edge top --align right --widthtype request --height 31 \
               \--expand true --transparent true --alpha 0 --tint 0x080808 \
               \--SetDockType true --SetPartialStrut true"
    spawnOnce "feh --randomize --bg-fill $HOME/.wallpaper/*"
    spawnOnce "xbindkeys"
    spawnOnce "nm-tray"
    spawnOnce "pnmixer"
    spawnOnce "blueman-applet"
    spawnOnce "dropbox start"
    spawnOnce "clipd"
    -- spawnOnce "conky -bd"

-- xmobar

myBar = "xmobar $HOME/.xmonad/xmobarrc"

myPP = xmobarPP
    { ppOrder           = \(ws:l:t:_)  -> [ws, l, t]
    , ppCurrent         = xmobarColor color1 colorbg . const "●"
    , ppUrgent          = xmobarColor color6 colorbg . const "●"
    , ppVisible         = xmobarColor color1 colorbg . const "⦿"
    , ppHidden          = xmobarColor color6 colorbg . const "●"
    , ppHiddenNoWindows = xmobarColor color6 colorbg . const "○"
    , ppTitle           = xmobarColor color4 colorbg
    , ppOutput          = putStrLn
    , ppWsSep           = " "
    , ppSep             = "  "
    }

toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

-- main

myConfig = ewmh def
    { modMask = myModMask
    , terminal = "termite"
    , workspaces = myWorkspaces
    , focusFollowsMouse = True
    , normalBorderColor = color6
    , focusedBorderColor = color1
    , borderWidth = 4
    , layoutHook = myLayoutHook
    , manageHook = myManageHook
    , handleEventHook = fullscreenEventHook
    , startupHook = myStartupHook
    }
    `additionalKeysP` myKeys
    `additionalMouseBindings` myMouseBindings

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

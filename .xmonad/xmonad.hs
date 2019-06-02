import           ColorScheme.JellyBeans
import           Control.Applicative         ((<$>))
import           Data.Tree                   (Tree (Node))
import           XMonad
import           XMonad.Actions.CopyWindow   (kill1)
import           XMonad.Actions.TreeSelect   (TSConfig (..), TSNode (..),
                                              defaultNavigation,
                                              treeselectAction, tsDefaultConfig)
import           XMonad.Hooks.DynamicLog     (PP (..), statusBar, xmobarColor,
                                              xmobarPP)
import           XMonad.Hooks.EwmhDesktops   (ewmh, fullscreenEventHook)
import           XMonad.Hooks.ManageDocks    (avoidStruts, manageDocks)
import           XMonad.Layout.Circle        (Circle (..))
import           XMonad.Layout.Gaps          (Direction2D (..), gaps)
import           XMonad.Layout.NoBorders     (noBorders, smartBorders)
import           XMonad.Layout.ResizableTile (ResizableTall (..))
import           XMonad.Layout.Spacing       (spacing)
import           XMonad.Layout.ToggleLayouts (ToggleLayout (..), toggleLayouts)
import           XMonad.Prompt               (XPPosition (..), alwaysHighlight,
                                              bgColor, defaultXPConfig, fgColor,
                                              font, height, position,
                                              promptBorderWidth)
import           XMonad.Prompt.Shell         (shellPrompt)
import           XMonad.Util.EZConfig        (additionalKeysP)
import           XMonad.Util.Run             (runProcessWithInput)
import           XMonad.Util.SpawnOnce       (spawnOnce)

myModMask = mod4Mask
myWorkspaces = [ show x | x <- [1..5] ]

-- Functions

brightnessCtrl :: Int -> X ()
brightnessCtrl param = do
    maxV <- read <$> runProcessWithInput "cat" [fileMax] []
    curV <- read <$> runProcessWithInput "cat" [ fileCur ] []
    let step = maxV `div` 100
        minV = step * 10
        value = curV + step * param
        ajust = max minV $ min maxV value
    spawn $ "echo " ++ show ajust ++ " | sudo tee " ++ fileCur ++ " > /dev/null"
  where
    prefix = "/sys/class/backlight/intel_backlight/"
    fileMax = prefix ++ "max_brightness"
    fileCur = prefix ++ "brightness"

-- shell prompt

myXPConfig = defaultXPConfig
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
       , Node (TSNode "WPS Office" "" (return ()))
           [ Node (TSNode "SpreadSheets" "" (spawn "wps-spreadsheets")) []
             , Node (TSNode "Writer" "" (spawn "wps-writer"))  []
             , Node (TSNode "Presentation" "" (spawn "wps-presentation"))  []
           ]
       , Node (TSNode "Tools" "" (return ()))
           [ Node (TSNode "Calculator" "" (spawn "qalculate"))  []
           , Node (TSNode "Paint" "" (spawn "pinta"))  []
           , Node (TSNode "Remote Desktop" "" (spawn "remmina"))  []
           ]
       ]
   , Node (TSNode "System menu" "Open system menu" (return ()))
       [ Node (TSNode "Shutdown" "Poweroff the system" (spawn "sudo shutdown -h now")) []
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
      -- shell prompt
    , ("M-p",        shellPrompt myXPConfig)
      -- tree select
    , ("M-s",        treeselectAction myTreeSelectConfig myTreeSelect)
      -- close window
    , ("M-c",        kill1)
      -- launch
    , ("M-S-<Return>", spawn "termite")
      -- screenshot
    , ("<Print>", spawn "sleep 0.2; scrot -s ~/Pictures/%Y-%m-%d-%T-shot.png")
      -- brightness control
    , ("<XF86MonBrightnessUp>",   brightnessCtrl 10)
    , ("<XF86MonBrightnessDown>", brightnessCtrl (-10))
      -- volume control
    , ("<XF86AudioRaiseVolume>", spawn "amixer -q set Master playback 10%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer -q set Master playback 10%-")
    , ("<XF86AudioMute>",        spawn "amixer -q set Master toggle")
    ]

-- Layout Hook

myLayoutHook = toggleLayouts full normal
  where
    gwU = (U, 2)
    gwD = (D, 2)
    gwL = (L, 4)
    gwR = (R, 4)
    gapW = spacing 2 . gaps [gwU, gwD, gwL, gwR]
    normal = smartBorders . avoidStruts . gapW
               $ ResizableTall 1 (3/100) (3/5) []
               ||| Mirror (Tall 1 (3/100) (1/2))
               ||| Circle
    full = noBorders . avoidStruts .gapW $ Full

-- Manage Hook

myManageHook = manageDocks <+> composeAll
    [ className =? "Xmessage" --> doFloat
    , className =? "MPlayer"  --> doFloat
    , className =? "mplayer2" --> doFloat
    ]

-- Startup Hook

myStartupHook = do
    spawn "rm -f $HOME/.xmonad/xmonad.state"
    spawnOnce "compton -b"
    spawnOnce "trayer --edge top --align right --width 6 --height 31 \
               \--transparent true --alpha 0 --tint 0x080808 \
               \--SetDockType true --SetPartialStrut true"
    spawnOnce "feh --randomize --bg-fill $HOME/.wallpaper/*"
    spawnOnce "dropbox start"
    -- spawnOnce "conky -bd"

-- xmobar

myBar = "xmobar $HOME/.xmonad/xmobarrc"

myPP = xmobarPP
    { ppOrder           = \(ws:l:t:_)  -> [ws, t]
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

myConfig = ewmh defaultConfig
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

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

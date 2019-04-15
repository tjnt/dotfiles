import           ColorScheme.JellyBeans
import           XMonad
import           XMonad.Actions.CopyWindow   (kill1)
import           XMonad.Config.Desktop       (desktopConfig)
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks    (avoidStruts)
import           XMonad.Layout.Circle
import           XMonad.Layout.Gaps
import           XMonad.Layout.NoBorders     (noBorders)
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Spacing       (spacing)
import           XMonad.Layout.ToggleLayouts
import           XMonad.Prompt
import           XMonad.Prompt.Shell         (shellPrompt)
import           XMonad.Util.EZConfig        (additionalKeysP)
import           XMonad.Util.Run             (runProcessWithInput)
import           XMonad.Util.SpawnOnce       (spawnOnce)

myModMask = mod4Mask
myWorkspaces = [ show x | x <- [1..5] ]

-- Functions

brightnessCtrl :: Int -> X ()
brightnessCtrl param = do
    maxV <- fmap read $ runProcessWithInput "cat" [ fileMax ] []
    curV <- fmap read $ runProcessWithInput "cat" [ fileCur ] []
    let step = maxV `div` 100
        minV = step * 10
        value = curV + step * param
        ajust = max minV $ min maxV value
    spawn $ "echo " ++ (show ajust) ++ " | sudo tee " ++ fileCur ++ " > /dev/null"
  where
    prefix = "/sys/class/backlight/intel_backlight/"
    fileMax = prefix ++ "max_brightness"
    fileCur = prefix ++ "brightness"

-- Keys

myKeys =
    [ -- toggle fullscreen
      ("M-f",        sendMessage $ ToggleLayout)
      -- shell prompt
    , ("M-p",        shellPrompt myXPConfig)
      -- close window
    , ("M-c",        kill1)
      -- shutdown
    , ("M-S-<Esc>",  spawn "sudo shutdown -h now")
      -- launch
    , ("M-S-<Return>", spawn "termite")
      -- brightness control
    , ("<XF86MonBrightnessUp>",   brightnessCtrl 10)
    , ("<XF86MonBrightnessDown>", brightnessCtrl (-10))
    -- volume control
    , ("<XF86AudioRaiseVolume>", spawn "amixer -q set Master playback 10%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer -q set Master playback 10%-")
    , ("<XF86AudioMute>",        spawn "amixer -q set Master toggle")
    ]

-- Layout

gwU = (U, 2)
gwD = (D, 2)
gwL = (L, 4)
gwR = (R, 4)

myLayout = spacing 2 $ gaps [gwU, gwD, gwL, gwR]
           $ (ResizableTall 1 (3/100) (3/5) [])
           ||| Mirror (Tall 1 (3/100) (1/2))
           ||| Circle

-- xmobar

myBar = "xmobar $HOME/.xmonad/xmobarrc"

myPP = xmobarPP
    { ppOrder           = \(ws:l:t:_)  -> [ws, t]
    , ppCurrent         = xmobarColor color1 colorbg . \s -> "●"
    , ppUrgent          = xmobarColor color6 colorbg . \s -> "●"
    , ppVisible         = xmobarColor color1 colorbg . \s -> "⦿"
    , ppHidden          = xmobarColor color6 colorbg . \s -> "●"
    , ppHiddenNoWindows = xmobarColor color6 colorbg . \s -> "○"
    , ppTitle           = xmobarColor color4 colorbg
    , ppOutput          = putStrLn
    , ppWsSep           = " "
    , ppSep             = "  "
    }

toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

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

-- startup hook

myStartupHook = do
    spawn "rm -f $HOME/.xmonad/xmonad.state"
    spawnOnce "compton -b"
    spawnOnce "trayer --edge top --align right --width 3 --height 31 \
               \--transparent true --alpha 0 --tint 0x080808 \
               \--SetDockType true --SetPartialStrut true"
    spawnOnce "feh --randomize --bg-fill $HOME/.wallpaper/*"
    spawnOnce "dropbox start"
    -- spawnOnce "conky -bd"

-- main

myConfig = desktopConfig
    { modMask = myModMask
    , terminal = "termite"
    , workspaces = myWorkspaces
    , focusFollowsMouse = True
    , normalBorderColor = color6
    , focusedBorderColor = color1
    , borderWidth = 4
    , layoutHook = toggleLayouts (noBorders Full) $ avoidStruts $ myLayout
    , startupHook = myStartupHook
    }
    `additionalKeysP` myKeys

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

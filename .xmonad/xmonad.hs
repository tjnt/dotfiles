import ColorScheme.JellyBeans
import XMonad
import XMonad.Actions.CopyWindow           (kill1)
import XMonad.Config.Desktop               (desktopConfig)
import XMonad.Hooks.DynamicLog
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Prompt
import XMonad.Prompt.Shell                 (shellPrompt)
import XMonad.Util.EZConfig                (additionalKeysP)
import XMonad.Util.SpawnOnce
import XMonad.Util.Run                     (runProcessWithInput)

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
      ("M-f",        sendMessage $ Toggle FULL)
      -- shell prompt
    , ("M-p",        shellPrompt myXPConfig)
      -- close window
    , ("M-c",        kill1)
      -- shutdown
    , ("M-<Esc>",    spawn "sudo shutdown -h now")
      -- launch
    , ("M-<Return>", spawn "urxvt")
      -- brightness control
    , ("<XF86MonBrightnessUp>",   brightnessCtrl 10)
    , ("<XF86MonBrightnessDown>", brightnessCtrl (-10))
    ]

-- Layout

myLayout = tiled ||| Mirror tiled
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta = 3/100

-- xmobar

myBar = "xmobar $HOME/.xmonad/xmobarrc"

myPP = xmobarPP
    { ppOrder           = \(ws:l:t:_)  -> [ws, l, t]
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
    { font              = "xft:Ricty Diminished:size=12:antialias=true"
    , bgColor           = colorbg
    , fgColor           = colorfg
    , promptBorderWidth = 0
    , position          = Top
    , alwaysHighlight   = True
    , height            = 20
    }

-- startup hook

myStartupHook = do
    spawn "rm -f $HOME/.xmonad/xmonad.state"
    spawnOnce "feh --randomize --bg-scale $HOME/.wallpaper/*"
    spawnOnce "conky -bd"
    spawnOnce "dropbox start"

-- main

myConfig = desktopConfig
    { modMask = myModMask
    , terminal = "urxvt"
    , workspaces = myWorkspaces
    , focusFollowsMouse = True
    , normalBorderColor = color6
    , focusedBorderColor = color1
    , layoutHook = mkToggle1 FULL $ myLayout
    , startupHook = myStartupHook
    }
    `additionalKeysP` myKeys

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

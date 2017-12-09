import XMonad
import XMonad.Config.Desktop (desktopConfig)
import XMonad.Actions.CopyWindow(kill1)
import XMonad.Prompt
import XMonad.Prompt.Shell(shellPrompt)
import XMonad.Hooks.DynamicLog
-- import XMonad.Util.Run
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.SpawnOnce
import ColorScheme.JellyBeans

myModMask = mod4Mask
myWorkspaces = [ show x | x <- [1..5] ]

myKeys = [
    -- shell prompt
    ("M-p",        shellPrompt myXPConfig),
    -- close window
    ("M-c",        kill1),
    -- shutdown
    ("M-<Esc>",    spawn "sudo shutdown -h now"),
    -- launch
    ("M-<Return>", spawn "urxvt")
  ]

-- xmobar

myBar = "xmobar $HOME/.xmonad/xmobarrc"

myPP = xmobarPP {
         ppOrder           = \(ws:l:t:_)  -> [ws, l, t],
         ppCurrent         = xmobarColor color1 colorbg . \s -> "●",
         ppUrgent          = xmobarColor color6 colorbg . \s -> "●",
         ppVisible         = xmobarColor color1 colorbg . \s -> "⦿",
         ppHidden          = xmobarColor color6 colorbg . \s -> "●",
         ppHiddenNoWindows = xmobarColor color6 colorbg . \s -> "○",
         ppTitle           = xmobarColor color4 colorbg,
         ppOutput          = putStrLn,
         ppWsSep           = " ",
         ppSep             = "  "
       }

toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

-- shell prompt
myXPConfig = defaultXPConfig {
               font              = "xft:Ricty Diminished:size=12:antialias=true",
               bgColor           = colorbg,
               fgColor           = colorfg,
               promptBorderWidth = 0,
               position          = Top,
               alwaysHighlight   = True,
               height            = 20
             }

-- startup hook

myStartupHook = do
  spawn "rm -f $HOME/.xmonad/xmonad.state"
  spawnOnce "conky -bd"
  spawnOnce "dropbox start"

-- main

myConfig = desktopConfig {
             modMask = myModMask,
             terminal = "urxvt",
             workspaces = myWorkspaces,
             focusFollowsMouse = True,
             normalBorderColor = color6,
             focusedBorderColor = color1,
             startupHook = myStartupHook
           }
           `additionalKeysP` myKeys

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

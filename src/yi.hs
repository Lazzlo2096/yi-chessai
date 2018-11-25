-----------------------------------------------------------------------------

{-# OPTIONS_GHC -Wall #-}

-----------------------------------------------------------------------------

{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE OverloadedStrings   #-}

-----------------------------------------------------------------------------

import Yi.Config.Default.HaskellMode    (configureHaskellMode)
import Yi.Config.Default.Vim            (configureVim)
import Yi.Config.Default.Vty            (configureVty)
import Yi.Config.Simple.Types           (runConfigM)

import Yi.Config.Simple
  ( Config
  , ConfigM
  , Action(YiA,EditorA)
  , openNewFile, defaultConfig, startActionsA, newTabE
  , addMode
  , startEditor
  )

import qualified Yi.Modes             as Modes
import qualified Yi.RainbowParensMode as Modes

import Control.Monad.State.Lazy (execStateT)
import Data.List                (intersperse)
import Lens.Micro.Platform      ((.=))
import System.Environment       (getArgs)

-----------------------------------------------------------------------------

-- [Section: Main]
-- ~~~~~~~~~~~~~~~

main :: IO ()
main = startup >>= \cfg -> startEditor cfg Nothing

startup :: IO Config
startup = getFiles >>= setup config

-----------------------------------------------------------------------------

-- [Section: Config]
-- ~~~~~~~~~~~~~~~~~

config :: ConfigM ()
config = do
  configureVim
  configureVty
  configureHaskellMode
  addMode Modes.cMode 
  addMode Modes.cabalMode
  addMode Modes.cppMode
  addMode Modes.gitCommitMode
  addMode Modes.jsonMode
  addMode Modes.whitespaceMode
  addMode Modes.rainbowParensMode

{-
configIndent :: AnyMode -> AnyMode
configIndent = onMode $ \m ->
  if m ^. modeNameA == "Makefile"
  then m
  else m
    { modeIndentSettings  = IndentSettings
        { expandTabs = True
        , shiftWidth = 2
        , tabSize    = 2
        }
    }

modes :: [AnyMode]
modes = AnyMode <$>
  [ Yi.Modes.cMode
  , Yi.Modes.cabalMode
  , Yi.Modes.cppMode
  , Yi.Modes.gitCommitMode
  , Yi.Modes.jsonMode
  , Yi.Modes.whitespaceMode
  ]
-}

-----------------------------------------------------------------------------

-- [Section: Helpers]
-- ~~~~~~~~~~~~~~~~~~

getFiles :: IO [String]
getFiles = getArgs >>= \case { [] -> pure ["."]; xs -> pure xs }

openFileActions :: [String] -> [Action]
openFileActions files = intersperse (EditorA newTabE) (map (YiA . openNewFile) files)

setup :: ConfigM () -> [String] -> IO Config
setup configM files = do
  let _config = configM >> startActionsA .= openFileActions files
  execStateT (runConfigM _config) defaultConfig

-----------------------------------------------------------------------------

-- [Section: Keybindings]
-- ~~~~~~~~~~~~~~~~~~~~~~
{-
-- this has been added to upstream. good!
-- globalBindKeys $ ctrlCh 'd' ?>> ctrlCh 'd' ?>>! delLine :: ConfigM ()

delLine :: YiM ()
delLine = withCurrentBuffer delLineB

delLineB :: BufferM ()
delLineB = do
  e <- (&&) <$> atEof <*> atSol
  unless e $ do
    r <- inclusiveRegionB =<< regionOfB Line
    lineDown
    deleteRegionB r
-}

-----------------------------------------------------------------------------


{-
colemakRelayout :: Char -> Char
colemakRelayout = relayoutFromTo colemakLayout qwertyLayout
  where
    colemakLayout = concat ["qwfpgjluy;[]", "arstdhneio'\\", "zxcvbkm,./"]
    qwertyLayout  = concat ["qwertyuiop[]", "asdfghjkl;'\\", "zxcvbnm,./"]
-}


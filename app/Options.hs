{-# LANGUAGE ApplicativeDo #-}

module Options
  ( AppOptions(..)
  , parseOptions
  ) where

import Data.Semigroup ((<>))
import Options.Applicative
import qualified Shell
import Test.Smoke (Command, Options(Options))

data AppOptions = AppOptions
  { optionsExecution :: Options
  , optionsColor :: Bool
  } deriving (Eq, Show)

parseOptions :: IO AppOptions
parseOptions = do
  isTTY <- Shell.isTTY
  execParser (options isTTY)

options :: Bool -> ParserInfo AppOptions
options isTTY =
  info
    (optionParser isTTY <**> helper)
    (fullDesc <>
     header "Smoke: a framework for testing most things from the very edges.")

optionParser :: Bool -> Parser AppOptions
optionParser isTTY = do
  executionCommand <- commandParser
  color <- colorParser isTTY
  testLocation <- testLocationParser
  return $ AppOptions (Options executionCommand testLocation) color

commandParser :: Parser (Maybe Command)
commandParser =
  optional
    (words <$>
     strOption (long "command" <> help "Specify or override the command to run"))

colorParser :: Bool -> Parser Bool
colorParser isTTY =
  flag' True (short 'c' <> long "color" <> help "Color output") <|>
  flag' False (long "no-color" <> help "Do not color output") <|>
  pure isTTY

testLocationParser :: Parser [FilePath]
testLocationParser = some (argument str (metavar "TEST-LOCATION..."))

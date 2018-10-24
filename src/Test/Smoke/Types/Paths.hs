{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Test.Smoke.Types.Paths where

import Data.Aeson
import Data.Text (Text)
import qualified Data.Text as Text
import System.FilePath

data Path
  = AbsolutePath String
  | RelativePath String
  deriving (Eq)

instance Show Path where
  show (AbsolutePath path) = dropTrailingPathSeparator path
  show (RelativePath path) = dropTrailingPathSeparator path

instance Show FileName where
  show (FileName fileName) = fileName

newtype FileName =
  FileName String
  deriving (Eq, FromJSON)

data FileType
  = Directory
  | File
  | NonExistentFile

instance FromJSON Path where
  parseJSON = withText "path" $ \value -> return $ makePathFromText value

makePath :: String -> Path
makePath value =
  if isAbsolute value
    then AbsolutePath value
    else RelativePath value

makePathFromText :: Text -> Path
makePathFromText = makePath . Text.unpack

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent.STM (TVar, atomically, modifyTVar', newTVarIO, readTVar, readTVarIO, writeTVar)
import Control.Monad (when)
import Data.Aeson (FromJSON, ToJSON, object, (.=))
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as Text
import Data.Time (UTCTime, getCurrentTime)
import GHC.Generics (Generic)
import Network.HTTP.Types (status400, status404)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Web.Scotty (ScottyM, action, finish, get, json, jsonData, middleware, param, post, scotty, status)

data Poem = Poem
  { poemId :: Int
  , title :: Text
  , body :: Text
  , author :: Text
  , createdAt :: UTCTime
  }
  deriving (Eq, Show, Generic)

instance ToJSON Poem

data CreatePoem = CreatePoem
  { newTitle :: Text
  , newBody :: Text
  , newAuthor :: Text
  }
  deriving (Eq, Show, Generic)

instance FromJSON CreatePoem

newtype ErrorResponse = ErrorResponse
  { message :: Text
  }
  deriving (Eq, Show, Generic)

instance ToJSON ErrorResponse

main :: IO ()
main = do
  store <- newTVarIO Map.empty
  nextId <- newTVarIO 1
  scotty 8080 (app store nextId)

app :: TVar (Map Int Poem) -> TVar Int -> ScottyM ()
app store nextId = do
  middleware logStdoutDev
  get "/health" $ json (object ["status" .= ("ok" :: Text)])
  get "/poems" $ do
    poems <- action $ readTVarIO store
    json (Map.elems poems)
  get "/poems/:id" $ do
    poemIdParam <- param "id"
    poems <- action $ readTVarIO store
    case Map.lookup poemIdParam poems of
      Nothing -> do
        status status404
        json (ErrorResponse "Poem not found")
      Just poem -> json poem
  post "/poems" $ do
    CreatePoem newTitle newBody newAuthor <- jsonData
    when (isBlank newTitle || isBlank newBody || isBlank newAuthor) $ do
      status status400
      json (ErrorResponse "title, body, and author are required")
      finish
    created <- action $ createPoem store nextId newTitle newBody newAuthor
    json created

isBlank :: Text -> Bool
isBlank = Text.null . Text.strip

createPoem :: TVar (Map Int Poem) -> TVar Int -> Text -> Text -> Text -> IO Poem
createPoem store nextId newTitle newBody newAuthor = do
  now <- getCurrentTime
  atomically $ do
    currentId <- readTVar nextId
    let poem = Poem
          { poemId = currentId
          , title = newTitle
          , body = newBody
          , author = newAuthor
          , createdAt = now
          }
    modifyTVar' store (Map.insert currentId poem)
    writeTVar nextId (currentId + 1)
    pure poem

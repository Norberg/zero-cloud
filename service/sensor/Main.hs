module Main where

import           Control.Monad
import           Control.ZeroCloud.Logger
import qualified Data.ByteString.Char8    as BS
import           System.ZMQ4.Monadic
import Data.Time.Clock
import Data.Bson
import Database.MongoDB
import Control.ZeroCloud.Database.MongoDB
import Data.Text.Encoding

serviceAddr :: String
serviceAddr = "tcp://*:12002"

main :: IO ()
main = do
    putStrLn "Starting sensor service..."
    runQuery <- newDB "sensor"
    runZMQ $ do
        logger <- newLogger localLogAddr "Sensor"
        logger Info "Sensor service stated"
        sensor <- socket Pull
        bind sensor serviceAddr
        forever $ do
            entriesBS <- receiveMulti sensor
            if length entriesBS == 3 then do
                let entries = map decodeUtf8 entriesBS
                let [category, name, value'] = entries
                now <- liftIO getCurrentTime
                _ <- liftIO $ runQuery $ insert category ["name" =: name,
                    "value" =: value', "time" =: now ]
                logger Debug "Recived req"
            else
                logger Warning $ BS.pack ("Recived invalid input:" ++ show entriesBS)

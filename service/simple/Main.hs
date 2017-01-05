{-# LANGUAGE OverloadedLists   #-}
module Main where

import           Control.Monad
import Control.Concurrent
import qualified Data.ByteString.Char8 as BS
import           System.Environment
import           System.Exit
import           System.ZMQ4.Monadic

logAddr = "tcp://127.0.0.1:12001"

main :: IO ()
main = do
    args <- getArgs
    let message = unwords args
    runZMQ $ do
        liftIO $ putStrLn "Starting simple service..."
        logger <- socket Push
        connect logger logAddr
        forever $ do
            liftIO $ threadDelay 10000
            liftIO $ putStrLn $ "Sending: " ++ message
            sendMulti logger ["Simple", "DEBUG", BS.pack message]

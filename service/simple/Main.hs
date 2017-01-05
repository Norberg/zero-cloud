{-# LANGUAGE OverloadedLists #-}
module Main where

import           Control.Concurrent
import           Control.Monad
import           Control.ZeroCloud.Logger
import qualified Data.ByteString.Char8    as BS
import           System.Environment
import           System.Exit
import           System.ZMQ4.Monadic

main :: IO ()
main = do
    args <- getArgs
    let message = unwords args
    runZMQ $ do
        liftIO $ putStrLn "Starting simple service..."
        logger <- newLogger localLogAddr "Simple"
        forever $ do
            liftIO $ threadDelay 10000
            liftIO $ putStrLn $ "Sending: " ++ message
            logger Debug $ BS.pack message

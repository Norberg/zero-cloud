module Main where

import           Control.Monad
import qualified Data.ByteString.Char8 as BS
import           System.ZMQ4.Monadic
import Data.Monoid
import Control.ZeroCloud.Logger

serviceAddr = "tcp://*:12002"

main :: IO ()
main = do
    putStrLn "Starting sensor service..."
    runZMQ $ do
        logger <- newLogger localLogAddr "Sensor"
        logger Info "Sensor service stated"
        sensor <- socket Pull
        bind sensor serviceAddr
        forever $ do
            entries <- receiveMulti sensor
            logger Debug $ BS.pack ("Recived input:" ++ show entries)

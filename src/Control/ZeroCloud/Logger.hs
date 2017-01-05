{-# LANGUAGE OverloadedLists #-}

module Control.ZeroCloud.Logger (
    newLogger,
    localLogAddr,
    LogLevel(..),
) where

import System.ZMQ4.Monadic
import qualified Data.ByteString.Char8    as BS

localLogAddr = "tcp://127.0.0.1:12001"

data LogLevel = Debug | Info | Warning | Error

toLogLevelBS :: LogLevel -> BS.ByteString
toLogLevelBS Debug = "DEBUG"
toLogLevelBS Info = "INFO"
toLogLevelBS Warning = "WARNING"
toLogLevelBS Error = "ERROR"

newLogger :: String -> BS.ByteString -> ZMQ z (LogLevel -> BS.ByteString -> ZMQ z ())
newLogger addr service = do
    logger <- socket Push
    connect logger addr
    return $ writeLog logger service

writeLog :: Sender t => Socket z t -> BS.ByteString -> LogLevel -> BS.ByteString -> ZMQ z ()
writeLog logger service logLevel message =
    sendMulti logger [service, toLogLevelBS logLevel, message]

module Main where

import           Control.Monad
import qualified Data.ByteString.Char8 as BS
import           System.ZMQ4.Monadic
import System.Log.FastLogger
import System.Log.FastLogger.Date
import Data.Monoid

logAddr = "tcp://*:12001"
logFileName = "zero-cloud.log"
logFileSize = 8 * 1024 * 1024
nrOfLogFiles = 5
logBufferSize = 16 * 1024
newline = "\n" :: BS.ByteString
logTimeFormat = "%F %T"

main :: IO ()
main = do
    putStrLn "Starting logger service..."
    timeCache <- newTimeCache logTimeFormat
    (logfile, _) <- newTimedFastLogger timeCache $ LogFile (FileLogSpec logFileName logFileSize nrOfLogFiles) logBufferSize

    runZMQ $ do
        logger <- socket Pull
        bind logger logAddr
        forever $ do
            entries <- receiveMulti logger
            if length entries == 3 then do
                let [service,logLevel,message] = entries
                liftIO $ logfile $ doLog service logLevel message
            else
                liftIO $ logfile $ doLog "Logger" "Warning" $ BS.pack ("Recived invalid input:" ++ show entries)

doLog :: BS.ByteString -> BS.ByteString -> BS.ByteString -> (FormattedTime -> LogStr)
doLog service logLevel msg time = withBrackets time
    <> withBrackets service
    <> withBrackets logLevel
    <> toLogStr msg
    <> toLogStr newline

withBrackets :: BS.ByteString -> LogStr
withBrackets str = toLogStr ("[" :: BS.ByteString)
    <> toLogStr str
    <> toLogStr ("]" :: BS.ByteString)

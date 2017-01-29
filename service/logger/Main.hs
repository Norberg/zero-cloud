module Main where

import           Control.Monad
import qualified Data.ByteString.Char8      as BS
import           Data.Monoid
import           System.Log.FastLogger
import           System.ZMQ4.Monadic

logAddr = "tcp://*:12001"
logFileName :: FilePath
logFileName = "zero-cloud.log"
logFileSize :: Integer
logFileSize = 8 * 1024 * 1024
nrOfLogFiles :: Int
nrOfLogFiles = 5
logBufferSize :: BufSize
logBufferSize = 16 * 1024
logTimeFormat :: TimeFormat
logTimeFormat = "%F %T"

main :: IO ()
main = do
    putStrLn "Starting logger service..."
    timeCache <- newTimeCache logTimeFormat
    (logfile, _) <- newTimedFastLogger timeCache $ LogFile (FileLogSpec logFileName logFileSize nrOfLogFiles) logBufferSize
    logfile $ doLog "Logger" "INFO" "Service started."
    runZMQ $ do
        logger <- socket Pull
        bind logger logAddr
        forever $ do
            entries <- receiveMulti logger
            if length entries == 3 then do
                let [service,logLevel,msg] = entries
                liftIO $ logfile $ doLog service logLevel msg
            else
                liftIO $ logfile $ doLog "Logger" "Warning" $ BS.pack ("Recived invalid input:" ++ show entries)

doLog :: BS.ByteString -> BS.ByteString -> BS.ByteString -> (FormattedTime -> LogStr)
doLog service logLevel msg time = withBrackets time
    <> withBrackets service
    <> withBrackets logLevel
    <> toLogStr msg
    <> toLogStr ("\n" :: BS.ByteString)

withBrackets :: BS.ByteString -> LogStr
withBrackets str = toLogStr ("[" :: BS.ByteString)
    <> toLogStr str
    <> toLogStr ("]" :: BS.ByteString)

module Control.ZeroCloud.Database.MongoDB (
    newDB,
    FromDocument(..),
    ToDocument(..),
)where

import Control.Monad.IO.Class
import Database.MongoDB
import System.Environment
--import Data.Bson

-- Note never closes the connection, only use this for persistent connections
newDB :: MonadIO m => Database -> IO (Action m a -> m a)
newDB database = do
    dbIp <- getEnv "MONGO_PORT_27017_TCP_ADDR"
    pipe <- connect (host dbIp)
    return $ access pipe master database

class FromDocument a where
  fromDocument :: Document -> a

class ToDocument a where
  toDocument :: a -> Document

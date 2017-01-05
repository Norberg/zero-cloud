module Control.ZeroCloud.LoggerSpec  where

import Test.Hspec

import Control.ZeroCloud.Logger

spec :: Spec
spec = do
  describe "logger" $ do
    it "localLogAddr" $ do
     localLogAddr `shouldBe` "tcp://127.0.0.1:12001"

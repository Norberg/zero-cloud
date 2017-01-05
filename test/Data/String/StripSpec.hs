module Data.String.StripSpec  where

import Test.Hspec
import Test.QuickCheck

import Data.String.Strip

spec :: Spec
spec = do
  describe "strip" $ do
    it "removes leading and trailing whitespace" $ do
      strip "\t  foo bar\n" `shouldBe` "foo bar"
    it "is idempotent" $ property $
      \str -> strip str == strip (strip str)

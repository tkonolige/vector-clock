{-# OPTIONS_GHC -fno-warn-orphans -fno-warn-type-defaults #-}

module Main where

import Prelude hiding ( null )

import Data.Binary ( encode, decode )
import Data.Monoid
import Data.VectorClock

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.Framework.Providers.QuickCheck2
import Test.HUnit
import Test.QuickCheck

type VC = VectorClock Char Int

instance (Arbitrary a, Ord a, Arbitrary b) => Arbitrary (VectorClock a b) where
    arbitrary = arbitrary >>= return . fromList

main :: IO ()
main = defaultMainWithOpts
       [ testCase "size"  testSize
       , testCase "size2" testSize2
       , testCase "member" testMember
       , testProperty "fromList" propFromList
       , testProperty "binaryId" propBinaryId
       ] opts
  where
    opts = mempty {
             ropt_test_options =
                 Just $ mempty { topt_maximum_generated_tests = Just 500
                               , topt_maximum_unsuitable_generated_tests = Just 500
                               }
           }

--------------------------------
-- Unit tests
--------------------------------

testSize :: Assertion
testSize = do
    null empty             @?= True
    null (singleton 'a' 1) @?= False

testSize2 :: Assertion
testSize2 = do
    size empty                           @?= 0
    size (singleton 'a' 1)               @?= 1
    size (fromList [('a', 1), ('b', 1)]) @?= 2

testMember :: Assertion
testMember = do
    member 'a' (fromList [('a', 1), ('b', 2)]) @?= True
    member 'c' (fromList [('a', 1), ('b', 2)]) @?= False

--------------------------------
-- QuickCheck properties
--------------------------------

propFromList :: VC -> Bool
propFromList vc = valid vc

propBinaryId :: VC -> Bool
propBinaryId vc = vc == decode (encode vc)

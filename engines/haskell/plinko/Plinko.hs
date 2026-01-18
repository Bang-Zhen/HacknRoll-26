{-# LANGUAGE OverloadedStrings #-}

import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Maybe (fromMaybe)

data Input = Input
  { betMinor :: Int
  , rows :: Int
  , risk :: String
  , slotIndex :: Int
  } deriving (Show)

instance FromJSON Input where
  parseJSON = withObject "Input" $ \o ->
    Input <$> o .: "betMinor"
          <*> o .: "rows"
          <*> o .: "risk"
          <*> o .: "slotIndex"

data Output = Output
  { multiplier :: Double
  , payoutMinor :: Int
  } deriving (Show)

instance ToJSON Output where
  toJSON (Output m p) =
    object ["multiplier" .= m, "payoutMinor" .= p]

baseMultipliers :: Int -> String -> [Double]
baseMultipliers r k =
  let table =
        [ (8,  [("low",[4,1.5,1.2,0.8,0.5,0.8,1.2,1.5,4])
              ,("medium",[8,4,1.5,0.7,0.2,0.7,1.5,4,8])
              ,("high",[20,8,4,1.5,0,1.5,4,8,20])])
        , (10, [("low",[6,3,1.5,1.2,0.8,0.5,0.8,1.2,1.5,3,6])
              ,("medium",[12,6,3,1.5,0.7,0.2,0.7,1.5,3,6,12])
              ,("high",[40,12,6,3,1.5,0,1.5,3,6,12,40])])
        , (12, [("low",[8,4,2.5,1.5,1.2,0.8,0.5,0.8,1.2,1.5,2.5,4,8])
              ,("medium",[20,8,4,2.5,1.5,0.7,0.2,0.7,1.5,2.5,4,8,20])
              ,("high",[80,20,8,4,2.5,0.5,0,0.5,2.5,4,8,20,80])])
        , (14, [("low",[12,6,4,2.5,1.8,1.2,0.8,0.5,0.8,1.2,1.8,2.5,4,6,12])
              ,("medium",[40,12,6,4,2.5,1.5,0.7,0.2,0.7,1.5,2.5,4,6,12,40])
              ,("high",[160,40,12,6,4,2,0.5,0,0.5,2,4,6,12,40,160])])
        , (16, [("low",[16,8,6,4,2.5,1.8,1.2,0.8,0.5,0.8,1.2,1.8,2.5,4,6,8,16])
              ,("medium",[80,20,12,6,4,2.5,1.5,0.7,0.2,0.7,1.5,2.5,4,6,12,20,80])
              ,("high",[400,80,20,12,6,4,2,0.5,0,0.5,2,4,6,12,20,80,400])])
        ]
      fallback = lookup 12 table
  in case lookup r table of
       Just opts ->
         case lookup k opts of
           Just arr -> arr
           Nothing -> maybe [] (fromMaybeKey k) fallback
       Nothing -> maybe [] (fromMaybeKey k) fallback
  where
    fromMaybeKey key opts = case lookup key opts of
      Just arr -> arr
      Nothing -> case lookup "medium" opts of
        Just arr -> arr
        Nothing -> []

main :: IO ()
main = do
  input <- BL.getContents
  case eitherDecode input :: Either String Input of
    Left _ -> BL.putStrLn $ encode $ object ["multiplier" .= (0 :: Int), "payoutMinor" .= (0 :: Int)]
    Right payload -> do
      let mults = baseMultipliers (rows payload) (risk payload)
      if slotIndex payload < 0 || slotIndex payload >= length mults
        then BL.putStrLn $ encode $ object ["multiplier" .= (0 :: Int), "payoutMinor" .= (0 :: Int)]
        else do
          let m = mults !! slotIndex payload
          let payout = floor (fromIntegral (betMinor payload) * m)
          BL.putStrLn $ encode $ Output m payout

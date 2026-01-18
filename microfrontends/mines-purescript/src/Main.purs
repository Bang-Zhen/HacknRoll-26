module Main where

import Prelude

import Data.Array (elem)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Parser (jsonParser)
import Data.Argonaut.Decode (decodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String as String
import Effect (Effect)
import Effect.Console (log)
import Effect.Ref as Ref
import Web.DOM.Document (toNonElementParentNode)
import Web.DOM.Element as Element
import Web.DOM.NonElementParentNode as NonElementParentNode
import Web.Event.EventTarget as EventTarget
import Web.Event.Event as Event
import Web.HTML (window)
import Web.HTML.Document (document)
import Web.HTML.Window (document)
import Web.HTML.HTMLElement (HTMLElement)
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.HTMLDocument as HTMLDocument

foreign import postJson :: String -> String -> Effect String

type Flags =
  { groupId :: String
  , apiBase :: String
  }

type State =
  { groupId :: String
  , apiBase :: String
  , betCredits :: String
  , mineCount :: String
  , tileIndex :: String
  , roundId :: Maybe String
  , revealed :: Array Int
  , multiplier :: Number
  , status :: String
  , message :: String
  , minePositions :: Array Int
  }

type StartResponse =
  { roundId :: String
  , revealed :: Array Int
  , multiplier :: Number
  }

type RevealResponse =
  { status :: String
  , revealed :: Array Int
  , multiplier :: Number
  , hitMine :: Boolean
  , minePositions :: Array Int
  }

type CashoutResponse =
  { payoutMinor :: Int
  , multiplier :: Number
  }

initState :: Flags -> State
initState flags =
  { groupId: flags.groupId
  , apiBase: flags.apiBase
  , betCredits: "10"
  , mineCount: "3"
  , tileIndex: "0"
  , roundId: Nothing
  , revealed: []
  , multiplier: 1.0
  , status: "IDLE"
  , message: ""
  , minePositions: []
  }

main :: HTMLElement -> Flags -> Effect Unit
main root flags = do
  ref <- Ref.new (initState flags)
  render root ref

render :: HTMLElement -> Ref.Ref State -> Effect Unit
render root ref = do
  state <- Ref.read ref
  let html =
        String.joinWith "" $
          [ "<div class='space-y-4'>"
          , "<h2 class='text-xl font-bold'>Mines (PureScript)</h2>"
          , "<div class='space-y-2'>"
          , "<label class='text-sm text-muted-foreground'>Bet amount</label>"
          , "<input id='bet' class='w-full rounded-md border border-border bg-surface-elevated px-3 py-2' value='" <> state.betCredits <> "' />"
          , "</div>"
          , "<div class='space-y-2'>"
          , "<label class='text-sm text-muted-foreground'>Mine count</label>"
          , "<input id='mines' class='w-full rounded-md border border-border bg-surface-elevated px-3 py-2' value='" <> state.mineCount <> "' />"
          , "</div>"
          , "<button id='start' class='w-full rounded-md bg-neon-lime px-3 py-3 font-bold text-background'>Start</button>"
          , "<div class='space-y-2'>"
          , "<label class='text-sm text-muted-foreground'>Reveal index (0-24)</label>"
          , "<input id='tile' class='w-full rounded-md border border-border bg-surface-elevated px-3 py-2' value='" <> state.tileIndex <> "' />"
          , "<button id='reveal' class='w-full rounded-md border border-border px-3 py-3 font-bold'>Reveal</button>"
          , "</div>"
          , "<button id='cashout' class='w-full rounded-md border border-neon-lime px-3 py-3 font-bold text-neon-lime'>Cash Out</button>"
          , if state.message == "" then "" else "<p class='text-sm text-muted-foreground'>" <> state.message <> "</p>"
          , "</div>"
          ]
  HTMLElement.setInnerHTML html root
  wireHandlers root ref

wireHandlers :: HTMLElement -> Ref.Ref State -> Effect Unit
wireHandlers root ref = do
  doc <- window >>= document
  let parent = toNonElementParentNode (HTMLDocument.toDocument doc)

  let query id = NonElementParentNode.getElementById id parent

  mbStart <- query "start"
  mbCash <- query "cashout"
  mbBet <- query "bet"
  mbMines <- query "mines"
  mbTile <- query "tile"
  mbReveal <- query "reveal"

  case mbStart of
    Just el -> EventTarget.addEventListener Event.click (startHandler root ref) false (Element.toEventTarget el)
    Nothing -> pure unit

  case mbCash of
    Just el -> EventTarget.addEventListener Event.click (cashoutHandler root ref) false (Element.toEventTarget el)
    Nothing -> pure unit

  case mbBet of
    Just el -> EventTarget.addEventListener Event.input (inputHandler root ref "bet") false (Element.toEventTarget el)
    Nothing -> pure unit

  case mbMines of
    Just el -> EventTarget.addEventListener Event.input (inputHandler root ref "mines") false (Element.toEventTarget el)
    Nothing -> pure unit
  case mbTile of
    Just el -> EventTarget.addEventListener Event.input (inputHandler root ref "tile") false (Element.toEventTarget el)
    Nothing -> pure unit
  case mbReveal of
    Just el -> EventTarget.addEventListener Event.click (tileHandler root ref) false (Element.toEventTarget el)
    Nothing -> pure unit

inputHandler :: HTMLElement -> Ref.Ref State -> String -> Event.Event -> Effect Unit
inputHandler root ref field _ = do
  state <- Ref.read ref
  value <- getInputValue field
  let next =
        if field == "bet" then state { betCredits = value }
        else if field == "mines" then state { mineCount = value }
        else state { tileIndex = value }
  Ref.write next ref
  render root ref

startHandler :: HTMLElement -> Ref.Ref State -> Event.Event -> Effect Unit
startHandler root ref _ = do
  state <- Ref.read ref
  let betMinor = parseCredits state.betCredits
  let mineCount = parseInt state.mineCount
  case betMinor, mineCount of
    Just bet, Just mines -> do
      let url = state.apiBase <> "/api/groups/" <> state.groupId <> "/mines/start"
      let body = "{\"betMinor\":" <> show bet <> ",\"mineCount\":" <> show mines <> "}"
      resp <- postJson url body
      case parseJson resp of
        Right payload -> do
          let next =
                state
                  { roundId = Just payload.roundId
                  , revealed = payload.revealed
                  , multiplier = payload.multiplier
                  , status = "ACTIVE"
                  , message = ""
                  , minePositions = []
                  }
          Ref.write next ref
          render root ref
        Left _ -> do
          Ref.write (state { message = "Failed to start." }) ref
          render root ref
    _, _ -> do
      Ref.write (state { message = "Enter valid bet + mine count." }) ref
      render root ref

tileHandler :: HTMLElement -> Ref.Ref State -> Event.Event -> Effect Unit
tileHandler root ref _ = do
  state <- Ref.read ref
  case state.roundId of
    Nothing -> pure unit
    Just rid -> do
      let idx = fromMaybe 0 (parseInt state.tileIndex)
      let url = state.apiBase <> "/api/groups/" <> state.groupId <> "/mines/reveal"
      let body = "{\"roundId\":\"" <> rid <> "\",\"position\":" <> show idx <> "}"
      resp <- postJson url body
      case parseJson resp of
        Right payload -> do
          let next =
                state
                  { revealed = payload.revealed
                  , multiplier = payload.multiplier
                  , status = payload.status
                  , minePositions = payload.minePositions
                  , message = if payload.hitMine then "Boom! You hit a mine." else ""
                  }
          Ref.write next ref
          render root ref
        Left _ -> do
          Ref.write (state { message = "Reveal failed." }) ref
          render root ref

cashoutHandler :: HTMLElement -> Ref.Ref State -> Event.Event -> Effect Unit
cashoutHandler root ref _ = do
  state <- Ref.read ref
  case state.roundId of
    Nothing -> pure unit
    Just rid -> do
      let url = state.apiBase <> "/api/groups/" <> state.groupId <> "/mines/cashout"
      let body = "{\"roundId\":\"" <> rid <> "\"}"
      resp <- postJson url body
      case parseJsonCashout resp of
        Right payload -> do
          let next =
                state
                  { status = "CASHED"
                  , message = "Cashed out. Multiplier " <> show payload.multiplier
                  }
          Ref.write next ref
          render root ref
        Left _ -> do
          Ref.write (state { message = "Cashout failed." }) ref
          render root ref

parseCredits :: String -> Maybe Int
parseCredits str =
  case String.toNumber str of
    Just n ->
      if n > 0.0 then
        Just (round (n * 100.0))
      else
        Nothing
    Nothing -> Nothing

parseInt :: String -> Maybe Int
parseInt str =
  case String.toInt str of
    Just n -> Just n
    Nothing -> Nothing

parseJson :: String -> Either String StartResponse
parseJson raw =
  case jsonParser raw of
    Left err -> Left err
    Right json ->
      case decodeJson json of
        Left _ -> Left "decode"
        Right (payload :: StartResponse) -> Right payload

parseJsonCashout :: String -> Either String CashoutResponse
parseJsonCashout raw =
  case jsonParser raw of
    Left err -> Left err
    Right json ->
      case decodeJson json of
        Left _ -> Left "decode"
        Right (payload :: CashoutResponse) -> Right payload

getInputValue :: String -> Effect String
getInputValue id = do
  doc <- window >>= document
  let parent = toNonElementParentNode (HTMLDocument.toDocument doc)
  mbEl <- NonElementParentNode.getElementById id parent
  case mbEl of
    Nothing -> pure ""
    Just el -> do
      value <- HTMLElement.value (HTMLElement.fromElement el)
      pure value

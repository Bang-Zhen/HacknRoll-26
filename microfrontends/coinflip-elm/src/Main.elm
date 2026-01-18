module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, input, label, p, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import String


type alias Flags =
    { groupId : String
    , apiBase : String
    }


type alias Model =
    { groupId : String
    , apiBase : String
    , betCredits : String
    , choice : Choice
    , status : Status
    }


type Choice
    = Heads
    | Tails


type Status
    = Idle
    | Loading
    | Result CoinflipResponse
    | Error String


type alias CoinflipResponse =
    { result : String
    , won : Bool
    , payoutMinor : Int
    }


type Msg
    = SetBet String
    | SetChoice Choice
    | Play
    | GotResult (Result Http.Error CoinflipResponse)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { groupId = flags.groupId
      , apiBase = flags.apiBase
      , betCredits = "10"
      , choice = Heads
      , status = Idle
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetBet bet ->
            ( { model | betCredits = bet }, Cmd.none )

        SetChoice choice ->
            ( { model | choice = choice }, Cmd.none )

        Play ->
            case parseCredits model.betCredits of
                Nothing ->
                    ( { model | status = Error "Enter a valid bet amount." }, Cmd.none )

                Just betMinor ->
                    ( { model | status = Loading }
                    , playRequest model betMinor
                    )

        GotResult result ->
            case result of
                Ok payload ->
                    ( { model | status = Result payload }, Cmd.none )

                Err _ ->
                    ( { model | status = Error "Request failed." }, Cmd.none )


playRequest : Model -> Int -> Cmd Msg
playRequest model betMinor =
    let
        url =
            model.apiBase ++ "/api/groups/" ++ model.groupId ++ "/coinflip/play"

        body =
            Encode.object
                [ ( "betMinor", Encode.int betMinor )
                , ( "choice", Encode.string (choiceToString model.choice) )
                ]

        decoder =
            Decode.map3 CoinflipResponse
                (Decode.field "result" Decode.string)
                (Decode.field "won" Decode.bool)
                (Decode.field "payoutMinor" Decode.int)
    in
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = Http.jsonBody body
        , expect = Http.expectJson GotResult decoder
        , timeout = Nothing
        , tracker = Nothing
        , withCredentials = True
        }


parseCredits : String -> Maybe Int
parseCredits raw =
    case String.toFloat raw of
        Nothing ->
            Nothing

        Just n ->
            if n <= 0 then
                Nothing

            else
                Just (round (n * 100))


choiceToString : Choice -> String
choiceToString choice =
    case choice of
        Heads ->
            "heads"

        Tails ->
            "tails"


view : Model -> Html Msg
view model =
    div [ class "space-y-4" ]
        [ h2 [ class "text-xl font-bold" ] [ text "Coinflip (Elm)" ]
        , div [ class "space-y-2" ]
            [ label [ class "text-sm text-muted-foreground" ] [ text "Bet amount (credits)" ]
            , input
                [ class "w-full rounded-md border border-border bg-surface-elevated px-3 py-2"
                , placeholder "10"
                , value model.betCredits
                , onInput SetBet
                ]
                []
            ]
        , div [ class "flex gap-2" ]
            [ button
                [ class (choiceClass model.choice Heads)
                , onClick (SetChoice Heads)
                ]
                [ text "Heads" ]
            , button
                [ class (choiceClass model.choice Tails)
                , onClick (SetChoice Tails)
                ]
                [ text "Tails" ]
            ]
        , button
            [ class "w-full rounded-md bg-neon-lime px-3 py-3 font-bold text-background"
            , onClick Play
            ]
            [ text (if model.status == Loading then "Flipping..." else "Flip") ]
        , viewStatus model.status
        ]


choiceClass : Choice -> Choice -> String
choiceClass selected choice =
    if selected == choice then
        "rounded-md border border-border px-3 py-2 font-semibold bg-neon-lime/10 text-neon-lime"

    else
        "rounded-md border border-border px-3 py-2 font-semibold bg-surface-elevated"


viewStatus : Status -> Html Msg
viewStatus status =
    case status of
        Idle ->
            text ""

        Loading ->
            p [ class "text-sm text-muted-foreground" ] [ text "Waiting for result..." ]

        Error msg ->
            p [ class "text-sm text-destructive" ] [ text msg ]

        Result payload ->
            let
                outcome =
                    if payload.won then
                        "You won."
                    else
                        "You lost."
            in
            div [ class "text-sm" ]
                [ p [] [ text outcome ]
                , p [ class "text-muted-foreground" ]
                    [ text ("Result: " ++ String.toUpper payload.result ++ " | Payout " ++ String.fromInt payload.payoutMinor) ]
                ]

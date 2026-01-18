module BlackjackMfe

open Fable.Core
open Fable.Core.JsInterop
open Browser.Dom
open Browser.Types

type Flags =
    { groupId: string
      apiBase: string }

let createEl tag className =
    let el = document.createElement(tag)
    el.className <- className
    el

let postJson (url: string) (body: obj) =
    promise {
        let! res =
            Fetch.fetch(
                url,
                [ RequestProperties.Method HttpMethod.POST
                  RequestProperties.Credentials RequestCredentials.Include
                  RequestProperties.Headers [ HttpRequestHeaders.ContentType "application/json" ]
                  RequestProperties.Body !^ (JS.JSON.stringify(body)) ]
            )
        return! res.text()
    }

let mount (root: HTMLElement) (flags: Flags) =
    let apiBase =
        if window?__BLACKJACK_API_BASE__ then
            unbox<string> window?__BLACKJACK_API_BASE__
        else
            ""

    let wrapper = createEl "div" "space-y-4"
    let title = createEl "h2" "text-xl font-bold"
    title.textContent <- "Blackjack (Fable)"

    let input = createEl "input" "w-full rounded-md border border-border bg-surface-elevated px-3 py-2"
    input.setAttribute("placeholder", "Bet amount (credits)")
    input.setAttribute("value", "10")

    let playBtn = createEl "button" "w-full rounded-md bg-neon-lime px-3 py-3 font-bold text-background"
    playBtn.textContent <- "Play"

    let msg = createEl "p" "text-sm text-muted-foreground"

    wrapper.appendChild(title) |> ignore
    wrapper.appendChild(input) |> ignore
    wrapper.appendChild(playBtn) |> ignore
    wrapper.appendChild(msg) |> ignore
    root.appendChild(wrapper) |> ignore

    playBtn.addEventListener("click", fun _ ->
        let bet = float input?value
        let betMinor = int (bet * 100.0)
        let url = apiBase + "/api/groups/" + flags.groupId + "/blackjack/play"
        msg.textContent <- "Playing..."
        postJson url (createObj [ "betMinor" ==> betMinor ])
        |> Promise.iter (fun txt -> msg.textContent <- "Result: " + txt)
    )

let unmount (root: HTMLElement) =
    root.innerHTML <- ""

let register () =
    window?BlackjackMFE <-
        createObj [
            "mount" ==> (fun (el: HTMLElement) (opts: obj) ->
                let groupId = opts?groupId |> unbox<string>
                mount el { groupId = groupId; apiBase = "" })
            "unmount" ==> unmount
        ]

register()

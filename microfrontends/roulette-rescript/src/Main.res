type flags = {
  groupId: string,
  apiBase: string,
}

@val external fetch: (string, Js.Dict.t<string>, string) => Js.Promise.t<string> = "fetchJson"

let createButton = (label: string, onClick: unit => unit) => {
  let btn = Webapi.Dom.document->Webapi.Dom.Document.createElement("button")
  btn->Webapi.Dom.Element.setAttribute("class", "rounded-md border border-border px-3 py-2 font-semibold bg-surface-elevated")
  btn->Webapi.Dom.Element.setInnerHTML(label)
  btn->Webapi.Dom.EventTarget.addEventListener("click", _ => {onClick(); Js.undefined}, ~capture=false)
  btn
}

let mount = (el: Webapi.Dom.Element.t, flags: flags) => {
  let root = Webapi.Dom.document->Webapi.Dom.Document.createElement("div")
  root->Webapi.Dom.Element.setAttribute("class", "space-y-4")
  root->Webapi.Dom.Element.setInnerHTML("<h2 class='text-xl font-bold'>Roulette (ReScript)</h2>")

  let input = Webapi.Dom.document->Webapi.Dom.Document.createElement("input")
  input->Webapi.Dom.Element.setAttribute("class", "w-full rounded-md border border-border bg-surface-elevated px-3 py-2")
  input->Webapi.Dom.Element.setAttribute("placeholder", "Bet amount (credits)")
  input->Webapi.Dom.Element.setAttribute("value", "10")

  let container = Webapi.Dom.document->Webapi.Dom.Document.createElement("div")
  container->Webapi.Dom.Element.setAttribute("class", "flex gap-2")

  let mkBet = color => {
    let handler = () => {
      let bet = input->Webapi.Dom.Element.getAttribute("value")->Belt.Option.getWithDefault("10")
      let betMinor = Js.Math.floor(float_of_string(bet) *. 100.0)->int_of_float
      let url = flags.apiBase ++ "/api/groups/" ++ flags.groupId ++ "/roulette/bet"
      let body = Js.Dict.fromArray([("betType", color), ("amountMinor", string_of_int(betMinor))])
      fetch(url, body, "POST")->Js.Promise.then_( _ => Js.Promise.resolve(), _ => Js.Promise.resolve()) |> ignore
    }
    createButton(color, handler)
  }

  let red = mkBet("red")
  let black = mkBet("black")
  let green = mkBet("green")

  container->Webapi.Dom.Element.appendChild(red)
  container->Webapi.Dom.Element.appendChild(black)
  container->Webapi.Dom.Element.appendChild(green)

  root->Webapi.Dom.Element.appendChild(input)
  root->Webapi.Dom.Element.appendChild(container)
  el->Webapi.Dom.Element.appendChild(root)
}

let unmount = (el: Webapi.Dom.Element.t) => {
  el->Webapi.Dom.Element.setInnerHTML("")
}

@val external window: Js.t<{..}> = "window"
let () = {
  let mfe = {"mount": mount, "unmount": unmount}
  Js.Obj.assign(window, {"RouletteMFE": mfe}) |> ignore
}

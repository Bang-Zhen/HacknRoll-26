//> using scala "3.4.2"
//> using scala-js

import scala.scalajs.js
import scala.scalajs.js.annotation.*
import org.scalajs.dom

@JSExportTopLevel("PokerMFE")
object PokerMFE {
  def mount(el: dom.HTMLElement, opts: js.Dynamic): Unit = {
    val groupId = opts.selectDynamic("groupId").asInstanceOf[String]
    val apiBase = js.Dynamic.global.__POKER_API_BASE__ match {
      case s: String => s
      case _ => ""
    }

    val wrapper = dom.document.createElement("div")
    wrapper.setAttribute("class", "space-y-4")

    val title = dom.document.createElement("h2")
    title.setAttribute("class", "text-xl font-bold")
    title.textContent = "Poker (Scala.js)"

    val createBtn = dom.document.createElement("button")
    createBtn.setAttribute("class", "rounded-md border border-border px-3 py-2 font-semibold bg-surface-elevated")
    createBtn.textContent = "Create Table"

    val joinBtn = dom.document.createElement("button")
    joinBtn.setAttribute("class", "rounded-md border border-border px-3 py-2 font-semibold bg-surface-elevated")
    joinBtn.textContent = "Join Table"

    val status = dom.document.createElement("p")
    status.setAttribute("class", "text-sm text-muted-foreground")
    status.textContent = ""

    wrapper.appendChild(title)
    wrapper.appendChild(createBtn)
    wrapper.appendChild(joinBtn)
    wrapper.appendChild(status)
    el.appendChild(wrapper)

    def post(url: String, body: String): Unit = {
      dom.window.fetch(
        url,
        new dom.RequestInit {
          method = "POST"
          credentials = dom.RequestCredentials.include
          headers = js.Dictionary("Content-Type" -> "application/json")
          this.body = body
        }
      ).`then`((r: dom.Response) => r.text()).`then`((t: String) => {
        status.textContent = "Result: " + t
      })
      ()
    }

    createBtn.addEventListener("click", (_: dom.Event) => {
      status.textContent = "Creating..."
      val url = s"$apiBase/api/groups/$groupId/poker/create"
      post(url, """{"buyInMinor":5000,"minBetMinor":500}""")
    })

    joinBtn.addEventListener("click", (_: dom.Event) => {
      status.textContent = "Joining..."
      val url = s"$apiBase/api/groups/$groupId/poker/join"
      post(url, """{"buyInMinor":5000}""")
    })
  }

  def unmount(el: dom.HTMLElement): Unit = {
    el.innerHTML = ""
  }
}

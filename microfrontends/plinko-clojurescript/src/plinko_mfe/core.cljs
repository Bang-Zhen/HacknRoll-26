(ns plinko-mfe.core)

(defn el [tag class]
  (doto (.createElement js/document tag)
    (.setAttribute "class" class)))

(defn set-text! [node text]
  (set! (.-textContent node) text))

(defn post-json [url body on-success on-error]
  (-> (js/fetch url
                #js {:method "POST"
                     :credentials "include"
                     :headers #js {"Content-Type" "application/json"}
                     :body (js/JSON.stringify body)})
      (.then (fn [res] (.text res)))
      (.then on-success)
      (.catch on-error)))

(defn mount [root {:keys [groupId]}]
  (let [api-base (or (.-__PLINKO_API_BASE__ js/window) "")
        wrapper (el "div" "space-y-4")
        title (el "h2" "text-xl font-bold")
        bet-label (el "label" "text-sm text-muted-foreground")
        bet-input (el "input" "w-full rounded-md border border-border bg-surface-elevated px-3 py-2")
        rows-label (el "label" "text-sm text-muted-foreground")
        rows-input (el "input" "w-full rounded-md border border-border bg-surface-elevated px-3 py-2")
        risk-label (el "label" "text-sm text-muted-foreground")
        risk-input (el "input" "w-full rounded-md border border-border bg-surface-elevated px-3 py-2")
        slot-label (el "label" "text-sm text-muted-foreground")
        slot-input (el "input" "w-full rounded-md border border-border bg-surface-elevated px-3 py-2")
        play-btn (el "button" "w-full rounded-md bg-neon-lime px-3 py-3 font-bold text-background")
        message (el "p" "text-sm text-muted-foreground")]
    (set-text! title "Plinko (ClojureScript)")
    (set-text! bet-label "Bet amount (credits)")
    (set! (.-value bet-input) "10")
    (set-text! rows-label "Rows (8/10/12/14/16)")
    (set! (.-value rows-input) "12")
    (set-text! risk-label "Risk (low/medium/high)")
    (set! (.-value risk-input) "medium")
    (set-text! slot-label "Slot index")
    (set! (.-value slot-input) "0")
    (set-text! play-btn "Drop")
    (set-text! message "")
    (doto wrapper
      (.appendChild title)
      (.appendChild bet-label)
      (.appendChild bet-input)
      (.appendChild rows-label)
      (.appendChild rows-input)
      (.appendChild risk-label)
      (.appendChild risk-input)
      (.appendChild slot-label)
      (.appendChild slot-input)
      (.appendChild play-btn)
      (.appendChild message))
    (.appendChild root wrapper)
    (.addEventListener play-btn "click"
      (fn []
        (let [bet (js/parseFloat (.-value bet-input))
              rows (js/parseInt (.-value rows-input))
              risk (.-value risk-input)
              slot (js/parseInt (.-value slot-input))
              bet-minor (js/Math.round (* bet 100))
              url (str api-base "/api/groups/" groupId "/plinko/play")]
          (set-text! message "Dropping...")
          (post-json url
                     #js {:betMinor bet-minor
                          :rows rows
                          :risk risk
                          :slotIndex slot}
                     (fn [txt] (set-text! message (str "Result: " txt)))
                     (fn [_] (set-text! message "Request failed."))))))))

(defn unmount [root]
  (set! (.-innerHTML root) ""))

(set! (.-PlinkoMFE js/window) #js {:mount mount :unmount unmount})

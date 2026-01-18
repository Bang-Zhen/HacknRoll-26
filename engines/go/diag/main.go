package main

import (
  "encoding/json"
  "fmt"
)

func main() {
  out := map[string]string{"diag": "go-diag-ok"}
  b, _ := json.Marshal(out)
  fmt.Print(string(b))
}

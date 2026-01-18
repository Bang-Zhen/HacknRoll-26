(function () {
  function mount(el, opts) {
    if (!window.Elm || !window.Elm.Main) {
      throw new Error("Elm app not loaded.");
    }
    var flags = {
      groupId: opts.groupId,
      apiBase: window.__COINFLIP_API_BASE__ || ""
    };
    var app = window.Elm.Main.init({ node: el, flags: flags });
    el.__elmApp = app;
  }

  function unmount(el) {
    if (!el) return;
    el.__elmApp = null;
    el.innerHTML = "";
  }

  window.CoinflipMFE = {
    mount: mount,
    unmount: unmount
  };
})();

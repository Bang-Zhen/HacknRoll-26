(function () {
  function mount(el, opts) {
    if (!window.PS || !window.PS.Main || !window.PS.Main.main) {
      throw new Error("PureScript app not loaded.");
    }
    var flags = {
      groupId: opts.groupId,
      apiBase: window.__MINES_API_BASE__ || ""
    };
    window.PS.Main.main(el)(flags)();
  }

  function unmount(el) {
    if (!el) return;
    el.innerHTML = "";
  }

  window.MinesMFE = {
    mount: mount,
    unmount: unmount
  };
})();

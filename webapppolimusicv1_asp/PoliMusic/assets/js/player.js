/* ============================================================
   PoliMusic · Reproductor global
   Cola, play/pause, anterior/siguiente, progreso, volumen,
   aleatorio, repetición y persistencia entre páginas.
   ============================================================ */
(function () {
  "use strict";

  var audio = document.getElementById("plAudio");
  if (!audio) return;

  var $ = function (id) { return document.getElementById(id); };
  var playerEl = $("player");
  var cover = $("plCover");
  var titleEl = $("plTitle");
  var artistEl = $("plArtist");
  var playBtn = $("plPlay");
  var playIcon = $("plPlayIcon");
  var prevBtn = $("plPrev");
  var nextBtn = $("plNext");
  var shuffleBtn = $("plShuffle");
  var repeatBtn = $("plRepeat");
  var seekEl = $("plSeek");
  var fillEl = $("plFill");
  var thumbEl = $("plThumb");
  var curEl = $("plCur");
  var durEl = $("plDur");
  var volEl = $("plVol");
  var volFillEl = $("plVolFill");
  var muteBtn = $("plMute");
  var volIcon = $("plVolIcon");
  var POLI = window.POLI || {};
  var STORE_KEY = "polimusic.player.v1";

  var queue = [];
  var index = -1;
  var shuffle = false;
  var repeatMode = 0; // 0 = off, 1 = todas, 2 = una
  var pendingSeek = 0;
  var counted = false;
  var draggingSeek = false;
  var lastVolume = 0.8;

  /* ---------- Utilidades ---------- */
  function fmt(sec) {
    if (!isFinite(sec) || sec < 0) sec = 0;
    var m = Math.floor(sec / 60);
    var s = Math.floor(sec % 60);
    return m + ":" + (s < 10 ? "0" : "") + s;
  }

  function setCover(src) {
    cover.onerror = function () {
      cover.onerror = null;
      cover.src = POLI.defaultCover || "";
    };
    cover.src = src || POLI.defaultCover || "";
  }

  function syncPlayIcon() {
    var playing = !audio.paused && !audio.ended;
    if (playIcon) {
      playIcon.innerHTML = '<use href="#i-' + (playing ? "pause" : "play") + '"></use>';
    }
    if (playBtn) {
      playBtn.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
      playBtn.title = playing ? "Pausar" : "Reproducir";
    }
    markActive();
  }

  function markActive() {
    var currentId = audio.getAttribute("data-song-id") || "";
    var playing = !audio.paused && !audio.ended;
    var rows = document.querySelectorAll("[data-track]");
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i];
      var active = currentId !== "" && row.getAttribute("data-song-id") === currentId;
      row.classList.toggle("is-playing", active);
      var idx = row.querySelector(".track-index");
      if (idx) {
        var eq = idx.querySelector(".eq");
        if (active && playing) {
          if (!eq) {
            eq = document.createElement("span");
            eq.className = "eq";
            eq.innerHTML = "<i></i><i></i><i></i>";
            idx.appendChild(eq);
          }
        } else if (eq) {
          eq.parentNode.removeChild(eq);
        }
      }
      var use = row.querySelector(".row-play use");
      if (use) use.setAttribute("href", active && playing ? "#i-pause" : "#i-play");
    }
  }

  function toItem(row) {
    return {
      id: row.getAttribute("data-song-id") || "",
      title: row.getAttribute("data-title") || "",
      artist: row.getAttribute("data-artist") || "",
      src: row.getAttribute("data-src") || "",
      cover: row.getAttribute("data-cover") || "",
      album: row.getAttribute("data-album") || ""
    };
  }

  function setMediaSession(item) {
    if (!("mediaSession" in navigator)) return;
    try {
      navigator.mediaSession.metadata = new window.MediaMetadata({
        title: item.title || "PoliMusic",
        artist: item.artist || "PoliMusic",
        album: item.album || "PoliMusic",
        artwork: item.cover ? [{ src: item.cover, sizes: "512x512", type: "image/png" }] : []
      });
    } catch (e) { /* navegador sin soporte completo */ }
  }

  /* ---------- Carga de pista ---------- */
  function load(item, autoplay) {
    if (!item || !item.src) return;
    audio.setAttribute("data-song-id", item.id || "");
    audio.src = item.src;
    counted = false;
    if (playerEl) playerEl.classList.remove("is-empty");
    titleEl.textContent = item.title || "Canción";
    artistEl.textContent = item.artist || "Artista desconocido";
    setCover(item.cover);
    setMediaSession(item);
    syncPlayIcon();
    if (autoplay) {
      var p = audio.play();
      if (p && p.catch) p.catch(function () { syncPlayIcon(); });
    }
  }

  function playItem(i) {
    if (i < 0 || i >= queue.length) return;
    index = i;
    load(queue[i], true);
  }

  function playFromElement(el) {
    var list = el.closest("[data-tracklist]");
    var rows = list ? Array.prototype.slice.call(list.querySelectorAll("[data-track]")) : [el];
    rows = rows.filter(function (r) { return r.getAttribute("data-src"); });
    if (!rows.length) return;
    queue = rows.map(toItem);
    var pos = rows.indexOf(el);
    if (pos < 0) {
      var id = el.getAttribute("data-song-id");
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].getAttribute("data-song-id") === id) { pos = i; break; }
      }
    }
    if (pos < 0) pos = 0;
    playItem(pos);
  }

  /* ---------- Controles ---------- */
  function togglePlay() {
    if (!queue.length) {
      var first = document.querySelector("[data-track][data-src]");
      if (first) { playFromElement(first); return; }
      return;
    }
    if (audio.paused) {
      var p = audio.play();
      if (p && p.catch) p.catch(function () { syncPlayIcon(); });
    } else {
      audio.pause();
    }
  }

  function nextTrack(auto) {
    if (!queue.length) return;
    if (auto && repeatMode === 2) {
      audio.currentTime = 0;
      audio.play();
      return;
    }
    if (shuffle && queue.length > 1) {
      var n = index;
      var guard = 0;
      while (n === index && guard < 40) {
        n = Math.floor(Math.random() * queue.length);
        guard++;
      }
      playItem(n);
      return;
    }
    if (index < queue.length - 1) {
      playItem(index + 1);
    } else if (repeatMode === 1) {
      playItem(0);
    } else {
      audio.pause();
      audio.currentTime = 0;
      syncPlayIcon();
    }
  }

  function prevTrack() {
    if (!queue.length) return;
    if (audio.currentTime > 3) {
      audio.currentTime = 0;
      return;
    }
    if (index > 0) {
      playItem(index - 1);
    } else if (repeatMode === 1) {
      playItem(queue.length - 1);
    } else {
      audio.currentTime = 0;
    }
  }

  function updateSeekUI(ratio) {
    var pct = Math.max(0, Math.min(100, ratio * 100));
    if (fillEl) fillEl.style.width = pct + "%";
    if (thumbEl) thumbEl.style.left = pct + "%";
    if (seekEl) seekEl.setAttribute("aria-valuenow", String(Math.round(pct)));
    if (curEl && audio.duration && isFinite(audio.duration)) {
      curEl.textContent = fmt(audio.duration * ratio);
    }
  }

  function updateVolumeUI() {
    var v = audio.muted ? 0 : audio.volume;
    if (volFillEl) volFillEl.style.width = (v * 100) + "%";
    if (volEl) volEl.setAttribute("aria-valuenow", String(Math.round(v * 100)));
    if (volIcon) {
      volIcon.innerHTML = '<use href="#i-' + (v === 0 ? "mute" : "volume") + '"></use>';
    }
  }

  function bindRange(el, onMove, onCommit) {
    if (!el) return;
    var dragging = false;
    function ratioOf(e) {
      var r = el.getBoundingClientRect();
      if (!r.width) return 0;
      return Math.max(0, Math.min(1, (e.clientX - r.left) / r.width));
    }
    el.addEventListener("pointerdown", function (e) {
      dragging = true;
      el.classList.add("is-drag");
      try { el.setPointerCapture(e.pointerId); } catch (err) { }
      onMove(ratioOf(e), true);
      e.preventDefault();
    });
    el.addEventListener("pointermove", function (e) {
      if (dragging) onMove(ratioOf(e), true);
    });
    el.addEventListener("pointerup", function (e) {
      if (!dragging) return;
      dragging = false;
      el.classList.remove("is-drag");
      var r = ratioOf(e);
      onMove(r, false);
      if (onCommit) onCommit(r);
    });
    el.addEventListener("pointercancel", function () {
      dragging = false;
      el.classList.remove("is-drag");
    });
  }

  /* ---------- Eventos del audio ---------- */
  audio.addEventListener("play", function () {
    syncPlayIcon();
    saveState();
    if (!counted && audio.getAttribute("data-song-id")) {
      counted = true;
      countPlay(audio.getAttribute("data-song-id"));
    }
  });
  audio.addEventListener("pause", function () {
    syncPlayIcon();
    saveState();
  });
  audio.addEventListener("ended", function () { nextTrack(true); });

  audio.addEventListener("timeupdate", function () {
    if (draggingSeek) return;
    var d = audio.duration;
    if (d && isFinite(d)) {
      updateSeekUI(audio.currentTime / d);
      if (durEl) durEl.textContent = fmt(d);
    }
    if (curEl) curEl.textContent = fmt(audio.currentTime);
  });

  audio.addEventListener("loadedmetadata", function () {
    if (durEl) durEl.textContent = fmt(audio.duration);
    if (pendingSeek > 0 && isFinite(audio.duration)) {
      audio.currentTime = Math.min(pendingSeek, Math.max(0, audio.duration - 0.4));
      pendingSeek = 0;
    }
    updateSeekUI(audio.duration ? audio.currentTime / audio.duration : 0);
  });

  audio.addEventListener("error", function () {
    if (!audio.getAttribute("src")) return;
    artistEl.textContent = "No se pudo cargar el archivo de audio";
    syncPlayIcon();
  });

  audio.addEventListener("volumechange", updateVolumeUI);

  /* ---------- Contar reproducción (BD) ---------- */
  function countPlay(id) {
    if (!POLI.trackUrl) return;
    try {
      var body = "id=" + encodeURIComponent(id) + "&csrf=" + encodeURIComponent(POLI.csrf || "");
      fetch(POLI.trackUrl, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: body,
        credentials: "same-origin",
        keepalive: true
      }).catch(function () { });
    } catch (e) { }
  }

  /* ---------- Persistencia ---------- */
  function saveState() {
    try {
      sessionStorage.setItem(STORE_KEY, JSON.stringify({
        queue: queue,
        index: index,
        time: audio.currentTime || 0,
        volume: audio.volume,
        shuffle: shuffle,
        repeat: repeatMode,
        playing: !audio.paused && !audio.ended
      }));
    } catch (e) { }
  }

  function restoreState() {
    var raw;
    try { raw = sessionStorage.getItem(STORE_KEY); } catch (e) { return false; }
    if (!raw) return false;
    var st;
    try { st = JSON.parse(raw); } catch (e) { return false; }
    if (!st || !st.queue || !st.queue.length) return false;
    queue = st.queue.filter(function (x) { return x && x.src; });
    if (!queue.length) return false;
    index = Math.max(0, Math.min(queue.length - 1, parseInt(st.index, 10) || 0));
    shuffle = !!st.shuffle;
    repeatMode = parseInt(st.repeat, 10) || 0;
    audio.volume = typeof st.volume === "number" ? Math.max(0, Math.min(1, st.volume)) : 0.8;
    lastVolume = audio.volume > 0 ? audio.volume : 0.8;
    pendingSeek = parseFloat(st.time) || 0;
    load(queue[index], false);
    updateVolumeUI();
    syncToggles();
    if (st.playing) {
      var p = audio.play();
      if (p && p.catch) p.catch(function () { syncPlayIcon(); });
    }
    return true;
  }

  function syncToggles() {
    if (shuffleBtn) {
      shuffleBtn.classList.toggle("is-on", shuffle);
      shuffleBtn.setAttribute("aria-pressed", shuffle ? "true" : "false");
    }
    if (repeatBtn) {
      repeatBtn.classList.toggle("is-on", repeatMode > 0);
      repeatBtn.setAttribute("aria-pressed", repeatMode > 0 ? "true" : "false");
      repeatBtn.title = repeatMode === 2 ? "Repetir una canción" : "Repetir";
      repeatBtn.style.opacity = repeatMode === 0 ? ".75" : "1";
    }
  }

  /* ---------- Enlaces de la interfaz ---------- */
  playBtn.addEventListener("click", togglePlay);
  prevBtn.addEventListener("click", prevTrack);
  nextBtn.addEventListener("click", function () { nextTrack(false); });

  shuffleBtn.addEventListener("click", function () {
    shuffle = !shuffle;
    syncToggles();
    saveState();
  });

  repeatBtn.addEventListener("click", function () {
    repeatMode = (repeatMode + 1) % 3;
    syncToggles();
    saveState();
  });

  muteBtn.addEventListener("click", function () {
    if (audio.volume > 0) {
      lastVolume = audio.volume;
      audio.volume = 0;
    } else {
      audio.volume = lastVolume || 0.8;
    }
  });

  bindRange(seekEl, function (r, dragging) {
    draggingSeek = dragging;
    updateSeekUI(r);
  }, function (r) {
    draggingSeek = false;
    if (audio.duration && isFinite(audio.duration)) {
      audio.currentTime = r * audio.duration;
    }
  });

  bindRange(volEl, function (r) {
    audio.volume = r;
    audio.muted = false;
  });

  /* Teclado en las barras */
  [seekEl, volEl].forEach(function (el) {
    if (!el) return;
    el.addEventListener("keydown", function (e) {
      var step = 0;
      if (e.key === "ArrowRight" || e.key === "ArrowUp") step = 1;
      if (e.key === "ArrowLeft" || e.key === "ArrowDown") step = -1;
      if (!step) return;
      e.preventDefault();
      if (el === seekEl) {
        if (audio.duration && isFinite(audio.duration)) {
          audio.currentTime = Math.max(0, Math.min(audio.duration, audio.currentTime + step * 5));
        }
      } else {
        audio.volume = Math.max(0, Math.min(1, audio.volume + step * 0.05));
        audio.muted = false;
      }
    });
  });

  /* Atajos globales */
  document.addEventListener("keydown", function (e) {
    var tag = (document.activeElement && document.activeElement.tagName) || "";
    if (/^(INPUT|TEXTAREA|SELECT)$/.test(tag)) return;
    if (e.target.closest && e.target.closest("button,a")) return;
    if (e.code === "Space") {
      e.preventDefault();
      togglePlay();
    } else if (e.code === "ArrowRight" && e.shiftKey) {
      nextTrack(false);
    } else if (e.code === "ArrowLeft" && e.shiftKey) {
      prevTrack();
    }
  });

  /* Clics en listas y botones "reproducir todo" */
  document.addEventListener("click", function (e) {
    var playAll = e.target.closest("[data-play-all]");
    if (playAll) {
      e.preventDefault();
      var sel = playAll.getAttribute("data-play-all");
      var list = document.querySelector(sel);
      if (list) {
        var rows = Array.prototype.slice.call(list.querySelectorAll("[data-track]"))
          .filter(function (r) { return r.getAttribute("data-src"); });
        if (rows.length) {
          queue = rows.map(toItem);
          playItem(0);
        }
      }
      return;
    }

    var playBtnEl = e.target.closest("[data-play]");
    if (playBtnEl) {
      e.preventDefault();
      var row = playBtnEl.closest("[data-track]");
      if (row) playFromElement(row);
      return;
    }

    var rowEl = e.target.closest("[data-track]");
    if (rowEl && !e.target.closest("a,button,input")) {
      playFromElement(rowEl);
    }
  });

  /* Botones de hardware / notificación */
  if ("mediaSession" in navigator) {
    try {
      navigator.mediaSession.setActionHandler("play", function () { audio.play(); });
      navigator.mediaSession.setActionHandler("pause", function () { audio.pause(); });
      navigator.mediaSession.setActionHandler("previoustrack", prevTrack);
      navigator.mediaSession.setActionHandler("nexttrack", function () { nextTrack(false); });
    } catch (e) { }
  }

  window.addEventListener("pagehide", saveState);
  window.addEventListener("beforeunload", saveState);
  setInterval(saveState, 5000);

  /* ---------- Arranque ---------- */
  audio.volume = 0.8;
  updateVolumeUI();

  var autoList = document.querySelector("[data-autoplay]");
  if (autoList) {
    var autoRows = Array.prototype.slice.call(autoList.querySelectorAll("[data-track]"))
      .filter(function (r) { return r.getAttribute("data-src"); });
    if (autoRows.length) {
      queue = autoRows.map(toItem);
      playItem(0);
    }
  } else {
    restoreState();
  }
  syncToggles();
  syncPlayIcon();
})();

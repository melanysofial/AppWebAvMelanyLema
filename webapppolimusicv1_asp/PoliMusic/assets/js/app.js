/* ============================================================
   PoliMusic · Interacciones generales de la interfaz
   ============================================================ */
(function () {
  "use strict";

  document.documentElement.classList.add("js");

  /* ---------- Menú lateral (móvil) ---------- */
  var sidebar = document.getElementById("sidebar");
  var openBtn = document.querySelector("[data-sidebar-toggle]");
  var closeEls = document.querySelectorAll("[data-sidebar-close]");

  function openSidebar() {
    if (!sidebar) return;
    sidebar.classList.add("is-open");
    document.body.style.overflow = "hidden";
  }
  function closeSidebar() {
    if (!sidebar) return;
    sidebar.classList.remove("is-open");
    document.body.style.overflow = "";
  }
  if (openBtn) openBtn.addEventListener("click", openSidebar);
  closeEls.forEach(function (el) { el.addEventListener("click", closeSidebar); });
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") closeSidebar();
  });

  /* ---------- Menú de usuario ---------- */
  var menus = document.querySelectorAll("[data-menu]");
  menus.forEach(function (menu) {
    var toggle = menu.querySelector("[data-menu-toggle]");
    if (!toggle) return;
    toggle.addEventListener("click", function (e) {
      e.stopPropagation();
      var willOpen = !menu.classList.contains("is-open");
      menus.forEach(function (m) { m.classList.remove("is-open"); });
      menu.classList.toggle("is-open", willOpen);
      toggle.setAttribute("aria-expanded", willOpen ? "true" : "false");
    });
  });
  document.addEventListener("click", function () {
    menus.forEach(function (m) { m.classList.remove("is-open"); });
  });

  /* ---------- Imágenes con respaldo ---------- */
  window.poliImgFallback = function (img, kind) {
    if (!img || img.dataset.fallbackApplied) return;
    img.dataset.fallbackApplied = "1";
    var map = {
      album: "assets/img/cover-default.png",
      artist: "assets/img/artist-default.jpg",
      playlist: "assets/img/playlist-default.png",
      user: "assets/img/avatar-default.png"
    };
    var base = (window.POLI && window.POLI.root) || "/";
    img.src = base + (map[kind] || map.album);
  };

  /* ---------- Confirmación antes de eliminar ---------- */
  document.addEventListener("submit", function (e) {
    var form = e.target;
    if (form.matches("form[data-confirm]")) {
      var msg = form.getAttribute("data-confirm") || "¿Seguro que deseas eliminar este registro?";
      if (!window.confirm(msg)) {
        e.preventDefault();
      }
    }
  });

  /* ---------- Avisos: se ocultan solos ---------- */
  document.querySelectorAll("[data-flash]").forEach(function (el) {
    setTimeout(function () {
      el.style.transition = "opacity .4s, transform .4s";
      el.style.opacity = "0";
      el.style.transform = "translateY(-6px)";
      setTimeout(function () { el.remove(); }, 420);
    }, 6000);
  });

  /* ---------- Atajo de búsqueda: "/" ---------- */
  document.addEventListener("keydown", function (e) {
    if (e.key !== "/" || e.ctrlKey || e.metaKey || e.altKey) return;
    var tag = (document.activeElement && document.activeElement.tagName) || "";
    if (/^(INPUT|TEXTAREA|SELECT)$/.test(tag)) return;
    var input = document.querySelector(".search input[name='q']");
    if (input) {
      e.preventDefault();
      input.focus();
      input.select();
    }
  });

  /* ---------- Mostrar / ocultar contraseña ---------- */
  document.querySelectorAll("[data-pw-toggle]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var input = document.getElementById(btn.getAttribute("data-pw-toggle"));
      if (!input) return;
      var show = input.type === "password";
      input.type = show ? "text" : "password";
      btn.setAttribute("aria-label", show ? "Ocultar contraseña" : "Mostrar contraseña");
      btn.classList.toggle("is-on", show);
    });
  });

  /* ---------- Año actual en el pie ---------- */
  document.querySelectorAll("[data-year]").forEach(function (el) {
    el.textContent = String(new Date().getFullYear());
  });
})();

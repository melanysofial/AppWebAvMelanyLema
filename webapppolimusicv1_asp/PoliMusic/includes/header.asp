<%
If Len(pageTitle & "") = 0 Then pageTitle = "Inicio"
If Len(activeNav & "") = 0 Then activeNav = ""
Dim hdrPhoto, hdrName, hdrRole
hdrPhoto = ImgSrc(Session("UserPhoto"), "user")
hdrName = CStr(Session("Username") & "")
hdrRole = CStr(Session("RoleName") & "")
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title><%=H(pageTitle)%> · <%=APP_NAME%></title>
<meta name="description" content="PoliMusic: tu música, en azul.">
<meta name="theme-color" content="#070b14">
<link rel="icon" type="image/svg+xml" href="<%=Url("assets/img/favicon.svg")%>">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=Url("assets/css/app.css?v=" & ASSET_VER)%>">
</head>
<body data-page="<%=A(activeNav)%>">

<svg class="svg-sprite" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
  <symbol id="i-home" viewBox="0 0 24 24"><path d="M3 10.7 12 3.2l9 7.5"/><path d="M5.2 9.4V21h13.6V9.4"/><path d="M9.6 21v-5.8h4.8V21"/></symbol>
  <symbol id="i-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.2-3.2"/></symbol>
  <symbol id="i-album" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="2.4"/><path d="M12 3v3.4M12 17.6V21M3 12h3.4M17.6 12H21"/></symbol>
  <symbol id="i-artist" viewBox="0 0 24 24"><rect x="9" y="2.8" width="6" height="11" rx="3"/><path d="M5.5 11.5a6.5 6.5 0 0 0 13 0"/><path d="M12 18v3.2M8.8 21.2h6.4"/></symbol>
  <symbol id="i-playlist" viewBox="0 0 24 24"><path d="M4 6.5h11M4 11.5h11M4 16.5h7"/><path d="M18.5 10.2v8.2"/><circle cx="16.6" cy="18.9" r="2.1"/><path d="M18.5 10.2c1.7.2 2.9 1.1 3.2 2.6"/></symbol>
  <symbol id="i-admin" viewBox="0 0 24 24"><path d="M12 3 5 6v5.5c0 4.3 2.9 7.9 7 9.5 4.1-1.6 7-5.2 7-9.5V6l-7-3Z"/><path d="m9 12 2.2 2.2L15.4 10"/></symbol>
  <symbol id="i-users" viewBox="0 0 24 24"><circle cx="9" cy="8.2" r="3.4"/><path d="M2.8 20c.5-3.6 3-5.6 6.2-5.6s5.7 2 6.2 5.6"/><path d="M16.2 5.2a3.2 3.2 0 0 1 0 6.1"/><path d="M18 14.7c2.1.6 3.4 2.3 3.7 5.3"/></symbol>
  <symbol id="i-music" viewBox="0 0 24 24"><path d="M9 18.2V6.3l10-2v11.6"/><circle cx="6.4" cy="18.6" r="2.7"/><circle cx="16.4" cy="16.2" r="2.7"/></symbol>
  <symbol id="i-logout" viewBox="0 0 24 24"><path d="M14 4h4.2A1.8 1.8 0 0 1 20 5.8v12.4a1.8 1.8 0 0 1-1.8 1.8H14"/><path d="M10 8 6 12l4 4"/><path d="M6 12h9"/></symbol>
  <symbol id="i-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="3.6"/><path d="M4.6 20.4c.6-4 3.5-6.2 7.4-6.2s6.8 2.2 7.4 6.2"/></symbol>
  <symbol id="i-menu" viewBox="0 0 24 24"><path d="M3.5 6.5h17M3.5 12h17M3.5 17.5h17"/></symbol>
  <symbol id="i-close" viewBox="0 0 24 24"><path d="m6 6 12 12M18 6 6 18"/></symbol>
  <symbol id="i-chevron" viewBox="0 0 24 24"><path d="m7 10 5 5 5-5"/></symbol>
  <symbol id="i-play" viewBox="0 0 24 24"><path d="M8.2 5.6v12.8c0 .8.9 1.3 1.6.9l9.7-6.4c.6-.4.6-1.3 0-1.7L9.8 4.7c-.7-.4-1.6.1-1.6.9Z"/></symbol>
  <symbol id="i-pause" viewBox="0 0 24 24"><rect x="7" y="5" width="3.6" height="14" rx="1.2"/><rect x="13.4" y="5" width="3.6" height="14" rx="1.2"/></symbol>
  <symbol id="i-prev" viewBox="0 0 24 24"><path d="M18.4 6.1v11.8c0 .7-.8 1.1-1.4.8l-8.3-5.9a.95.95 0 0 1 0-1.6L17 5.3c.6-.3 1.4.1 1.4.8Z"/><rect x="4.4" y="5.4" width="2.4" height="13.2" rx="1"/></symbol>
  <symbol id="i-next" viewBox="0 0 24 24"><path d="M5.6 6.1v11.8c0 .7.8 1.1 1.4.8l8.3-5.9a.95.95 0 0 0 0-1.6L7 5.3c-.6-.3-1.4.1-1.4.8Z"/><rect x="17.2" y="5.4" width="2.4" height="13.2" rx="1"/></symbol>
  <symbol id="i-shuffle" viewBox="0 0 24 24"><path d="M3.5 6.5h2.9c1.2 0 2.3.6 3 1.6l4.7 7.4c.7 1 1.8 1.6 3 1.6h3.4"/><path d="m17.6 14.4 3 2.7-3 2.7"/><path d="M3.5 17.9h2.9c1.2 0 2.3-.6 3-1.6l1.2-1.9"/><path d="m14.2 9.7 1-1.6c.7-1 1.8-1.6 3-1.6h3.4"/><path d="m17.6 3.8 3 2.7-3 2.7"/></symbol>
  <symbol id="i-repeat" viewBox="0 0 24 24"><path d="M17.5 3.8 21 7.2l-3.5 3.4"/><path d="M3.4 11.6V9.9a2.7 2.7 0 0 1 2.7-2.7H21"/><path d="M6.5 20.2 3 16.8l3.5-3.4"/><path d="M20.6 12.4v1.7a2.7 2.7 0 0 1-2.7 2.7H3"/></symbol>
  <symbol id="i-volume" viewBox="0 0 24 24"><path d="M4 9.4h3.2L12 5.2v13.6L7.2 14.6H4Z"/><path d="M15.6 9.2a4 4 0 0 1 0 5.6"/><path d="M18.2 6.6a7.6 7.6 0 0 1 0 10.8"/></symbol>
  <symbol id="i-mute" viewBox="0 0 24 24"><path d="M4 9.4h3.2L12 5.2v13.6L7.2 14.6H4Z"/><path d="m16 9.5 4.4 5M20.4 9.5l-4.4 5"/></symbol>
  <symbol id="i-check" viewBox="0 0 24 24"><path d="m4.8 12.4 4.8 4.8L19.4 7"/></symbol>
  <symbol id="i-alert" viewBox="0 0 24 24"><path d="M12 3.6 21.2 20H2.8L12 3.6Z"/><path d="M12 9.4v4.8M12 17.2h.01"/></symbol>
  <symbol id="i-plus" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></symbol>
  <symbol id="i-edit" viewBox="0 0 24 24"><path d="M4 20h4.2L19 9.2a2.1 2.1 0 0 0 0-3l-1.2-1.2a2.1 2.1 0 0 0-3 0L4 15.8V20Z"/><path d="m13.6 6.8 3.6 3.6"/></symbol>
  <symbol id="i-trash" viewBox="0 0 24 24"><path d="M4.4 7h15.2M9.4 7V4.8h5.2V7M6.6 7l.9 12.4a1.8 1.8 0 0 0 1.8 1.6h5.4a1.8 1.8 0 0 0 1.8-1.6L17.4 7"/><path d="M10.2 11v6M13.8 11v6"/></symbol>
  <symbol id="i-arrow-left" viewBox="0 0 24 24"><path d="M20 12H4"/><path d="m10 6-6 6 6 6"/></symbol>
  <symbol id="i-clock" viewBox="0 0 24 24"><circle cx="12" cy="12" r="8.6"/><path d="M12 7.4V12l3.2 2"/></symbol>
  <symbol id="i-headphones" viewBox="0 0 24 24"><path d="M4 14v-2a8 8 0 0 1 16 0v2"/><rect x="3" y="13.6" width="4" height="7" rx="2"/><rect x="17" y="13.6" width="4" height="7" rx="2"/></symbol>
  <symbol id="i-spark" viewBox="0 0 24 24"><path d="m12 3 1.9 5.3L19 10.2l-5.1 1.9L12 17.4l-1.9-5.3L5 10.2l5.1-1.9L12 3Z"/><path d="M18.4 15.6l.8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8.8-2.2Z"/></symbol>
  <symbol id="i-grid" viewBox="0 0 24 24"><rect x="3.4" y="3.4" width="7.2" height="7.2" rx="1.8"/><rect x="13.4" y="3.4" width="7.2" height="7.2" rx="1.8"/><rect x="3.4" y="13.4" width="7.2" height="7.2" rx="1.8"/><rect x="13.4" y="13.4" width="7.2" height="7.2" rx="1.8"/></symbol>
  <symbol id="i-eye" viewBox="0 0 24 24"><path d="M2.4 12S6 5.8 12 5.8 21.6 12 21.6 12 18 18.2 12 18.2 2.4 12 2.4 12Z"/><circle cx="12" cy="12" r="2.8"/></symbol>
</svg>

<div class="app-shell">
  <aside class="sidebar" id="sidebar" aria-label="Menú principal">
    <div class="brand">
      <a class="brand-link" href="<%=Url("index.asp")%>">
        <span class="brand-mark"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-music"></use></svg></span>
        <span class="brand-name">Poli<span>Music</span></span>
      </a>
      <button class="icon-btn sidebar-close" type="button" data-sidebar-close aria-label="Cerrar menú">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-close"></use></svg>
      </button>
    </div>

    <nav class="nav">
      <p class="nav-label">Explorar</p>
      <a class="nav-item<%=IIfStr(activeNav = "home", " is-active", "")%>" href="<%=Url("index.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-home"></use></svg><span>Inicio</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "search", " is-active", "")%>" href="<%=Url("search.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg><span>Buscar</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "albums", " is-active", "")%>" href="<%=Url("albums.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg><span>Álbumes</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "artists", " is-active", "")%>" href="<%=Url("artists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg><span>Artistas</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "playlists", " is-active", "")%>" href="<%=Url("playlists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg><span>Playlists</span>
      </a>

      <% If IsAdmin() Then %>
      <p class="nav-label">Gestión</p>
      <a class="nav-item<%=IIfStr(activeNav = "admin-panel", " is-active", "")%>" href="<%=Url("admin_index.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-grid"></use></svg><span>Panel</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "admin-users", " is-active", "")%>" href="<%=Url("admin_users.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg><span>Usuarios</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "admin-songs", " is-active", "")%>" href="<%=Url("admin_songs.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg><span>Canciones</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "admin-artists", " is-active", "")%>" href="<%=Url("admin_artists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg><span>Artistas</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "admin-albums", " is-active", "")%>" href="<%=Url("admin_albums.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg><span>Álbumes</span>
      </a>
      <a class="nav-item<%=IIfStr(activeNav = "admin-playlists", " is-active", "")%>" href="<%=Url("admin_playlists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg><span>Playlists</span>
      </a>
      <% End If %>
    </nav>

    <div class="sidebar-foot">
      <a class="sidebar-user" href="<%=Url("profile.asp")%>">
        <img class="avatar avatar-sm" src="<%=A(hdrPhoto)%>" alt="" onerror="poliImgFallback(this,'user')">
        <span class="sidebar-user-txt">
          <strong><%=H(hdrName)%></strong>
          <small><%=H(hdrRole)%></small>
        </span>
      </a>
      <a class="icon-btn" href="<%=Url("logout.asp")%>" title="Cerrar sesión" aria-label="Cerrar sesión">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-logout"></use></svg>
      </a>
    </div>
  </aside>

  <div class="sidebar-scrim" data-sidebar-close></div>

  <div class="main">
    <header class="topbar">
      <button class="icon-btn menu-btn" type="button" data-sidebar-toggle aria-label="Abrir menú">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-menu"></use></svg>
      </button>

      <form class="search" action="<%=Url("search.asp")%>" method="get" role="search">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(Request.QueryString("q"))%>" placeholder="Buscar canciones, artistas o álbumes" autocomplete="off" aria-label="Buscar">
        <span class="search-hint">Enter</span>
      </form>

      <div class="topbar-actions">
        <% If IsAdmin() Then %>
        <a class="pill pill-admin" href="<%=Url("admin_index.asp")%>">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-admin"></use></svg><span>Admin</span>
        </a>
        <% End If %>

        <div class="user-menu" data-menu>
          <button class="user-chip" type="button" data-menu-toggle aria-haspopup="true" aria-expanded="false">
            <img class="avatar avatar-xs" src="<%=A(hdrPhoto)%>" alt="" onerror="poliImgFallback(this,'user')">
            <span class="user-chip-txt">
              <strong><%=H(hdrName)%></strong>
              <small><%=H(hdrRole)%></small>
            </span>
            <svg class="icon chev" viewBox="0 0 24 24"><use href="#i-chevron"></use></svg>
          </button>
          <div class="menu-panel" role="menu">
            <div class="menu-head">
              <strong><%=H(hdrName)%></strong>
              <small><%=H(Session("Email"))%></small>
            </div>
            <a href="<%=Url("profile.asp")%>" role="menuitem">
              <svg class="icon" viewBox="0 0 24 24"><use href="#i-user"></use></svg>Mi perfil
            </a>
            <% If IsAdmin() Then %>
            <a href="<%=Url("admin_index.asp")%>" role="menuitem">
              <svg class="icon" viewBox="0 0 24 24"><use href="#i-grid"></use></svg>Panel de administración
            </a>
            <% End If %>
            <a class="danger" href="<%=Url("logout.asp")%>" role="menuitem">
              <svg class="icon" viewBox="0 0 24 24"><use href="#i-logout"></use></svg>Cerrar sesión
            </a>
          </div>
        </div>
      </div>
    </header>

    <main class="content" id="content">

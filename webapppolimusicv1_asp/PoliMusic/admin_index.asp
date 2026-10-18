<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim totalUsers, totalSongs, totalArtists, totalAlbums, totalPlaylists
Dim rsUsers, rsTop

totalUsers = DbCount("SELECT COUNT(*) FROM TBL_USER", Array())
totalSongs = DbCount("SELECT COUNT(*) FROM TBL_SONG", Array())
totalArtists = DbCount("SELECT COUNT(*) FROM TBL_ARTIST", Array())
totalAlbums = DbCount("SELECT COUNT(*) FROM TBL_ALBUM", Array())
totalPlaylists = DbCount("SELECT COUNT(*) FROM TBL_PLAYLIST", Array())

Set rsUsers = DbQuery("SELECT TOP 6 ID_USER, USERNAME, EMAIL, USER_TYPE, USER_PHOTO FROM TBL_USER ORDER BY ID_USER DESC", Array())

Set rsTop = DbQuery("SELECT TOP 5 s.ID_SONG, s.SONG_NAME, s.PLAYS, " & _
    "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Sin artista') AS ARTISTS " & _
    "FROM TBL_SONG s ORDER BY ISNULL(s.PLAYS, 0) DESC, s.ID_SONG", Array())

pageTitle = "Panel de administración"
activeNav = "admin-panel"
adminActive = "panel"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-admin"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Hola, <%=H(Session("Username"))%></h1>
    <p class="page-sub">Gestiona usuarios, canciones, artistas, álbumes y playlists desde un solo lugar.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-ghost" href="<%=Url("index.asp")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-headphones"></use></svg>Ver sitio
    </a>
    <a class="btn btn-primary" href="<%=Url("admin_songs.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nueva canción
    </a>
  </div>
</div>

<%=FlashHtml()%>
<!--#include file="admin_tabs.asp"-->

<div class="stat-grid">
  <div class="stat-card">
    <span class="stat-ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg></span>
    <span class="stat-value"><%=totalUsers%></span>
    <span class="stat-label">Usuarios registrados</span>
  </div>
  <div class="stat-card">
    <span class="stat-ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg></span>
    <span class="stat-value"><%=totalSongs%></span>
    <span class="stat-label">Canciones</span>
  </div>
  <div class="stat-card">
    <span class="stat-ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg></span>
    <span class="stat-value"><%=totalArtists%></span>
    <span class="stat-label">Artistas</span>
  </div>
  <div class="stat-card">
    <span class="stat-ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg></span>
    <span class="stat-value"><%=totalAlbums%></span>
    <span class="stat-label">Álbumes</span>
  </div>
  <div class="stat-card">
    <span class="stat-ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg></span>
    <span class="stat-value"><%=totalPlaylists%></span>
    <span class="stat-label">Playlists</span>
  </div>
</div>

<div class="admin-columns">
  <section class="panel">
    <div class="panel-head">
      <h2 class="panel-title"><svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg>Usuarios recientes</h2>
      <a class="section-link" href="<%=Url("admin_users.asp")%>">Ver todos</a>
    </div>
    <div class="panel-body tight">
      <div class="table-wrap">
        <table class="data-table" style="min-width:520px">
          <thead>
            <tr><th>Usuario</th><th>Correo</th><th>Rol</th><th></th></tr>
          </thead>
          <tbody>
            <% Do While Not rsUsers.EOF %>
            <tr>
              <td>
                <div class="cell-main">
                  <img src="<%=A(ImgSrc(rsUsers("USER_PHOTO"), "user"))%>" alt="" onerror="poliImgFallback(this,'user')">
                  <div>
                    <strong><%=H(rsUsers("USERNAME"))%></strong>
                    <small>#<%=rsUsers("ID_USER")%></small>
                  </div>
                </div>
              </td>
              <td><%=H(rsUsers("EMAIL"))%></td>
              <td>
                <% If CStr(rsUsers("USER_TYPE")) = "1" Then %>
                <span class="badge badge-blue">Admin</span>
                <% Else %>
                <span class="badge">Usuario</span>
                <% End If %>
              </td>
              <td class="cell-actions">
                <a class="icon-btn sm" href="<%=Url("admin_users.asp?action=edit&id=" & rsUsers("ID_USER"))%>" title="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
              </td>
            </tr>
            <% rsUsers.MoveNext : Loop %>
          </tbody>
        </table>
      </div>
    </div>
  </section>

  <div>
    <section class="panel" style="margin-bottom:22px">
      <div class="panel-head">
        <h2 class="panel-title"><svg class="icon" viewBox="0 0 24 24"><use href="#i-headphones"></use></svg>Más escuchadas</h2>
      </div>
      <div class="panel-body tight">
        <div class="table-wrap">
          <table class="data-table" style="min-width:0">
            <tbody>
              <% Do While Not rsTop.EOF %>
              <tr>
                <td>
                  <div class="cell-main">
                    <div>
                      <strong><%=H(rsTop("SONG_NAME"))%></strong>
                      <small><%=H(rsTop("ARTISTS"))%></small>
                    </div>
                  </div>
                </td>
                <td class="num"><%=Num(rsTop("PLAYS"))%></td>
              </tr>
              <% rsTop.MoveNext : Loop %>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section class="panel">
      <div class="panel-head">
        <h2 class="panel-title"><svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Acciones rápidas</h2>
      </div>
      <div class="panel-body">
        <div class="quick-grid">
          <a class="quick-item" href="<%=Url("admin_users.asp?action=new")%>">
            <svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg>Nuevo usuario
          </a>
          <a class="quick-item" href="<%=Url("admin_artists.asp?action=new")%>">
            <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>Nuevo artista
          </a>
          <a class="quick-item" href="<%=Url("admin_albums.asp?action=new")%>">
            <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>Nuevo álbum
          </a>
          <a class="quick-item" href="<%=Url("admin_playlists.asp?action=new")%>">
            <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>Nueva playlist
          </a>
        </div>
      </div>
    </section>
  </div>
</div>

<%
rsUsers.Close : Set rsUsers = Nothing
rsTop.Close : Set rsTop = Nothing
%>
<!--#include file="includes/footer.asp"-->

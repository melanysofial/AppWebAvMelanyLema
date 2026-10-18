<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, rs, q, sql, p1, p2, p3
q = Trim(Request.QueryString("q") & "")

sql = "SELECT p.ID_PLAYLIST, p.TITLE, p.TYPE, p.PHOTO, p.CREATION_DATE, u.USERNAME, " & _
      "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
      "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER "

If IsAdmin() Then
    If q <> "" Then
        sql = sql & "WHERE p.TITLE LIKE ? ESCAPE '\' ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC"
        Set rs = DbQuery(sql, Array(LikeParam(q)))
    Else
        sql = sql & "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC"
        Set rs = DbQuery(sql, Array())
    End If
Else
    If q <> "" Then
        sql = sql & "WHERE (p.ID_USER = ? OR p.TYPE = 0) AND p.TITLE LIKE ? ESCAPE '\' " & _
                    "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC"
        Set rs = DbQuery(sql, Array(CurrentUserId(), LikeParam(q)))
    Else
        sql = sql & "WHERE (p.ID_USER = ? OR p.TYPE = 0) ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC"
        Set rs = DbQuery(sql, Array(CurrentUserId()))
    End If
End If

pageTitle = "Playlists"
activeNav = "playlists"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>
      Colecciones
    </span>
    <h1 class="page-title">Playlists</h1>
    <p class="page-sub">
      <% If IsAdmin() Then %>
      Todas las playlists del sistema. Puedes administrarlas desde el panel.
      <% Else %>
      Tus playlists y las playlists públicas de la comunidad PoliMusic.
      <% End If %>
    </p>
  </div>
  <form class="page-actions" method="get" action="<%=Url("playlists.asp")%>">
    <div class="search" style="width:260px">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
      <input type="search" name="q" value="<%=A(q)%>" placeholder="Filtrar playlists" aria-label="Filtrar playlists">
    </div>
  </form>
</div>

<%=FlashHtml()%>

<% If rs.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>
  <strong>No hay playlists para mostrar</strong>
  <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Todavía no se han creado playlists.<% End If %></p>
</div>
<% Else %>
<div class="grid-cards wide">
  <% Do While Not rs.EOF %>
  <a class="card" href="<%=Url("playlist.asp?id=" & rs("ID_PLAYLIST"))%>">
    <span class="card-cover">
      <img src="<%=A(ImgSrc(rs("PHOTO"), "playlist"))%>" alt="Portada de <%=A(rs("TITLE"))%>" loading="lazy" onerror="poliImgFallback(this,'playlist')">
      <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
    </span>
    <span class="card-title"><%=H(rs("TITLE"))%></span>
    <span class="card-sub">
      <%=rs("SONGS")%> canciones · <%=PlaylistTypeLabel(rs("TYPE"))%> · <%=H(rs("USERNAME"))%>
    </span>
  </a>
  <% rs.MoveNext : Loop %>
</div>
<% End If %>

<% rs.Close : Set rs = Nothing %>
<!--#include file="includes/footer.asp"-->

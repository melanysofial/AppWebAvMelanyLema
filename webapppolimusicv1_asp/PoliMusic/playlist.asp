<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/trackrow.asp"-->
<%
RequireLogin

Dim playlistId, rsPlaylist, rsTracks, pageTitle, activeNav, nTrack, autoplay
playlistId = IntParam(Request.QueryString("id"), 0)
If playlistId <= 0 Then Response.Redirect Url("playlists.asp?e=notfound")

Set rsPlaylist = DbQuery("SELECT p.ID_PLAYLIST, p.ID_USER, p.TITLE, p.CREATION_DATE, p.TYPE, p.PHOTO, u.USERNAME, " & _
    "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS, " & _
    "(SELECT ISNULL(SUM(s.PLAYS), 0) FROM TBL_PLAYLIST_SONG ps JOIN TBL_SONG s ON s.ID_SONG = ps.ID_SONG " & _
    " WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS TOTAL_PLAYS " & _
    "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
    "WHERE p.ID_PLAYLIST = ?", Array(playlistId))

If rsPlaylist.EOF Then
    rsPlaylist.Close
    Response.Redirect Url("playlists.asp?e=notfound")
End If

' Una playlist privada solo la ve su dueño o un administrador
If CStr(rsPlaylist("TYPE")) = "1" And CLng(rsPlaylist("ID_USER")) <> CurrentUserId() And Not IsAdmin() Then
    rsPlaylist.Close
    Response.Redirect Url("playlists.asp?e=denied")
End If

Set rsTracks = DbQuery("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
    "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH, " & _
    "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "FROM TBL_PLAYER p2 JOIN TBL_ARTIST a ON a.ID_ARTIST = p2.ID_ARTIST " & _
    "WHERE p2.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
    "FROM TBL_PLAYLIST_SONG ps JOIN TBL_SONG s ON s.ID_SONG = ps.ID_SONG " & _
    "OUTER APPLY (SELECT TOP 1 al2.ID_ALBUM, al2.TITLE_ALBUM, al2.ALBUM_IMAGE_PATH " & _
    "  FROM TBL_TRACKLIST t JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t.ID_ALBUM " & _
    "  WHERE t.ID_SONG = s.ID_SONG ORDER BY al2.ID_ALBUM) alb " & _
    "WHERE ps.ID_PLAYLIST = ? ORDER BY s.ID_SONG", Array(playlistId))

autoplay = (LCase(Request.QueryString("play") & "") = "1")
pageTitle = CStr(rsPlaylist("TITLE") & "")
activeNav = "playlists"
%>
<!--#include file="includes/header.asp"-->

<div class="detail-head">
  <div class="detail-cover">
    <img src="<%=A(ImgSrc(rsPlaylist("PHOTO"), "playlist"))%>" alt="Portada de <%=A(rsPlaylist("TITLE"))%>" onerror="poliImgFallback(this,'playlist')">
  </div>
  <div class="detail-info">
    <span class="detail-type">
      Playlist
      <% If CStr(rsPlaylist("TYPE")) = "1" Then %>
      <span class="badge badge-private" style="margin-left:8px">Privada</span>
      <% Else %>
      <span class="badge badge-ok" style="margin-left:8px">Pública</span>
      <% End If %>
    </span>
    <h1 class="detail-title"><%=H(rsPlaylist("TITLE"))%></h1>
    <div class="detail-meta">
      <strong><%=H(rsPlaylist("USERNAME"))%></strong>
      <span class="dot"></span>
      <span><%=FmtDate(rsPlaylist("CREATION_DATE"))%></span>
      <span class="dot"></span>
      <span><%=rsPlaylist("SONGS")%> canciones</span>
      <span class="dot"></span>
      <span><%=Num(rsPlaylist("TOTAL_PLAYS"))%> reproducciones</span>
    </div>
    <div class="detail-actions">
      <% If rsPlaylist("SONGS") > 0 Then %>
      <button class="btn btn-primary" type="button" data-play-all="#playlistTracks">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>Reproducir
      </button>
      <% End If %>
      <a class="btn btn-ghost" href="<%=Url("playlists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-arrow-left"></use></svg>Volver
      </a>
      <% If IsAdmin() Then %>
      <a class="btn btn-ghost" href="<%=Url("admin_playlists.asp?action=edit&id=" & playlistId)%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>Editar
      </a>
      <% End If %>
    </div>
  </div>
</div>

<%=FlashHtml()%>

<% If rsTracks.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
  <strong>Esta playlist está vacía</strong>
  <p>Un administrador puede agregar canciones a la playlist desde el panel de administración.</p>
</div>
<% Else %>
<div class="tracklist" data-tracklist id="playlistTracks"<% If autoplay Then Response.Write " data-autoplay=""1""" %>>
  <div class="track-head">
    <span>#</span><span>Título</span><span>Álbum</span>
    <span style="text-align:right">Reproducciones</span><span></span>
  </div>
  <%
  nTrack = 0
  Do While Not rsTracks.EOF
      nTrack = nTrack + 1
      Response.Write TrackRowHtml(nTrack, rsTracks("ID_SONG"), rsTracks("SONG_NAME"), rsTracks("ARTISTS"), _
          MediaSrc(rsTracks("SONG_PATH")), ImgSrc(rsTracks("ALBUM_IMAGE_PATH"), "album"), _
          rsTracks("TITLE_ALBUM"), rsTracks("ID_ALBUM"), rsTracks("PLAYS"), True)
      rsTracks.MoveNext
  Loop
  %>
</div>
<% End If %>

<%
rsTracks.Close : Set rsTracks = Nothing
rsPlaylist.Close : Set rsPlaylist = Nothing
%>
<!--#include file="includes/footer.asp"-->

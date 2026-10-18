<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/trackrow.asp"-->
<%
RequireLogin

Dim albumId, rsAlbum, rsTracks, rsArt, pageTitle, activeNav, autoplay
Dim albumArtists, nTrack
albumId = IntParam(Request.QueryString("id"), 0)
If albumId <= 0 Then Response.Redirect Url("albums.asp?e=notfound")

Set rsAlbum = DbQuery("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
    "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS, " & _
    "(SELECT ISNULL(SUM(s.PLAYS), 0) FROM TBL_TRACKLIST t JOIN TBL_SONG s ON s.ID_SONG = t.ID_SONG " & _
    " WHERE t.ID_ALBUM = al.ID_ALBUM) AS TOTAL_PLAYS " & _
    "FROM TBL_ALBUM al WHERE al.ID_ALBUM = ?", Array(albumId))

If rsAlbum.EOF Then
    rsAlbum.Close
    Response.Redirect Url("albums.asp?e=notfound")
End If

albumArtists = ""
Set rsArt = DbQuery("SELECT DISTINCT a.ARTIST_NAME, a.ARTIST_LASTNAME FROM TBL_TRACKLIST t " & _
    "JOIN TBL_PLAYER p ON p.ID_SONG = t.ID_SONG " & _
    "JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "WHERE t.ID_ALBUM = ? ORDER BY a.ARTIST_NAME", Array(albumId))
Do While Not rsArt.EOF
    If albumArtists <> "" Then albumArtists = albumArtists & ", "
    albumArtists = albumArtists & rsArt("ARTIST_NAME") & ""
    If Not IsNull(rsArt("ARTIST_LASTNAME")) Then
        If Trim(rsArt("ARTIST_LASTNAME") & "") <> "" Then albumArtists = albumArtists & " " & rsArt("ARTIST_LASTNAME")
    End If
    rsArt.MoveNext
Loop
rsArt.Close : Set rsArt = Nothing

Set rsTracks = DbQuery("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
    "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
    "FROM TBL_TRACKLIST t JOIN TBL_SONG s ON s.ID_SONG = t.ID_SONG " & _
    "WHERE t.ID_ALBUM = ? ORDER BY s.ID_SONG", Array(albumId))

autoplay = (LCase(Request.QueryString("play") & "") = "1")
pageTitle = CStr(rsAlbum("TITLE_ALBUM") & "")
activeNav = "albums"
%>
<!--#include file="includes/header.asp"-->

<div class="detail-head">
  <div class="detail-cover">
    <img src="<%=A(ImgSrc(rsAlbum("ALBUM_IMAGE_PATH"), "album"))%>" alt="Portada de <%=A(rsAlbum("TITLE_ALBUM"))%>" onerror="poliImgFallback(this,'album')">
  </div>
  <div class="detail-info">
    <span class="detail-type">Álbum</span>
    <h1 class="detail-title"><%=H(rsAlbum("TITLE_ALBUM"))%></h1>
    <div class="detail-meta">
      <% If albumArtists <> "" Then %>
      <strong><%=H(albumArtists)%></strong>
      <span class="dot"></span>
      <% End If %>
      <span><%=H(rsAlbum("RELEASE_YEAR"))%></span>
      <span class="dot"></span>
      <span><%=rsAlbum("TRACKS")%> canciones</span>
      <span class="dot"></span>
      <span><%=Num(rsAlbum("TOTAL_PLAYS"))%> reproducciones</span>
    </div>
    <div class="detail-actions">
      <% If rsAlbum("TRACKS") > 0 Then %>
      <button class="btn btn-primary" type="button" data-play-all="#albumTracks">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>Reproducir
      </button>
      <% End If %>
      <a class="btn btn-ghost" href="<%=Url("albums.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-arrow-left"></use></svg>Volver
      </a>
    </div>
  </div>
</div>

<%=FlashHtml()%>

<% If rsTracks.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
  <strong>Este álbum no tiene canciones</strong>
  <p>Un administrador puede asociar canciones al álbum desde el panel de administración.</p>
</div>
<% Else %>
<div class="tracklist" data-tracklist id="albumTracks"<% If autoplay Then Response.Write " data-autoplay=""1""" %>>
  <div class="track-head no-album">
    <span>#</span><span>Título</span>
    <span style="text-align:right">Reproducciones</span><span></span>
  </div>
  <%
  nTrack = 0
  Do While Not rsTracks.EOF
      nTrack = nTrack + 1
      Response.Write TrackRowHtml(nTrack, rsTracks("ID_SONG"), rsTracks("SONG_NAME"), rsTracks("ARTISTS"), _
          MediaSrc(rsTracks("SONG_PATH")), ImgSrc(rsAlbum("ALBUM_IMAGE_PATH"), "album"), _
          rsAlbum("TITLE_ALBUM"), rsAlbum("ID_ALBUM"), rsTracks("PLAYS"), False)
      rsTracks.MoveNext
  Loop
  %>
</div>
<% End If %>

<%
rsTracks.Close : Set rsTracks = Nothing
rsAlbum.Close : Set rsAlbum = Nothing
%>
<!--#include file="includes/footer.asp"-->

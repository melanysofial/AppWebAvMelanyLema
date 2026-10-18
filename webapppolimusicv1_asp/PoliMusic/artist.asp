<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/trackrow.asp"-->
<%
RequireLogin

Dim artistId, rsArtist, rsTracks, pageTitle, activeNav, fullName, nTrack, autoplay
artistId = IntParam(Request.QueryString("id"), 0)
If artistId <= 0 Then Response.Redirect Url("artists.asp?e=notfound")

Set rsArtist = DbQuery("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
    "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS, " & _
    "(SELECT ISNULL(SUM(s.PLAYS), 0) FROM TBL_PLAYER p JOIN TBL_SONG s ON s.ID_SONG = p.ID_SONG " & _
    " WHERE p.ID_ARTIST = a.ID_ARTIST) AS TOTAL_PLAYS " & _
    "FROM TBL_ARTIST a WHERE a.ID_ARTIST = ?", Array(artistId))

If rsArtist.EOF Then
    rsArtist.Close
    Response.Redirect Url("artists.asp?e=notfound")
End If

fullName = CStr(rsArtist("ARTIST_NAME") & "")
If Not IsNull(rsArtist("ARTIST_LASTNAME")) Then
    If Trim(rsArtist("ARTIST_LASTNAME") & "") <> "" Then fullName = fullName & " " & rsArtist("ARTIST_LASTNAME")
End If

Set rsTracks = DbQuery("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
    "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH, " & _
    "ISNULL((SELECT STUFF((SELECT ', ' + a2.ARTIST_NAME + ISNULL(' ' + a2.ARTIST_LASTNAME, '') " & _
    "FROM TBL_PLAYER p2 JOIN TBL_ARTIST a2 ON a2.ID_ARTIST = p2.ID_ARTIST " & _
    "WHERE p2.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
    "FROM TBL_PLAYER p JOIN TBL_SONG s ON s.ID_SONG = p.ID_SONG " & _
    "OUTER APPLY (SELECT TOP 1 al2.ID_ALBUM, al2.TITLE_ALBUM, al2.ALBUM_IMAGE_PATH " & _
    "  FROM TBL_TRACKLIST t JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t.ID_ALBUM " & _
    "  WHERE t.ID_SONG = s.ID_SONG ORDER BY al2.ID_ALBUM) alb " & _
    "WHERE p.ID_ARTIST = ? ORDER BY ISNULL(s.PLAYS, 0) DESC, s.ID_SONG", Array(artistId))

autoplay = (LCase(Request.QueryString("play") & "") = "1")
pageTitle = fullName
activeNav = "artists"
%>
<!--#include file="includes/header.asp"-->

<div class="detail-head">
  <div class="detail-cover round">
    <img src="<%=A(ImgSrc(rsArtist("ARTIST_IMAGE"), "artist"))%>" alt="<%=A(fullName)%>" onerror="poliImgFallback(this,'artist')">
  </div>
  <div class="detail-info">
    <span class="detail-type">Artista</span>
    <h1 class="detail-title"><%=H(fullName)%></h1>
    <div class="detail-meta">
      <span><%=rsArtist("SONGS")%> canciones</span>
      <span class="dot"></span>
      <span><%=Num(rsArtist("TOTAL_PLAYS"))%> reproducciones</span>
    </div>
    <div class="detail-actions">
      <% If rsArtist("SONGS") > 0 Then %>
      <button class="btn btn-primary" type="button" data-play-all="#artistTracks">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>Reproducir
      </button>
      <% End If %>
      <a class="btn btn-ghost" href="<%=Url("artists.asp")%>">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-arrow-left"></use></svg>Volver
      </a>
    </div>
  </div>
</div>

<%=FlashHtml()%>

<% If rsTracks.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
  <strong>Este artista aún no tiene canciones</strong>
  <p>Un administrador puede asociar canciones al artista desde el panel de administración.</p>
</div>
<% Else %>
<div class="tracklist" data-tracklist id="artistTracks"<% If autoplay Then Response.Write " data-autoplay=""1""" %>>
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
rsArtist.Close : Set rsArtist = Nothing
%>
<!--#include file="includes/footer.asp"-->

<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/trackrow.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, greet, hh
hh = Hour(Now())
If hh < 12 Then
    greet = "Buenos días"
ElseIf hh < 19 Then
    greet = "Buenas tardes"
Else
    greet = "Buenas noches"
End If

Dim rsHero, hasHero, rsAlbums, rsSongs, rsPlaylists
Dim totalSongs, totalAlbums, totalArtists

totalSongs = DbCount("SELECT COUNT(*) FROM TBL_SONG", Array())
totalAlbums = DbCount("SELECT COUNT(*) FROM TBL_ALBUM", Array())
totalArtists = DbCount("SELECT COUNT(*) FROM TBL_ARTIST", Array())

Set rsHero = DbQuery("SELECT TOP 1 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
    "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
    "FROM TBL_ALBUM al " & _
    "ORDER BY (SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) DESC, al.ID_ALBUM", Array())
hasHero = Not rsHero.EOF

Set rsAlbums = DbQuery("SELECT TOP 6 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
    "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
    "FROM TBL_ALBUM al ORDER BY al.ID_ALBUM", Array())

Set rsSongs = DbQuery("SELECT TOP 6 s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
    "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH, " & _
    "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
    "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
    "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
    "FROM TBL_SONG s " & _
    "OUTER APPLY (SELECT TOP 1 al2.ID_ALBUM, al2.TITLE_ALBUM, al2.ALBUM_IMAGE_PATH " & _
    "  FROM TBL_TRACKLIST t JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t.ID_ALBUM " & _
    "  WHERE t.ID_SONG = s.ID_SONG ORDER BY al2.ID_ALBUM) alb " & _
    "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.ID_SONG", Array())

If IsAdmin() Then
    Set rsPlaylists = DbQuery("SELECT TOP 4 p.ID_PLAYLIST, p.TITLE, p.TYPE, p.PHOTO, p.CREATION_DATE, u.USERNAME, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
        "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
        "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC", Array())
Else
    Set rsPlaylists = DbQuery("SELECT TOP 4 p.ID_PLAYLIST, p.TITLE, p.TYPE, p.PHOTO, p.CREATION_DATE, u.USERNAME, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
        "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
        "WHERE p.ID_USER = ? OR p.TYPE = 0 " & _
        "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC", Array(CurrentUserId()))
End If

pageTitle = "Inicio"
activeNav = "home"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-spark"></use></svg>
      Tu música
    </span>
    <h1 class="page-title"><%=greet%>, <%=H(Session("Username"))%></h1>
    <p class="page-sub">Esto es lo que suena hoy en PoliMusic. Explora el catálogo, arma tu cola y disfruta.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-ghost" href="<%=Url("search.asp")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>Buscar
    </a>
    <% If IsAdmin() Then %>
    <a class="btn btn-primary" href="<%=Url("admin_index.asp")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-grid"></use></svg>Panel
    </a>
    <% End If %>
  </div>
</div>

<%=FlashHtml()%>

<% If hasHero Then %>
<section class="hero">
  <div class="hero-body">
    <span class="hero-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-spark"></use></svg>
      Destacado
    </span>
    <h2 class="hero-title">Dale play a <span><%=H(rsHero("TITLE_ALBUM"))%></span></h2>
    <p class="hero-text">
      Un recorrido por el catálogo de PoliMusic. Portadas, artistas y listas de canciones
      conectadas directamente a la base de datos.
    </p>
    <div class="hero-actions">
      <a class="btn btn-primary" href="<%=Url("album.asp?id=" & rsHero("ID_ALBUM") & "&play=1")%>">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>
        Reproducir álbum
      </a>
      <a class="btn btn-ghost" href="<%=Url("album.asp?id=" & rsHero("ID_ALBUM"))%>">
        Ver detalles
      </a>
    </div>
    <div class="hero-meta">
      <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg><%=rsHero("TRACKS")%> canciones</span>
      <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-clock"></use></svg><%=H(rsHero("RELEASE_YEAR"))%></span>
      <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-headphones"></use></svg><%=totalSongs%> canciones en el catálogo</span>
    </div>
  </div>
  <div class="hero-art">
    <img src="<%=A(ImgSrc(rsHero("ALBUM_IMAGE_PATH"), "album"))%>" alt="Portada de <%=A(rsHero("TITLE_ALBUM"))%>" onerror="poliImgFallback(this,'album')">
  </div>
</section>
<% End If %>

<% If Not rsPlaylists.EOF Then %>
<section class="section">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>Playlists para ti
    </h2>
    <a class="section-link" href="<%=Url("playlists.asp")%>">Ver todas</a>
  </div>
  <div class="grid-cards">
    <% Do While Not rsPlaylists.EOF %>
    <a class="card" href="<%=Url("playlist.asp?id=" & rsPlaylists("ID_PLAYLIST"))%>">
      <span class="card-cover">
        <img src="<%=A(ImgSrc(rsPlaylists("PHOTO"), "playlist"))%>" alt="Portada de <%=A(rsPlaylists("TITLE"))%>" loading="lazy" onerror="poliImgFallback(this,'playlist')">
        <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
      </span>
      <span class="card-title"><%=H(rsPlaylists("TITLE"))%></span>
      <span class="card-sub"><%=rsPlaylists("SONGS")%> canciones · <%=PlaylistTypeLabel(rsPlaylists("TYPE"))%></span>
    </a>
    <% rsPlaylists.MoveNext : Loop %>
  </div>
</section>
<% End If %>

<section class="section">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>Álbumes
    </h2>
    <a class="section-link" href="<%=Url("albums.asp")%>">Ver todos</a>
  </div>
  <div class="grid-cards">
    <% Do While Not rsAlbums.EOF %>
    <a class="card" href="<%=Url("album.asp?id=" & rsAlbums("ID_ALBUM"))%>">
      <span class="card-cover">
        <img src="<%=A(ImgSrc(rsAlbums("ALBUM_IMAGE_PATH"), "album"))%>" alt="Portada de <%=A(rsAlbums("TITLE_ALBUM"))%>" loading="lazy" onerror="poliImgFallback(this,'album')">
        <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
      </span>
      <span class="card-title"><%=H(rsAlbums("TITLE_ALBUM"))%></span>
      <span class="card-sub"><%=H(rsAlbums("RELEASE_YEAR"))%> · <%=rsAlbums("TRACKS")%> canciones</span>
    </a>
    <% rsAlbums.MoveNext : Loop %>
  </div>
</section>

<section class="section">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-headphones"></use></svg>Canciones más escuchadas
    </h2>
    <% If Not rsSongs.EOF Then %>
    <button class="btn btn-ghost btn-sm" type="button" data-play-all="#homeTracks">
      <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>Reproducir todo
    </button>
    <% End If %>
  </div>

  <% If rsSongs.EOF Then %>
  <div class="empty">
    <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
    <strong>Aún no hay canciones</strong>
    <p>El catálogo está vacío. Un administrador puede agregar canciones desde el panel.</p>
  </div>
  <% Else %>
  <div class="tracklist" data-tracklist id="homeTracks">
    <div class="track-head">
      <span>#</span><span>Título</span><span>Álbum</span>
      <span style="text-align:right">Reproducciones</span><span></span>
    </div>
    <% Dim nHome : nHome = 0
       Do While Not rsSongs.EOF
         nHome = nHome + 1
         Response.Write TrackRowHtml(nHome, rsSongs("ID_SONG"), rsSongs("SONG_NAME"), rsSongs("ARTISTS"), _
            MediaSrc(rsSongs("SONG_PATH")), ImgSrc(rsSongs("ALBUM_IMAGE_PATH"), "album"), _
            rsSongs("TITLE_ALBUM"), rsSongs("ID_ALBUM"), rsSongs("PLAYS"), True)
         rsSongs.MoveNext
       Loop %>
  </div>
  <% End If %>
</section>

<div class="hero-meta" style="justify-content:center;margin:36px 0 8px;color:var(--muted-2)">
  <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg><%=totalAlbums%> álbumes</span>
  <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg><%=totalArtists%> artistas</span>
  <span><svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg><%=totalSongs%> canciones</span>
</div>

<%
rsHero.Close : Set rsHero = Nothing
rsAlbums.Close : Set rsAlbums = Nothing
rsSongs.Close : Set rsSongs = Nothing
rsPlaylists.Close : Set rsPlaylists = Nothing
%>
<!--#include file="includes/footer.asp"-->

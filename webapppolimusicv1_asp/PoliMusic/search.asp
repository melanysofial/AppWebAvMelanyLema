<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<!--#include file="includes/trackrow.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, q, hasQuery, likeQ, rsSongs, rsArtists, rsAlbums, nSong
q = Trim(Request.QueryString("q") & "")
hasQuery = (q <> "")

If hasQuery Then
    likeQ = LikeParam(q)

    Set rsSongs = DbQuery("SELECT TOP 30 s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH, " & _
        "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
        "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
        "FROM TBL_SONG s " & _
        "OUTER APPLY (SELECT TOP 1 al2.ID_ALBUM, al2.TITLE_ALBUM, al2.ALBUM_IMAGE_PATH " & _
        "  FROM TBL_TRACKLIST t JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t.ID_ALBUM " & _
        "  WHERE t.ID_SONG = s.ID_SONG ORDER BY al2.ID_ALBUM) alb " & _
        "WHERE s.SONG_NAME LIKE ? ESCAPE '\' " & _
        "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.SONG_NAME", Array(likeQ))

    Set rsArtists = DbQuery("SELECT TOP 8 a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
        "FROM TBL_ARTIST a " & _
        "WHERE a.ARTIST_NAME LIKE ? ESCAPE '\' OR a.ARTIST_LASTNAME LIKE ? ESCAPE '\' " & _
        "ORDER BY a.ARTIST_NAME", Array(likeQ, likeQ))

    Set rsAlbums = DbQuery("SELECT TOP 8 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
        "FROM TBL_ALBUM al WHERE al.TITLE_ALBUM LIKE ? ESCAPE '\' ORDER BY al.TITLE_ALBUM", Array(likeQ))
Else
    Set rsSongs = DbQuery("SELECT TOP 5 s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH, " & _
        "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
        "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Artista desconocido') AS ARTISTS " & _
        "FROM TBL_SONG s " & _
        "OUTER APPLY (SELECT TOP 1 al2.ID_ALBUM, al2.TITLE_ALBUM, al2.ALBUM_IMAGE_PATH " & _
        "  FROM TBL_TRACKLIST t JOIN TBL_ALBUM al2 ON al2.ID_ALBUM = t.ID_ALBUM " & _
        "  WHERE t.ID_SONG = s.ID_SONG ORDER BY al2.ID_ALBUM) alb " & _
        "ORDER BY ISNULL(s.PLAYS, 0) DESC, s.ID_SONG", Array())

    Set rsArtists = DbQuery("SELECT TOP 6 a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
        "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME", Array())

    Set rsAlbums = DbQuery("SELECT TOP 6 al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
        "FROM TBL_ALBUM al ORDER BY al.ID_ALBUM", Array())
End If

pageTitle = "Buscar"
activeNav = "search"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
      Buscar
    </span>
    <h1 class="page-title">
      <% If hasQuery Then %>Resultados para “<%=H(q)%>”<% Else %>¿Qué quieres escuchar?<% End If %>
    </h1>
    <p class="page-sub">
      <% If hasQuery Then %>
      Encuentra canciones, artistas y álbumes que coincidan con tu búsqueda.
      <% Else %>
      Busca por nombre de canción, artista o álbum. También puedes usar la barra superior en cualquier página.
      <% End If %>
    </p>
  </div>
</div>

<form class="search big" action="<%=Url("search.asp")%>" method="get" role="search" style="margin-bottom:28px">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
  <input type="search" name="q" value="<%=A(q)%>" placeholder="Canciones, artistas, álbumes..." aria-label="Buscar" <% If Not hasQuery Then %>autofocus<% End If %>>
  <button class="btn btn-primary btn-sm" type="submit">Buscar</button>
</form>

<%=FlashHtml()%>

<% If hasQuery And rsSongs.EOF And rsArtists.EOF And rsAlbums.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
  <strong>Sin resultados</strong>
  <p>No encontramos nada para “<%=H(q)%>”. Revisa la ortografía o prueba con otro término.</p>
</div>
<% End If %>

<% If Not rsSongs.EOF Then %>
<section class="section" style="margin-top:0">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
      Canciones <% If hasQuery Then %><span class="badge badge-blue"><%=rsSongs.RecordCount%></span><% End If %>
    </h2>
    <button class="btn btn-ghost btn-sm" type="button" data-play-all="#searchTracks">
      <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg>Reproducir todo
    </button>
  </div>
  <div class="tracklist" data-tracklist id="searchTracks">
    <div class="track-head">
      <span>#</span><span>Título</span><span>Álbum</span>
      <span style="text-align:right">Reproducciones</span><span></span>
    </div>
    <% nSong = 0
       Do While Not rsSongs.EOF
         nSong = nSong + 1
         Response.Write TrackRowHtml(nSong, rsSongs("ID_SONG"), rsSongs("SONG_NAME"), rsSongs("ARTISTS"), _
            MediaSrc(rsSongs("SONG_PATH")), ImgSrc(rsSongs("ALBUM_IMAGE_PATH"), "album"), _
            rsSongs("TITLE_ALBUM"), rsSongs("ID_ALBUM"), rsSongs("PLAYS"), True)
         rsSongs.MoveNext
       Loop %>
  </div>
</section>
<% End If %>

<% If Not rsArtists.EOF Then %>
<section class="section">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
      Artistas <% If hasQuery Then %><span class="badge badge-blue"><%=rsArtists.RecordCount%></span><% End If %>
    </h2>
    <% If hasQuery Then %><a class="section-link" href="<%=Url("artists.asp?q=" & Server.URLEncode(q))%>">Ver todos</a><% End If %>
  </div>
  <div class="grid-cards">
    <% Dim aName
       Do While Not rsArtists.EOF
         aName = rsArtists("ARTIST_NAME") & ""
         If Not IsNull(rsArtists("ARTIST_LASTNAME")) Then
             If Trim(rsArtists("ARTIST_LASTNAME") & "") <> "" Then aName = aName & " " & rsArtists("ARTIST_LASTNAME")
         End If %>
    <a class="card artist-card" href="<%=Url("artist.asp?id=" & rsArtists("ID_ARTIST"))%>">
      <span class="card-cover">
        <img src="<%=A(ImgSrc(rsArtists("ARTIST_IMAGE"), "artist"))%>" alt="<%=A(aName)%>" loading="lazy" onerror="poliImgFallback(this,'artist')">
        <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
      </span>
      <span class="card-title"><%=H(aName)%></span>
      <span class="card-sub"><%=rsArtists("SONGS")%> canciones</span>
    </a>
    <% rsArtists.MoveNext : Loop %>
  </div>
</section>
<% End If %>

<% If Not rsAlbums.EOF Then %>
<section class="section">
  <div class="section-head">
    <h2 class="section-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
      Álbumes <% If hasQuery Then %><span class="badge badge-blue"><%=rsAlbums.RecordCount%></span><% End If %>
    </h2>
    <% If hasQuery Then %><a class="section-link" href="<%=Url("albums.asp?q=" & Server.URLEncode(q))%>">Ver todos</a><% End If %>
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
<% End If %>

<%
rsSongs.Close : Set rsSongs = Nothing
rsArtists.Close : Set rsArtists = Nothing
rsAlbums.Close : Set rsAlbums = Nothing
%>
<!--#include file="includes/footer.asp"-->

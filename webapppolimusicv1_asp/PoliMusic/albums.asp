<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, rs, q, sql, p1
q = Trim(Request.QueryString("q") & "")

sql = "SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
      "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
      "FROM TBL_ALBUM al "
If q <> "" Then
    sql = sql & "WHERE al.TITLE_ALBUM LIKE ? ESCAPE '\' "
    p1 = LikeParam(q)
    sql = sql & "ORDER BY al.TITLE_ALBUM"
    Set rs = DbQuery(sql, Array(p1))
Else
    sql = sql & "ORDER BY al.ID_ALBUM"
    Set rs = DbQuery(sql, Array())
End If

pageTitle = "Álbumes"
activeNav = "albums"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
      Catálogo
    </span>
    <h1 class="page-title">Álbumes</h1>
    <p class="page-sub">Todas las producciones disponibles en PoliMusic, con su portada y cantidad de canciones.</p>
  </div>
  <form class="page-actions" method="get" action="<%=Url("albums.asp")%>">
    <div class="search" style="width:260px">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
      <input type="search" name="q" value="<%=A(q)%>" placeholder="Filtrar álbumes" aria-label="Filtrar álbumes">
    </div>
  </form>
</div>

<%=FlashHtml()%>

<% If rs.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
  <strong>No se encontraron álbumes</strong>
  <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”. Prueba con otro término.<% Else %>Todavía no hay álbumes registrados.<% End If %></p>
</div>
<% Else %>
<div class="grid-cards wide">
  <% Do While Not rs.EOF %>
  <a class="card" href="<%=Url("album.asp?id=" & rs("ID_ALBUM"))%>">
    <span class="card-cover">
      <img src="<%=A(ImgSrc(rs("ALBUM_IMAGE_PATH"), "album"))%>" alt="Portada de <%=A(rs("TITLE_ALBUM"))%>" loading="lazy" onerror="poliImgFallback(this,'album')">
      <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
    </span>
    <span class="card-title"><%=H(rs("TITLE_ALBUM"))%></span>
    <span class="card-sub"><%=H(rs("RELEASE_YEAR"))%> · <%=rs("TRACKS")%> canciones</span>
  </a>
  <% rs.MoveNext : Loop %>
</div>
<% End If %>

<% rs.Close : Set rs = Nothing %>
<!--#include file="includes/footer.asp"-->

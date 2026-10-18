<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, rs, q, sql, p1, fullName
q = Trim(Request.QueryString("q") & "")

sql = "SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
      "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
      "FROM TBL_ARTIST a "
If q <> "" Then
    p1 = LikeParam(q)
    sql = sql & "WHERE (a.ARTIST_NAME LIKE ? ESCAPE '\' OR a.ARTIST_LASTNAME LIKE ? ESCAPE '\') " & _
                "ORDER BY a.ARTIST_NAME"
    Set rs = DbQuery(sql, Array(p1, p1))
Else
    sql = sql & "ORDER BY a.ARTIST_NAME"
    Set rs = DbQuery(sql, Array())
End If

pageTitle = "Artistas"
activeNav = "artists"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
      Talento
    </span>
    <h1 class="page-title">Artistas</h1>
    <p class="page-sub">Las voces y los músicos que forman parte del catálogo de PoliMusic.</p>
  </div>
  <form class="page-actions" method="get" action="<%=Url("artists.asp")%>">
    <div class="search" style="width:260px">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
      <input type="search" name="q" value="<%=A(q)%>" placeholder="Filtrar artistas" aria-label="Filtrar artistas">
    </div>
  </form>
</div>

<%=FlashHtml()%>

<% If rs.EOF Then %>
<div class="empty">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
  <strong>No se encontraron artistas</strong>
  <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Todavía no hay artistas registrados.<% End If %></p>
</div>
<% Else %>
<div class="grid-cards">
  <% Do While Not rs.EOF
       fullName = rs("ARTIST_NAME") & ""
       If Not IsNull(rs("ARTIST_LASTNAME")) Then
           If Trim(rs("ARTIST_LASTNAME") & "") <> "" Then fullName = fullName & " " & rs("ARTIST_LASTNAME")
       End If %>
  <a class="card artist-card" href="<%=Url("artist.asp?id=" & rs("ID_ARTIST"))%>">
    <span class="card-cover">
      <img src="<%=A(ImgSrc(rs("ARTIST_IMAGE"), "artist"))%>" alt="<%=A(fullName)%>" loading="lazy" onerror="poliImgFallback(this,'artist')">
      <span class="card-play"><svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-play"></use></svg></span>
    </span>
    <span class="card-title"><%=H(fullName)%></span>
    <span class="card-sub"><%=rs("SONGS")%> canciones</span>
  </a>
  <% rs.MoveNext : Loop %>
</div>
<% End If %>

<% rs.Close : Set rs = Nothing %>
<!--#include file="includes/footer.asp"-->

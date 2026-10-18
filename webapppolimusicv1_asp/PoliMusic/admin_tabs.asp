<%
If Len(adminActive & "") = 0 Then adminActive = ""
%>
<div class="admin-tabs" role="tablist" aria-label="Secciones de administración">
  <a class="admin-tab<%=IIfStr(adminActive = "panel", " is-active", "")%>" href="<%=Url("admin_index.asp")%>">Panel</a>
  <a class="admin-tab<%=IIfStr(adminActive = "users", " is-active", "")%>" href="<%=Url("admin_users.asp")%>">Usuarios</a>
  <a class="admin-tab<%=IIfStr(adminActive = "songs", " is-active", "")%>" href="<%=Url("admin_songs.asp")%>">Canciones</a>
  <a class="admin-tab<%=IIfStr(adminActive = "artists", " is-active", "")%>" href="<%=Url("admin_artists.asp")%>">Artistas</a>
  <a class="admin-tab<%=IIfStr(adminActive = "albums", " is-active", "")%>" href="<%=Url("admin_albums.asp")%>">Álbumes</a>
  <a class="admin-tab<%=IIfStr(adminActive = "playlists", " is-active", "")%>" href="<%=Url("admin_playlists.asp")%>">Playlists</a>
</div>

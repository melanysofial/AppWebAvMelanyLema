<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim action, doAction, editId, errMsg, q, likeQ, isForm
Dim vTitle, vUser, vType, vDateRaw, vPhoto, vDate, selIds, playlistId
Dim rs, rsUsers, rsTypes, rsSongs, rsList, rsSel, arr, i, sid, tmpSql, ph, delId, totalRows

action = LCase(Trim(Request.QueryString("action") & ""))
editId = IntParam(Request.QueryString("id"), 0)
q = Trim(Request.QueryString("q") & "")
errMsg = ""
vTitle = ""
vUser = 0
vType = 0
vDateRaw = FmtDateInput(Date())
vPhoto = ""
selIds = ","

If editId > 0 Then
    Set rs = DbQuery("SELECT ID_PLAYLIST, ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(editId))
    If rs.EOF Then
        rs.Close
        Response.Redirect Url("admin_playlists.asp?e=notfound")
    End If
    vTitle = CStr(rs("TITLE") & "")
    vUser = CLng(rs("ID_USER"))
    vType = CInt(rs("TYPE"))
    vDateRaw = FmtDateInput(rs("CREATION_DATE"))
    vPhoto = CStr(rs("PHOTO") & "")
    rs.Close

    Set rsSel = DbQuery("SELECT ID_SONG FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(editId))
    Do While Not rsSel.EOF
        selIds = selIds & rsSel("ID_SONG") & ","
        rsSel.MoveNext
    Loop
    rsSel.Close : Set rsSel = Nothing
End If

If IsPost() Then
    RequireCsrf
    doAction = LCase(Request.Form("do") & "")

    If doAction = "delete" Then
        delId = IntParam(Request.Form("id"), 0)
        If delId <= 0 Or IsNull(DbScalar("SELECT ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(delId))) Then
            Response.Redirect Url("admin_playlists.asp?e=notfound")
        End If
        DbExec "SET XACT_ABORT ON; BEGIN TRAN; " & _
               "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?; " & _
               "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?; COMMIT;", Array(delId, delId)
        Response.Redirect Url("admin_playlists.asp?ok=deleted")

    ElseIf doAction = "save" Then
        editId = IntParam(Request.Form("id"), 0)
        vTitle = Trim(Request.Form("title") & "")
        vUser = IntParam(Request.Form("id_user"), 0)
        vType = IntParam(Request.Form("type"), 0)
        vDateRaw = Trim(Request.Form("creation_date") & "")
        vPhoto = Trim(Request.Form("photo") & "")
        action = "form"

        selIds = ","
        If Request.Form("song") <> "" Then
            arr = Split(Request.Form("song") & "", ",")
            For i = 0 To UBound(arr)
                sid = IntParam(Trim(arr(i)), 0)
                If sid > 0 Then selIds = selIds & sid & ","
            Next
        End If

        If vTitle = "" Or Len(vTitle) > 50 Then
            errMsg = "El título de la playlist es obligatorio (máximo 50 caracteres)."
        ElseIf vUser <= 0 Or IsNull(DbScalar("SELECT ID_USER FROM TBL_USER WHERE ID_USER = ?", Array(vUser))) Then
            errMsg = "Selecciona un usuario propietario válido."
        ElseIf vType <> 0 And vType <> 1 Then
            errMsg = "El tipo de playlist no es válido."
        ElseIf vDateRaw = "" Then
            errMsg = "Indica la fecha de creación."
        End If

        If errMsg = "" Then
            vDate = ParseIsoDate(vDateRaw)
            If IsNull(vDate) Then errMsg = "La fecha de creación no es válida."
        End If

        If errMsg = "" Then
            ph = SafePath(vPhoto, True)
            If vPhoto <> "" And ph = "" Then
                errMsg = "La ruta de la imagen no es válida."
            End If
        End If

        If errMsg = "" Then
            If editId > 0 Then
                DbExec "UPDATE TBL_PLAYLIST SET ID_USER = ?, TITLE = ?, CREATION_DATE = ?, TYPE = ?, PHOTO = ? WHERE ID_PLAYLIST = ?", Array( _
                    vUser, vTitle, vDate, vType, ph, editId)
                playlistId = editId
            Else
                playlistId = CLng(DbScalar("INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) OUTPUT INSERTED.ID_PLAYLIST VALUES (?, ?, ?, ?, ?)", Array( _
                    vUser, vTitle, vDate, vType, ph)))
            End If

            tmpSql = "SET XACT_ABORT ON; BEGIN TRAN; DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = " & playlistId & ";"
            If Len(selIds) > 2 Then
                arr = Split(Mid(selIds, 2, Len(selIds) - 2), ",")
                For i = 0 To UBound(arr)
                    sid = IntParam(Trim(arr(i)), 0)
                    If sid > 0 Then
                        tmpSql = tmpSql & " INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (" & playlistId & ", " & sid & ");"
                    End If
                Next
            End If
            tmpSql = tmpSql & " COMMIT;"
            DbExec tmpSql, Array()

            Response.Redirect Url("admin_playlists.asp?ok=saved")
        End If
    End If
End If

isForm = (action = "new" Or action = "edit" Or action = "form")

Set rsUsers = DbQuery("SELECT ID_USER, USERNAME FROM TBL_USER ORDER BY USERNAME", Array())
Set rsTypes = DbQuery("SELECT COD_CATALOG, VALUE FROM TBL_CATALOG WHERE COD_CATALOG_PARENT = '2' ORDER BY COD_CATALOG", Array())
Set rsSongs = DbQuery("SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", Array())

If q <> "" Then
    likeQ = LikeParam(q)
    Set rsList = DbQuery("SELECT p.ID_PLAYLIST, p.TITLE, p.CREATION_DATE, p.TYPE, p.PHOTO, u.USERNAME, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
        "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
        "WHERE p.TITLE LIKE ? ESCAPE '\' OR u.USERNAME LIKE ? ESCAPE '\' " & _
        "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC", Array(likeQ, likeQ))
Else
    Set rsList = DbQuery("SELECT p.ID_PLAYLIST, p.TITLE, p.CREATION_DATE, p.TYPE, p.PHOTO, u.USERNAME, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS SONGS " & _
        "FROM TBL_PLAYLIST p JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
        "ORDER BY p.CREATION_DATE DESC, p.ID_PLAYLIST DESC", Array())
End If
totalRows = rsList.RecordCount

pageTitle = "Playlists"
activeNav = "admin-playlists"
adminActive = "playlists"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Playlists</h1>
    <p class="page-sub">Gestiona las playlists de todos los usuarios, su visibilidad y sus canciones.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-primary" href="<%=Url("admin_playlists.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nueva playlist
    </a>
  </div>
</div>

<%=FlashHtml()%>
<!--#include file="admin_tabs.asp"-->

<% If isForm Then %>
<section class="panel form-panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-<%=IIfStr(editId > 0, "edit", "plus")%>"></use></svg>
      <% If editId > 0 Then %>Editar playlist #<%=editId%><% Else %>Nueva playlist<% End If %>
    </h2>
    <a class="section-link" href="<%=Url("admin_playlists.asp")%>">Cancelar</a>
  </div>
  <div class="panel-body">
    <% If errMsg <> "" Then %>
    <div class="form-error">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form method="post" action="<%=Url("admin_playlists.asp?action=" & IIfStr(editId > 0, "edit", "new"))%>">
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<%=editId%>">

      <div class="form-grid">
        <div class="field">
          <label for="title">Título</label>
          <input type="text" id="title" name="title" value="<%=A(vTitle)%>" maxlength="50" required>
        </div>

        <div class="field">
          <label for="id_user">Propietario</label>
          <select id="id_user" name="id_user" required>
            <option value="">Selecciona un usuario</option>
            <% Do While Not rsUsers.EOF %>
            <option value="<%=rsUsers("ID_USER")%>"<% If CLng(vUser) = CLng(rsUsers("ID_USER")) Then Response.Write " selected" %>><%=H(rsUsers("USERNAME"))%></option>
            <% rsUsers.MoveNext : Loop %>
          </select>
        </div>

        <div class="field">
          <label for="type">Visibilidad</label>
          <select id="type" name="type">
            <%
            If rsTypes.EOF Then
            %>
            <option value="0"<% If vType = 0 Then Response.Write " selected" %>>Pública</option>
            <option value="1"<% If vType = 1 Then Response.Write " selected" %>>Privada</option>
            <%
            Else
                Do While Not rsTypes.EOF
            %>
            <option value="<%=A(rsTypes("COD_CATALOG"))%>"<% If CStr(vType) = CStr(rsTypes("COD_CATALOG")) Then Response.Write " selected" %>><%=H(rsTypes("VALUE"))%></option>
            <%
                    rsTypes.MoveNext
                Loop
            End If
            %>
          </select>
        </div>

        <div class="field">
          <label for="creation_date">Fecha de creación</label>
          <input type="date" id="creation_date" name="creation_date" value="<%=A(vDateRaw)%>" required>
        </div>

        <div class="field full">
          <label for="photo">Ruta de la portada</label>
          <input type="text" id="photo" name="photo" value="<%=A(vPhoto)%>" maxlength="255" placeholder="~/playlistImages/default.jpg">
          <span class="hint">Ruta relativa dentro del sitio. Si se deja vacía se usa una portada por defecto.</span>
        </div>

        <div class="field full">
          <label>Canciones</label>
          <% If rsSongs.EOF Then %>
          <p class="hint">No hay canciones registradas.</p>
          <% Else %>
          <div class="check-grid">
            <% Do While Not rsSongs.EOF
                 sid = CLng(rsSongs("ID_SONG")) %>
            <label class="check-item">
              <input type="checkbox" name="song" value="<%=sid%>"<% If InStr(selIds, "," & sid & ",") > 0 Then Response.Write " checked" %>>
              <span><%=H(rsSongs("SONG_NAME"))%></span>
            </label>
            <% rsSongs.MoveNext : Loop %>
          </div>
          <span class="hint">Las canciones marcadas se guardan en TBL_PLAYLIST_SONG.</span>
          <% End If %>
        </div>
      </div>

      <div class="form-actions">
        <button class="btn btn-primary" type="submit">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>
          <% If editId > 0 Then %>Guardar cambios<% Else %>Crear playlist<% End If %>
        </button>
        <a class="btn btn-ghost" href="<%=Url("admin_playlists.asp")%>">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>
      Listado <span class="badge badge-blue"><%=totalRows%></span>
    </h2>
    <form method="get" action="<%=Url("admin_playlists.asp")%>" style="display:flex;gap:8px">
      <div class="search" style="width:250px;height:38px">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(q)%>" placeholder="Buscar playlist o usuario" aria-label="Buscar playlist">
      </div>
      <button class="btn btn-ghost btn-sm" type="submit">Filtrar</button>
    </form>
  </div>

  <div class="panel-body tight">
    <% If rsList.EOF Then %>
    <div class="empty">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-playlist"></use></svg>
      <strong>No hay playlists</strong>
      <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Crea la primera playlist con el botón de arriba.<% End If %></p>
    </div>
    <% Else %>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Playlist</th>
            <th>Propietario</th>
            <th>Visibilidad</th>
            <th>Creada</th>
            <th class="num">Canciones</th>
            <th style="text-align:right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <% Do While Not rsList.EOF %>
          <tr>
            <td>
              <div class="cell-main">
                <img src="<%=A(ImgSrc(rsList("PHOTO"), "playlist"))%>" alt="" onerror="poliImgFallback(this,'playlist')">
                <div>
                  <strong><%=H(rsList("TITLE"))%></strong>
                  <small>#<%=rsList("ID_PLAYLIST")%></small>
                </div>
              </div>
            </td>
            <td><%=H(rsList("USERNAME"))%></td>
            <td>
              <% If CStr(rsList("TYPE")) = "1" Then %>
              <span class="badge badge-private">Privada</span>
              <% Else %>
              <span class="badge badge-ok">Pública</span>
              <% End If %>
            </td>
            <td><%=FmtDate(rsList("CREATION_DATE"))%></td>
            <td class="num"><%=rsList("SONGS")%></td>
            <td>
              <div class="row-actions">
                <a class="icon-btn sm" href="<%=Url("admin_playlists.asp?action=edit&id=" & rsList("ID_PLAYLIST"))%>" title="Editar" aria-label="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
                <form class="inline-form" method="post" action="<%=Url("admin_playlists.asp")%>" data-confirm="¿Eliminar la playlist <%=A(rsList("TITLE"))%>?">
                  <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
                  <input type="hidden" name="do" value="delete">
                  <input type="hidden" name="id" value="<%=rsList("ID_PLAYLIST")%>">
                  <button class="icon-btn sm" type="submit" title="Eliminar" aria-label="Eliminar">
                    <svg class="icon" viewBox="0 0 24 24"><use href="#i-trash"></use></svg>
                  </button>
                </form>
              </div>
            </td>
          </tr>
          <% rsList.MoveNext : Loop %>
        </tbody>
      </table>
    </div>
    <% End If %>
  </div>
</section>

<%
rsUsers.Close : Set rsUsers = Nothing
rsTypes.Close : Set rsTypes = Nothing
rsSongs.Close : Set rsSongs = Nothing
rsList.Close : Set rsList = Nothing
%>
<!--#include file="includes/footer.asp"-->

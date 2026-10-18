<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim action, doAction, editId, errMsg, q, likeQ, isForm
Dim vName, vPath, vPlays, selIds, songId
Dim rs, rsArtists, rsList, rsSel, arr, i, aid, tmpSql, nDup, delId
Dim totalRows

action = LCase(Trim(Request.QueryString("action") & ""))
editId = IntParam(Request.QueryString("id"), 0)
q = Trim(Request.QueryString("q") & "")
errMsg = ""
vName = ""
vPath = ""
vPlays = 0
selIds = ","

' ---- Cargar canción a editar ----
If editId > 0 Then
    Set rs = DbQuery("SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG WHERE ID_SONG = ?", Array(editId))
    If rs.EOF Then
        rs.Close
        Response.Redirect Url("admin_songs.asp?e=notfound")
    End If
    vName = CStr(rs("SONG_NAME") & "")
    vPath = CStr(rs("SONG_PATH") & "")
    If Not IsNull(rs("PLAYS")) Then vPlays = CLng(rs("PLAYS"))
    rs.Close

    Set rsSel = DbQuery("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(editId))
    Do While Not rsSel.EOF
        selIds = selIds & rsSel("ID_ARTIST") & ","
        rsSel.MoveNext
    Loop
    rsSel.Close : Set rsSel = Nothing
End If

' ---- Acciones POST ----
If IsPost() Then
    RequireCsrf
    doAction = LCase(Request.Form("do") & "")

    If doAction = "delete" Then
        delId = IntParam(Request.Form("id"), 0)
        If delId <= 0 Or IsNull(DbScalar("SELECT ID_SONG FROM TBL_SONG WHERE ID_SONG = ?", Array(delId))) Then
            Response.Redirect Url("admin_songs.asp?e=notfound")
        End If
        DbExec "SET XACT_ABORT ON; BEGIN TRAN; " & _
               "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?; " & _
               "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?; " & _
               "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?; " & _
               "DELETE FROM TBL_SONG WHERE ID_SONG = ?; COMMIT;", Array(delId, delId, delId, delId)
        Response.Redirect Url("admin_songs.asp?ok=deleted")

    ElseIf doAction = "save" Then
        editId = IntParam(Request.Form("id"), 0)
        vName = Trim(Request.Form("song_name") & "")
        vPath = Trim(Request.Form("song_path") & "")
        vPlays = IntParam(Request.Form("plays"), 0)
        action = "form"

        selIds = ","
        If Request.Form("artist") <> "" Then
            arr = Split(Request.Form("artist") & "", ",")
            For i = 0 To UBound(arr)
                aid = IntParam(Trim(arr(i)), 0)
                If aid > 0 Then selIds = selIds & aid & ","
            Next
        End If

        If vName = "" Or Len(vName) > 50 Then
            errMsg = "El nombre de la canción es obligatorio (máximo 50 caracteres)."
        ElseIf vPath = "" Then
            errMsg = "Indica la ruta del archivo de audio."
        ElseIf SafeMediaPath(vPath) = "" Then
            errMsg = "La ruta debe apuntar a un archivo .mp3, .wav, .ogg o .m4a dentro del sitio."
        ElseIf vPlays < 0 Then
            errMsg = "Las reproducciones no pueden ser negativas."
        Else
            If editId > 0 Then
                nDup = DbCount("SELECT COUNT(*) FROM TBL_SONG WHERE SONG_NAME = ? AND ID_SONG <> ?", Array(vName, editId))
            Else
                nDup = DbCount("SELECT COUNT(*) FROM TBL_SONG WHERE SONG_NAME = ?", Array(vName))
            End If
            If nDup > 0 Then errMsg = "Ya existe una canción con ese nombre."
        End If

        If errMsg = "" Then
            vPath = SafeMediaPath(vPath)
            If editId > 0 Then
                DbExec "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?", Array( _
                    vName, vPath, vPlays, editId)
                songId = editId
            Else
                songId = CLng(DbScalar("INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) OUTPUT INSERTED.ID_SONG VALUES (?, ?, ?)", Array( _
                    vName, vPath, vPlays)))
            End If

            ' Reconstruir la relación canción-artista (TBL_PLAYER)
            tmpSql = "SET XACT_ABORT ON; BEGIN TRAN; DELETE FROM TBL_PLAYER WHERE ID_SONG = " & songId & ";"
            If Len(selIds) > 2 Then
                arr = Split(Mid(selIds, 2, Len(selIds) - 2), ",")
                For i = 0 To UBound(arr)
                    aid = IntParam(Trim(arr(i)), 0)
                    If aid > 0 Then
                        tmpSql = tmpSql & " INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (" & songId & ", " & aid & ");"
                    End If
                Next
            End If
            tmpSql = tmpSql & " COMMIT;"
            DbExec tmpSql, Array()

            Response.Redirect Url("admin_songs.asp?ok=saved")
        End If
    End If
End If

isForm = (action = "new" Or action = "edit" Or action = "form")

Set rsArtists = DbQuery("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME", Array())

If q <> "" Then
    likeQ = LikeParam(q)
    Set rsList = DbQuery("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
        "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Sin artista') AS ARTISTS " & _
        "FROM TBL_SONG s WHERE s.SONG_NAME LIKE ? ESCAPE '\' ORDER BY s.ID_SONG", Array(likeQ))
Else
    Set rsList = DbQuery("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "ISNULL((SELECT STUFF((SELECT ', ' + a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '') " & _
        "FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "WHERE p.ID_SONG = s.ID_SONG FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')), 'Sin artista') AS ARTISTS " & _
        "FROM TBL_SONG s ORDER BY s.ID_SONG", Array())
End If
totalRows = rsList.RecordCount

pageTitle = "Canciones"
activeNav = "admin-songs"
adminActive = "songs"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Canciones</h1>
    <p class="page-sub">Administra el catálogo musical y la relación de cada canción con sus artistas.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-primary" href="<%=Url("admin_songs.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nueva canción
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
      <% If editId > 0 Then %>Editar canción #<%=editId%><% Else %>Nueva canción<% End If %>
    </h2>
    <a class="section-link" href="<%=Url("admin_songs.asp")%>">Cancelar</a>
  </div>
  <div class="panel-body">
    <% If errMsg <> "" Then %>
    <div class="form-error">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form method="post" action="<%=Url("admin_songs.asp?action=" & IIfStr(editId > 0, "edit", "new"))%>">
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<%=editId%>">

      <div class="form-grid">
        <div class="field">
          <label for="song_name">Nombre de la canción</label>
          <input type="text" id="song_name" name="song_name" value="<%=A(vName)%>" maxlength="50" required>
        </div>

        <div class="field">
          <label for="plays">Reproducciones</label>
          <input type="number" id="plays" name="plays" value="<%=vPlays%>" min="0" step="1">
          <span class="hint">Se incrementa automáticamente al reproducir.</span>
        </div>

        <div class="field full">
          <label for="song_path">Ruta del archivo de audio</label>
          <input type="text" id="song_path" name="song_path" value="<%=A(vPath)%>" maxlength="255" placeholder="~/songFiles/mi-cancion.mp3" required>
          <span class="hint">Formatos permitidos: .mp3, .wav, .ogg, .m4a. El archivo debe existir dentro del sitio.</span>
        </div>

        <div class="field full">
          <label>Artistas</label>
          <% If rsArtists.EOF Then %>
          <p class="hint">No hay artistas registrados. Puedes crear uno primero en la sección Artistas.</p>
          <% Else %>
          <div class="check-grid">
            <% Do While Not rsArtists.EOF
                 aid = CLng(rsArtists("ID_ARTIST")) %>
            <label class="check-item">
              <input type="checkbox" name="artist" value="<%=aid%>"<% If InStr(selIds, "," & aid & ",") > 0 Then Response.Write " checked" %>>
              <span><%=H(rsArtists("ARTIST_NAME"))%> <%=H(rsArtists("ARTIST_LASTNAME"))%></span>
            </label>
            <% rsArtists.MoveNext : Loop %>
          </div>
          <span class="hint">Una canción puede tener varios artistas (TBL_PLAYER).</span>
          <% End If %>
        </div>
      </div>

      <div class="form-actions">
        <button class="btn btn-primary" type="submit">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>
          <% If editId > 0 Then %>Guardar cambios<% Else %>Crear canción<% End If %>
        </button>
        <a class="btn btn-ghost" href="<%=Url("admin_songs.asp")%>">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
      Listado <span class="badge badge-blue"><%=totalRows%></span>
    </h2>
    <form method="get" action="<%=Url("admin_songs.asp")%>" style="display:flex;gap:8px">
      <div class="search" style="width:250px;height:38px">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(q)%>" placeholder="Buscar canción" aria-label="Buscar canción">
      </div>
      <button class="btn btn-ghost btn-sm" type="submit">Filtrar</button>
    </form>
  </div>

  <div class="panel-body tight">
    <% If rsList.EOF Then %>
    <div class="empty">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg>
      <strong>No hay canciones</strong>
      <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Agrega la primera canción con el botón de arriba.<% End If %></p>
    </div>
    <% Else %>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Canción</th>
            <th>Archivo</th>
            <th>Artistas</th>
            <th class="num">Reproducciones</th>
            <th style="text-align:right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <% Do While Not rsList.EOF %>
          <tr>
            <td>
              <div class="cell-main">
                <div>
                  <strong><%=H(rsList("SONG_NAME"))%></strong>
                  <small>#<%=rsList("ID_SONG")%></small>
                </div>
              </div>
            </td>
            <td><small style="color:var(--muted)"><%=H(rsList("SONG_PATH"))%></small></td>
            <td><%=H(rsList("ARTISTS"))%></td>
            <td class="num"><%=Num(rsList("PLAYS"))%></td>
            <td>
              <div class="row-actions">
                <a class="icon-btn sm" href="<%=Url("admin_songs.asp?action=edit&id=" & rsList("ID_SONG"))%>" title="Editar" aria-label="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
                <form class="inline-form" method="post" action="<%=Url("admin_songs.asp")%>" data-confirm="¿Eliminar la canción <%=A(rsList("SONG_NAME"))%>? Se quitará de álbumes y playlists.">
                  <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
                  <input type="hidden" name="do" value="delete">
                  <input type="hidden" name="id" value="<%=rsList("ID_SONG")%>">
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
rsArtists.Close : Set rsArtists = Nothing
rsList.Close : Set rsList = Nothing
%>
<!--#include file="includes/footer.asp"-->

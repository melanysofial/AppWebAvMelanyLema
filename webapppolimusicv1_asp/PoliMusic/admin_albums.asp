<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim action, doAction, editId, errMsg, q, likeQ, isForm
Dim vTitle, vYear, vImage, vYearRaw, selIds, albumId
Dim rs, rsSongs, rsList, rsSel, arr, i, sid, tmpSql, nDup, delId, ph, totalRows, y

action = LCase(Trim(Request.QueryString("action") & ""))
editId = IntParam(Request.QueryString("id"), 0)
q = Trim(Request.QueryString("q") & "")
errMsg = ""
vTitle = ""
vYearRaw = ""
vImage = ""
selIds = ","

If editId > 0 Then
    Set rs = DbQuery("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(editId))
    If rs.EOF Then
        rs.Close
        Response.Redirect Url("admin_albums.asp?e=notfound")
    End If
    vTitle = CStr(rs("TITLE_ALBUM") & "")
    If Not IsNull(rs("RELEASE_YEAR")) Then vYearRaw = CStr(rs("RELEASE_YEAR"))
    vImage = CStr(rs("ALBUM_IMAGE_PATH") & "")
    rs.Close

    Set rsSel = DbQuery("SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(editId))
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
        If delId <= 0 Or IsNull(DbScalar("SELECT ID_ALBUM FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(delId))) Then
            Response.Redirect Url("admin_albums.asp?e=notfound")
        End If
        DbExec "SET XACT_ABORT ON; BEGIN TRAN; " & _
               "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?; " & _
               "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?; COMMIT;", Array(delId, delId)
        Response.Redirect Url("admin_albums.asp?ok=deleted")

    ElseIf doAction = "save" Then
        editId = IntParam(Request.Form("id"), 0)
        vTitle = Trim(Request.Form("title_album") & "")
        vYearRaw = Trim(Request.Form("release_year") & "")
        vImage = Trim(Request.Form("album_image") & "")
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
            errMsg = "El título del álbum es obligatorio (máximo 50 caracteres)."
        ElseIf vYearRaw <> "" And (Not IsNumeric(vYearRaw) Or Len(vYearRaw) > 4) Then
            errMsg = "El año de lanzamiento debe ser un número de 4 dígitos."
        Else
            y = 0
            If vYearRaw <> "" Then y = CLng(vYearRaw)
            If vYearRaw <> "" And (y < 1900 Or y > 2100) Then
                errMsg = "El año debe estar entre 1900 y 2100."
            Else
                If editId > 0 Then
                    nDup = DbCount("SELECT COUNT(*) FROM TBL_ALBUM WHERE TITLE_ALBUM = ? AND ID_ALBUM <> ?", Array(vTitle, editId))
                Else
                    nDup = DbCount("SELECT COUNT(*) FROM TBL_ALBUM WHERE TITLE_ALBUM = ?", Array(vTitle))
                End If
                If nDup > 0 Then errMsg = "Ya existe un álbum con ese título."
            End If
        End If

        If errMsg = "" Then
            ph = SafePath(vImage, True)
            If vImage <> "" And ph = "" Then
                errMsg = "La ruta de la imagen no es válida."
            End If
        End If

        If errMsg = "" Then
            If vYearRaw = "" Then
                vYear = Null
            Else
                vYear = CLng(vYearRaw)
            End If

            If editId > 0 Then
                DbExec "UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?", Array( _
                    vTitle, vYear, ph, editId)
                albumId = editId
            Else
                albumId = CLng(DbScalar("INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) OUTPUT INSERTED.ID_ALBUM VALUES (?, ?, ?)", Array( _
                    vTitle, vYear, ph)))
            End If

            tmpSql = "SET XACT_ABORT ON; BEGIN TRAN; DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = " & albumId & ";"
            If Len(selIds) > 2 Then
                arr = Split(Mid(selIds, 2, Len(selIds) - 2), ",")
                For i = 0 To UBound(arr)
                    sid = IntParam(Trim(arr(i)), 0)
                    If sid > 0 Then
                        tmpSql = tmpSql & " INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (" & albumId & ", " & sid & ");"
                    End If
                Next
            End If
            tmpSql = tmpSql & " COMMIT;"
            DbExec tmpSql, Array()

            Response.Redirect Url("admin_albums.asp?ok=saved")
        End If
    End If
End If

isForm = (action = "new" Or action = "edit" Or action = "form")

Set rsSongs = DbQuery("SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", Array())

If q <> "" Then
    likeQ = LikeParam(q)
    Set rsList = DbQuery("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
        "FROM TBL_ALBUM al WHERE al.TITLE_ALBUM LIKE ? ESCAPE '\' ORDER BY al.ID_ALBUM", Array(likeQ))
Else
    Set rsList = DbQuery("SELECT al.ID_ALBUM, al.TITLE_ALBUM, al.RELEASE_YEAR, al.ALBUM_IMAGE_PATH, " & _
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = al.ID_ALBUM) AS TRACKS " & _
        "FROM TBL_ALBUM al ORDER BY al.ID_ALBUM", Array())
End If
totalRows = rsList.RecordCount

pageTitle = "Álbumes"
activeNav = "admin-albums"
adminActive = "albums"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Álbumes</h1>
    <p class="page-sub">Gestiona los álbumes, su portada y las canciones que forman parte del tracklist.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-primary" href="<%=Url("admin_albums.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nuevo álbum
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
      <% If editId > 0 Then %>Editar álbum #<%=editId%><% Else %>Nuevo álbum<% End If %>
    </h2>
    <a class="section-link" href="<%=Url("admin_albums.asp")%>">Cancelar</a>
  </div>
  <div class="panel-body">
    <% If errMsg <> "" Then %>
    <div class="form-error">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form method="post" action="<%=Url("admin_albums.asp?action=" & IIfStr(editId > 0, "edit", "new"))%>">
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<%=editId%>">

      <div class="form-grid">
        <div class="field">
          <label for="title_album">Título del álbum</label>
          <input type="text" id="title_album" name="title_album" value="<%=A(vTitle)%>" maxlength="50" required>
        </div>
        <div class="field">
          <label for="release_year">Año de lanzamiento</label>
          <input type="number" id="release_year" name="release_year" value="<%=A(vYearRaw)%>" min="1900" max="2100" step="1">
          <span class="hint">Puede quedar vacío si no se conoce.</span>
        </div>
        <div class="field full">
          <label for="album_image">Ruta de la portada</label>
          <input type="text" id="album_image" name="album_image" value="<%=A(vImage)%>" maxlength="255" placeholder="~/albumImages/album1.png">
          <span class="hint">Ruta relativa dentro del sitio. Si se deja vacía se usa una portada por defecto.</span>
        </div>

        <div class="field full">
          <label>Tracklist</label>
          <% If rsSongs.EOF Then %>
          <p class="hint">No hay canciones registradas. Crea canciones primero.</p>
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
          <span class="hint">Marca las canciones que pertenecen al álbum (TBL_TRACKLIST).</span>
          <% End If %>
        </div>
      </div>

      <div class="form-actions">
        <button class="btn btn-primary" type="submit">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>
          <% If editId > 0 Then %>Guardar cambios<% Else %>Crear álbum<% End If %>
        </button>
        <a class="btn btn-ghost" href="<%=Url("admin_albums.asp")%>">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
      Listado <span class="badge badge-blue"><%=totalRows%></span>
    </h2>
    <form method="get" action="<%=Url("admin_albums.asp")%>" style="display:flex;gap:8px">
      <div class="search" style="width:250px;height:38px">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(q)%>" placeholder="Buscar álbum" aria-label="Buscar álbum">
      </div>
      <button class="btn btn-ghost btn-sm" type="submit">Filtrar</button>
    </form>
  </div>

  <div class="panel-body tight">
    <% If rsList.EOF Then %>
    <div class="empty">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg>
      <strong>No hay álbumes</strong>
      <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Crea el primer álbum con el botón de arriba.<% End If %></p>
    </div>
    <% Else %>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Álbum</th>
            <th>Año</th>
            <th class="num">Canciones</th>
            <th>Portada</th>
            <th style="text-align:right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <% Do While Not rsList.EOF %>
          <tr>
            <td>
              <div class="cell-main">
                <img src="<%=A(ImgSrc(rsList("ALBUM_IMAGE_PATH"), "album"))%>" alt="" onerror="poliImgFallback(this,'album')">
                <div>
                  <strong><%=H(rsList("TITLE_ALBUM"))%></strong>
                  <small>#<%=rsList("ID_ALBUM")%></small>
                </div>
              </div>
            </td>
            <td><%=H(rsList("RELEASE_YEAR"))%></td>
            <td class="num"><%=rsList("TRACKS")%></td>
            <td><small style="color:var(--muted)"><%=H(rsList("ALBUM_IMAGE_PATH"))%></small></td>
            <td>
              <div class="row-actions">
                <a class="icon-btn sm" href="<%=Url("admin_albums.asp?action=edit&id=" & rsList("ID_ALBUM"))%>" title="Editar" aria-label="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
                <form class="inline-form" method="post" action="<%=Url("admin_albums.asp")%>" data-confirm="¿Eliminar el álbum <%=A(rsList("TITLE_ALBUM"))%>? Se eliminará su tracklist.">
                  <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
                  <input type="hidden" name="do" value="delete">
                  <input type="hidden" name="id" value="<%=rsList("ID_ALBUM")%>">
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
rsSongs.Close : Set rsSongs = Nothing
rsList.Close : Set rsList = Nothing
%>
<!--#include file="includes/footer.asp"-->

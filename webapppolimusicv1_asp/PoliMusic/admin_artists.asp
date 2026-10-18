<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim action, doAction, editId, errMsg, q, likeQ, isForm
Dim vName, vLast, vImage
Dim rs, rsList, ph, nDup, delId, totalRows

action = LCase(Trim(Request.QueryString("action") & ""))
editId = IntParam(Request.QueryString("id"), 0)
q = Trim(Request.QueryString("q") & "")
errMsg = ""
vName = ""
vLast = ""
vImage = ""

If editId > 0 Then
    Set rs = DbQuery("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(editId))
    If rs.EOF Then
        rs.Close
        Response.Redirect Url("admin_artists.asp?e=notfound")
    End If
    vName = CStr(rs("ARTIST_NAME") & "")
    vLast = CStr(rs("ARTIST_LASTNAME") & "")
    vImage = CStr(rs("ARTIST_IMAGE") & "")
    rs.Close
End If

If IsPost() Then
    RequireCsrf
    doAction = LCase(Request.Form("do") & "")

    If doAction = "delete" Then
        delId = IntParam(Request.Form("id"), 0)
        If delId <= 0 Or IsNull(DbScalar("SELECT ID_ARTIST FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(delId))) Then
            Response.Redirect Url("admin_artists.asp?e=notfound")
        End If
        DbExec "SET XACT_ABORT ON; BEGIN TRAN; " & _
               "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?; " & _
               "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?; COMMIT;", Array(delId, delId)
        Response.Redirect Url("admin_artists.asp?ok=deleted")

    ElseIf doAction = "save" Then
        editId = IntParam(Request.Form("id"), 0)
        vName = Trim(Request.Form("artist_name") & "")
        vLast = Trim(Request.Form("artist_lastname") & "")
        vImage = Trim(Request.Form("artist_image") & "")
        action = "form"

        If vName = "" Or Len(vName) > 100 Then
            errMsg = "El nombre del artista es obligatorio (máximo 100 caracteres)."
        ElseIf Len(vLast) > 100 Then
            errMsg = "El apellido no puede superar los 100 caracteres."
        Else
            If editId > 0 Then
                nDup = DbCount("SELECT COUNT(*) FROM TBL_ARTIST WHERE ARTIST_NAME = ? AND ISNULL(ARTIST_LASTNAME, '') = ? AND ID_ARTIST <> ?", Array(vName, vLast, editId))
            Else
                nDup = DbCount("SELECT COUNT(*) FROM TBL_ARTIST WHERE ARTIST_NAME = ? AND ISNULL(ARTIST_LASTNAME, '') = ?", Array(vName, vLast))
            End If
            If nDup > 0 Then errMsg = "Ya existe un artista con ese nombre."
        End If

        If errMsg = "" Then
            ph = SafePath(vImage, True)
            If vImage <> "" And ph = "" Then
                errMsg = "La ruta de la imagen no es válida."
            End If
        End If

        If errMsg = "" Then
            If vLast = "" Then
                vLast = Null
            End If
            If editId > 0 Then
                DbExec "UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?", Array( _
                    vName, vLast, ph, editId)
            Else
                DbExec "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) VALUES (?, ?, ?)", Array( _
                    vName, vLast, ph)
            End If
            Response.Redirect Url("admin_artists.asp?ok=saved")
        End If
    End If
End If

isForm = (action = "new" Or action = "edit" Or action = "form")

If q <> "" Then
    likeQ = LikeParam(q)
    Set rsList = DbQuery("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
        "FROM TBL_ARTIST a WHERE a.ARTIST_NAME LIKE ? ESCAPE '\' OR a.ARTIST_LASTNAME LIKE ? ESCAPE '\' " & _
        "ORDER BY a.ARTIST_NAME", Array(likeQ, likeQ))
Else
    Set rsList = DbQuery("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
        "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME", Array())
End If
totalRows = rsList.RecordCount

pageTitle = "Artistas"
activeNav = "admin-artists"
adminActive = "artists"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Artistas</h1>
    <p class="page-sub">Gestiona los artistas y su imagen. Las canciones se relacionan desde la sección Canciones.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-primary" href="<%=Url("admin_artists.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nuevo artista
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
      <% If editId > 0 Then %>Editar artista #<%=editId%><% Else %>Nuevo artista<% End If %>
    </h2>
    <a class="section-link" href="<%=Url("admin_artists.asp")%>">Cancelar</a>
  </div>
  <div class="panel-body">
    <% If errMsg <> "" Then %>
    <div class="form-error">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form method="post" action="<%=Url("admin_artists.asp?action=" & IIfStr(editId > 0, "edit", "new"))%>">
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<%=editId%>">

      <div class="form-grid">
        <div class="field">
          <label for="artist_name">Nombre</label>
          <input type="text" id="artist_name" name="artist_name" value="<%=A(vName)%>" maxlength="100" required>
        </div>
        <div class="field">
          <label for="artist_lastname">Apellido</label>
          <input type="text" id="artist_lastname" name="artist_lastname" value="<%=A(vLast)%>" maxlength="100">
        </div>
        <div class="field full">
          <label for="artist_image">Ruta de la imagen</label>
          <input type="text" id="artist_image" name="artist_image" value="<%=A(vImage)%>" maxlength="255" placeholder="~/ArtistImages/artista.png">
          <span class="hint">Ruta relativa dentro del sitio. Si se deja vacía se usa una imagen por defecto.</span>
        </div>
      </div>

      <div class="form-actions">
        <button class="btn btn-primary" type="submit">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>
          <% If editId > 0 Then %>Guardar cambios<% Else %>Crear artista<% End If %>
        </button>
        <a class="btn btn-ghost" href="<%=Url("admin_artists.asp")%>">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
      Listado <span class="badge badge-blue"><%=totalRows%></span>
    </h2>
    <form method="get" action="<%=Url("admin_artists.asp")%>" style="display:flex;gap:8px">
      <div class="search" style="width:250px;height:38px">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(q)%>" placeholder="Buscar artista" aria-label="Buscar artista">
      </div>
      <button class="btn btn-ghost btn-sm" type="submit">Filtrar</button>
    </form>
  </div>

  <div class="panel-body tight">
    <% If rsList.EOF Then %>
    <div class="empty">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-artist"></use></svg>
      <strong>No hay artistas</strong>
      <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Crea el primer artista con el botón de arriba.<% End If %></p>
    </div>
    <% Else %>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Artista</th>
            <th class="num">Canciones</th>
            <th>Imagen</th>
            <th style="text-align:right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <% Do While Not rsList.EOF %>
          <tr>
            <td>
              <div class="cell-main round">
                <img src="<%=A(ImgSrc(rsList("ARTIST_IMAGE"), "artist"))%>" alt="" onerror="poliImgFallback(this,'artist')">
                <div>
                  <strong><%=H(rsList("ARTIST_NAME"))%> <%=H(rsList("ARTIST_LASTNAME"))%></strong>
                  <small>#<%=rsList("ID_ARTIST")%></small>
                </div>
              </div>
            </td>
            <td class="num"><%=rsList("SONGS")%></td>
            <td><small style="color:var(--muted)"><%=H(rsList("ARTIST_IMAGE"))%></small></td>
            <td>
              <div class="row-actions">
                <a class="icon-btn sm" href="<%=Url("admin_artists.asp?action=edit&id=" & rsList("ID_ARTIST"))%>" title="Editar" aria-label="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
                <form class="inline-form" method="post" action="<%=Url("admin_artists.asp")%>" data-confirm="¿Eliminar al artista <%=A(rsList("ARTIST_NAME"))%>? Sus canciones se conservarán.">
                  <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
                  <input type="hidden" name="do" value="delete">
                  <input type="hidden" name="id" value="<%=rsList("ID_ARTIST")%>">
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

<% rsList.Close : Set rsList = Nothing %>
<!--#include file="includes/footer.asp"-->

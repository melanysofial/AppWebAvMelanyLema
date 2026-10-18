<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireAdmin

Dim pageTitle, activeNav, adminActive
Dim action, doAction, editId, errMsg, q, likeQ, isForm
Dim vUsername, vPassword, vEmail, vBirthday, vPhoto, vType
Dim rs, rsTypes, rsList, bday, ph, nDup, tType, adminCount, delId
Dim totalRows

action = LCase(Trim(Request.QueryString("action") & ""))
editId = IntParam(Request.QueryString("id"), 0)
q = Trim(Request.QueryString("q") & "")
errMsg = ""

vUsername = ""
vPassword = ""
vEmail = ""
vBirthday = ""
vPhoto = ""
vType = 0

' ---- Cargar el registro a editar ----
If editId > 0 Then
    Set rs = DbQuery("SELECT ID_USER, USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(editId))
    If rs.EOF Then
        rs.Close
        Response.Redirect Url("admin_users.asp?e=notfound")
    End If
    vUsername = CStr(rs("USERNAME") & "")
    vEmail = CStr(rs("EMAIL") & "")
    vBirthday = FmtDateInput(rs("BIRTHDAY"))
    vPhoto = CStr(rs("USER_PHOTO") & "")
    vType = CInt(rs("USER_TYPE"))
    rs.Close
End If

' ---- Acciones POST ----
If IsPost() Then
    RequireCsrf
    doAction = LCase(Request.Form("do") & "")

    If doAction = "delete" Then
        delId = IntParam(Request.Form("id"), 0)

        If delId = CurrentUserId() Then
            Response.Redirect Url("admin_users.asp?e=self")
        End If

        tType = DbScalar("SELECT USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(delId))
        If IsNull(tType) Then
            Response.Redirect Url("admin_users.asp?e=notfound")
        End If

        If CStr(tType) = "1" Then
            adminCount = DbCount("SELECT COUNT(*) FROM TBL_USER WHERE USER_TYPE = 1", Array())
            If adminCount <= 1 Then
                Response.Redirect Url("admin_users.asp?e=lastadmin")
            End If
        End If

        DbExec "SET XACT_ABORT ON; BEGIN TRAN; " & _
               "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST IN (SELECT ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER = ?); " & _
               "DELETE FROM TBL_PLAYLIST WHERE ID_USER = ?; " & _
               "DELETE FROM TBL_USER WHERE ID_USER = ?; COMMIT;", Array(delId, delId, delId)
        Response.Redirect Url("admin_users.asp?ok=deleted")

    ElseIf doAction = "save" Then
        editId = IntParam(Request.Form("id"), 0)
        vUsername = Trim(Request.Form("username") & "")
        vPassword = Request.Form("password") & ""
        vEmail = Trim(Request.Form("email") & "")
        vBirthday = Trim(Request.Form("birthday") & "")
        vPhoto = Trim(Request.Form("photo") & "")
        vType = IntParam(Request.Form("user_type"), 0)
        action = "form"

        If Len(vUsername) < 3 Or Len(vUsername) > 50 Then
            errMsg = "El nombre de usuario debe tener entre 3 y 50 caracteres."
        ElseIf InStr(vUsername, " ") > 0 Then
            errMsg = "El nombre de usuario no puede contener espacios."
        ElseIf editId = 0 And Len(vPassword) < PWD_MIN_LEN Then
            errMsg = "La contraseña debe tener al menos " & PWD_MIN_LEN & " caracteres."
        ElseIf editId > 0 And vPassword <> "" And Len(vPassword) < PWD_MIN_LEN Then
            errMsg = "La nueva contraseña debe tener al menos " & PWD_MIN_LEN & " caracteres."
        ElseIf vEmail = "" Or InStr(vEmail, "@") < 2 Or InStr(vEmail, ".") = 0 Or Len(vEmail) > 50 Then
            errMsg = "Ingresa un correo electrónico válido (máximo 50 caracteres)."
        ElseIf vType <> 0 And vType <> 1 Then
            errMsg = "El rol seleccionado no es válido."
        Else
            If editId > 0 Then
                nDup = DbCount("SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = ? AND ID_USER <> ?", Array(vUsername, editId))
            Else
                nDup = DbCount("SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = ?", Array(vUsername))
            End If
            If nDup > 0 Then errMsg = "Ese nombre de usuario ya está en uso."
        End If

        If errMsg = "" Then
            bday = ParseIsoDate(vBirthday)
            If vBirthday <> "" And IsNull(bday) Then
                errMsg = "La fecha de nacimiento no es válida."
            End If
        End If

        If errMsg = "" Then
            ph = SafePath(vPhoto, True)
            If vPhoto <> "" And ph = "" Then
                errMsg = "La ruta de la foto no es válida."
            End If
        End If

        If errMsg = "" And editId > 0 And vType = 0 Then
            tType = DbScalar("SELECT USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(editId))
            If Not IsNull(tType) Then
                If CStr(tType) = "1" Then
                    adminCount = DbCount("SELECT COUNT(*) FROM TBL_USER WHERE USER_TYPE = 1", Array())
                    If adminCount <= 1 Then
                        errMsg = "Debe existir al menos un administrador en el sistema."
                    End If
                End If
            End If
        End If

        If errMsg = "" And editId > 0 And editId = CurrentUserId() And vType <> 1 Then
            errMsg = "No puedes quitarte a ti mismo el rol de administrador."
        End If

        If errMsg = "" Then
            If editId > 0 Then
                If vPassword <> "" Then
                    If LCase(PWD_MODE) = "plain" Then
                        DbExec "UPDATE TBL_USER SET USERNAME = ?, PASSWORD = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? WHERE ID_USER = ?", Array( _
                            vUsername, vPassword, vEmail, bday, ph, vType, editId)
                    Else
                        DbExec "UPDATE TBL_USER SET USERNAME = ?, PASSWORD = CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2), EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? WHERE ID_USER = ?", Array( _
                            vUsername, vPassword, vEmail, bday, ph, vType, editId)
                    End If
                Else
                    DbExec "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? WHERE ID_USER = ?", Array( _
                        vUsername, vEmail, bday, ph, vType, editId)
                End If
            Else
                If LCase(PWD_MODE) = "plain" Then
                    DbExec "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) VALUES (?, ?, ?, ?, ?, ?)", Array( _
                        vUsername, vPassword, vEmail, bday, ph, vType)
                Else
                    DbExec "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) VALUES (?, CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2), ?, ?, ?, ?)", Array( _
                        vUsername, vPassword, vEmail, bday, ph, vType)
                End If
            End If
            Response.Redirect Url("admin_users.asp?ok=saved")
        End If
    End If
End If

isForm = (action = "new" Or action = "edit" Or action = "form")

Set rsTypes = DbQuery("SELECT COD_CATALOG, VALUE FROM TBL_CATALOG WHERE COD_CATALOG_PARENT = '1' ORDER BY COD_CATALOG", Array())

If q <> "" Then
    likeQ = LikeParam(q)
    Set rsList = DbQuery("SELECT u.ID_USER, u.USERNAME, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST p WHERE p.ID_USER = u.ID_USER) AS PLAYLISTS " & _
        "FROM TBL_USER u WHERE u.USERNAME LIKE ? ESCAPE '\' OR u.EMAIL LIKE ? ESCAPE '\' " & _
        "ORDER BY u.ID_USER", Array(likeQ, likeQ))
Else
    Set rsList = DbQuery("SELECT u.ID_USER, u.USERNAME, u.EMAIL, u.BIRTHDAY, u.USER_PHOTO, u.USER_TYPE, " & _
        "(SELECT COUNT(*) FROM TBL_PLAYLIST p WHERE p.ID_USER = u.ID_USER) AS PLAYLISTS " & _
        "FROM TBL_USER u ORDER BY u.ID_USER", Array())
End If
totalRows = rsList.RecordCount

pageTitle = "Usuarios"
activeNav = "admin-users"
adminActive = "users"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg>
      Administración
    </span>
    <h1 class="page-title">Usuarios</h1>
    <p class="page-sub">Crea, edita y elimina cuentas. Los roles se toman de TBL_CATALOG (USER TYPE).</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-primary" href="<%=Url("admin_users.asp?action=new")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-plus"></use></svg>Nuevo usuario
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
      <% If editId > 0 Then %>Editar usuario #<%=editId%><% Else %>Nuevo usuario<% End If %>
    </h2>
    <a class="section-link" href="<%=Url("admin_users.asp")%>">Cancelar</a>
  </div>
  <div class="panel-body">
    <% If errMsg <> "" Then %>
    <div class="form-error">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form method="post" action="<%=Url("admin_users.asp?action=" & IIfStr(editId > 0, "edit", "new"))%>">
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<%=editId%>">

      <div class="form-grid">
        <div class="field">
          <label for="username">Nombre de usuario</label>
          <input type="text" id="username" name="username" value="<%=A(vUsername)%>" maxlength="50" required>
          <span class="hint">Sin espacios. Se usa para iniciar sesión.</span>
        </div>

        <div class="field">
          <label for="password">Contraseña</label>
          <input type="password" id="password" name="password" maxlength="50" autocomplete="new-password" <% If editId = 0 Then %>required<% End If %>>
          <span class="hint"><% If editId > 0 Then %>Déjala vacía para conservar la contraseña actual.<% Else %>Mínimo <%=PWD_MIN_LEN%> caracteres.<% End If %></span>
        </div>

        <div class="field">
          <label for="email">Correo electrónico</label>
          <input type="email" id="email" name="email" value="<%=A(vEmail)%>" maxlength="50" required>
        </div>

        <div class="field">
          <label for="birthday">Fecha de nacimiento</label>
          <input type="date" id="birthday" name="birthday" value="<%=A(vBirthday)%>">
        </div>

        <div class="field">
          <label for="photo">Ruta de la foto</label>
          <input type="text" id="photo" name="photo" value="<%=A(vPhoto)%>" maxlength="255" placeholder="~/userImages/default.jpg">
          <span class="hint">Ruta relativa dentro del sitio.</span>
        </div>

        <div class="field">
          <label for="user_type">Rol</label>
          <select id="user_type" name="user_type">
            <%
            If rsTypes.EOF Then
            %>
            <option value="0"<% If vType = 0 Then Response.Write " selected" %>>Usuario</option>
            <option value="1"<% If vType = 1 Then Response.Write " selected" %>>Administrador</option>
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
      </div>

      <div class="form-actions">
        <button class="btn btn-primary" type="submit">
          <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>
          <% If editId > 0 Then %>Guardar cambios<% Else %>Crear usuario<% End If %>
        </button>
        <a class="btn btn-ghost" href="<%=Url("admin_users.asp")%>">Cancelar</a>
      </div>
    </form>
  </div>
</section>
<% End If %>

<section class="panel">
  <div class="panel-head">
    <h2 class="panel-title">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg>
      Listado <span class="badge badge-blue"><%=totalRows%></span>
    </h2>
    <form method="get" action="<%=Url("admin_users.asp")%>" style="display:flex;gap:8px">
      <div class="search" style="width:250px;height:38px">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-search"></use></svg>
        <input type="search" name="q" value="<%=A(q)%>" placeholder="Buscar usuario o correo" aria-label="Buscar usuario">
      </div>
      <button class="btn btn-ghost btn-sm" type="submit">Filtrar</button>
    </form>
  </div>

  <div class="panel-body tight">
    <% If rsList.EOF Then %>
    <div class="empty">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-users"></use></svg>
      <strong>No hay usuarios</strong>
      <p><% If q <> "" Then %>No hay coincidencias para “<%=H(q)%>”.<% Else %>Crea el primer usuario con el botón de arriba.<% End If %></p>
    </div>
    <% Else %>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Usuario</th>
            <th>Correo</th>
            <th>Rol</th>
            <th>Cumpleaños</th>
            <th class="num">Playlists</th>
            <th style="text-align:right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <% Do While Not rsList.EOF %>
          <tr>
            <td>
              <div class="cell-main">
                <img src="<%=A(ImgSrc(rsList("USER_PHOTO"), "user"))%>" alt="" onerror="poliImgFallback(this,'user')">
                <div>
                  <strong>
                    <%=H(rsList("USERNAME"))%>
                    <% If CLng(rsList("ID_USER")) = CurrentUserId() Then %><span class="badge badge-soft" style="margin-left:6px">Tú</span><% End If %>
                  </strong>
                  <small>#<%=rsList("ID_USER")%></small>
                </div>
              </div>
            </td>
            <td><%=H(rsList("EMAIL"))%></td>
            <td>
              <% If CStr(rsList("USER_TYPE")) = "1" Then %>
              <span class="badge badge-blue">Administrador</span>
              <% Else %>
              <span class="badge">Usuario</span>
              <% End If %>
            </td>
            <td><%=FmtDate(rsList("BIRTHDAY"))%></td>
            <td class="num"><%=rsList("PLAYLISTS")%></td>
            <td>
              <div class="row-actions">
                <a class="icon-btn sm" href="<%=Url("admin_users.asp?action=edit&id=" & rsList("ID_USER"))%>" title="Editar" aria-label="Editar">
                  <svg class="icon" viewBox="0 0 24 24"><use href="#i-edit"></use></svg>
                </a>
                <% If CLng(rsList("ID_USER")) <> CurrentUserId() Then %>
                <form class="inline-form" method="post" action="<%=Url("admin_users.asp")%>" data-confirm="¿Eliminar al usuario <%=A(rsList("USERNAME"))%>? También se eliminarán sus playlists.">
                  <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
                  <input type="hidden" name="do" value="delete">
                  <input type="hidden" name="id" value="<%=rsList("ID_USER")%>">
                  <button class="icon-btn sm" type="submit" title="Eliminar" aria-label="Eliminar">
                    <svg class="icon" viewBox="0 0 24 24"><use href="#i-trash"></use></svg>
                  </button>
                </form>
                <% End If %>
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
rsTypes.Close : Set rsTypes = Nothing
rsList.Close : Set rsList = Nothing
%>
<!--#include file="includes/footer.asp"-->

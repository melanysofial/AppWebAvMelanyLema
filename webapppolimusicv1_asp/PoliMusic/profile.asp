<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
RequireLogin

Dim pageTitle, activeNav, rsUser, errMsg, okMsg
Dim vEmail, vBirthday, vPhoto, bday, newPhoto, uid
Dim curPwd, newPwd, newPwd2, okPwd

errMsg = ""
okMsg = ""
uid = CurrentUserId()

Set rsUser = DbQuery("SELECT ID_USER, USERNAME, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE ID_USER = ?", Array(uid))
If rsUser.EOF Then
    rsUser.Close
    Session.Contents.RemoveAll
    Session.Abandon
    Response.Redirect Url("login.asp")
End If

vEmail = CStr(rsUser("EMAIL") & "")
vBirthday = FmtDateInput(rsUser("BIRTHDAY"))
vPhoto = CStr(rsUser("USER_PHOTO") & "")

If IsPost() Then
    RequireCsrf

    If Request.Form("do") = "profile" Then
        vEmail = Trim(Request.Form("email") & "")
        vBirthday = Trim(Request.Form("birthday") & "")
        vPhoto = Trim(Request.Form("photo") & "")

        If vEmail = "" Or InStr(vEmail, "@") < 2 Or InStr(vEmail, ".") = 0 Then
            errMsg = "Ingresa un correo electrónico válido."
        ElseIf Len(vEmail) > 50 Then
            errMsg = "El correo no puede superar los 50 caracteres."
        Else
            bday = ParseIsoDate(vBirthday)
            If vBirthday <> "" And IsNull(bday) Then
                errMsg = "La fecha de nacimiento no es válida."
            Else
                newPhoto = SafePath(vPhoto, True)
                If vPhoto <> "" And newPhoto = "" Then
                    errMsg = "La ruta de la foto no es válida."
                Else
                    DbExec "UPDATE TBL_USER SET EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ? WHERE ID_USER = ?", Array( _
                        vEmail, bday, newPhoto, uid)
                    Session("Email") = vEmail
                    Session("UserPhoto") = newPhoto
                    Response.Redirect Url("profile.asp?ok=saved")
                End If
            End If
        End If

    ElseIf Request.Form("do") = "password" Then
        curPwd = Request.Form("current_password") & ""
        newPwd = Request.Form("new_password") & ""
        newPwd2 = Request.Form("new_password2") & ""

        okPwd = DbCount("SELECT COUNT(*) FROM TBL_USER WHERE ID_USER = ? AND (PASSWORD = ? OR " & _
            "UPPER(PASSWORD) = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2)))", Array( _
            uid, curPwd, curPwd))

        If okPwd = 0 Then
            errMsg = "La contraseña actual no es correcta."
        ElseIf Len(newPwd) < PWD_MIN_LEN Then
            errMsg = "La nueva contraseña debe tener al menos " & PWD_MIN_LEN & " caracteres."
        ElseIf newPwd <> newPwd2 Then
            errMsg = "La nueva contraseña y su confirmación no coinciden."
        Else
            If LCase(PWD_MODE) = "plain" Then
                DbExec "UPDATE TBL_USER SET PASSWORD = ? WHERE ID_USER = ?", Array(newPwd, uid)
            Else
                DbExec "UPDATE TBL_USER SET PASSWORD = CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2) WHERE ID_USER = ?", Array(newPwd, uid)
            End If
            Response.Redirect Url("profile.asp?ok=saved")
        End If
    End If
End If

pageTitle = "Mi perfil"
activeNav = "profile"
%>
<!--#include file="includes/header.asp"-->

<div class="page-head">
  <div>
    <span class="page-kicker">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-user"></use></svg>
      Cuenta
    </span>
    <h1 class="page-title">Mi perfil</h1>
    <p class="page-sub">Actualiza tus datos de contacto y tu contraseña. Tu nombre de usuario no cambia.</p>
  </div>
  <div class="page-actions">
    <a class="btn btn-ghost" href="<%=Url("index.asp")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-home"></use></svg>Inicio
    </a>
  </div>
</div>

<%=FlashHtml()%>

<% If errMsg <> "" Then %>
<div class="form-error">
  <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
  <span><%=H(errMsg)%></span>
</div>
<% End If %>

<div class="profile-grid">
  <aside class="profile-card">
    <img class="avatar avatar-lg" src="<%=A(ImgSrc(vPhoto, "user"))%>" alt="Foto de <%=A(rsUser("USERNAME"))%>" onerror="poliImgFallback(this,'user')">
    <div class="profile-name"><%=H(rsUser("USERNAME"))%></div>
    <div class="profile-role">
      <% If IsAdmin() Then %>
      <span class="badge badge-blue"><svg class="icon" viewBox="0 0 24 24"><use href="#i-admin"></use></svg>Administrador</span>
      <% Else %>
      <span class="badge"><svg class="icon" viewBox="0 0 24 24"><use href="#i-user"></use></svg>Usuario</span>
      <% End If %>
    </div>
    <div class="profile-rows">
      <div class="profile-row"><span>Usuario</span><strong><%=H(rsUser("USERNAME"))%></strong></div>
      <div class="profile-row"><span>Correo</span><strong><%=H(vEmail)%></strong></div>
      <div class="profile-row"><span>Cumpleaños</span><strong><% If IsDate(ParseIsoDate(vBirthday)) Then %><%=FmtDate(ParseIsoDate(vBirthday))%><% Else %>—<% End If %></strong></div>
      <div class="profile-row"><span>ID</span><strong>#<%=rsUser("ID_USER")%></strong></div>
    </div>
    <% If IsAdmin() Then %>
    <a class="btn btn-primary" style="width:100%;margin-top:18px" href="<%=Url("admin_index.asp")%>">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-grid"></use></svg>Panel de administración
    </a>
    <% End If %>
  </aside>

  <div>
    <section class="panel" style="margin-bottom:22px">
      <div class="panel-head">
        <h2 class="panel-title"><svg class="icon" viewBox="0 0 24 24"><use href="#i-user"></use></svg>Datos personales</h2>
      </div>
      <div class="panel-body">
        <form method="post" action="<%=Url("profile.asp")%>">
          <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
          <input type="hidden" name="do" value="profile">
          <div class="form-grid">
            <div class="field">
              <label>Usuario</label>
              <input type="text" value="<%=A(rsUser("USERNAME"))%>" disabled>
              <span class="hint">El nombre de usuario solo lo puede cambiar un administrador.</span>
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
              <input type="text" id="photo" name="photo" value="<%=A(vPhoto)%>" placeholder="~/userImages/mi-foto.png" maxlength="255">
              <span class="hint">Ruta relativa dentro del sitio. Déjala vacía para usar el avatar por defecto.</span>
            </div>
          </div>
          <div class="form-actions">
            <button class="btn btn-primary" type="submit">
              <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>Guardar cambios
            </button>
          </div>
        </form>
      </div>
    </section>

    <section class="panel">
      <div class="panel-head">
        <h2 class="panel-title"><svg class="icon" viewBox="0 0 24 24"><use href="#i-admin"></use></svg>Seguridad</h2>
      </div>
      <div class="panel-body">
        <form method="post" action="<%=Url("profile.asp")%>">
          <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">
          <input type="hidden" name="do" value="password">
          <div class="form-grid">
            <div class="field full">
              <label for="current_password">Contraseña actual</label>
              <input type="password" id="current_password" name="current_password" autocomplete="current-password" required>
            </div>
            <div class="field">
              <label for="new_password">Nueva contraseña</label>
              <input type="password" id="new_password" name="new_password" autocomplete="new-password" minlength="<%=PWD_MIN_LEN%>" required>
              <span class="hint">Mínimo <%=PWD_MIN_LEN%> caracteres.</span>
            </div>
            <div class="field">
              <label for="new_password2">Confirmar contraseña</label>
              <input type="password" id="new_password2" name="new_password2" autocomplete="new-password" minlength="<%=PWD_MIN_LEN%>" required>
            </div>
          </div>
          <div class="form-actions">
            <button class="btn btn-ghost" type="submit">
              <svg class="icon" viewBox="0 0 24 24"><use href="#i-check"></use></svg>Actualizar contraseña
            </button>
          </div>
        </form>
      </div>
    </section>
  </div>
</div>

<% rsUser.Close : Set rsUser = Nothing %>
<!--#include file="includes/footer.asp"-->

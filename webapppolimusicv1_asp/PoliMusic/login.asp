<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
If IsLoggedIn() Then
    If IsAdmin() Then
        Response.Redirect Url("admin_index.asp")
    Else
        Response.Redirect Url("index.asp")
    End If
End If

Dim errMsg, username, nextUrl, rs, sql, password, target
errMsg = ""
username = ""
nextUrl = SafeNextUrl(Request.QueryString("next"))

If IsPost() Then
    RequireCsrf
    username = Trim(Request.Form("username") & "")
    password = Request.Form("password") & ""

    If username = "" Or password = "" Then
        errMsg = "Ingresa tu usuario y contraseña."
    Else
        ' Acepta contraseñas en texto plano (datos del script SQL) y hashes SHA1.
        sql = "SELECT TOP 1 u.ID_USER, u.USERNAME, u.EMAIL, u.USER_PHOTO, u.USER_TYPE " & _
              "FROM TBL_USER u " & _
              "WHERE u.USERNAME = ? AND (u.PASSWORD = ? OR UPPER(u.PASSWORD) = " & _
              "UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2)))"

        Set rs = DbQuery(sql, Array(username, password, password))

        If rs.EOF Then
            errMsg = "Usuario o contraseña incorrectos. Verifica tus datos e inténtalo de nuevo."
            rs.Close
        Else
            SetSessionUser rs
            rs.Close

            If Len(nextUrl) > 0 Then
                target = nextUrl
            ElseIf IsAdmin() Then
                target = Url("admin_index.asp")
            Else
                target = Url("index.asp")
            End If
            Response.Redirect target
        End If
    End If
End If
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Iniciar sesión · <%=APP_NAME%></title>
<meta name="theme-color" content="#ffeee9">
<link rel="icon" type="image/svg+xml" href="<%=Url("assets/img/favicon.svg")%>">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=Url("assets/css/app.css?v=" & ASSET_VER)%>">
</head>
<body class="login-page">

<svg class="svg-sprite" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
  <symbol id="i-album" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="2.4"/><path d="M12 3v3.4M12 17.6V21M3 12h3.4M17.6 12H21"/></symbol>
  <symbol id="i-headphones" viewBox="0 0 24 24"><path d="M4 14v-2a8 8 0 0 1 16 0v2"/><rect x="3" y="13.6" width="4" height="7" rx="2"/><rect x="17" y="13.6" width="4" height="7" rx="2"/></symbol>
  <symbol id="i-admin" viewBox="0 0 24 24"><path d="M12 3 5 6v5.5c0 4.3 2.9 7.9 7 9.5 4.1-1.6 7-5.2 7-9.5V6l-7-3Z"/><path d="m9 12 2.2 2.2L15.4 10"/></symbol>
  <symbol id="i-alert" viewBox="0 0 24 24"><path d="M12 3.6 21.2 20H2.8L12 3.6Z"/><path d="M12 9.4v4.8M12 17.2h.01"/></symbol>
  <symbol id="i-eye" viewBox="0 0 24 24"><path d="M2.4 12S6 5.8 12 5.8 21.6 12 21.6 12 18 18.2 12 18.2 2.4 12 2.4 12Z"/><circle cx="12" cy="12" r="2.8"/></symbol>
  <symbol id="i-arrow-right" viewBox="0 0 24 24"><path d="M4 12h16"/><path d="m14 6 6 6-6 6"/></symbol>
</svg>

<div class="auth-wrap">
  <section class="auth-hero">
    <div class="auth-brand">
      <span class="brand-mark">
        <svg class="icon icon-fill" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M9 18.2V6.3l10-2v11.6"/><circle cx="6.4" cy="18.6" r="2.7"/><circle cx="16.4" cy="16.2" r="2.7"/>
        </svg>
      </span>
      <span class="brand-name">Poli<span>Music</span></span>
    </div>

    <h1 class="auth-title">Toda tu música.<br><span>En un solo lugar.</span></h1>
    <p class="auth-text">
      Explora álbumes, descubre artistas y reproduce tus canciones favoritas desde una
      interfaz pensada para ti. Bienvenido a <strong>PoliMusic</strong>.
    </p>

    <div class="auth-points">
      <div class="auth-point">
        <span class="ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-album"></use></svg></span>
        Portadas de álbumes y listas de canciones siempre a la mano.
      </div>
      <div class="auth-point">
        <span class="ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-headphones"></use></svg></span>
        Reproductor con play, pausa, progreso y volumen.
      </div>
      <div class="auth-point">
        <span class="ico"><svg class="icon" viewBox="0 0 24 24"><use href="#i-admin"></use></svg></span>
        Panel de administración para gestionar todo el catálogo.
      </div>
    </div>
  </section>

  <section class="auth-card">
    <h2>Inicia sesión</h2>
    <p class="sub">Accede con tu cuenta para explorar el catálogo de PoliMusic.</p>

    <% If errMsg <> "" Then %>
    <div class="alert alert-err" style="margin-top:20px;margin-bottom:0">
      <svg class="icon" viewBox="0 0 24 24"><use href="#i-alert"></use></svg>
      <span><%=H(errMsg)%></span>
    </div>
    <% End If %>

    <form class="auth-form" method="post" action="login.asp<% If nextUrl <> "" Then %>?next=<%=Server.URLEncode(nextUrl)%><% End If %>" novalidate>
      <input type="hidden" name="csrf" value="<%=A(CsrfToken())%>">

      <div class="field">
        <label for="username">Usuario</label>
        <input type="text" id="username" name="username" value="<%=A(username)%>" placeholder="Ej. userAdmin" autocomplete="username" required autofocus maxlength="50">
      </div>

      <div class="field">
        <label for="password">Contraseña</label>
        <div class="pw-wrap">
          <input type="password" id="password" name="password" placeholder="Tu contraseña" autocomplete="current-password" required maxlength="50">
          <button class="icon-btn pw-toggle" type="button" data-pw-toggle="password" aria-label="Mostrar contraseña">
            <svg class="icon" viewBox="0 0 24 24"><use href="#i-eye"></use></svg>
          </button>
        </div>
      </div>

      <button class="btn btn-primary auth-submit" type="submit">
        Entrar
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-arrow-right"></use></svg>
      </button>
    </form>

    <div class="auth-help">
      <p><strong>Cuentas de prueba</strong><br>
        Administrador: <code>userAdmin</code> / <code>12345678</code><br>
        Usuario: <code>userNormal</code> / <code>12345678</code>
      </p>
    </div>

    <p class="auth-foot"><%=APP_NAME%> · Proyecto académico · <span data-year></span></p>
  </section>
</div>

<script src="<%=Url("assets/js/app.js?v=" & ASSET_VER)%>"></script>
</body>
</html>

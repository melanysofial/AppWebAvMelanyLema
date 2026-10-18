<%
' ============================================================
'  Autenticacion y control de acceso por roles
'  USER_TYPE: 0 = Usuario normal, 1 = Administrador
'  (valores definidos en TBL_CATALOG, COD_CATALOG_PARENT = '1')
' ============================================================

Function IsLoggedIn()
    IsLoggedIn = (Len(CStr(Session("UserID") & "")) > 0)
End Function

Function IsAdmin()
    IsAdmin = (CStr(Session("UserType") & "") = "1")
End Function

Function CurrentUserId()
    If IsLoggedIn() Then
        CurrentUserId = CLng(Session("UserID"))
    Else
        CurrentUserId = 0
    End If
End Function

Sub RequireLogin()
    Dim nextUrl
    If Not IsLoggedIn() Then
        nextUrl = Request.ServerVariables("URL") & ""
        If Len(Request.ServerVariables("QUERY_STRING") & "") > 0 Then
            nextUrl = nextUrl & "?" & Request.ServerVariables("QUERY_STRING")
        End If
        Response.Redirect Url("login.asp?next=" & Server.URLEncode(nextUrl))
    End If
End Sub

Sub RequireAdmin()
    RequireLogin
    If Not IsAdmin() Then
        Response.Redirect Url("index.asp?e=denied")
    End If
End Sub

' Evita redirecciones abiertas: solo rutas internas absolutas
Function SafeNextUrl(ByVal u)
    Dim s
    s = Trim(CStr(u & ""))
    SafeNextUrl = ""
    If Len(s) = 0 Then Exit Function
    If Left(s, 1) <> "/" Then Exit Function
    If Left(s, 2) = "//" Then Exit Function
    If InStr(LCase(s), "http") > 0 Then Exit Function
    If InStr(s, "\") > 0 Then Exit Function
    If InStr(s, vbCr) > 0 Or InStr(s, vbLf) > 0 Then Exit Function
    SafeNextUrl = s
End Function

Sub SetSessionUser(ByVal rs)
    Session("UserID") = CLng(rs("ID_USER"))
    Session("Username") = CStr(rs("USERNAME") & "")
    Session("UserType") = CInt(rs("USER_TYPE"))
    Session("UserPhoto") = CStr(rs("USER_PHOTO") & "")
    Session("Email") = CStr(rs("EMAIL") & "")
    Session("RoleName") = RoleLabel(rs("USER_TYPE"))
    Session("LoginAt") = Now()
End Sub
%>

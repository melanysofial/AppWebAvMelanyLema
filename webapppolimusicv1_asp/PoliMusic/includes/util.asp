<%
' ============================================================
'  Utilidades generales: rutas, formato, seguridad, CSRF
' ============================================================

' --- Escapado seguro para HTML ---
Function H(ByVal v)
    If IsNull(v) Then
        H = ""
    ElseIf IsArray(v) Then
        H = ""
    Else
        H = Server.HTMLEncode(CStr(v))
    End If
End Function

' --- Escapado para atributos (comillas incluidas) ---
Function A(ByVal v)
    A = Replace(H(v), """", "&quot;")
End Function

' --- Raiz de la aplicacion, funciona en la raiz o en una subcarpeta ---
Function SiteRoot()
    Dim p, i
    p = Request.ServerVariables("SCRIPT_NAME") & ""
    p = Replace(p, "\", "/")
    i = InStrRev(p, "/")
    If i > 0 Then p = Left(p, i)
    If LCase(Right(p, 6)) = "admin/" Then p = Left(p, Len(p) - 6)
    If LCase(Right(p, 4)) = "api/" Then p = Left(p, Len(p) - 4)
    If Right(p, 1) <> "/" Then p = p & "/"
    SiteRoot = p
End Function

Function Url(ByVal path)
    Url = SiteRoot() & path
End Function

' --- Normaliza rutas guardadas en la BD del tipo "~/albumImages/x.png" ---
Function NormalizeRelPath(ByVal p)
    Dim s
    s = Trim(CStr(p & ""))
    s = Replace(s, "\", "/")
    Do While InStr(s, "//") > 0
        s = Replace(s, "//", "/")
    Loop
    If Left(s, 2) = "~/" Then s = Mid(s, 3)
    If Left(s, 1) = "~" Then s = Mid(s, 2)
    If Left(s, 1) = "/" Then s = Mid(s, 2)
    If InStr(s, "..") > 0 Then s = ""
    If InStr(s, ":") > 0 Then s = ""
    NormalizeRelPath = s
End Function

Function DefaultImage(ByVal kind)
    Select Case LCase(kind & "")
        Case "artist"   : DefaultImage = "assets/img/artist-default.jpg"
        Case "playlist" : DefaultImage = "assets/img/playlist-default.png"
        Case "user"     : DefaultImage = "assets/img/avatar-default.png"
        Case Else       : DefaultImage = "assets/img/cover-default.png"
    End Select
End Function

' --- URL publica de una imagen (con respaldo si viene vacia) ---
Function ImgSrc(ByVal p, ByVal kind)
    Dim s
    s = NormalizeRelPath(p)
    If s = "" Then s = DefaultImage(kind)
    ImgSrc = SiteRoot() & s
End Function

' --- URL publica de un archivo de audio ---
Function MediaSrc(ByVal p)
    Dim s
    s = NormalizeRelPath(p)
    If s = "" Then
        MediaSrc = ""
    Else
        MediaSrc = SiteRoot() & s
    End If
End Function

' --- Valida una ruta escrita por el administrador ---
Function SafePath(ByVal p, ByVal allowEmpty)
    Dim s
    s = NormalizeRelPath(p)
    If Len(s) > 255 Then s = ""
    If s = "" And Not allowEmpty Then SafePath = "" : Exit Function
    SafePath = s
End Function

Function SafeMediaPath(ByVal p)
    Dim s, ext
    s = SafePath(p, False)
    SafeMediaPath = ""
    If s = "" Then Exit Function
    ext = LCase(s)
    If Right(ext, 4) = ".mp3" Or Right(ext, 4) = ".wav" Or Right(ext, 4) = ".ogg" Or Right(ext, 5) = ".m4a" Then
        SafeMediaPath = s
    End If
End Function

' --- Iniciales para avatares/portadas sin imagen ---
Function Initials(ByVal txt)
    Dim parts, i, out, w
    txt = Trim(CStr(txt & ""))
    out = ""
    If txt = "" Then
        Initials = "PM"
        Exit Function
    End If
    parts = Split(txt, " ")
    For i = 0 To UBound(parts)
        w = Trim(parts(i))
        If Len(w) > 0 Then
            out = out & UCase(Left(w, 1))
            If Len(out) = 2 Then Exit For
        End If
    Next
    If out = "" Then out = UCase(Left(txt, 1))
    Initials = out
End Function

' --- Formatos ---
Function FmtDate(ByVal d)
    If IsNull(d) Then
        FmtDate = "—"
    ElseIf Not IsDate(d) Then
        FmtDate = "—"
    Else
        FmtDate = Right("0" & Day(d), 2) & "/" & Right("0" & Month(d), 2) & "/" & Year(d)
    End If
End Function

Function FmtDateInput(ByVal d)
    If IsNull(d) Then
        FmtDateInput = ""
    ElseIf Not IsDate(d) Then
        FmtDateInput = ""
    Else
        FmtDateInput = Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2)
    End If
End Function

Function ParseIsoDate(ByVal s)
    Dim p, y, m, d, dt
    ParseIsoDate = Null
    s = Trim(CStr(s & ""))
    If Len(s) < 10 Then Exit Function
    p = Split(Left(s, 10), "-")
    If UBound(p) <> 2 Then Exit Function
    If Not (IsNumeric(p(0)) And IsNumeric(p(1)) And IsNumeric(p(2))) Then Exit Function
    y = CInt(p(0)) : m = CInt(p(1)) : d = CInt(p(2))
    On Error Resume Next
    dt = DateSerial(y, m, d)
    If Err.Number = 0 Then
        If Year(dt) = y And Month(dt) = m And Day(dt) = d Then ParseIsoDate = dt
    End If
    Err.Clear
    On Error GoTo 0
End Function

Function Trunc(ByVal s, ByVal n)
    s = CStr(s & "")
    If Len(s) > n Then
        Trunc = Left(s, n - 1) & "…"
    Else
        Trunc = s
    End If
End Function

Function Num(ByVal v)
    If IsNull(v) Then
        Num = "0"
    Else
        Num = FormatNumber(v, 0, -1, 0, 0)
    End If
End Function

' --- Parametro LIKE seguro (escapa comodines) ---
Function LikeParam(ByVal s)
    s = Replace(CStr(s & ""), "\", "\\")
    s = Replace(s, "%", "\%")
    s = Replace(s, "_", "\_")
    s = Replace(s, "[", "\[")
    LikeParam = "%" & s & "%"
End Function

Function IntParam(ByVal v, ByVal def)
    If IsNumeric(v) Then
        IntParam = CLng(v)
    Else
        IntParam = def
    End If
End Function

Function IsPost()
    IsPost = (UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST")
End Function

' Version segura de IIf para cadenas (no evalua ambas ramas)
Function IIfStr(ByVal cond, ByVal siVerdadero, ByVal siFalso)
    If cond Then
        IIfStr = siVerdadero
    Else
        IIfStr = siFalso
    End If
End Function

Function RoleLabel(ByVal t)
    If CStr(t) = "1" Then
        RoleLabel = "Administrador"
    Else
        RoleLabel = "Usuario"
    End If
End Function

Function PlaylistTypeLabel(ByVal t)
    If CStr(t) = "1" Then
        PlaylistTypeLabel = "Privada"
    Else
        PlaylistTypeLabel = "Pública"
    End If
End Function

' --- Proteccion CSRF ---
Function CsrfToken()
    Dim t
    If Len(Session("CSRF") & "") = 0 Then
        Randomize
        t = Session.SessionID & CStr(CLng(Timer * 1000)) & CStr(Int(Rnd() * 1000000))
        t = Replace(Replace(Replace(t, "-", ""), ".", ""), " ", "")
        Session("CSRF") = t
    End If
    CsrfToken = Session("CSRF")
End Function

Sub RequireCsrf()
    Dim sent
    If Not IsPost() Then Exit Sub
    sent = Request.Form("csrf") & ""
    If Len(sent) = 0 Or Len(Session("CSRF") & "") = 0 Then
        Response.Status = "403 Forbidden"
        Response.Write "<p>Token de seguridad inválido. Recarga la página e inténtalo de nuevo.</p>"
        Response.End
    End If
    If sent <> CStr(Session("CSRF")) Then
        Response.Status = "403 Forbidden"
        Response.Write "<p>Token de seguridad inválido. Recarga la página e inténtalo de nuevo.</p>"
        Response.End
    End If
End Sub

' --- Mensajes flash por querystring ---
Function FlashHtml()
    Dim ok, er, html
    ok = LCase(Request.QueryString("ok") & "")
    er = LCase(Request.QueryString("e") & "")
    html = ""
    If ok = "saved" Then
        html = "<div class=""alert alert-ok"" data-flash><svg class=""icon""><use href=""#i-check""></use></svg><span>Los cambios se guardaron correctamente.</span></div>"
    ElseIf ok = "deleted" Then
        html = "<div class=""alert alert-ok"" data-flash><svg class=""icon""><use href=""#i-check""></use></svg><span>El registro se eliminó correctamente.</span></div>"
    End If
    If er = "denied" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>No tienes permisos para acceder a esa sección.</span></div>"
    ElseIf er = "notfound" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>El registro solicitado no existe.</span></div>"
    ElseIf er = "invalid" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>Revisa los datos ingresados e inténtalo de nuevo.</span></div>"
    ElseIf er = "exists" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>Ya existe un registro con ese nombre de usuario.</span></div>"
    ElseIf er = "self" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>No puedes eliminar tu propia cuenta mientras la estás usando.</span></div>"
    ElseIf er = "lastadmin" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>Debe existir al menos un administrador en el sistema.</span></div>"
    ElseIf er = "inuse" Then
        html = html & "<div class=""alert alert-err"" data-flash><svg class=""icon""><use href=""#i-alert""></use></svg><span>No se pudo eliminar: el registro tiene datos asociados.</span></div>"
    End If
    FlashHtml = html
End Function
%>

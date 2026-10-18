<%
' ============================================================
'  Capa de acceso a datos (ADO + SQL Server)
'  Todas las consultas usan parametros: no se concatena
'  entrada del usuario dentro del SQL.
' ============================================================

Const adCmdText      = 1
Const adParamInput   = 1
Const adVarChar      = 200
Const adVarWChar     = 202
Const adInteger      = 3
Const adDBTimeStamp  = 135
Const adBoolean      = 11
Const adOpenStatic   = 3
Const adLockReadOnly = 1
Const adUseClient    = 3

' ------------------------------------------------------------
'  Cadena de conexion. Se prueban varios proveedores OLE DB
'  para que el proyecto funcione aunque el equipo tenga
'  instalado MSOLEDBSQL, SQLNCLI11 o el antiguo SQLOLEDB.
' ------------------------------------------------------------
Function DbConnString(ByVal idx)
    Dim s
    Select Case idx
        Case 0
            s = "Provider=MSOLEDBSQL;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
                ";UID=" & DB_USER & ";PWD=" & DB_PASS & _
                ";Encrypt=Mandatory;TrustServerCertificate=Yes;"
        Case 1
            s = "Provider=MSOLEDBSQL;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
                ";UID=" & DB_USER & ";PWD=" & DB_PASS & _
                ";Encrypt=Optional;TrustServerCertificate=Yes;"
        Case 2
            s = "Provider=SQLNCLI11;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
                ";UID=" & DB_USER & ";PWD=" & DB_PASS & ";Encrypt=no;"
        Case Else
            s = "Provider=SQLOLEDB;Server=" & DB_SERVER & ";Database=" & DB_NAME & _
                ";UID=" & DB_USER & ";PWD=" & DB_PASS & ";"
    End Select
    DbConnString = s
End Function

Function OpenConn()
    Dim cached, conn, i, lastErr
    cached = ""

    On Error Resume Next
    cached = Application("POLIMUSIC_CONN")
    On Error GoTo 0

    If Len(cached & "") > 0 Then
        On Error Resume Next
        Set conn = Server.CreateObject("ADODB.Connection")
        conn.ConnectionTimeout = 8
        conn.Open cached
        If Err.Number = 0 Then
            On Error GoTo 0
            Set OpenConn = conn
            Exit Function
        End If
        Err.Clear
        On Error GoTo 0
        Application.Lock
        Application("POLIMUSIC_CONN") = ""
        Application.Unlock
    End If

    lastErr = ""
    For i = 0 To 3
        On Error Resume Next
        Set conn = Server.CreateObject("ADODB.Connection")
        conn.ConnectionTimeout = 8
        conn.Open DbConnString(i)
        If Err.Number = 0 Then
            On Error GoTo 0
            Application.Lock
            Application("POLIMUSIC_CONN") = DbConnString(i)
            Application.Unlock
            Set OpenConn = conn
            Exit Function
        End If
        lastErr = Err.Description
        Err.Clear
        On Error GoTo 0
    Next

    Response.Clear
    Response.Write "<!DOCTYPE html><html lang=""es""><head><meta charset=""utf-8"">"
    Response.Write "<title>PoliMusic - Error de conexion</title>"
    Response.Write "<style>body{font-family:Segoe UI,Arial,sans-serif;background:#070b14;color:#eaf0ff;"
    Response.Write "display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:24px}"
    Response.Write ".box{max-width:620px;background:#101a2e;border:1px solid #22314f;border-radius:18px;padding:32px}"
    Response.Write "h1{margin:0 0 12px;font-size:22px}p{color:#9db0d0;line-height:1.6}"
    Response.Write "code{background:#0a1120;padding:3px 7px;border-radius:6px;color:#7cc4ff}</style></head><body>"
    Response.Write "<div class=""box""><h1>No se pudo conectar con SQL Server</h1>"
    Response.Write "<p>Revisa que el servicio de SQL Server este activo, que la base <code>BDD_PoliMusic</code> exista "
    Response.Write "y que las credenciales de <code>includes/config.asp</code> sean correctas.</p>"
    Response.Write "<p><strong>Detalle tecnico:</strong> " & Server.HTMLEncode(lastErr) & "</p></div></body></html>"
    Response.End
End Function

' ------------------------------------------------------------
'  Parametros tipados
' ------------------------------------------------------------
Function NewParam(ByVal cmd, ByVal v)
    Dim p
    If IsNull(v) Then
        Set p = cmd.CreateParameter("p", adVarWChar, adParamInput, 1)
        p.Value = Null
    ElseIf VarType(v) = vbInteger Or VarType(v) = vbLong Then
        Set p = cmd.CreateParameter("p", adInteger, adParamInput)
        p.Value = CLng(v)
    ElseIf VarType(v) = vbDate Then
        Set p = cmd.CreateParameter("p", adDBTimeStamp, adParamInput)
        p.Value = v
    ElseIf VarType(v) = vbBoolean Then
        Set p = cmd.CreateParameter("p", adBoolean, adParamInput)
        p.Value = v
    Else
        Set p = cmd.CreateParameter("p", adVarWChar, adParamInput, 4000)
        p.Value = CStr(v)
    End If
    Set NewParam = p
End Function

Function ParamCount(ByVal aParams)
    Dim n
    n = -1
    If IsArray(aParams) Then
        On Error Resume Next
        n = UBound(aParams)
        If Err.Number <> 0 Then n = -1
        Err.Clear
        On Error GoTo 0
    End If
    ParamCount = n
End Function

' Acepta un arreglo, un escalar o Empty y devuelve siempre un arreglo
Function NormalizeParams(ByVal p)
    If IsArray(p) Then
        NormalizeParams = p
    ElseIf IsEmpty(p) Then
        NormalizeParams = Array()
    ElseIf IsNull(p) Then
        NormalizeParams = Array()
    Else
        NormalizeParams = Array(p)
    End If
End Function

' ------------------------------------------------------------
'  Consulta -> Recordset desconectado (el llamador debe cerrarlo)
' ------------------------------------------------------------
Function DbQueryArr(ByVal sSql, ByVal aParams)
    Dim conn, cmd, rs, i, n
    aParams = NormalizeParams(aParams)

    Set conn = OpenConn()
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = adCmdText
    cmd.CommandText = sSql

    n = ParamCount(aParams)
    For i = 0 To n
        cmd.Parameters.Append NewParam(cmd, aParams(i))
    Next

    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.CursorLocation = adUseClient
    rs.Open cmd, , adOpenStatic, adLockReadOnly
    Set rs.ActiveConnection = Nothing

    conn.Close
    Set cmd = Nothing
    Set conn = Nothing
    Set DbQueryArr = rs
End Function

' ------------------------------------------------------------
'  API publica: (sql, arreglo de parametros)
' ------------------------------------------------------------
Function DbQuery(ByVal sSql, ByVal aParams)
    Set DbQuery = DbQueryArr(sSql, aParams)
End Function

Function DbScalar(ByVal sSql, ByVal aParams)
    Dim rs, v
    Set rs = DbQueryArr(sSql, aParams)
    v = Null
    If Not rs.EOF Then v = rs(0)
    rs.Close
    Set rs = Nothing
    DbScalar = v
End Function

Function DbExecArr(ByVal sSql, ByVal aParams)
    Dim conn, cmd, i, n, affected
    aParams = NormalizeParams(aParams)

    Set conn = OpenConn()
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = adCmdText
    cmd.CommandText = sSql

    n = ParamCount(aParams)
    For i = 0 To n
        cmd.Parameters.Append NewParam(cmd, aParams(i))
    Next

    affected = 0
    cmd.Execute affected
    conn.Close
    Set cmd = Nothing
    Set conn = Nothing
    DbExecArr = affected
End Function

Function DbExec(ByVal sSql, ByVal aParams)
    DbExec = DbExecArr(sSql, aParams)
End Function

Function DbCount(ByVal sSql, ByVal aParams)
    Dim rs, v
    Set rs = DbQueryArr(sSql, aParams)
    v = Null
    If Not rs.EOF Then v = rs(0)
    rs.Close
    Set rs = Nothing
    If IsNull(v) Then
        DbCount = 0
    Else
        DbCount = CLng(v)
    End If
End Function
%>
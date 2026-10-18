<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

If Not IsLoggedIn() Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""ok"":false,""error"":""auth""}"
    Response.End
End If

If Not IsPost() Then
    Response.Status = "405 Method Not Allowed"
    Response.Write "{""ok"":false,""error"":""method""}"
    Response.End
End If

If (Request.Form("csrf") & "") <> CStr(Session("CSRF") & "") Then
    Response.Status = "403 Forbidden"
    Response.Write "{""ok"":false,""error"":""csrf""}"
    Response.End
End If

Dim songId, plays
songId = IntParam(Request.Form("id"), 0)
If songId <= 0 Then
    Response.Status = "400 Bad Request"
    Response.Write "{""ok"":false,""error"":""id""}"
    Response.End
End If

plays = DbScalar("UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 OUTPUT INSERTED.PLAYS WHERE ID_SONG = ?", Array(songId))

If IsNull(plays) Then
    Response.Status = "404 Not Found"
    Response.Write "{""ok"":false,""error"":""notfound""}"
Else
    Response.Write "{""ok"":true,""plays"":" & CLng(plays) & "}"
End If
%>

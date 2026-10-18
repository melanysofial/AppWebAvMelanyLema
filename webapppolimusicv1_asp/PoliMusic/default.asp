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
Else
    Response.Redirect Url("login.asp")
End If
%>

<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/config.asp"-->
<!--#include file="includes/db.asp"-->
<!--#include file="includes/util.asp"-->
<!--#include file="includes/auth.asp"-->
<%
' Cierre de sesión: se eliminan los datos y se abandona la sesión
Session.Contents.RemoveAll
Session.Abandon
Response.Redirect Url("login.asp")
%>

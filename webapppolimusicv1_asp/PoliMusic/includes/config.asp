<%
' ============================================================
'  PoliMusic - Configuracion general
'  Proyecto: Clon de Spotify (tema azul) en ASP clasico
' ============================================================

Response.Buffer = True
Response.CodePage = 65001
Response.Charset = "utf-8"
Session.CodePage = 65001
Session.Timeout = 90

Response.AddHeader "X-Content-Type-Options", "nosniff"
Response.AddHeader "X-Frame-Options", "SAMEORIGIN"
Response.AddHeader "Referrer-Policy", "same-origin"

' --- Identidad de la aplicacion ---
Const APP_NAME = "PoliMusic"
Const APP_TAGLINE = "Tu musica, en azul."
Const ASSET_VER = "1.0.0"

' --- Conexion a SQL Server (usuario de la base BDD_PoliMusic) ---
Const DB_SERVER = "localhost"
Const DB_NAME   = "BDD_PoliMusic"
Const DB_USER   = "usr_polimusic"
Const DB_PASS   = "Politecnica1"

' Almacenamiento de la contrasena para NUEVOS usuarios:
'   "sha1"  -> guarda el hash SHA1 (recomendado)
'   "plain" -> guarda el texto tal cual (compatible con los datos de ejemplo)
' El login SIEMPRE acepta ambos formatos, por lo que las cuentas
' creadas por el script SQL siguen funcionando sin cambios.
Const PWD_MODE = "sha1"

' Minimo de caracteres para una contrasena nueva
Const PWD_MIN_LEN = 6
%>

# PoliMusic · Clon de Spotify en ASP clásico

Aplicación web tipo Spotify con tema azul, desarrollada en **ASP clásico (VBScript)** sobre
**SQL Server**. Usa exclusivamente las tablas y relaciones que ya existen en la base
`BDD_PoliMusic`; no se crearon tablas nuevas ni se cambió la tecnología.

---

## Características

- **Login real contra la base de datos** con sesión y cierre de sesión.
- **Dos roles**: administrador (`USER_TYPE = 1`) y usuario normal (`USER_TYPE = 0`),
  tomados de `TBL_CATALOG` (catálogo `USER TYPE`).
- **CRUD completo para el administrador**: usuarios, canciones, artistas, álbumes y playlists.
- **Usuario normal en modo lectura**: reproduce canciones y consulta álbumes, artistas,
  playlists públicas y su propio perfil.
- **Reproductor global** con play/pausa, anterior/siguiente, barra de progreso, volumen,
  aleatorio, repetición, cola de reproducción y persistencia entre páginas.
- **Buscador** de canciones, artistas y álbumes.
- **Portadas de álbumes**, retratos de artistas, avatares y listas de canciones.
- **Diseño responsive** para computadora, tableta y celular.
- **Seguridad**: consultas parametrizadas, tokens CSRF, escapado de salida y control de acceso
  en cada página.

---

## Requisitos

| Componente | Detalle |
|---|---|
| Servidor web | IIS con la característica **ASP** habilitada |
| Base de datos | SQL Server 2016 o superior (probado en SQL Server 2025) |
| Proveedor OLE DB | `MSOLEDBSQL` (recomendado), `SQLNCLI11` o `SQLOLEDB` |
| Navegador | Chrome, Edge, Firefox o Safari actuales |

La capa de datos prueba automáticamente los tres proveedores OLE DB, por lo que funciona
aunque el equipo no tenga instalado el más moderno.

---

## Instalación

1. **Crear la base de datos**
   Abre `BDD_PoliMusic.sql` en SQL Server Management Studio y ejecútalo.
   > ⚠️ El script hace `DROP DATABASE IF EXISTS [BDD_PoliMusic]`: **elimina y vuelve a crear
   > la base**. Ejecútalo solo si estás de acuerdo con perder los datos actuales.

2. **Verificar el login SQL**
   El script crea `usr_polimusic` con contraseña `Politecnica1` y lo agrega a `db_owner`.
   Si tu instancia ya tenía ese login, revisa que la contraseña coincida con
   `includes/config.asp`.

3. **Publicar la aplicación**
   Copia la carpeta completa a `C:\inetpub\wwwroot\PoliMusic` o crea una aplicación IIS
   apuntando a esta carpeta.

4. **Habilitar ASP clásico**
   Panel de control → Programas → Activar o desactivar características de Windows →
   Internet Information Services → World Wide Web Services → Application Development
   Features → **ASP**.

5. **Grupo de aplicaciones**
   Se recomienda un grupo con **.NET CLR Version = No Managed Code** y canalización
   integrada. ASP clásico no depende de .NET, pero así se evitan conflictos.

6. **Permisos**
   Da permiso de **lectura** a `IIS_IUSRS` sobre la carpeta del proyecto.

7. **Abrir en el navegador**
   `http://localhost/PoliMusic/` (o la URL de tu sitio). `default.asp` redirige al login
   o al inicio según la sesión.

> **Nota sobre rutas:** todas las páginas están en la raíz de la aplicación y los `include`
> usan rutas relativas sin `..`. Esto evita depender de la opción *Enable Parent Paths*,
> que IIS desactiva por defecto. Por eso las páginas de administración se llaman
> `admin_*.asp` y no viven en una subcarpeta.

---

## Configuración

Todo se ajusta en **`includes/config.asp`**:

```asp
Const DB_SERVER = "localhost"
Const DB_NAME   = "BDD_PoliMusic"
Const DB_USER   = "usr_polimusic"
Const DB_PASS   = "Politecnica1"

' "sha1"  -> los usuarios nuevos se guardan con hash SHA1
' "plain" -> se guarda el texto tal cual (como los datos de ejemplo del script)
Const PWD_MODE = "sha1"
```

- El **login acepta ambos formatos** (texto plano y SHA1), por lo que las cuentas creadas
  por el script SQL siguen funcionando sin cambios.
- Si editas un usuario y dejas la contraseña vacía, se conserva la actual.
- `ASSET_VER` permite invalidar la caché de CSS/JS al publicar cambios.

---

## Credenciales de prueba

| Rol | Usuario | Contraseña |
|---|---|---|
| Administrador | `userAdmin` | `12345678` |
| Usuario normal | `userNormal` | `12345678` |
| Usuario normal | `username1` | `12345678` (guardada como SHA1 en el script) |

> El script original no incluye el usuario `epn.fis`. Si lo necesitas, puedes crearlo desde
> **Administración → Usuarios → Nuevo usuario** (rol Usuario), o ejecutar:
>
> ```sql
> INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
> VALUES ('epn.fis', CONVERT(varchar(40), HASHBYTES('SHA1', '12345678'), 2),
>         'epn.fis@epn.edu.ec', '2000-01-01', '~/userImages/default.jpg', 0);
> ```

---

## Permisos por rol

| Acción | Administrador | Usuario normal |
|---|:---:|:---:|
| Iniciar / cerrar sesión | ✅ | ✅ |
| Ver inicio, álbumes, artistas, playlists públicas | ✅ | ✅ |
| Reproducir canciones | ✅ | ✅ |
| Buscar | ✅ | ✅ |
| Editar su propio perfil y contraseña | ✅ | ✅ |
| Ver playlists privadas ajenas | ✅ | ❌ |
| CRUD de usuarios | ✅ | ❌ |
| CRUD de canciones | ✅ | ❌ |
| CRUD de artistas | ✅ | ❌ |
| CRUD de álbumes y tracklists | ✅ | ❌ |
| CRUD de playlists | ✅ | ❌ |

Las páginas `admin_*.asp` llaman a `RequireAdmin`; si un usuario normal intenta abrirlas
por URL, se le redirige al inicio con un aviso. Las páginas públicas llaman a
`RequireLogin`.

---

## Estructura del proyecto

```
PoliMusic/
├── default.asp              Redirección inicial según sesión
├── login.asp                Login (standalone)
├── logout.asp               Cierre de sesión
├── index.asp                Inicio: hero, playlists, álbumes, top canciones
├── albums.asp / album.asp   Catálogo y detalle de álbum con tracklist
├── artists.asp / artist.asp Catálogo y detalle de artista
├── playlists.asp / playlist.asp
├── search.asp               Búsqueda de canciones, artistas y álbumes
├── profile.asp              Perfil y cambio de contraseña
├── admin_index.asp          Panel con estadísticas
├── admin_users.asp          CRUD de usuarios
├── admin_songs.asp          CRUD de canciones + artistas (TBL_PLAYER)
├── admin_artists.asp        CRUD de artistas
├── admin_albums.asp         CRUD de álbumes + tracklist (TBL_TRACKLIST)
├── admin_playlists.asp      CRUD de playlists + canciones (TBL_PLAYLIST_SONG)
├── admin_tabs.asp           Pestañas compartidas del panel
├── api_play.asp             API JSON que incrementa PLAYS
├── includes/
│   ├── config.asp           Constantes y conexión
│   ├── db.asp               Capa ADO parametrizada
│   ├── util.asp             Rutas, formato, CSRF, mensajes
│   ├── auth.asp             Sesión y control de roles
│   ├── header.asp           Layout: sidebar, topbar, sprite SVG
│   ├── footer.asp           Reproductor global y scripts
│   └── trackrow.asp         Fila reutilizable de canción
├── assets/
│   ├── css/app.css          Tema azul, responsive
│   ├── js/app.js            Menú, avisos, utilidades
│   ├── js/player.js         Reproductor global
│   └── img/                 Logo, favicon y respaldos
├── albumImages/             Portadas
├── ArtistImages/            Retratos
├── playlistImages/          Portadas de playlists
├── userImages/              Avatares
├── songFiles/               Pistas de audio
├── web.config               Documento por defecto y MIME de audio
├── BDD_PoliMusic.sql        Script original de la base
└── README.md
```

---

## Tablas utilizadas

| Tabla | Uso en la aplicación |
|---|---|
| `TBL_USER` | Login, roles, CRUD de usuarios, perfil |
| `TBL_SONG` | Canciones, ruta del audio, reproducciones |
| `TBL_ARTIST` | Artistas e imágenes |
| `TBL_ALBUM` | Álbumes, año y portada |
| `TBL_TRACKLIST` | Canciones que pertenecen a cada álbum |
| `TBL_PLAYER` | Relación canción–artista (varios artistas por canción) |
| `TBL_PLAYLIST` | Playlists, dueño, tipo y portada |
| `TBL_PLAYLIST_SONG` | Canciones de cada playlist |
| `TBL_CATALOG` | Roles (`USER TYPE`) y visibilidad (`PLAYLIST TYPE`) |

No se agregó ninguna tabla, columna ni relación.

---

## Cómo funciona

### Autenticación

La consulta de login es parametrizada y acepta contraseñas en texto plano o SHA1:

```sql
SELECT TOP 1 u.ID_USER, u.USERNAME, u.EMAIL, u.USER_PHOTO, u.USER_TYPE
FROM TBL_USER u
WHERE u.USERNAME = ?
  AND (u.PASSWORD = ?
       OR UPPER(u.PASSWORD) = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', CAST(? AS varchar(50))), 2)))
```

Al validar, se guardan en sesión `UserID`, `Username`, `UserType`, `UserPhoto`, `Email` y
`RoleName`. El administrador entra al panel; el usuario normal entra al inicio.

### CRUD y relaciones

- **Canción**: al guardar se reconstruyen sus filas en `TBL_PLAYER` según los artistas
  marcados.
- **Álbum**: al guardar se reconstruye `TBL_TRACKLIST`.
- **Playlist**: al guardar se reconstruye `TBL_PLAYLIST_SONG`.
- **Borrados**: se eliminan primero las filas relacionadas dentro de una transacción
  (`SET XACT_ABORT ON; BEGIN TRAN … COMMIT`), evitando errores de clave foránea.
- **Usuarios**: no se permite eliminarse a uno mismo ni dejar el sistema sin administradores.

### Reproductor

`assets/js/player.js` mantiene una cola global. Al pulsar una fila o **Reproducir todo**,
se arma la cola con las filas de esa lista y se reproduce con `<audio>`. El estado
(canción, posición, volumen, aleatorio, repetición) se guarda en `sessionStorage`, por lo
que la música continúa al navegar entre páginas.

Cada inicio de reproducción llama a `api_play.asp`, que incrementa `TBL_SONG.PLAYS` y
devuelve el nuevo valor en JSON. La API exige sesión, método POST y token CSRF.

### Búsqueda

`search.asp` usa `LIKE` con parámetros y escape de comodines (`ESCAPE '\'`). Busca en
`SONG_NAME`, `ARTIST_NAME`/`ARTIST_LASTNAME` y `TITLE_ALBUM`.

---

## Seguridad implementada

- **Consultas parametrizadas** en toda la capa ADO (`ADODB.Command`), sin concatenar entrada
  del usuario.
- **CSRF**: token por sesión en todos los formularios POST; se valida en el servidor.
- **Escapado HTML** de todos los valores mostrados (`Server.HTMLEncode`).
- **Control de acceso** centralizado en `includes/auth.asp`.
- **Rutas de archivos** normalizadas y validadas (sin `..`, sin URLs externas).
- **Contraseñas**: SHA1 para usuarios nuevos y compatibilidad con texto plano del script.
- **Playlists privadas**: solo visibles para su dueño o un administrador.
- **Redirección `next`** validada para evitar redirecciones abiertas.
- **Cabeceras** `X-Content-Type-Options`, `X-Frame-Options` y `Referrer-Policy`.

---

## Multimedia de demostración

- Las **5 canciones** de `songFiles/` son pistas instrumentales originales sintetizadas
  para esta demo, con los mismos nombres de archivo que usa el script SQL
  (`bensound-adventure.mp3`, etc.). Se pueden reemplazar por archivos reales manteniendo
  la ruta, o cambiar la ruta desde **Administración → Canciones**.
- Las **portadas, retratos y avatares** fueron generados para el proyecto y están en
  `albumImages/`, `ArtistImages/`, `playlistImages/` y `userImages/`.
- Para agregar imágenes nuevas, copia el archivo dentro del sitio y escribe su ruta
  relativa (por ejemplo `~/albumImages/mi-portada.png`) en el formulario correspondiente.

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| “No se pudo conectar con SQL Server” | Servicio detenido, base inexistente o credenciales incorrectas | Verifica el servicio, ejecuta el script y revisa `includes/config.asp` |
| Error 500.19 al abrir el sitio | IIS bloquea alguna sección de `web.config` | Elimina el bloque `<staticContent>` de `web.config`; los MIME de audio suelen estar ya definidos |
| Las páginas de administración dan 404 | Se movieron a una subcarpeta | Usa las rutas `admin_index.asp`, `admin_users.asp`, etc. |
| Imágenes rotas | Ruta o nombre de archivo incorrecto | Revisa mayúsculas/minúsculas y que el archivo exista; hay imagen de respaldo automática |
| El audio no suena | Archivo inexistente o formato no permitido | Verifica `songFiles/`, usa `.mp3`, `.wav`, `.ogg` o `.m4a` |
| El login dice “incorrectos” | Usuario/contraseña distintos o `PWD_MODE` | Prueba `userAdmin / 12345678`; revisa la fila en `TBL_USER` |
| Error de compilación VBScript | Se editó un archivo con sintaxis inválida | Revisa la línea indicada por IIS; el proyecto original compila sin errores |

---

## Pruebas realizadas

El proyecto fue ejecutado en **IIS Express + SQL Server** y se verificó:

- Login de administrador y usuario normal, redirección por rol y cierre de sesión.
- Bloqueo de `admin_*.asp` para usuarios normales y para sesiones anónimas.
- CRUD de usuarios, canciones, artistas, álbumes y playlists, incluyendo asociaciones
  (`TBL_PLAYER`, `TBL_TRACKLIST`, `TBL_PLAYLIST_SONG`) y borrados sin filas huérfanas.
- Reproductor: play, pausa, siguiente, progreso, volumen y persistencia al navegar.
- Botón **Reproducir todo**, búsqueda, filtros y formularios con validación.
- Rechazo de POST sin token CSRF y de la API sin sesión.
- Diseño responsive en escritorio y móvil.

---

## Créditos

Proyecto académico desarrollado con ASP clásico y SQL Server. **PoliMusic** es un clon
educativo y no está afiliado a Spotify. Las pistas de audio incluidas son originales y
solo se usan como demostración.

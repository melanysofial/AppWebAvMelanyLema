<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== Song.aspx — Estilo Spotify Rosa/Blanco Glassmorphism ===== -->

    <style>
        /* ---------- Variables de color ---------- */
        :root {
            --pink-primary: #ff6b9d;
            --pink-light: #ffc3da;
            --pink-dark: #e84a7f;
            --pink-soft: #ffe4ef;
            --white-glass: rgba(255, 255, 255, 0.55);
            --white-glass-strong: rgba(255, 255, 255, 0.75);
            --white-border: rgba(255, 255, 255, 0.6);
            --pink-glass: rgba(255, 200, 221, 0.35);
            --pink-glass-border: rgba(255, 107, 157, 0.3);
            --text-dark: #6b2147;
            --text-medium: #9c4b6f;
            --text-light: #c97ba0;
            --shadow-pink: rgba(255, 107, 157, 0.2);
            --bg-gradient-start: #ffe4ef;
            --bg-gradient-end: #fff5f8;
        }

        /* ---------- Fondo general ---------- */
        .song-page-wrapper {
            min-height: 100vh;
            margin: -20px -15px 0 -15px;
            padding: 0;
            background: linear-gradient(135deg, var(--bg-gradient-start) 0%, var(--bg-gradient-end) 40%, #ffd6e7 100%);
            position: relative;
            font-family: 'Segoe UI', 'Helvetica Neue', sans-serif;
        }

        /* Burbujas decorativas de fondo */
        .song-page-wrapper::before,
        .song-page-wrapper::after {
            content: '';
            position: absolute;
            border-radius: 50%;
            filter: blur(60px);
            opacity: 0.4;
            z-index: 0;
        }
        .song-page-wrapper::before {
            width: 350px;
            height: 350px;
            background: var(--pink-primary);
            top: -80px;
            right: -60px;
        }
        .song-page-wrapper::after {
            width: 300px;
            height: 300px;
            background: var(--pink-light);
            bottom: 50px;
            left: -80px;
        }

        .song-content {
            position: relative;
            z-index: 1;
            padding: 30px 40px 120px 40px;
        }

        /* ---------- Header: saludo al usuario ---------- */
        .song-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
        }

        .song-greeting {
            background: var(--white-glass);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--white-border);
            border-radius: 16px;
            padding: 14px 24px;
            box-shadow: 0 4px 15px var(--shadow-pink);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .song-greeting .greeting-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--pink-primary), var(--pink-dark));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: white;
            box-shadow: 0 2px 8px var(--shadow-pink);
        }

        .song-greeting .greeting-text {
            font-size: 15px;
            color: var(--text-dark);
        }

        .song-greeting .greeting-text strong {
            color: var(--pink-dark);
            font-size: 17px;
        }

        .song-title-badge {
            background: linear-gradient(135deg, var(--pink-primary), var(--pink-dark));
            color: white;
            padding: 10px 22px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            box-shadow: 0 4px 12px var(--shadow-pink);
        }

        /* ---------- Hero section ---------- */
        .song-hero {
            background: var(--white-glass);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--white-border);
            border-radius: 24px;
            padding: 36px 40px;
            margin-bottom: 24px;
            box-shadow: 0 8px 30px var(--shadow-pink);
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .song-hero .hero-icon {
            width: 90px;
            height: 90px;
            border-radius: 22px;
            background: linear-gradient(135deg, var(--pink-primary), var(--pink-dark));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 44px;
            flex-shrink: 0;
            box-shadow: 0 6px 20px var(--shadow-pink);
        }

        .song-hero .hero-text h1 {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0 0 6px 0;
        }

        .song-hero .hero-text p {
            font-size: 15px;
            color: var(--text-medium);
            margin: 0;
        }

        /* ---------- Tabla de canciones (glassmorphism) ---------- */
        .songs-table-container {
            background: var(--white-glass);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border: 1px solid var(--white-border);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 6px 25px var(--shadow-pink);
            overflow: hidden;
        }

        .songs-table-container .table-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding-bottom: 14px;
            border-bottom: 2px solid var(--pink-glass-border);
        }

        .songs-table-container .table-header h2 {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0;
        }

        .songs-table-container .table-header .song-count {
            background: var(--pink-soft);
            color: var(--pink-dark);
            padding: 3px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        /* GridView personalizado */
        .gridview-pink {
            width: 100% !important;
            border-collapse: separate !important;
            border-spacing: 0 8px !important;
        }

        .gridview-pink thead th {
            background: var(--pink-glass) !important;
            backdrop-filter: blur(8px);
            color: var(--text-dark) !important;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 12px 16px !important;
            border: 1px solid var(--pink-glass-border) !important;
        }

        .gridview-pink thead th:first-child {
            border-top-left-radius: 12px;
            border-bottom-left-radius: 12px;
        }

        .gridview-pink thead th:last-child {
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }

        .gridview-pink tbody tr {
            background: var(--white-glass-strong) !important;
            transition: all 0.3s ease;
        }

        .gridview-pink tbody tr:hover {
            background: rgba(255, 200, 221, 0.6) !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px var(--shadow-pink);
        }

        .gridview-pink tbody td {
            padding: 12px 16px !important;
            border-top: 1px solid var(--white-border) !important;
            border-bottom: 1px solid var(--white-border) !important;
            color: var(--text-dark) !important;
            font-size: 14px;
        }

        .gridview-pink tbody td:first-child {
            border-left: 1px solid var(--white-border) !important;
            border-top-left-radius: 12px;
            border-bottom-left-radius: 12px;
        }

        .gridview-pink tbody td:last-child {
            border-right: 1px solid var(--white-border) !important;
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }

        /* Boton de reproducir en el grid */
        .btn-play-song {
            background: linear-gradient(135deg, var(--pink-primary), var(--pink-dark));
            color: white;
            border: none;
            padding: 8px 18px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 3px 10px var(--shadow-pink);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-play-song:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 18px var(--shadow-pink);
        }

        .btn-play-song.playing {
            background: linear-gradient(135deg, #c2185b, #880e4f);
        }

        /* Columna de numero/indice */
        .song-index {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: var(--pink-soft);
            color: var(--pink-dark);
            font-weight: 700;
            font-size: 13px;
        }

        /* ---------- Reproductor de audio (barra inferior fija) ---------- */
        .audio-player-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: var(--white-glass-strong);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-top: 1px solid var(--pink-glass-border);
            padding: 14px 30px;
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 -6px 25px var(--shadow-pink);
        }

        .audio-player-bar .now-playing-info {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 200px;
        }

        .audio-player-bar .now-playing-info .np-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--pink-primary), var(--pink-dark));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            color: white;
            box-shadow: 0 3px 10px var(--shadow-pink);
        }

        .audio-player-bar .now-playing-info .np-text {
            display: flex;
            flex-direction: column;
        }

        .audio-player-bar .now-playing-info .np-label {
            font-size: 11px;
            color: var(--text-light);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .audio-player-bar .now-playing-info .np-title {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-dark);
        }

        .audio-player-bar audio {
            flex: 1;
            height: 38px;
            border-radius: 20px;
        }

        .audio-player-bar audio::-webkit-media-controls-panel {
            background: var(--pink-soft);
        }

        /* ---------- Empty state ---------- */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-light);
        }

        .empty-state .empty-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        .empty-state p {
            font-size: 16px;
        }

        /* ---------- Responsive ---------- */
        @@media (max-width: 768px) {
            .song-content {
                padding: 20px 15px 120px 15px;
            }
            .song-hero {
                flex-direction: column;
                text-align: center;
                padding: 24px 20px;
            }
            .song-hero .hero-icon {
                width: 64px;
                height: 64px;
                font-size: 32px;
            }
            .song-hero .hero-text h1 {
                font-size: 24px;
            }
            .gridview-pink {
                font-size: 12px;
            }
            .audio-player-bar {
                padding: 10px 15px;
            }
            .audio-player-bar .now-playing-info {
                min-width: 140px;
            }
            .audio-player-bar .now-playing-info .np-icon {
                width: 36px;
                height: 36px;
                font-size: 16px;
            }
        }
    </style>

    <div class="song-page-wrapper">
        <div class="song-content">

            <!-- Header: saludo al usuario autenticado -->
            <div class="song-header">
                <div class="song-greeting">
                    <div class="greeting-icon">&#127892;</div>
                    <div class="greeting-text">
                        Bienvenida/o, <strong><asp:Label ID="lblUserName" runat="server" Text="Invitado"></asp:Label></strong>
                    </div>
                </div>
                <div class="song-title-badge">&#127925; PoliMusic Player</div>
            </div>

            <!-- Hero section -->
            <div class="song-hero">
                <div class="hero-icon">&#127925;</div>
                <div class="hero-text">
                    <h1>Tus Canciones</h1>
                    <p>Explora y reproduce tu coleccion de musica. Selecciona una cancion para empezar a escuchar.</p>
                </div>
            </div>

            <!-- Tabla de canciones con GridView -->
            <div class="songs-table-container">
                <div class="table-header">
                    <h2>&#9835; Lista de Canciones</h2>
                    <span class="song-count"><asp:Label ID="lblSongCount" runat="server" Text="0"></asp:Label> canciones</span>
                </div>

                <asp:GridView ID="gvSongs" runat="server"
                    AutoGenerateColumns="false"
                    CssClass="gridview-pink"
                    GridLines="None"
                    ShowHeader="true"
                    OnRowCommand="gvSongs_RowCommand"
                    EmptyDataText="No hay canciones disponibles.">
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span class="song-index"><%# Container.DataItemIndex + 1 %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ID_SONG" HeaderText="ID" ItemStyle-Width="60px" Visible="false" />
                        <asp:BoundField DataField="SONG_NAME" HeaderText="Cancion" ItemStyle-Width="300px" />
                        <asp:BoundField DataField="PLAYS" HeaderText="Reproducciones" ItemStyle-Width="140px" ItemStyle-HorizontalAlign="Center" />
                        <asp:TemplateField HeaderText="Accion" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnPlay" runat="server"
                                    CssClass="btn-play-song"
                                    CommandName="PlaySong"
                                    CommandArgument='<%# Eval("ID_SONG") + ";" + Eval("SONG_NAME") + ";" + Eval("SONG_PATH") %>'>
                                    &#9654; Reproducir
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

    <!-- Barra reproductora de audio fija en la parte inferior -->
    <div class="audio-player-bar" id="playerBar" style="display:none;">
        <div class="now-playing-info">
            <div class="np-icon">&#127925;</div>
            <div class="np-text">
                <span class="np-label">Reproduciendo ahora</span>
                <span class="np-title" id="nowPlayingTitle">--</span>
            </div>
        </div>
        <audio id="audioPlayer" controls autoplay></audio>
    </div>

    <!-- Hidden field para pasar la URL de la cancion desde el servidor al cliente -->
    <asp:HiddenField ID="hfSongUrl" runat="server" />
    <asp:HiddenField ID="hfSongTitle" runat="server" />

    <script type="text/javascript">
        // Mostrar el reproductor y cargar la cancion cuando se selecciona
        function playSong(songUrl, songTitle) {
            var playerBar = document.getElementById('playerBar');
            var audioPlayer = document.getElementById('audioPlayer');
            var titleSpan = document.getElementById('nowPlayingTitle');

            titleSpan.textContent = songTitle;
            audioPlayer.src = songUrl;
            audioPlayer.play();

            playerBar.style.display = 'flex';
        }

        // Al cargar la pagina, si hay una URL pendiente, reproducir
        window.onload = function () {
            var hfUrl = document.getElementById('<%= hfSongUrl.ClientID %>');
            var hfTitle = document.getElementById('<%= hfSongTitle.ClientID %>');
            if (hfUrl && hfUrl.value && hfUrl.value !== '') {
                playSong(hfUrl.value, hfTitle.value);
            }
        };
    </script>

</asp:Content>

    </main>
  </div>
</div>

<div class="player is-empty" id="player" aria-label="Reproductor de música">
  <div class="player-now">
    <div class="player-cover" id="plCoverWrap">
      <img id="plCover" src="<%=Url("assets/img/cover-default.png")%>" alt="">
      <span class="player-cover-ph"><svg class="icon" viewBox="0 0 24 24"><use href="#i-music"></use></svg></span>
    </div>
    <div class="player-meta">
      <span class="player-title" id="plTitle">Nada reproduciéndose</span>
      <span class="player-artist" id="plArtist">Elige una canción para empezar</span>
    </div>
  </div>

  <div class="player-main">
    <div class="player-controls">
      <button class="icon-btn sm" type="button" id="plShuffle" title="Aleatorio" aria-label="Aleatorio" aria-pressed="false">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-shuffle"></use></svg>
      </button>
      <button class="icon-btn" type="button" id="plPrev" title="Anterior" aria-label="Anterior">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-prev"></use></svg>
      </button>
      <button class="play-big" type="button" id="plPlay" title="Reproducir" aria-label="Reproducir">
        <svg class="icon icon-fill" id="plPlayIcon" viewBox="0 0 24 24"><use href="#i-play"></use></svg>
      </button>
      <button class="icon-btn" type="button" id="plNext" title="Siguiente" aria-label="Siguiente">
        <svg class="icon icon-fill" viewBox="0 0 24 24"><use href="#i-next"></use></svg>
      </button>
      <button class="icon-btn sm" type="button" id="plRepeat" title="Repetir" aria-label="Repetir" aria-pressed="false">
        <svg class="icon" viewBox="0 0 24 24"><use href="#i-repeat"></use></svg>
      </button>
    </div>
    <div class="player-progress">
      <span class="time" id="plCur">0:00</span>
      <div class="range" id="plSeek" role="slider" tabindex="0" aria-label="Progreso" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
        <div class="range-bg">
          <div class="range-fill" id="plFill"></div>
          <div class="range-thumb" id="plThumb"></div>
        </div>
      </div>
      <span class="time" id="plDur">0:00</span>
    </div>
  </div>

  <div class="player-right">
    <button class="icon-btn sm" type="button" id="plMute" title="Silenciar" aria-label="Silenciar">
      <svg class="icon" id="plVolIcon" viewBox="0 0 24 24"><use href="#i-volume"></use></svg>
    </button>
    <div class="range range-vol" id="plVol" role="slider" tabindex="0" aria-label="Volumen" aria-valuemin="0" aria-valuemax="100" aria-valuenow="80">
      <div class="range-bg">
        <div class="range-fill" id="plVolFill"></div>
      </div>
    </div>
  </div>

  <audio id="plAudio" preload="metadata"></audio>
</div>

<script>
window.POLI = {
  root: "<%=Url("")%>",
  csrf: "<%=A(CsrfToken())%>",
  userId: <%=CurrentUserId()%>,
  isAdmin: <%=IIfStr(IsAdmin(), "true", "false")%>,
  trackUrl: "<%=Url("api_play.asp")%>",
  defaultCover: "<%=Url("assets/img/cover-default.png")%>"
};
</script>
<script src="<%=Url("assets/js/app.js?v=" & ASSET_VER)%>"></script>
<script src="<%=Url("assets/js/player.js?v=" & ASSET_VER)%>"></script>
</body>
</html>

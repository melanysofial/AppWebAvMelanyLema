/**
 * Chat Rose — Lógica del cliente.
 * Responsabilidad única: gestionar el DOM, la conexión WebSocket y el estado
 * de la interfaz. Los estilos viven en styles.css y la estructura en index.html.
 */

'use strict';

/* ---------- Configuración ---------- */
const MAX_MESSAGE_LENGTH = 500;
const RECONNECT_DELAY_MS = 3000;
const RECONNECTING_DELAY_MS = 1200;
const TYPING_IDLE_MS = 1500;
const TYPING_EXPIRE_MS = 5000;
const TYPING_THROTTLE_MS = 1000;
const THEME_KEY = 'chat-theme';
const DEFAULT_USERNAME = 'Un invitado';

const STATE_LABELS = {
    conectado: 'Conectado',
    desconectado: 'Desconectado',
    reconectando: 'Reconectando'
};

/* ---------- Referencias al DOM ---------- */
const ui = {
    messages: document.getElementById('messages'),
    messageForm: document.getElementById('messageForm'),
    messageInput: document.getElementById('messageInput'),
    usernameInput: document.getElementById('usernameInput'),
    sendBtn: document.getElementById('sendBtn'),
    status: document.getElementById('status'),
    statusText: document.getElementById('statusText'),
    userCountValue: document.getElementById('userCountValue'),
    userCountLabel: document.getElementById('userCountLabel'),
    themeToggle: document.getElementById('themeToggle'),
    typingIndicator: document.getElementById('typingIndicator'),
    typingText: document.getElementById('typingText'),
    validationHint: document.getElementById('validationHint')
};

/* ---------- Estado de la aplicación ---------- */
let socket = null;
let clientId = null;
let connectionState = 'reconectando';
let reconnectTimers = [];
let typingIdleTimer = null;
let typingActive = false;
let lastTypingAt = 0;
const typers = new Map(); // clientId -> { username, timer }

/* ---------- Tema claro / oscuro ---------- */
function readSavedTheme() {
    try {
        return localStorage.getItem(THEME_KEY) === 'oscuro' ? 'oscuro' : 'claro';
    } catch (error) {
        return 'claro';
    }
}

function applyTheme(theme) {
    document.documentElement.dataset.theme = theme;
    ui.themeToggle.checked = theme === 'oscuro';
    ui.themeToggle.setAttribute(
        'aria-label',
        theme === 'oscuro' ? 'Activar modo claro' : 'Activar modo oscuro'
    );

    const metaTheme = document.querySelector('meta[name="theme-color"]');
    if (metaTheme) {
        metaTheme.setAttribute('content', theme === 'oscuro' ? '#221019' : '#fdeaf2');
    }
}

function initTheme() {
    applyTheme(readSavedTheme());
    ui.themeToggle.addEventListener('change', () => {
        const theme = ui.themeToggle.checked ? 'oscuro' : 'claro';
        try {
            localStorage.setItem(THEME_KEY, theme);
        } catch (error) {
            /* El navegador puede bloquear el almacenamiento; el tema sigue aplicándose. */
        }
        applyTheme(theme);
    });
}

/* ---------- Utilidades ---------- */
function presenceName() {
    return ui.usernameInput.value.trim() || DEFAULT_USERNAME;
}

function showHint(message) {
    ui.validationHint.textContent = message;
}

function scrollToBottom() {
    ui.messages.scrollTop = ui.messages.scrollHeight;
}

function appendElement(element) {
    ui.messages.appendChild(element);
    scrollToBottom();
}

function sendPayload(payload) {
    if (!socket || socket.readyState !== WebSocket.OPEN) return false;
    socket.send(JSON.stringify(payload));
    return true;
}

/* Devuelve la hora legible a partir del timestamp ISO 8601 que llega en el JSON */
function formatHour(isoString) {
    if (!isoString) return '';
    const date = new Date(isoString);
    if (Number.isNaN(date.getTime())) return '';
    return date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
}

/* ---------- Estado de conexión ---------- */
function setConnectionState(state) {
    connectionState = state;
    ui.status.dataset.estado = state;
    ui.statusText.textContent = STATE_LABELS[state];
    ui.sendBtn.disabled = state !== 'conectado';
}

function clearReconnectTimers() {
    reconnectTimers.forEach(clearTimeout);
    reconnectTimers = [];
}

function clearTypers() {
    typers.forEach((entry) => clearTimeout(entry.timer));
    typers.clear();
    renderTyping();
}

function connect() {
    if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
        return;
    }

    clearReconnectTimers();
    setConnectionState('reconectando');

    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    socket = new WebSocket(`${protocol}//${location.host}`);

    socket.addEventListener('open', () => {
        setConnectionState('conectado');
        showHint('');
        sendPayload({ type: 'join', username: presenceName() });
    });

    socket.addEventListener('message', (event) => {
        let data;
        try {
            data = JSON.parse(event.data);
        } catch (error) {
            console.error('Mensaje no válido:', error);
            return;
        }
        handleServerMessage(data);
    });

    socket.addEventListener('error', (error) => {
        console.error('Error WebSocket:', error);
        setConnectionState('desconectado');
    });

    socket.addEventListener('close', () => {
        setConnectionState('desconectado');
        clearTypers();
        clearReconnectTimers();
        reconnectTimers.push(
            setTimeout(() => setConnectionState('reconectando'), RECONNECTING_DELAY_MS)
        );
        reconnectTimers.push(
            setTimeout(() => {
                setConnectionState('reconectando');
                connect();
            }, RECONNECT_DELAY_MS)
        );
    });
}

/* ---------- Mensajes del servidor ---------- */
function handleServerMessage(data) {
    if (!data || typeof data !== 'object') return;

    switch (data.type) {
        case 'welcome':
            clientId = data.clientId;
            setUserCount(data.count);
            break;
        case 'users':
            setUserCount(data.count);
            break;
        case 'notice':
            renderNotice(data.text);
            break;
        case 'message':
            renderMessage(data);
            break;
        case 'typing':
            handleTyping(data);
            break;
        case 'error':
            showHint(data.message);
            break;
        default:
            break;
    }
}

function setUserCount(count) {
    const total = Number(count) || 0;
    ui.userCountValue.textContent = String(total);
    ui.userCountLabel.textContent = total === 1 ? 'conectado' : 'conectados';
}

function renderNotice(text) {
    const notice = document.createElement('div');
    notice.className = 'aviso';
    notice.textContent = text || '';
    appendElement(notice);
}

function renderMessage(data) {
    const ownMessage = Boolean(clientId && data.clientId === clientId);

    const row = document.createElement('div');
    row.className = `mensaje ${ownMessage ? 'mensaje--enviado' : 'mensaje--recibido'}`;

    const bubble = document.createElement('div');
    bubble.className = 'mensaje__burbuja';

    // Recibidos: alineados a la izquierda con el nombre de quien envía
    if (!ownMessage) {
        const author = document.createElement('span');
        author.className = 'mensaje__autor';
        author.textContent = data.username || DEFAULT_USERNAME;
        bubble.appendChild(author);
    }

    const text = document.createElement('p');
    text.className = 'mensaje__texto';
    text.textContent = data.text || '';
    bubble.appendChild(text);

    // Hora tomada del campo timestamp del JSON (ISO 8601)
    const time = document.createElement('time');
    time.className = `mensaje__hora${ownMessage ? ' mensaje__hora--json' : ''}`;
    time.textContent = formatHour(data.timestamp);
    time.dateTime = data.timestamp || '';
    time.title = data.timestamp || '';
    time.dataset.horaJson = data.timestamp || '';
    bubble.appendChild(time);

    row.appendChild(bubble);
    appendElement(row);
}

/* ---------- Indicador «escribiendo…» ---------- */
function handleTyping(data) {
    if (!data.clientId) return;

    const previous = typers.get(data.clientId);
    if (previous) clearTimeout(previous.timer);

    if (data.isTyping) {
        const timer = setTimeout(() => {
            typers.delete(data.clientId);
            renderTyping();
        }, TYPING_EXPIRE_MS);
        typers.set(data.clientId, { username: data.username || DEFAULT_USERNAME, timer });
    } else {
        typers.delete(data.clientId);
    }

    renderTyping();
}

function renderTyping() {
    const names = Array.from(typers.values(), (entry) => entry.username);
    ui.typingIndicator.classList.toggle('chat__escritura--activo', names.length > 0);

    if (names.length === 0) {
        ui.typingText.textContent = '';
    } else if (names.length === 1) {
        ui.typingText.textContent = `${names[0]} está escribiendo…`;
    } else if (names.length === 2) {
        ui.typingText.textContent = `${names[0]} y ${names[1]} están escribiendo…`;
    } else {
        ui.typingText.textContent = 'Varios usuarios están escribiendo…';
    }
}

function stopTyping() {
    clearTimeout(typingIdleTimer);
    if (!typingActive) return;
    typingActive = false;
    sendPayload({ type: 'typing', username: presenceName(), isTyping: false });
}

function notifyTyping() {
    if (!ui.messageInput.value.trim()) {
        stopTyping();
        return;
    }

    const now = Date.now();
    if (!typingActive || now - lastTypingAt > TYPING_THROTTLE_MS) {
        typingActive = true;
        lastTypingAt = now;
        sendPayload({ type: 'typing', username: presenceName(), isTyping: true });
    }

    clearTimeout(typingIdleTimer);
    typingIdleTimer = setTimeout(stopTyping, TYPING_IDLE_MS);
}

/* ---------- Envío y validación de mensajes ---------- */
function sendMessage() {
    const username = ui.usernameInput.value.trim();
    const text = ui.messageInput.value.trim();

    if (!username) {
        showHint('Ingresa tu nombre de usuario antes de enviar.');
        ui.usernameInput.focus();
        return;
    }

    if (!text) {
        showHint('El mensaje no puede estar vacío.');
        ui.messageInput.focus();
        return;
    }

    if (text.length > MAX_MESSAGE_LENGTH) {
        showHint(`El mensaje es demasiado largo (máximo ${MAX_MESSAGE_LENGTH} caracteres).`);
        ui.messageInput.focus();
        return;
    }

    if (connectionState !== 'conectado' || !sendPayload({ type: 'message', username, text })) {
        showHint('No hay conexión con el servidor.');
        return;
    }

    ui.messageInput.value = '';
    showHint('');
    stopTyping();
}

/* ---------- Eventos de la interfaz ---------- */
ui.messageForm.addEventListener('submit', (event) => {
    event.preventDefault();
    sendMessage();
});

ui.messageInput.addEventListener('input', () => {
    showHint('');
    notifyTyping();
});

ui.usernameInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        event.preventDefault();
        ui.messageInput.focus();
    }
});

ui.usernameInput.addEventListener('change', () => {
    sendPayload({ type: 'username', username: presenceName() });
});

/* ---------- Inicialización ---------- */
initTheme();
setConnectionState('reconectando');
connect();

// En móvil se evita abrir el teclado automáticamente al cargar la página
if (window.matchMedia('(min-width: 721px)').matches) {
    ui.usernameInput.focus();
}

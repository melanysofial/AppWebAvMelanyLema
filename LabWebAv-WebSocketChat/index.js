/**
 * Servidor del Web Chat (Express + WebSocket).
 * Responsabilidad única: servir los archivos estáticos y gestionar el
 * protocolo de mensajería en tiempo real.
 */

const express = require('express');
const WebSocket = require('ws');

const app = express();
const port = 3000;

// Límites compartidos con el cliente (public/app.js)
const MAX_MESSAGE_LENGTH = 500;
const MAX_USERNAME_LENGTH = 20;
const DEFAULT_USERNAME = 'Un invitado';

// Servir archivos estáticos
app.use(express.static('public'));

// Crear servidor HTTP
const server = app.listen(port, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});

// Crear servidor WebSocket
const wss = new WebSocket.Server({ server });

// Almacenar conexiones activas
const clients = new Set();
let sequence = 0;

const isOpen = (ws) => ws.readyState === WebSocket.OPEN;

const send = (ws, payload) => {
  if (isOpen(ws)) ws.send(JSON.stringify(payload));
};

// Broadcast: por defecto llega a todos, incluido el emisor
const broadcast = (payload, exclude) => {
  const data = JSON.stringify(payload);
  clients.forEach((client) => {
    if (client !== exclude && isOpen(client)) client.send(data);
  });
};

const broadcastUserCount = () => broadcast({ type: 'users', count: clients.size });

const broadcastNotice = (text, exclude) =>
  broadcast({ type: 'notice', text, timestamp: new Date().toISOString() }, exclude);

const cleanUsername = (value) =>
  typeof value === 'string' ? value.trim().slice(0, MAX_USERNAME_LENGTH) : '';

const rejectMessage = (ws) =>
  send(ws, {
    type: 'error',
    message: `Mensaje rechazado: no puede estar vacío ni superar ${MAX_MESSAGE_LENGTH} caracteres.`
  });

wss.on('connection', (ws) => {
  ws.clientId = `cliente-${++sequence}-${Date.now()}`;
  ws.username = DEFAULT_USERNAME;
  ws.joined = false;

  clients.add(ws);
  console.log('Cliente conectado. Total:', clients.size);

  // El cliente necesita su identificador para distinguir mensajes propios/ajenos
  send(ws, { type: 'welcome', clientId: ws.clientId, count: clients.size });
  broadcastUserCount();

  ws.on('message', (data) => {
    let message;
    try {
      message = JSON.parse(data.toString());
    } catch (error) {
      console.error('Error procesando mensaje:', error);
      return;
    }
    if (!message || typeof message !== 'object' || Array.isArray(message)) return;

    // Compatibilidad con el formato anterior { username, text }
    const type = message.type || (typeof message.text === 'string' ? 'message' : '');

    switch (type) {
      case 'join': {
        ws.username = cleanUsername(message.username) || DEFAULT_USERNAME;
        if (!ws.joined) {
          ws.joined = true;
          // A los demás les llega quién se unió; uno mismo ve un aviso personal
          broadcastNotice(`${ws.username} se ha unido al chat`, ws);
          send(ws, {
            type: 'notice',
            text: 'Te has unido al chat',
            timestamp: new Date().toISOString()
          });
        }
        broadcastUserCount();
        break;
      }

      // Mantener actualizado el nombre para los avisos de salida y "escribiendo…"
      case 'username': {
        ws.username = cleanUsername(message.username) || DEFAULT_USERNAME;
        break;
      }

      case 'message': {
        const text = typeof message.text === 'string' ? message.text.trim() : '';
        if (!text || text.length > MAX_MESSAGE_LENGTH) {
          rejectMessage(ws);
          return;
        }

        ws.username = cleanUsername(message.username) || DEFAULT_USERNAME;

        // La hora viaja dentro del JSON en formato ISO 8601
        broadcast({
          type: 'message',
          clientId: ws.clientId,
          username: ws.username,
          text,
          timestamp: new Date().toISOString()
        });

        // Al enviar, el usuario deja de estar escribiendo
        broadcast(
          { type: 'typing', clientId: ws.clientId, username: ws.username, isTyping: false },
          ws
        );
        break;
      }

      case 'typing': {
        ws.username = cleanUsername(message.username) || DEFAULT_USERNAME;
        broadcast(
          {
            type: 'typing',
            clientId: ws.clientId,
            username: ws.username,
            isTyping: Boolean(message.isTyping)
          },
          ws
        );
        break;
      }

      default:
        break;
    }
  });

  ws.on('close', () => {
    clients.delete(ws);
    console.log('Cliente desconectado. Total:', clients.size);

    broadcast({
      type: 'typing',
      clientId: ws.clientId,
      username: ws.username,
      isTyping: false
    });
    if (ws.joined) broadcastNotice(`${ws.username} ha salido del chat`);
    broadcastUserCount();
  });

  ws.on('error', (error) => {
    console.error('Error WebSocket:', error);
  });
});

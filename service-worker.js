// Nom du cache - version 2
const CACHE_NAME = 'sqlpage-cache-v2';

// Fichiers statiques minimaux à mettre en cache immédiatement
const ASSETS_TO_CACHE = [
  '/',
  '/manifest.json',
  '/js/app.js',
  '/js/pwa-notifications.js',
  '/img/barjacar_192.png',
  '/css/theme_01.css'
];

// 1. Installation du Service Worker et mise en cache des fichiers de base
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[Service Worker v2] Mise en cache des ressources initiales');
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  // Force le Service Worker actuel à devenir actif sans attendre
  self.skipWaiting();
});

// 2. Nettoyage des anciens caches (v1 -> v2) lors de la mise à jour
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cache) => {
          if (cache !== CACHE_NAME) {
            console.log('[Service Worker] Suppression de l\'ancien cache :', cache);
            return caches.delete(cache);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// 3. Interception des requêtes (Stratégie Network-First)
self.addEventListener('fetch', (event) => {
  // On n'intercepte JAMAIS les requêtes de formulaires ou d'actions (POST)
  if (event.request.method !== 'GET') return;

  event.respondWith(
    fetch(event.request)
      .then((networkResponse) => {
        // Si le réseau fonctionne, on met à jour le cache dynamiquement
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      })
      .catch(() => {
        // En cas de panne de réseau (hors-ligne), on cherche dans le cache
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          console.error('[Service Worker] Ressource non trouvée hors-ligne :', event.request.url);
        });
      })
  );
});

// 4. Écoute des notifications Push (Arrière-plan Android / Chrome)
self.addEventListener('push', (event) => {
  let data = { title: 'BARJACar', message: 'Nouvelle notification' };

  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      data.message = event.data.text();
    }
  }

  const options = {
    body: data.message || 'Vous avez reçu un nouveau message.',
    icon: '/img/barjacar_192.png',
    badge: '/img/barjacar_192.png',
    vibrate: [100, 50, 100],
    data: {
      url: '/index.sql?tab=6'
    }
  };

  // event.waitUntil empêche Android de tuer le processus avant l'affichage
  event.waitUntil(
    self.registration.showNotification(data.title || 'BARJACar', options)
  );
});

// 5. Redirection lors du clic sur la notification reçue
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const targetUrl = event.notification.data && event.notification.data.url 
    ? event.notification.data.url 
    : '/index.sql?tab=6';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      // Si une fenêtre de l'application est déjà ouverte, on la ramène au premier plan
      for (let client of windowClients) {
        if (client.url.includes('covoiturage.barjac-en-lozere.fr') && 'focus' in client) {
          client.navigate(targetUrl);
          return client.focus();
        }
      }
      // Sinon, on ouvre une nouvelle fenêtre
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});

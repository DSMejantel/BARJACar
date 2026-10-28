// clé publique VAPID (identique à celle dans send-pushes.js)
const VAPID_PUBLIC_KEY = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';


// Convertit la clé VAPID Base64 en Uint8Array pour le navigateur
function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding)
    .replace(/-/g, '+')
    .replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

// 1. Activer et enregistrer les notifications Push
async function enableNotifications() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
    alert("Les notifications Push ne sont pas supportées par votre navigateur.");
    return;
  }

  try {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
      alert("Vous avez refusé l'activation des notifications.");
      return;
    }

    const registration = await navigator.serviceWorker.ready;

    let subscription = await registration.pushManager.getSubscription();
    if (!subscription) {
      const convertedVapidKey = urlBase64ToUint8Array(VAPID_PUBLIC_KEY);
      subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: convertedVapidKey
      });
    }

    const jsonSub = subscription.toJSON();
    const formData = new URLSearchParams();
    formData.append('endpoint', jsonSub.endpoint || '');
    formData.append('p256dh', (jsonSub.keys && jsonSub.keys.p256dh) ? jsonSub.keys.p256dh : '');
    formData.append('auth', (jsonSub.keys && jsonSub.keys.auth) ? jsonSub.keys.auth : '');

    const response = await fetch('/save_subscription.sql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: formData.toString()
    });

    const rawData = await response.json();
    const result = Array.isArray(rawData) ? rawData[0] : rawData;

    if (result && result.status === 'success') {
      alert(result.message || "Notifications activées avec succès !");
      window.location.reload();
    } else {
      alert("Erreur lors de l'enregistrement : " + (result ? (result.message || result.status) : "Aucune réponse du serveur"));
    }

  } catch (error) {
    console.error("Erreur lors de l'activation des notifications Push :", error);
    alert("Une erreur est survenue lors de l'activation : " + error.message);
  }
}

// 2. Désactiver et supprimer les notifications Push
async function disableNotifications() {
  try {
    // A. Si le navigateur gère les SW et la souscription
    if (('serviceWorker' in navigator) && ('PushManager' in window)) {
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.getSubscription();
      if (subscription) {
        await subscription.unsubscribe();
      }
    }

    // B. Suppression forcée en base de données SQLite
    const response = await fetch('/unsubscribe.sql', {
      method: 'POST'
    });

    const rawData = await response.json();
    const result = Array.isArray(rawData) ? rawData[0] : rawData;

    if (result && result.status === 'success') {
      alert(result.message || "Vous avez été désabonné des notifications Push.");
      window.location.reload();
    } else {
      alert("Erreur lors du désabonnement : " + (result ? (result.message || result.status) : "Erreur serveur"));
    }

  } catch (error) {
    console.error("Erreur lors de la désactivation des notifications :", error);
    alert("Impossible de désactiver les notifications : " + error.message);
  }
}

// 3. Initialisation des événements DOM
document.addEventListener('DOMContentLoaded', () => {
  const btnPushEnable = document.getElementById('btn-pwa-push');
  if (btnPushEnable) {
    btnPushEnable.addEventListener('click', (e) => {
      e.preventDefault();
      enableNotifications();
    });
  }

  const btnPushDisable = document.getElementById('btn-pwa-push-disable');
  if (btnPushDisable) {
    btnPushDisable.addEventListener('click', (e) => {
      e.preventDefault();
      disableNotifications();
    });
  }
});

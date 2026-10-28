if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then(reg => console.log('Service Worker enregistré !'))
      .catch(err => console.log('Erreur d\'enregistrement :', err));
  });
}


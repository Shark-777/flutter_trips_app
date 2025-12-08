// Editor Bridge - связь между Flutter Visual Helper и Flutter App
(function() {
  console.log('[EditorBridge] Initializing...');

  // Слушаем postMessage от родительского окна (редактора)
  window.addEventListener('message', function(event) {
    console.log('[EditorBridge] Received message:', event.data);
    
    if (event.data && event.data.type === 'navigate') {
      var route = event.data.route;
      console.log('[EditorBridge] Navigate to:', route);
      
      // Меняем hash для навигации
      if (window.location.hash !== '#' + route) {
        window.location.hash = route;
      }
    }
  });

  // Уведомляем родителя что bridge готов
  if (window.parent !== window) {
    window.parent.postMessage({ type: 'bridge_ready' }, '*');
  }

  console.log('[EditorBridge] Initialized and ready');
})();

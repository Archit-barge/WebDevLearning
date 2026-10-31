// main.js - register service worker & subscribe for push
if ('serviceWorker' in navigator && 'PushManager' in window) {
    navigator.serviceWorker.register('<%=request.getContextPath()%>/student/static/js/sw.js')
        .then(function(registration) {
            console.log('Service Worker registered with scope:', registration.scope);

            return registration.pushManager.getSubscription()
                .then(function(subscription) {
                    if (subscription) return subscription; // already subscribed

                    // Subscribe for push notifications
                    return registration.pushManager.subscribe({
                        userVisibleOnly: true,
                        applicationServerKey: urlBase64ToUint8Array('<YOUR_PUBLIC_VAPID_KEY>')
                    });
                });
        })
        .then(function(subscription) {
            // Send subscription to backend
            return fetch('<%=request.getContextPath()%>/teacher/savePushSubscription', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(subscription)
            });
        })
        .then(() => console.log('Push subscription saved on server'))
        .catch(function(err) {
            console.error('Service Worker or Push subscription failed:', err);
        });
}

// Helper function to convert VAPID key
function urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; i++) {
        outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
}

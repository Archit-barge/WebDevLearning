self.addEventListener('install', event => {
    console.log('[SW] Installed');
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    console.log('[SW] Activated');
});

self.addEventListener('push', event => {
    console.log('[SW] Push received');

    let data = {};
    if (event.data) {
        data = event.data.json();
    }

    const title = data.title || 'New Announcement';
    const options = {
        body: data.body || 'You have a new message',
        icon: '/EduVerse/student/static/images/logo.png',
        badge: '/EduVerse/student/static/images/logo.png',
    };

    event.waitUntil(
        self.registration.showNotification(title, options)
    );
});

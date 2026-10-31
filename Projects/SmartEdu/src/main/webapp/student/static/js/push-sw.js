self.addEventListener('push', function (event) {

    let data = {
        title: "New Announcement",
        body: "You have a new notification"
    };

    // If real JSON comes from server, use it
    if (event.data) {
        try {
            data = event.data.json();
        } catch (e) {
            data.body = event.data.text();
        }
    }

    const options = {
        body: data.body,
        icon: '/EduVerse/student/static/icon.png'
    };

    event.waitUntil(
        self.registration.showNotification(data.title, options)
    );
});

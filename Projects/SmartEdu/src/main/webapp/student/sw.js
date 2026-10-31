self.addEventListener("push", event => {
    const data = event.data.json();

    self.registration.showNotification(data.title, {
        body: data.message,
        icon: "/EduVerse/images/logo.png",
        badge: "/EduVerse/images/badge.png"
    });
});

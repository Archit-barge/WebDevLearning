// LOGIN PAGE
let usernameField = document.getElementById("username");
if (usernameField) {
	usernameField.addEventListener("input", function () {
		var errorDiv = document.querySelector(".error-message");
		if (errorDiv) errorDiv.style.display = "none";
	});
}

let passwordField = document.getElementById("password");
if (passwordField) {
	passwordField.addEventListener("input", function () {
		var errorDiv = document.querySelector(".error-message");
		if (errorDiv) errorDiv.style.display = "none";
	});
}

// LOGOUT
function logout() {
	if (confirm("Are you sure you want to log out?")) {
		localStorage.clear();
		window.location.href = "../LogoutServlet";
	}
}

// SIDEBAR & PAGE LOADING
function loadPage(filename) {
	fetch("../PageLoader?page=" + filename + "&role=parent")
		.then(response => {
			if (!response.ok) {
				throw new Error("Page not found");
			}
			return response.text();
		})
		.then(data => {
			document.getElementById("main-content").innerHTML = data;
			localStorage.setItem("lastParentPage", filename);

			let links = document.querySelectorAll(".sidebar-menu a");
			links.forEach(link => link.classList.remove("active"));
			let activeLink = Array.from(links).find(link =>
				link.getAttribute("onclick") === `loadPage('${filename}')`
			);
			if (activeLink) activeLink.classList.add("active");

            if (filename === 'view_timetable.jsp' || filename === 'view_timetables.jsp') {
                if(typeof loadTimetablesTable === 'function') setTimeout(loadTimetablesTable, 50);
            }
		})
		.catch(error => {
			document.getElementById("main-content").innerHTML =
				"<h1>404</h1><p>Page not found.</p>";
		});
}

// SIDEBAR TOGGLE FUNCTIONS
const sidebar = document.querySelector('.sidebar');
const overlay = document.querySelector('.sidebar-overlay');
const toggleBtn = document.querySelector('#sidebarToggle');
const toggleDiv = document.querySelector('.mobile-toggle');

function openSidebar() {
    if (!sidebar) return;
    sidebar.classList.add('active');
    if (overlay) overlay.classList.add('active');
    if (toggleDiv) toggleDiv.classList.add('hidden');
}

function closeSidebar() {
    if (!sidebar) return;
    sidebar.classList.remove('active');
    if (overlay) overlay.classList.remove('active');
    if (toggleDiv) toggleDiv.classList.remove('hidden');
}

function toggleSidebar() {
    if (sidebar && sidebar.classList.contains('active')) {
        closeSidebar();
    } else {
        openSidebar();
    }
}

// Mobile sidebar toggle
document.addEventListener("DOMContentLoaded", function() {
    if (toggleBtn) {
        toggleBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            toggleSidebar();
        });
    }

    if (overlay) {
        overlay.addEventListener('click', closeSidebar);
    }

    // Close sidebar when clicking on a menu item (mobile)
    let menuLinks = document.querySelectorAll(".sidebar-menu a");
    menuLinks.forEach(function(link) {
        link.addEventListener("click", function() {
            if (window.innerWidth <= 1024) {
                closeSidebar();
            }
        });
    });

    // Close sidebar when clicking outside
    document.addEventListener("click", function(e) {
        if (window.innerWidth <= 1024 && sidebar && sidebar.classList.contains('active')) {
            if (!sidebar.contains(e.target) && !toggleDiv.contains(e.target)) {
                closeSidebar();
            }
        }
    });
});

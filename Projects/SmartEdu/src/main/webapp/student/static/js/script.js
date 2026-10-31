
// =======================
// Student Dashboard JS
// =======================

// =======================
// Logout Function
// =======================
function logout() {
    if (confirm("Are you sure you want to log out?")) {
        localStorage.clear();
        window.location.href = "../LogoutServlet";
    }
}

// =======================
// Load Page Dynamically
// =======================
function loadPage(pageName) {

    if (!pageName) return;

    fetch("../PageLoaderStudent?page=" + encodeURIComponent(pageName))
        .then(response => {
            if (!response.ok) {
                throw new Error("Page not found: " + pageName);
            }
            return response.text();
        })
        .then(html => {
            const mainContent = document.getElementById("main-content");
            if (!mainContent) return;

            mainContent.innerHTML = html;
            runScripts(mainContent);

            localStorage.setItem("lastPage", pageName);

            document.querySelectorAll(".sidebar-menu a").forEach(link => {
                link.classList.remove("active");
                const onclickValue = link.getAttribute("onclick");
                if (onclickValue === `loadPage('${pageName}')`) {
                    link.classList.add("active");
                }
            });
        })
        .catch(error => {
            console.error(error);
            document.getElementById("main-content").innerHTML = `
                <div class="alert alert-danger">
                    <h4>404</h4>
                    <p>Page not found.</p>
                </div>
            `;
        });
}

function runScripts(container) {
    container.querySelectorAll("script").forEach(oldScript => {
        const newScript = document.createElement("script");
        Array.from(oldScript.attributes).forEach(attr =>
            newScript.setAttribute(attr.name, attr.value)
        );
        newScript.textContent = oldScript.textContent;
        oldScript.parentNode.replaceChild(newScript, oldScript);
    });
}


// =======================
// STUDENT DOCUMENT LIBRARY
// =======================
var sdDocs = [];

function sdLoad() {
    var sEl   = document.getElementById('sdSearch');
    var subEl = document.getElementById('sdSubject');
    var tEl   = document.getElementById('sdType');
    if (!sEl) return; // not on doc library page

    var params = 'search='    + encodeURIComponent(sEl.value)
        + '&subjectId=' + encodeURIComponent(subEl.value)
        + '&docType='   + encodeURIComponent(tEl.value);

    document.getElementById('sdGrid').innerHTML =
        '<div class="empty-state"><i class="fas fa-spinner fa-spin"></i><p>Loading\u2026</p></div>';

    fetch('../getStudentDocuments?' + params)
        .then(function(r) { return r.json(); })
        .then(function(docs) { renderSdCards(docs); })
        .catch(function() {
            document.getElementById('sdGrid').innerHTML =
                '<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>Failed to load documents.</p></div>';
        });
}

function renderSdCards(docs) {
    sdDocs = docs || [];
    var grid = document.getElementById('sdGrid');
    if (!sdDocs.length) {
        grid.innerHTML = '<div class="empty-state"><i class="fas fa-folder-open"></i><p>No documents available.</p></div>';
        return;
    }
    var html = '';
    for (var i = 0; i < sdDocs.length; i++) {
        var d = sdDocs[i];
        html += '<div class="doc-card" onclick="openSdModal(' + i + ')">';
        html += '<div class="doc-card-header"><h3 class="doc-title">' + sdEsc(d.title) + '</h3></div>';
        html += '<p class="doc-sub">' + sdEsc(d.subjectName || 'General') + ' &bull; ' + sdEsc(d.classDisplay || 'All Classes') + '</p>';
        html += '<p class="doc-uploader">By ' + sdEsc(d.uploader || '\u2014') + '</p>';
        html += '<div class="doc-actions" onclick="event.stopPropagation()">';
        html += '<a class="btn btn-primary" href="../downloadDocument?id=' + d.id + '" onclick="event.stopPropagation()">Download</a>';
        html += '</div></div>';
    }
    grid.innerHTML = html;
}

function sdEsc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function openSdModal(idx) {
    var d = sdDocs[idx];
    document.getElementById('sdModalTitle').textContent   = d.title        || '\u2014';
    document.getElementById('sdModalDesc').textContent    = d.description   || '\u2014';
    document.getElementById('sdModalUploader').textContent = d.uploader      || '\u2014';
    document.getElementById('sdModalSubject').textContent  = d.subjectName   || 'General';
    document.getElementById('sdModalClass').textContent    = d.classDisplay  || 'All Classes';
    document.getElementById('sdModalType').textContent     = d.type          || '\u2014';
    document.getElementById('sdModalFile').textContent     = d.originalFile  || '\u2014';
    document.getElementById('sdDownloadBtn').href          = '../downloadDocument?id=' + d.id;
    document.getElementById('sdDetailsModal').classList.add('active');
}
function closeSdModal()           { document.getElementById('sdDetailsModal').classList.remove('active'); }
function closeSdModalOnOverlay(e) { if (e.target === e.currentTarget) closeSdModal(); }

// Auto-init when page loads
document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('sdGrid')) sdLoad();
});


// =======================
// Sidebar Toggle (Mobile)
// =======================
document.addEventListener("DOMContentLoaded", () => {

    const toggleBtn = document.getElementById("sidebarToggle");
    const sidebar = document.querySelector(".sidebar");

    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener("click", () => {
            sidebar.classList.toggle("open");
        });
    }

    // Load last visited page OR dashboard
    const lastPage = localStorage.getItem("lastPage") || "dashboard.jsp";
    loadPage(lastPage);
});

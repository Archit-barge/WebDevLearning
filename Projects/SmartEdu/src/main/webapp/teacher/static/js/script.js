// =======================
// DOM READY
// =======================
document.addEventListener("DOMContentLoaded", function () {

    const sidebar = document.querySelector(".sidebar");
    const toggleBtn = document.getElementById("sidebarToggle");
    const overlay = document.getElementById("sidebarOverlay");
    const links = document.querySelectorAll(".sidebar-menu a");

    // =======================
    // SIDEBAR TOGGLE
    // =======================
    function toggleSidebar() {
        sidebar.classList.toggle("open");
        toggleBtn.classList.toggle("active");
        overlay.classList.toggle("active");
    }

    if (toggleBtn) {
        toggleBtn.addEventListener("click", toggleSidebar);
    }

    // =======================
    // CLOSE SIDEBAR WHEN CLICKING OVERLAY
    // =======================
    if (overlay) {
        overlay.addEventListener("click", function () {
            sidebar.classList.remove("open");
            toggleBtn.classList.remove("active");
            overlay.classList.remove("active");
        });
    }

    // =======================
    // CLOSE SIDEBAR AFTER CLICKING MENU (MOBILE)
    // =======================
    links.forEach(link => {
        link.addEventListener("click", function () {

            // Active class switching
            links.forEach(l => l.classList.remove("active"));
            this.classList.add("active");

            // Close sidebar only if mobile
            if (window.innerWidth <= 768) {
                sidebar.classList.remove("open");
                toggleBtn.classList.remove("active");
                overlay.classList.remove("active");
            }
        });
    });

});


// =======================
// LOAD PAGE FUNCTION
// =======================
function loadPage(filename) {

    fetch("../PageLoaderTeacher?page=" + filename)
        .then(response => {
            if (!response.ok) {
                throw new Error("Page not found");
            }
            return response.text();
        })
        .then(data => {
            const container = document.getElementById("main-content");
            container.innerHTML = data;
            localStorage.setItem("lastPage", filename);

            // Re-execute <script> tags — innerHTML skips them by default
            runScripts(container);

            // Set active menu
            let links = document.querySelectorAll(".sidebar-menu a");
            links.forEach(link => link.classList.remove("active"));

            let activeLink = Array.from(links).find(link =>
                link.getAttribute("onclick") === `loadPage('${filename}')`
            );

            if (activeLink) {
                activeLink.classList.add("active");
            }
        })
        .catch(error => {
            document.getElementById("main-content").innerHTML =
                "<h1>404</h1><p>Page not found.</p>";
        });
}

function runScripts(container) {
    container.querySelectorAll("script").forEach(oldScript => {
        const newScript = document.createElement("script");
        // Copy attributes (type, src, etc.)
        Array.from(oldScript.attributes).forEach(attr =>
            newScript.setAttribute(attr.name, attr.value)
        );
        // Copy inline script content
        newScript.textContent = oldScript.textContent;
        oldScript.parentNode.replaceChild(newScript, oldScript);
    });
}



// =======================
// LOGOUT
// =======================
function logout() {
    if (confirm("Are you sure you want to log out?")) {
        localStorage.clear();
        window.location.href = "../LogoutServlet";
    }
}


// =======================
// AUTO LOAD LAST PAGE
// =======================
window.onload = function () {
    const lastPage = localStorage.getItem("lastPage") || "dashboard.jsp";
    loadPage(lastPage);
};


// =======================
// POST DOCUMENT – upload
// =======================
function uploadDocument() {
    var form = document.getElementById('documentForm');
    if (!form) return;
    var fd  = new FormData(form);
    var res = document.getElementById('docResult');
    res.innerHTML = '<div class="alert"><i class="fas fa-spinner fa-spin"></i> Uploading\u2026</div>';

    fetch('../teacherUploadDocument', { method: 'POST', body: fd })
        .then(function(r) { return r.text(); })
        .then(function(html) {
            var tmp = document.createElement('div');
            tmp.innerHTML = html;
            var msg = tmp.textContent || tmp.innerText || 'Done.';
            if (html.indexOf('success') >= 0) {
                res.innerHTML = '<div class="alert alert-success"><i class="fas fa-check-circle"></i> ' + msg + '</div>';
                form.reset();
            } else {
                res.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> ' + msg + '</div>';
            }
            res.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        })
        .catch(function() {
            res.innerHTML = '<div class="alert alert-error"><i class="fas fa-exclamation-triangle"></i> Upload failed. Please try again.</div>';
        });
}


// =======================
// DOCUMENT LIBRARY
// =======================
var dlDocs = [];
var dlCurrentDoc = null;

function dlLoad() {
    var sEl = document.getElementById('dlSearch');
    var cEl = document.getElementById('dlClass');
    var subEl = document.getElementById('dlSubject');
    var tEl = document.getElementById('dlType');
    var oEl = document.getElementById('dlOwner');
    if (!sEl) return;  // not on doc library page

    var params = 'search=' + encodeURIComponent(sEl.value)
        + '&classId='   + encodeURIComponent(cEl.value)
        + '&subjectId=' + encodeURIComponent(subEl.value)
        + '&docType='   + encodeURIComponent(tEl.value)
        + (oEl.value === 'mine' ? '&onlyMine=1' : '');

    document.getElementById('docGrid').innerHTML =
        '<div class="empty-state"><i class="fas fa-spinner fa-spin"></i><p>Loading\u2026</p></div>';

    fetch('../getTeacherDocuments?' + params)
        .then(function(r) { return r.json(); })
        .then(function(docs) { renderDlCards(docs); })
        .catch(function() {
            document.getElementById('docGrid').innerHTML =
                '<div class="empty-state"><i class="fas fa-exclamation-circle"></i><p>Failed to load documents.</p></div>';
        });
}

function renderDlCards(docs) {
    dlDocs = docs || [];
    var grid = document.getElementById('docGrid');
    if (!dlDocs.length) {
        grid.innerHTML = '<div class="empty-state"><i class="fas fa-folder-open"></i><p>No documents found.</p></div>';
        return;
    }
    var myId = window.DL_MY_USER_ID || 0;
    var html = '';
    for (var i = 0; i < dlDocs.length; i++) {
        var d = dlDocs[i];
        html += '<div class="doc-card" onclick="openDocModal(' + i + ')">';
        if (d.uploadedBy === myId) html += '<span class="mine-badge">Mine</span><br>';
        html += '<div class="doc-card-header"><h3 class="doc-title">' + dlEsc(d.title) + '</h3></div>';
        html += '<p class="doc-sub">' + dlEsc(d.subjectName || 'General') + ' &bull; ' + dlEsc(d.classDisplay || 'All Classes') + '</p>';
        html += '<p class="doc-uploader">By ' + dlEsc(d.uploader || '\u2014') + '</p>';
        html += '<div class="doc-actions" onclick="event.stopPropagation()">';
        html += '<a class="btn btn-primary" href="../downloadDocument?id=' + d.id + '" onclick="event.stopPropagation()">Download</a>';
        html += '</div></div>';
    }
    grid.innerHTML = html;
}

function dlEsc(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function openDocModal(idx) {
    dlCurrentDoc = dlDocs[idx];
    var d = dlCurrentDoc;
    var myId = window.DL_MY_USER_ID || 0;
    document.getElementById('docModalTitle').textContent       = d.title        || '\u2014';
    document.getElementById('docModalDescription').textContent = d.description  || '\u2014';
    document.getElementById('docModalUploader').textContent    = d.uploader     || '\u2014';
    document.getElementById('docModalSubject').textContent     = d.subjectName  || 'General';
    document.getElementById('docModalClass').textContent       = d.classDisplay || 'All Classes';
    document.getElementById('docModalType').textContent        = d.type         || '\u2014';
    document.getElementById('docModalFileName').textContent    = d.originalFile || '\u2014';

    var a = '';
    if (d.uploadedBy === myId) {
        a += '<button class="btn btn-secondary" onclick="openEditModal()">Edit</button>';
        a += '<button class="btn btn-danger"    onclick="openDeleteModal()">Delete</button>';
    }
    a += '<a class="btn btn-primary"         href="../downloadDocument?id=' + d.id + '">Download</a>';
    a += '<button class="btn btn-secondary"  onclick="closeDocModal()">Close</button>';
    document.getElementById('docModalActions').innerHTML = a;
    document.getElementById('docDetailsModal').classList.add('active');
}

function closeDocModal()           { document.getElementById('docDetailsModal').classList.remove('active'); }
function closeDocModalOnOverlay(e) { if (e.target === e.currentTarget) closeDocModal(); }

function openDeleteModal() {
    closeDocModal();
    document.getElementById('deleteDocResult').innerHTML = '';
    document.getElementById('deleteDocModal').classList.add('active');
}
function closeDeleteModal() { document.getElementById('deleteDocModal').classList.remove('active'); }

function confirmDelete() {
    fetch('../deleteDocument', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'documentId=' + dlCurrentDoc.id
    }).then(function(r) { return r.text(); })
      .then(function(html) {
        document.getElementById('deleteDocResult').innerHTML = html;
        if (html.toLowerCase().indexOf('success') >= 0) {
            setTimeout(function() { closeDeleteModal(); dlLoad(); }, 1200);
        }
    });
}

function openEditModal() {
    closeDocModal();
    var d = dlCurrentDoc;
    document.getElementById('editDocId').value           = d.id;
    document.getElementById('editDocTitle').value        = d.title        || '';
    document.getElementById('editDocType').value         = d.type         || 'NOTES';
    document.getElementById('editDocClass').value        = d.classId      || '';
    document.getElementById('editDocSubject').value      = d.subjectId    || '';
    document.getElementById('editDocDescription').value  = d.description  || '';
    document.getElementById('editDocFile').value         = '';
    document.getElementById('editDocResult').innerHTML   = '';
    document.getElementById('editDocModal').classList.add('active');
}
function closeEditModal()          { document.getElementById('editDocModal').classList.remove('active'); }
function closeEditModalOuter(e)    { if (e.target === e.currentTarget) closeEditModal(); }

function updateDocument(e) {
    e.preventDefault();
    var fd = new FormData();
    fd.append('documentId',   document.getElementById('editDocId').value);
    fd.append('title',        document.getElementById('editDocTitle').value);
    fd.append('documentType', document.getElementById('editDocType').value);
    fd.append('classId',      document.getElementById('editDocClass').value);
    fd.append('subjectId',    document.getElementById('editDocSubject').value);
    fd.append('description',  document.getElementById('editDocDescription').value);
    var file = document.getElementById('editDocFile').files[0];
    if (file) fd.append('documentFile', file);
    fetch('../updateDocument', {method:'POST', body:fd})
        .then(function(r) { return r.text(); })
        .then(function(html) {
            document.getElementById('editDocResult').innerHTML = html;
            if (html.toLowerCase().indexOf('success') >= 0) {
                setTimeout(function() { closeEditModal(); dlLoad(); }, 1200);
            }
        });
}

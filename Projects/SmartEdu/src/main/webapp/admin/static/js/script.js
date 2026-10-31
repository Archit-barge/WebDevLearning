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

function toggleLoginPassword() {
	const passwordInput = document.getElementById("password");
	const eyeIcon = document.getElementById("loginPasswordEye");
	if (!passwordInput || !eyeIcon) return;

	const show = passwordInput.type === "password";
	passwordInput.type = show ? "text" : "password";
	eyeIcon.className = show ? "fa-solid fas fa-eye-slash" : "fa-solid fas fa-eye";
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
	fetch("../PageLoader?page=" + filename)
		.then(response => {
			if (!response.ok) {
				throw new Error("Page not found");
			}
			return response.text();
		})
		.then(data => {
			document.getElementById("main-content").innerHTML = data;
			localStorage.setItem("lastPage", filename);
			closeSidebar();

			let links = document.querySelectorAll(".sidebar-menu a");
			links.forEach(link => link.classList.remove("active"));
			let activeLink = Array.from(links).find(link =>
				link.getAttribute("onclick") === `loadPage('${filename}')`
			);
			if (activeLink) activeLink.classList.add("active");

			if (filename === 'view_timetable.jsp') {
				if (typeof loadTimetablesTable === 'function') setTimeout(loadTimetablesTable, 50);
			} else if (filename === 'document_library.jsp') {
				if (typeof loadDocumentsTable === 'function') setTimeout(loadDocumentsTable, 50);
			} else if (filename === 'post_doc.jsp') {
				if (typeof initPostDocUpload === 'function') setTimeout(initPostDocUpload, 50);
			} else if (filename === 'admin_announcements.jsp') {
				if (typeof loadAdminAnnouncementsTable === 'function') setTimeout(loadAdminAnnouncementsTable, 50);
			} else if (filename === 'teacherTasks.jsp') {
				if (typeof initTeacherTasksPage === 'function') setTimeout(initTeacherTasksPage, 50);
			}

			// Attach dynamic filter clear button listeners
			attachFilterListeners(filename);
		})
		.catch(error => {
			document.getElementById("main-content").innerHTML =
				"<h1>404</h1><p>Page not found.</p>";
		});
}

function attachFilterListeners(filename) {
	// Utility to set up filter dependencies
	const setupDynamicClear = (buttonId, inputIds) => {
		const btn = document.getElementById(buttonId);
		if (!btn) return;

		const inputs = inputIds.map(id => document.getElementById(id)).filter(el => el);
		if (inputs.length === 0) return;

		const toggleBtn = (show) => {
			if (show) {
				btn.classList.remove('ux-hidden', 'u-hidden');
				btn.style.display = '';
			} else {
				btn.classList.add('ux-hidden');
				btn.style.display = 'none';
			}
		};

		const checkFilters = () => {
			const hasValue = inputs.some(el => el.value.trim() !== "");
			toggleBtn(hasValue);
		};

		inputs.forEach(el => {
			el.addEventListener('input', checkFilters);
			el.addEventListener('change', checkFilters);
		});

		checkFilters();
	};

	if (filename === 'view_students.jsp') {
		setupDynamicClear('clearStudentsFilterBtn', ['search', 'classFilter', 'genderFilter']);
	} else if (filename === 'view_parents.jsp') {
		setupDynamicClear('clearParentsFilterBtn', ['parentSearch']);
	} else if (filename === 'view_teachers.jsp') {
		setupDynamicClear('clearTeachersFilterBtn', ['teacherSearch', 'teacherClassFilter', 'teacherSubjectFilter']);
	} else if (filename === 'view_admins.jsp') {
		setupDynamicClear('clearAdminsFilterBtn', ['adminSearch']);
	} else if (filename === 'view_timetable.jsp') {
		setupDynamicClear('clearTimetableFilterBtn', ['timetableSearch', 'timetableClassFilter', 'timetableUploaderFilter']);
	} else if (filename === 'document_library.jsp') {
		setupDynamicClear('clearDocFilterBtn', ['docSearch', 'docClassFilter', 'docSubjectFilter', 'docTypeFilter', 'docUploaderFilter']);
	} else if (filename === 'teacherTasks.jsp') {
		setupDynamicClear('clearTeacherTasksFilterBtn', ['teacherTaskTeacherId', 'teacherTaskClassId', 'teacherTaskSubjectId', 'teacherTaskStartDate', 'teacherTaskEndDate']);
	}
}

let appDeleteConfirmHandler = null;

function ensureDeleteConfirmModal() {
	let modal = document.getElementById("appDeleteConfirmModal");
	if (modal) return modal;

	modal = document.createElement("div");
	modal.id = "appDeleteConfirmModal";
	modal.className = "modal-overlay";
	modal.innerHTML = `
		<div class="modal-container" style="max-width: 520px;">
			<div class="modal-header">
				<h2>Confirm Delete</h2>
				<button class="modal-close" type="button" onclick="closeDeleteConfirmModal()">&times;</button>
			</div>
			<p id="appDeleteConfirmMessage">Are you sure you want to delete this item?</p>
			<div class="form-actions">
				<button class="btn btn-secondary" type="button" onclick="closeDeleteConfirmModal()">Cancel</button>
				<button class="btn btn-danger" type="button" onclick="confirmDeleteConfirmModal()">Delete</button>
			</div>
		</div>
	`;

	modal.addEventListener("click", function (e) {
		if (e.target === modal) {
			closeDeleteConfirmModal();
		}
	});

	document.body.appendChild(modal);
	return modal;
}

function showModalById(modalId) {
	const modal = document.getElementById(modalId);
	if (!modal) return null;
	modal.classList.remove("ux-hidden", "u-hidden");
	modal.classList.add("active");
	modal.style.display = "flex";
	return modal;
}

function hideModalById(modalId) {
	const modal = document.getElementById(modalId);
	if (!modal) return null;
	modal.classList.remove("active");
	modal.classList.add("ux-hidden");
	modal.style.display = "none";
	return modal;
}

function openDeleteConfirmModal(message, onConfirm) {
	const modal = ensureDeleteConfirmModal();
	const msg = document.getElementById("appDeleteConfirmMessage");
	if (msg) msg.textContent = message || "Are you sure you want to delete this item?";
	appDeleteConfirmHandler = onConfirm;
	showModalById("appDeleteConfirmModal");
}

function closeDeleteConfirmModal() {
	hideModalById("appDeleteConfirmModal");
	appDeleteConfirmHandler = null;
}

function confirmDeleteConfirmModal() {
	if (typeof appDeleteConfirmHandler === "function") {
		appDeleteConfirmHandler();
	}
	closeDeleteConfirmModal();
}

function confirmDeleteForm(formEl, message) {
	openDeleteConfirmModal(message || "Are you sure you want to delete this item?", function () {
		if (formEl) formEl.submit();
	});
	return false;
}

function toggleSidebar() {
	let sidebar = document.getElementsByClassName("sidebar")[0];
	let overlay = document.getElementById("sidebarOverlay");
	let toggleDiv = document.querySelector(".mobile-toggle");
	if (sidebar) {
		sidebar.classList.toggle("active");
	}
	if (overlay) {
		overlay.classList.toggle("active");
	}
	if (toggleDiv) {
		toggleDiv.classList.toggle("hidden", sidebar && sidebar.classList.contains("active"));
	}
	document.body.classList.toggle("sidebar-open");
}

function closeSidebar() {
	let sidebar = document.getElementsByClassName("sidebar")[0];
	let overlay = document.getElementById("sidebarOverlay");
	let toggleDiv = document.querySelector(".mobile-toggle");
	if (sidebar) sidebar.classList.remove("active");
	if (overlay) overlay.classList.remove("active");
	if (toggleDiv) toggleDiv.classList.remove("hidden");
	document.body.classList.remove("sidebar-open");
}

document.addEventListener('DOMContentLoaded', function () {
	let toggleBtn = document.getElementById('sidebarToggle');
	if (toggleBtn) {
		toggleBtn.addEventListener('click', toggleSidebar);
	}
	let overlay = document.getElementById('sidebarOverlay');
	if (overlay) {
		overlay.addEventListener('click', closeSidebar);
	}

	let sidebar = document.querySelector(".sidebar");
	let toggleDiv = document.querySelector(".mobile-toggle");
	let menuLinks = document.querySelectorAll(".sidebar-menu a");

	menuLinks.forEach(function (link) {
		link.addEventListener("click", function () {
			if (window.innerWidth <= 1024) {
				closeSidebar();
			}
		});
	});

	document.addEventListener("click", function (e) {
		if (window.innerWidth <= 1024 && sidebar && sidebar.classList.contains("active")) {
			if (!sidebar.contains(e.target) && (!toggleDiv || !toggleDiv.contains(e.target))) {
				closeSidebar();
			}
		}
	});
});

// ADD ADMIN PAGE

function toggleAdminPassword() {
	const passwordInput = document.getElementById("adminPassword");
	const eyeIcon = document.getElementById("adminPasswordEye");
	if (!passwordInput || !eyeIcon) return;

	const show = passwordInput.type === "password";
	passwordInput.type = show ? "text" : "password";
	eyeIcon.className = show ? "fa-solid fas fa-eye-slash" : "fa-solid fas fa-eye";
}

function validateAdminForm() {
	const requiredIds = [
		"adminUsername",
		"adminPassword",
		"adminEmail",
		"adminFirstName",
		"adminLastName"
	];

	for (let id of requiredIds) {
		const el = document.getElementById(id);
		if (!el || !el.value.trim()) {
			alert("Please fill in all required fields.");
			if (el) el.focus();
			return false;
		}
	}

	const email = document.getElementById("adminEmail").value;
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (!emailRegex.test(email)) {
		alert("Please enter a valid email address.");
		document.getElementById("adminEmail").focus();
		return false;
	}
	return true;
}

function addAdmin(event) {
	event.preventDefault();

	if (!validateAdminForm()) {
		return;
	}

	const username = document.getElementById("adminUsername").value;
	const password = document.getElementById("adminPassword").value;
	const email = document.getElementById("adminEmail").value;
	const firstName = document.getElementById("adminFirstName").value;
	const lastName = document.getElementById("adminLastName").value;
	const phone = document.getElementById("adminPhone").value;
	const address = document.getElementById("adminAddress").value;

	const form = event.target;
	const submitBtn = form.querySelector("button[type='submit']");
	const originalText = submitBtn ? submitBtn.innerHTML : "";
	if (submitBtn) {
		submitBtn.disabled = true;
		submitBtn.innerHTML = "<i class='fas fa-spinner fa-spin'></i> Adding...";
	}

	const params =
		"username=" + encodeURIComponent(username) +
		"&password=" + encodeURIComponent(password) +
		"&email=" + encodeURIComponent(email) +
		"&firstName=" + encodeURIComponent(firstName) +
		"&lastName=" + encodeURIComponent(lastName) +
		"&phone=" + encodeURIComponent(phone) +
		"&address=" + encodeURIComponent(address);

	const xhr = new XMLHttpRequest();
	xhr.open("GET", "../addAdmin?" + params, true);

	xhr.onreadystatechange = function () {
		if (this.readyState === 4) {
			const resultDiv = document.getElementById("addAdminResult");
			if (resultDiv) {
				resultDiv.innerHTML = this.responseText || "";

				const container = document.querySelector(".main-content") || window;
				const top = form.getBoundingClientRect().top + window.pageYOffset - 80;
				container === window
					? window.scrollTo({ top, behavior: "smooth" })
					: container.scrollTo({ top: 0, behavior: "smooth" });
			}

			if (submitBtn) {
				submitBtn.disabled = false;
				submitBtn.innerHTML = originalText;
			}

			if (this.status === 200) {
				setTimeout(function () {
					form.reset();
					if (resultDiv) resultDiv.innerHTML = "";
				}, 1500);
			}
		}
	};

	xhr.send();
}

// ADD STUDENT PAGE

function validateForm() {
	const requiredFields = [
		"username",
		"password",
		"email",
		"rollNumber",
		"firstName",
		"lastName",
		"dateOfBirth",
		"gender",
	];

	for (let field of requiredFields) {
		const element = document.getElementById(field);
		if (!element.value.trim()) {
			alert("Please fill in all required fields.");
			element.focus();
			return false;
		}
	}

	const email = document.getElementById("email").value;
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (!emailRegex.test(email)) {
		alert("Please enter a valid email address.");
		document.getElementById("email").focus();
		return false;
	}

	return true;
}

let admissionDate = document.getElementById('admissionDate');
if (admissionDate) {
	admissionDate.value = new Date().toISOString().split('T')[0];
}

// VIEW STUDENTS PAGE

function loadStudentsTable() {
	let search = document.getElementById("search") ? document.getElementById("search").value : "";
	let classFilter = document.getElementById("classFilter") ? document.getElementById("classFilter").value : "";
	let genderFilter = document.getElementById("genderFilter") ? document.getElementById("genderFilter").value : "";

	let xmlhttp = new XMLHttpRequest();
	let url = "../getStudentTable?search=" + encodeURIComponent(search) +
		"&class=" + encodeURIComponent(classFilter) +
		"&gender=" + encodeURIComponent(genderFilter);

	xmlhttp.open("GET", url, true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState !== 4) return;

		let tableBody = document.getElementById("studentTableBody");
		if (!tableBody) return;

		if (this.status === 200) {
			tableBody.innerHTML = this.responseText;
		} else {
			tableBody.innerHTML = "<tr><td colspan='6' class='table-cell-error'>Failed to load students.</td></tr>";
		}
	};
}

function openEditStudentModal(studentId, fullName, rollNumber, username, email, dateOfBirth, gender, phone, classId, address, admissionDate, password) {
	let modal = document.getElementById("editStudentModal");
	if (!modal) {
		console.error("Edit student modal not found!");
		return;
	}

	let fields = {
		'editStudentId': studentId,
		'editUsername': username,
		'editEmail': email,
		'editRollNumber': rollNumber,
		'editFirstName': fullName.split(' ')[0],
		'editLastName': fullName.split(' ')[1] || "",
		'editDateOfBirth': dateOfBirth || "",
		'editGender': gender || "",
		'editPhone': phone || "",
		'editClassId': classId || "",
		'editAddress': address || "",
		'editAdmissionDate': admissionDate || ""
	};

	for (let fieldId in fields) {
		let element = document.getElementById(fieldId);
		if (element) {
			element.value = fields[fieldId];
		}
	}

	let pwd = document.getElementById("editPassword");
	if (pwd) {
		pwd.value = password || "";
	}

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditStudentModal() {
	let modal = document.getElementById("editStudentModal");
	if (modal) {
		modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
	}

	let resultDiv = document.getElementById("editStudentResult");
	if (resultDiv) {
		resultDiv.innerHTML = "";
	}
}

function updateStudent() {
	let studentId = document.getElementById("editStudentId").value;
	let firstName = document.getElementById("editFirstName").value;
	let lastName = document.getElementById("editLastName").value;
	let rollNumber = document.getElementById("editRollNumber").value;
	let username = document.getElementById("editUsername").value;
	let email = document.getElementById("editEmail").value;
	let dateOfBirth = document.getElementById("editDateOfBirth").value;
	let gender = document.getElementById("editGender").value;
	let phone = document.getElementById("editPhone").value;
	let classId = document.getElementById("editClassId").value;
	let address = document.getElementById("editAddress").value;
	let admissionDate = document.getElementById("editAdmissionDate").value;
	let password = document.getElementById("editPassword") ? document.getElementById("editPassword").value : ""; // NEW

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open(
		"GET",
		"../updateStudent?studentId=" + studentId +
		"&firstName=" + encodeURIComponent(firstName) +
		"&lastName=" + encodeURIComponent(lastName) +
		"&rollNumber=" + encodeURIComponent(rollNumber) +
		"&username=" + encodeURIComponent(username) +
		"&email=" + encodeURIComponent(email) +
		"&dateOfBirth=" + encodeURIComponent(dateOfBirth) +
		"&gender=" + encodeURIComponent(gender) +
		"&phone=" + encodeURIComponent(phone) +
		"&classId=" + encodeURIComponent(classId) +
		"&address=" + encodeURIComponent(address) +
		"&admissionDate=" + encodeURIComponent(admissionDate) +
		"&password=" + encodeURIComponent(password),
		true
	);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("editStudentResult")) {
				document.getElementById("editStudentResult").innerHTML = this.responseText;
			}
			if (this.status === 200) {
				setTimeout(function () {
					closeEditStudentModal();
					loadStudentsTable();
					loadStudentsStats();
				}, 1500);
			}
		}
	};
}

function openViewModal(studentId, fullName, username, email, rollNumber, dateOfBirth, gender, phone, className, address, admissionDate, status, password) {
	let modal = document.getElementById("viewDetailsModal");
	if (!modal) {
		console.error("View details modal not found!");
		return;
	}

	const normalizeValue = (value, fallback = "") => {
		if (value === null || value === undefined) return fallback;
		if (value === "null" || value === "undefined") return fallback;
		return value;
	};

	const nameParts = normalizeValue(fullName).trim().split(/\s+/).filter(Boolean);
	const firstName = nameParts.length ? nameParts[0] : "";
	const lastName = nameParts.length > 1 ? nameParts.slice(1).join(" ") : "";

	let fields = {
		'detailFirstName': firstName,
		'detailLastName': lastName,
		'detailUsername': normalizeValue(username, "-"),
		'detailEmail': normalizeValue(email, "-"),
		'detailRollNumber': normalizeValue(rollNumber, "-"),
		'detailDateOfBirth': normalizeValue(dateOfBirth, "-"),
		'detailGender': normalizeValue(gender, "-"),
		'detailPhone': normalizeValue(phone, "-"),
		'detailClass': normalizeValue(className, "-"),
		'detailAddress': normalizeValue(address, "-"),
		'detailAdmissionDate': normalizeValue(admissionDate, "-"),
		'detailStatus': normalizeValue(status, "-"),
		'detailPassword': normalizeValue(password, "")
	};

	for (let fieldId in fields) {
		let element = document.getElementById(fieldId);
		if (element) {
			element.textContent = fields[fieldId];
		}
	}

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeViewDetailsModal() {
	let modal = document.getElementById("viewDetailsModal");
	if (modal) {
		modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
	}
}

function deleteStudent(studentId, studentName) {
	openDeleteConfirmModal("Are you sure you want to delete student '" + studentName + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteStudent?studentId=" + studentId, true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4 && this.status === 200) {
				loadStudentsTable();
				loadStudentsStats();
			}
		};
	});
}

function loadStudentsStats() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getStudentStats", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let statsGrid = document.getElementById("studentStats");
			if (statsGrid) {
				statsGrid.innerHTML = this.responseText;
			}
		}
	};
}

// VIEW TEACHERS PAGE

function loadTeachersTable() {
	let search = document.getElementById("teacherSearch") ? document.getElementById("teacherSearch").value : "";
	let classFilter = document.getElementById("teacherClassFilter") ? document.getElementById("teacherClassFilter").value : "";
	let subjectFilter = document.getElementById("teacherSubjectFilter") ? document.getElementById("teacherSubjectFilter").value : "";

	let xmlhttp = new XMLHttpRequest();
	let url = "../getTeacherTable?search=" + encodeURIComponent(search) +
		"&class=" + encodeURIComponent(classFilter) +
		"&subject=" + encodeURIComponent(subjectFilter);

	xmlhttp.open("GET", url, true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let tableBody = document.getElementById("teachersTableBody");
			if (tableBody) {
				tableBody.innerHTML = this.responseText;
			}
		}
	};
}

function openEditTeacherModal(teacherId, fullName, username, email, employeeId, phone,
	classId, subjectId, address, password) {

	let modal = document.getElementById("editTeacherModal");
	if (!modal) {
		console.error("Edit teacher modal not found!");
		return;
	}

	let first = fullName.split(' ')[0] || "";
	let last = fullName.split(' ')[1] || "";

	let fields = {
		'editTeacherId': teacherId,
		'editTeacherUsername': username,
		'editTeacherEmail': email,
		'editEmployeeId': employeeId,
		'editTeacherFirstName': first,
		'editTeacherLastName': last,
		'editTeacherPhone': phone || "",
		'editTeacherClassId': classId || "",
		'editTeacherSubjectId': subjectId || "",
		'editTeacherAddress': address || ""
	};

	for (let id in fields) {
		let el = document.getElementById(id);
		if (el) el.value = fields[id];
	}

	let pwd = document.getElementById("editTeacherPassword");
	if (pwd) {
		pwd.value = password || "";
	}

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditTeacherModal() {
	let modal = document.getElementById("editTeacherModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";

	let resultDiv = document.getElementById("editTeacherResult");
	if (resultDiv) resultDiv.innerHTML = "";
}

function updateTeacher() {
	let teacherId = document.getElementById("editTeacherId").value;
	let username = document.getElementById("editTeacherUsername").value;
	let password = document.getElementById("editTeacherPassword").value;
	let email = document.getElementById("editTeacherEmail").value;
	let employeeId = document.getElementById("editEmployeeId").value;
	let firstName = document.getElementById("editTeacherFirstName").value;
	let lastName = document.getElementById("editTeacherLastName").value;
	let phone = document.getElementById("editTeacherPhone").value;
	let classId = document.getElementById("editTeacherClassId").value;
	let subjectId = document.getElementById("editTeacherSubjectId").value;
	let address = document.getElementById("editTeacherAddress").value;

	if (!firstName.trim() || !lastName.trim() || !employeeId.trim() ||
		!username.trim() || !email.trim() || !password.trim()) {
		alert("Please fill in all required fields.");
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open(
		"GET",
		"../updateTeacher?" +
		"teacherId=" + encodeURIComponent(teacherId) +
		"&firstName=" + encodeURIComponent(firstName) +
		"&lastName=" + encodeURIComponent(lastName) +
		"&employeeId=" + encodeURIComponent(employeeId) +
		"&username=" + encodeURIComponent(username) +
		"&email=" + encodeURIComponent(email) +
		"&password=" + encodeURIComponent(password) +
		"&phone=" + encodeURIComponent(phone) +
		"&classId=" + encodeURIComponent(classId) +
		"&subjectId=" + encodeURIComponent(subjectId) +
		"&address=" + encodeURIComponent(address),
		true
	);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			let resultDiv = document.getElementById("editTeacherResult");
			if (resultDiv) {
				resultDiv.innerHTML = this.responseText;
			}
			if (this.status === 200) {
				setTimeout(function () {
					closeEditTeacherModal();
					loadTeachersTable();
				}, 1500);
			}
		}
	};
}

function openViewTeacherModal(fullName, username, email, employeeId, phone,
	className, subjectName, address, password) {

	let modal = document.getElementById("viewTeacherModal");
	if (!modal) {
		console.error("View teacher modal not found!");
		return;
	}

	const normalizeValue = (value, fallback = "") => {
		if (value === null || value === undefined) return fallback;
		if (value === "null" || value === "undefined") return fallback;
		return value;
	};

	const nameParts = normalizeValue(fullName).trim().split(/\s+/).filter(Boolean);
	let first = nameParts.length ? nameParts[0] : "";
	let last = nameParts.length > 1 ? nameParts.slice(1).join(" ") : "";

	let fields = {
		'detailTeacherUsername': normalizeValue(username, "-"),
		'detailTeacherPassword': normalizeValue(password, ""),
		'detailTeacherEmail': normalizeValue(email, "-"),
		'detailEmployeeId': normalizeValue(employeeId, "-"),
		'detailTeacherFirstName': first,
		'detailTeacherLastName': last,
		'detailTeacherPhone': normalizeValue(phone, "-"),
		'detailTeacherAddress': normalizeValue(address, "-"),
		'detailTeacherClass': normalizeValue(className, "-"),
		'detailTeacherSubject': normalizeValue(subjectName, "-")
	};

	for (let id in fields) {
		let el = document.getElementById(id);
		if (el) el.textContent = fields[id];
	}

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeViewTeacherModal() {
	let modal = document.getElementById("viewTeacherModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function deleteTeacher(teacherId, teacherName) {
	openDeleteConfirmModal("Are you sure you want to delete teacher '" + teacherName + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteTeacher?teacherId=" + teacherId, true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4 && this.status === 200) {
				loadTeachersTable();

			}
		};
	});
}

document.addEventListener('DOMContentLoaded', function () {
	let searchInput = document.getElementById("teacherSearch");
	if (searchInput) {
		searchInput.addEventListener("input", function () {
			loadTeachersTable();
		});
	}

	let classFilter = document.getElementById("teacherClassFilter");
	if (classFilter) {
		classFilter.addEventListener("change", function () {
			loadTeachersTable();
		});
	}

	let subjectFilter = document.getElementById("teacherSubjectFilter");
	if (subjectFilter) {
		subjectFilter.addEventListener("change", function () {
			loadTeachersTable();
		});
	}
});

// VIEW ADMINS

function loadAdminsTable() {
	const searchInput = document.getElementById('adminSearch');
	const search = searchInput ? searchInput.value.trim() : '';

	fetch('../getAdminTable?search=' + encodeURIComponent(search), {
		method: 'GET'
	})
		.then(res => res.text())
		.then(html => {
			const body = document.getElementById('adminsTableBody');
			if (body) {
				body.innerHTML = html;
			}
		})
		.catch(err => console.error('Error loading admins table', err));
}

function openViewAdminModal(fullName, username, email, phone, password, address) {
	const modal = document.getElementById('viewAdminDetailsModal');
	if (!modal) return;

	const normalizeValue = (value, fallback = "") => {
		if (value === null || value === undefined) return fallback;
		if (value === "null" || value === "undefined") return fallback;
		return value;
	};

	document.getElementById('detailAdminFullName').textContent = normalizeValue(fullName, '-');
	document.getElementById('detailAdminUsername').textContent = normalizeValue(username, '-');
	document.getElementById('detailAdminEmail').textContent = normalizeValue(email, '-');
	document.getElementById('detailAdminPhone').textContent = normalizeValue(phone, '-');
	document.getElementById('detailAdminPassword').textContent = normalizeValue(password, '');
	document.getElementById('detailAdminAddress').textContent = normalizeValue(address, '-');

	modal.classList.remove('ux-hidden', 'u-hidden');
	modal.classList.add('active');
	modal.style.display = 'flex';
}

function closeViewAdminModal() {
	const modal = document.getElementById('viewAdminDetailsModal');
	if (modal) modal.classList.remove('active');
	modal.classList.add('ux-hidden');
	modal.style.display = 'none';
}

function openEditAdminModal(adminId, fullName, username, email, phone, password, address) {
	const modal = document.getElementById('editAdminModal');
	if (!modal) {
		console.error('editAdminModal not found');
		return;
	}

	fullName = fullName || '';
	const parts = fullName.trim().split(/\s+/, 2);
	const firstName = parts.length > 0 ? parts[0] : '';
	const lastName = parts.length > 1 ? parts[1] : '';

	document.getElementById('editAdminId').value = adminId;
	document.getElementById('editAdminUsername').value = username || '';
	document.getElementById('editAdminPassword').value = password || '';
	document.getElementById('editAdminEmail').value = email || '';
	document.getElementById('editAdminFirstName').value = firstName;
	document.getElementById('editAdminLastName').value = lastName;
	document.getElementById('editAdminPhone').value = phone || '';
	document.getElementById('editAdminAddress').value = address || '';

	const res = document.getElementById('editAdminResult');
	if (res) res.innerHTML = '';

	modal.classList.remove('ux-hidden', 'u-hidden');
	modal.classList.add('active');
	modal.style.display = 'flex';
}

function closeEditAdminModal() {
	const modal = document.getElementById('editAdminModal');
	if (modal) modal.classList.remove('active');
	modal.classList.add('ux-hidden');
	modal.style.display = 'none';

	const res = document.getElementById('editAdminResult');
	if (res) res.innerHTML = '';
}

function updateAdmin() {
	const id = document.getElementById('editAdminId').value;
	const username = document.getElementById('editAdminUsername').value.trim();
	const password = document.getElementById('editAdminPassword').value.trim();
	const email = document.getElementById('editAdminEmail').value.trim();
	const firstName = document.getElementById('editAdminFirstName').value.trim();
	const lastName = document.getElementById('editAdminLastName').value.trim();
	const phone = document.getElementById('editAdminPhone').value.trim();
	const address = document.getElementById('editAdminAddress').value.trim();

	if (!username || !password || !email || !firstName || !lastName) {
		alert('All required fields must be filled.');
		return;
	}

	const params = new URLSearchParams();
	params.append('adminId', id);
	params.append('username', username);
	params.append('password', password);
	params.append('email', email);
	params.append('firstName', firstName);
	params.append('lastName', lastName);
	params.append('phone', phone);
	params.append('address', address);

	fetch('../UpdateAdminServlet', {
		method: 'POST',
		headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
		body: params.toString()
	})
		.then(res => res.text())
		.then(text => {
			const resDiv = document.getElementById('editAdminResult');
			if (resDiv) resDiv.innerHTML = text;

			if (text.toLowerCase().includes('success')) {
				setTimeout(() => {
					closeEditAdminModal();
					loadAdminsTable();
				}, 800);
			}
		})
		.catch(err => console.error('Error updating admin', err));
}

// DELETE ADMIN

let deleteAdminId = null;

function openDeleteAdminModal(adminId, fullName) {
	deleteAdminId = adminId;
	const nameEl = document.getElementById('deleteAdminName');
	if (nameEl) nameEl.textContent = fullName;
	const modal = document.getElementById('deleteAdminModal');
	if (modal) modal.classList.remove('ux-hidden', 'u-hidden');
	modal.classList.add('active');
	modal.style.display = 'flex';
}

function closeDeleteAdminModal() {
	const modal = document.getElementById('deleteAdminModal');
	if (modal) modal.classList.remove('active');
	modal.classList.add('ux-hidden');
	modal.style.display = 'none';
	deleteAdminId = null;
}

function confirmDeleteAdmin() {
	if (deleteAdminId == null) return;

	const params = new URLSearchParams();
	params.append('adminId', deleteAdminId);

	fetch('../DeleteAdminServlet', {
		method: 'POST',
		headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
		body: params.toString()
	})
		.then(res => res.text())
		.then(msg => {
			closeDeleteAdminModal();
			loadAdminsTable();
		})
		.catch(err => console.error('Error deleting admin', err));
}

// MANAGE SUBJECTS PAGE

function addSubject() {
	if (!document.subjectForm) {
		console.log("subjectForm not found");
		return;
	}

	let subjectName = document.subjectForm.subjectName.value;
	let subjectCode = document.subjectForm.subjectCode.value;
	let description = document.subjectForm.description.value;

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../addSubject?subjectName="
		+ encodeURIComponent(subjectName) + "&subjectCode="
		+ encodeURIComponent(subjectCode) + "&description="
		+ encodeURIComponent(description), true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("result")) {
				document.getElementById("result").innerHTML = this.responseText || "No response";
			}
			if (this.status === 200) {
				if (document.subjectForm) {
					document.subjectForm.subjectName.value = "";
					document.subjectForm.subjectCode.value = "";
					document.subjectForm.description.value = "";
				}

				setTimeout(function () {
					loadSubjectsTable();
					loadSubjectsStats();
				}, 1000);
			}
		}
	};
}

function loadSubjectsTable() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getSubjectTable", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let tableBody = document.getElementById("subjectsTableBody");
			if (tableBody) {
				tableBody.innerHTML = this.responseText;
			}
		}
	};
}

function loadSubjectsStats() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getSubjectStat", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let statCard = document.getElementById("totalSubjectsCount");
			if (statCard) {
				statCard.innerHTML = this.responseText;
			}
		}
	};
}
function openEditSubjectModal(id, name, code, desc) {
	let modal = document.getElementById("editSubjectModal");
	if (!modal) {
		console.error("editSubjectModal not found");
		return;
	}

	document.getElementById("editSubjectId").value = id;
	document.getElementById("editSubjectName").value = name || "";
	document.getElementById("editSubjectCode").value = code || "";
	document.getElementById("editSubjectDescription").value = desc || "";
	let res = document.getElementById("editSubjectResult");
	if (res) res.innerHTML = "";

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditSubjectModal() {
	let modal = document.getElementById("editSubjectModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function updateSubject() {
	let id = document.getElementById("editSubjectId").value;
	let name = document.getElementById("editSubjectName").value.trim();
	let code = document.getElementById("editSubjectCode").value.trim();
	let desc = document.getElementById("editSubjectDescription").value.trim();

	if (!name || !code) {
		alert("Subject name and code are required.");
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open(
		"GET",
		"../updateSubject?subjectId=" + encodeURIComponent(id) +
		"&subjectName=" + encodeURIComponent(name) +
		"&subjectCode=" + encodeURIComponent(code) +
		"&description=" + encodeURIComponent(desc),
		true
	);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			let res = document.getElementById("editSubjectResult");
			if (res) res.innerHTML = this.responseText || "";

			if (this.status === 200) {
				setTimeout(function () {
					closeEditSubjectModal();
					loadSubjectsTable();
					loadSubjectsStats();
				}, 800);
			}
		}
	};
}

function deleteSubject(id, name) {
	openDeleteConfirmModal("Delete subject '" + name + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteSubject?subjectId=" + encodeURIComponent(id), true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4 && this.status === 200) {
				let res = document.getElementById("result");
				if (res) res.innerHTML = this.responseText;
				if (this.responseText === "OK") {
					loadSubjectsTable();
					loadSubjectsStats();
				}
			}
		};
	});
}

// MANAGE CLASSES PAGE 

function loadClassesTable() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getClassTable", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			const table = document.getElementById("classesTableBody");
			if (!table) return;

			// Split-table mode: endpoint may return <thead> + <tbody>, but we only need rows in body table.
			const temp = document.createElement("table");
			temp.innerHTML = this.responseText;
			const parsedBody = temp.querySelector("tbody");
			const targetBody = table.querySelector("tbody");

			if (targetBody && parsedBody) {
				targetBody.innerHTML = parsedBody.innerHTML;
			} else if (targetBody) {
				targetBody.innerHTML = this.responseText;
			} else {
				table.innerHTML = this.responseText;
			}
		}
	};
}

function loadClassesStats() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getClassStat", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let statsGrid = document.getElementById("classesStats");
			if (statsGrid) {
				statsGrid.innerHTML = this.responseText;
			}
		}
	};
}

function addClass() {
	if (!document.classForm) {
		console.log("classForm not found");
		return;
	}
	let className = document.classForm.className.value;
	let section = document.classForm.section.value;
	let capacity = document.classForm.capacity.value;
	let classTeacherId = document.classForm.classTeacherId.value;

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../addClass?className=" + encodeURIComponent(className) + "&section=" + encodeURIComponent(section) + "&capacity=" + encodeURIComponent(capacity) + "&classTeacherId=" + encodeURIComponent(classTeacherId), true);
	xmlhttp.send();
	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("classResult")) {
				document.getElementById("classResult").innerHTML = this.responseText || "No response";
			}
			if (this.status === 200) {
				if (document.classForm) {
					document.classForm.className.value = "";
					document.classForm.section.value = "";
					document.classForm.capacity.value = "";
					document.classForm.classTeacherId.value = "";
				}
				setTimeout(function () {
					loadClassesTable();
					loadClassesStats();
				}, 1000);
			}
		}
	};
}


function openEditClassModal(classId, className, section, capacity, teacherId) {
	let modal = document.getElementById("editModal");
	if (!modal) {
		console.error("Edit modal not found!");
		return;
	}

	let fields = {
		'editClassId': classId,
		'editClassName': className,
		'editSection': section || "",
		'editCapacity': capacity || 40,
		'editClassTeacherId': teacherId || ""
	};

	for (let fieldId in fields) {
		let element = document.getElementById(fieldId);
		if (element) {
			element.value = fields[fieldId];
		}
	}

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditModal() {
	let modal = document.getElementById("editModal");
	if (modal) {
		modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
	}

	let resultDiv = document.getElementById("editResult");
	if (resultDiv) {
		resultDiv.innerHTML = "";
	}
}

function updateClass() {
	let classId = document.getElementById("editClassId").value;
	let className = document.getElementById("editClassName").value;
	let section = document.getElementById("editSection").value;
	let capacity = document.getElementById("editCapacity").value;
	let classTeacherId = document.getElementById("editClassTeacherId").value;

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open(
		"GET",
		"../updateClass?classId=" + classId +
		"&className=" + encodeURIComponent(className) +
		"&section=" + encodeURIComponent(section) +
		"&capacity=" + encodeURIComponent(capacity) +
		"&classTeacherId=" + encodeURIComponent(classTeacherId),
		true
	);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			let editResult = document.getElementById("editResult");
			if (editResult) {
				editResult.innerHTML = this.responseText;
			}
			if (this.status === 200) {
				setTimeout(function () {
					closeEditModal();
					loadClassesTable();
					loadClassesStats();
				}, 1500);
			}
		}
	};
}

function deleteClass(classId, classDisplayName) {
	openDeleteConfirmModal("Are you sure you want to delete class '" + classDisplayName + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteClass?classId=" + classId, true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4 && this.status === 200) {
				loadClassesTable();
				loadClassesStats();
			}
		};
	});
}

//Post Document(Syllabus and Notes)
let currentDocId = null;

function initPostDocUpload() {
    const fileInput = document.getElementById("documentFileInput");
    const fileName = document.getElementById("selectedDocFileName");
    if (!fileInput || !fileName) return;

    fileInput.addEventListener("change", function () {
        fileName.textContent = (fileInput.files && fileInput.files[0]) ? fileInput.files[0].name : "No file chosen";
    });
}

function uploadDocument() {
    const form = document.getElementById("documentForm");
    const resultBox = document.getElementById("docResult");
    if (!form || !resultBox) return;

    const formData = new FormData(form);
    const title = (formData.get("title") || "").toString().trim();
    const docType = (formData.get("documentType") || "").toString().trim();
    const file = formData.get("documentFile");

    if (!title || !docType || !(file instanceof File) || file.size === 0) {
        resultBox.innerHTML = "<div class='error'>Title, document type, and file are required.</div>";
        return;
    }

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "../uploadDocument", true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            resultBox.innerHTML = xhr.responseText;
            if (xhr.status === 200 && xhr.responseText.includes("alert-success")) {
                form.reset();
                const selected = document.getElementById("selectedDocFileName");
                if (selected) selected.textContent = "No file chosen";
            }
        }
    };
    xhr.send(formData);
}

function openDocModal(card) {
	if (!card) return;

	currentDocId = card.dataset.docId;

	const title = card.dataset.title && card.dataset.title.trim() ? card.dataset.title.trim() : "-";
	const desc = card.dataset.desc && card.dataset.desc.trim() ? card.dataset.desc.trim() : "-";
	const type = card.dataset.type && card.dataset.type.trim() ? card.dataset.type.trim() : "-";
	const uploader = card.dataset.uploader && card.dataset.uploader.trim() ? card.dataset.uploader.trim() : "-";

	const originalFile =
		card.dataset.originalFile &&
			card.dataset.originalFile !== "null" &&
			card.dataset.originalFile.trim()
			? card.dataset.originalFile.trim()
			: "-";


    const subjectText =
        card.dataset.subjectName && card.dataset.subjectName !== "null" && card.dataset.subjectName.trim()
            ? card.dataset.subjectName.trim()
            : "General";
    const className = card.dataset.className && card.dataset.className !== "null" ? card.dataset.className.trim() : "";
    const classSection = card.dataset.classSection && card.dataset.classSection !== "null" ? card.dataset.classSection.trim() : "";
    const classText = className ? className + (classSection ? " - " + classSection : "") : "All Classes";

	document.getElementById("docModalTitle").textContent = title;
	document.getElementById("docModalDescription").textContent = desc;
	document.getElementById("docModalType").textContent = type;
	document.getElementById("docModalUploader").textContent = uploader;
	document.getElementById("docModalFileName").textContent = originalFile;
	document.getElementById("docModalSubject").textContent = subjectText;
	document.getElementById("docModalClass").textContent = classText;

	const modal = document.getElementById("docDetailsModal");
	if (modal) modal.classList.add("active");
}



function closeDocModal() {
	const modal = document.getElementById("docDetailsModal");
	if (modal) modal.classList.remove("active");
	currentDocId = null;
}

function closeDocModalOnOverlay(e) {
	if (e.target.id === "docDetailsModal") {
		closeDocModal();
	}
}

document.addEventListener("click", function (e) {
	if (e.target.closest(".doc-download-btn")) {
		e.stopPropagation();
	}
});

function downloadDocument() {
	if (!currentDocId) return;

	const url = "../downloadDocument?id=" + encodeURIComponent(currentDocId);

	const a = document.createElement("a");
	a.href = url;
	a.style.display = "none";
	document.body.appendChild(a);
	a.click();
	document.body.removeChild(a);
}

function openDocumentInNewTab() {
	if (!currentDocId) return;
	const url = "../downloadDocument?id=" + encodeURIComponent(currentDocId) + "&inline=true";
	window.open(url, "_blank");
}

let deleteDocId = null;

function openDeleteDocumentModal() {
	if (!currentDocId) return;

	deleteDocId = currentDocId;

	const modal = document.getElementById("deleteDocumentModal");
	if (modal) modal.classList.add("active");
}

function closeDeleteDocumentModal() {
	const modal = document.getElementById("deleteDocumentModal");
	if (modal) modal.classList.remove("active");

	deleteDocId = null;
}

function confirmDeleteDocument() {
	if (!deleteDocId) return;

	const xhr = new XMLHttpRequest();
	xhr.open("POST", "../deleteDocument", true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			const res = document.getElementById("deleteDocumentResult");
			if (res) res.innerHTML = xhr.responseText;

			if (xhr.status === 200 && xhr.responseText.includes("alert-success")) {
				setTimeout(() => {
					closeDeleteDocumentModal();
					closeDocModal();
					location.reload();
				}, 1200);
			}
		}
	};

	xhr.send("documentId=" + encodeURIComponent(deleteDocId));
}

function openEditDocumentModal() {
	if (!currentDocId) return;

	const card = document.querySelector(`.doc-card[data-doc-id="${currentDocId}"]`);
	if (!card) return;

	document.getElementById("editDocId").value = currentDocId;
	document.getElementById("editDocTitle").value = card.dataset.title || "";
	document.getElementById("editDocDescription").value = card.dataset.desc || "";
	document.getElementById("editDocType").value = card.dataset.type || "";

	document.getElementById("editDocFileName").value =
		card.dataset.originalFile && card.dataset.originalFile !== "null"
			? card.dataset.originalFile
			: "";

	document.getElementById("editDocClass").value =
		card.dataset.classId && card.dataset.classId !== "null"
			? card.dataset.classId
			: "";

	document.getElementById("editDocSubject").value =
		card.dataset.subjectId && card.dataset.subjectId !== "null"
			? card.dataset.subjectId
			: "";

	const fileInput = document.getElementById("editDocFile");
	if (fileInput) fileInput.value = "";

	document.getElementById("editDocumentModal").classList.add("active");
}


function closeEditDocumentModal() {
	const modal = document.getElementById("editDocumentModal");
	if (modal) modal.classList.remove("active");
}

function updateDocument(e) {
	e.preventDefault();

	const formData = new FormData();
	formData.append("documentId", document.getElementById("editDocId").value);
	formData.append("title", document.getElementById("editDocTitle").value.trim());
	formData.append("documentType", document.getElementById("editDocType").value);
	formData.append("classId", document.getElementById("editDocClass").value);
	formData.append("subjectId", document.getElementById("editDocSubject").value);
	formData.append("description", document.getElementById("editDocDescription").value.trim());
	formData.append("originalFileName", document.getElementById("editDocFileName").value.trim());

	const fileInput = document.getElementById("editDocFile");
	if (fileInput && fileInput.files && fileInput.files[0]) {
		formData.append("documentFile", fileInput.files[0]);
	}

	const xhr = new XMLHttpRequest();
	xhr.open("POST", "../updateDocument", true);

	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			document.getElementById("editDocumentResult").innerHTML = xhr.responseText;

			if (xhr.status === 200 && xhr.responseText.includes("alert-success")) {
				setTimeout(() => location.reload(), 1200);
			}
		}
	};

	xhr.send(formData);
}

// ===========================================
// Document Library AJAX Filtering
// ===========================================

function loadDocumentsTable() {
	let search = document.getElementById("docSearch") ? document.getElementById("docSearch").value : "";
	let classId = document.getElementById("docClassFilter") ? document.getElementById("docClassFilter").value : "";
	let subjectId = document.getElementById("docSubjectFilter") ? document.getElementById("docSubjectFilter").value : "";
	let docType = document.getElementById("docTypeFilter") ? document.getElementById("docTypeFilter").value : "";
	let uploaderRole = document.getElementById("docUploaderFilter") ? document.getElementById("docUploaderFilter").value : "";

	let url = "../getDocumentTable?search=" + encodeURIComponent(search) +
		"&classId=" + encodeURIComponent(classId) +
		"&subjectId=" + encodeURIComponent(subjectId) +
		"&docType=" + encodeURIComponent(docType) +
		"&uploaderRole=" + encodeURIComponent(uploaderRole) +
		"&_=" + new Date().getTime();

	let xhr = new XMLHttpRequest();
	xhr.open("GET", url, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			let grid = document.getElementById("docGrid");
			let countEl = document.getElementById("documentsCountText");
			if (xhr.status === 200 && grid) {
				grid.innerHTML = xhr.responseText;
				if (countEl) {
					const cards = grid.querySelectorAll(".doc-card.doc-library-card").length;
					countEl.textContent = cards + " documents";
				}
			} else if (countEl) {
				countEl.textContent = "0 documents";
			}
		}
	};
	xhr.send();
}

// ===========================================
// Admin Announcements Functions
// ===========================================
const ADMIN_ANN_ENDPOINTS = {
	create: "../createAdminAnnouncement",
	previewWhatsapp: "../previewAdminAnnouncementWhatsApp",
	update: "../updateAdminAnnouncement",
	delete: "../deleteAdminAnnouncement",
	table: "../getAdminAnnouncementsTable"
};

function loadAdminAnnouncementsTable() {
	const xhr = new XMLHttpRequest();
	xhr.open("GET", ADMIN_ANN_ENDPOINTS.table + "?_=" + new Date().getTime(), true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			const grid = document.getElementById("announcementsGrid");
			if (!grid) return;

			if (xhr.status === 200) {
				grid.innerHTML = xhr.responseText;
				const cards = grid.querySelectorAll(".announcement-card").length;
				const countEl = document.getElementById("announcementsCountText");
				if (countEl) countEl.textContent = cards + " announcements";
			} else {
				grid.innerHTML = "<div class='alert alert-error'><i class='fas fa-exclamation-triangle'></i> Failed to load announcements.</div>";
				const countEl = document.getElementById("announcementsCountText");
				if (countEl) countEl.textContent = "0 announcements";
			}
		}
	};
	xhr.send();
}

let pendingAdminAnnouncementPreview = null;

function buildAdminAnnouncementPayload() {
	const titleEl = document.getElementById("annTitle");
	const classEl = document.getElementById("annClassId");
	const descEl = document.getElementById("annDescription");

	return {
		title: titleEl ? titleEl.value.trim() : "",
		classId: classEl ? classEl.value : "",
		description: descEl ? descEl.value.trim() : ""
	};
}

function postAdminAnnouncementAction(endpoint, payload, done) {
	const params = new URLSearchParams();
	params.append("title", payload.title || "");
	params.append("classId", payload.classId || "");
	params.append("description", payload.description || "");
	if (payload.sendToWhatsapp) {
		params.append("sendToWhatsapp", "true");
	}

	const xhr = new XMLHttpRequest();
	const target = ADMIN_ANN_ENDPOINTS[endpoint] || ("../" + endpoint);
	xhr.open("POST", target, true);
	xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4 && typeof done === "function") {
			done(xhr);
		}
	};
	xhr.send(params.toString());
}

function setAdminAnnouncementResult(html) {
	const result = document.getElementById("adminAnnouncementResult");
	if (result) result.innerHTML = html || "";
}

function extractAlertData(html) {
	const data = {};
	const temp = document.createElement("div");
	temp.innerHTML = html || "";
	const alertBox = temp.querySelector(".alert");
	if (!alertBox) return data;

	for (let i = 0; i < alertBox.attributes.length; i++) {
		const attr = alertBox.attributes[i];
		if (attr && attr.name && attr.name.indexOf("data-") === 0) {
			const key = attr.name.substring(5);
			data[key] = attr.value || "";
		}
	}
	return data;
}

function copyTextToClipboard(text, cb) {
	if (navigator.clipboard && navigator.clipboard.writeText) {
		navigator.clipboard.writeText(text).then(function () {
			if (typeof cb === "function") cb(true);
		}).catch(function () {
			fallbackCopyText(text, cb);
		});
		return;
	}
	fallbackCopyText(text, cb);
}

function fallbackCopyText(text, cb) {
	const ta = document.createElement("textarea");
	ta.value = text || "";
	ta.setAttribute("readonly", "readonly");
	ta.style.position = "fixed";
	ta.style.opacity = "0";
	document.body.appendChild(ta);
	ta.focus();
	ta.select();
	let ok = false;
	try {
		ok = document.execCommand("copy");
	} catch (e) {
		ok = false;
	}
	document.body.removeChild(ta);
	if (typeof cb === "function") cb(ok);
}

function createAdminAnnouncement(e) {
	if (e && typeof e.preventDefault === "function") e.preventDefault();

	const payload = buildAdminAnnouncementPayload();
	const hasClass = !!(payload.classId && payload.classId.trim() !== "");

	if (!hasClass) {
		postAdminAnnouncementAction("create", payload, function (xhr) {
			setAdminAnnouncementResult(xhr.responseText);
			if (xhr.status === 200 && xhr.responseText.toLowerCase().indexOf("alert-success") !== -1) {
				const titleEl = document.getElementById("annTitle");
				const classEl = document.getElementById("annClassId");
				const descEl = document.getElementById("annDescription");
				if (titleEl) titleEl.value = "";
				if (classEl) classEl.value = "";
				if (descEl) descEl.value = "";
				loadAdminAnnouncementsTable();
			}
		});
		return false;
	}

	postAdminAnnouncementAction("previewWhatsapp", payload, function (xhr) {
		setAdminAnnouncementResult(xhr.responseText);
		if (xhr.status !== 200 || xhr.responseText.toLowerCase().indexOf("alert-success") === -1) {
			return;
		}

		const data = extractAlertData(xhr.responseText);
		if ((data.preview || "").toLowerCase() !== "true") {
			return;
		}

			pendingAdminAnnouncementPreview = {
			title: payload.title,
			classId: payload.classId,
			description: payload.description,
			groupLink: data["group-link"] || "",
			message: data.message || "",
			classLabel: data["class-label"] || "Selected Class"
		};
			openAdminAnnouncementWhatsAppModal();
		});
	return false;
}

function openViewAnnouncementModal(btn) {
	const modal = document.getElementById("viewAnnouncementModal");
	if (!modal || !btn) return;

	document.getElementById("viewAnnTitle").textContent = btn.dataset.title || "-";
	document.getElementById("viewAnnDescription").textContent = btn.dataset.description || "-";
	document.getElementById("viewAnnTarget").textContent = btn.dataset.target || "General";
	document.getElementById("viewAnnCreated").textContent = btn.dataset.created || "-";
	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeViewAnnouncementModal() {
	const modal = document.getElementById("viewAnnouncementModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function openEditAnnouncementModal(btn) {
	const modal = document.getElementById("editAnnouncementModal");
	if (!modal || !btn) return;

	document.getElementById("editAnnId").value = btn.dataset.id || "";
	document.getElementById("editAnnTitle").value = btn.dataset.title || "";
	document.getElementById("editAnnDescription").value = btn.dataset.description || "";
	document.getElementById("editAnnClassId").value = btn.dataset.classId || "";
	const result = document.getElementById("editAnnouncementResult");
	if (result) result.innerHTML = "";
	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditAnnouncementModal() {
	const modal = document.getElementById("editAnnouncementModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function openAdminAnnouncementWhatsAppModal() {
	const modal = document.getElementById("whatsappAnnouncementModal");
	if (!modal || !pendingAdminAnnouncementPreview) return;

	const classEl = document.getElementById("waPreviewClassLabel");
	const messageEl = document.getElementById("waPreviewMessage");
	if (classEl) classEl.textContent = pendingAdminAnnouncementPreview.classLabel || "Selected Class";
	if (messageEl) messageEl.value = pendingAdminAnnouncementPreview.message || "";
	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function cancelAdminAnnouncementPreview() {
	pendingAdminAnnouncementPreview = null;
	const modal = document.getElementById("whatsappAnnouncementModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function confirmAdminAnnouncementAndSend() {
	if (!pendingAdminAnnouncementPreview) return;

	const payload = {
		title: pendingAdminAnnouncementPreview.title,
		classId: pendingAdminAnnouncementPreview.classId,
		description: pendingAdminAnnouncementPreview.description,
		sendToWhatsapp: true
	};

	postAdminAnnouncementAction("create", payload, function (xhr) {
		setAdminAnnouncementResult(xhr.responseText);
		if (xhr.status !== 200 || xhr.responseText.toLowerCase().indexOf("alert-success") === -1) {
			return;
		}

		const data = extractAlertData(xhr.responseText);
		const finalMessage = data.message || pendingAdminAnnouncementPreview.message || "";
		const finalGroupLink = data["group-link"] || pendingAdminAnnouncementPreview.groupLink || "";

		const titleEl = document.getElementById("annTitle");
		const classEl = document.getElementById("annClassId");
		const descEl = document.getElementById("annDescription");
		if (titleEl) titleEl.value = "";
		if (classEl) classEl.value = "";
		if (descEl) descEl.value = "";

		loadAdminAnnouncementsTable();
		cancelAdminAnnouncementPreview();

		copyTextToClipboard(finalMessage, function () {
			if (finalGroupLink) {
				window.open(finalGroupLink, "_blank");
			}
		});
	});
}

function updateAdminAnnouncement(e) {
	if (e && typeof e.preventDefault === "function") e.preventDefault();
	const form = document.getElementById("editAnnouncementForm");
	if (!form) return false;

	const params = new URLSearchParams(new FormData(form));
	const xhr = new XMLHttpRequest();
	xhr.open("POST", ADMIN_ANN_ENDPOINTS.update, true);
	xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			const result = document.getElementById("editAnnouncementResult");
			if (result) result.innerHTML = xhr.responseText;
			if (xhr.status === 200 && xhr.responseText.toLowerCase().includes("alert-success")) {
				setTimeout(function () {
					closeEditAnnouncementModal();
					loadAdminAnnouncementsTable();
				}, 600);
			}
		}
	};
	xhr.send(params.toString());
	return false;
}

function deleteAdminAnnouncement(id) {
	openDeleteConfirmModal("Delete this announcement?", function () {
		const xhr = new XMLHttpRequest();
		xhr.open("POST", ADMIN_ANN_ENDPOINTS.delete, true);
		xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		xhr.onreadystatechange = function () {
			if (xhr.readyState === 4) {
				const result = document.getElementById("adminAnnouncementResult");
				if (result) result.innerHTML = xhr.responseText;
				if (xhr.status === 200 && xhr.responseText.toLowerCase().includes("alert-success")) {
					loadAdminAnnouncementsTable();
				}
			}
		};
		xhr.send("id=" + encodeURIComponent(id));
	});
}

// ==================== WHATSAPP LINK MANAGEMENT ====================

function addWhatsAppLink() {
	if (!document.whatsappForm) {
		console.log("whatsappForm not found");
		return;
	}
	let classId = document.whatsappForm.classId.value;
	let whatsappLink = document.whatsappForm.whatsappLink.value;

	if (!classId) {
		document.getElementById("linkResult").innerHTML = "<p style='color: #dc2626;'>Please select a class</p>";
		return;
	}

	if (!whatsappLink) {
		document.getElementById("linkResult").innerHTML = "<p style='color: #dc2626;'>Please enter a WhatsApp link</p>";
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../addWhatsAppLink?classId=" + encodeURIComponent(classId) + "&whatsappLink=" + encodeURIComponent(whatsappLink), true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("linkResult")) {
				document.getElementById("linkResult").innerHTML = this.responseText || "No response";
			}
			if (this.status === 200) {
				if (document.whatsappForm) {
					document.whatsappForm.classId.value = "";
					document.whatsappForm.whatsappLink.value = "";
				}
				setTimeout(function () {
					location.reload();
				}, 1500);
			}
		}
	};
}

function loadLinksTable() {
	let classFilter = document.getElementById("classFilter") ? document.getElementById("classFilter").value : "all";

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getWhatsAppLinks?class=" + encodeURIComponent(classFilter), true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let tbody = document.getElementById("linksTableBody");
			if (tbody) {
				tbody.innerHTML = this.responseText;
			}
		}
	};
}

function openEditLinkModal(classId, className, section, link) {
	let modal = document.getElementById("editLinkModal");
	if (!modal) {
		console.error("Edit link modal not found!");
		return;
	}

	document.getElementById("editClassId").value = classId;
	let displayName = className + (section ? " - " + section : "");
	document.getElementById("editClassName").value = displayName;
	document.getElementById("editWhatsAppLink").value = link;

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function updateWhatsAppLink() {
	let classId = document.getElementById("editClassId").value;
	let whatsappLink = document.getElementById("editWhatsAppLink").value;

	if (!whatsappLink) {
		document.getElementById("editResult").innerHTML = "<p style='color: #dc2626;'>Please enter a WhatsApp link</p>";
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open(
		"GET",
		"../updateWhatsAppLink?classId=" + encodeURIComponent(classId) + "&whatsappLink=" + encodeURIComponent(whatsappLink),
		true
	);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			let editResult = document.getElementById("editResult");
			if (editResult) {
				editResult.innerHTML = this.responseText;
			}
			if (this.status === 200) {
				setTimeout(function () {
					closeEditLinkModal();
					location.reload();
				}, 1500);
			}
		}
	};
}

function deleteWhatsAppLink(classId, className) {
	openDeleteConfirmModal("Are you sure you want to delete the WhatsApp link for '" + className + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteWhatsAppLink?classId=" + classId, true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4 && this.status === 200) {
				location.reload();
			}
		};
	});
}

function closeEditLinkModal() {
	let modal = document.getElementById("editLinkModal");
	if (modal) {
		modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
		document.getElementById("editResult").innerHTML = "";
	}
}

// ===========================================
// Timetables Management Functions
// ===========================================

function loadTimetablesTable() {
	let search = document.getElementById("timetableSearch") ? document.getElementById("timetableSearch").value : "";
	let classId = document.getElementById("timetableClassFilter") ? document.getElementById("timetableClassFilter").value : "";
	let uploaderRole = document.getElementById("timetableUploaderFilter") ? document.getElementById("timetableUploaderFilter").value : "";

	let url = "../getAdminTimetables?search=" + encodeURIComponent(search) +
		"&classId=" + encodeURIComponent(classId) +
		"&uploaderRole=" + encodeURIComponent(uploaderRole) +
		"&_=" + new Date().getTime();

	let xhr = new XMLHttpRequest();
	xhr.open("GET", url, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			let grid = document.getElementById("timetableGrid");
			let countEl = document.getElementById("timetablesCountText");
			if (xhr.status === 200 && grid) {
				grid.innerHTML = xhr.responseText;
				if (countEl) {
					const cards = grid.querySelectorAll(".timetable-card").length;
					countEl.textContent = cards + " timetables";
				}
			} else if (countEl) {
				countEl.textContent = "0 timetables";
			}
		}
	};
	xhr.send();
}

function deleteTimetable(docId) {
	openDeleteConfirmModal("Are you sure you want to delete this timetable?", function () {
		const xhr = new XMLHttpRequest();
		xhr.open("POST", "../deleteAdminTimetable", true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		xhr.onreadystatechange = function () {
			if (xhr.readyState === 4) {
				loadTimetablesTable();
			}
		};

		xhr.send("documentId=" + encodeURIComponent(docId));
	});
}

function openEditTimetableModal(docId) {
	const card = document.querySelector(`.timetable-card[data-doc-id="${docId}"]`);
	if (!card) return;

	document.getElementById("editTimetableId").value = docId;
	document.getElementById("editTimetableTitle").value = card.dataset.title || "";
	document.getElementById("editTimetableDescription").value = card.dataset.desc || "";
	document.getElementById("editTimetableOriginalFile").value = card.dataset.originalFile || "";
	document.getElementById("editTimetableClass").value = card.dataset.classId || "";
	document.getElementById("editTimetableFile").value = "";

	const result = document.getElementById("editTimetableResult");
	if (result) result.innerHTML = "";

	const modal = document.getElementById("editTimetableModal");
	if (modal) modal.classList.add("active");
}

function closeEditTimetableModal() {
	const modal = document.getElementById("editTimetableModal");
	if (modal) modal.classList.remove("active");
}

function updateTimetable(e) {
	e.preventDefault();

	const formData = new FormData();
	formData.append("documentId", document.getElementById("editTimetableId").value);
	formData.append("title", document.getElementById("editTimetableTitle").value.trim());
	formData.append("description", document.getElementById("editTimetableDescription").value.trim());
	formData.append("documentType", "TIMETABLES");
	formData.append("classId", document.getElementById("editTimetableClass").value);
	formData.append("subjectId", "");
	formData.append("originalFileName", document.getElementById("editTimetableOriginalFile").value.trim());

	const fileInput = document.getElementById("editTimetableFile");
	if (fileInput && fileInput.files && fileInput.files[0]) {
		formData.append("documentFile", fileInput.files[0]);
	}

	const xhr = new XMLHttpRequest();
	xhr.open("POST", "../updateDocument", true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			const result = document.getElementById("editTimetableResult");
			if (result) result.innerHTML = xhr.responseText;

			if (xhr.status === 200 && xhr.responseText.includes("alert-success")) {
				setTimeout(function () {
					closeEditTimetableModal();
					loadTimetablesTable();
				}, 1100);
			}
		}
	};
	xhr.send(formData);
}

// ===========================================
// Parent Management Functions
// ===========================================

function loadParentsTable() {
	let search = document.getElementById("parentSearch").value;
	let url = "../getParentsTable?search=" + encodeURIComponent(search);

	let xhr = new XMLHttpRequest();
	xhr.open("GET", url, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4 && xhr.status === 200) {
			document.getElementById("parentsTableBody").innerHTML = xhr.responseText;
		}
	};
	xhr.send();
}

function searchStudentsForParent(context) {
	let searchInputId = context === 'add' ? 'addParentStudentSearch' : 'linkStudentSearch';
	let classFilterId = context === 'add' ? 'addParentClassFilter' : 'linkClassFilter';
	let resultsBodyId = context === 'add' ? 'addStudentSearchResults' : 'linkStudentSearchResults';

	let search = document.getElementById(searchInputId) ? document.getElementById(searchInputId).value : "";
	let classId = document.getElementById(classFilterId) ? document.getElementById(classFilterId).value : "";
	let excludeParentId = '';

	if (context === 'link') {
		excludeParentId = document.getElementById('linkParentId').value;
	}

	let url = "../getParentStudentTable?search=" + encodeURIComponent(search) +
		"&classId=" + encodeURIComponent(classId) +
		"&excludeParentId=" + encodeURIComponent(excludeParentId);

	let xhr = new XMLHttpRequest();
	xhr.open("GET", url, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4 && xhr.status === 200) {
			let tbody = document.getElementById(resultsBodyId);
			if (tbody) {
				tbody.innerHTML = xhr.responseText;

				// Update onclick handlers to pass context
				let buttons = tbody.getElementsByTagName("button");
				for (let btn of buttons) {
					let currentOnClick = btn.getAttribute("onclick");
					if (currentOnClick && !currentOnClick.includes(", '" + context + "')")) {
						let parts = currentOnClick.split(")");
						let newOnClick = parts[0] + ", '" + context + "')";
						btn.setAttribute("onclick", newOnClick);
					}
				}
			}
		}
	};
	xhr.send();
}

// ... selectStudentForParent ... (unchanged)

// ... removeSelectedStudent ... (unchanged)

// ... loadLinkedStudents ... (unchanged)

// ... linkStudent ... (unchanged)

// ... unlinkStudent ... (unchanged)

// ... Parent Modals ... (unchanged)

function selectStudentForParent(studentId, name, rollNumber, context) {
	if (context === 'add') {
		let container = document.getElementById("selectedStudentsList");
		let parentContainer = document.getElementById("selectedStudentsContainer");

		if (document.getElementById("student-chip-" + studentId)) return;

		parentContainer.style.display = "block";

		let chip = document.createElement("div");
		chip.id = "student-chip-" + studentId;
		chip.className = "student-chip";
		chip.style.cssText = "display: inline-flex; align-items: center; background: #e2e8f0; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.875rem; color: #1e293b; margin-right: 0.5rem; margin-bottom: 0.5rem;";

		chip.innerHTML =
			'<span>' + name + ' (' + rollNumber + ')</span>' +
			'<input type="hidden" name="studentIds" value="' + studentId + '">' +
			'<button type="button" onclick="removeSelectedStudent(' + studentId + ')" style="margin-left: 0.5rem; background: none; border: none; cursor: pointer; color: #64748b; font-size: 1rem;">&times;</button>';

		container.appendChild(chip);

	} else if (context === 'link') {
		// Direct backend link
		let parentId = document.getElementById("linkParentId").value;
		linkStudent(parentId, studentId);
	} else if (context === 'import') {
		// Append roll number to the import preview row
		if (importLinkRowIndex >= 0) {
			var current = importUsersParsedData[importLinkRowIndex]['student_roll_numbers'] || '';
			if (current) {
				var rolls = current.split(',').map(function(r) { return r.trim(); });
				// Keep only known existing rolls so unresolved imported values can be corrected from the modal.
				rolls = rolls.filter(function(r) {
					if (!r) return false;
					if (typeof importKnownStudentRolls === 'undefined' || !importKnownStudentRolls || importKnownStudentRolls.size === 0) return true;
					return importKnownStudentRolls.has((r || '').trim().toLowerCase());
				});
				if (rolls.indexOf(rollNumber) === -1) rolls.push(rollNumber);
				importUsersParsedData[importLinkRowIndex]['student_roll_numbers'] = rolls.join(', ');
			} else {
				importUsersParsedData[importLinkRowIndex]['student_roll_numbers'] = rollNumber;
			}
			closeImportLinkStudentModal();
			renderImportPreviewTable();
		}
	}
}

function removeSelectedStudent(studentId) {
	let chip = document.getElementById("student-chip-" + studentId);
	if (chip) {
		chip.remove();
		let container = document.getElementById("selectedStudentsList");
		if (container.children.length === 0) {
			document.getElementById("selectedStudentsContainer").style.display = "none";
		}
	}
}

function loadLinkedStudents(parentId, containerId, allowUnlink) {
	let container = document.getElementById(containerId);
	if (container) {
		container.innerHTML = "Loading...";

		let xhr = new XMLHttpRequest();
		xhr.open("GET", "../linkParentStudent?action=list&parentId=" + parentId + "&allowUnlink=" + allowUnlink, true);
		xhr.onreadystatechange = function () {
			if (xhr.readyState === 4 && xhr.status === 200) {
				container.innerHTML = xhr.responseText;
			}
		};
		xhr.send();
	}
}

function linkStudent(parentId, studentId) {
	let xhr = new XMLHttpRequest();
	xhr.open("GET", "../linkParentStudent?action=link&parentId=" + parentId + "&studentId=" + studentId, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			if (xhr.status === 200) {
				loadLinkedStudents(parentId, 'linkCurrentStudents', true);

				// Remove from search results visually
				let btn = document.querySelector("#linkStudentSearchResults button[onclick*='selectStudentForParent(" + studentId + "']");
				if (btn) {
					btn.closest("tr").remove();
				}

				document.getElementById("linkParentResult").innerHTML = xhr.responseText;
			} else {
				document.getElementById("linkParentResult").innerHTML = "<p style='color:red'>Error linking student</p>";
			}
		}
	};
	xhr.send();
}

function unlinkStudent(parentId, studentId) {
	openDeleteConfirmModal("Are you sure you want to unlink this student?", function () {
		let xhr = new XMLHttpRequest();
		xhr.open("GET", "../linkParentStudent?action=unlink&parentId=" + parentId + "&studentId=" + studentId, true);
		xhr.onreadystatechange = function () {
			if (xhr.readyState === 4 && xhr.status === 200) {
				// refresh active modal list
				if (document.getElementById("editParentModal").classList.contains("active")) {
					loadLinkedStudents(parentId, 'editLinkedStudentsList', true);
				} else if (document.getElementById("linkParentModal").classList.contains("active")) {
					loadLinkedStudents(parentId, 'linkCurrentStudents', true);
					searchStudentsForParent('link');
				}
			}
		};
		xhr.send();
	});
}

// Parent Modals
function openEditParentModal(id, fname, lname, phone, email, address, relationship, username, password) {
	document.getElementById("editParentId").value = id;
	document.getElementById("editParentFirstName").value = fname;
	document.getElementById("editParentLastName").value = lname;
	document.getElementById("editParentPhone").value = phone;
	document.getElementById("editParentEmail").value = email;
	document.getElementById("editParentAddress").value = address;

	let relSelect = document.getElementById("editParentRelationship");
	relSelect.value = relationship.toLowerCase();

	let usernameInput = document.getElementById("editParentUsername");
	if (usernameInput) usernameInput.value = username || "";
	let passwordInput = document.getElementById("editParentPassword");
	if (passwordInput) passwordInput.value = password || "";

	document.getElementById("editParentResult").innerHTML = "";
	loadLinkedStudents(id, 'editLinkedStudentsList', true);
	showModalById("editParentModal");
}

function closeEditParentModal() {
	hideModalById("editParentModal");
}

function updateParent() {
	let id = document.getElementById("editParentId").value;
	let fname = document.getElementById("editParentFirstName").value;
	let lname = document.getElementById("editParentLastName").value;
	let phone = document.getElementById("editParentPhone").value;
	let email = document.getElementById("editParentEmail").value;
	let address = document.getElementById("editParentAddress").value;
	let relationship = document.getElementById("editParentRelationship").value;
	let username = document.getElementById("editParentUsername") ? document.getElementById("editParentUsername").value : "";
	let password = document.getElementById("editParentPassword") ? document.getElementById("editParentPassword").value : "";

	let xhr = new XMLHttpRequest();
	let params = "parentId=" + id +
		"&firstName=" + encodeURIComponent(fname) +
		"&lastName=" + encodeURIComponent(lname) +
		"&phone=" + encodeURIComponent(phone) +
		"&email=" + encodeURIComponent(email) +
		"&address=" + encodeURIComponent(address) +
		"&relationship=" + encodeURIComponent(relationship) +
		"&username=" + encodeURIComponent(username) +
		"&password=" + encodeURIComponent(password);

	xhr.open("GET", "../updateParent?" + params, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			document.getElementById("editParentResult").innerHTML = xhr.responseText;
			if (xhr.status === 200 && xhr.responseText.includes("successfully")) {
				loadParentsTable();
				setTimeout(closeEditParentModal, 1500);
			}
		}
	};
	xhr.send();
}

function openViewParentModal(parentId, fullName, username, email, phone, address, dummy, relationship, password) {
	let modal = document.getElementById("viewParentModal");
	if (!modal) {
		console.error("View parent modal not found!");
		return;
	}

	const normalizeValue = (value, fallback = "") => {
		if (value === null || value === undefined) return fallback;
		if (value === "null" || value === "undefined") return fallback;
		return value;
	};

	let fields = {
		'detailParentFullName': normalizeValue(fullName, "-"),
		'detailParentUsername': normalizeValue(username, "-"),
		'detailParentEmail': normalizeValue(email, "-"),
		'detailParentPhone': normalizeValue(phone, "-"),
		'detailParentAddress': normalizeValue(address, "-"),
		'detailParentRelationship': normalizeValue(relationship, "-"),
		'detailParentFullNamePersonal': normalizeValue(fullName, "-"),
		'detailParentPassword': normalizeValue(password, "")
	};

	for (let id in fields) {
		let el = document.getElementById(id);
		if (el) el.textContent = fields[id] || "-";
	}

	loadLinkedStudents(parentId, 'viewLinkedStudentsList', false);
	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeViewParentModal() {
	hideModalById("viewParentModal");
}

function openLinkParentModal(parentId, parentName) {
	document.getElementById("linkParentId").value = parentId;
	document.getElementById("linkParentName").innerText = parentName;
	document.getElementById("linkParentResult").innerHTML = "";
	loadLinkedStudents(parentId, 'linkCurrentStudents', true);
	searchStudentsForParent('link');

	showModalById("linkParentModal");
}

function closeLinkParentModal() {
	hideModalById("linkParentModal");
	loadParentsTable();
}

function searchStudentsForLink() {
	searchStudentsForParent('link');
}

function openDeleteParentModal(id, name) {
	document.getElementById("deleteParentName").innerText = name;
	let confirmBtn = document.querySelector("#deleteParentModal .btn-primary");
	confirmBtn.setAttribute("onclick", "confirmDeleteParent(" + id + ")");
	showModalById("deleteParentModal");
}

function closeDeleteParentModal() {
	hideModalById("deleteParentModal");
}

function confirmDeleteParent(id) {
	let xhr = new XMLHttpRequest();
	xhr.open("GET", "../deleteParent?parentId=" + id, true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			if (xhr.status === 200) {
				closeDeleteParentModal();
				loadParentsTable();
			}
		}
	};
	xhr.send();
}

// CLASS SUBJECTS MANAGEMENT

function addClassSubject() {
	if (!document.classSubjectForm) {
		console.log("classSubjectForm not found");
		return;
	}

	let classId = document.classSubjectForm.classId.value;
	let subjectId = document.classSubjectForm.subjectId.value;
	let teacherId = document.classSubjectForm.teacherId.value;

	if (!classId || classId.trim() === "") {
		alert("Please select a class");
		return;
	}

	if (!subjectId || subjectId.trim() === "") {
		alert("Please select a subject");
		return;
	}

	if (!teacherId || teacherId.trim() === "") {
		alert("Please select a teacher");
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../addClassSubject?classId=" + encodeURIComponent(classId)
		+ "&subjectId=" + encodeURIComponent(subjectId)
		+ "&teacherId=" + encodeURIComponent(teacherId), true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("result")) {
				document.getElementById("result").innerHTML = this.responseText || "No response";
			}
			if (this.status === 200) {
				if (document.classSubjectForm) {
					document.classSubjectForm.classId.value = "";
					document.classSubjectForm.subjectId.value = "";
					document.classSubjectForm.teacherId.value = "";
				}

				setTimeout(function () {
					loadClassSubjectsTable();
					loadClassSubjectsStats();
				}, 1000);
			}
		}
	};
}

function loadClassSubjectsTable() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getClassSubjectsTable", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let tableBody = document.getElementById("classSubjectsTableBody");
			if (tableBody) {
				tableBody.innerHTML = this.responseText;
			}
		}
	};
}

function loadClassSubjectsStats() {
	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../getClassSubjectsStat", true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4 && this.status === 200) {
			let statCard = document.getElementById("totalClassSubjectsCount");
			if (statCard) {
				statCard.innerHTML = this.responseText;
			}
		}
	};
}

function openEditClassSubjectModal(id, classId, subjectId, teacherId, className, subjectName, teacherName) {
	let modal = document.getElementById("editClassSubjectModal");
	if (!modal) {
		console.error("editClassSubjectModal not found");
		return;
	}

	document.getElementById("editClassSubjectId").value = id;
	document.getElementById("editClassId").value = classId;
	document.getElementById("editSubjectId").value = subjectId;
	document.getElementById("editTeacherId").value = teacherId || "";

	let res = document.getElementById("editClassSubjectResult");
	if (res) res.innerHTML = "";

	modal.classList.remove("ux-hidden", "u-hidden");modal.classList.add("active");modal.style.display = "flex";
}

function closeEditClassSubjectModal() {
	let modal = document.getElementById("editClassSubjectModal");
	if (modal) modal.classList.remove("active");modal.classList.add("ux-hidden");modal.style.display = "none";
}

function updateClassSubject() {
	let id = document.getElementById("editClassSubjectId").value;
	let classId = document.getElementById("editClassId").value;
	let subjectId = document.getElementById("editSubjectId").value;
	let teacherId = document.getElementById("editTeacherId").value;

	if (!id || id.trim() === "") {
		alert("Invalid class subject ID");
		return;
	}

	if (!classId || classId.trim() === "") {
		alert("Please select a class");
		return;
	}

	if (!subjectId || subjectId.trim() === "") {
		alert("Please select a subject");
		return;
	}

	if (!teacherId || teacherId.trim() === "") {
		alert("Please select a teacher");
		return;
	}

	let xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "../updateClassSubject?id=" + encodeURIComponent(id)
		+ "&classId=" + encodeURIComponent(classId)
		+ "&subjectId=" + encodeURIComponent(subjectId)
		+ "&teacherId=" + encodeURIComponent(teacherId), true);
	xmlhttp.send();

	xmlhttp.onreadystatechange = function () {
		if (this.readyState === 4) {
			if (document.getElementById("editClassSubjectResult")) {
				document.getElementById("editClassSubjectResult").innerHTML = this.responseText || "No response";
			}
			if (this.status === 200) {
				setTimeout(function () {
					closeEditClassSubjectModal();
					loadClassSubjectsTable();
					loadClassSubjectsStats();
				}, 1500);
			}
		}
	};
}

function deleteClassSubject(id, className, subjectName) {
	openDeleteConfirmModal("Are you sure you want to remove '" + subjectName + "' from '" + className + "'?", function () {
		let xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "../deleteClassSubject?id=" + encodeURIComponent(id), true);
		xmlhttp.send();

		xmlhttp.onreadystatechange = function () {
			if (this.readyState === 4) {
				if (this.status === 200) {
					loadClassSubjectsTable();
					loadClassSubjectsStats();
				}
			}
		};
	});
}


// =========== IMPORT USERS FEATURE ===========

let importUsersRole = 'student';
let importUsersParsedData = [];
let importUsersSelectedFile = null;
let importLinkRowIndex = -1;
let importClassesList = [];
let importSubjectsList = [];
let importKnownStudentRolls = new Set();

const IMPORT_ROLE_COLUMNS = {
	student: ['Username', 'Password', 'Email', 'Roll Number', 'First Name', 'Last Name', 'DOB', 'Gender', 'Phone', 'Class Name', 'Section', 'Address', 'Admission Date'],
	teacher: ['Username', 'Password', 'Email', 'Employee ID', 'First Name', 'Last Name', 'Phone', 'Address', 'Subject'],
	parent: ['Username', 'Password', 'Email', 'First Name', 'Last Name', 'Phone', 'Relationship', 'Address', 'Student Roll Numbers'],
	admin: ['Username', 'Password', 'Email', 'First Name', 'Last Name', 'Phone', 'Address']
};

const IMPORT_ROLE_REQUIRED = {
	student: ['Username', 'Password', 'Email', 'Roll Number', 'First Name', 'Last Name', 'DOB', 'Gender'],
	teacher: ['Username', 'Password', 'Email', 'Employee ID', 'First Name', 'Last Name'],
	parent: ['Username', 'Password', 'Email', 'First Name', 'Last Name', 'Relationship'],
	admin: ['Username', 'Password', 'Email', 'First Name', 'Last Name']
};

function normalizeImportRoll(roll) {
	return (roll || '').trim().toLowerCase();
}

function parseImportRollNumbers(rollNumbers) {
	if (!rollNumbers) return [];
	return String(rollNumbers)
		.split(/[,;\s]+/)
		.map(function (r) { return r.trim(); })
		.filter(function (r) { return r.length > 0; });
}

function escapeJsSingleQuoted(str) {
	return String(str || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

function hasImportWarning(row) {
	return !!(row && (row._subjectWarning || row._classWarning || row._parentRollWarning));
}

function seedImportKnownRollsFromTableBody(tbodyId) {
	var tbody = document.getElementById(tbodyId);
	if (!tbody) return;
	var rows = tbody.getElementsByTagName('tr');
	for (var i = 0; i < rows.length; i++) {
		var firstCell = rows[i].getElementsByTagName('td')[0];
		if (!firstCell) continue;
		var roll = (firstCell.textContent || '').trim();
		if (roll && roll !== '-') {
			importKnownStudentRolls.add(normalizeImportRoll(roll));
		}
	}
}

function setImportKnownRollsFromStudents(students) {
	if (!students || !students.length) return;
	students.forEach(function (s) {
		if (s && s.roll_number) {
			importKnownStudentRolls.add(normalizeImportRoll(s.roll_number));
		}
	});
}

window.switchRole = function (role) {
	importUsersRole = role;
	document.querySelectorAll('.import_users-content .role-tab').forEach(function (tab) {
		tab.classList.toggle('active', tab.getAttribute('data-role') === role);
	});
	resetImportUsers();
};

function initImportUsersDragDrop() {
	const dropZone = document.getElementById('dropZone');
	if (dropZone) {
		dropZone.addEventListener('dragover', function (e) {
			e.preventDefault(); dropZone.classList.add('dragover');
		});
		dropZone.addEventListener('dragleave', function () {
			dropZone.classList.remove('dragover');
		});
		dropZone.addEventListener('drop', function (e) {
			e.preventDefault(); dropZone.classList.remove('dragover');
			if (e.dataTransfer.files.length) {
				document.getElementById('fileInput').files = e.dataTransfer.files;
				onFileSelected(document.getElementById('fileInput'));
			}
		});
	}
	seedImportKnownRollsFromTableBody('linkStudentSearchResults');
}
document.addEventListener('DOMContentLoaded', initImportUsersDragDrop);

window.onFileSelected = function (input) {
	if (input.files && input.files[0]) {
		importUsersSelectedFile = input.files[0];
		const nameEl = document.getElementById('selectedFileName');
		if (nameEl) {
			nameEl.textContent = '\u{1F4C4} ' + importUsersSelectedFile.name;
			nameEl.classList.remove('ux-hidden', 'u-hidden');
			nameEl.style.display = 'block';
		}
		document.getElementById('scanBtn').disabled = false;
		const clearBtn = document.getElementById('clearBtn');
		if (clearBtn) {
			clearBtn.classList.remove('ux-hidden', 'u-hidden');
			clearBtn.style.display = 'inline-flex';
		}
	}
};

window.clearUpload = function () {
	importUsersSelectedFile = null;
	document.getElementById('fileInput').value = '';
	const selected = document.getElementById('selectedFileName');
	if (selected) {
		selected.style.display = 'none';
		selected.classList.add('ux-hidden');
		selected.textContent = '';
	}
	document.getElementById('scanBtn').disabled = true;
	const clearBtn = document.getElementById('clearBtn');
	if (clearBtn) {
		clearBtn.style.display = 'none';
		clearBtn.classList.add('ux-hidden');
	}
};

window.scanFile = function () {
	if (!importUsersSelectedFile) return;

	const scanBtn = document.getElementById('scanBtn');
	scanBtn.disabled = true;
	scanBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Scanning...';

	const formData = new FormData();
	formData.append('file', importUsersSelectedFile);
	formData.append('role', importUsersRole);

	const xhr = new XMLHttpRequest();
	xhr.open('POST', '../parseUploadFile', true);
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			scanBtn.disabled = false;
			scanBtn.innerHTML = '<i class="fas fa-search"></i> Scan File';

			if (xhr.status === 200) {
				try {
					importUsersParsedData = JSON.parse(xhr.responseText);
					if (importClassesList.length === 0 || importSubjectsList.length === 0) {
						var dxhr = new XMLHttpRequest();
						dxhr.open('GET', '../getStudentsList', true);
						dxhr.onreadystatechange = function() {
							if (dxhr.readyState === 4) {
								if (dxhr.status === 200) {
								try {
									var d = JSON.parse(dxhr.responseText);
									importClassesList = d.classes || [];
									importSubjectsList = d.subjects || [];
									setImportKnownRollsFromStudents(d.students || []);
								} catch(e) {}
								}
								renderImportPreviewTable();
							}
						};
						dxhr.send();
					} else {
						renderImportPreviewTable();
					}
				} catch (e) {
					alert('Error parsing server response. Please try again.');
				}
			} else {
				alert('Error scanning file (HTTP ' + xhr.status + '): ' + (xhr.responseText || 'Server error'));
			}
		}
	};
	xhr.send(formData);
};

function renderImportPreviewTable() {
	var cols = IMPORT_ROLE_COLUMNS[importUsersRole].slice();
	var required = IMPORT_ROLE_REQUIRED[importUsersRole];
	var previewCols = [];

	if (importUsersRole === 'student') {
		cols.forEach(function(col) {
			if (col === 'Class Name') { previewCols.push('Class'); }
			else if (col === 'Section') { }
			else { previewCols.push(col); }
		});
	} else {
		previewCols = cols.slice();
	}

	var headHtml = '<tr><th>#</th><th>Status</th>';
	previewCols.forEach(function(col) {
		headHtml += '<th>' + col + (required.indexOf(col) !== -1 ? ' *' : '') + '</th>';
	});
	if (importUsersRole === 'parent') headHtml += '<th>Action</th>';
	headHtml += '</tr>';
	document.getElementById('previewTableHead').innerHTML = headHtml;

	var readyCount = 0, invalidCount = 0, warningCount = 0;
	var bodyHtml = '';
	importUsersParsedData.forEach(function(row, i) {
		var isValid = row.valid !== 'false';
		row._subjectWarning = false;
		row._classWarning = false;
		row._parentRollWarning = false;
		row._parentMissingRolls = '';

		if (!isValid) invalidCount++;

		if (importUsersRole === 'teacher' && isValid) {
			var sv = row['subject'] || '';
			if (sv) {
				var sm = importSubjectsList.some(function(s) { return s.name && s.name.toLowerCase() === sv.toLowerCase(); });
				if (!sm) row._subjectWarning = true;
			}
		}

		if (importUsersRole === 'student' && isValid) {
			var classNameCheck = (row['class_name'] || '').trim();
			var sectionCheck = (row['section'] || '').trim();
			if (classNameCheck) {
				var combinedCheck = classNameCheck + (sectionCheck ? ' - ' + sectionCheck : '');
				var classMatched = importClassesList.some(function(c) {
					return c.name && c.name.toLowerCase() === combinedCheck.toLowerCase();
				});
				if (!classMatched) row._classWarning = true;
			}
		}

		if (importUsersRole === 'parent' && isValid) {
			var importedRolls = parseImportRollNumbers(row['student_roll_numbers'] || '');
			if (importedRolls.length > 0) {
				var missing = importedRolls.filter(function(r) {
					return !importKnownStudentRolls.has(normalizeImportRoll(r));
				});
				if (importKnownStudentRolls.size === 0 || missing.length > 0) {
					row._parentRollWarning = true;
					row._parentMissingRolls = (importKnownStudentRolls.size === 0) ? importedRolls.join(', ') : missing.join(', ');
				}
			}
		}

		var rowWarning = isValid && hasImportWarning(row);
		if (rowWarning) warningCount++;
		if (isValid && !rowWarning) readyCount++;

		var rowClass = !isValid ? 'row-invalid' : (rowWarning ? 'row-warning' : '');
		bodyHtml += '<tr class="' + rowClass + '">';
		bodyHtml += '<td>' + (i + 1) + '</td>';
		bodyHtml += '<td>';
		if (!isValid) {
			bodyHtml += '<span class="badge badge-invalid" title="' + (row.error || '') + '"><i class="fas fa-exclamation-triangle"></i> Invalid</span>';
		} else if (rowWarning) {
			var warningTitle = 'Resolve highlighted warnings before insertion';
			if (row._classWarning) warningTitle = 'Class/section not found in DB';
			else if (row._parentRollWarning) warningTitle = 'Some student roll numbers were not found';
			else if (row._subjectWarning) warningTitle = 'Subject not found in DB';
			bodyHtml += '<span class="badge badge-warning" title="' + escapeHtml(warningTitle) + '"><i class="fas fa-exclamation-circle"></i> Warning</span>';
		} else {
			bodyHtml += '<span class="badge badge-valid"><i class="fas fa-check-circle"></i> Valid</span>';
		}
		bodyHtml += '</td>';

		previewCols.forEach(function(col) {
			if (importUsersRole === 'student' && col === 'Class') {
				var className = row['class_name'] || '';
				var section = row['section'] || '';
				var combined = className + (section ? ' - ' + section : '');
				bodyHtml += '<td>';
				bodyHtml += '<select onchange="updateImportRowClass(' + i + ', this)" style="padding:0.3rem;border:1px solid #cbd5e1;border-radius:4px;font-size:16px;min-width:120px;">';
				bodyHtml += '<option value="">Select Class</option>';
				var matched = false;
				importClassesList.forEach(function(c) {
					var sel = '';
					if (combined && c.name && c.name.toLowerCase() === combined.toLowerCase()) { sel = ' selected'; matched = true; }
					bodyHtml += '<option value="' + escapeHtml(c.name) + '"' + sel + '>' + escapeHtml(c.name) + '</option>';
				});
				if (combined && !matched) {
					bodyHtml += '<option value="' + escapeHtml(combined) + '" selected style="color:#dc2626;">' + escapeHtml(combined) + ' (not found)</option>';
				}
				bodyHtml += '</select>';
				bodyHtml += '</td>';
			} else if (importUsersRole === 'teacher' && col === 'Subject') {
				var subjectVal = row['subject'] || '';
				var subMatched = false;
				if (subjectVal) {
					importSubjectsList.forEach(function(s) {
						if (s.name && s.name.toLowerCase() === subjectVal.toLowerCase()) subMatched = true;
					});
				}
				bodyHtml += '<td' + (subjectVal && !subMatched ? ' style="background:#fef9c3;"' : '') + '>';
				bodyHtml += '<select onchange="updateImportRowSubject(' + i + ', this)" style="padding:0.3rem;border:1px solid #cbd5e1;border-radius:4px;font-size:16px;min-width:120px;">';
				bodyHtml += '<option value="">Select Subject</option>';
				importSubjectsList.forEach(function(s) {
					var sel = (subjectVal && s.name && s.name.toLowerCase() === subjectVal.toLowerCase()) ? ' selected' : '';
					bodyHtml += '<option value="' + escapeHtml(s.name) + '"' + sel + '>' + escapeHtml(s.name) + '</option>';
				});
				if (subjectVal && !subMatched) {
					bodyHtml += '<option value="" selected style="color:#ca8a04;">' + escapeHtml(subjectVal) + ' (not in DB - select a valid subject)</option>';
				}
				bodyHtml += '</select>';
				bodyHtml += '</td>';
			} else if (importUsersRole === 'parent' && col === 'Student Roll Numbers') {
				var rollVal = row['student_roll_numbers'] || '';
				var rollCellStyle = row._parentRollWarning ? ' style="background:#fef9c3;"' : '';
				bodyHtml += '<td' + rollCellStyle + '>';
				var rollList = parseImportRollNumbers(rollVal);
				if (rollList.length === 0) {
					bodyHtml += '<span style="color:#94a3b8;">-</span>';
				} else {
					rollList.forEach(function(roll) {
						bodyHtml += '<span style="display:inline-flex;align-items:center;background:#e2e8f0;color:#1e293b;border-radius:999px;padding:2px 8px;margin:2px 6px 2px 0;font-size:13px;">';
						bodyHtml += '<span>' + escapeHtml(roll) + '</span>';
						bodyHtml += '<button type="button" title="Remove" onclick="removeImportParentRoll(' + i + ', \'' + escapeJsSingleQuoted(roll) + '\')" style="margin-left:6px;border:none;background:none;color:#475569;cursor:pointer;font-weight:700;line-height:1;">&times;</button>';
						bodyHtml += '</span>';
					});
				}
				if (row._parentRollWarning && row._parentMissingRolls) {
					bodyHtml += '<div style="font-size:12px;color:#854d0e;margin-top:4px;">Not found: ' + escapeHtml(row._parentMissingRolls) + '</div>';
				}
				bodyHtml += '</td>';
			} else {
				var key = col.toLowerCase().replace(/ /g, '_');
				var val = row[key] || '';
				bodyHtml += '<td>' + escapeHtml(val) + '</td>';
			}
		});
		if (importUsersRole === 'parent') {
			bodyHtml += '<td>';
			bodyHtml += '<button class="btn-link-student" onclick="openImportLinkStudentModal(' + i + ')"><i class="fas fa-link"></i> Link Student</button>';
			bodyHtml += '</td>';
		}
		bodyHtml += '</tr>';
	});
	document.getElementById('previewTableBody').innerHTML = bodyHtml;

	var statsHtml = '<span class="stat stat-total">' + importUsersParsedData.length + ' Total</span>';
	statsHtml += '<span class="stat stat-valid">' + readyCount + ' Ready</span>';
	if (warningCount > 0) statsHtml += '<span class="stat" style="background:#fef9c3;color:#854d0e;">' + warningCount + ' Warning</span>';
	if (invalidCount > 0) statsHtml += '<span class="stat stat-invalid">' + invalidCount + ' Invalid</span>';
	document.getElementById('previewStats').innerHTML = statsHtml;

	document.getElementById('previewSection').style.display = 'block';
	document.getElementById('confirmBtn').disabled = (readyCount === 0);
}

window.updateImportRowClass = function(rowIndex, selectEl) {
	var val = selectEl.value;
	if (val) {
		var parts = val.split(' - ');
		importUsersParsedData[rowIndex]['class_name'] = parts[0] || '';
		importUsersParsedData[rowIndex]['section'] = parts[1] || '';
	} else {
		importUsersParsedData[rowIndex]['class_name'] = '';
		importUsersParsedData[rowIndex]['section'] = '';
	}
	renderImportPreviewTable();
};

window.updateImportRowSubject = function(rowIndex, selectEl) {
	importUsersParsedData[rowIndex]['subject'] = selectEl.value;
	renderImportPreviewTable();
};

window.removeImportParentRoll = function(rowIndex, rollToRemove) {
	if (rowIndex < 0 || rowIndex >= importUsersParsedData.length) return;
	var current = importUsersParsedData[rowIndex]['student_roll_numbers'] || '';
	var rolls = parseImportRollNumbers(current);
	var target = (rollToRemove || '').trim().toLowerCase();
	rolls = rolls.filter(function(r) { return r.trim().toLowerCase() !== target; });
	importUsersParsedData[rowIndex]['student_roll_numbers'] = rolls.join(', ');
	renderImportPreviewTable();
};

window.loadImportDropdowns = function() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '../getStudentsList', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                importClassesList = data.classes || [];
                importSubjectsList = data.subjects || [];
				setImportKnownRollsFromStudents(data.students || []);
            } catch(e) {}
        }
    };
    xhr.send();
};

window.openImportLinkStudentModal = function(rowIndex) {
    importLinkRowIndex = rowIndex;
	showModalById('importLinkStudentModal');
	var searchEl = document.getElementById('linkStudentSearch');
	if (searchEl) searchEl.value = '';
    var classFilter = document.getElementById('linkClassFilter');
    if (classFilter) classFilter.value = '';
	seedImportKnownRollsFromTableBody('linkStudentSearchResults');
	searchImportLinkStudents();
};

window.closeImportLinkStudentModal = function() {
	hideModalById('importLinkStudentModal');
    importLinkRowIndex = -1;
};

window.searchImportLinkStudents = function() {
    var search = document.getElementById('linkStudentSearch') ? document.getElementById('linkStudentSearch').value : '';
    var classId = document.getElementById('linkClassFilter') ? document.getElementById('linkClassFilter').value : '';

    var url = '../getParentStudentTable?search=' + encodeURIComponent(search) +
        '&classId=' + encodeURIComponent(classId);

    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var tbody = document.getElementById('linkStudentSearchResults');
            if (tbody) {
                tbody.innerHTML = xhr.responseText;
				seedImportKnownRollsFromTableBody('linkStudentSearchResults');
                var buttons = tbody.getElementsByTagName('button');
                for (var i = 0; i < buttons.length; i++) {
                    var btn = buttons[i];
                    var currentOnClick = btn.getAttribute('onclick');
                    if (currentOnClick && currentOnClick.indexOf('selectStudentForParent') !== -1) {
                        var match = currentOnClick.match(/selectStudentForParent\((\d+),\s*'((?:\\'|[^'])*)',\s*'((?:\\'|[^'])*)'(?:,\s*'[^']*')?\)/);
                        if (match) {
							btn.setAttribute('onclick', "selectStudentForParent(" + match[1] + ", '" + match[2] + "', '" + match[3] + "', 'import')");
                        }
                    }
                }
            }
        }
    };
    xhr.send();
};

window.startBulkInsert = function () {
	const validRows = importUsersParsedData.filter(function (r) {
		return r.valid !== 'false' && !hasImportWarning(r);
	});
	if (validRows.length === 0) { alert('No ready rows to insert. Resolve warnings/errors first.'); return; }

	document.getElementById('summarySection').style.display = 'block';
	document.getElementById('loadingOverlay').style.display = 'block';
	document.getElementById('summaryResult').style.display = 'none';
	document.getElementById('loadingText').textContent = 'Inserting ' + validRows.length + ' users... please wait.';
	document.getElementById('confirmBtn').disabled = true;

	document.getElementById('summarySection').scrollIntoView({ behavior: 'smooth' });

	const xhr = new XMLHttpRequest();
	xhr.open('POST', '../bulkInsertUsers', true);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.onreadystatechange = function () {
		if (xhr.readyState === 4) {
			document.getElementById('loadingOverlay').style.display = 'none';
			document.getElementById('summaryResult').style.display = 'block';

			if (xhr.status === 200) {
				try {
					const results = JSON.parse(xhr.responseText);
					renderImportSummary(results);
				} catch (e) {
					alert('Error parsing insert results.');
				}
			} else {
				alert('Error during bulk insert: ' + (xhr.responseText || 'Server error'));
				document.getElementById('confirmBtn').disabled = false;
			}
		}
	};
	xhr.send(JSON.stringify({ role: importUsersRole, users: validRows }));
};

function renderImportSummary(results) {
	let successCount = 0;
	let bodyHtml = '';
	results.forEach(function (r, i) {
		const ok = r.success === 'true';
		if (ok) successCount++;
		bodyHtml += '<tr>';
		bodyHtml += '<td>' + (i + 1) + '</td>';
		bodyHtml += '<td>' + escapeHtml(r.name || '-') + '</td>';
		bodyHtml += '<td>' + escapeHtml(r.username || '-') + '</td>';
		bodyHtml += '<td>';
		if (ok) {
			bodyHtml += '<span class="badge badge-success"><i class="fas fa-check-circle"></i> Added</span>';
		} else {
			bodyHtml += '<span class="badge badge-error"><i class="fas fa-times-circle"></i> Failed</span>';
		}
		bodyHtml += '</td>';
		bodyHtml += '<td>' + escapeHtml(r.error || 'Success') + '</td>';
		bodyHtml += '</tr>';
	});
	document.getElementById('summaryTableBody').innerHTML = bodyHtml;

	const total = results.length;
	const pct = total > 0 ? Math.round((successCount / total) * 100) : 0;
	document.getElementById('progressBarFill').style.width = pct + '%';
	document.getElementById('progressText').textContent = successCount + ' / ' + total + ' users added successfully';

	const badge = document.getElementById('summaryBadge');
	if (successCount === total) {
		badge.className = 'badge badge-success';
		badge.innerHTML = '<i class="fas fa-check-circle"></i> All Successful';
	} else {
		badge.className = 'badge badge-error';
		badge.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + (total - successCount) + ' Failed';
	}
}

window.resetImportUsers = function () {
	importUsersParsedData = [];
	importUsersSelectedFile = null;
	importKnownStudentRolls = new Set();
	document.getElementById('fileInput').value = '';
	const selFileDiv = document.getElementById('selectedFileName');
	if (selFileDiv) {
		selFileDiv.style.display = 'none';
		selFileDiv.classList.add('ux-hidden');
		selFileDiv.textContent = '';
	}
	const sBtn = document.getElementById('scanBtn');
	if (sBtn) sBtn.disabled = true;
	const cBtn = document.getElementById('clearBtn');
	if (cBtn) {
		cBtn.style.display = 'none';
		cBtn.classList.add('ux-hidden');
	}
	const pSec = document.getElementById('previewSection');
	if (pSec) pSec.style.display = 'none';
	const sSec = document.getElementById('summarySection');
	if (sSec) sSec.style.display = 'none';
	const lOv = document.getElementById('loadingOverlay');
	if (lOv) lOv.style.display = 'none';
	const sRes = document.getElementById('summaryResult');
	if (sRes) sRes.style.display = 'none';
	const ptBody = document.getElementById('previewTableBody');
	if (ptBody) ptBody.innerHTML = '';
	const stBody = document.getElementById('summaryTableBody');
	if (stBody) stBody.innerHTML = '';
	seedImportKnownRollsFromTableBody('linkStudentSearchResults');
};

// Also expose resetImportUsers as resetAll to avoid breaking the inline HTML calls
window.resetAll = window.resetImportUsers;

function escapeHtml(str) {
	if (!str) return '';
	return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// TEACHER TASKS (ADMIN)
function getTeacherTasksFilters() {
	function getValue(id) {
		var el = document.getElementById(id);
		return el ? el.value : '';
	}
	return {
		teacherId: getValue('teacherTaskTeacherId') || '',
		classId: getValue('teacherTaskClassId') || '',
		subjectId: getValue('teacherTaskSubjectId') || '',
		startDate: getValue('teacherTaskStartDate') || '',
		endDate: getValue('teacherTaskEndDate') || ''
	};
}

function setTeacherTasksValidationState() {
	const filters = getTeacherTasksFilters();
	const rules = [
		{ group: 'teacherTaskTeacherGroup', ok: filters.teacherId !== '' },
		{ group: 'teacherTaskClassGroup', ok: filters.classId !== '' },
		{ group: 'teacherTaskSubjectGroup', ok: filters.subjectId !== '' }
	];
	let valid = true;
	rules.forEach(function (r) {
		const el = document.getElementById(r.group);
		if (!el) return;
		if (r.ok) {
			el.classList.remove('invalid');
		} else {
			el.classList.add('invalid');
			valid = false;
		}
	});
	return valid;
}

function showTeacherTasksValidation(show) {
	const alertEl = document.getElementById('teacherTasksValidationAlert');
	if (!alertEl) return;
	alertEl.style.display = show ? 'block' : 'none';
}

function teacherTasksToQuery(filters) {
	return Object.keys(filters)
		.filter(function (k) { return filters[k] !== ''; })
		.map(function (k) { return encodeURIComponent(k) + '=' + encodeURIComponent(filters[k]); })
		.join('&');
}

function applyTeacherTasksFilters() {
	if (!setTeacherTasksValidationState()) {
		showTeacherTasksValidation(true);
		return false;
	}
	showTeacherTasksValidation(false);
	loadTeacherTasksTable();
	return false;
}

function resetTeacherTasksFilters() {
	const ids = [
		'teacherTaskTeacherId',
		'teacherTaskClassId',
		'teacherTaskSubjectId',
		'teacherTaskStartDate',
		'teacherTaskEndDate'
	];
	ids.forEach(function (id) {
		const el = document.getElementById(id);
		if (el) el.value = '';
	});

	['teacherTaskTeacherGroup', 'teacherTaskClassGroup', 'teacherTaskSubjectGroup'].forEach(function (id) {
		const group = document.getElementById(id);
		if (group) group.classList.remove('invalid');
	});

	showTeacherTasksValidation(false);
	loadTeacherTasksTable();
}

function exportTeacherTasks() {
	if (!setTeacherTasksValidationState()) {
		showTeacherTasksValidation(true);
		return;
	}
	showTeacherTasksValidation(false);
	const query = teacherTasksToQuery(getTeacherTasksFilters());
	const url = '../exportTeacherTasks' + (query ? ('?' + query) : '');
	window.location.href = url;
}

function loadTeacherTasksTable() {
	const tbody = document.getElementById('teacherTasksTableBody');
	if (!tbody) return;

	const query = teacherTasksToQuery(getTeacherTasksFilters());
	const url = '../getTeacherTasksTable' + (query ? ('?' + query) : '');

	tbody.innerHTML = "<tr><td colspan='7' class='no-data'>Loading...</td></tr>";

	const xhr = new XMLHttpRequest();
	xhr.open('GET', url, true);
	xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xhr.onreadystatechange = function () {
		if (xhr.readyState !== 4) return;

		if (xhr.status === 200) {
			tbody.innerHTML = xhr.responseText;
			const total = xhr.getResponseHeader('X-Total-Count') || '0';
			const countEl = document.getElementById('teacherTasksCount');
			if (countEl) countEl.textContent = total + ' records found';
		} else if (xhr.status === 401 || xhr.status === 403) {
			tbody.innerHTML = "<tr><td colspan='7' class='table-cell-error'>Unauthorized. Please login again.</td></tr>";
		} else {
			tbody.innerHTML = "<tr><td colspan='7' class='table-cell-error'>Failed to load teacher tasks.</td></tr>";
		}
	};
	xhr.send();
}

function initTeacherTasksPage() {
	const form = document.getElementById('teacherTasksFilterForm');
	if (form) {
		form.addEventListener('submit', function (e) {
			e.preventDefault();
			applyTeacherTasksFilters();
		});
	}

	['teacherTaskTeacherId', 'teacherTaskClassId', 'teacherTaskSubjectId'].forEach(function (id) {
		const el = document.getElementById(id);
		if (!el) return;
		el.addEventListener('change', function () {
			if (el.value) {
				const group = el.closest('.filter-group');
				if (group) group.classList.remove('invalid');
			}
		});
	});

	showTeacherTasksValidation(false);
	loadTeacherTasksTable();
}






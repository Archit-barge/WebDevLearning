<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SMART COLLEGE UTILITY HUB - Login</title>
<link rel="stylesheet" href="admin/static/css/style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<script>
	(function() {
		const params = new URLSearchParams(window.location.search);
		if (params.get("forceLogout") === "true") {
			localStorage.clear();
		}

		if (!sessionStorage.getItem('splashShown')) {
			sessionStorage.setItem('splashShown', 'true');
			if (!params.get('fromSplash')) {

				window.location.replace('splash.jsp');
				return;
			}
		}
	})();
</script>
</head>
<body class="login-body">

	<div class="login-container">
		<div class="logo">
			<img src="bvit.webp" alt="College Logo">
		</div>

		<div class="login-header">
			<h1>SMART COLLEGE UTILITY HUB</h1>

			<p>Please sign in to continue</p>
		</div>

		<%
		String loginError = (String) request.getAttribute("loginError");
		if (loginError == null) {
			String reason = request.getParameter("reason");
			if ("sessionExpired".equals(reason)) {
				loginError = "Your session has expired. Please log in again.";
			}
		}
		if (loginError != null) {
		%>
		<div class="error-message"><%=loginError%></div>
		<%
		}
		%>

		<form action="LoginServlet" method="post">
			<div class="form-group">
				<label for="username">Username</label> <input type="text"
					name="username" id="username" placeholder="Enter your username"
					required>
			</div>
			<div class="form-group">
				<label for="password">Password</label>
				<div class="password-wrap">
					<input type="password" name="password" id="password"
						placeholder="Enter your password" required>
					<button type="button" class="password-toggle"
						onclick="toggleLoginPassword()" aria-label="Toggle password visibility">
						<i id="loginPasswordEye" class="fa-solid fas fa-eye" aria-hidden="true"></i>
					</button>
				</div>
			</div>
			<button class="login-button" type="submit">Login</button>
		</form>
	</div>

	<script src="admin/static/js/script.js"></script>
</body>
</html>

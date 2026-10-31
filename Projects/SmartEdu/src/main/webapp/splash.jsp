<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SMART COLLEGE UTILITY HUB - Loading...</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    overflow: hidden;
}

.splash-container {
    text-align: center;
    color: white;
    animation: fadeIn 1s ease-in;
}

.logo-container {
    margin-bottom: 40px;
    animation: scaleIn 1s ease-out;
}

.logo-container img {
    width: 150px;
    height: auto;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.app-title {
    font-size: 42px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 3px;
    margin-bottom: 15px;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
    animation: slideUp 1s ease-out 0.3s both;
}

.app-tagline {
    font-size: 18px;
    font-weight: 300;
    opacity: 0.9;
    margin-bottom: 50px;
    animation: slideUp 1s ease-out 0.5s both;
}

.loading-container {
    animation: slideUp 1s ease-out 0.7s both;
}

.loading-bar {
    width: 300px;
    height: 4px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 2px;
    overflow: hidden;
    margin: 0 auto 20px;
}

.loading-progress {
    height: 100%;
    background: white;
    border-radius: 2px;
    animation: loading 3s ease-in-out infinite;
}

.loading-text {
    font-size: 14px;
    opacity: 0.8;
    letter-spacing: 2px;
}

@media screen and (max-width: 480px) {
    .splash-container {
        padding: 15px;
    }
    
    .logo-container {
        margin-bottom: 30px;
    }
    
    .logo-container img {
        width: 100px;
        border-radius: 15px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
    }
    
    .app-title {
        font-size: 24px;
        letter-spacing: 2px;
        margin-bottom: 10px;
    }
    
    .app-tagline {
        font-size: 14px;
        margin-bottom: 30px;
    }
    
    .loading-bar {
        width: 80%;
        max-width: 250px;
        height: 3px;
        margin: 0 auto 15px;
    }
    
    .loading-text {
        font-size: 12px;
    }
    
    .circle-1 {
        width: 150px;
        height: 150px;
        top: -50px;
        left: -50px;
    }
    
    .circle-2 {
        width: 100px;
        height: 100px;
        bottom: -30px;
        right: -30px;
    }
    
    .circle-3 {
        width: 80px;
        height: 80px;
    }
}

@media screen and (min-width: 481px) and (max-width: 768px) {
    .logo-container img {
        width: 120px;
    }
    
    .app-title {
        font-size: 32px;
    }
    
    .app-tagline {
        font-size: 16px;
    }
    
    .loading-bar {
        width: 250px;
    }
    
    .circle-1 {
        width: 200px;
        height: 200px;
    }
    
    .circle-2 {
        width: 150px;
        height: 150px;
    }
}

.dots {
    display: inline-block;
}

.dots::after {
    content: '';
    animation: dots 1.5s infinite;
}

@keyframes fadeIn {
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}

@keyframes scaleIn {
    from {
        transform: scale(0.5);
        opacity: 0;
    }
    to {
        transform: scale(1);
        opacity: 1;
    }
}

@keyframes slideUp {
    from {
        transform: translateY(30px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

@keyframes loading {
    0% {
        width: 0%;
        margin-left: 0;
    }
    50% {
        width: 60%;
        margin-left: 20%;
    }
    100% {
        width: 0%;
        margin-left: 100%;
    }
}

@keyframes dots {
    0%, 20% {
        content: '';
    }
    40% {
        content: '.';
    }
    60% {
        content: '..';
    }
    80%, 100% {
        content: '...';
    }
}


.circle {
    position: absolute;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    animation: float 6s ease-in-out infinite;
}

.circle-1 {
    width: 300px;
    height: 300px;
    top: -100px;
    left: -100px;
    animation-delay: 0s;
}

.circle-2 {
    width: 200px;
    height: 200px;
    bottom: -50px;
    right: -50px;
    animation-delay: 2s;
}

.circle-3 {
    width: 150px;
    height: 150px;
    top: 50%;
    right: 10%;
    animation-delay: 4s;
}

@keyframes float {
    0%, 100% {
        transform: translateY(0) rotate(0deg);
    }
    50% {
        transform: translateY(-20px) rotate(10deg);
    }
}
</style>
</head>
<body>
<!-- Decorative circles -->
<div class="circle circle-1"></div>
<div class="circle circle-2"></div>
<div class="circle circle-3"></div>

<div class="splash-container">
    <div class="logo-container">
        <img src="logo.jpeg" alt="College Logo">
    </div>
    <h1 class="app-title">SMART COLLEGE</h1>
    <p class="app-tagline">UTILITY HUB</p>
    
    <div class="loading-container">
        <div class="loading-bar">
            <div class="loading-progress"></div>
        </div>
        <p class="loading-text">LOADING<span class="dots"></span></p>
    </div>
</div>

<script>
  
    setTimeout(function() {
        window.location.href = 'login.jsp?fromSplash=true';
    }, 5000);
    
    history.pushState(null, null, location.href);
    window.onpopstate = function() {
        history.go(1);
    };
</script>
</body>
</html>

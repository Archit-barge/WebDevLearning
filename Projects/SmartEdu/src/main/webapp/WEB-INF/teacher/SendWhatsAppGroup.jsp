<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String groupLink = (String) request.getAttribute("groupLink");
    String message = (String) request.getAttribute("message");
%>

<!DOCTYPE html>
<html>
<head>
<title>WhatsApp Group Announcement</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
    /* CSS Variables for consistent theming */
    :root {
        --primary: #667eea;
        --primary-dark: #5a67d8;
        --whatsapp-green: #25D366;
        --whatsapp-dark: #128C7E;
        --text-dark: #1e293b;
        --text-muted: #64748b;
        --bg-light: #f8fafc;
        --white: #ffffff;
        --shadow-sm: 0 4px 12px rgba(0,0,0,0.08);
        --shadow-md: 0 8px 24px rgba(0,0,0,0.12);
        --shadow-lg: 0 16px 40px rgba(0,0,0,0.16);
        --radius-sm: 8px;
        --radius-md: 12px;
        --radius-lg: 16px;
        --radius-xl: 20px;
        --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        --touch-target: 48px;
    }

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    html {
        -webkit-text-size-adjust: 100%;
        -webkit-tap-highlight-color: transparent;
    }

    body {
        font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Roboto', sans-serif;
        background: linear-gradient(135deg, var(--primary) 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }

    .container {
        width: 100%;
        max-width: 480px;
        animation: slideUp 0.5s ease-out;
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .back-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        color: var(--white);
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        margin-bottom: 16px;
        padding: 12px 16px;
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(10px);
        border-radius: var(--radius-sm);
        transition: var(--transition);
        cursor: pointer;
        border: none;
        min-height: var(--touch-target);
        width: 100%;
    }

    .back-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: translateX(-3px);
    }

    .back-btn:active {
        transform: translateX(-3px) scale(0.98);
    }

    .back-btn svg {
        width: 18px;
        height: 18px;
        flex-shrink: 0;
    }

    .box {
        background: var(--white);
        padding: 24px;
        border-radius: var(--radius-lg);
        box-shadow: var(--shadow-lg);
    }

    .header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
    }

    .header-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, var(--whatsapp-green) 0%, var(--whatsapp-dark) 100%);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(37, 211, 102, 0.3);
        flex-shrink: 0;
        animation: iconPop 0.5s ease-out 0.2s both;
    }

    @keyframes iconPop {
        0% {
            transform: scale(0);
        }
        70% {
            transform: scale(1.1);
        }
        100% {
            transform: scale(1);
        }
    }

    .header-icon svg {
        width: 26px;
        height: 26px;
        fill: var(--white);
    }

    h2 {
        color: var(--text-dark);
        font-size: clamp(1.125rem, 4vw, 1.375rem);
        font-weight: 600;
        line-height: 1.3;
    }

    .label {
        display: block;
        color: var(--text-muted);
        font-size: 12px;
        font-weight: 600;
        margin-bottom: 8px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    textarea {
        width: 100%;
        height: 120px;
        font-size: 15px;
        padding: 14px;
        border: 2px solid #e2e8f0;
        border-radius: var(--radius-md);
        resize: none;
        font-family: inherit;
        color: var(--text-dark);
        background: var(--bg-light);
        transition: var(--transition);
        min-height: var(--touch-target);
    }

    textarea:focus {
        outline: none;
        border-color: var(--primary);
        background: var(--white);
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1), var(--shadow-md);
    }

    .button-group {
        display: flex;
        gap: 12px;
        margin-top: 20px;
    }

    .btn-whatsapp {
        flex: 1;
        background: linear-gradient(135deg, var(--whatsapp-green) 0%, var(--whatsapp-dark) 100%);
        color: var(--white);
        padding: 14px 24px;
        font-size: 15px;
        font-weight: 600;
        border: none;
        border-radius: var(--radius-md);
        cursor: pointer;
        transition: var(--transition);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        min-height: var(--touch-target);
        box-shadow: 0 4px 15px rgba(37, 211, 102, 0.3);
        width: 100%;
    }

    .btn-whatsapp:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(37, 211, 102, 0.4);
    }

    .btn-whatsapp:active {
        transform: translateY(0) scale(0.98);
    }

    .btn-whatsapp svg {
        width: 22px;
        height: 22px;
        fill: currentColor;
    }

    .hint {
        margin-top: 20px;
        padding: 14px;
        background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
        border-radius: var(--radius-md);
        text-align: center;
        border: 1px dashed #cbd5e1;
    }

    .hint p {
        color: var(--text-muted);
        font-size: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-wrap: wrap;
        gap: 4px;
    }

    .hint strong {
        color: var(--text-dark);
        font-weight: 600;
    }

    .hint .arrow {
        color: var(--primary);
        font-weight: bold;
    }

    /* Toast notification */
    .toast {
        position: fixed;
        bottom: 24px;
        left: 50%;
        transform: translateX(-50%) translateY(100px);
        background: var(--text-dark);
        color: var(--white);
        padding: 14px 24px;
        border-radius: var(--radius-md);
        font-size: 14px;
        font-weight: 500;
        opacity: 0;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 1000;
        box-shadow: var(--shadow-lg);
        text-align: center;
        max-width: 90%;
    }

    .toast.show {
        transform: translateX(-50%) translateY(0);
        opacity: 1;
    }

    .toast.success {
        background: linear-gradient(135deg, var(--whatsapp-green) 0%, var(--whatsapp-dark) 100%);
    }

    /* Mobile Responsive Styles */
    @media (max-width: 480px) {

        .container {
            width: 100%;
        }

        .back-btn {
            margin-bottom: 12px;
        }

        .box {
            padding: 20px;
            border-radius: var(--radius-md);
        }

        .header {
            flex-direction: column;
            text-align: center;
            gap: 12px;
        }

        .header-icon {
            width: 56px;
            height: 56px;
        }

        .header-icon svg {
            width: 30px;
            height: 30px;
        }

        h2 {
            font-size: 1.125rem;
        }

        textarea {
            height: 100px;
            font-size: 14px;
        }

        .button-group {
            flex-direction: column;
            gap: 10px;
            margin-top: 16px;
        }

        .btn-whatsapp {
            padding: 16px 20px;
            font-size: 14px;
        }

        .hint {
            margin-top: 16px;
            padding: 12px;
        }

        .hint p {
            font-size: 13px;
        }

        .toast {
            bottom: 20px;
            left: 12px;
            right: 12px;
            transform: translateX(0) translateY(100px);
            width: auto;
        }

        .toast.show {
            transform: translateX(0) translateY(0);
        }
    }

    @media (max-width: 360px) {

        .box {
            padding: 16px;
        }

        .header-icon {
            width: 48px;
            height: 48px;
        }

        h2 {
            font-size: 1rem;
        }
    }

    /* Touch feedback for mobile */
    @media (hover: none) {
        .back-btn:hover {
            transform: none;
            background: rgba(255, 255, 255, 0.2);
        }
        
        .btn-whatsapp:hover {
            transform: none;
        }
    }

    /* Prevent double-tap zoom */
    .back-btn, .btn-whatsapp {
        touch-action: manipulation;
    }
</style>

<script>
function copyAndOpen() {
    const text = document.getElementById("msg");
    
    // Use modern clipboard API with fallback
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text.value).then(function() {
            showToast("Message copied to clipboard!", "success");
        }).catch(function() {
            fallbackCopy();
        });
    } else {
        fallbackCopy();
    }
    
    // Open WhatsApp group after a short delay
    setTimeout(() => {
        window.open("<%= groupLink %>", "_blank");
    }, 500);
}

function fallbackCopy() {
    const text = document.getElementById("msg");
    text.select();
    text.setSelectionRange(0, 99999);
    
    try {
        document.execCommand("copy");
        showToast("Message copied to clipboard!", "success");
    } catch (err) {
        showToast("Failed to copy. Please copy manually.", "");
    }
}

function showToast(message, type) {
    const toast = document.getElementById("toast");
    toast.textContent = message;
    toast.className = "toast";
    if (type === "success") {
        toast.classList.add("success");
    }
    toast.classList.add("show");
    
    setTimeout(() => {
        toast.classList.remove("show");
    }, 3000);
}

function goBack() {
    if (document.referrer && document.referrer !== window.location.href) {
        history.back();
    } else {
        window.location.href = "dashboard.jsp";
    }
}
</script>

</head>

<body>

<div class="container">
    <button class="back-btn" onclick="goBack()" aria-label="Go back">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        <span>Back</span>
    </button>

    <div class="box">
        <div class="header">
            <div class="header-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2ZM10 17l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                </svg>
            </div>
            <h2>WhatsApp Group Announcement</h2>
        </div>

        <label class="label" for="msg">Your Message</label>
        <textarea id="msg" readonly aria-label="Message content"><%= message %></textarea>

        <div class="button-group">
            <button class="btn-whatsapp" onclick="copyAndOpen()" aria-label="Copy message and open WhatsApp">
                <svg viewBox="0 0 24 24">
                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                </svg>
                Copy & Open WhatsApp
            </button>
        </div>

        <div class="hint">
            <p>👉 <span>Paste in group and press</span> <strong>ENTER</strong></p>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

</body>
</html>

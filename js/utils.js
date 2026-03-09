// Serenity Mindspace - Utility Functions
// Common JavaScript functions used across the platform

/* ==========================================
   TOKEN MANAGEMENT
   ========================================== */

function getTokens() {
    return parseInt(localStorage.getItem('tokens') || '100');
}

function setTokens(amount) {
    localStorage.setItem('tokens', amount.toString());
    updateAllTokenDisplays();
}

function deductTokens(amount) {
    const currentTokens = getTokens();
    if (currentTokens < amount) {
        return false; // Insufficient tokens
    }
    setTokens(currentTokens - amount);
    return true;
}

function updateAllTokenDisplays() {
    const displays = document.querySelectorAll('[id*="token"], [id*="Token"]');
    const tokens = getTokens();
    displays.forEach(display => {
        if (display.textContent.match(/\d+/)) {
            display.textContent = tokens;
        }
    });
}

/* ==========================================
   AUTHENTICATION
   ========================================== */

function isLoggedIn() {
    return localStorage.getItem('isLoggedIn') === 'true';
}

function getUserType() {
    return localStorage.getItem('userType') || 'user';
}

function login(userType) {
    localStorage.setItem('isLoggedIn', 'true');
    localStorage.setItem('userType', userType);
}

function logout() {
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('userType');
    window.location.href = 'index.html';
}

function requireAuth() {
    if (!isLoggedIn()) {
        window.location.href = 'login.html';
    }
}

function requireSpecialist() {
    if (!isLoggedIn() || getUserType() !== 'specialist') {
        window.location.href = 'login.html';
    }
}

/* ==========================================
   DATA STORAGE
   ========================================== */

function saveAssessment(data) {
    localStorage.setItem('assessmentData', JSON.stringify(data));
}

function getAssessment() {
    const data = localStorage.getItem('assessmentData');
    return data ? JSON.parse(data) : null;
}

function saveBooking(booking) {
    const bookings = getBookings();
    bookings.push(booking);
    localStorage.setItem('bookings', JSON.stringify(bookings));
}

function getBookings() {
    const data = localStorage.getItem('bookings');
    return data ? JSON.parse(data) : [];
}

function saveChatHistory(sessionId, messages) {
    localStorage.setItem(`chat_${sessionId}`, JSON.stringify(messages));
}

function getChatHistory(sessionId) {
    const data = localStorage.getItem(`chat_${sessionId}`);
    return data ? JSON.parse(data) : [];
}

/* ==========================================
   DATE & TIME FORMATTING
   ========================================== */

function formatDate(date) {
    const d = new Date(date);
    return d.toLocaleDateString('en-US', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
}

function formatTime(date) {
    const d = new Date(date);
    return d.toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
    });
}

function formatDateTime(date) {
    return `${formatDate(date)} at ${formatTime(date)}`;
}

function getTimeAgo(date) {
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    
    let interval = seconds / 31536000;
    if (interval > 1) return Math.floor(interval) + " years ago";
    
    interval = seconds / 2592000;
    if (interval > 1) return Math.floor(interval) + " months ago";
    
    interval = seconds / 86400;
    if (interval > 1) return Math.floor(interval) + " days ago";
    
    interval = seconds / 3600;
    if (interval > 1) return Math.floor(interval) + " hours ago";
    
    interval = seconds / 60;
    if (interval > 1) return Math.floor(interval) + " minutes ago";
    
    return "Just now";
}

/* ==========================================
   VALIDATION
   ========================================== */

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function validatePhone(phone) {
    const re = /^[\d\s\-\+\(\)]+$/;
    return phone.length >= 10 && re.test(phone);
}

function validatePassword(password) {
    return password.length >= 8;
}

function sanitizeInput(input) {
    const div = document.createElement('div');
    div.textContent = input;
    return div.innerHTML;
}

/* ==========================================
   UI HELPERS
   ========================================== */

function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 16px 24px;
        background: ${type === 'success' ? '#7A9B76' : type === 'error' ? '#D47C7C' : '#7C9FD4'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

function showLoader() {
    const loader = document.createElement('div');
    loader.id = 'globalLoader';
    loader.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    `;
    loader.innerHTML = '<div style="width: 50px; height: 50px; border: 4px solid rgba(255,255,255,0.3); border-top-color: white; border-radius: 50%; animation: spin 1s linear infinite;"></div>';
    document.body.appendChild(loader);
}

function hideLoader() {
    const loader = document.getElementById('globalLoader');
    if (loader) loader.remove();
}

function confirmAction(message) {
    return new Promise((resolve) => {
        if (confirm(message)) {
            resolve(true);
        } else {
            resolve(false);
        }
    });
}

/* ==========================================
   ANALYTICS & TRACKING
   ========================================== */

function trackEvent(category, action, label) {
    // In production, this would send to analytics service
    console.log('Event:', { category, action, label });
}

function trackPageView(pageName) {
    trackEvent('Page View', pageName, window.location.pathname);
}

function trackTokenPurchase(amount, price) {
    trackEvent('Purchase', 'Token Package', `${amount} tokens for ${price}`);
}

function trackSessionBooked(specialistName, sessionType) {
    trackEvent('Booking', sessionType, specialistName);
}

/* ==========================================
   CRISIS DETECTION
   ========================================== */

function detectCrisisKeywords(text) {
    const crisisKeywords = [
        'suicide', 'kill myself', 'end my life', 'want to die',
        'self harm', 'hurt myself', 'no reason to live'
    ];
    
    const lowerText = text.toLowerCase();
    return crisisKeywords.some(keyword => lowerText.includes(keyword));
}

function showCrisisResources() {
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.style.display = 'flex';
    modal.innerHTML = `
        <div class="modal">
            <div class="modal-header">
                <div class="modal-icon" style="font-size: 3rem;">⚠️</div>
                <h3 class="modal-title" style="color: var(--color-error);">Crisis Support Available</h3>
            </div>
            <div class="modal-body">
                <p style="margin-bottom: var(--space-lg); text-align: center;">
                    If you're experiencing thoughts of self-harm, please reach out for immediate help:
                </p>
                <div style="background: rgba(212, 124, 124, 0.1); padding: var(--space-xl); border-radius: var(--radius-md); text-align: center; margin-bottom: var(--space-lg);">
                    <h2 style="color: var(--color-error); margin-bottom: var(--space-md);">
                        <a href="tel:988" style="color: inherit;">988</a>
                    </h2>
                    <p style="margin: 0;">Suicide & Crisis Lifeline</p>
                    <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-top: var(--space-sm);">
                        Available 24/7 • Free & Confidential
                    </p>
                </div>
                <p style="text-align: center; color: var(--text-secondary); font-size: var(--text-sm);">
                    You don't have to face this alone. Help is available.
                </p>
            </div>
            <div class="modal-actions">
                <button class="btn btn-primary btn-lg" onclick="this.closest('.modal-overlay').remove()">
                    I Understand
                </button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
}

/* ==========================================
   NOTIFICATIONS
   ========================================== */

function checkNotifications() {
    // Simulate checking for notifications
    const notifications = JSON.parse(localStorage.getItem('notifications') || '[]');
    return notifications;
}

function addNotification(notification) {
    const notifications = checkNotifications();
    notifications.push({
        ...notification,
        id: Date.now(),
        read: false,
        timestamp: new Date().toISOString()
    });
    localStorage.setItem('notifications', JSON.stringify(notifications));
}

function markNotificationRead(id) {
    const notifications = checkNotifications();
    const notification = notifications.find(n => n.id === id);
    if (notification) {
        notification.read = true;
        localStorage.setItem('notifications', JSON.stringify(notifications));
    }
}

/* ==========================================
   EXPORT/IMPORT
   ========================================== */

function exportData(data, filename) {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

function exportChatTranscript(messages, filename) {
    let transcript = 'Serenity Mindspace - Chat Transcript\n';
    transcript += `Date: ${new Date().toLocaleDateString()}\n\n`;
    
    messages.forEach(msg => {
        transcript += `[${formatTime(msg.timestamp)}] ${msg.sender}: ${msg.text}\n`;
    });
    
    const blob = new Blob([transcript], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename || `transcript-${Date.now()}.txt`;
    a.click();
    URL.revokeObjectURL(url);
}

/* ==========================================
   LUCKY VAULT
   ========================================== */

function canSpinVault() {
    const lastSpin = localStorage.getItem('lastVaultSpin');
    const today = new Date().toDateString();
    return lastSpin !== today;
}

function spinLuckyVault() {
    if (!canSpinVault()) {
        showToast('You can only spin once per day!', 'error');
        return false;
    }
    
    const won = Math.random() < 0.01; // 1% chance
    
    if (won) {
        const currentTokens = getTokens();
        setTokens(currentTokens + 50);
        showToast('Congratulations! You won 50 tokens!', 'success');
    } else {
        showToast('Better luck tomorrow!', 'info');
    }
    
    localStorage.setItem('lastVaultSpin', new Date().toDateString());
    return won;
}

/* ==========================================
   INITIALIZE ON LOAD
   ========================================== */

document.addEventListener('DOMContentLoaded', () => {
    // Update all token displays
    updateAllTokenDisplays();
    
    // Track page view
    trackPageView(document.title);
    
    // Check authentication for protected pages
    const protectedPages = ['dashboard', 'booking', 'chat-room', 'video-call'];
    const currentPage = window.location.pathname.split('/').pop().replace('.html', '');
    
    if (protectedPages.includes(currentPage) && !isLoggedIn()) {
        window.location.href = 'login.html';
    }
    
    // Check specialist-only pages
    if (currentPage === 'specialist-dashboard' && getUserType() !== 'specialist') {
        window.location.href = 'dashboard.html';
    }
});

/* ==========================================
   CSS ANIMATIONS (ADD TO HEAD)
   ========================================== */

const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateX(100px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes slideOut {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(100px);
        }
    }
    
    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
`;
document.head.appendChild(style);
// Navigation, Dropdown & Mobile Menu Logic
document.addEventListener('DOMContentLoaded', () => {
    const navbar = document.getElementById('navbar');
    const menuToggle = document.getElementById('menuToggle');
    const navLinks = document.getElementById('navLinks');

    // ── Scroll effect ──────────────────────────────────────────────
    window.addEventListener('scroll', () => {
        if (navbar) {
            navbar.classList.toggle('scrolled', window.scrollY > 50);
        }
    }, { passive: true });

    // ── Compare Dropdown — click-based on ALL screen sizes ─────────
    // (CSS :hover was removed; this keeps dropdown open during scroll)
    const dropdowns = document.querySelectorAll('.nav-dropdown');

    dropdowns.forEach(dropdown => {
        const toggle = dropdown.querySelector('.nav-dropdown-toggle');
        if (!toggle) return;

        toggle.addEventListener('click', (e) => {
            e.stopPropagation();
            const isOpen = dropdown.classList.contains('open');

            // Close all other dropdowns
            dropdowns.forEach(d => d.classList.remove('open'));

            // Toggle this one
            if (!isOpen) dropdown.classList.add('open');
        });
    });

    // Close dropdowns when clicking anywhere outside
    document.addEventListener('click', () => {
        dropdowns.forEach(d => d.classList.remove('open'));
    });

    // ── Mobile menu toggle ─────────────────────────────────────────
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            menuToggle.classList.toggle('active');
            navLinks.classList.toggle('active');
            document.body.style.overflow = navLinks.classList.contains('active') ? 'hidden' : '';
        });

        // Close menu when a nav link (not dropdown toggle) is clicked
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                menuToggle.classList.remove('active');
                navLinks.classList.remove('active');
                document.body.style.overflow = '';
                dropdowns.forEach(d => d.classList.remove('open'));
            });
        });
    }

    // ── Cookie Consent Banner ──────────────────────────────────────
    initCookieConsent();
});


function initCookieConsent() {
    if (localStorage.getItem('cookieConsent') === 'accepted') return;

    const banner = document.createElement('div');
    banner.id = 'cookie-consent-banner';
    banner.innerHTML = `
        <div style="position:fixed;bottom:20px;left:50%;transform:translateX(-50%);width:90%;max-width:600px;background:white;padding:20px;border-radius:20px;box-shadow:0 10px 40px rgba(0,0,0,0.15);z-index:9999;display:flex;flex-direction:column;gap:15px;border:1px solid #e2e8f0;font-family:'Plus Jakarta Sans',sans-serif;">
            <div style="display:flex;align-items:center;gap:10px;">
                <span style="font-size:1.5rem;">🍪</span>
                <p style="margin:0;font-size:0.9rem;color:#1e293b;line-height:1.5;">We use cookies to improve your experience and show relevant ads. By continuing to visit this site you agree to our use of cookies.</p>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <a href="/privacy.html" style="padding:10px 20px;font-size:0.85rem;color:#64748b;text-decoration:none;font-weight:600;">Learn More</a>
                <button id="accept-cookies" style="background:#6366f1;color:white;border:none;padding:10px 25px;border-radius:12px;font-weight:700;cursor:pointer;font-size:0.85rem;transition:transform 0.2s;">Accept</button>
            </div>
        </div>
    `;
    document.body.appendChild(banner);

    document.getElementById('accept-cookies').addEventListener('click', () => {
        localStorage.setItem('cookieConsent', 'accepted');
        banner.style.opacity = '0';
        banner.style.transition = 'opacity 0.3s ease';
        setTimeout(() => banner.remove(), 300);
    });
}


function trackCTA(location) {
    if (typeof gtag !== 'undefined') {
        gtag('event', 'cta_click', {
            'event_category': 'engagement',
            'event_label': location
        });
    }
}

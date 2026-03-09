# Serenity Mindspace 🧘

A modern, compassionate mental health platform connecting users with AI-powered support and licensed mental health specialists through chat and video sessions.

![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🎨 Design Philosophy

This platform was designed with a distinctive, warm aesthetic that avoids generic AI-generated looks:

- **Typography**: Bricolage Grotesque (display) + Source Serif 4 (body) for a warm, humanist feel
- **Color Palette**: Earthy sage greens (#7A9B76), warm terracotta (#D4927C), soft cream (#FAF7F2)
- **Visual Identity**: Organic shapes, breathing animations, hand-drawn SVG elements
- **Differentiation**: Feels like a warm embrace, not a cold tech platform

## ✨ Key Features

### For Users
- **24/7 AI Support**: Intelligent chatbot with compassionate responses (first 10 messages free)
- **Licensed Specialists**: Connect via text chat (50 tokens/30min) or video (100 tokens/30min)
- **Wellness Assessment**: Comprehensive 17-question form across 4 sections
- **Token System**: Flexible credit system with welcome bonus (100 tokens on signup)
- **Lucky Vault**: Daily chance to win 50 free tokens (1% probability)
- **Private & Secure**: End-to-end encryption, HIPAA-inspired privacy
- **Crisis Resources**: Always-accessible emergency hotlines and resources

### For Specialists
- **Credential Verification**: Upload Aadhar, degree, and license for verification
- **Specialist Dashboard**: Manage appointments, view earnings, set availability
- **Patient Management**: Access assessment summaries, session notes
- **Flexible Scheduling**: Set recurring availability or book specific slots

## 📋 Pages Included

### Core Pages
1. **Landing Page** (`index.html`)
   - Hero section with breathing animation
   - Feature cards
   - How It Works section
   - Trust indicators
   - Crisis resources in footer

2. **Authentication** (`login.html`)
   - User type toggle (Regular User / Specialist)
   - Google Sign-In integration
   - Specialist credential upload
   - Welcome bonus modal (100 tokens)

3. **Wellness Assessment** (`assessment.html`)
   - Multi-step form with progress tracking
   - 4 sections: Emotional State, History, Daily Functioning, Goals
   - Crisis detection and immediate resources
   - Personalized results page

4. **Choose Support** (`choose-support.html`)
   - Three options: AI Assistant, Chat Specialist, Video Specialist
   - Pricing and features comparison
   - Personalized recommendations based on assessment

5. **AI Chat** (`ai-chat.html`)
   - Clean chat interface
   - Quick action buttons
   - Message history
   - Export transcript functionality
   - Token usage tracking

6. **Specialists Directory** (`specialists.html`)
   - Filter by specialization, language, experience, availability
   - Specialist cards with ratings and credentials
   - Verified badge system

7. **Token Store** (`store.html`)
   - Three pricing tiers (100, 500, 1000 tokens)
   - Bonus tokens on larger packages
   - Usage examples
   - FAQ section

## 🛠️ Technical Stack

### Frontend
- **HTML5**: Semantic markup
- **CSS3**: Custom design system with CSS variables
- **Vanilla JavaScript**: No framework dependencies
- **Fonts**: Google Fonts (Bricolage Grotesque, Source Serif 4)

### Design Tokens
All colors, spacing, typography, and other design decisions are centralized in CSS variables:
```css
:root {
  --color-primary: #7A9B76;      /* Sage green */
  --color-secondary: #D4927C;     /* Warm terracotta */
  --color-accent: #E8C468;        /* Warm gold */
  --font-display: 'Bricolage Grotesque', sans-serif;
  --font-body: 'Source Serif 4', serif;
  /* ... and many more */
}
```

### Storage
- **LocalStorage**: User tokens, authentication status, assessment data
- **Session Data**: Temporary form data

### APIs (Production Ready)
- **Gemini API**: AI chat responses (placeholder included)
- **Firebase**: Authentication, Firestore, Storage
- **Razorpay/Stripe**: Payment processing
- **Agora/Daily.co**: Video call infrastructure

## 🚀 Setup Instructions

### Prerequisites
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Local web server (optional, but recommended)

### Installation

1. **Clone or Download**
   ```bash
   # Extract the files to your desired directory
   cd serenity-mindspace
   ```

2. **File Structure**
   ```
   serenity-mindspace/
   ├── index.html              # Landing page
   ├── login.html              # Authentication
   ├── assessment.html         # Wellness assessment
   ├── choose-support.html     # Support type selection
   ├── ai-chat.html            # AI chatbot
   ├── specialists.html        # Specialist directory
   ├── store.html              # Token store
   ├── css/
   │   ├── main.css           # Global styles & design tokens
   │   └── components.css     # Reusable components
   └── README.md              # This file
   ```

3. **Run Locally**
   
   **Option A: Python**
   ```bash
   # Python 3
   python -m http.server 8000
   
   # Then visit: http://localhost:8000
   ```
   
   **Option B: Node.js**
   ```bash
   npx serve
   ```
   
   **Option C: VS Code**
   - Install "Live Server" extension
   - Right-click `index.html` → "Open with Live Server"

4. **Test User Flow**
   - Visit landing page
   - Click "Sign Up"
   - Choose "I need support"
   - Create account (simulated)
   - Complete wellness assessment
   - Choose support type
   - Interact with AI or browse specialists

## 💾 Data Flow

### User Authentication
```javascript
// Check login status
const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true';
const userType = localStorage.getItem('userType'); // 'user' or 'specialist'
```

### Token Management
```javascript
// Get current token balance
const tokens = localStorage.getItem('tokens'); // Default: 100

// Deduct tokens for AI chat (after 10 free messages)
// 5 tokens per message

// Specialist sessions
// Chat: 50 tokens per 30 min
// Video: 100 tokens per 30 min
```

### Assessment Data
```javascript
// Saved after completion
const assessmentData = JSON.parse(localStorage.getItem('assessmentData'));
// Contains: feeling, mood, duration, reasons, impact, history, etc.
```

## 🎯 Feature Highlights

### Crisis Detection
The assessment automatically detects crisis situations:
```javascript
if (selfHarmResponse === 'recently') {
  // Show immediate crisis resources
  // Display 988 hotline prominently
  // Recommend immediate specialist contact
}
```

### Token Economics
- **Welcome Bonus**: 100 tokens on signup
- **Lucky Vault**: 1% daily chance to win 50 tokens
- **AI Chat**: First 10 messages free, then 5 tokens/message
- **Specialist Chat**: 50 tokens per 30-minute session
- **Video Call**: 100 tokens per 30-minute session

### Responsive Design
- **Mobile**: < 640px (hamburger menu, stacked cards)
- **Tablet**: 640px - 1024px (2-column grids)
- **Desktop**: > 1024px (full experience)

## 🔒 Security & Privacy

### Current Implementation (Demo)
- Client-side storage (LocalStorage)
- Simulated authentication
- No actual data transmission

### Production Recommendations
- **Firebase Auth**: Social login, email/password
- **Firestore**: Encrypted database
- **HTTPS**: SSL certificates required
- **End-to-End Encryption**: For all conversations
- **HIPAA Compliance**: For healthcare data
- **Two-Factor Authentication**: For specialist accounts
- **Session Timeouts**: Auto-logout after inactivity
- **Data Export**: Allow users to download their data
- **Right to Deletion**: GDPR compliance

## 🎨 Customization

### Colors
Edit CSS variables in `css/main.css`:
```css
:root {
  --color-primary: #7A9B76;      /* Change to your brand color */
  --color-secondary: #D4927C;     /* Accent color */
  --color-accent: #E8C468;        /* Highlight color */
}
```

### Typography
Change fonts in `css/main.css`:
```css
@import url('your-font-url');

:root {
  --font-display: 'Your Display Font', sans-serif;
  --font-body: 'Your Body Font', serif;
}
```

### Content
- **Crisis Numbers**: Update in footer of all pages
- **Specialist Profiles**: Add/edit in `specialists.html`
- **Assessment Questions**: Modify in `assessment.html`

## 🚧 Known Limitations (Demo)

1. **No Backend**: All data is stored client-side (LocalStorage)
2. **Simulated Payments**: No actual payment processing
3. **Mock AI**: Responses are rule-based, not from Gemini API
4. **No Video Calls**: Interface only (no actual WebRTC)
5. **No Real Verification**: Specialist credentials are uploaded but not verified
6. **Single User**: No multi-user support or authentication

## 🔮 Production Enhancements

### Backend (Node.js + Express)
```javascript
// Example structure
/server
  /routes
    - auth.js          // Login, signup, JWT
    - users.js         // User CRUD
    - specialists.js   // Specialist management
    - sessions.js      // Booking system
    - payments.js      // Razorpay integration
  /models
    - User.js
    - Specialist.js
    - Session.js
    - Assessment.js
  /middleware
    - auth.js          // JWT verification
    - validate.js      // Input validation
  - server.js
```

### Database Schema (MongoDB)
```javascript
// User
{
  _id: ObjectId,
  email: String,
  passwordHash: String,
  userType: String,
  tokens: Number,
  assessmentData: Object,
  createdAt: Date
}

// Specialist
{
  _id: ObjectId,
  userId: ObjectId,
  credentials: {
    aadhar: String,
    degree: String,
    license: String
  },
  verification: String,  // 'pending', 'approved', 'rejected'
  specialization: String,
  bio: String,
  availability: Array
}

// Session
{
  _id: ObjectId,
  userId: ObjectId,
  specialistId: ObjectId,
  type: String,          // 'chat', 'video'
  startTime: Date,
  endTime: Date,
  tokens: Number,
  transcript: String     // Encrypted
}
```

### Gemini API Integration
```javascript
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

async function chatWithAI(userMessage, assessmentContext) {
  const prompt = `
    You are a compassionate mental health assistant.
    User's assessment summary: ${JSON.stringify(assessmentContext)}
    User message: ${userMessage}
    
    Provide empathetic, supportive response:
  `;
  
  const result = await model.generateContent(prompt);
  return result.response.text();
}
```

### Payment Integration (Razorpay)
```javascript
// Server-side order creation
app.post('/api/create-order', async (req, res) => {
  const { tokens, amount } = req.body;
  
  const order = await razorpay.orders.create({
    amount: amount * 100,  // Paise
    currency: 'INR',
    receipt: `token_${Date.now()}`
  });
  
  res.json({ orderId: order.id });
});

// Client-side payment
const options = {
  key: RAZORPAY_KEY_ID,
  amount: amount * 100,
  currency: 'INR',
  order_id: orderId,
  handler: function(response) {
    // Update user tokens
    updateTokens(response.razorpay_payment_id);
  }
};

const rzp = new Razorpay(options);
rzp.open();
```

## 📱 Progressive Web App

Add these files for PWA support:

**manifest.json**
```json
{
  "name": "Serenity Mindspace",
  "short_name": "Serenity",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FAF7F2",
  "theme_color": "#7A9B76",
  "icons": [
    {
      "src": "icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

**service-worker.js**
```javascript
const CACHE_NAME = 'serenity-v1';
const urlsToCache = [
  '/',
  '/css/main.css',
  '/css/components.css',
  '/index.html',
  '/ai-chat.html'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});
```

## 🧪 Testing Recommendations

### Manual Testing Checklist
- [ ] Complete user registration flow
- [ ] Fill out wellness assessment
- [ ] Try all support types
- [ ] Purchase tokens
- [ ] Spin Lucky Vault
- [ ] Test on mobile devices
- [ ] Verify responsive design
- [ ] Check accessibility (keyboard navigation, screen readers)

### Automated Testing
```javascript
// Example with Jest
describe('Token System', () => {
  test('should deduct tokens for AI chat', () => {
    setTokens(100);
    sendAIMessage(); // Should cost 5 tokens
    expect(getTokens()).toBe(95);
  });
  
  test('should add welcome bonus on signup', () => {
    signup();
    expect(getTokens()).toBe(100);
  });
});
```

## 🤝 Contributing

While this is a demo project, here are guidelines if you want to extend it:

1. **Code Style**: Follow existing patterns
2. **CSS**: Use design tokens, avoid hardcoded values
3. **Accessibility**: Maintain ARIA labels and keyboard navigation
4. **Comments**: Document complex logic
5. **Responsive**: Test on multiple screen sizes

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 🆘 Support

### Crisis Resources
If you or someone you know is in crisis:
- **988 Suicide & Crisis Lifeline**: Call or text 988
- **Crisis Text Line**: Text HOME to 741741
- **National Helpline**: 1-800-273-8255

### Technical Support
For questions about this demo:
- Review this README
- Check browser console for errors
- Ensure JavaScript is enabled
- Try a different browser

## 🎯 Future Enhancements

- **Mobile Apps**: React Native or Flutter
- **Group Therapy**: Virtual group sessions
- **Mood Tracking**: Daily check-ins with visualizations
- **Journaling**: Private, encrypted journal entries
- **Progress Reports**: AI-generated insights
- **Specialist Matching**: Algorithm-based recommendations
- **Insurance Integration**: Verify coverage, submit claims
- **Prescription Management**: For psychiatrists
- **Family Accounts**: Multi-user support
- **Multi-language**: Support for Hindi, Spanish, etc.

## 📊 Analytics (Production)

Track important metrics:
- User signups & retention
- Assessment completion rate
- AI vs. Specialist preference
- Token purchase conversion
- Session completion rate
- Crisis detection frequency
- User satisfaction scores

---

**Made with 💚 for mental wellness**

Remember: This platform is designed to support mental health, but it's not a substitute for professional medical advice, diagnosis, or treatment. If you're experiencing a mental health emergency, please call 988.
# ProChat App Logic

## User Roles
- **Client**: 3 tabs - Home, Categories, Profile
- **Expert**: 5 tabs - Dashboard, Clients, Categories, Business, Profile
- **Guest**: 2 tabs - Browse Experts, Categories

## Navigation Rules
- Bottom navigation must persist for all screens
- Back button exits app or returns to previous tab, never breaks navigation

## Firebase Logic (brief)
- Booking, chat, and sessions are synced to Firestore
- Each expert is tied to a business via businessCode

# MatchIQ — Sports Pre-Match Analysis Platform

A subscription and credit-based pre-match statistical analysis app for football and basketball.

> **Important:** This platform provides pre-match statistical data and analysis only.
> It does not facilitate betting, gambling, or any real-money transactions.
> Every premium report includes the disclaimer:
> *"This analysis is provided for statistical informational purposes only. It does not guarantee any result, profit, or betting outcome."*

---

## Project Structure

```
/
├── backend/          # NestJS API (Node.js + TypeScript)
├── admin/            # Next.js admin panel
├── mobile/           # Flutter mobile app
└── docker-compose.yml
```

## Tech Stack

| Layer    | Technology                          |
|----------|-------------------------------------|
| Backend  | NestJS, TypeScript, Prisma, PostgreSQL |
| Auth     | JWT (access tokens), bcrypt          |
| Admin    | Next.js, TypeScript                  |
| Mobile   | Flutter, Dart, Riverpod, go_router   |

---

## Quick Start

### Prerequisites
- Node.js 20+
- PostgreSQL 14+
- Flutter 3.19+
- Docker (optional)

### Backend

```bash
cd backend
cp .env.example .env        # fill in values
npm install
npx prisma migrate dev      # run migrations
npx ts-node prisma/seed.ts  # seed demo data
npm run start:dev
```

API: http://localhost:3000
Swagger: http://localhost:3000/api/docs

### Admin Panel

```bash
cd admin
cp .env.local.example .env.local
npm install
npm run dev
```

Admin: http://localhost:3001/admin/login  
Default admin: `admin@matchiq.app` / `Admin1234!`

### Flutter App

```bash
cd mobile
flutter pub get
flutter run
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /auth/register | Register |
| POST | /auth/login | Login |
| GET | /auth/me | Current user |
| GET | /sports | List sports |
| GET | /leagues | List leagues |
| GET | /teams | List teams |
| GET | /matches | All matches |
| GET | /matches/today | Today's matches |
| GET | /matches/popular | Popular matches |
| GET | /matches/:id | Match detail |
| GET | /reports/:matchId | Report preview (locked) |
| POST | /reports/:matchId/unlock | Unlock report |
| GET | /reports/unlocked | My unlocked reports |
| GET | /credits/packages | Credit packages |
| GET | /credits/history | Transaction history |
| POST | /credits/mock-purchase | Buy credits (mock) |
| GET | /subscriptions/packages | Subscription plans |
| POST | /subscriptions/mock-activate | Activate subscription (mock) |
| GET | /admin/* | Admin endpoints (ADMIN role) |

---

## Subscription Plans

| Plan | Duration | Reports | Price |
|------|----------|---------|-------|
| Free | — | 2 credits | $0 |
| Weekly Pro | 7 days | Unlimited | $4.99 |
| Monthly Pro | 30 days | Unlimited | $14.99 |
| Elite | 30 days | Unlimited | $24.99 |

---

## Credit System

- 1 credit = 1 premium report unlock
- Once unlocked, re-viewing is free
- Credits deducted atomically (database transaction)
- Subscription holders bypass credit deduction

---

## Flutter Screens

1. SplashScreen
2. OnboardingScreen
3. LoginScreen
4. RegisterScreen
5. HomeScreen (football/basketball tabs)
6. MatchesScreen (filterable)
7. MatchDetailScreen (stats, form, risk)
8. PremiumReportScreen (locked → unlock → full view)
9. CreditsScreen (balance, packages, history)
10. SubscriptionScreen (plans)
11. ProfileScreen
12. UnlockedReportsScreen
13. SettingsScreen

---

## Payment Integration

Mock payment endpoints are in place. To integrate real payments, replace `mockPurchase` and `mockActivate` in `credits.service.ts` and `subscriptions.service.ts` with your iyzico/PayTR/Stripe provider.

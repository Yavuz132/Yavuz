import { PrismaClient, RiskLevel, MatchStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // Admin user
  const adminHash = await bcrypt.hash(process.env.ADMIN_PASSWORD ?? 'Admin1234!', 10);
  const admin = await prisma.user.upsert({
    where: { email: process.env.ADMIN_EMAIL ?? 'admin@matchiq.app' },
    update: {},
    create: {
      email: process.env.ADMIN_EMAIL ?? 'admin@matchiq.app',
      passwordHash: adminHash,
      name: 'Admin',
      role: 'ADMIN',
      creditBalance: 0,
    },
  });

  // Sports
  const football = await prisma.sport.upsert({
    where: { slug: 'football' },
    update: {},
    create: { name: 'Football', slug: 'football' },
  });

  const basketball = await prisma.sport.upsert({
    where: { slug: 'basketball' },
    update: {},
    create: { name: 'Basketball', slug: 'basketball' },
  });

  // Leagues
  const superLig = await prisma.league.upsert({
    where: { id: 1 },
    update: {},
    create: { sportId: football.id, name: 'Süper Lig', country: 'Turkey' },
  });

  const nba = await prisma.league.upsert({
    where: { id: 2 },
    update: {},
    create: { sportId: basketball.id, name: 'NBA', country: 'USA' },
  });

  // Teams
  const gala = await prisma.team.upsert({
    where: { id: 1 },
    update: {},
    create: { sportId: football.id, leagueId: superLig.id, name: 'Galatasaray' },
  });

  const fener = await prisma.team.upsert({
    where: { id: 2 },
    update: {},
    create: { sportId: football.id, leagueId: superLig.id, name: 'Fenerbahçe' },
  });

  const lakers = await prisma.team.upsert({
    where: { id: 3 },
    update: {},
    create: { sportId: basketball.id, leagueId: nba.id, name: 'LA Lakers' },
  });

  const celtics = await prisma.team.upsert({
    where: { id: 4 },
    update: {},
    create: { sportId: basketball.id, leagueId: nba.id, name: 'Boston Celtics' },
  });

  // Demo match
  const demoMatch = await prisma.match.upsert({
    where: { id: 1 },
    update: {},
    create: {
      sportId: football.id,
      leagueId: superLig.id,
      homeTeamId: gala.id,
      awayTeamId: fener.id,
      matchDate: new Date(Date.now() + 3600 * 1000 * 24),
      status: MatchStatus.SCHEDULED,
      popularityScore: 95,
      dataScore: 78,
      riskLevel: RiskLevel.MEDIUM,
    },
  });

  // Match stats
  await prisma.matchStat.upsert({
    where: { matchId: demoMatch.id },
    update: {},
    create: {
      matchId: demoMatch.id,
      homeLastFive: 'W,W,D,W,L',
      awayLastFive: 'W,L,W,W,D',
      homeAverageScore: 2.2,
      awayAverageScore: 1.8,
      homeDefenseAverage: 0.8,
      awayDefenseAverage: 1.2,
      homePerformanceNote: 'Strong home performance in last 5 matches',
      awayPerformanceNote: 'Inconsistent away defensive performance',
    },
  });

  // Demo premium report
  await prisma.premiumReport.upsert({
    where: { matchId: demoMatch.id },
    update: {},
    create: {
      matchId: demoMatch.id,
      title: 'Galatasaray vs Fenerbahçe Pre-Match Analysis',
      summary: 'A high-stakes derby with strong data signals from the home side.',
      dataScore: 78,
      riskLevel: RiskLevel.MEDIUM,
      confidenceLevel: 'HIGH',
      positiveFactors: [
        'Strong home performance in last 5 matches',
        'High attacking numbers across recent fixtures',
        'Opponent shows inconsistent away defensive performance',
      ],
      negativeFactors: [
        'Derby matches carry inherent high uncertainty',
        'Two key midfielders are unavailable',
      ],
      scenarioText:
        'The home team may assert early pressure in the opening phase. However, given the derby nature of this fixture, uncertainty remains elevated and the risk level is assessed as medium.',
      isPublished: true,
    },
  });

  console.log('Seed complete. Admin:', admin.email);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());

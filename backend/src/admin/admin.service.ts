import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMatchDto } from './dto/create-match.dto';
import { CreateLeagueDto } from './dto/create-league.dto';
import { CreateTeamDto } from './dto/create-team.dto';
import { CreateReportDto } from './dto/create-report.dto';
import { AddCreditsDto } from './dto/add-credits.dto';
import { ActivateSubscriptionDto } from './dto/activate-subscription.dto';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';

const SUBSCRIPTION_PACKAGES = [
  { id: 'weekly_pro', name: 'Weekly Pro', durationDays: 7, reportLimit: -1, price: 4.99 },
  { id: 'monthly_pro', name: 'Monthly Pro', durationDays: 30, reportLimit: -1, price: 14.99 },
  { id: 'elite', name: 'Elite', durationDays: 30, reportLimit: -1, price: 24.99 },
];

@Injectable()
export class AdminService {
  constructor(
    private prisma: PrismaService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  // ── Dashboard ────────────────────────────────────────────────────────────────
  async getDashboard() {
    const [totalUsers, totalMatches, totalReports, totalUnlocks] = await Promise.all([
      this.prisma.user.count({ where: { role: 'USER' } }),
      this.prisma.match.count(),
      this.prisma.premiumReport.count(),
      this.prisma.unlockedReport.count(),
    ]);
    return { totalUsers, totalMatches, totalReports, totalUnlocks };
  }

  // ── Matches ──────────────────────────────────────────────────────────────────
  getMatches() {
    return this.prisma.match.findMany({
      include: {
        sport: true, league: true,
        homeTeam: { select: { id: true, name: true } },
        awayTeam: { select: { id: true, name: true } },
      },
      orderBy: { matchDate: 'desc' },
    });
  }

  createMatch(dto: CreateMatchDto) {
    return this.prisma.match.create({ data: { ...dto, matchDate: new Date(dto.matchDate) } });
  }

  async updateMatch(id: number, dto: Partial<CreateMatchDto>) {
    await this.ensureMatch(id);
    return this.prisma.match.update({
      where: { id },
      data: { ...dto, ...(dto.matchDate && { matchDate: new Date(dto.matchDate) }) },
    });
  }

  async deleteMatch(id: number) {
    await this.ensureMatch(id);
    return this.prisma.match.delete({ where: { id } });
  }

  // ── Leagues ──────────────────────────────────────────────────────────────────
  getLeagues() {
    return this.prisma.league.findMany({ include: { sport: true }, orderBy: { name: 'asc' } });
  }

  createLeague(dto: CreateLeagueDto) {
    return this.prisma.league.create({ data: dto });
  }

  async updateLeague(id: number, dto: Partial<CreateLeagueDto>) {
    await this.ensureLeague(id);
    return this.prisma.league.update({ where: { id }, data: dto });
  }

  async deleteLeague(id: number) {
    await this.ensureLeague(id);
    return this.prisma.league.delete({ where: { id } });
  }

  // ── Teams ────────────────────────────────────────────────────────────────────
  getTeams() {
    return this.prisma.team.findMany({
      include: { sport: true, league: true },
      orderBy: { name: 'asc' },
    });
  }

  createTeam(dto: CreateTeamDto) {
    return this.prisma.team.create({ data: dto });
  }

  async updateTeam(id: number, dto: Partial<CreateTeamDto>) {
    await this.ensureTeam(id);
    return this.prisma.team.update({ where: { id }, data: dto });
  }

  async deleteTeam(id: number) {
    await this.ensureTeam(id);
    return this.prisma.team.delete({ where: { id } });
  }

  // ── Reports ──────────────────────────────────────────────────────────────────
  getReports() {
    return this.prisma.premiumReport.findMany({
      include: { match: { include: { homeTeam: true, awayTeam: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  createReport(dto: CreateReportDto) {
    return this.prisma.premiumReport.create({ data: dto });
  }

  async updateReport(id: number, dto: Partial<CreateReportDto>) {
    await this.ensureReport(id);
    return this.prisma.premiumReport.update({ where: { id }, data: dto });
  }

  async deleteReport(id: number) {
    await this.ensureReport(id);
    return this.prisma.premiumReport.delete({ where: { id } });
  }

  // ── Users ────────────────────────────────────────────────────────────────────
  getUsers() {
    return this.prisma.user.findMany({
      where: { role: 'USER' },
      select: {
        id: true, email: true, name: true, creditBalance: true, createdAt: true,
        subscription: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async addCredits(userId: number, dto: AddCreditsDto, adminId: number) {
    await this.ensureUser(userId);
    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { creditBalance: { increment: dto.amount } },
      }),
      this.prisma.creditTransaction.create({
        data: { userId, type: 'ADMIN_ADD', amount: dto.amount, description: 'Added by admin' },
      }),
      this.prisma.auditLog.create({
        data: { adminId, action: 'ADD_CREDITS', entityType: 'User', entityId: userId },
      }),
    ]);
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, creditBalance: true },
    });
  }

  async activateSubscription(userId: number, dto: ActivateSubscriptionDto, adminId: number) {
    await this.ensureUser(userId);
    const result = await this.subscriptionsService.mockActivate(userId, dto.packageId);
    await this.prisma.auditLog.create({
      data: { adminId, action: 'ACTIVATE_SUBSCRIPTION', entityType: 'User', entityId: userId },
    });
    return result;
  }

  // ── Guards ───────────────────────────────────────────────────────────────────
  private async ensureMatch(id: number) {
    const m = await this.prisma.match.findUnique({ where: { id } });
    if (!m) throw new NotFoundException('Match not found');
  }

  private async ensureLeague(id: number) {
    const l = await this.prisma.league.findUnique({ where: { id } });
    if (!l) throw new NotFoundException('League not found');
  }

  private async ensureTeam(id: number) {
    const t = await this.prisma.team.findUnique({ where: { id } });
    if (!t) throw new NotFoundException('Team not found');
  }

  private async ensureReport(id: number) {
    const r = await this.prisma.premiumReport.findUnique({ where: { id } });
    if (!r) throw new NotFoundException('Report not found');
  }

  private async ensureUser(id: number) {
    const u = await this.prisma.user.findUnique({ where: { id } });
    if (!u) throw new NotFoundException('User not found');
  }
}

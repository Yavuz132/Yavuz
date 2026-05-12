import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User } from '@prisma/client';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async getReport(matchId: number) {
    const report = await this.prisma.premiumReport.findUnique({
      where: { matchId },
      include: {
        match: {
          include: {
            homeTeam: { select: { id: true, name: true, logoUrl: true } },
            awayTeam: { select: { id: true, name: true, logoUrl: true } },
            league: { select: { id: true, name: true, country: true } },
            sport: { select: { id: true, name: true, slug: true } },
          },
        },
      },
    });
    if (!report || !report.isPublished) throw new NotFoundException('Report not found');
    // Return report metadata without sensitive content — user must unlock to read full report
    const { positiveFactors, negativeFactors, scenarioText, summary, ...preview } = report;
    return { ...preview, locked: true };
  }

  async unlockReport(matchId: number, user: User) {
    const report = await this.prisma.premiumReport.findUnique({ where: { matchId } });
    if (!report || !report.isPublished) throw new NotFoundException('Report not found');

    // Already unlocked — return full report without charging
    const existing = await this.prisma.unlockedReport.findUnique({
      where: { userId_reportId: { userId: user.id, reportId: report.id } },
    });
    if (existing) return this.getFullReport(report.id, user.id);

    // Check active subscription with remaining report capacity
    const sub = await this.prisma.subscription.findUnique({ where: { userId: user.id } });
    const hasActiveSub =
      sub &&
      sub.status === 'ACTIVE' &&
      new Date(sub.endDate) > new Date() &&
      (sub.reportLimit === -1 || sub.usedReportCount < sub.reportLimit);

    if (hasActiveSub) {
      await this.prisma.$transaction([
        this.prisma.unlockedReport.create({
          data: { userId: user.id, reportId: report.id, unlockedBy: 'SUBSCRIPTION' },
        }),
        this.prisma.subscription.update({
          where: { userId: user.id },
          data: { usedReportCount: { increment: 1 } },
        }),
      ]);
      return this.getFullReport(report.id, user.id);
    }

    // Deduct 1 credit (atomic transaction to prevent race conditions)
    if (user.creditBalance < 1) {
      throw new BadRequestException('Insufficient credits. Purchase credits or subscribe to unlock this report.');
    }

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { creditBalance: { decrement: 1 } },
      }),
      this.prisma.unlockedReport.create({
        data: { userId: user.id, reportId: report.id, unlockedBy: 'CREDIT' },
      }),
      this.prisma.creditTransaction.create({
        data: {
          userId: user.id,
          type: 'SPEND',
          amount: -1,
          description: `Unlocked report: ${report.title}`,
        },
      }),
    ]);

    return this.getFullReport(report.id, user.id);
  }

  private async getFullReport(reportId: number, userId: number) {
    const report = await this.prisma.premiumReport.findUnique({
      where: { id: reportId },
      include: {
        match: {
          include: {
            homeTeam: { select: { id: true, name: true, logoUrl: true } },
            awayTeam: { select: { id: true, name: true, logoUrl: true } },
            league: { select: { id: true, name: true, country: true } },
            sport: { select: { id: true, name: true, slug: true } },
            stats: true,
          },
        },
      },
    });
    return { ...report, locked: false };
  }

  async getUnlockedReports(userId: number) {
    const unlocked = await this.prisma.unlockedReport.findMany({
      where: { userId },
      include: {
        report: {
          include: {
            match: {
              include: {
                homeTeam: { select: { id: true, name: true } },
                awayTeam: { select: { id: true, name: true } },
                league: { select: { id: true, name: true } },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return unlocked.map((u) => ({ ...u.report, unlockedAt: u.createdAt, unlockedBy: u.unlockedBy }));
  }
}

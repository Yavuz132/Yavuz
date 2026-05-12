import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getProfile(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true, role: true, creditBalance: true, createdAt: true },
    });
    return user;
  }

  async getCredits(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { creditBalance: true },
    });
    return { creditBalance: user.creditBalance };
  }

  async getSubscription(userId: number) {
    return this.prisma.subscription.findUnique({
      where: { userId },
    });
  }

  async getUnlockedReports(userId: number) {
    return this.prisma.unlockedReport.findMany({
      where: { userId },
      include: {
        report: {
          include: { match: { include: { homeTeam: true, awayTeam: true, league: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}

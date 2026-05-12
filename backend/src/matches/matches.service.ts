import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const MATCH_INCLUDE = {
  sport: { select: { id: true, name: true, slug: true } },
  league: { select: { id: true, name: true, country: true, logoUrl: true } },
  homeTeam: { select: { id: true, name: true, logoUrl: true } },
  awayTeam: { select: { id: true, name: true, logoUrl: true } },
  stats: true,
  premiumReport: { select: { id: true, isPublished: true } },
};

@Injectable()
export class MatchesService {
  constructor(private prisma: PrismaService) {}

  findAll(sportId?: number, leagueId?: number) {
    return this.prisma.match.findMany({
      where: {
        ...(sportId && { sportId }),
        ...(leagueId && { leagueId }),
        status: { in: ['SCHEDULED', 'LIVE'] },
      },
      include: MATCH_INCLUDE,
      orderBy: { matchDate: 'asc' },
    });
  }

  findToday(sportId?: number) {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);

    return this.prisma.match.findMany({
      where: {
        matchDate: { gte: start, lte: end },
        ...(sportId && { sportId }),
      },
      include: MATCH_INCLUDE,
      orderBy: { matchDate: 'asc' },
    });
  }

  findPopular(limit = 10) {
    return this.prisma.match.findMany({
      where: { status: { in: ['SCHEDULED', 'LIVE'] } },
      include: MATCH_INCLUDE,
      orderBy: { popularityScore: 'desc' },
      take: limit,
    });
  }

  async findOne(id: number) {
    const match = await this.prisma.match.findUnique({
      where: { id },
      include: {
        ...MATCH_INCLUDE,
        stats: true,
      },
    });
    if (!match) throw new NotFoundException('Match not found');
    return match;
  }
}

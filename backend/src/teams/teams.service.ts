import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TeamsService {
  constructor(private prisma: PrismaService) {}

  findAll(sportId?: number, leagueId?: number) {
    return this.prisma.team.findMany({
      where: {
        ...(sportId && { sportId }),
        ...(leagueId && { leagueId }),
      },
      include: {
        sport: { select: { id: true, name: true, slug: true } },
        league: { select: { id: true, name: true, country: true } },
      },
      orderBy: { name: 'asc' },
    });
  }

  async findOne(id: number) {
    const team = await this.prisma.team.findUnique({
      where: { id },
      include: { sport: true, league: true },
    });
    if (!team) throw new NotFoundException('Team not found');
    return team;
  }
}

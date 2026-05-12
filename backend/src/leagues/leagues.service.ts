import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LeaguesService {
  constructor(private prisma: PrismaService) {}

  findAll(sportId?: number) {
    return this.prisma.league.findMany({
      where: sportId ? { sportId } : undefined,
      include: { sport: { select: { id: true, name: true, slug: true } } },
      orderBy: { name: 'asc' },
    });
  }

  async findOne(id: number) {
    const league = await this.prisma.league.findUnique({
      where: { id },
      include: { sport: true, teams: true },
    });
    if (!league) throw new NotFoundException('League not found');
    return league;
  }
}

import { Controller, Get, Post, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '@prisma/client';

@ApiTags('reports')
@Controller('reports')
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Get('unlocked')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  getUnlocked(@CurrentUser() user: User) {
    return this.reportsService.getUnlockedReports(user.id);
  }

  @Get(':matchId')
  getReport(@Param('matchId', ParseIntPipe) matchId: number) {
    return this.reportsService.getReport(matchId);
  }

  @Post(':matchId/unlock')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  unlock(@Param('matchId', ParseIntPipe) matchId: number, @CurrentUser() user: User) {
    return this.reportsService.unlockReport(matchId, user);
  }
}

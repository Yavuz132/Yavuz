import {
  Controller, Get, Post, Put, Delete,
  Param, Body, ParseIntPipe, UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateMatchDto } from './dto/create-match.dto';
import { CreateLeagueDto } from './dto/create-league.dto';
import { CreateTeamDto } from './dto/create-team.dto';
import { CreateReportDto } from './dto/create-report.dto';
import { AddCreditsDto } from './dto/add-credits.dto';
import { ActivateSubscriptionDto } from './dto/activate-subscription.dto';
import { User } from '@prisma/client';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('dashboard')
  getDashboard() { return this.adminService.getDashboard(); }

  // Matches
  @Get('matches') getMatches() { return this.adminService.getMatches(); }
  @Post('matches') createMatch(@Body() dto: CreateMatchDto) { return this.adminService.createMatch(dto); }
  @Put('matches/:id') updateMatch(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateMatchDto>) { return this.adminService.updateMatch(id, dto); }
  @Delete('matches/:id') deleteMatch(@Param('id', ParseIntPipe) id: number) { return this.adminService.deleteMatch(id); }

  // Leagues
  @Get('leagues') getLeagues() { return this.adminService.getLeagues(); }
  @Post('leagues') createLeague(@Body() dto: CreateLeagueDto) { return this.adminService.createLeague(dto); }
  @Put('leagues/:id') updateLeague(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateLeagueDto>) { return this.adminService.updateLeague(id, dto); }
  @Delete('leagues/:id') deleteLeague(@Param('id', ParseIntPipe) id: number) { return this.adminService.deleteLeague(id); }

  // Teams
  @Get('teams') getTeams() { return this.adminService.getTeams(); }
  @Post('teams') createTeam(@Body() dto: CreateTeamDto) { return this.adminService.createTeam(dto); }
  @Put('teams/:id') updateTeam(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateTeamDto>) { return this.adminService.updateTeam(id, dto); }
  @Delete('teams/:id') deleteTeam(@Param('id', ParseIntPipe) id: number) { return this.adminService.deleteTeam(id); }

  // Reports
  @Get('reports') getReports() { return this.adminService.getReports(); }
  @Post('reports') createReport(@Body() dto: CreateReportDto) { return this.adminService.createReport(dto); }
  @Put('reports/:id') updateReport(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateReportDto>) { return this.adminService.updateReport(id, dto); }
  @Delete('reports/:id') deleteReport(@Param('id', ParseIntPipe) id: number) { return this.adminService.deleteReport(id); }

  // Users
  @Get('users') getUsers() { return this.adminService.getUsers(); }
  @Post('users/:id/add-credits') addCredits(@Param('id', ParseIntPipe) id: number, @Body() dto: AddCreditsDto, @CurrentUser() admin: User) { return this.adminService.addCredits(id, dto, admin.id); }
  @Post('users/:id/activate-subscription') activateSubscription(@Param('id', ParseIntPipe) id: number, @Body() dto: ActivateSubscriptionDto, @CurrentUser() admin: User) { return this.adminService.activateSubscription(id, dto, admin.id); }
}

import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { ApiTags, ApiQuery } from '@nestjs/swagger';
import { TeamsService } from './teams.service';

@ApiTags('teams')
@Controller('teams')
export class TeamsController {
  constructor(private teamsService: TeamsService) {}

  @Get()
  @ApiQuery({ name: 'sportId', required: false, type: Number })
  @ApiQuery({ name: 'leagueId', required: false, type: Number })
  findAll(@Query('sportId') sportId?: string, @Query('leagueId') leagueId?: string) {
    return this.teamsService.findAll(
      sportId ? parseInt(sportId) : undefined,
      leagueId ? parseInt(leagueId) : undefined,
    );
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.teamsService.findOne(id);
  }
}

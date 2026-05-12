import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { ApiTags, ApiQuery } from '@nestjs/swagger';
import { MatchesService } from './matches.service';

@ApiTags('matches')
@Controller('matches')
export class MatchesController {
  constructor(private matchesService: MatchesService) {}

  @Get()
  @ApiQuery({ name: 'sportId', required: false, type: Number })
  @ApiQuery({ name: 'leagueId', required: false, type: Number })
  findAll(@Query('sportId') sportId?: string, @Query('leagueId') leagueId?: string) {
    return this.matchesService.findAll(
      sportId ? parseInt(sportId) : undefined,
      leagueId ? parseInt(leagueId) : undefined,
    );
  }

  @Get('today')
  @ApiQuery({ name: 'sportId', required: false, type: Number })
  findToday(@Query('sportId') sportId?: string) {
    return this.matchesService.findToday(sportId ? parseInt(sportId) : undefined);
  }

  @Get('popular')
  findPopular() {
    return this.matchesService.findPopular();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.matchesService.findOne(id);
  }
}

import { Controller, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { ApiTags, ApiQuery } from '@nestjs/swagger';
import { LeaguesService } from './leagues.service';

@ApiTags('leagues')
@Controller('leagues')
export class LeaguesController {
  constructor(private leaguesService: LeaguesService) {}

  @Get()
  @ApiQuery({ name: 'sportId', required: false, type: Number })
  findAll(@Query('sportId') sportId?: string) {
    return this.leaguesService.findAll(sportId ? parseInt(sportId) : undefined);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.leaguesService.findOne(id);
  }
}

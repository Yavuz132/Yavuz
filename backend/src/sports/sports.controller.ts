import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { SportsService } from './sports.service';

@ApiTags('sports')
@Controller('sports')
export class SportsController {
  constructor(private sportsService: SportsService) {}

  @Get()
  findAll() {
    return this.sportsService.findAll();
  }
}

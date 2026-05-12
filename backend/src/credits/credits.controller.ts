import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CreditsService } from './credits.service';
import { MockPurchaseDto } from './dto/mock-purchase.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '@prisma/client';

@ApiTags('credits')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('credits')
export class CreditsController {
  constructor(private creditsService: CreditsService) {}

  @Get('packages')
  getPackages() {
    return this.creditsService.getPackages();
  }

  @Get('history')
  getHistory(@CurrentUser() user: User) {
    return this.creditsService.getHistory(user.id);
  }

  @Post('mock-purchase')
  mockPurchase(@CurrentUser() user: User, @Body() dto: MockPurchaseDto) {
    return this.creditsService.mockPurchase(user.id, dto.packageId);
  }
}

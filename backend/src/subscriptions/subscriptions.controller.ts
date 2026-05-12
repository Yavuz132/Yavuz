import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { SubscriptionsService } from './subscriptions.service';
import { MockActivateDto } from './dto/mock-activate.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '@prisma/client';

@ApiTags('subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private subscriptionsService: SubscriptionsService) {}

  @Get('packages')
  getPackages() {
    return this.subscriptionsService.getPackages();
  }

  @Post('mock-activate')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  mockActivate(@CurrentUser() user: User, @Body() dto: MockActivateDto) {
    return this.subscriptionsService.mockActivate(user.id, dto.packageId);
  }
}

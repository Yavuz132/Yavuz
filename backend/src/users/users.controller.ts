import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '@prisma/client';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  getProfile(@CurrentUser() user: User) {
    return this.usersService.getProfile(user.id);
  }

  @Get('me/credits')
  getCredits(@CurrentUser() user: User) {
    return this.usersService.getCredits(user.id);
  }

  @Get('me/subscription')
  getSubscription(@CurrentUser() user: User) {
    return this.usersService.getSubscription(user.id);
  }

  @Get('me/unlocked-reports')
  getUnlockedReports(@CurrentUser() user: User) {
    return this.usersService.getUnlockedReports(user.id);
  }
}

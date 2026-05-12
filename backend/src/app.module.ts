import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { SportsModule } from './sports/sports.module';
import { LeaguesModule } from './leagues/leagues.module';
import { TeamsModule } from './teams/teams.module';
import { MatchesModule } from './matches/matches.module';
import { ReportsModule } from './reports/reports.module';
import { CreditsModule } from './credits/credits.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { AdminModule } from './admin/admin.module';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    SportsModule,
    LeaguesModule,
    TeamsModule,
    MatchesModule,
    ReportsModule,
    CreditsModule,
    SubscriptionsModule,
    AdminModule,
    NotificationsModule,
  ],
})
export class AppModule {}

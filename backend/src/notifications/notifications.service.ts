import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  findAll() {
    return this.prisma.notification.findMany({ orderBy: { createdAt: 'desc' } });
  }

  // Placeholder — wire FCM here in a future iteration
  async send(title: string, body: string, targetType: 'ALL' | 'USER' | 'SUBSCRIBERS' = 'ALL') {
    return this.prisma.notification.create({ data: { title, body, targetType } });
  }
}

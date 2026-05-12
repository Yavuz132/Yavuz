import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const SUBSCRIPTION_PACKAGES = [
  {
    id: 'free',
    name: 'Free',
    durationDays: 0,
    reportLimit: 2,
    price: 0,
    description: '2 free analyses per month',
  },
  {
    id: 'weekly_pro',
    name: 'Weekly Pro',
    durationDays: 7,
    reportLimit: -1,
    price: 4.99,
    description: 'Unlimited analyses for 7 days',
  },
  {
    id: 'monthly_pro',
    name: 'Monthly Pro',
    durationDays: 30,
    reportLimit: -1,
    price: 14.99,
    description: 'Unlimited analyses for 30 days',
  },
  {
    id: 'elite',
    name: 'Elite',
    durationDays: 30,
    reportLimit: -1,
    price: 24.99,
    description: 'Unlimited analyses + priority access for 30 days',
  },
];

@Injectable()
export class SubscriptionsService {
  constructor(private prisma: PrismaService) {}

  getPackages() {
    return SUBSCRIPTION_PACKAGES;
  }

  async mockActivate(userId: number, packageId: string) {
    const pkg = SUBSCRIPTION_PACKAGES.find((p) => p.id === packageId);
    if (!pkg || pkg.id === 'free') throw new Error('Invalid subscription package');

    const endDate = new Date();
    endDate.setDate(endDate.getDate() + pkg.durationDays);

    const sub = await this.prisma.subscription.upsert({
      where: { userId },
      update: {
        packageName: pkg.name,
        status: 'ACTIVE',
        startDate: new Date(),
        endDate,
        reportLimit: pkg.reportLimit,
        usedReportCount: 0,
      },
      create: {
        userId,
        packageName: pkg.name,
        status: 'ACTIVE',
        endDate,
        reportLimit: pkg.reportLimit,
      },
    });

    await this.prisma.paymentMock.create({
      data: { userId, type: 'SUBSCRIPTION', amount: pkg.price, status: 'COMPLETED' },
    });

    return { success: true, subscription: sub };
  }
}

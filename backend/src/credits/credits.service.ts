import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const CREDIT_PACKAGES = [
  { id: 'pack_5', credits: 5, price: 4.99, label: '5 Credits' },
  { id: 'pack_15', credits: 15, price: 12.99, label: '15 Credits' },
  { id: 'pack_30', credits: 30, price: 22.99, label: '30 Credits' },
];

@Injectable()
export class CreditsService {
  constructor(private prisma: PrismaService) {}

  getPackages() {
    return CREDIT_PACKAGES;
  }

  getHistory(userId: number) {
    return this.prisma.creditTransaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async mockPurchase(userId: number, packageId: string) {
    const pkg = CREDIT_PACKAGES.find((p) => p.id === packageId);
    if (!pkg) throw new Error('Invalid package');

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { creditBalance: { increment: pkg.credits } },
      }),
      this.prisma.creditTransaction.create({
        data: {
          userId,
          type: 'PURCHASE',
          amount: pkg.credits,
          description: `Mock purchase: ${pkg.label}`,
        },
      }),
      this.prisma.paymentMock.create({
        data: { userId, type: 'CREDIT', amount: pkg.price, status: 'COMPLETED' },
      }),
    ]);

    const updated = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { creditBalance: true },
    });
    return { success: true, creditsAdded: pkg.credits, newBalance: updated.creditBalance };
  }
}

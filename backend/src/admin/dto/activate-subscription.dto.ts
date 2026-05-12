import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ActivateSubscriptionDto {
  @ApiProperty({ example: 'monthly_pro' })
  @IsString()
  packageId: string;
}

import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class MockActivateDto {
  @ApiProperty({ example: 'monthly_pro', enum: ['weekly_pro', 'monthly_pro', 'elite'] })
  @IsString()
  packageId: string;
}

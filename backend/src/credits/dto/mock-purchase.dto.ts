import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class MockPurchaseDto {
  @ApiProperty({ example: 'pack_5', enum: ['pack_5', 'pack_15', 'pack_30'] })
  @IsString()
  packageId: string;
}

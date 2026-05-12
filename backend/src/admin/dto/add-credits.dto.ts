import { IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddCreditsDto {
  @ApiProperty({ minimum: 1 })
  @IsInt()
  @Min(1)
  amount: number;
}

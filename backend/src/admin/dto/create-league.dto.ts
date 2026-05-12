import { IsInt, IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateLeagueDto {
  @ApiProperty() @IsInt() sportId: number;
  @ApiProperty() @IsString() name: string;
  @ApiProperty() @IsString() country: string;
  @ApiPropertyOptional() @IsOptional() @IsString() logoUrl?: string;
}

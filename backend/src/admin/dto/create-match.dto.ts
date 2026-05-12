import { IsInt, IsDateString, IsEnum, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { RiskLevel } from '@prisma/client';

export class CreateMatchDto {
  @ApiProperty() @IsInt() sportId: number;
  @ApiProperty() @IsInt() leagueId: number;
  @ApiProperty() @IsInt() homeTeamId: number;
  @ApiProperty() @IsInt() awayTeamId: number;
  @ApiProperty() @IsDateString() matchDate: string;
  @ApiPropertyOptional({ minimum: 0, maximum: 100 }) @IsOptional() @IsInt() @Min(0) @Max(100) dataScore?: number;
  @ApiPropertyOptional({ minimum: 0, maximum: 100 }) @IsOptional() @IsInt() @Min(0) @Max(100) popularityScore?: number;
  @ApiPropertyOptional({ enum: RiskLevel }) @IsOptional() @IsEnum(RiskLevel) riskLevel?: RiskLevel;
}

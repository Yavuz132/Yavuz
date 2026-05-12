import { IsInt, IsString, IsEnum, IsArray, IsBoolean, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { RiskLevel, ConfidenceLevel } from '@prisma/client';

export class CreateReportDto {
  @ApiProperty() @IsInt() matchId: number;
  @ApiProperty() @IsString() title: string;
  @ApiProperty() @IsString() summary: string;
  @ApiProperty({ minimum: 0, maximum: 100 }) @IsInt() @Min(0) @Max(100) dataScore: number;
  @ApiProperty({ enum: RiskLevel }) @IsEnum(RiskLevel) riskLevel: RiskLevel;
  @ApiProperty({ enum: ConfidenceLevel }) @IsEnum(ConfidenceLevel) confidenceLevel: ConfidenceLevel;
  @ApiProperty({ type: [String] }) @IsArray() @IsString({ each: true }) positiveFactors: string[];
  @ApiProperty({ type: [String] }) @IsArray() @IsString({ each: true }) negativeFactors: string[];
  @ApiProperty() @IsString() scenarioText: string;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() isPublished?: boolean;
}

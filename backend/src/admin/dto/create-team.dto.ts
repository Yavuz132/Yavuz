import { IsInt, IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateTeamDto {
  @ApiProperty() @IsInt() sportId: number;
  @ApiProperty() @IsInt() leagueId: number;
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsOptional() @IsString() logoUrl?: string;
}

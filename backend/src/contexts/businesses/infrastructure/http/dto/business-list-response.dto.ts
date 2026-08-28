import { ApiProperty } from '@nestjs/swagger';
import { BusinessResponseDto } from './business-response.dto';

export class BusinessListResponseDto {
  @ApiProperty({ type: [BusinessResponseDto] })
  items!: BusinessResponseDto[];

  @ApiProperty({ nullable: true, type: String })
  nextCursor!: string | null;
}

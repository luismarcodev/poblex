import { ApiProperty } from '@nestjs/swagger';
import { NewsResponseDto } from './news-response.dto';

export class NewsListResponseDto {
  @ApiProperty({ type: [NewsResponseDto] })
  pinned!: NewsResponseDto[];

  @ApiProperty({ type: [NewsResponseDto] })
  items!: NewsResponseDto[];

  @ApiProperty({ nullable: true, type: String })
  nextCursor!: string | null;
}

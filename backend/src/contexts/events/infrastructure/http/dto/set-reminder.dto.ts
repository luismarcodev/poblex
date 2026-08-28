import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDate } from 'class-validator';

export class SetReminderDto {
  @ApiProperty({
    type: String,
    format: 'date-time',
    description: 'Instante en el que avisar. Debe ser anterior al inicio.',
  })
  @Type(() => Date)
  @IsDate()
  remindAt!: Date;
}

export class ReminderResponseDto {
  @ApiProperty()
  eventId!: string;

  @ApiProperty()
  remindAt!: string;
}

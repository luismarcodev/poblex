import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { DeviceThrottlerGuard } from '../../../../shared/infrastructure/http/device-throttler.guard';
import {
  GetFormDetailUseCase,
  ListFormsUseCase,
} from '../../application/use-cases/query-forms.use-cases';
import { SubmitFormUseCase } from '../../application/use-cases/submit-form.use-case';
import { FormHttpMapper } from '../mappers/form-http.mapper';
import {
  FormListResponseDto,
  FormResponseDto,
  FormDetailQueryDto,
  ListFormsQueryDto,
  SubmitFormDto,
} from './dto/form.dto';

@ApiTags('forms')
@Controller('forms')
export class FormsController {
  constructor(
    private readonly listForms: ListFormsUseCase,
    private readonly getFormDetail: GetFormDetailUseCase,
    private readonly submitForm: SubmitFormUseCase,
  ) {}

  @Get()
  async list(@Query() query: ListFormsQueryDto): Promise<FormListResponseDto> {
    const result = await this.listForms.execute({
      municipalityId: query.municipalityId,
      includeClosed: query.includeClosed,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((form) =>
        FormHttpMapper.toResponseDto(form, false),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @ApiHeader({ name: 'X-Device-Id', required: false })
  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: FormDetailQueryDto,
    @DeviceIdHeader() deviceId: string | undefined,
  ): Promise<FormResponseDto> {
    const result = await this.getFormDetail.execute(
      id,
      query.municipalityId,
      deviceId,
    );
    if (result.isFailure) throw result.error;
    return FormHttpMapper.toResponseDto(
      result.value.form,
      result.value.alreadySubmitted,
    );
  }

  @UseGuards(DeviceThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  @Post(':id/submissions')
  @HttpCode(HttpStatus.NO_CONTENT)
  async submit(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: SubmitFormDto,
  ): Promise<void> {
    const result = await this.submitForm.execute({
      formId: id,
      deviceId,
      answers: dto.answers,
    });
    if (result.isFailure) throw result.error;
  }
}

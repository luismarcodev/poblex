import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiProduces, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import {
  CreateFormUseCase,
  DeleteFormUseCase,
  ExportFormSubmissionsUseCase,
} from '../../application/use-cases/manage-forms.use-cases';
import { FormHttpMapper } from '../mappers/form-http.mapper';
import { CreateFormDto, FormResponseDto } from './dto/form.dto';

@ApiTags('forms-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/forms')
export class FormsAdminController {
  constructor(
    private readonly createForm: CreateFormUseCase,
    private readonly deleteForm: DeleteFormUseCase,
    private readonly exportSubmissions: ExportFormSubmissionsUseCase,
  ) {}

  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateFormDto,
  ): Promise<FormResponseDto> {
    const result = await this.createForm.execute({
      managerId,
      municipalityId: dto.municipalityId,
      title: dto.title,
      description: dto.description,
      deadline: dto.deadline,
      fields: dto.fields,
    });
    if (result.isFailure) throw result.error;
    return FormHttpMapper.toResponseDto(result.value, false);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteForm.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }

  @ApiProduces('text/csv')
  @Header('Content-Type', 'text/csv; charset=utf-8')
  @Header('Content-Disposition', 'attachment; filename="respuestas.csv"')
  @Get(':id/submissions.csv')
  async exportCsv(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<string> {
    const result = await this.exportSubmissions.execute(id, managerId);
    if (result.isFailure) throw result.error;
    return result.value;
  }
}

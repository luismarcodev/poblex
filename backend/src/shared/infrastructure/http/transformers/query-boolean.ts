import type { TransformFnParams } from 'class-transformer';

// Only the two canonical query-string values are converted. Leaving any
// other value untouched lets @IsBoolean reject it instead of silently
// treating a typo such as `?includeClosed=treu` as false.
export function parseQueryBoolean({ value }: TransformFnParams): unknown {
  if (value === true || value === 'true') return true;
  if (value === false || value === 'false') return false;
  return value;
}

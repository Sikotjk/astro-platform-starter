// Mappt Domain-Fehler (framework-unabhängig geworfen) auf saubere HTTP-Status.
// Ohne diesen Filter würden z.B. ungültige Statusübergänge als 500 erscheinen.

import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';
import { BookingTransitionError } from '../bookings/booking.machine';
import { BookingNotFoundError, BookingStateError } from '../bookings/booking.service';
import { CustomsValidationError } from '../customs/customs.service';

@Catch()
export class DomainExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('DomainException');

  catch(exception: unknown, host: ArgumentsHost): void {
    const res = host.switchToHttp().getResponse<Response>();

    // NestJS-eigene HttpExceptions unverändert durchreichen.
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      res.status(status).json(toBody(status, exception.getResponse()));
      return;
    }

    const { status, message } = this.classify(exception);
    if (status >= 500) this.logger.error(message, (exception as Error)?.stack);
    res.status(status).json({ statusCode: status, message });
  }

  private classify(e: unknown): { status: number; message: string } {
    if (e instanceof BookingNotFoundError) {
      return { status: HttpStatus.NOT_FOUND, message: e.message };
    }
    if (e instanceof BookingTransitionError || e instanceof BookingStateError) {
      // Ungültiger Übergang / Geschäftsregel verletzt -> Konflikt.
      return { status: HttpStatus.CONFLICT, message: e.message };
    }
    if (e instanceof CustomsValidationError) {
      return { status: HttpStatus.BAD_REQUEST, message: e.message };
    }
    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      message: 'Internal server error',
    };
  }
}

function toBody(status: number, response: string | object): object {
  return typeof response === 'string' ? { statusCode: status, message: response } : response;
}

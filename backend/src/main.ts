import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DomainExceptionFilter } from './common/domain-exception.filter';

async function bootstrap(): Promise<void> {
  // rawBody:true ist nötig, damit der Stripe-Webhook die Signatur prüfen kann.
  const app = await NestFactory.create(AppModule, { rawBody: true });

  // CORS nur aktivieren, wenn Origins konfiguriert sind (für ein Web-Frontend).
  // Mobile Apps brauchen kein CORS. CORS_ORIGIN = kommagetrennte Liste.
  const corsOrigins = (process.env.CORS_ORIGIN ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter((o) => o.length > 0);
  if (corsOrigins.length > 0) {
    app.enableCors({ origin: corsOrigins, credentials: true });
  }

  app.useGlobalFilters(new DomainExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // unbekannte Felder verwerfen
      forbidNonWhitelisted: true, // bzusätzliche Felder => Fehler
      transform: true, // Payload in DTO-Instanzen umwandeln
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
  new Logger('Bootstrap').log(`API läuft auf http://localhost:${port}`);
}

void bootstrap();

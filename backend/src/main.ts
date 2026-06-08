import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  // rawBody:true ist nötig, damit der Stripe-Webhook die Signatur prüfen kann.
  const app = await NestFactory.create(AppModule, { rawBody: true });

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

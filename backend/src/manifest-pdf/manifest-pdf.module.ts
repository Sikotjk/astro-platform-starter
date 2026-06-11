import { Module, Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ManifestPdfController } from './manifest-pdf.controller';
import { ManifestPdfService } from './manifest-pdf.service';
import { PdfKitManifestRenderer } from './pdfkit-renderer';
import { MANIFEST_PDF_RENDERER } from './manifest-pdf.tokens';
import { CustomsModule } from '../customs/customs.module';
import { AuthModule } from '../auth/auth.module';

const rendererProvider: Provider = {
  provide: MANIFEST_PDF_RENDERER,
  inject: [ConfigService],
  useFactory: (config: ConfigService) =>
    new PdfKitManifestRenderer({ fontDir: config.get<string>('MANIFEST_FONT_DIR') }),
};

@Module({
  imports: [CustomsModule, AuthModule],
  controllers: [ManifestPdfController],
  providers: [ManifestPdfService, rendererProvider],
})
export class ManifestPdfModule {}

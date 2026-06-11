import { Injectable, UnprocessableEntityException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CustomsService } from '../customs/customs.service';
import { CreatePackageDto } from './dto/package.dto';

@Injectable()
export class PackagesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly customs: CustomsService,
  ) {}

  async create(senderId: string, dto: CreatePackageDto) {
    // Zoll-Prüfung VOR dem Anlegen: verbotene Inhalte gar nicht erst speichern.
    const declaration = this.customs.evaluate(
      dto.items.map((i) => ({
        category: i.category,
        description: i.description,
        quantity: i.quantity,
        unitValueEur: i.unitValueEur,
        isSealed: i.isSealed,
      })),
    );

    if (!declaration.declarable) {
      throw new UnprocessableEntityException({
        message: 'Paket enthält nicht transportierbare Inhalte.',
        declaration,
      });
    }

    const pkg = await this.prisma.package.create({
      data: {
        senderId,
        title: dto.title,
        weightKg: new Prisma.Decimal(dto.weightKg),
        dimensionsCm: dto.dimensionsCm,
        declaredValueEur: new Prisma.Decimal(dto.declaredValueEur),
        recipientName: dto.recipientName,
        recipientPhone: dto.recipientPhone,
        recipientCity: dto.recipientCity,
        items: {
          create: dto.items.map((i) => ({
            category: i.category,
            description: i.description,
            quantity: i.quantity,
            unitValueEur: new Prisma.Decimal(i.unitValueEur),
            isSealed: i.isSealed,
          })),
        },
      },
      include: { items: true },
    });

    return { package: pkg, declaration };
  }
}

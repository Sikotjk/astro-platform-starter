import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

/** Markiert einen Endpunkt als rollenbeschränkt (z.B. @Roles('ADMIN')). */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

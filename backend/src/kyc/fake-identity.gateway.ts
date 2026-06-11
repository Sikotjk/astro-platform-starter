import { randomBytes } from 'node:crypto';
import type {
  IdentityGateway,
  CreateVerificationInput,
  CreateVerificationResult,
} from './identity.gateway';

export class FakeIdentityGateway implements IdentityGateway {
  readonly created: CreateVerificationInput[] = [];

  async createVerificationSession(
    input: CreateVerificationInput,
  ): Promise<CreateVerificationResult> {
    this.created.push(input);
    const id = `vs_fake_${randomBytes(6).toString('hex')}`;
    return { sessionId: id, clientSecret: `${id}_secret`, url: `https://verify.test/${id}` };
  }
}

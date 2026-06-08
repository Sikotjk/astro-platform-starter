// ESLint Flat-Config (ESLint 9 + typescript-eslint 8).
import tseslint from 'typescript-eslint';
import eslintConfigPrettier from 'eslint-config-prettier';

export default tseslint.config(
  { ignores: ['dist', 'node_modules', 'prisma/migrations', 'assets', 'coverage'] },
  ...tseslint.configs.recommended,
  // Prettier zuletzt: schaltet formatierungsbezogene Regeln ab.
  eslintConfigPrettier,
  {
    rules: {
      // Wir nutzen an wenigen, klar kommentierten Stellen bewusst `any`
      // (z.B. Prisma-JSON, Duck-Typing) -> als Warnung statt Fehler.
      '@typescript-eslint/no-explicit-any': 'warn',
      // Ungenutzte Variablen: erlaube absichtliche _-Prefixe.
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },
  {
    // Tests dürfen lockerer sein.
    files: ['**/*.test.ts', '**/*.e2e-spec.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
);

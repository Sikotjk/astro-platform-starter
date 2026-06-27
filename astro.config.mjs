import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

// Statischer Build für GitHub Pages (Projekt-Site unter /astro-platform-starter).
// https://astro.build/config
export default defineConfig({
    site: 'https://sikotjk.github.io',
    base: '/astro-platform-starter',
    output: 'static',
    trailingSlash: 'ignore',
    vite: {
        plugins: [tailwindcss()]
    },
    integrations: [react(), sitemap()]
});

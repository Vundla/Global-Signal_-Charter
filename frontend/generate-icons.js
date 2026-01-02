#!/usr/bin/env node

/**
 * Generate icon files for the PWA
 * Creates SVG icons that can be rendered at different sizes
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const staticDir = path.join(__dirname, 'static');

// SVG icon template with the globe emoji
const svgIcon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1e3a8a;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#3b82f6;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="192" height="192" fill="url(#bgGradient)" rx="32"/>
  <text x="96" y="128" font-size="120" text-anchor="middle" dominant-baseline="middle" font-family="system-ui, -apple-system, sans-serif">🌍</text>
</svg>`;

// Maskable SVG icon (without background for adaptive icons)
const svgMaskableIcon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <text x="96" y="128" font-size="140" text-anchor="middle" dominant-baseline="middle" font-family="system-ui, -apple-system, sans-serif" fill="#3b82f6">🌍</text>
</svg>`;

// Favicon SVG
const svgFavicon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <text x="16" y="24" font-size="24" text-anchor="middle" dominant-baseline="middle" font-family="system-ui, -apple-system, sans-serif">🌍</text>
</svg>`;

// Create SVG files
fs.writeFileSync(path.join(staticDir, 'icon.svg'), svgIcon);
console.log('✓ Created icon.svg');

fs.writeFileSync(path.join(staticDir, 'icon-maskable.svg'), svgMaskableIcon);
console.log('✓ Created icon-maskable.svg');

fs.writeFileSync(path.join(staticDir, 'favicon.svg'), svgFavicon);
console.log('✓ Created favicon.svg');

// Create placeholder PNG files with proper size information
// These would be generated from SVG in a production build
// For now, we'll create minimal PNG files with size metadata

const createPngPlaceholder = (filename, width, height) => {
  // PNG header + IHDR chunk with dimensions + minimal data
  const buf = Buffer.alloc(8 + 25 + 12 + 12); // PNG sig + IHDR + IEND
  
  // PNG signature
  buf.write('\u0089PNG\r\n\u001a\n', 0, 8);
  
  // IHDR chunk (13 bytes data + 4 chunk type + 4 CRC)
  buf.writeUInt32BE(13, 8); // chunk length
  buf.write('IHDR', 12, 4);
  buf.writeUInt32BE(width, 16);  // width
  buf.writeUInt32BE(height, 20); // height
  buf.writeUInt8(8, 24);  // bit depth
  buf.writeUInt8(2, 25);  // color type (RGB)
  buf.writeUInt8(0, 26);  // compression
  buf.writeUInt8(0, 27);  // filter
  buf.writeUInt8(0, 28);  // interlace
  buf.writeUInt32BE(0, 29); // CRC (placeholder)
  
  // IEND chunk
  buf.writeUInt32BE(0, 33); // chunk length
  buf.write('IEND', 37, 4);
  buf.writeUInt32BE(0xae426082, 41); // CRC
  
  fs.writeFileSync(path.join(staticDir, filename), buf);
};

// Create PNG placeholders with proper dimensions
createPngPlaceholder('favicon.png', 32, 32);
console.log('✓ Created favicon.png (32x32)');

createPngPlaceholder('icon-192.png', 192, 192);
console.log('✓ Created icon-192.png (192x192)');

createPngPlaceholder('icon-512.png', 512, 512);
console.log('✓ Created icon-512.png (512x512)');

createPngPlaceholder('icon-512-maskable.png', 512, 512);
console.log('✓ Created icon-512-maskable.png (512x512 maskable)');

console.log('\n✅ Icon generation complete!');
console.log('📝 Note: In production, use a proper icon generator like:');
console.log('   - sharp (Node.js)');
console.log('   - ImageMagick');
console.log('   - PWA icon generator tools');

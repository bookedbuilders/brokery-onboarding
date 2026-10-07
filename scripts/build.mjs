import { copyFile, mkdir, rm } from 'node:fs/promises';

const root = new URL('../', import.meta.url);
const output = new URL('dist/', root);

await rm(output, { recursive: true, force: true });
await mkdir(new URL('admin/', output), { recursive: true });

// Explicitly publish only browser assets. Add new app assets here as needed.
for (const file of ['index.html', 'config.js', 'admin/index.html']) {
  await copyFile(new URL(file, root), new URL(file, output));
}

console.log('Built static site in dist/');

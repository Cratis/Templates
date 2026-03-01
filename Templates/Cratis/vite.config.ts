import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { EmitMetadataPlugin } from '@cratis/arc.vite'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  optimizeDeps: {
    exclude: ['tslib'],
  },
  esbuild: {
    supported: {
      'top-level-await': true,
    },
  },
  plugins: [
    react(),
    tailwindcss(),
    EmitMetadataPlugin() as any
  ],
  build: {
    outDir: '../wwwroot',
    assetsDir: '',
    modulePreload: false,
    target: 'esnext',
    minify: false,
    cssCodeSplit: false,
    emptyOutDir: true
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        ws: true
      }
    }
  },
  resolve: {
    alias: {
      'Api': path.resolve('./Features')
    }
  }
})

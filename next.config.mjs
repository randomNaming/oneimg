/** @type {import('next').NextConfig} */
// added by create cloudflare to enable calling `getCloudflareContext()` in `next dev`
// Cloudflare dev mode is disabled by default to prevent workerd binary issues during Docker builds
// To enable in local development, uncomment the line below or set ENABLE_CLOUDFLARE_DEV=1
const nextConfig = {}

// Cloudflare dev mode initialization - disabled for Docker builds
// Uncomment the following lines if you need Cloudflare dev mode in local development:
// if (process.env.NODE_ENV !== 'production' && process.env.SKIP_CLOUDFLARE_DEV !== '1') {
//   try {
//     const { initOpenNextCloudflareForDev } = await import('@opennextjs/cloudflare')
//     initOpenNextCloudflareForDev()
//   } catch (error) {
//     console.warn('Cloudflare dev mode skipped:', error.message)
//   }
// }

export default nextConfig

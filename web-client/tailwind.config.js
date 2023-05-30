/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,}",
  ],
  theme: {
    extend: {
      colors: {
        theme: {
          neutral: '#e2e8f0',
          'current-screen': '#ffffff'
        }
      }
    },
  },
  plugins: [],
}

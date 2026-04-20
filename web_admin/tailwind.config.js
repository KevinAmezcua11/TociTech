/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background:  "#0F0F14",
        surface:     "#1A1A22",
        surfaceDark: "#0F172A",
        primary:     "#6C63FF",
        blue:        "#1E88E5",
        "brand-green": "#22C55E",
        // Text helpers (usados como color de texto)
        primary:     "#6C63FF",
        secondary:   "rgba(255,255,255,0.70)",
        muted:       "rgba(255,255,255,0.38)",
      },
    },
  },
  plugins: [],
};
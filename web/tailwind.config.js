/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Inter', 'Segoe UI', 'sans-serif'],
            },
            animation: {
                'fade-in': 'fadeIn 0.5s ease-out forwards',
                'pulse-glow': 'pulseGlow 3s infinite',
            },
            keyframes: {
                fadeIn: {
                    '0%': { opacity: '0', transform: 'translateY(20px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                pulseGlow: {
                    '0%, 100%': { filter: 'drop-shadow(0 0 5px rgba(236, 72, 153, 0.5))' },
                    '50%': { filter: 'drop-shadow(0 0 15px rgba(6, 182, 212, 0.5))' },
                }
            }
        },
    },
    plugins: [],
}

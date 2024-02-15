import defaultTheme from "tailwindcss/defaultTheme";
import forms from "@tailwindcss/forms";

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php",
        "./storage/framework/views/*.php",
        "./resources/views/**/*.blade.php",
        "./node_modules/flowbite/**/.js",
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ["Figtree", ...defaultTheme.fontFamily.sans],
                poppins: ["Poppins", ...defaultTheme.fontFamily.sans],
                montserrat: ["Montserrat", ...defaultTheme.fontFamily.sans],
                crimson: ["Crimson Text", ...defaultTheme.fontFamily.sans],
            },
            colors: {
                white: {
                    DEFAULT: "#ffffff",
                    100: "#f8f7f4",
                    200: "#fbfff4",
                    300: "#fffef7",
                    400: "#fff5ee",
                    500: "#fff5ea",
                },
            },
        },
    },

    plugins: [forms, require("flowbite/plugin")],
};

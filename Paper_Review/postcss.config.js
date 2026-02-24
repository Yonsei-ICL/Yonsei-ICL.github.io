module.exports = {
  plugins: [
    require("postcss-import")({
      path: ["assets/css"]
    }),
    require("tailwindcss"),
    require("autoprefixer"),
    require("postcss-nested"),
    ...(process.env.NODE_ENV == "production" ? [require("cssnano")({ preset: "default" })] : []),
  ],
};

/** ts-jest runs the TypeScript sources directly — no build step for tests. */
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testMatch: ["**/__tests__/**/*.test.ts"],
};

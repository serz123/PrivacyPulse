export default {
  transform: {
    "^.+\\.[tj]s$": "babel-jest", // Use Babel to transpile test files
  },
  testEnvironment: "node", // Use Node.js environment for tests
};

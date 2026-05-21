module.exports = {
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.js$': 'babel-jest',
    'node_modules/@hotwired/stimulus/.+\\.js$': 'babel-jest',
  },
  transformIgnorePatterns: [],
  testMatch: ['<rootDir>/test/javascript/**/*.test.js'],
  collectCoverageFrom: [
    'app/javascript/**/*.{js,jsx}',
    '!app/javascript/application.js',
  ],
  moduleNameMapper: {
    '^~/(.+)$': '<rootDir>/app/javascript/$1',
    '^app/(.+)$': '<rootDir>/app/$1',
  },
};

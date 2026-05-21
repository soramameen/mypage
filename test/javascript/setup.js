// Jest setup file
require('@testing-library/jest-dom');

// Mock ActionCable
global.App = {
  cable: {
    subscriptions: {
      create: jest.fn(() => ({
        perform: jest.fn(),
        unsubscribe: jest.fn(),
      })),
    },
  },
};

// Mock WebSocket
global.WebSocket = jest.fn();

// Custom Event polyfill for testing
global.CustomEvent = class CustomEvent extends Event {
  constructor(type, options = {}) {
    super(type, options);
    this.detail = options.detail || {};
  }
};

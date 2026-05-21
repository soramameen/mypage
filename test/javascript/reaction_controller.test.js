const ReactionController = require('~/controllers/reaction_controller').default;

describe('ReactionController', () => {
  let controller;
  let element;
  let mockEvent;

  beforeEach(() => {
    // Create test element
    element = document.createElement('button');
    element.setAttribute('data-controller', 'reaction');
    element.setAttribute('data-action', 'reaction#toggle');
    element.textContent = '👍';

    // Mock element property on ReactionController
    const originalElementPropertyDescriptor = Object.getOwnPropertyDescriptor(
      Object.getPrototypeOf(ReactionController),
      'element'
    );
    Object.defineProperty(ReactionController.prototype, 'element', {
      ...originalElementPropertyDescriptor,
      get: function() { return element; },
      configurable: true
    });

    // Create controller instance
    controller = new ReactionController();

    // Mock event
    mockEvent = {
      preventDefault: jest.fn(),
    };
  });

  afterEach(() => {
    jest.clearAllMocks();
    document.body.innerHTML = '';
  });

  describe('toggle', () => {
    test('JC-007: リアクションの切り替え', () => {
      // The toggle logic is handled by server
      // The button will be replaced with updated state via Turbo
      expect(() => {
        controller.toggle(mockEvent);
      }).not.toThrow();
    });

    test('handles toggle without error', () => {
      // Verify method exists and can be called
      expect(typeof controller.toggle).toBe('function');
      controller.toggle(mockEvent);
    });
  });

  describe('edge cases', () => {
    test('handles events without preventDefault', () => {
      const eventWithoutPreventDefault = {};
      expect(() => {
        controller.toggle(eventWithoutPreventDefault);
      }).not.toThrow();
    });
  });
});

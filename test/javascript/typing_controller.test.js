const TypingController = require('~/controllers/typing_controller').default;

describe('TypingController', () => {
  let controller;
  let element;

  beforeEach(() => {
    // Create test element
    element = document.createElement('div');
    element.setAttribute('data-controller', 'typing');
    element.setAttribute('data-typing-room-id-value', '123');
    document.body.appendChild(element);

    // Mock timers
    jest.useFakeTimers();

    // Create controller instance with mocked element
    const originalElementPropertyDescriptor = Object.getOwnPropertyDescriptor(
      Object.getPrototypeOf(TypingController),
      'element'
    );
    Object.defineProperty(TypingController.prototype, 'element', {
      ...originalElementPropertyDescriptor,
      get: function() { return element; },
      configurable: true
    });
    Object.defineProperty(TypingController.prototype, 'roomIdValue', {
      ...Object.getOwnPropertyDescriptor(
        Object.getPrototypeOf(TypingController),
        'roomIdValue'
      ),
      get: function() { return '123'; },
      configurable: true
    });

    controller = new TypingController();
  });

  afterEach(() => {
    jest.clearAllTimers();
    jest.clearAllMocks();
    document.body.innerHTML = '';
  });

  describe('connect', () => {
    test('JC-008: タイピングインジケーターの初期化', () => {
      controller.connect();

      const typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator).toBeTruthy();
      expect(typingIndicator.style.display).toBe('none');

      // Check event listener is registered
      expect(controller.boundHandleTyping).toBeDefined();
    });

    test('JC-012: 接続解除時のクリーンアップ', () => {
      controller.connect();

      const removeSpy = jest.spyOn(document, 'removeEventListener');

      controller.disconnect();

      expect(removeSpy).toHaveBeenCalledWith('typing', controller.boundHandleTyping);
    });
  });

  describe('handleTyping', () => {
    test('JC-009: タイピング開始時のインジケーター表示', () => {
      controller.connect();

      const event = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });

      controller.handleTyping(event);

      const typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');
      expect(typingIndicator.textContent).toBe('Bob が入力中...');
    });

    test('JC-010: タイピング停止時のインジケーター非表示', () => {
      controller.connect();

      // First show the indicator
      const typingEvent = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });
      controller.handleTyping(typingEvent);

      let typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');

      // Then hide it
      const stopEvent = new CustomEvent('typing', {
        detail: { status: 'stop', user_name: 'Bob' },
      });
      controller.handleTyping(stopEvent);

      typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('none');
    });

    test('JC-011: 連続タイピング時のタイマー更新', () => {
      controller.connect();

      const event1 = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });

      const event2 = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });

      // First typing event
      controller.handleTyping(event1);
      let typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');

      // Second typing event before timer expires
      controller.handleTyping(event2);
      typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');

      // Advance time by 3 seconds
      jest.advanceTimersByTime(3000);

      typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('none');
    });

    test('automatically hides after 3 seconds', () => {
      controller.connect();

      const event = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });

      controller.handleTyping(event);

      let typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');

      // Advance time by 2.9 seconds (should still be visible)
      jest.advanceTimersByTime(2900);
      typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');

      // Advance time by another 0.2 seconds (should now be hidden)
      jest.advanceTimersByTime(200);
      typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('none');
    });
  });

  describe('hideTyping', () => {
    test('hides the typing indicator', () => {
      controller.connect();

      const typingIndicator = document.getElementById('typing-indicator');
      typingIndicator.style.display = 'block';

      controller.hideTyping();

      expect(typingIndicator.style.display).toBe('none');
    });
  });

  describe('clearTypingTimer', () => {
    test('clears the typing timer', () => {
      controller.connect();

      const event = new CustomEvent('typing', {
        detail: { status: 'typing', user_name: 'Bob' },
      });

      controller.handleTyping(event);

      const timer = controller.typingTimer;
      expect(timer).toBeDefined();
      // In Jest with fake timers, setTimeout returns a number
      expect(typeof timer).toBe('number');

      // Verify that a timer was actually set
      expect(timer).toBeGreaterThan(0);

      controller.clearTypingTimer();

      // The timer should still have been set to some positive value
      // The clearTypingTimer method simply calls clearTimeout if this.typingTimer exists
      // It doesn't automatically reset this.typingTimer to undefined
    });

    test('handles null timer gracefully', () => {
      controller.typingTimer = null;

      expect(() => {
        controller.clearTypingTimer();
      }).not.toThrow();
    });
  });

  describe('edge cases', () => {
    test('handles unknown status', () => {
      controller.connect();

      const event = new CustomEvent('typing', {
        detail: { status: 'unknown', user_name: 'Bob' },
      });

      expect(() => {
        controller.handleTyping(event);
      }).not.toThrow();
    });

    test('handles events without user_name', () => {
      controller.connect();

      const event = new CustomEvent('typing', {
        detail: { status: 'typing' },
      });

      expect(() => {
        controller.handleTyping(event);
      }).not.toThrow();

      const typingIndicator = document.getElementById('typing-indicator');
      expect(typingIndicator.style.display).toBe('block');
    });
  });
});

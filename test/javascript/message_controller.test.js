const { Controller } = require('@hotwired/stimulus');

// Create element outside of mock
const mockElement = document.createElement('div');

// Setup global.App if not already set
if (!global.App) {
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
}

// Mock Controller to extend properly
jest.mock('@hotwired/stimulus', () => {
  return {
    Controller: class MockController {
      constructor() {
        this._element = mockElement;
        this.targets = [];
      }

      get element() {
        return this._element;
      }

      set element(value) {
        this._element = value;
      }

      static targets = [];
      static values = {};
      static classes = [];

      disconnect() {}
    },
  };
});

const MessageController = require('~/controllers/message_controller').default;

describe('MessageController', () => {
  let controller;
  let element;
  let inputTarget;
  let mockSubscription;

  beforeEach(() => {
    // Create test element
    element = document.createElement('div');
    element.setAttribute('data-controller', 'message');
    element.setAttribute('data-message-room-id-value', '123');

    // Create input target
    inputTarget = document.createElement('input');
    inputTarget.setAttribute('data-message-target', 'input');
    inputTarget.type = 'text';
    element.appendChild(inputTarget);

    // Mock ActionCable subscription
    mockSubscription = {
      perform: jest.fn(),
      unsubscribe: jest.fn(),
    };
    global.App.cable.subscriptions.create.mockReturnValue(mockSubscription);

    // Create controller instance - mock element assignment
    Object.defineProperty(MessageController.prototype, 'element', {
      ...Object.getOwnPropertyDescriptor(
        Object.getPrototypeOf(MessageController),
        'element'
      ),
      get: function() { return element; },
      configurable: true
    });
    Object.defineProperty(MessageController.prototype, 'roomIdValue', {
      ...Object.getOwnPropertyDescriptor(
        Object.getPrototypeOf(MessageController),
        'roomIdValue'
      ),
      get: function() { return '123'; },
      configurable: true
    });

    controller = new MessageController();
    controller.targets = [{ input: inputTarget }];
    controller.hasInputTarget = true;
    controller.inputTarget = inputTarget;
  });

  afterEach(() => {
    jest.clearAllMocks();
    document.body.innerHTML = '';
  });

  describe('connect', () => {
    test('JC-001: 初期化時のActionCable接続', () => {
      controller.connect();

      expect(global.App.cable.subscriptions.create).toHaveBeenCalledWith(
        { channel: 'Chat::RoomChannel', room_id: '123' },
        expect.any(Object)
      );

      expect(controller.subscription).toEqual(mockSubscription);

      // Check blur event listener is attached
      expect(inputTarget.onblur).toBeDefined();
    });

    test('JC-006: 接続解除時のクリーンアップ', () => {
      controller.connect();
      controller.disconnect();

      expect(mockSubscription.unsubscribe).toHaveBeenCalled();
    });
  });

  describe('reset', () => {
    test('JC-002: メッセージ送信後の入力リセット', () => {
      controller.connect();
      inputTarget.value = 'Test message';

      controller.reset();

      expect(inputTarget.value).toBe('');
    });
  });

  describe('typing', () => {
    test('JC-003: タイピングイベントの送信', () => {
      controller.connect();
      controller.typing();

      expect(mockSubscription.perform).toHaveBeenCalledWith('typing', { status: 'typing' });
    });

    test('JC-004: タイピング停止イベントの送信', () => {
      controller.connect();

      // Simulate blur event
      const blurEvent = new Event('blur');
      inputTarget.dispatchEvent(blurEvent);

      expect(mockSubscription.perform).toHaveBeenCalledWith('typing', { status: 'stop' });
    });
  });

  describe('handleReceived', () => {
    test('JC-005: 受信データのハンドリング', () => {
      controller.connect();

      // Mock dispatchEvent
      const dispatchSpy = jest.spyOn(document, 'dispatchEvent');

      const data = {
        type: 'typing',
        user_name: 'Bob',
        status: 'typing',
      };

      controller.handleReceived(data);

      expect(dispatchSpy).toHaveBeenCalled();
      const event = dispatchSpy.mock.calls[0][0];
      expect(event.type).toBe('typing');
      expect(event.detail).toEqual(data);
    });

    test('handles non-typing events', () => {
      controller.connect();

      // Should not throw error for other event types
      expect(() => {
        controller.handleReceived({ type: 'message', content: 'Hello' });
      }).not.toThrow();
    });
  });

  describe('edge cases', () => {
    test('handles missing subscription gracefully', () => {
      controller.subscription = null;

      expect(() => {
        controller.typing();
      }).not.toThrow();
    });

    test('handles disconnect without subscription', () => {
      controller.subscription = null;

      expect(() => {
        controller.disconnect();
      }).not.toThrow();
    });
  });
});

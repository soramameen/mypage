import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]
  static values = { roomId: String }

  connect() {
    // Initialize ActionCable subscription with room_id
    this.subscription = App.cable.subscriptions.create(
      { channel: "Chat::RoomChannel", room_id: this.roomIdValue },
      {
        received: (data) => {
          this.handleReceived(data)
        }
      }
    )

    // Dispatch typing stop event when input is blurred
    this.inputTarget.addEventListener("blur", () => {
      if (this.subscription) {
        this.subscription.perform("typing", { status: "stop" })
      }
    })

    // Initialize scroll position tracking
    this.isUserAtBottom = true
    this.messagesContainer = document.querySelector("#messages")
    if (this.messagesContainer) {
      this.messagesContainer.addEventListener("scroll", () => this.handleScroll())
    }

    // Scroll to bottom on initial load
    this.scrollToBottom()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  reset(event) {
    this.inputTarget.value = ""

    // Scroll to bottom after message is sent
    this.scrollToBottom()
  }

  typing() {
    // Broadcast typing event via ActionCable
    if (this.subscription) {
      this.subscription.perform("typing", { status: "typing" })
    }
  }

  loading(event) {
    // Show loading state
    const loadingIndicator = document.getElementById("loading-indicator")
    if (loadingIndicator) {
      loadingIndicator.style.display = "inline"
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
    this.element.classList.add("loading")
  }

  handleScroll() {
    // Check if user is at the bottom
    if (this.messagesContainer) {
      const threshold = 100 // pixels from bottom to consider "at bottom"
      this.isUserAtBottom = this.messagesContainer.scrollHeight - this.messagesContainer.scrollTop <= this.messagesContainer.clientHeight + threshold
    }
  }

  scrollToBottom() {
    if (this.messagesContainer) {
      // Only auto-scroll if user was at bottom or if there are no messages yet
      if (this.isUserAtBottom || this.messagesContainer.children.length === 0) {
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight
      }
    }
  }

  handleReceived(data) {
    // Handle received data from ActionCable
    if (data.type === "typing") {
      // Dispatch event for typing controller to handle
      const event = new CustomEvent("typing", { detail: data })
      document.dispatchEvent(event)
    } else if (data.type === "message") {
      // New message received
      this.scrollToBottom()
    }
  }
}

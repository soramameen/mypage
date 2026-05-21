import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { roomId: String }

  connect() {
    // Check if typing indicator already exists
    this.typingIndicator = document.getElementById("typing-indicator")

    // If not, create it
    if (!this.typingIndicator) {
      this.typingIndicator = document.createElement("div")
      this.typingIndicator.id = "typing-indicator"
      this.typingIndicator.style.display = "none"

      // Append to messages container
      const messagesContainer = this.element
      if (messagesContainer) {
        messagesContainer.appendChild(this.typingIndicator)
      }
    }

    // Listen for typing events from ActionCable (dispatched by message controller)
    this.boundHandleTyping = this.handleTyping.bind(this)
    document.addEventListener("typing", this.boundHandleTyping)
  }

  disconnect() {
    document.removeEventListener("typing", this.boundHandleTyping)
    if (this.typingTimer) {
      clearTimeout(this.typingTimer)
    }
  }

  handleTyping(event) {
    const data = event.detail

    // Check if this typing event is for this room
    if (data.room_id && data.room_id != this.roomIdValue) {
      return
    }

    if (data.status === "typing") {
      this.typingIndicator.textContent = `${data.user_name || "ユーザー"} が入力中...`
      this.typingIndicator.style.display = "block"

      // Clear typing indicator after 3 seconds
      this.clearTypingTimer()
      this.typingTimer = setTimeout(() => {
        this.hideTyping()
      }, 3000)
    } else if (data.status === "stop") {
      this.hideTyping()
    }
  }

  hideTyping() {
    if (this.typingIndicator) {
      this.typingIndicator.style.display = "none"
    }
  }

  clearTypingTimer() {
    if (this.typingTimer) {
      clearTimeout(this.typingTimer)
      this.typingTimer = null
    }
  }
}

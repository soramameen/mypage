import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    // Hide reaction buttons initially
    this.hideReactionButtons()
  }

  toggle(event) {
    // Toggle logic is handled by the server
    // The button will be replaced with the updated state
    const button = event.currentTarget
    button.classList.add("loading")
  }

  showReactionButtons() {
    const container = this.element.closest(".message")
    if (container) {
      const reactions = container.querySelector(".reactions")
      if (reactions) {
        reactions.style.opacity = "1"
      }
    }
  }

  hideReactionButtons() {
    const container = this.element.closest(".message")
    if (container) {
      const reactions = container.querySelector(".reactions")
      if (reactions) {
        reactions.style.opacity = "0.5"
      }
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
  }

  // Automatically dismisses toast animation when it ends
  dismiss(event) {
    // Only run if the target is this.element
    if (event.target !== this.element) return

    // Don't run if animation name isn't toast-out
    if (event.animationName !== 'toast-out') return
    
    // Call bootstrap alert dismiss
    bootstrap.Alert.getOrCreateInstance(this.element).close()
  }
}

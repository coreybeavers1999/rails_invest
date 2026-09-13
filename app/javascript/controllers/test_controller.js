import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="test"
export default class extends Controller {
  connect() {
  }

  duplicate(event) {
    console.log('Called event', event.target, event.animationName)
  }
}

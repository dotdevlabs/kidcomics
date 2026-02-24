import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  submit(event) {
    // Prevent default form submission
    if (event && event.preventDefault) {
      event.preventDefault()
    }

    // Submit the form via Turbo
    this.formTarget.requestSubmit()
  }

  debounceSubmit(event) {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Set new timeout for debounced submission
    this.timeout = setTimeout(() => {
      this.submit()
    }, 300) // 300ms debounce delay
  }
}

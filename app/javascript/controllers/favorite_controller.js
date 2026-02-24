import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // This controller is primarily for future AJAX functionality
    // Currently the favorite toggle works via form submission
  }

  toggle(event) {
    // Future: implement AJAX toggle without page reload
    // For now, the default form submission behavior is used
  }
}

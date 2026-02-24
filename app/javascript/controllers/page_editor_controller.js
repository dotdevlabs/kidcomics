import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "narrationText",
    "dialogueText",
    "caption",
    "deleteButton",
    "regenerateButton"
  ]

  static values = {
    updateUrl: String
  }

  async autoSave(event) {
    const textarea = event.target

    // Get form data
    const formData = new FormData()
    if (this.hasNarrationTextTarget) {
      formData.append("page[narration_text]", this.narrationTextTarget.value)
    }
    if (this.hasDialogueTextTarget) {
      formData.append("page[dialogue_text]", this.dialogueTextTarget.value)
    }
    if (this.hasCaptionTarget) {
      formData.append("page[caption]", this.captionTarget.value)
    }

    try {
      const response = await fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        // Visual feedback - briefly show saved state
        this.showSaveFeedback(textarea)
      } else {
        console.error("Auto-save failed")
      }
    } catch (error) {
      console.error("Auto-save error:", error)
    }
  }

  showSaveFeedback(element) {
    const originalBorderColor = element.style.borderColor
    element.style.borderColor = "#10b981" // green-500
    element.style.transition = "border-color 0.3s"

    setTimeout(() => {
      element.style.borderColor = originalBorderColor
    }, 1000)
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ""
  }
}

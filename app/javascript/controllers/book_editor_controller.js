import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "title",
    "dedication",
    "editMode",
    "autoSaveIndicator",
    "saveStatus"
  ]

  static values = {
    autoSaveUrl: String
  }

  connect() {
    this.isDirty = false
    this.autoSaveTimeout = null
    this.autoSaveInterval = 30000 // 30 seconds

    // Warn before leaving with unsaved changes
    window.addEventListener("beforeunload", this.handleBeforeUnload.bind(this))
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.handleBeforeUnload.bind(this))
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }
  }

  markDirty() {
    this.isDirty = true
    this.updateSaveStatus("unsaved")

    // Schedule auto-save
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout)
    }

    this.autoSaveTimeout = setTimeout(() => {
      this.autoSave()
    }, this.autoSaveInterval)
  }

  async autoSave() {
    if (!this.isDirty) return

    this.updateSaveStatus("saving")

    const formData = new FormData()
    formData.append("book[title]", this.titleTarget.value)
    formData.append("book[dedication]", this.dedicationTarget.value)

    const checkedEditMode = this.editModeTargets.find(radio => radio.checked)
    if (checkedEditMode) {
      formData.append("book[edit_mode]", checkedEditMode.value)
    }

    try {
      const response = await fetch(this.autoSaveUrlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.isDirty = false
        this.updateSaveStatus("saved")
      } else {
        this.updateSaveStatus("error")
      }
    } catch (error) {
      console.error("Auto-save failed:", error)
      this.updateSaveStatus("error")
    }
  }

  updateSaveStatus(status) {
    const statusMap = {
      saved: "Saved",
      saving: "Saving...",
      unsaved: "Unsaved changes",
      error: "Save failed"
    }

    if (this.hasSaveStatusTarget) {
      this.saveStatusTarget.textContent = statusMap[status] || "Unknown"
    }

    if (this.hasAutoSaveIndicatorTarget) {
      this.autoSaveIndicatorTarget.classList.remove(
        "text-gray-500",
        "text-blue-500",
        "text-green-500",
        "text-red-500"
      )

      const colorMap = {
        saved: "text-green-500",
        saving: "text-blue-500",
        unsaved: "text-gray-500",
        error: "text-red-500"
      }

      this.autoSaveIndicatorTarget.classList.add(colorMap[status] || "text-gray-500")
    }
  }

  handleBeforeUnload(event) {
    if (this.isDirty) {
      event.preventDefault()
      event.returnValue = ""
      return ""
    }
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ""
  }
}

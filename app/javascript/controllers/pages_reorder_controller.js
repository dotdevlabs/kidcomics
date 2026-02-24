import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "handle"]
  static values = {
    url: String
  }

  connect() {
    this.draggedItem = null
    this.draggedOverItem = null
  }

  startDrag(event) {
    const item = event.target.closest('[data-pages-reorder-target="item"]')
    if (!item) return

    this.draggedItem = item
    item.style.opacity = "0.5"

    // Set data for drag and drop
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/html", item.innerHTML)
  }

  dragOver(event) {
    event.preventDefault()
    const item = event.target.closest('[data-pages-reorder-target="item"]')

    if (item && item !== this.draggedItem) {
      this.draggedOverItem = item

      // Visual feedback
      const rect = item.getBoundingClientRect()
      const midpoint = rect.top + rect.height / 2

      if (event.clientY < midpoint) {
        item.style.borderTop = "2px solid #3b82f6"
        item.style.borderBottom = ""
      } else {
        item.style.borderTop = ""
        item.style.borderBottom = "2px solid #3b82f6"
      }
    }

    return false
  }

  dragLeave(event) {
    const item = event.target.closest('[data-pages-reorder-target="item"]')
    if (item) {
      item.style.borderTop = ""
      item.style.borderBottom = ""
    }
  }

  async drop(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.draggedItem || !this.draggedOverItem) return

    const items = Array.from(this.itemTargets)
    const draggedIndex = items.indexOf(this.draggedItem)
    const targetIndex = items.indexOf(this.draggedOverItem)

    if (draggedIndex === targetIndex) {
      this.cleanupDrag()
      return
    }

    // Determine new position based on drop location
    const rect = this.draggedOverItem.getBoundingClientRect()
    const midpoint = rect.top + rect.height / 2
    let newPosition = targetIndex

    if (event.clientY > midpoint && draggedIndex < targetIndex) {
      // Dropped below midpoint and dragging down
      newPosition = targetIndex
    } else if (event.clientY < midpoint && draggedIndex > targetIndex) {
      // Dropped above midpoint and dragging up
      newPosition = targetIndex
    }

    // Update the server
    const pageId = this.draggedItem.dataset.pageId
    await this.updatePosition(pageId, newPosition)

    // Reorder DOM
    if (draggedIndex < targetIndex) {
      this.draggedOverItem.parentNode.insertBefore(
        this.draggedItem,
        this.draggedOverItem.nextSibling
      )
    } else {
      this.draggedOverItem.parentNode.insertBefore(
        this.draggedItem,
        this.draggedOverItem
      )
    }

    this.cleanupDrag()
  }

  dragEnd() {
    this.cleanupDrag()
  }

  cleanupDrag() {
    if (this.draggedItem) {
      this.draggedItem.style.opacity = ""
      this.draggedItem = null
    }

    if (this.draggedOverItem) {
      this.draggedOverItem.style.borderTop = ""
      this.draggedOverItem.style.borderBottom = ""
      this.draggedOverItem = null
    }

    // Clean up all items
    this.itemTargets.forEach(item => {
      item.style.borderTop = ""
      item.style.borderBottom = ""
    })
  }

  async updatePosition(pageId, position) {
    try {
      const response = await fetch(
        `${this.urlValue}/pages/${pageId}/reorder`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getCSRFToken(),
            "Accept": "application/json"
          },
          body: JSON.stringify({ position })
        }
      )

      if (!response.ok) {
        console.error("Failed to update position")
      }
    } catch (error) {
      console.error("Error updating position:", error)
    }
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ""
  }

  // Touch support for mobile
  handleTargetMount(event) {
    const handle = event.target
    handle.draggable = true

    handle.addEventListener("dragstart", this.startDrag.bind(this))
    handle.addEventListener("dragend", this.dragEnd.bind(this))

    const item = handle.closest('[data-pages-reorder-target="item"]')
    if (item) {
      item.addEventListener("dragover", this.dragOver.bind(this))
      item.addEventListener("dragleave", this.dragLeave.bind(this))
      item.addEventListener("drop", this.drop.bind(this))
    }
  }

  handleTargetConnect() {
    this.handleTargets.forEach(handle => {
      const event = { target: handle }
      this.handleTargetMount(event)
    })
  }
}

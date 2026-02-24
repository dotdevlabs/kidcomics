import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "handle"]
  static values = { url: String }

  connect() {
    this.initializeSortable()
  }

  initializeSortable() {
    this.itemTargets.forEach((item) => {
      this.makeItemDraggable(item)
    })
  }

  makeItemDraggable(item) {
    const handle = item.querySelector('[data-drawings-reorder-target="handle"]')

    if (!handle) return

    handle.addEventListener('mousedown', (e) => {
      this.startDrag(item, e)
    })

    handle.addEventListener('touchstart', (e) => {
      this.startDrag(item, e)
    })
  }

  startDrag(item, event) {
    event.preventDefault()

    const draggedItem = item
    const items = this.itemTargets
    let placeholder = null

    draggedItem.classList.add('opacity-50', 'cursor-grabbing')

    const onMove = (e) => {
      const afterElement = this.getDragAfterElement(e.clientY || e.touches[0].clientY)

      if (placeholder) {
        placeholder.remove()
      }

      placeholder = this.createPlaceholder()

      if (afterElement == null) {
        this.element.appendChild(placeholder)
      } else {
        this.element.insertBefore(placeholder, afterElement)
      }
    }

    const onEnd = () => {
      draggedItem.classList.remove('opacity-50', 'cursor-grabbing')

      if (placeholder) {
        const newPosition = Array.from(this.element.children).indexOf(placeholder)
        this.element.insertBefore(draggedItem, placeholder)
        placeholder.remove()

        this.updatePosition(draggedItem, newPosition)
      }

      document.removeEventListener('mousemove', onMove)
      document.removeEventListener('mouseup', onEnd)
      document.removeEventListener('touchmove', onMove)
      document.removeEventListener('touchend', onEnd)
    }

    document.addEventListener('mousemove', onMove)
    document.addEventListener('mouseup', onEnd)
    document.addEventListener('touchmove', onMove)
    document.addEventListener('touchend', onEnd)
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.itemTargets].filter(item =>
      !item.classList.contains('opacity-50')
    )

    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2

      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  createPlaceholder() {
    const placeholder = document.createElement('div')
    placeholder.className = 'border-2 border-dashed border-purple-400 rounded-lg h-24 bg-purple-50'
    return placeholder
  }

  updatePosition(item, newPosition) {
    const drawingId = item.dataset.drawingId
    const url = `/child_profiles/${this.getChildProfileId()}/books/${this.getBookId()}/drawings/${drawingId}/reorder`

    fetch(url, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCSRFToken()
      },
      body: JSON.stringify({ position: newPosition })
    })
    .then(response => {
      if (response.ok) {
        this.updatePositionBadges()
      } else {
        console.error('Failed to update position')
      }
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }

  updatePositionBadges() {
    this.itemTargets.forEach((item, index) => {
      const badge = item.querySelector('.bg-purple-100')
      if (badge) {
        badge.textContent = index + 1
      }
      item.dataset.position = index
    })
  }

  getChildProfileId() {
    const match = window.location.pathname.match(/\/child_profiles\/(\d+)/)
    return match ? match[1] : null
  }

  getBookId() {
    const match = window.location.pathname.match(/\/books\/(\d+)/)
    return match ? match[1] : null
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ''
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "page",
    "currentPage",
    "totalPages",
    "currentPageDisplay",
    "totalPagesDisplay",
    "prevButton",
    "nextButton"
  ]

  connect() {
    this.currentPageIndex = 0
    this.updateDisplay()

    // Keyboard navigation
    document.addEventListener("keydown", this.handleKeyboard.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeyboard.bind(this))
  }

  nextPage() {
    if (this.currentPageIndex < this.pageTargets.length - 1) {
      this.goToPage(this.currentPageIndex + 1)
    }
  }

  previousPage() {
    if (this.currentPageIndex > 0) {
      this.goToPage(this.currentPageIndex - 1)
    }
  }

  goToPage(index) {
    // Hide current page
    this.pageTargets[this.currentPageIndex]?.classList.add("hidden")

    // Show new page
    this.currentPageIndex = index
    this.pageTargets[this.currentPageIndex]?.classList.remove("hidden")

    // Update display
    this.updateDisplay()

    // Scroll to top
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  updateDisplay() {
    const pageNumber = this.currentPageIndex + 1
    const totalPages = this.pageTargets.length

    // Update page counters
    if (this.hasCurrentPageTarget) {
      this.currentPageTarget.textContent = pageNumber
    }
    if (this.hasTotalPagesTarget) {
      this.totalPagesTarget.textContent = totalPages
    }
    if (this.hasCurrentPageDisplayTarget) {
      this.currentPageDisplayTarget.textContent = pageNumber
    }
    if (this.hasTotalPagesDisplayTarget) {
      this.totalPagesDisplayTarget.textContent = totalPages
    }

    // Update button states
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = this.currentPageIndex === 0
    }
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = this.currentPageIndex === totalPages - 1
    }
  }

  handleKeyboard(event) {
    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.previousPage()
        break
      case "ArrowRight":
        event.preventDefault()
        this.nextPage()
        break
      case "Home":
        event.preventDefault()
        this.goToPage(0)
        break
      case "End":
        event.preventDefault()
        this.goToPage(this.pageTargets.length - 1)
        break
    }
  }
}

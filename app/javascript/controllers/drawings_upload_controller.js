import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewContainer", "previewList", "submitButton"]

  preview(event) {
    const files = event.target.files

    if (files.length === 0) {
      this.hidePreview()
      return
    }

    this.clearPreviews()
    this.showPreview()

    Array.from(files).forEach((file, index) => {
      if (file.type.startsWith('image/')) {
        this.createPreviewItem(file, index)
      }
    })
  }

  createPreviewItem(file, index) {
    const reader = new FileReader()

    reader.onload = (e) => {
      const previewItem = document.createElement('div')
      previewItem.className = 'relative border border-gray-200 rounded-lg overflow-hidden'

      previewItem.innerHTML = `
        <div class="aspect-square bg-gray-100">
          <img src="${e.target.result}" class="w-full h-full object-cover" alt="Preview ${index + 1}">
        </div>
        <div class="p-2 bg-white">
          <p class="text-xs text-gray-600 truncate">${file.name}</p>
          <p class="text-xs text-gray-500">${this.formatFileSize(file.size)}</p>
        </div>
      `

      this.previewListTarget.appendChild(previewItem)
    }

    reader.readAsDataURL(file)
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'

    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  showPreview() {
    this.previewContainerTarget.classList.remove('hidden')
  }

  hidePreview() {
    this.previewContainerTarget.classList.add('hidden')
  }

  clearPreviews() {
    this.previewListTarget.innerHTML = ''
  }
}

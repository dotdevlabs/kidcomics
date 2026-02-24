import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "form"]

  previewFile(event) {
    const file = event.target.files[0]

    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader()

      reader.onload = (e) => {
        // Create or update preview image
        const existingImg = this.previewTarget.querySelector("img")

        if (existingImg) {
          existingImg.src = e.target.result
        } else {
          // Replace placeholder with image
          this.previewTarget.innerHTML = `
            <img src="${e.target.result}"
                 alt="Cover preview"
                 class="w-full h-full object-cover" />
          `
        }
      }

      reader.readAsDataURL(file)
    }
  }
}

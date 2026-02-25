import { Controller } from "@hotwired/stimulus"

// Manages the landing page animated background
// - Cycles through children's drawings that transform into rendered versions
// - Animates page turn effect between transitions
// - Loops continuously to showcase the product's transformation capability
export default class extends Controller {
  static targets = ["scene", "page"]
  static values = {
    currentScene: { type: Number, default: 0 },
    sceneCount: { type: Number, default: 3 }
  }

  connect() {
    this.animating = false
    this.startAnimationCycle()
  }

  disconnect() {
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout)
    }
  }

  startAnimationCycle() {
    // Wait for initial display, then start transforming
    this.animationTimeout = setTimeout(() => {
      this.transformScene()
    }, 3000)
  }

  transformScene() {
    if (this.animating) return
    this.animating = true

    const currentScene = this.sceneTargets[this.currentSceneValue]

    // Add transform class to trigger CSS animation
    currentScene.classList.add("transforming")

    // After transform completes, trigger page turn
    setTimeout(() => {
      this.turnPage()
    }, 2000)
  }

  turnPage() {
    const currentScene = this.sceneTargets[this.currentSceneValue]

    // Trigger page turn animation
    this.pageTarget.classList.add("turning")

    // After page turn, switch to next scene
    setTimeout(() => {
      this.switchScene()
    }, 1500)
  }

  switchScene() {
    const currentScene = this.sceneTargets[this.currentSceneValue]

    // Hide current scene
    currentScene.classList.remove("active", "transforming")
    currentScene.classList.add("hidden")

    // Move to next scene
    this.currentSceneValue = (this.currentSceneValue + 1) % this.sceneCountValue

    const nextScene = this.sceneTargets[this.currentSceneValue]

    // Reset page turn
    this.pageTarget.classList.remove("turning")

    // Show next scene
    nextScene.classList.remove("hidden")
    nextScene.classList.add("active")

    this.animating = false

    // Start next cycle
    this.animationTimeout = setTimeout(() => {
      this.transformScene()
    }, 3000)
  }
}

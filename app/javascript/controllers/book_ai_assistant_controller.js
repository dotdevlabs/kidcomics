import { Controller } from "@hotwired/stimulus"

// Simulated AI assistant for book metadata refinement
// This demonstrates the conversational interface pattern
// In production, this would integrate with a real AI service

export default class extends Controller {
  static targets = [
    "messages",
    "messageInput",
    "sendButton",
    "imageInput",
    "titleDisplay",
    "dedicationDisplay",
    "editModeDisplay"
  ]

  static values = {
    bookId: Number,
    updateUrl: String
  }

  connect() {
    console.log("Book AI Assistant connected")
    this.conversationHistory = []
  }

  sendMessage(event) {
    event.preventDefault()

    const message = this.messageInputTarget.value.trim()
    if (!message) return

    // Add user message to chat
    this.addUserMessage(message)

    // Clear input
    this.messageInputTarget.value = ""

    // Generate AI response
    setTimeout(() => {
      this.generateAIResponse(message)
    }, 500)
  }

  quickAction(event) {
    const message = event.currentTarget.dataset.message
    this.messageInputTarget.value = message
    this.sendMessage(new Event('submit'))
  }

  handleImageUpload(event) {
    const file = event.target.files[0]
    if (!file) return

    // Show user uploaded an image
    this.addUserMessage(`[Uploaded image: ${file.name}]`)

    // Simulate AI analyzing the image
    setTimeout(() => {
      this.analyzeImage(file)
    }, 1000)
  }

  analyzeImage(file) {
    // Simulated AI image analysis
    const suggestions = [
      "I can see a dragon in your drawing! How about calling this book 'The Dragon's Adventure'?",
      "This looks like a magical forest scene. Would 'Journey Through the Magic Woods' work as a title?",
      "I see a superhero character! Maybe 'The Adventures of Super Kid' for the title?",
      "That's a beautiful castle! How about 'The Castle of Dreams' as the title?"
    ]

    const suggestion = suggestions[Math.floor(Math.random() * suggestions.length)]

    this.addAIMessage(
      `I've analyzed your drawing! ${suggestion}\n\nWould you like me to update the title? Just say "yes" or suggest a different one!`
    )
  }

  generateAIResponse(userMessage) {
    const lowerMessage = userMessage.toLowerCase()

    // Pattern matching for common requests
    if (lowerMessage.includes('title')) {
      this.handleTitleRequest()
    } else if (lowerMessage.includes('dedication')) {
      this.handleDedicationRequest()
    } else if (lowerMessage.includes('parent') || lowerMessage.includes('lock')) {
      this.handleEditModeRequest()
    } else if (lowerMessage.includes('yes') || lowerMessage.includes('update') || lowerMessage.includes('change')) {
      this.handleConfirmation()
    } else {
      this.addAIMessage(
        "I can help you with:\n" +
        "• Suggesting a title based on your story\n" +
        "• Writing a dedication\n" +
        "• Changing who can edit the book\n" +
        "• Analyzing uploaded drawings\n\n" +
        "What would you like to do?"
      )
    }
  }

  handleTitleRequest() {
    const suggestions = [
      "The Amazing Adventures",
      "A Story of Wonder",
      "Dreams Come True",
      "The Brave Little Hero"
    ]

    const title = suggestions[Math.floor(Math.random() * suggestions.length)]

    this.addAIMessage(
      `Based on your story, I suggest the title: "${title}"\n\n` +
      `Would you like me to update it? Say "yes" to confirm, or tell me a different title you prefer.`
    )

    this.pendingUpdate = { title: title }
  }

  handleDedicationRequest() {
    this.addAIMessage(
      `I can help write a dedication! Who would you like to dedicate this book to? ` +
      `For example, you could say "For my amazing child who loves to draw" or "To the best storyteller I know."`
    )
  }

  handleEditModeRequest() {
    this.addAIMessage(
      `I'll change the edit mode to "Parents Only" so only parents can make changes. ` +
      `Say "yes" to confirm.`
    )

    this.pendingUpdate = { edit_mode: 'parent_only' }
  }

  handleConfirmation() {
    if (!this.pendingUpdate) {
      this.addAIMessage("I'm not sure what you'd like to update. Can you be more specific?")
      return
    }

    // Update the book via AJAX
    this.updateBook(this.pendingUpdate)
  }

  updateBook(updates) {
    this.addAIMessage("Updating your book...")

    fetch(this.updateUrlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ book: updates })
    })
    .then(response => response.json())
    .then(data => {
      // Update the display
      if (updates.title) {
        this.titleDisplayTarget.textContent = updates.title
      }
      if (updates.dedication) {
        this.dedicationDisplayTarget.textContent = updates.dedication
      }
      if (updates.edit_mode) {
        this.editModeDisplayTarget.textContent = updates.edit_mode === 'parent_only' ? 'Parents Only' : 'Everyone (Shared)'
      }

      this.addAIMessage("✓ Updated! Your changes have been saved.")
      this.pendingUpdate = null
    })
    .catch(error => {
      console.error('Error updating book:', error)
      this.addAIMessage("Sorry, there was an error updating the book. Please try again.")
    })
  }

  addUserMessage(text) {
    const messageHtml = `
      <div class="flex gap-3 justify-end">
        <div class="bg-purple-100 rounded-lg p-3 max-w-md">
          <p class="text-sm text-gray-800 whitespace-pre-wrap">${this.escapeHtml(text)}</p>
        </div>
        <div class="flex-shrink-0">
          <div class="w-8 h-8 rounded-full bg-purple-600 flex items-center justify-center">
            <i data-lucide="user" class="w-4 h-4 text-white"></i>
          </div>
        </div>
      </div>
    `

    this.messagesTarget.insertAdjacentHTML('beforeend', messageHtml)
    this.scrollToBottom()
    this.reinitializeLucide()
  }

  addAIMessage(text) {
    const messageHtml = `
      <div class="flex gap-3">
        <div class="flex-shrink-0">
          <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
            <i data-lucide="bot" class="w-4 h-4 text-blue-600"></i>
          </div>
        </div>
        <div class="bg-blue-50 rounded-lg p-3 max-w-md">
          <p class="text-sm text-gray-800 whitespace-pre-wrap">${this.escapeHtml(text)}</p>
        </div>
      </div>
    `

    this.messagesTarget.insertAdjacentHTML('beforeend', messageHtml)
    this.scrollToBottom()
    this.reinitializeLucide()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  reinitializeLucide() {
    // Reinitialize Lucide icons for newly added elements
    if (window.lucide) {
      window.lucide.createIcons()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}

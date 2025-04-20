import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    // Show modal backdrop
    document.getElementById('modal-backdrop').classList.remove('hidden')
    
    // Prevent scrolling on the body
    document.body.classList.add('overflow-hidden')
    
    // Add event listener for escape key
    document.addEventListener('keydown', this.handleKeyDown)
  }
  
  disconnect() {
    // Remove event listener for escape key
    document.removeEventListener('keydown', this.handleKeyDown)
  }
  
  close() {
    // Hide modal backdrop
    document.getElementById('modal-backdrop').classList.add('hidden')
    
    // Allow scrolling on the body again
    document.body.classList.remove('overflow-hidden')
    
    // Clear the modal content
    document.getElementById('modal').innerHTML = ''
  }
  
  handleKeyDown = (event) => {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}

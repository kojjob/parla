import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-upload"
export default class extends Controller {
  static targets = ["input", "preview", "container", "template"]

  connect() {
    this.updatePreview()
  }

  // Prevent default drag behaviors
  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  // Handle dropped files
  handleDrop(e) {
    this.preventDefaults(e)
    const files = e.dataTransfer.files
    this.addFiles(files)
  }

  // Handle selected files from file input
  handleFiles(e) {
    const files = e.target.files
    this.addFiles(files)
  }

  // Add files to the gallery
  addFiles(files) {
    Array.from(files).forEach(file => {
      // Only process image files
      if (!file.type.match('image.*')) {
        return
      }

      this.addImagePreview(file)
    })
  }

  // Add a single image preview
  addImagePreview(file) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      // Clone the template
      const template = this.templateTarget.content.cloneNode(true)
      const previewImage = template.querySelector('img')
      const previewItem = template.querySelector('.gallery-item')
      
      // Set a unique ID for this preview
      const uniqueId = Date.now().toString(36) + Math.random().toString(36).substr(2, 5)
      previewItem.dataset.id = uniqueId
      
      // Set the image source
      previewImage.src = e.target.result
      
      // Add the preview to the container
      this.containerTarget.appendChild(template)
      
      // Create a new file input for this image
      this.createHiddenInput(file, uniqueId)
    }
    
    reader.readAsDataURL(file)
  }

  // Create a hidden input for the file
  createHiddenInput(file, uniqueId) {
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    
    const input = document.createElement('input')
    input.type = 'file'
    input.name = 'post[gallery_images][]'
    input.classList.add('hidden')
    input.dataset.id = uniqueId
    input.files = dataTransfer.files
    
    this.element.appendChild(input)
  }

  // Remove an image from the gallery
  removeImage(e) {
    const button = e.currentTarget
    const item = button.closest('.gallery-item')
    const itemId = item.dataset.id
    
    // Remove the preview
    item.remove()
    
    // Remove the corresponding hidden input
    const input = this.element.querySelector(`input[data-id="${itemId}"]`)
    if (input) {
      input.remove()
    }
  }

  // Open file browser when clicking on the upload area
  browseFiles() {
    this.inputTarget.click()
  }

  // Update preview for existing images
  updatePreview() {
    // This method can be used to initialize the preview with existing images
    // when editing a post that already has gallery images
  }
}

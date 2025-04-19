import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "previewImage", "previewContainer", "placeholder", "dropzone"]

  connect() {
    // Initialize the controller
  }

  // Prevent default drag behaviors
  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  // Handle dropped files
  handleDrop(e) {
    this.preventDefaults(e)
    const file = e.dataTransfer.files[0]
    if (file && file.type.match('image.*')) {
      this.handleImageFile(file)
    }
  }

  // Handle file selection from input
  handleFile(e) {
    const file = this.inputTarget.files[0]
    if (file && file.type.match('image.*')) {
      this.handleImageFile(file)
    }
  }

  // Process the image file
  handleImageFile(file) {
    // Show the preview container and hide the placeholder
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add('hidden')
    }
    this.previewContainerTarget.classList.remove('hidden')

    // Create a URL for the file and set it as the preview image source
    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
    }
    reader.readAsDataURL(file)
  }

  // Remove the selected image
  removeImage(e) {
    e.preventDefault()
    e.stopPropagation()

    // Clear the file input
    this.inputTarget.value = ''

    // Hide the preview and show the placeholder
    this.previewContainerTarget.classList.add('hidden')
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove('hidden')
    }

    // If we're editing an existing post with an image, we need to mark it for removal
    if (this.inputTarget.dataset.existingImage === 'true') {
      // Create a hidden input to signal the image should be removed
      const hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      hiddenInput.name = 'post[remove_cover_image]'
      hiddenInput.value = '1'
      this.element.appendChild(hiddenInput)
    }
  }

  // Open file browser when clicking on the upload area
  browseFiles() {
    this.inputTarget.click()
  }
}

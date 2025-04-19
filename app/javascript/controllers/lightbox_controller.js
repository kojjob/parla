import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lightbox"
export default class extends Controller {
  static targets = ["image"]
  
  connect() {
    // Create lightbox container if it doesn't exist
    if (!document.getElementById('lightbox-container')) {
      const lightbox = document.createElement('div')
      lightbox.id = 'lightbox-container'
      lightbox.className = 'fixed inset-0 bg-black bg-opacity-90 z-50 flex items-center justify-center hidden'
      lightbox.innerHTML = `
        <button id="lightbox-close" class="absolute top-4 right-4 text-white hover:text-gray-300">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <button id="lightbox-prev" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <img id="lightbox-image" class="max-h-[90vh] max-w-[90vw] object-contain" src="" alt="Enlarged image">
        <button id="lightbox-next" class="absolute right-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </button>
      `
      document.body.appendChild(lightbox)
      
      // Add event listeners
      document.getElementById('lightbox-close').addEventListener('click', () => this.close())
      document.getElementById('lightbox-prev').addEventListener('click', () => this.navigate(-1))
      document.getElementById('lightbox-next').addEventListener('click', () => this.navigate(1))
      
      // Close on escape key
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') this.close()
        if (e.key === 'ArrowLeft') this.navigate(-1)
        if (e.key === 'ArrowRight') this.navigate(1)
      })
      
      // Close when clicking outside the image
      document.getElementById('lightbox-container').addEventListener('click', (e) => {
        if (e.target.id === 'lightbox-container') this.close()
      })
    }
  }
  
  open(e) {
    e.preventDefault()
    
    const lightbox = document.getElementById('lightbox-container')
    const lightboxImage = document.getElementById('lightbox-image')
    
    // Get the clicked image
    const clickedImage = e.currentTarget.querySelector('img') || e.currentTarget
    
    // Set the current index
    this.currentIndex = this.imageTargets.indexOf(e.currentTarget)
    
    // Set the image source
    const fullSizeUrl = e.currentTarget.href || clickedImage.src
    lightboxImage.src = fullSizeUrl
    
    // Show the lightbox
    lightbox.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
  }
  
  close() {
    const lightbox = document.getElementById('lightbox-container')
    lightbox.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
  }
  
  navigate(direction) {
    // Calculate the new index
    let newIndex = this.currentIndex + direction
    
    // Wrap around if needed
    if (newIndex < 0) newIndex = this.imageTargets.length - 1
    if (newIndex >= this.imageTargets.length) newIndex = 0
    
    // Update current index
    this.currentIndex = newIndex
    
    // Get the new image
    const newImage = this.imageTargets[newIndex]
    const fullSizeUrl = newImage.href || newImage.querySelector('img').src
    
    // Update the lightbox image
    const lightboxImage = document.getElementById('lightbox-image')
    lightboxImage.src = fullSizeUrl
  }
}

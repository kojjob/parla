import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-show"
export default class extends Controller {
  connect() {
    // Initialize any functionality needed for the post show page
  }
  
  // Function to copy URL to clipboard
  copyToClipboard(event) {
    const button = event.currentTarget;
    const input = button.previousElementSibling;
    input.select();
    document.execCommand('copy');

    // Show copied feedback
    const originalSvg = button.innerHTML;
    button.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-500" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>
    `;

    setTimeout(() => {
      button.innerHTML = originalSvg;
    }, 2000);
  }
}

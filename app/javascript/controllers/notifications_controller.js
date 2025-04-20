import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    // Initialize the controller
    console.log("Notifications controller connected")

    // Add event listener for clicks outside the dropdown
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    // Remove event listener when controller disconnects
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  // Handle the "Mark all as read" button click
  markAllAsRead(event) {
    // Prevent event propagation to keep dropdown open
    event.stopPropagation()

    // Let Turbo handle the form submission
    // This will be a background request that updates the page
    // without a full page reload
  }

  // Handle viewing a single notification
  viewNotification(event) {
    // We don't stop propagation here because we want the link to work normally
    // This is just a hook for any additional logic we might want to add
    console.log("Viewing notification")
  }

  // Handle viewing all notifications
  viewAll(event) {
    // We don't stop propagation here because we want the link to work normally
    // This is just a hook for any additional logic we might want to add
    console.log("Viewing all notifications")
  }

  // Handle clicks outside the dropdown
  handleClickOutside(event) {
    // If we have a dropdown target and the click is outside the controller element
    if (this.hasDropdownTarget && !this.element.contains(event.target)) {
      // Hide the dropdown
      this.hideDropdown()
    }
  }

  // Toggle the dropdown visibility
  toggle(event) {
    event.stopPropagation()

    if (this.dropdownTarget.classList.contains('hidden')) {
      this.showDropdown()
    } else {
      this.hideDropdown()
    }
  }

  // Show the dropdown with animation
  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
    setTimeout(() => {
      this.dropdownTarget.classList.add('show')
    }, 10)
  }

  // Hide the dropdown with animation
  hideDropdown() {
    this.dropdownTarget.classList.remove('show')
    setTimeout(() => {
      this.dropdownTarget.classList.add('hidden')
    }, 200)
  }
}

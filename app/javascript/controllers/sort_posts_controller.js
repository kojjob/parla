import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("SortPosts controller connected")
    
    // Set the initial value from URL params if present
    const url = new URL(window.location)
    const sort = url.searchParams.get('sort')
    
    if (sort && this.element.querySelector(`option[value="${sort}"]`)) {
      this.element.value = sort
    }
  }

  sort(event) {
    const sortValue = event.target.value
    const url = new URL(window.location)
    
    if (sortValue) {
      url.searchParams.set('sort', sortValue)
    } else {
      url.searchParams.delete('sort')
    }
    
    // Reset to page 1 when sorting
    url.searchParams.delete('page')
    
    Turbo.visit(url.toString(), { action: "replace" })
  }
}
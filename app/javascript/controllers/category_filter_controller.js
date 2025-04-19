import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("CategoryFilter controller connected")
  }

  filter(event) {
    const categoryId = event.target.value
    const url = new URL(window.location)
    
    if (categoryId) {
      url.searchParams.set('category_id', categoryId)
    } else {
      url.searchParams.delete('category_id')
    }
    
    // Reset to page 1 when filtering
    url.searchParams.delete('page')
    
    Turbo.visit(url.toString(), { action: "replace" })
  }
}
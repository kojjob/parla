import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comments"
export default class extends Controller {
  static targets = ["contentType", "contentTypeField", "contentContainer", "textContent",
                    "emojiPicker", "replyForm", "commentsContainer"]

  connect() {
    // Initialize the controller
    this.initializeContentTypeBtns();
    this.initializeEmojiPicker();
    this.initializeReplyButtons();
    this.initializeFormValidation();
  }

  initializeContentTypeBtns() {
    const contentTypeBtns = this.element.querySelectorAll('.content-type-btn');

    contentTypeBtns.forEach(btn => {
      btn.addEventListener('click', (event) => {
        const type = event.currentTarget.dataset.type;

        // Update active button
        contentTypeBtns.forEach(b => b.classList.remove('active', 'bg-indigo-100', 'text-indigo-700'));
        event.currentTarget.classList.add('active', 'bg-indigo-100', 'text-indigo-700');

        // Update content type field
        if (this.hasContentTypeFieldTarget) {
          this.contentTypeFieldTarget.value = type === 'text' ? 'text' : (type === 'rich' ? 'rich' : type);
        }

        // Show/hide appropriate container
        this.contentContainerTargets.forEach(container => container.classList.add('hidden'));
        this.element.querySelector(`#${type}-content-container`).classList.remove('hidden');
      });
    });
  }

  // Initialize emoji picker (for backward compatibility)
  initializeEmojiPicker() {
    // Add click outside handler to close emoji picker
    document.addEventListener('click', (event) => {
      if (this.hasEmojiPickerTarget && !this.element.contains(event.target)) {
        this.emojiPickerTarget.classList.add('hidden');

        // Remove active class from emoji button
        const emojiBtn = this.element.querySelector('.emoji-btn');
        if (emojiBtn) {
          emojiBtn.classList.remove('active');
        }
      }
    });
  }

  // Toggle emoji picker visibility (called from data-action)
  toggleEmojiPicker(event) {
    event.preventDefault();
    event.stopPropagation();

    // Toggle emoji picker visibility
    if (this.hasEmojiPickerTarget) {
      this.emojiPickerTarget.classList.toggle('hidden');

      // Toggle active class on the emoji button
      const emojiBtn = event.currentTarget;
      emojiBtn.classList.toggle('active');
    }
  }

  // Insert emoji into text field (called from data-action)
  insertEmoji(event) {
    event.preventDefault();

    const emoji = event.currentTarget.dataset.emoji;
    const textContentField = this.hasTextContentTarget ?
      this.textContentTarget :
      this.element.querySelector('textarea[name="comment[content]"]');

    if (textContentField) {
      const cursorPos = textContentField.selectionStart;
      const textBefore = textContentField.value.substring(0, cursorPos);
      const textAfter = textContentField.value.substring(cursorPos);

      textContentField.value = textBefore + emoji + textAfter;
      textContentField.focus();
      textContentField.selectionStart = cursorPos + emoji.length;
      textContentField.selectionEnd = cursorPos + emoji.length;

      // Hide emoji picker after selection
      if (this.hasEmojiPickerTarget) {
        this.emojiPickerTarget.classList.add('hidden');

        // Remove active class from emoji button
        const emojiBtn = this.element.querySelector('.emoji-btn');
        if (emojiBtn) {
          emojiBtn.classList.remove('active');
        }
      }
    }
  }

  initializeReplyButtons() {
    const replyButtons = document.querySelectorAll('.reply-button');
    const cancelReplyButtons = document.querySelectorAll('.cancel-reply-btn');

    replyButtons.forEach(btn => {
      btn.addEventListener('click', (event) => {
        const commentId = event.currentTarget.dataset.commentId;
        const replyForm = document.getElementById(`reply-form-${commentId}`);

        // Hide all other reply forms
        document.querySelectorAll('[id^="reply-form-"]').forEach(form => {
          if (form.id !== `reply-form-${commentId}`) {
            form.classList.add('hidden');
          }
        });

        replyForm.classList.toggle('hidden');
      });
    });

    cancelReplyButtons.forEach(btn => {
      btn.addEventListener('click', (event) => {
        const commentId = event.currentTarget.dataset.commentId;
        const replyForm = document.getElementById(`reply-form-${commentId}`);
        replyForm.classList.add('hidden');
      });
    });
  }

  // For the comments section toggle
  toggleComments() {
    if (this.hasCommentsContainerTarget) {
      this.commentsContainerTarget.classList.toggle('hidden');

      const showText = this.element.querySelector('.show-text');
      const hideText = this.element.querySelector('.hide-text');

      if (showText && hideText) {
        showText.classList.toggle('hidden');
        hideText.classList.toggle('hidden');
      }
    }
  }

  // Validate comment form before submission
  initializeFormValidation() {
    const form = this.element.querySelector('form.comment-form');

    if (form) {
      form.addEventListener('submit', (event) => {
        // Get the active content type
        const contentType = this.contentTypeFieldTarget.value;
        let isValid = false;

        // Check if the appropriate content field has a value
        if (contentType === 'text') {
          const textContent = this.hasTextContentTarget ? this.textContentTarget.value.trim() : '';
          isValid = textContent.length > 0;
        } else if (contentType === 'rich') {
          const richContent = form.querySelector('trix-editor').editor.getDocument().toString().trim();
          isValid = richContent.length > 0;
        } else if (contentType === 'image') {
          const imageInput = form.querySelector('input[type="file"][name="comment[image]"]');
          isValid = imageInput && imageInput.files.length > 0;
        } else if (contentType === 'video') {
          const videoInput = form.querySelector('input[type="file"][name="comment[video]"]');
          isValid = videoInput && videoInput.files.length > 0;
        } else if (contentType === 'gif') {
          const gifInput = form.querySelector('input[type="file"][name="comment[gif]"]');
          isValid = gifInput && gifInput.files.length > 0;
        }

        // If not valid, prevent form submission and show error
        if (!isValid) {
          event.preventDefault();

          // Show error message
          let errorMessage = form.querySelector('.validation-error');
          if (!errorMessage) {
            errorMessage = document.createElement('div');
            errorMessage.className = 'validation-error bg-red-50 text-red-500 p-3 rounded-md mb-4';
            form.prepend(errorMessage);
          }

          errorMessage.textContent = 'Please enter some content for your comment.';

          // Scroll to error message
          errorMessage.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      });
    }
  }
}

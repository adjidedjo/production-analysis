// Migration Notice Modal Handler
$(document).ready(function() {
  // Check if user is logged in and modal should be shown
  if ($('#migrationNoticeModal').length > 0) {
    // Check if modal has been shown in this session
    var modalShown = sessionStorage.getItem('migrationNoticeShown');

    if (!modalShown) {
      // Show modal after 1 second delay
      setTimeout(function() {
        $('#migrationNoticeModal').modal('show');
        // Mark as shown in session storage
        sessionStorage.setItem('migrationNoticeShown', 'true');
      }, 1000);
    }
  }

  // Optional: Show modal again when dismiss button is clicked (for testing)
  // Remove this in production if you want it to show only once per session
  $('#migrationNoticeModal').on('hidden.bs.modal', function () {
    // Modal closed
  });
});

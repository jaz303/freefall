var ff = {
  
  init: function() {
    ff.notifications.init();
  },
  
  //
  // Background activity
  
  bg: {
    busyCount: 0,
    
    busy: function() {
      ff.bg.busyCount++;
  		if (ff.bg.busyCount > 0) {
        $('#activity-indicator').show();
  		}
    },
    
    idle: function() {
      ff.bg.busyCount--;
  		if (ff.bg.busyCount < 1) {
  			$('#activity-indicator').hide();
  		}
    }
  },
  
  //
  // Notifications
  
  notifications: {
    DEFAULT_TIMEOUT: 5000,
    
    init: function() {
      setTimeout(ff.notifications._flashRipple, 5000);
    },
    
    flash: function(type, message, timeout) {
  		if (arguments.length < 3) timeout = ff.DEFAULT_FLASH_TIMEOUT;
  		var jq = $("<div style='display:none' class='flash " + type + "'>" + message + "</div>").prependTo('#notifications').fadeIn();
  		if (timeout) window.setTimeout(function() { jq.fadeOut(function() { $(this).remove(); }) }, timeout);
  	},
  	
  	_flashRipple: function() {
      if ($('#notifications .flash').length > 0) {
        $('#notifications .flash:last').fadeOut(function() {
          $(this).remove();
          setTimeout(ff.notifications._flashRipple, 2000);
        });
      }
    },
    
  }
  
};
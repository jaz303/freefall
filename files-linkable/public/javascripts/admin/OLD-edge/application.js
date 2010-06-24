var admin = {
    dialog: {
        open: function(url, width, height) {
            window.open(url, "_blank", "status=0,toolbar=0,location=0,menubar=0,width=" + width + ",height=" + height);
            return false;
        }
    },

	busyCount: 0,

	busy: function() {
		admin.busyCount += 1;
		if(admin.busyCount > 0) {
			$('#activity-indicator').show();
		}
	},
	
	idle: function() {
		admin.busyCount -= 1;
		if(admin.busyCount < 1) {
			$('#activity-indicator').hide();
		}
	}
};

$(function() {
	
	Boxy.DEFAULTS.closeText = '[x]';
    
    $('body').ajaxStart(function() {
        admin.busy();
    }).ajaxStop(function() {
        admin.idle();
    });
    
    $('[rel=tipsy]').tipsy({gravity: 'north'});
	
	$('[rel=boxy]').boxy();
	
	$('#asset-dialog-actuator').click(AssetDialog.toggle);
	
	$('.asset-input').each(function() {
	
		var $input = $(this).find('input'),
			$icon = $(this).find('.asset-icon'),
			$caption = $(this).find('.caption');

		$(this).find('a[rel=change]').click(function() {
			AssetDialog.select(function(asset) {
				$input.val(asset.id);
				$icon.css('backgroundImage', asset.iconCSS);
				$caption.text(asset.name);
			});
			return false;
		}).end().find('a[rel=delete]').click(function() {
			$input.val('');
			$icon.css('backgroundImage', 'none');
			$caption.text('(no asset selected)');
		});
		
	});
	
	$('.multi-asset-input').each(function() {
		
		var $table 		= $(this).find('table'),
			$tfoot		= $table.find('tfoot').show().remove(),
			basename	= $(this).find('input[name=basename]').remove().val();
			
		function rows() { return $table.find('tbody tr'); };
		function count() { return rows().length; };
		
		function rejig() {
			if (count()) {
				$tfoot.remove();
			} else {
				$tfoot.appendTo($table);
			}
		};
		rejig();
		
		$table.click(function(evt) {
			var $t = $(evt.target), $row = $t.parents('tr:first');
			if ($t.is('[rel=delete]')) {
				$row.remove();
				rejig();
			} else if ($t.is('[rel=up]')) {
				$row.insertBefore($row.prev('tr'));
			} else if ($t.is('[rel=down]')) {
				$row.insertAfter($row.next('tr'));
			}
			return false;
		});
		
		$(this).find('[rel=add]').click(function() {
			AssetDialog.select(function(asset) {
				$table.append(
					$('<tr/>')
						.append($('<td/>').html($('<div class="asset-icon"/>').css('backgroundImage', asset.iconCSS)))
						.append($('<td/>').text(asset.name))
						.append($('<td/>')
							.append($('<input type="hidden"/>').attr({name: basename, value: asset.id}))
							.append("<a href='#' rel='up'>Up</a> | " +
									"<a href='#' rel='down'>Down</a> | " +
								 	"<a href='#' rel='delete'>Delete</a>")
						)
				);
				rejig();
			});
			return false;
		});
		
	});
		
});

$.fn.slugify = function(slug) {
	var locked = false;
	var $title = $(this);
	var $slug  = $(slug);
	
	if($slug.length && $slug.val().length > 0) {
		locked = true;
	}
	
	$slug.blur(function() {
		locked = true;
	});
	
	$title.blur(function() {
		if(!locked) {
			$slug.val($title.val().toLowerCase().replace(/[^a-z0-9]+/g, '-'));
		}
	});
};
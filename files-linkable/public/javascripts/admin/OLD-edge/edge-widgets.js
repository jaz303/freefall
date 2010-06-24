
// TODO: optionally work with IDs rather than indexes for compatibility with back-button
// Widget init process should be split into two stages so vars are guaranteed to be setup
// before defaults() is called because it would be best if the selectedIndex could be
// inferred from the CSS class.
Widget.extend('TabPane', {
	methods: {
		setup: function() {
	        var self = this, $act = self.$root.find('> ul.tab-bar > li');
	        $act.click(function() {
	            $act.removeClass('selected');
	            $(this).addClass('selected');
	            self.$root.find('.panel').hide().eq($act.index(this)).show();
	            return false;
	        }).eq(self.config.selectedIndex).click();
	    },

	    defaults: function() {
	        return { selectedIndex: 0 };
	    }
	}
});

Widget.extend('PageSectionEditor', {
	methods: {
		tinyMCE: function() { return tinyMCE.activeEditor; },
		getActiveContent: function() { return this.tinyMCE().getContent(); },
		setActiveContent: function(content) { this.tinyMCE().setContent(content); },
		isContentKeyValid: function(k) { return k.match(/^[a-zA-Z0-9_-]+$/); },
		contentExists: function(k) { return this.$tabs.find('input[name="' + this.config.basename + '[' + k + ']"]').length > 0 },
		storeContent: function() { this.$tabs.find('li.selected input').val(this.getActiveContent()); },
		selectFirst: function() { this.$tabs.find('li:first').click(); },
		
		selectContent: function(ele) {
			this.storeContent();
			this.setActiveContent($(ele).find('input').val());
			this.$tabs.find('li').removeClass('selected');
			$(ele).addClass('selected');
		},
		
		addContent: function() {
			var section = null, self = this;
			
			do {
		    	section = prompt("Please enter the name of the section to add:");
		    	if (section === null) return;
		  	} while (this.contentExists(section) || !this.isContentKeyValid(section));
		
			var $tab = $('<li />').append($('<a href="#" />').text(section))
								  .append($('<input type="hidden" value="" name="' + this.config.basename + '[' + section + ']" />'));
								
			$tab.click(this._selectFromClick);
			$tab.appendTo(this.$tabs);
		},
		
		removeContent: function() {
			if (this.$tabs.find('li').length == 1) {
				alert('The last page section cannot be deleted');
		  	} else if (confirm("Are you sure?")) {
				this.$tabs.find('li.selected').remove();
				this.selectFirst();
			}
		},
		
		setup: function() {
			
			this.$tabs = this.$root.find('.tab-bar');
			
			var self = this;
			
			this._selectFromClick = function() {
				self.selectContent(this);
				return false;
			}
			
			this.$root.find('[rel=add-new-section]').click(function() { self.addContent(); return false; });
			this.$root.find('[rel=remove-selected-section]').click(function() { self.removeContent(); return false; });
			this.$tabs.find('li').click(this._selectFromClick);
			
			this.$root.closest('form').submit(function() { self.storeContent(); });
			
			this.$tabs.find('li:first').addClass('selected');
			
		}
	}
});

Widget.extend('ModularRegionEditor', {
	methods: {
		setup: function() {
			console.log(this.config);
		}
	}
});

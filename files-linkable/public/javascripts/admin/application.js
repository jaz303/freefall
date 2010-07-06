$(function() {
    ff.init();
});

$.rebind(function(context) {
    
    /**
     * Any <form> with the class 'ajax' will submit via AJAX.
     *
     * Triggers 'form.success' or 'form.error' on the submitted form on completion.
     * Supports the following HTML5 data attributes:
     * data-ajax-update : jQuery selector to update with HTML, or 'true' to update self
     * date-ajax-data-type - jQuery AJAX dataType. Default: 'html'
     */
    $('form.ajax', context).each(function() {
        var $form   = $(this),
            update  = $form.attr('data-ajax-update'),
            type    = $form.attr('data-ajax-data-type') || 'html';
          
        $form.ajaxForm({
            dataType: type,
            success: function(data, textStatus, xhr) {
                if (update) {
                    if (update === 'true') update = $form;
                    $(update).html(data);
                }
                $form.trigger('form.success', data, textStatus, xhr);
            },
            error: function(xhr, textStatus, errorThrown) {
                $form.trigger('form.error', xhr, textStatus, errorThrown);
            }
        });
    });
  
    /*
     * Rich-text editors
     */
    if (typeof $.fn.tinymce == 'function') {
        $('textarea.tinymce', context).each(function() {
            var optionSets = ['common'];

            $.each(this.className.split(/\s+/), function() {
               if (this.match(/^tinymce-options-(.*?)$/)) optionSets.push(RegExp.$1);
            });

            if (optionSets.length == 1) {
               $.each(ff.config.admin.tinyMCE.defaultOptionSets, function() {
                   optionSets.push(this);
               });
            }

            var options = {};
            $.each(optionSets, function() {
               $.extend(options, ff.config.admin.tinyMCE.optionSets[this] || {});
            });

            $(this).tinymce(options);
        });
    }
    
    /*
     * Datetime inputs
     */
    if (typeof Calendar != 'undefined') {
        var calendarSeq = 0;
        $('.datetime-picker, .date-picker', context).each(function() {

            var input   = $('input[type=hidden]', this)[0],
                display = $('input[type=text]', this)[0],
                button  = $('a', this)[0];

            input.id    = 'dt-' + (calendarSeq++);
            display.id  = 'dt-' + (calendarSeq++);
            button.id   = 'dt-' + (calendarSeq++);

            var time    = $(this).is('.datetime-picker'),
                format  = ff.config.admin.datePicker[time ? 'formatWithTime' : 'format'],
                date    = Date.parseDate(input.value, "%Y-%m-%dT%H:%M:%S");

            Calendar.setup({
                inputField: input.id,
                displayArea: display.id,
                button: button.id,
                ifFormat: "%Y-%m-%dT%H:%M:%S",
                daFormat: format,
                firstDay: 1,
                showsTime: time,
                timeFormat: 24,
                date: input.value
            });
            
            display.value = date.print(format);
            
        });
 	}
  
});

//
// Inject Rails' authenticity token to all AJAX requests

$.ajaxSetup({
    beforeSend: function(request) {
        this.type = this.type.toLowerCase();
						
		/*
		if (this.type != 'get' && this.type != 'post') {
		    this.data = ff.util.appendURIComponent(this.data, '_method', this.type, true);
		    this.type = 'post';
		}
		*/
		
		if (this.type == 'post') {
		    this.data = ff.util.appendURIComponent(this.data, 'authenticity_token', AUTHENTICITY_TOKEN, false);
		}
	}
});

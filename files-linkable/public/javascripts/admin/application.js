$(function() {
    ff.init();
});

$.rebind(function(context) {
  
    /*
     * Rich-text editors
     */
    if (typeof $.fn.tinymce == 'function') {
        $('textarea.tinymce').each(function() {
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
        $('.datetime-picker, .date-picker').each(function() {

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
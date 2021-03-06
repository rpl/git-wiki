jQuery.fn.disableSelection = function() {
    return this.attr('unselectable', 'on')
               .css('MozUserSelect', 'none')
               .bind('selectstart.ui', function() { return false; });
};

jQuery.fn.historyTable = function() {
    $(this).disableSelection();
    var rows = $('tbody tr', this);
    rows.mousedown(function(event) {
        event.preventDefault();

	var from = $(this),
            offset = from.offset(),
            to = null;
	    fromText = $('td:first-child a:first-child', from).text(),
	    fromDate = $('td:nth-child(3)', from).text(),
	    draggable = null;

	function stop() {
	    if (draggable)
                draggable.remove();
	    $(document).unbind('mouseup.history keypress.history');
	    rows.unbind('mouseover.history mousemove.history');
	}

	$(document).bind('mouseup.history', function() {
	    stop();
	    if (to) {
	        var toSha = to.attr('id').substr(7),
	            fromSha = from.attr('id').substr(7),
                    path = location.pathname;
	        if (toSha != fromSha) {
		    path = path.substr(0, path.length - 7);
	            location.href = path + 'diff?from=' + fromSha + '&to=' + toSha;
		}
            }
            return true;
	}).bind('keypress.history', function(event) {
	    stop();
	    return true;
	});

	rows.bind('mousemove.history', function(moveEvent) {
            var distance = Math.abs(event.pageX - moveEvent.pageX) + Math.abs(event.pageY - moveEvent.pageY);
            if (distance > 5) {
                draggable = $('<div class="history-draggable">' + fromText + ' (' + fromDate + ')</div>').css({
                    width: (from.width() - 10) + 'px',
                    height: (from.height() - 4) + 'px',
                    padding: '2px 5px',
                    position: 'absolute',
                    display: 'block',
                    zIndex: 1000,
                    cursor: 'move',
                    top: Math.round(offset.top) + 'px',
                    left: Math.round(offset.left) + 'px'
		}).appendTo('body');
		rows.unbind('mousemove.history');
	    }
            return true;
	}).bind('mouseover.history', function() {
            if (draggable) {
                to = $(this);
		var toText = $('td:first-child a:first-child', to).text(),
		    toDate = $('td:nth-child(3)', to).text(),
		    offset = to.offset();
                draggable.css({
	            top: Math.round(offset.top) + 'px',
		    left: Math.round(offset.left) + 'px'
	        }).html(fromText + ' (' + fromDate + ') &#8594; ' + toText + ' (' + toDate + ')');
	    }
            return true;
	});

	return false;
    });
};

// Wiki bootstrap
// Written by Daniel Mendler
$(function() {
    $('#themes').styleswitcher();

    $('.tabs').tabs();

    $('table.sortable').tablesorter({widgets: ['zebra']});

    $('table.history').historyTable();

    $('.zebra tr:even, .history tr:even').addClass('even');
    $('.zebra tr:odd, .history tr:odd').addClass('odd');

    $('input.placeholder').placeholder();

    $('.date').dateToggler();
    $('label, #menu, .tabs > ul').disableSelection();
    $('#upload-file').change(function() {
        var elem = $('#upload-path'), val, oldpath;
	if (elem.size() == 1) {
	    val = elem.val();
	    oldpath = elem.data('oldpath') || 'new page';
            if (val.length == 0) {
		elem.val(this.value);
		elem.data('oldpath', this.value);
            } else if (val.match(new RegExp('^(.*\/)?' + oldpath + '$'))) {
		val = val.replace(new RegExp(oldpath + '$'), '') + this.value;
		elem.val(val);
		elem.data('oldpath', this.value);
	    }
	}
    });

    $('*[accesskey]').underlineAccessKey();
});

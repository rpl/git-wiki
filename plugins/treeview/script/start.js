$.translations({
    en: {
      menu: 'Menu',
      tree: 'Tree'
    },
    de: {
      menu: 'Menü',
      tree: 'Baumansicht'
    },
});

$(function() {
    if ($.browser.mozilla || $.browser.safari) {
	sidebar = $('#sidebar');
	sidebar.html('<div id="treeview-tabs"><ul><li class="tabs-selected"><a href="#sidebar-menu">' + $.t('menu') +
                     '</a></li><li><a href="#sidebar-treeview">' + $.t('tree') + '</a></li></ul></div>' +
		     '<div id="sidebar-treeview"><h1>' + $.t('tree') +
                     '</h1><div id="treeview"></div></div><div id="sidebar-menu">' + sidebar.html() + '</div>');
	$('#treeview-tabs').tabs({store: 'treeview-tabs'});
	$('#treeview').treeView({stateStore: 'treeview-state', counterStore: 'treeview-counter'});
    }
});

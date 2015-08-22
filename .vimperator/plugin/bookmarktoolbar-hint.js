

liberator.plugins.bookmarkToolbarHints = (function() {
	if (typeof plugins == 'undefined') plugins = liberator.plugins; // for 2.0 pre

	function onKeyPress(event)
    {
		manager.onEvent(event);
		event.stopPropagation();
		event.preventDefault();
	}

	var manager = {
		bk_tbopt_: null,
        where_: liberator.CURERNT_TAB,
        current_: null,
        hints_: [],
        pressed_: "",

		startup: function(where)
        {
			this.where_ = where;
			this.bk_tbopt_ = liberator.modules.options.toolbars;
			liberator.modules.options.toolbars = "bookmarks";
			liberator.modules.modes.setCustomMode(
                    'BookmarksToolbar-Hint',
                    function() { return; },
                    function() { return; });
			liberator.modules.modes.set(
                    liberator.modules.modes.CUSTOM,
                    liberator.modules.modes.QUICK_HINT);
			this.show(document.getElementById('PlacesToolbarItems'), "bottomright");
			window.addEventListener('keypress', onKeyPress, true);
		},

		show: function(target, anchor)
        {
			this.hints_ = [];
			this.pressed_ = "";
			this.current_ = target;
			for (let i = 0; i < target.childNodes.length; i++) {
				let button = target.childNodes[i];
				if (button.localName == "menuseparator") continue;
				this.hints_.push(button);
				let tooltip = this.createTooltip();
                tooltip.showPopup(button, -1, -1, "tooltip", anchor, "topright");
			}
		},

		onEvent: function(event)
        {
			var key = liberator.modules.events.toString(event);
			switch (key)
            {
				case "<Esc>":
				case "<C-[>":
                    closeMenus(this.current_);
                    this.quit();
					break;
				default:
					if (/^[0-9]$/.test(key)) {
						this.pressed_ += key;
						let num = parseInt(this.pressed_, 10);
						if (this.hints_[num-1]) {
							this.pressed_ = "";
                            target = this.hints_[num-1]
                            if (target.getAttribute('container') == 'true') {
                                this.open_folder(target);
                            } else {
                                this.open_item(target);
                                this.quit();
                            }
						}
					}
					break;
			}
		},

        open_item: function(target)
        {
            if (target.hasAttribute('oncommand')) {
                let fn = new Function("event", target.getAttribute("oncommand"));
                if (where_ == liberator.CURRENT_TAB)
                    fn.call(target, { button:0, ctrlKey:false });
                else
                    fn.call(target, { button:1, ctrlKey:true });
            } else {
                liberator.open(target._placesNode.uri, this.where_);
            }
            closeMenus(target);
        },

        open_folder: function(target)
        {
            target.firstChild.showPopup();
			while (tooltipbox.hasChildNodes()) {
				tooltipbox.firstChild.hidePopup();
				tooltipbox.removeChild(tooltipbox.firstChild);
			}
            this.show(target.firstChild, "topleft");
        },

		quit: function()
        {
			window.removeEventListener('keypress', onKeyPress, true);
			while (tooltipbox.hasChildNodes()) {
				tooltipbox.firstChild.hidePopup();
				tooltipbox.removeChild(tooltipbox.firstChild);
			}
            liberator.modules.options.toolbars = this.bk_tbopt_;
			liberator.modules.modes.reset(true);
		},

        createTooltip: function()
        {
            var tooltip = document.createElement('tooltip');
            tooltip.setAttribute('style', 'padding:0; margin:0;');
            var label = document.createElement('label');
            label.setAttribute('value',tooltipbox.childNodes.length+1);
            label.setAttribute('style','padding:0; margin:0 2px;');
            tooltip.appendChild(label);
            tooltipbox.appendChild(tooltip);
            return tooltip;
        },
    };

	var tooltipbox = document.createElement('box');
	tooltipbox.setAttribute('id','liberator-tooltip-container');
	document.getElementById('browser').appendChild(tooltipbox);
	return manager;
})();


liberator.modules.mappings.addUserMap(
    [liberator.modules.modes.NORMAL],
    ['<Leader>f'],
	'Start Toolbar-HINTS (open current tab)',
	function() { liberator.plugins.bookmarkToolbarHints.startup(liberator.CURRENT_TAB); },
	{ rhs: 'Bookmarks Toolbar-HINTS (current-tab)'}
);

liberator.modules.mappings.addUserMap(
    [liberator.modules.modes.NORMAL],
    ['<Leader>F'],
	'Start Toolbar-HINTS (open new tab)',
	function() { liberator.plugins.bookmarkToolbarHints.startup(liberator.NEW_TAB); },
	{ rhs: 'Bookmarks Toolbar-HINTS (new-tab)' }
);


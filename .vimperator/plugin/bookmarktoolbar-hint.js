// ==VimperatorPlugin==
// @name           BookmarksToolbar-Hint
// @description    Feature the BookmarksToolbar-Hint
// @description-ja ブックマークツールバーのヒント機能を提供
// @version        0.2e (mod)
// ==/VimperatorPlugin==
//
// Usage:
// 
// <Leader>f   -> open current tab
// <Leader>F   -> open new tab
//
// Note: <Leader> is `\' by default
//
// duaing BookmarksToolbar-Hint, numbering tooltip is appear.
// the item of matched number will open when type the number
// and <BS> remove pending number or backward to parent (at opening a folder)
//

liberator.plugins.bookmarkToolbarHints = (function() {
    var where_;
    var bk_tbopt_;
    var hints_;
    var key_stack_;
    var current_;

	function start(where)
    {
        where_ = where;
        bk_tbopt_ = liberator.modules.options.toolbars;
        liberator.modules.options.toolbars = "bookmarks";
        liberator.modules.modes.setCustomMode(
                'BookmarksToolbar-Hint',
                function() { return; },
                function() { return; });
        liberator.modules.modes.set(
                liberator.modules.modes.CUSTOM,
                liberator.modules.modes.QUICK_HINT);
        show(document.getElementById('PlacesToolbarItems'), "bottomright");
        window.addEventListener('keypress', onKeyPress, true);
    }

    function show(target, anchor)
    {
        hints_ = [];
        key_stack_ = "";
        current_ = target;
        for (let i = 0; i < target.childNodes.length; i++) {
            let button = target.childNodes[i];
            if (button.localName == "menuseparator") continue;

            let idx = tooltipbox.childNodes.length + 1;
            var tooltip = document.createElement('tooltip');
            tooltip.setAttribute('style', 'padding:0; margin:0;');
            var label = document.createElement('label');
            label.setAttribute('value', idx);
            label.setAttribute('style','padding:0; margin:0 2px;');
            tooltip.appendChild(label);
            tooltipbox.appendChild(tooltip);

            hints_[idx.toString()] = button;
            tooltip.showPopup(button, -1, -1, "tooltip", anchor, "topright");
        }
    }

    function quit()
    {
        window.removeEventListener('keypress', onKeyPress, true);
        while (tooltipbox.hasChildNodes()) {
            tooltipbox.firstChild.hidePopup();
            tooltipbox.removeChild(tooltipbox.firstChild);
        }
        liberator.modules.options.toolbars = bk_tbopt_;
        liberator.modules.modes.reset(true);
    }

	function onKeyPress(event)
    {
        var key = liberator.modules.events.toString(event);
        switch (key)
        {
            case "<Esc>":
            case "<C-[>":
                closeMenus(current_);
                quit();
                break;
            case "l":
                open(hints_[key_stack_]);
                break;
            default:
                if (/^[0-9]$/.test(key)) {
                    key_stack_ += key;
                    let regex = new RegExp("^" + key_stack_);
                    let cnt = 0;
                    for (var k in hints_)
                        if (regex.test(k)) cnt += 1;
                    if (cnt > 1) break;
                    open(hints_[key_stack_]);
                }
                break;
        }
		event.stopPropagation();
		event.preventDefault();
    }

    function open(target)
    {
        if (target) {
            if (target.getAttribute('container') == 'true') {
                openFolder(target);
            } else {
                openItem(target);
                quit();
            }
        }
    }

    function openItem(target)
    {
        if (target.hasAttribute('oncommand')) {
            let fn = new Function("event", target.getAttribute("oncommand"));
            if (where_ == liberator.CURRENT_TAB)
                fn.call(target, { button:0, ctrlKey:false });
            else
                fn.call(target, { button:1, ctrlKey:true });
        } else {
            liberator.open(target._placesNode.uri, where_);
        }
        closeMenus(target);
    }

    function openFolder(target)
    {
        target.firstChild.showPopup();
        while (tooltipbox.hasChildNodes()) {
            tooltipbox.firstChild.hidePopup();
            tooltipbox.removeChild(tooltipbox.firstChild);
        }
        show(target.firstChild, "topleft");
    }

	var tooltipbox = document.createElement('box');
	tooltipbox.setAttribute('id','liberator-tooltip-container');
	document.getElementById('browser').appendChild(tooltipbox);

    liberator.modules.mappings.addUserMap(
        [liberator.modules.modes.NORMAL],
        ['<Leader>f'],
        'Start Toolbar-HINTS (open current tab)',
        function() { start(liberator.CURRENT_TAB); },
        { rhs: 'Bookmarks Toolbar-HINTS (current-tab)'}
    );

    liberator.modules.mappings.addUserMap(
        [liberator.modules.modes.NORMAL],
        ['<Leader>F'],
        'Start Toolbar-HINTS (open new tab)',
        function() { start(liberator.NEW_TAB); },
        { rhs: 'Bookmarks Toolbar-HINTS (new-tab)' }
    );
})();


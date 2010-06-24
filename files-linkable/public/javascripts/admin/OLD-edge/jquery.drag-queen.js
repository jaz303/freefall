function DragWidget(root, options) {
    
    var self = this;
    
    this.options = $.extend({}, { nodeClass: DragWidget.Node, extensions: {} }, options || {});
    
    this.$root      = $(root);
    this.dragState  = 'off';
    this.locked     = 0;
    this.nodeClass  = this.options.nodeClass;
    
    $.extend(this, this.options.extensions);
    
    this.$root.find('> ul > li').data('drag-queen-root', true);
    this.attachLocalBehaviours(root);
    this.$dragBadge = $('<div class="drag-widget-badge"></div>').hide().appendTo(document.body);
    
    $(this.root).mousemove(function(evt) {
        if (self.dragState == 'active') self.updateDragBadge(evt);
    }).hover(function() {}, function() {
		self.$dragBadge.hide();
		self.dragState = 'off';
	});
    
};

DragWidget.nodeForElement = function(element, ctor) {
    var node, $element = $(element).closest('li');
    if (!(node = $element.data('drag-queen-node'))) {
        node = new ctor($element);
        $element.data('drag-queen-node', node);
    }
    return node;
};

DragWidget.prototype = {
    
    //
    // Locking
    
    lock: function() { this.locked++; },
    unlock: function() { this.locked--; },
    isLocked: function() { return this.locked > 0; },
    
    //
    // Behaviours
    
    attachLocalBehaviours: function(root) {
        
        var self = this;
        
        // Disable text selection
        $('.item', root).each(function() {
           this.onselectstart = function() { return false; };
           this.unselectable = 'on';
           this.style.MozUserSelect = 'none';
        });
        
        // Highlight drop validity on hover
        $('.item', root).hover(function() {
            if (self.dragState == 'active') {
                if (self.nodeFor(this).acceptsDrop(self.getSelectedNodes())) {
                    $(this).addClass('drop-target-valid');
                } else {
                    $(this).addClass('drop-target-invalid');
                }
            }
        }, function() {
            $(this).removeClass('drop-target-valid')
                   .removeClass('drop-target-invalid');
        });

        // Mouse down for drag start + add to selection
        $('.item', root).mousedown(function(evt) {
            if (self.isLocked()) return;
            if (!evt.metaKey) self.clearSelection();
            self.toggleSelected(this);
            self.dragState = 'waiting';
            self.dragStart = [evt.pageX, evt.pageY];
        });
        
        // Drag start on mouse move
        $('.item', root).mousemove(function(evt) {
            if (self.dragState == 'waiting') {
                var dx = Math.abs(evt.pageX - self.dragStart[0]);
                var dy = Math.abs(evt.pageY - self.dragStart[1]);
                if (dx > 2 || dy > 2) {
                    self.makeSelected(this);
                    self.dragState = 'active';
                }
            }
        });

        // Drop
        $('.item', root).mouseup(function(evt) {
            
            var targetNode = self.nodeFor(this),
                selectedNodes = self.getSelectedNodes();
            
            if (self.dragState == 'active') {
                self.$dragBadge.hide();
                self.loadChildrenFor(targetNode, function(targetList) {
                    if (targetNode.acceptsDrop(selectedNodes)) {
                        targetNode.dropWillOccur(selectedNodes, function(outcome) {
                            if (typeof outcome == 'string') {
                                self.removeSelection();
                                self.setChildrenHTML(targetNode.getRootElement().find('> ul'), outcome);
                            } else if (outcome === true) {
                                $.each(sel.getSelection(), function(ele) {
                                    $(this).closest('li').appendTo(targetList);
                                });
                            }
                            if (outcome !== false) self.toggleVisibility(targetList, true);
                            self.clearSelection();
                        });
                    }                   
                });
            }
            
            self.dragState = 'off';
        
        });
        
        // Reordering
        $('.reorder-target', root).hover(function() {
            if (self.dragState == 'active') {
                if (self.nodeFor(this).acceptsInsertBefore(self.getSelectedNodes())) {
                    $(this).addClass('reorder-target-valid');
                } else {
                    $(this).addClass('reorder-target-invalid');
                }
            }
        }, function() {
            $(this).removeClass('reorder-target-valid')
                   .removeClass('reorder-target-invalid');
        }).mouseup(function(evt) {
            
            var targetNode = self.nodeFor(this),
                selectedNodes = self.getSelectedNodes();
            
            if (self.dragState == 'active') {
                self.$dragBadge.hide();
                if (targetNode.acceptsInsertBefore(selectedNodes)) {
                    targetNode.insertBeforeWillOccur(selectedNodes, function(outcome) {
                        if (typeof outcome == 'string') {
                            self.removeSelection();
                            self.setChildrenHTML(targetNode.getParent().getRootElement().find('> ul'), outcome);
                        } else if (outcome === true) {
                            $.each(self.getSelection(), function(ele) {
                                $(this).closest('li').insertBefore(targetNode.getRootElement());
                            });
                        }
                        self.clearSelection();
                    });
                }
            }
            
            self.dragState = 'off';
        
        });
        
        // Prevent mousedown on expander from bubbling to select row
        $('.expander', root).mousedown(function(evt) { evt.stopPropagation(); });
        
        // Toggle expansion
        $('.expander', root).click(function(evt) {
            self.loadChildrenFor(self.nodeFor(this), function(childList) {
                self.toggleVisibility(childList);
            });
            return false;
        });
        
		self.customBehaviours(root);

    },
    
    // ensure a node's children are loaded, firing callback on completion
    // callback will receive jQuery object wrapping entire child list.
    loadChildrenFor: function(node, after) {
        var self = this, $root = node.getRootElement(), $children = $root.find('> ul');
        if ($children.length == 0) {
            node.loadChildren(function(html) {
                $children = $('<ul style="display:none" />').appendTo($root);
                self.setChildrenHTML($children, html);
                if (after) after($children);
            });
        } else {
            if (after) after($children);
        }
    },
    
    setChildrenHTML: function($ul, html) {
        $ul.html(html);
        this.attachLocalBehaviours($ul);
    },
    
    toggleVisibility: function(childList, show) {
        var expander = childList.prev('.item').find('.expander');
        if (!show && childList.is(':visible')) {
            childList.hide();
            expander.removeClass('expanded');
        } else {
            childList.show();
            expander.addClass('expanded');
        }
    },

    updateDragBadge: function(evt) {
        this.$dragBadge.text(this.getSelection().length)
                      .show()
                      .css({left: (evt.pageX + 10) + "px",
                            top:  (evt.pageY + 10) + "px"});
    },
    
    //
    // Nodes
    
    nodeFor: function(ele) {
        return DragWidget.nodeForElement(ele, this.nodeClass);
    },
    
    nodesFor: function(nodes) {
        var self = this;
        return $.map(nodes, function(n) { return self.nodeFor(n); });
    },
    
    //
    // Selections
    
    hasSelection: function() {
        return this.getSelection().length > 0;
    },

    getSelection: function() {
        return $('.item.selected', this.root);
    },
    
    clearSelection: function() {
        $('.item', this.root).removeClass('selected');
    },
    
    makeSelected: function(ele) {
        $(ele).addClass('selected');
    },
    
    toggleSelected: function(ele) {
        $(ele).toggleClass('selected');
    },
    
    getSelectedNodes: function() {
        return this.nodesFor(this.getSelection());
    },
    
    removeSelection: function() {
        $.each(this.getSelection(), function(ele) {
            $(this).closest('li').remove();
        });
    },
    
    //
    // User-overridable event hooks
    
    /**
     * Override this function to preprocess any nodes before they are displayed.
     * in the widget. For example, you might want to initialise some tooltips.
     */
    customBehaviours: function(root) {}

    
};

DragWidget.Node = function($node) {
    this.$node = $node;
};

DragWidget.Node.extend = function(methods) {
    var nodeClass = function($node) { this.$node = $node; };
    $.extend(nodeClass.prototype, DragWidget.Node.prototype, methods || {});
    return nodeClass;
};

$.extend(DragWidget.Node.prototype, {
    
    //
    // Public API - methods you may wish to override
    
    // Returns true of all nodes can become children of this node
    acceptsDrop: function(nodes) {
        if (!this.isContainer()) return false;
        return this.ensureNoNodesOnAncestorChain(nodes);
    },
    
    /**
     * Called when items have been dropped onto a node, after an acceptsDrop()
     * test has been passed. A callback function is supplied in order to commit
     * the drop; this enables asynchronous (e.g. AJAX) operation.
     *
     * after() takes a single parameter. Pass string to set the HTML for all
     * child elements of the target node. Pass true if to indicate that the
     * operation succeeded and that the widget should append the moved nodes to
     * the new target itself. Pass false if the operation failed.
     *
     * If you're going to do anything that takes a significant amount of time
     * it's probably best to lock() the widget - remember to unlock() after...
     *
     * It is not permissible to modify the selection in this function.
     *
     * @param droppedNodes array of dropped nodes
     * @param after call this function to commit/cancel the drop operation
     */
    dropWillOccur: function(droppedNodes, after) {
        after(true);
    },
    
    // Returns true if all nodes can be inserted before this node
    acceptsInsertBefore: function(nodes) {
        return this.ensureNoNodesOnAncestorChain(nodes);
    },
    
    insertBeforeWillOccur: function(insertedNodes, after) {
        after(true);
    },
    
    // Implement custom logic for loading child nodes here.
    // after - call this function once you've loaded the children, passing their
    //         representative HTML. this should be a series of <li>...</li> tags
    //         with *no* surrounding <ul>...</ul> tags, or an empty string if no
    //         children exist. you don't need to set up event handlers etc here,
    //         this will be handled later.
    loadChildren: function(after) {
        after('');
    },
    
    //
    // Public API - methods you probably want to leave alone
    
    // Returns the root <li/> wrapping the node element
    getRootElement: function() {
        return this.$node;
    },
    
    getParent: function() {
        return this.isRoot() ? null : DragWidget.nodeForElement(this.$node[0].parentNode, this.constructor);
    },
    
    //
    // The following methods do not form part of the public API but are relied upon by
    // the default Node implementation.
    
    isRoot: function() {
        return !! this.$node.data('drag-queen-root');
    },
    
    isContainer: function() {
        return true;
    },
    
    equals: function(that) {
        return this.$node[0] == that.$node[0];
    },
    
    ensureNoNodesOnAncestorChain: function(nodes) {
        for (var i = 0; i < nodes.length; i++) {
            var tmp = this;
            while (tmp) {
                if (tmp.equals(nodes[i])) return false;
                tmp = tmp.getParent();
            }
        }
        return true;
    }
    
});

module: llist

define class <llist-node-base> (<object>) end;
define class <llist-node-nil> (<llist-node-base>) end;
define constant $nil = make(<llist-node-nil>);

define class <llist-node> (<llist-node-base>)
    slot prev :: <llist-node-base>, required-init-keyword: prev:;
    slot next :: <llist-node-base>, required-init-keyword: next:;
    constant slot data :: <string>, required-init-keyword: data:;
end class;

define class <llist> (<collection>)
    slot head_ :: <llist-node-base>, init-value: $nil;
    slot tail_ :: <llist-node-base>, init-value: $nil;
end class;

define method add! (l :: <llist>, d :: <string>) => (l :: <llist>)
    let new = make(<llist-node>, prev: l.tail_, next: $nil, data: d);
    if (l.empty?)
        l.head_ := new;
        l.tail_ := new;
    else
        l.tail_.next := new;
        l.tail_ := new;
    end;
    l
end method;

define method forward-iteration-protocol (l :: <llist>) =>
    (
        initial-state :: <llist-node-base>,
        limit :: <llist-node-nil>,
        next-state :: <function>,
        finished-state? :: <function>,
        current-key :: <function>,
        current-element :: <function>,
        current-element-setter :: <function>,
        copy-state :: <function>
    )
    values
    (
        l.head_,
        $nil,
        method(l, n) n.next end,
        method(l, n, _) n == $nil end,
        method(l, n) 0 end,
        method(l, n) n.data end,
        method(v, l, n) end,
        method(l, n) n end
    )
end method;

define class <llist-iter> (<object>)
    constant slot llist :: <llist>, required-init-keyword: llist:;
    constant slot node :: <llist-node-base>, required-init-keyword: node:;
end class;

define method iterator (l :: <llist>) => (iterator :: <llist-iter>)
    make(<llist-iter>, llist: l, node: l.head_)
end method;

define method data (i :: <llist-iter>) => (data :: <string>)
    i.node.data
end method;

define method erased? (i :: <llist-iter>) => (erased? :: <boolean>)
    i.node.prev == $nil & i.node.next == $nil & i.node ~= i.llist.head_
end method;

define method valid? (i :: <llist-iter>) => (valid? :: <boolean>)
    i.node ~= $nil & ~i.erased?
end method;

define method next (i :: <llist-iter>) => (next-iter :: <llist-iter>)
    assert(i.valid?);
    make(<llist-iter>, llist: i.llist, node: i.node.next)
end method;

define method prev (i :: <llist-iter>) => (prev-iter :: <llist-iter>)
    assert(i.valid?);
    make(<llist-iter>, llist: i.llist, node: i.node.prev)
end method;

define method insert-before (i :: <llist-iter>, d :: <string>)
    assert(i.valid?);
    let new = make(<llist-node>, prev: i.node.prev, next: i.node, data: d);
    i.node.prev := new;
    if (new.prev == $nil) i.llist.head_ := new; end;
end method;

define method insert-after (i :: <llist-iter>, d :: <string>)
    assert(i.valid?);
    let new = make(<llist-node>, prev: i.node, next: i.node.next, data: d);
    i.node.next := new;
    if (new.next == $nil) i.llist.tail_ := new; end;
end method;

define method insert-before (i :: <llist-iter>, src-list :: <llist>)
    assert(i.valid?);
    if (~src-list.empty?)
        let dst-list = i.llist;
        let before = i.node.prev;
        let after = i.node;
        let first = src-list.head_;
        let last = src-list.tail_;

        if (before == $nil)
            dst-list.head_ := first;
        else
            before.next := first;
        end;

        after.prev := last;
        first.prev := before;
        last.next := after;
    end;
    src-list.head_ := $nil;
    src-list.tail_ := $nil;
end method;

define method erase (i :: <llist-iter>)
    assert(i.valid?);
    let l = i.llist;
    if (i.node == l.head_) l.head_ := i.node.next; end;
    if (i.node == l.tail_) l.tail_ := i.node.prev; end;
    let (p, n) = values(i.node.prev, i.node.next);
    if (p ~= $nil) p.next := i.node.next; end;
    if (n ~= $nil) n.prev := i.node.prev; end;
    i.node.next := $nil;
    i.node.prev := $nil;
end method;

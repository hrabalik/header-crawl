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

define method push-front (l :: <llist>, d :: <string>)
    if (l.empty?)
        l.head_ := make(<llist-node>, prev: $nil, next: $nil, data: d);
        l.tail_ := l.head_;
    else
        let new = make(<llist-node>, prev: $nil, next: l.head_, data: d);
        l.head_.prev := new;
        l.head_ := new;
    end;
end method;

define method push-back (l :: <llist>, d :: <string>)
    if (l.empty?)
        l.head_ := make(<llist-node>, prev: $nil, next: $nil, data: d);
        l.tail_ := l.head_;
    else
        let new = make(<llist-node>, prev: l.tail_, next: $nil, data: d);
        l.tail_.next := new;
        l.tail_ := new;
    end;
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

define method data (i :: <llist-iter>) => (data :: <string>)
    i.node.data
end method;

define method valid? (i :: <llist-iter>) => (valid? :: <boolean>)
    i.node ~= $nil
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

define method erased? (i :: <llist-iter>) => (erased? :: <boolean>)
    i.node.prev == $nil & i.node.next == $nil & i.node ~= i.llist.head_
end method;

define method erase (i :: <llist-iter>)
    assert(i.valid? & ~i.erased?);
    let l = i.llist;
    if (i.node == l.head_) l.head_ := i.node.next; end;
    if (i.node == l.tail_) l.tail_ := i.node.prev; end;
    let (prev, next) = values(i.node.prev, i.node.next);
    if (prev ~= $nil) prev.next := i.node.next; end;
    if (next ~= $nil) next.prev := i.node.prev; end;
    i.node.next := $nil;
    i.node.prev := $nil;
end method;

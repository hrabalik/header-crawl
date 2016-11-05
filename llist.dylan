module: llist

define class <llist-node-base> (<object>) end;
define class <llist-node-nil> (<llist-node-base>) end;
define constant $nil = make(<llist-node-nil>);

define class <llist-node> (<llist-node-base>)
    slot prev :: <llist-node-base>, required-init-keyword: prev:;
    slot next :: <llist-node-base>, required-init-keyword: next:;
    constant slot data :: <string>, required-init-keyword: data:;
end;

define class <llist> (<object>)
    slot head_ :: <llist-node-base>, init-value: $nil;
    slot tail_ :: <llist-node-base>, init-value: $nil;
end;

define method empty? (l :: <llist>) => (empty? :: <boolean>)
    l.head_ == $nil
end;

define method push-front (l :: <llist>, d :: <string>)
    if (l.empty?)
        l.head_ := make(<llist-node>, prev: $nil, next: $nil, data: d);
        l.tail_ := l.head_;
    else
        let new = make(<llist-node>, prev: $nil, next: l.head_, data: d);
        l.head_.prev := new;
        l.head_ := new;
    end;
end;

define method push-back (l :: <llist>, d :: <string>)
    if (l.empty?)
        l.head_ := make(<llist-node>, prev: $nil, next: $nil, data: d);
        l.tail_ := l.head_;
    else
        let new = make(<llist-node>, prev: l.tail_, next: $nil, data: d);
        l.tail_.next := new;
        l.tail_ := new;
    end;
end;

define class <llist-iter> (<object>)
    constant slot llist :: <llist>, required-init-keyword: llist:;
    constant slot node :: <llist-node-base>, required-init-keyword: node:;
end;

define method data (i :: <llist-iter>) => (data :: <string>)
    i.node.data
end;

define method valid? (i :: <llist-iter>) => (valid? :: <boolean>)
    i.node ~= $nil
end;

define method next (i :: <llist-iter>) => (next-iter :: <llist-iter>)
    assert(i.valid?);
    make(<llist-iter>, llist: i.llist, node: i.node.next)
end;

define method prev (i :: <llist-iter>) => (prev-iter :: <llist-iter>)
    assert(i.valid?);
    make(<llist-iter>, llist: i.llist, node: i.node.prev)
end;

define method insert-before (i :: <llist-iter>, d :: <string>)
    let new = make(<llist-node>, prev: i.node.prev, next: i.node, data: d);
    i.node.prev := new;
    if (new.prev == $nil) i.llist.head_ := new; end;
end;

define method insert-after (i :: <llist-iter>, d :: <string>)
    let new = make(<llist-node>, prev: i.node, next: i.node.next, data: d);
    i.node.next := new;
    if (new.next == $nil) i.llist.tail_ := new; end;
end;

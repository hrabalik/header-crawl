module: dylan-user

define library header-crawl
  use common-dylan;
  use io;
  use system;
  use regular-expressions;
  use strings;
  use collections;
end library header-crawl;

define module llist
  use common-dylan;
  export
    <llist>, head-iterator, tail-iterator,
    <llist-iter>, data, valid?, next, prev, insert-before, insert-after, erase;
end module llist;

define module header-crawl
  use common-dylan;
  use format-out;
  use streams;
  use file-system;
  use llist;
  use strings;
  use regular-expressions;
  use table-extensions;
end module header-crawl;

module: dylan-user

define library header-crawl
  use common-dylan;
  use io;
  use system;
end library header-crawl;

define module llist
  use common-dylan;
  export
    <llist>, push-front, push-back,
    <llist-iter>, data, valid?, next, prev, insert-before, insert-after, erase;
end module llist;

define module header-crawl
  use common-dylan;
  use format-out;
  use streams;
  use file-system;
end module header-crawl;

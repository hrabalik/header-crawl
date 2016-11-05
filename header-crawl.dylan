module: header-crawl

define method main (name :: <string>, arguments :: <vector>)
  format-out("Hello, world!\n");
end;

main(application-name(), application-arguments());

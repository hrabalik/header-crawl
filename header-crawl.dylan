module: header-crawl

define method read-file (filename :: <string>) => (lines :: <llist>)
    let result = make(<llist>);

    if (~file-exists?(filename))
        format-out("File \"%s\" doesn't exist.\n", filename);
    else
        let properties = file-properties(filename);
        if (~element(properties, #"readable?"))
            format-out("File \"%s\" is not readable.\n", filename);
        else
            let file-stream = make(<file-stream>, locator: filename);

            block (done)
                while (#t)
                    let (line, eol) = read-line(file-stream,
                                                on-end-of-stream: "");
                    add!(result, line);
                    if (~eol) done(); end;
                end;
            cleanup
                file-stream.close;
            end;

            result // return stretchy vector of lines
        end;
    end;

    result
end method;

define method matches?(s :: <string>, r :: <regex>) => (match? :: <boolean>)
    let match :: false-or(<regex-match>) = regex-search(r, s);
    if (match) #t else #f; end;
end method;

define method extract(s :: <string>, r :: <regex>) => (got :: <string>)
    let match :: false-or(<regex-match>) = regex-search(r, s);
    if (match)
        let result = match-group(match, 1);
        if (result) result else "" end;
    else
        ""
    end;
end method;

define constant $comment-regex :: <regex> = compile-regex("^\\s*//.*$");
define method remove-boring-lines! (lines :: <llist>)
    let i = lines.head-iterator;
    while (i.valid?)
        let j = i;
        i := i.next;
        if (j.data == "" | matches?(j.data, $comment-regex))
            j.erase;
        end;
    end;
end method;

define constant $ifndef-regex :: <regex> = compile-regex("^#ifndef (\\S*).*$");
define constant $define-regex :: <regex> = compile-regex("^#define (\\S*).*$");
define constant $endif-regex :: <regex> = compile-regex("^#endif.*$");
define method remove-include-guard! (lines :: <llist>)
    let i = lines.head-iterator;
    let j = lines.tail-iterator;
    if (i.valid? & next(i).valid? & j.valid?)
        let name1 :: <string> = extract(i.data, $ifndef-regex);
        let name2 :: <string> = extract(next(i).data, $define-regex);
        let endif :: <boolean> = matches?(j.data, $endif-regex);
        if (name1 ~= "" & string-equal?(name1, name2) & endif)
            next(i).erase;
            i.erase;
            j.erase;
        end;
    end;
end;

define method main (args :: <vector>)
    if (args.size == 0)
        format-out("Welcome to header-crawl!\n");
        format-out("Please specify a filename to crawl.\n");
        exit-application(1);
    end;

    let filename :: <string> = element(args, 0);
    let lines = read-file(filename);
    remove-boring-lines!(lines);
    remove-include-guard!(lines);

    for (line in lines)
        format-out("%s\n", line);
    end;

    format-out("Got %d lines.\n", lines.size);
end method;

main(application-arguments());

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

define constant $strip-file-regex :: <regex> = compile-regex("^(.*/).*$");
define constant $strip-up-regex :: <regex> = compile-regex("^\\.\\./(.*)$");
define constant $strip-dir-regex :: <regex> = compile-regex("^(.*/).*/$");
define method join-paths(path :: <string>, rel :: <string>) => (out :: <string>)
    let dir = extract(path, $strip-file-regex);
    while (extract(rel, $strip-up-regex) ~= "")
        rel := extract(rel, $strip-up-regex);
        dir := extract(dir, $strip-dir-regex);
    end;
    concatenate(dir, rel)
end method;

define constant $include-regex :: <regex> = compile-regex(
    "^#include \"([a-zA-Z0-9._\\- \\\\/]*)\".*$");
define method crawl (file :: <string>) => (source :: <llist>)
    if (#t) // TODO add visited check
        format-out("Entering: '%s'\n", file);
        force-out();
        let lines = read-file(file);
        remove-boring-lines!(lines);
        remove-include-guard!(lines);

        let i = lines.head-iterator;
        while (i.valid?)
            let included-file = extract(i.data, $include-regex);
            if (included-file ~= "")
                let included-path = join-paths(file, included-file);
                crawl(included-path);
            end;
            i := i.next;
        end;

        lines
    else
        make(<llist>)
    end;
end;

define method main (args :: <vector>)
    if (args.size == 0)
        format-out("Welcome to header-crawl!\n");
        format-out("Please specify a filename to crawl.\n");
        exit-application(1);
    end;

    let filename :: <string> = element(args, 0);
    let lines = crawl(filename);

    for (line in lines)
        format-out("%s\n", line);
    end;

    format-out("Got %d lines.\n", lines.size);
end method;

main(application-arguments());

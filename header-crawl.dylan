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
                    push-back(result, line); //add!(result, line);
                    if (~eol) done(); end;
                end;
            cleanup
                file-stream.close;
            end;

            result // return stretchy vector of lines
        end;
    end;

    result
end;

define method main (args :: <vector>)
    if (args.size == 0)
        format-out("Welcome to header-crawl!\n");
        format-out("Please specify a filename to crawl.\n");
        exit-application(1);
    end;

    let filename :: <string> = element(args, 0);
    let lines = read-file(filename);

    for (line in lines)
        format-out("%s\n", line);
    end;

    format-out("Got %d lines.\n", lines.size);
end;

main(application-arguments());

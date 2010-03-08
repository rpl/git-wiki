author       'Daniel Mendler'
description  'Emacs org-mode filter'
dependencies 'engine/filter'

Filter.create :orgmode do |content|
  begin
    file = Tempfile.new('orgmode')
    ### WORKAROUND: generated html will be titled with the tempfile name without an explicit title metadata
    file.write("#+TITLE: #{context.resource.title}\n")
    file.write(content)
    file.close

    ### WORKAROUND: explicit enable org-mode on temp file
    `/usr/bin/emacs --batch -l org --eval '(setq org-export-headline-levels 3 org-export-with-toc nil org-export-author-info nil)'\
    --visit='#{file.path}' --funcall org-mode --funcall org-export-as-html-batch >/dev/null 2>&1`


    result = File.read(file.path + '.html')
    result =~ /<body>(.*)<\/body>/m;
    $1
  ensure
    File.unlink(file.path) rescue nil
    File.unlink(file.path + '.html') rescue nil
  end
end

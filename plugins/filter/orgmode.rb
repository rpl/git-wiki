author       'Daniel Mendler'
description  'Emacs org-mode filter'
dependencies 'engine/filter'

Filter.create :orgmode do |content|
  begin
    file = Tempfile.new('orgmode')
    file.write(content)
    file.close

    ### WORKAROUND: explicit enable org-mode on temp file
    `/usr/bin/emacs --batch -l org --eval '(setq org-export-headline-levels 3 org-export-with-toc nil org-export-author-info nil)'\
    --visit='#{file.path}' --funcall org-mode --funcall org-export-as-html-batch >/dev/null 2>&1`


    result = File.read(file.path + '.html')
    result =~ /<body>(.*)<\/body>/m;
    ### WORKAROUND: generated html will be titled with the tempfile name (remove it)
    result =~ /<h1 class="title">#{File.basename file.path}<\/h1>(.*)/m;
    $1
  ensure
    File.unlink(file.path) rescue nil
    File.unlink(file.path + '.html') rescue nil
  end
end

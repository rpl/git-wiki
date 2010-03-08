def xslt_engine(name, opts = {})
  engine name do
    is_cacheable
    has_priority 2
    accepts "text/x-#{opts[:markup]}"
    mime opts[:mime]
    filter :remove_metadata, :remove_comments, :math
    filter :tag do
      filter opts[:markup], :rubypants
    end
    filter :toc, :html_wrapper, opts[:xslt]
  end
end

def markup_engine(name, opts = {})
  engine name do
    needs_layout
    is_cacheable
    has_priority opts[:priority]
    accepts(opts[:accepts] || "text/x-#{name}")
    filter :remove_metadata, :remove_comments, :math
    filter :tag do
      filter name, :rubypants
    end
    filter :toc
  end

  xslt_engine :s5, :markup => name, :xslt => :s5, :mime => 'application/xhtml+xml; charset=utf-8'
  xslt_engine :latex, :markup => name, :xslt => 'xhtml2latex.xsl', :mime => 'text/plain; charset=utf-8'
end

engine :creole do
  needs_layout
  is_cacheable
  has_priority 1
  accepts 'text/x-creole'
  filter :editsection do
    filter :remove_metadata, :remove_comments, :math
    filter :tag do
      filter :creole, :rubypants
    end
  end
  filter :toc
end

xslt_engine :s5, :markup => :creole, :xslt => :s5, :mime => 'application/xhtml+xml; charset=utf-8'
xslt_engine :latex, :markup => :creole, :xslt => 'xhtml2latex.xsl', :mime => 'text/plain; charset=utf-8'

markup_engine :textile
markup_engine :markdown
markup_engine :maruku, :priority => 2, :accepts => 'text/x-markdown|text/x-maruku'
markup_engine :orgmode, :priority => 1, :accepts => 'text/x-orgmode'

author       'Daniel Mendler'
description  'Safe html tags'
dependencies 'filter/tag'

HTML_TAGS = {
  :a => %w(href title),
  :img => %w(src alt title),
  :br => [],
  :i => [],
  :u => [],
  :b => [],
  :pre => [],
  :kbd => [],
  # provided by syntax highlighter
  # :code => %w(lang),
  :cite => [],
  :strong => [],
  :em => [],
  :ins => [],
  :sup => [],
  :sub => [],
  :del => [],
  :table => [],
  :tr => [],
  :td => %w(colspan rowspan),
  :th => [],
  :ol => %w(start),
  :ul => [],
  :li => [],
  :p => [],
  :h1 => [],
  :h2 => [],
  :h3 => [],
  :h4 => [],
  :h5 => [],
  :h6 => [],
  :blockquote => %w(cite),
  :div => %w(style),
  :span => %w(style),
  :style => %w(type),
}

HTML_TAGS.each do |name, allowed|
  Tag.define(name) do |context, attrs, content|
    attrs = attrs.select {|k| allowed.include? k }.map {|k,v| %{#{k}="#{Wiki.html_escape v}"} }.join(' ')
    "<#{name}#{attrs.blank? ? '' : ' '+attrs}>#{subfilter(nested_tags(context, content))}</#{name}>"
  end
end
